-- luacheck: globals vim

vim.filetype.add({
  extension = {},
  filename = {
    ['.yamllint'] = 'yaml',
  },
  pattern = {
    ['.*/tasks/.*.yml'] = 'yaml.ansible',
    ['.*/tasks/.*.yaml'] = 'yaml.ansible',
    ["galaxy.yml"] = 'yaml.ansible',
    ["galaxy.yaml"] = 'yaml.ansible',
  },
})
