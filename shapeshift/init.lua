--- Validates tables and data.
-- Somewhat inspired by leafo/tableshape, but more functional.
-- @module shapeshift

local shapeshift = {}

--- Validates a table against a prototype.
local function validate_table(prototype, subject, prefix)
	local transformed = {}
	local prefix = prefix or tostring(subject)

	for key, validator in pairs(prototype) do
		if key:sub(1,2) ~= "__" then
			local prefix = prefix and prefix..'.'..tostring(key) or tostring(key)
			local result, message = validator(subject[key])
			if result then
				transformed[key] = result
			else
				return nil, tostring(prefix) .. ": " .. (message or 'Validation Failed')
			end
		end
	end
	return transformed
end

--- Partially applies `shapeshift.table` with a given prototype.
-- Keys not in the prototype get silently dropped.
-- The special option `__extra` can be "drop", "keep" or absent to either drop
-- keys that are not in the prototype, keep them "as is" in the result or
-- (default) throw an error respectively.
-- @tparam table prototype A table mapping keys to value-validations.
-- @tparam string extra When not nil, overrides `__extra` property.
-- @usage
function shapeshift.table(prototype, extra)
	extra = extra or prototype.__extra
	if extra == "drop" then
		return function(subject, prefix)
			return validate_table(prototype, subject)
		end
	elseif extra == "keep" then
		return function(subject, prefix)
			local result, message = validate_table(prototype, subject)
			if result then
				for key in pairs(subject) do
					if not prototype[key] then
						result[key]=subject[key]
					end
				end
			end
			return result, message
		end
	else
		return function(subject, prefix)
			for key in pairs(subject) do
				if not prototype[key] then
					return nil, "Unexpected key: "..tostring(key).." in "..tostring(prefix)
				end
			end
			return validate_table(prototype, subject, prefix)
		end
	end
end

--- A validator that returns the passed-in default object when the subject is `nil`.
function shapeshift.default(default)
	return function(subject)
		if subject == nil then
			return default
		else
			return subject
		end
	end
end

--- Run a list of validations on a subject and fail if none succeeds.
-- The result of the first successful validation is returned.
-- Additional validations will not be tried.
function shapeshift.any(validations)
	return function(subject, prefix)
		local prefix = prefix or tostring(subject)
		for i, validation in ipairs(validations) do
			local result = validation(subject, prefix)
			if result then
				return result
			end
		end
		return false, tostring(prefix)..": Did not meet any validation"
	end
end

--- Runs a list of validations on a subject and succeed if all of them do.
-- The result of each validation is fed into the next one.
-- This allows for validation "pipelines" to continuously transform data.
function shapeshift.all(validations)
	return function(subject, prefix)
		local prefix = prefix or tostring(subject)
		for i, validation in ipairs(validations) do
			local message
			subject, message = validation(subject, prefix)
			if not subject then
				return nil, message
			end
		end
		return subject
	end
end

return shapeshift
