local __is = {}

function __is:__index(key)
	self[key] = function(value)
		if type(value):lower() == tostring(key):lower() then
			return true, value
		else
			return false, key .. " expected, got " .. type(value)
		end
	end
	return self[key]
end

local is = setmetatable({}, __is)

return is
