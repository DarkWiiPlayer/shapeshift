--- Validates tables and data.
-- Somewhat inspired by leafo/tableshape, but more functional.
-- @module shapeshift

local shapeshift = {}

shapeshift.is = require 'shapeshift.is'

--- Validates a table against a prototype.
local function validate_table(prototype, subject)
	local transformed = {}

	for key, validator in pairs(prototype) do
		if key:sub(1,2) ~= "__" then
			local result, message = validator(subject[key])
			if result then
				transformed[key] = result
			else
				return nil, tostring(key) .. ": " .. (message or 'Validation Failed')
			end
		end
	end
	return transformed
end

--- Partially applies `shapeshift.table` with a given prototype.
-- The special option `__extra` can be "drop", "keep" or absent to either drop
-- keys that are not in the prototype, keep them "as is" in the result or
-- (default) throw an error respectively.
-- @tparam table prototype A table mapping keys to value-validations.
-- @tparam string extra When not nil, overrides `__extra` property.
-- @usage
function shapeshift.table(prototype, extra)
	extra = extra or prototype.__extra
	if extra == "drop" then
		return function(subject)
			return validate_table(prototype, subject)
		end
	elseif extra == "keep" then
		return function(subject)
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
		return function(subject)
			for key in pairs(subject) do
				if not prototype[key] then
					return nil, "Unexpected key: "..tostring(key)
				end
			end
			return validate_table(prototype, subject)
		end
	end
end

--- Run a list of validations on a subject and fail if none succeeds.
-- The result of the first successful validation is returned.
-- Additional validations will not be tried.
function shapeshift.any(validations)
	return function(subject)
		local messages = { "+++" }
		for i, validation in ipairs(validations) do
			local result, message = validation(subject)
			if result then
				return result
			else
				table.insert(messages, "\t"..message)
			end
		end
		table.insert(messages, "---")
		return false, "Did not meet any validation:\n"..table.concat(messages, "\n")
	end
end

--- Runs a list of validations on a subject and succeed if all of them do.
-- The result of each validation is fed into the next one.
-- This allows for validation "pipelines" to continuously transform data.
function shapeshift.all(validations)
	return function(subject)
		for i, validation in ipairs(validations) do
			local message
			subject, message = validation(subject)
			if not subject then
				return nil, message
			end
		end
		return subject
	end
end

--- Provides a default value for a test subject.
-- The default is returned when the subject, optionally filtered through another test,
-- returns nil. Otherwise this value is returned unmodified.
function shapeshift.default(default, test)
	return function(subject)
		if test then
			subject = test(subject)
		end
		if subject ~= nil then
			return subject
		else
			return default
		end
	end
end

return shapeshift
