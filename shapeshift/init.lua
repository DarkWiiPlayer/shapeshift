--- Validates tables and data.
-- Somewhat inspired by leafo/tableshape, but more functional.
-- @module shapeshift

local function deepmodule(prefix)
	return setmetatable({}, {
		__index = function(self, name)
			return require(prefix .. "." .. name)
		end
	})
end
local shapeshift = deepmodule(...)
local NIL = shapeshift.is.NIL

--- Creates an assertion helper.
-- The returned function returns all of its parameters as is
-- except when the first argument is nil,
-- in which case it returns nil plus an error message.
-- Avoid calling in-place, as closure creation is NYI.
-- @tparam string message A fallback-message for the assertion.
-- @treturn function Assertion helper bound to `message`
local function assertion(message)
	return function(...)
		if ... then
			return ...
		else
			return nil, message
		end
	end
end

--- Validates a table against a prototype.
local function validate_table(prototype, subject)
	local transformed = {}

	for key, validator in pairs(prototype) do
		if key:sub(1,2) ~= "__" and subject[key] ~= NIL then
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

--- Static Validators
-- @section validators

--- Tries to convert a value to a number.
function shapeshift.tonumber(subject)
	local number = tonumber(subject)
	if number then
		return number
	else
		return nil, "Could not be converted to number"
	end
end

--- Tries to convert a value to a string.
-- This shouldn't ever fail, but a custom
-- `__tostring` *could* return nil.
function shapeshift.tostring(subject)
	local str = tostring(subject)
	if str then
		return str
	else
		return nil, "Could not be converted to string"
	end
end

--- Validator Generators
-- @section generators

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

--- Makes sure that the subject is a specific object.
function shapeshift.eq(other)
	return function(subject)
		if other == subject then
			return subject
		else
			return nil, string.format("Expected %s to be %s", tostring(subject), tostring(object))
		end
	end
end

--- Transformation that maps values using a table.
function shapeshift.map(map)
	if type(map) == "table" then
		return function(subject)
			local value = map[subject]
			if value then
				return value
			else
				return nil, string.format("Value %s is not a key of %s", tostring(subject), tostring(map))
			end
		end
	elseif type(map) == "function" then
		local as = assertion("Value is not a key of %s"..tostring(map))
		return function(subject)
			return as(map(subject))
		end
	else
		error("Validation mapping is neither table nor function")
	end
end

--- Validates that an object appears in a sequence.
function shapeshift.oneof(sequence)
	local map = {}
	for i, element in ipairs(sequence) do
		map[element]=element
	end
	return shapeshift.map(map)
end

--- Runs a validation only if the subject is not nil.
function shapeshift.maybe(validation)
	return function(subject)
		if subject == nil then
			return NIL
		else
			return validation(subject)
		end
	end
end

--- Run a list of validations on a subject and fail if none succeeds.
-- The result of the first successful validation is returned.
-- Additional validations will not be tried.
function shapeshift.any(validations, ...)
	if type(validations) ~= "table" then
		return shapeshift.any{validations, ...}
	end
	return function(subject)
		local messages = { "Did not meet any validation:", "+++" }
		for i, validation in ipairs(validations) do
			local result, message = validation(subject)
			if result then
				return result
			else
				table.insert(messages, "\t"..tostring(message))
			end
		end
		table.insert(messages, "---")
		return false, table.concat(messages, "\n")
	end
end

--- Runs a list of validations on a subject and succeed if all of them do.
-- The result of each validation is fed into the next one.
-- This allows for validation "pipelines" to continuously transform data.
function shapeshift.all(validations, ...)
	if type(validations) ~= "table" then
		return shapeshift.all{validations, ...}
	end
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

--- Runs a validation on every element of a sequence and fails unless all of them pass.
function shapeshift.each(validation)
	return function(subject)
		for idx, value in ipairs(subject) do
			local message
			value, message = validation(value)
			if not value then
				return nil, "["..idx.."]: "..message
			end
			subject[idx] = value
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

--- Confirms that the input is a string and matches a given pattern.
-- The pattern is *not* anchored and can match anywhere in the string.
-- Add ^ and $ if it should only match the whole string.
function shapeshift.matches(pattern)
	return function(subject)
		if type(subject)=="string" and string.find(subject, pattern) then
			return subject
		else
			return nil, string.format('Subject [[%s]] does not match pattern [[%s]]', subject, pattern)
		end
	end
end

do local match_assertion = assertion("Subject does not match pattern")
	--- Confirms that the input is a string and returns only the match for the given pattern.
	-- The pattern is *not* anchored and can match anywhere in the string.
	-- Add ^ and $ if it should only match the whole string.
	function shapeshift.match(pattern)
		return function(subject)
			if type(subject)=="string" then
				return match_assertion(string.match(subject, pattern))
			else
				return nil, string.format('Subject [[%s]] does not match pattern [[%s]]', subject, pattern)
			end
		end
	end
end

return shapeshift
