-- External CLI tools invoked from keymaps (async via vim.system).

local M = {}

function M.iferr()
    local row, col = unpack(vim.api.nvim_win_get_cursor(0))
    local offset = vim.fn.line2byte(row) + col
    local result = vim.fn.systemlist("iferr -pos " .. offset .. " " .. vim.fn.expand("%"))
    if vim.v.shell_error ~= 0 then
        vim.notify("iferr: " .. table.concat(result, "\n"), vim.log.levels.WARN)
        return
    end
    vim.api.nvim_put(result, "l", true, true)
end

-- Generate method stubs using the "impl" tool
function M.impl()
    vim.ui.input({ prompt = "Receiver (e.g. 'r *MyStruct'): " }, function(receiver)
        if not receiver or receiver == "" then
            return
        end
        vim.ui.input({ prompt = "Interface (e.g. 'io.Reader'): " }, function(interface)
            if not interface or interface == "" then
                return
            end
            -- Run in the current file's directory: impl resolves the receiver
            -- type from the package in its working directory
            local cwd = vim.fn.expand("%:p:h")
            -- Table-form bypasses the shell, eliminating quoting/injection issues
            vim.system({ "impl", receiver, interface }, { text = true, cwd = cwd }, function(obj)
                vim.schedule(function()
                    if obj.code ~= 0 then
                        vim.notify("impl failed: " .. (obj.stderr or ""), vim.log.levels.ERROR)
                        return
                    end
                    local lines = vim.split(obj.stdout, "\n", { trimempty = true })
                    vim.api.nvim_put(lines, "l", true, true)
                end)
            end)
        end)
    end)
end

-- Add or remove struct tags using gomodifytags
function M.modify_tags(clear)
    local fname = vim.fn.expand("%:p")
    local row, col = unpack(vim.api.nvim_win_get_cursor(0))
    local offset = vim.fn.line2byte(row) + col

    if clear then
        vim.system(
            { "gomodifytags", "-file", fname, "-offset", tostring(offset), "-clear-tags", "-w" },
            { text = true },
            function(obj)
                vim.schedule(function()
                    if obj.code == 0 then
                        vim.cmd("checktime")
                    else
                        vim.notify("gomodifytags failed: " .. (obj.stderr or ""), vim.log.levels.ERROR)
                    end
                end)
            end
        )
        return
    end

    vim.ui.input({ prompt = "Add tags (e.g. json,yaml): ", default = "json" }, function(tags)
        if not tags or tags == "" then
            return
        end
        vim.ui.select(
            { "snakecase", "camelcase", "lispcase", "pascalcase", "keep" },
            { prompt = "Transform: " },
            function(transform)
                if not transform then
                    return
                end
                vim.system(
                    {
                        "gomodifytags",
                        "-file",
                        fname,
                        "-offset",
                        tostring(offset),
                        "-add-tags",
                        tags,
                        "-transform",
                        transform,
                        "-w",
                    },
                    { text = true },
                    function(obj)
                        vim.schedule(function()
                            if obj.code == 0 then
                                vim.cmd("checktime")
                            else
                                vim.notify("gomodifytags failed: " .. (obj.stderr or ""), vim.log.levels.ERROR)
                            end
                        end)
                    end
                )
            end
        )
    end)
end

return M
