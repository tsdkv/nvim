-- External Go tools invoked from buffer-local keymaps.

local M = {}

function M.iferr()
    local buf = vim.api.nvim_get_current_buf()
    local row, col = unpack(vim.api.nvim_win_get_cursor(0))
    -- iferr uses one-based byte positions in the source passed on stdin.
    local offset = vim.api.nvim_buf_get_offset(buf, row - 1) + col + 1
    local ok, result = pcall(vim.fn.systemlist, { "iferr", "-pos", tostring(offset) }, buf)
    if not ok or vim.v.shell_error ~= 0 then
        local message = ok and table.concat(result, "\n") or tostring(result)
        vim.notify("iferr: " .. message, vim.log.levels.WARN)
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
                vim.system({
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
                }, { text = true }, function(obj)
                    vim.schedule(function()
                        if obj.code == 0 then
                            vim.cmd("checktime")
                        else
                            vim.notify("gomodifytags failed: " .. (obj.stderr or ""), vim.log.levels.ERROR)
                        end
                    end)
                end)
            end
        )
    end)
end

return M
