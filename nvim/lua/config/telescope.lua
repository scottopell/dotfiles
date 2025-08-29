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

local function diffview_picker()
  local function get_git_refs()
    local refs = {}
    local current_branch = vim.fn.system("git branch --show-current 2>/dev/null | tr -d '\n'")

    -- Get recent branches with metadata (excluding current branch)
    local branch_info = vim.fn.systemlist("git for-each-ref --count=15 --sort=-committerdate refs/heads/ --format='%(refname:short)|%(committerdate:relative)|%(subject)'")
    for _, line in ipairs(branch_info) do
      if line ~= "" and not line:match("^fatal:") then
        local parts = vim.split(line, "|", { plain = true })
        local branch, date, subject = parts[1], parts[2] or "", parts[3] or ""
        -- Skip current branch since it's equivalent to HEAD
        if branch ~= current_branch then
          table.insert(refs, { branch, "branch", date, subject, false })
        end
      end
    end

    -- Get recent tags with metadata
    local tag_info = vim.fn.systemlist("git for-each-ref --count=8 --sort=-creatordate refs/tags/ --format='%(refname:short)|%(creatordate:relative)|%(subject)'")
    for _, line in ipairs(tag_info) do
      if line ~= "" and not line:match("^fatal:") then
        local parts = vim.split(line, "|", { plain = true })
        local tag, date, subject = parts[1], parts[2] or "", parts[3] or ""
        table.insert(refs, { tag, "tag", date, subject, false })
      end
    end

    -- Add special targets
    local head_subject = vim.fn.system("git log -1 --format='%s' HEAD 2>/dev/null | tr -d '\n'")
    table.insert(refs, 1, { "HEAD", "commit", "current", head_subject or "Current commit", false })

    -- Add main/master if they exist and aren't the current branch
    local main_exists = vim.fn.system("git rev-parse --verify main 2>/dev/null") ~= ""
    local master_exists = vim.fn.system("git rev-parse --verify master 2>/dev/null") ~= ""

    if main_exists and "main" ~= current_branch then
      local main_subject = vim.fn.system("git log -1 --format='%s' main 2>/dev/null | tr -d '\n'")
      table.insert(refs, { "main", "branch", "", main_subject or "", false })
    end

    if master_exists and "master" ~= current_branch then
      local master_subject = vim.fn.system("git log -1 --format='%s' master 2>/dev/null | tr -d '\n'")
      table.insert(refs, { "master", "branch", "", master_subject or "", false })
    end

    -- Add origin remotes
    local origin_main_exists = vim.fn.system("git rev-parse --verify origin/main 2>/dev/null") ~= ""
    local origin_master_exists = vim.fn.system("git rev-parse --verify origin/master 2>/dev/null") ~= ""

    if origin_main_exists then
      local origin_main_subject = vim.fn.system("git log -1 --format='%s' origin/main 2>/dev/null | tr -d '\n'")
      table.insert(refs, { "origin/main", "remote", "", origin_main_subject or "", false })
    end

    if origin_master_exists then
      local origin_master_subject = vim.fn.system("git log -1 --format='%s' origin/master 2>/dev/null | tr -d '\n'")
      table.insert(refs, { "origin/master", "remote", "", origin_master_subject or "", false })
    end

    return refs
  end

  local function get_icon_and_color(ref_type)
    local icons = {
      branch = " ",
      tag = " ",
      commit = " ",
      remote = " "
    }

    local colors = {
      branch = "String",
      tag = "Number",
      commit = "Constant",
      remote = "Function"
    }

    return icons[ref_type] or " ", colors[ref_type] or "Normal"
  end

  pickers.new({}, {
    prompt_title = " Select Diff Target",
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
    attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        if selection then
          vim.cmd("DiffviewOpen " .. selection.value)
        end
      end)
      return true
    end,
  }):find()
end

-- Make the function globally accessible
_G.diffview_picker = diffview_picker
