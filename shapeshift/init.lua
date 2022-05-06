--- Validates tables and data.
-- Somewhat inspired by leafo/tableshape, but more functional.
-- @module shapeshift

local function table_map(tab, fn)
	local result = {}
	for idx, value in ipairs(tab) do
		result[idx] = fn(value)
	end
	return result
end

local generic = "Could not validate"

local function deepmodule(prefix)
	return setmetatable({}, {
		__index = function(self, name)
			return require(prefix .. "." .. name)
		end
	})
end
local shapeshift = deepmodule(...)

--- Validates a table against a prototype.
local function validate_table(prototype, subject)
	local transformed = {}

	for key, validator in pairs(prototype) do
		if key:sub(1,2)--[[GC]] ~= "__" then
			local success, result = validator(subject[key])
			if success then
				transformed[key] = result
			else
				return false, tostring(key) .. ": " .. (result or generic)
			end
		end
	end
	return true, transformed
end

--- Static Validators
-- @section validators

--- Tries to convert a value to a number.
function shapeshift.tonumber(subject)
	local number = tonumber(subject)
	if number then
		return true, number
	else
		return false, "Could not be converted to number"
	end
end

--- Tries to convert a value to a string.
-- This shouldn't ever fail, but a custom
-- `__tostring` *could* return nil.
function shapeshift.tostring(subject)
	local str = tostring(subject)
	if str then
		return true, str
	else
		return false, "Could not be converted to string"
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
			local success, result = validate_table(prototype, subject)
			if success then
				for key in pairs(subject) do
					if not prototype[key] then
						result[key]=subject[key]
					end
				end
			end
			return success, result
		end
	else
		return function(subject)
			for key in pairs(subject) do
				if not prototype[key] then
					return false, "Unexpected key: "..tostring(key)
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
			return true, subject
		else
			return false, string.format("Expected %s to be %s", tostring(subject), tostring(object))
		end
	end
end

--- Transformation that maps values using a table.
-- Fails for values that do not appear in the given table. Never fails for functions.
function shapeshift.map(map)
	if type(map) == "table" then
		return function(subject)
			if map[subject] then
				return true, map[subject]
			else
				return false, "Key "..subject.." not found in map/set"
			end
		end
	elseif type(map) == "function" then
		return function(subject)
			return true, map(subject)
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
	local joined
	return function(subject)
		if map[subject] then
			return true, subject
		else
			joined = joined or table.concat(table_map(sequence, tostring), ', ')
			return false, 'expected one of '..joined..'; got '..tostring(subject)
		end
	end
end

--- Runs a validation only if the subject is not nil.
function shapeshift.maybe(validation)
	return function(subject)
		if subject ~= nil then
			return validation(subject)
		else
			return true, subject
		end
	end
end

local function tabulate(str)
	return (str:gsub("[^\n]+", function(line)
		return "\t" .. line
	end))
end

--- Run a list of validations on a subject and fail if none succeeds.
-- The result of the first successful validation is returned.
-- Additional validations will not be tried.
function shapeshift.any(validations, ...)
	if type(validations) ~= "table" then
		return shapeshift.any{validations, ...}
	end
	return function(subject)
		local messages = { "Did not meet any validation:" }
		for i, validation in ipairs(validations) do
			local success, result = validation(subject)
			if success then
				return true, result
			else
				table.insert(messages, tabulate(tostring(result)))
			end
		end
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
			success, subject = validation(subject)
			if not success then
				return false, subject
			end
		end
		return true, subject
	end
end

--- Runs a validation on every element of a sequence and fails unless all of them pass.
function shapeshift.each(validation)
	return function(subject)
		for idx, value in ipairs(subject) do
			success, result = validation(value)
			if not success then
				return false, "["..idx.."]: "..result
			end
			subject[idx] = result
		end
		return true, subject
	end
end

--- Runs a validation on every element of a sequence and keeps only those that pass.
function shapeshift.filter(validation)
	return function(subject)
		local result = {}
		for idx, value in ipairs(subject) do
			success, result = validation(value)
			if success then
				table.insert(result, value)
			end
		end
		return result
	end
end

--- Provides a default value for a test subject.
-- The default is returned when the subject, optionally filtered through another test,
-- returns nil. Otherwise this value is returned unmodified.
function shapeshift.default(default, test)
	test = test or function(subject) return subject~=nil, subject end
	return function(subject)
		local success, result = test(subject)
		if success then
			return true, subject
		else
			return true, default
		end
	end
end

--- Confirms that the input is a string and matches a given pattern.
-- The pattern is *not* anchored and can match anywhere in the string.
-- Add ^ and $ if it should only match the whole string.
function shapeshift.matches(pattern)
	return function(subject)
		if type(subject)=="string" and string.find(subject, pattern) then
			return true, subject
		else
			return false, string.format('Subject [[%s]] does not match pattern [[%s]]', subject, pattern)
		end
	end
end

return shapeshift
