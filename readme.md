Shapeshift
================================================================================

A library to validate and transform data in Lua with special focus on
recursively validating tables.

Usage
--------------------------------------------------------------------------------

	local shapeshift = require 'shapeshift'
	local is = require 'shapeshift.is'

	local user = shapeshift.table {
		name = is.string;
		age = is.number;
		address = shapeshift.table {
			street = is.string;
			city = is.string;
			room = shapeshift.any { is.string, is.number }
		}
	}

	-- Create an example user
	local henry = {
		name = "Henry";
		age = 10;
		address = {
			street = "Foo Street";
			city = "City of Bar";
			room = "20 B";
		}
	}

	-- And validate it
	assert(user(henry))
