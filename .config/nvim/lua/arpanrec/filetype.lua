vim.filetype.add({
    extension = {},
    filename = {
        ['.yamllint'] = 'yaml',
    },
    pattern = {
        ['.*/tasks/.*.yml'] = 'yaml.ansible',
    },
})
