vim.api.nvim_create_user_command("IceUpdate", "lua require('core.utils').update()", { nargs = 0 })
vim.api.nvim_create_user_command("IceHealth", "checkhealth core", { nargs = 0 })

-- Allow a command to be repeated based on v:count1
vim.api.nvim_create_user_command("IceRepeat", function(args)
    for _ = 1, vim.v.count1 do
        vim.cmd(args.args)
    end
end, { nargs = "+", complete = "command" })

-- View the output of a command in an external buffer
vim.api.nvim_create_user_command("IceView", function(args)
    local path = vim.fn.stdpath "data" .. "/ice-view.txt"
    if args.args == "" then
        vim.cmd("edit " .. path)
    else
        vim.cmd(string.format(
            [[
                redir! > %s
                silent %s
                redir END
                edit %s
            ]],
            path,
            args.args,
            path
        ))
    end
end, { nargs = "*", complete = "command" })
