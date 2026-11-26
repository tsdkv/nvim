local M = {}

function M.show()
    local trace = require("core.load").get_trace()
    local lines = { "Configuration Loader Trace", string.rep("=", 60), "" }
    local row = "%-10s %-9s %-30s %10s  %s"
    table.insert(lines, row:format("Status", "Planned", "Target", "Duration", "Why"))

    local totals = { now = 0, later = 0, event = 0, filetype = 0, ensure = 0 }
    local total_ms = 0

    for _, entry in ipairs(trace) do
        local duration = entry.duration_ms or 0
        total_ms = total_ms + duration

        if entry.trigger then
            totals[entry.trigger] = totals[entry.trigger] + duration
        end

        local why = entry.reason or ""
        if entry.parent then
            why = why .. " by " .. entry.parent
        end
        local dur_str = entry.duration_ms and string.format("%.2fms", duration) or ""
        table.insert(lines, row:format(entry.status, entry.phase, entry.target, dur_str, why))
        if entry.err then
            for _, line in ipairs(vim.split(entry.err, "\n", { plain = true })) do
                table.insert(lines, "    " .. line)
            end
        end
    end

    table.insert(lines, "")
    table.insert(lines, string.rep("-", 60))
    table.insert(lines, string.format("Total Load Time: %.2fms", total_ms))
    table.insert(lines, string.format("  Eager (now):   %.2fms", totals.now))
    table.insert(lines, string.format("  Deferred:      %.2fms", totals.later))
    table.insert(lines, string.format("  Ensure:        %.2fms", totals.ensure))
    table.insert(lines, string.format("  Event/FT:      %.2fms", totals.event + totals.filetype))

    -- Create a scratch buffer
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

    -- Set buffer options
    vim.bo[buf].modifiable = false
    vim.bo[buf].filetype = "loadtrace"
    vim.bo[buf].bufhidden = "wipe"

    -- Open in a vertical split
    vim.cmd("vsplit")
    vim.api.nvim_win_set_buf(0, buf)
end

return M
