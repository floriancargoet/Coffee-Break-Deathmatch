
global.util = {}

function util.copy(from, to)
    for k, v in pairs(from) do
        to[k] = v
    end
end
