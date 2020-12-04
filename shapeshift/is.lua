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

return setmetatable({}, __is)
