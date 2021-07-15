local __is = {}

function __is:__index(key)
	self[key] = function(value)
		if type(value) == tostring(key) then
			return true, value
		else
			return false, key .. " expected, got " .. type(value)
		end
	end
	return self[key]
end

local is = {}

is["nil"] = function(value)
	if value == nil then
		return true, value
	else
		return false, "nil expected, got " .. type(value)
	end
end

return setmetatable(is, __is)
