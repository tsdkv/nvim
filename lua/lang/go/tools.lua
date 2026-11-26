-- External Go tools invoked from buffer-local keymaps.

local M = {}
local impl_marks = vim.api.nvim_create_namespace("go.impl")

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
    local buf = vim.api.nvim_get_current_buf()
    local cwd = vim.fn.expand("%:p:h")
    local row = vim.api.nvim_win_get_cursor(0)[1]
    -- Track the insertion point just after the invoking line, including at EOF.
    local mark = vim.api.nvim_buf_set_extmark(buf, impl_marks, row, 0, { right_gravity = false })

    local function release_mark()
        if vim.api.nvim_buf_is_loaded(buf) then
            local pos = vim.api.nvim_buf_get_extmark_by_id(buf, impl_marks, mark, {})
            vim.api.nvim_buf_del_extmark(buf, impl_marks, mark)
            return pos[1]
        end
    end

    local function on_exit(result)
        local insert_at = release_mark()
        if result.code ~= 0 then
            vim.notify("impl failed: " .. (result.stderr or ""), vim.log.levels.ERROR)
        elseif insert_at then
            if not vim.bo[buf].modifiable then
                vim.notify("impl: source buffer is no longer modifiable", vim.log.levels.WARN)
                return
            end
            local lines = vim.split(result.stdout, "\n", { trimempty = true })
            if vim.api.nvim_get_current_buf() == buf and vim.api.nvim_win_get_cursor(0)[1] == insert_at then
                vim.api.nvim_put(lines, "l", true, true)
            else
                vim.api.nvim_buf_set_lines(buf, insert_at, insert_at, true, lines)
            end
        end
    end

    vim.ui.input({ prompt = "Receiver (e.g. 'r *MyStruct'): " }, function(receiver)
        if not receiver or receiver == "" then
            release_mark()
            return
        end
        vim.ui.input({ prompt = "Interface (e.g. 'io.Reader'): " }, function(interface)
            if not interface or interface == "" then
                release_mark()
                return
            end
            local ok, err = pcall(
                vim.system,
                { "impl", receiver, interface },
                { text = true, cwd = cwd },
                vim.schedule_wrap(on_exit)
            )
            if not ok then
                release_mark()
                vim.notify("impl failed: " .. tostring(err), vim.log.levels.ERROR)
            end
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
