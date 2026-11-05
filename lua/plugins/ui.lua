local colors = {
  red = "#ca1243",
  grey = "#2345f2",
  azul = "#1194B4",
  black = "#200000",
  verde = "#aaaaaa",
  negro = "#000000",
  light_green = "#03a578",
  orange = "#ce5429",
  green = "#8ec07c",
  ama = "#ED872D",
  ginda = "#7F1734",
  lima = "#00FF40",
  oro = "#FFD700",
}

local theme = {
  normal = {
    a = { fg = colors.black, bg = colors.azul, gui = "italic" },
    b = { fg = colors.black, bg = colors.grey },
    c = { fg = colors.verde, bg = colors.black },
  },
  insert = {
    a = { fg = colors.black, bg = colors.ama },
    b = { fg = colors.negro, bg = colors.ama },
    c = { fg = colors.oro, bg = colors.negro },
  },
  visual = {
    a = { fg = colors.black, bg = colors.light_green },
    b = { fg = colors.verde, bg = colors.grey },
    c = { fg = colors.black, bg = colors.negro },
  },
  replace = {
    a = { fg = colors.black, bg = colors.green },
    b = { fg = colors.verde, bg = colors.grey },
    c = { fg = colors.black, bg = colors.negro },
  },
}

local empty = require("lualine.component"):extend()
function empty:draw(default_highlight)
  self.status = ""
  self.applied_separator = ""
  self:apply_highlights(default_highlight)
  self:apply_section_separators()
  return self.status
end

-- Put proper separators and gaps between components in sections
local function process_sections(sections)
  for name, section in pairs(sections) do
    local left = name:sub(9, 10) < "x"
    for pos = 1, name ~= "lualine_z" and #section or #section - 1 do
      table.insert(section, pos * 1, { empty, color = { fg = colors.verde, bg = colors.negro } })
    end
    for id, comp in ipairs(section) do
      if type(comp) ~= "table" then
        comp = { comp }
        section[id] = comp
      end
      comp.separator = left and { right = "" } or { left = "" }
      --comp.separator = left and { right = '' } or { left = '' }
    end
  end
  return sections
end

local function search_result()
  if vim.v.hlsearch == 0 then
    return ""
  end
  local last_search = vim.fn.getreg("/")
  if not last_search or last_search == "" then
    return ""
  end
  local searchcount = vim.fn.searchcount({ maxcount = 9999 })
  return last_search .. "(" .. searchcount.current .. "/" .. searchcount.total .. ")"
end

local function modified()
  if vim.bo.modified then
    return "+"
  elseif vim.bo.modifiable == false or vim.bo.readonly == true then
    return "-"
  end
  return ""
end

require("lualine").setup({
  options = {
    theme = theme,
    --	globalstatus = true, -- one statusline for all windows
    component_separators = { left = "", right = "" },
    section_separators = { left = "", right = "" },
  },
  sections = process_sections({
    lualine_a = {
      {
        "mode",
        fmt = function(str)
          return str:sub(1, 2)
        end,
      },
      {
        "lsp_status",
      },
    },
    lualine_b = {
      {
        "diagnostics",
        source = { "nvim" },
        sections = { "error" },
        diagnostics_color = { error = { bg = colors.red, fg = colors.verde } },
      },
      {
        "diagnostics",
        source = { "nvim" },
        sections = { "warn" },
        diagnostics_color = { warn = { bg = colors.orange, fg = colors.verde } },
      },
      { "filename", file_status = false,        path = 1 },
      { modified,   color = { bg = colors.red } },
      {
        "%w",
        cond = function()
          return vim.wo.previewwindow
        end,
      },
      {
        "%r",
        cond = function()
          return vim.bo.readonly
        end,
      },
      {
        "%q",
        cond = function()
          return vim.bo.buftype == "quickfix"
        end,
      },
    },
    lualine_c = {},
    lualine_x = {
      {
        require("noice").api.status.message.get_hl,
        cond = require("noice").api.status.message.has,
      },
      {
        require("noice").api.status.command.get,
        cond = require("noice").api.status.command.has,
        color = { fg = "#DCE63D" },
      },
      {
        require("noice").api.status.mode.get,
        cond = require("noice").api.status.mode.has,
        color = { fg = "#E63D88" },
      },
      {
        require("noice").api.status.search.get,
        cond = require("noice").api.status.search.has,
        color = { fg = "#473DE6" },
      },
    },
    lualine_y = { search_result, "filetype" },
    lualine_z = { "%l:%c", "%p%%/%L" },
  }),
  inactive_sections = {
    lualine_c = { "%f %y %m" },
    lualine_x = {},
  },
})
require("todo-comments").setup()

require("trouble").setup()
local map = function(lhs, rhs, desc) vim.keymap.set("n", lhs, rhs, { desc = desc, silent = true }) end
map("<leader>hx", "<cmd>Trouble diagnostics toggle<CR>", "Diagnostics (Trouble)")
map("<leader>hb", "<cmd>Trouble diagnostics toggle filter.buf=0<CR>", "Buffer diagnostics")
map("<leader>hq", "<cmd>Trouble qflist toggle<CR>", "Quickfix list")
map("<leader>hl", "<cmd>Trouble loclist toggle<CR>", "Location list")
map("<leader>hs", "<cmd>Trouble symbols toggle focus=false<CR>", "Symbols outline")
map("<leader>ht", "<cmd>TodoTrouble<CR>", "TODO comments (Trouble)")
