local __is = {}

function __is:__index(key)
	self[key] = function(value)
		if type(value) == tostring(key) then
			return value
		else
			return nil, key .. " expected, got " .. type(value)
		end
	end
	return self[key]
end

local is = { NIL = {} }

is["nil"] = function(value)
	if value == nil then
		return is.NIL
	else
		return nil, "nil expected, got " .. type(value)
	end
end

return setmetatable(is, __is)
