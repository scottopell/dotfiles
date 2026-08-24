-- Telescope Configuration
require('telescope').setup({
  extensions = {
    fzf = {
      fuzzy = true,                    -- false will only do exact matching
      override_generic_sorter = true, -- override the generic sorter
      override_file_sorter = true,     -- override the file sorter
      case_mode = "smart_case",        -- or "ignore_case" or "respect_case"
    },
    ['ui-select'] = {
      require('telescope.themes').get_dropdown()
    }
  }
})

-- Load extensions
pcall(require('telescope').load_extension, 'fzf')
pcall(require('telescope').load_extension, 'ui-select')

-- Custom Diffview picker
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

local function git_result(args)
  local command = { "git" }
  vim.list_extend(command, args)
  return vim.system(command, { text = true }):wait()
end

local function git_output(args)
  local result = git_result(args)
  if result.code ~= 0 then
    return ""
  end
  return vim.trim(result.stdout or "")
end

local function git_lines(args)
  local output = git_output(args)
  if output == "" then
    return {}
  end
  return vim.split(output, "\n", { plain = true, trimempty = true })
end

local function diffview_picker()
  local function get_git_refs()
    local refs = {}
    local head_subject = git_output({ "log", "-1", "--format=%s", "HEAD" })

    -- Core options: HEAD and HEAD with untracked
    table.insert(refs, { "HEAD", "commit", "current", head_subject or "Current commit" })
    table.insert(refs, { "-u", "commit", "current", "HEAD with untracked files" })

    -- Check which remote branches exist
    local origin_main_exists = git_output({ "rev-parse", "--verify", "--quiet", "--end-of-options", "origin/main^{commit}" }) ~= ""
    local origin_master_exists = git_output({ "rev-parse", "--verify", "--quiet", "--end-of-options", "origin/master^{commit}" }) ~= ""

    -- Add PR diff (merge-base diff against remote main branch - matches gh pr diff)
    local remote_main_branch = nil
    if origin_main_exists then
      remote_main_branch = "origin/main"
    elseif origin_master_exists then
      remote_main_branch = "origin/master"
    end

    if remote_main_branch then
      local commits_ahead = git_output({ "rev-list", "--count", remote_main_branch .. "..HEAD" })
      local pr_desc = string.format("PR diff (%s commits)", commits_ahead)
      table.insert(refs, { remote_main_branch .. "...HEAD", "pr", "merge-base", pr_desc })
    end

    -- Custom diff bases from git config (comma-separated)
    -- Set per-repo: git config --local custom.diffBases "q-branch-observer,other-branch"
    -- For bare branch names, checks both local and origin/ variants
    local custom_bases = git_output({ "config", "--get", "custom.diffBases" })
    if custom_bases ~= "" then
      for base in custom_bases:gmatch("[^,]+") do
        base = vim.trim(base)
        -- Build list of refs to try: the exact name, plus origin/ prefix for bare names
        local candidates = { base }
        if not base:find("/") then
          table.insert(candidates, "origin/" .. base)
        end
        for _, ref in ipairs(candidates) do
          local valid_ref = git_result({ "check-ref-format", "--branch", ref }).code == 0
          local exists = valid_ref and git_output({ "rev-parse", "--verify", "--quiet", "--end-of-options", ref .. "^{commit}" }) ~= ""
          if exists then
            local commits = git_output({ "rev-list", "--count", ref .. "..HEAD" })
            local desc = string.format("Custom base (%s commits ahead)", commits)
            table.insert(refs, { ref .. "...HEAD", "pr", "merge-base", desc })
          end
        end
      end
    end

    return refs
  end

  local function get_icon_and_color(ref_type)
    local icons = {
      branch = " ",
      tag = " ",
      commit = " ",
      remote = " ",
      pr = " "
    }

    local colors = {
      branch = "String",
      tag = "Number",
      commit = "Constant",
      remote = "Function",
      pr = "Special"
    }

    return icons[ref_type] or " ", colors[ref_type] or "Normal"
  end

  local previewers = require("telescope.previewers")

  pickers.new({}, {
    prompt_title = " Select Diff Target",
    results_title = "Diff Options",
    preview_title = "Preview",
    layout_strategy = "vertical",
    layout_config = {
      vertical = {
        width = 0.9,
        height = 0.9,
        preview_height = 0.6,
        preview_cutoff = 0,
      }
    },
    finder = finders.new_table({
      results = get_git_refs(),
      entry_maker = function(entry)
        local ref, ref_type, date, subject = entry[1], entry[2], entry[3], entry[4]
        local icon, color = get_icon_and_color(ref_type)

        -- Format the display string with better spacing
        local date_display = date ~= "" and string.format(" • %s", date) or ""
        local subject_display = subject ~= "" and string.format(" • %s", subject:sub(1, 60)) or ""

        -- Truncate long subjects with ellipsis
        if #subject > 60 and subject ~= "" then
          subject_display = string.format(" • %s…", subject:sub(1, 57))
        end

        local display = string.format("%s %-30s%s%s", icon, ref, date_display, subject_display)

        return {
          value = ref,
          display = display,
          ordinal = ref .. " " .. subject,
          ref_type = ref_type
        }
      end,
    }),
    sorter = conf.generic_sorter({}),
    previewer = previewers.new_buffer_previewer({
      title = "Diff Preview",
      define_preview = function(self, entry, status)
        local ref = entry.value
        local preview_lines = {}

        if ref == "HEAD" then
          -- Show recent commits for HEAD
          local log_output = git_lines({ "log", "--oneline", "--decorate", "--color=never", "-15", "HEAD" })
          table.insert(preview_lines, "Recent Commits:")
          table.insert(preview_lines, "")
          for _, line in ipairs(log_output) do
            table.insert(preview_lines, line)
          end

        elseif ref == "-u" then
          -- Show untracked files
          local untracked = git_lines({ "ls-files", "--others", "--exclude-standard" })
          table.insert(preview_lines, "Untracked Files:")
          table.insert(preview_lines, "")
          if #untracked == 0 then
            table.insert(preview_lines, "No untracked files")
          else
            for _, file in ipairs(untracked) do
              table.insert(preview_lines, "  " .. file)
            end
          end

          -- Also show unstaged changes
          table.insert(preview_lines, "")
          table.insert(preview_lines, "Unstaged Changes:")
          table.insert(preview_lines, "")
          local unstaged = git_lines({ "diff", "--stat", "HEAD", "--" })
          if #unstaged == 0 then
            table.insert(preview_lines, "No unstaged changes")
          else
            for _, line in ipairs(unstaged) do
              table.insert(preview_lines, line)
            end
          end

        else
          -- For PR diff or other refs, show shortstat + commits
          local shortstat = git_lines({ "diff", "--shortstat", ref, "--" })
          table.insert(preview_lines, "Diff Summary:")
          table.insert(preview_lines, "")
          if #shortstat > 0 then
            for _, line in ipairs(shortstat) do
              table.insert(preview_lines, "  " .. line)
            end
          else
            table.insert(preview_lines, "  No changes")
          end

          table.insert(preview_lines, "")
          table.insert(preview_lines, "Files Changed:")
          table.insert(preview_lines, "")
          local files_stat = git_lines({ "diff", "--stat", ref, "--" })
          for _, line in ipairs(files_stat) do
            table.insert(preview_lines, line)
          end

          -- Show commits in range
          table.insert(preview_lines, "")
          table.insert(preview_lines, "Commits in Range:")
          table.insert(preview_lines, "")
          local commit_range = ref:gsub("%.%.%.", "..")  -- Convert three-dot to two-dot for log
          local commits = git_lines({ "log", "--oneline", "--color=never", commit_range, "--" })
          if #commits == 0 then
            table.insert(preview_lines, "  No commits")
          else
            for _, line in ipairs(commits) do
              table.insert(preview_lines, "  " .. line)
            end
          end
        end

        vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, preview_lines)
      end,
    }),
    attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        if selection then
          vim.api.nvim_cmd({ cmd = "DiffviewOpen", args = { selection.value } }, {})
        end
      end)
      return true
    end,
  }):find()
end

-- Make the function globally accessible
_G.diffview_picker = diffview_picker
