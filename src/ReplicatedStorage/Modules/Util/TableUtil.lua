local tableUtil = {}

function tableUtil.tablesAreEqual(t1, t2)
    if type(t1) ~= type(t2) then
        return false
    end

    if type(t1) ~= "table" then
        return t1 == t2
    end

    if #t1 ~= #t2 then
        return false
    end

    for k, v in (t1) do
        if not tableUtil.tablesAreEqual(v, t2[k]) then
            return false
        end
    end

    return true
end

function tableUtil.tableContainsValue(t, value)
    for _, v in (t) do
        if tableUtil.tablesAreEqual(v, value) then
            return true
        end
    end

    return false
end

return tableUtil
