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
    
    -- Get recent branches
    local recent_branches = vim.fn.systemlist("git for-each-ref --count=10 --sort=-committerdate refs/heads/ --format='%(refname:short)'")
    for _, branch in ipairs(recent_branches) do
      if branch ~= "" and not branch:match("^fatal:") then
        table.insert(refs, { branch, "branch" })
      end
    end
    
    -- Get recent tags
    local recent_tags = vim.fn.systemlist("git tag --sort=-version:refname | head -5")
    for _, tag in ipairs(recent_tags) do
      if tag ~= "" and not tag:match("^fatal:") then
        table.insert(refs, { tag, "tag" })
      end
    end
    
    -- Add common targets
    table.insert(refs, 1, { "HEAD", "commit" })
    table.insert(refs, 2, { "main", "branch" })
    table.insert(refs, 3, { "master", "branch" })
    table.insert(refs, 4, { "origin/main", "remote" })
    table.insert(refs, 5, { "origin/master", "remote" })
    
    return refs
  end

  pickers.new({}, {
    prompt_title = "Select Diff Target",
    finder = finders.new_table({
      results = get_git_refs(),
      entry_maker = function(entry)
        local ref, type = entry[1], entry[2]
        local display = string.format("%-20s (%s)", ref, type)
        return {
          value = ref,
          display = display,
          ordinal = ref,
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