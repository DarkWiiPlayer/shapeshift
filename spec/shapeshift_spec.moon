package.path = "?/init.lua;?.lua;" .. package.path
shapeshift = require 'shapeshift'

describe 'shapeshift', ->
	describe 'is', ->
		it 'returns helper functions for type-checking', ->
			status, message = shapeshift.is.string("foobar")
			assert.truthy status
			status, message = shapeshift.is.string(20)
			assert.falsy status
			assert.is.string message
	describe 'table', ->
		before_each ->
			export person = shapeshift.table {
				name: shapeshift.is.string
				age: shapeshift.is.number
			}
		it 'returns a function', ->
			assert.is.function shapeshift.table { foo: "bar" }
		it 'detects missing keys', ->
			assert.falsy person { name: "Henry" }
		it 'recurses validations', ->
			assert.falsy person { name: "Henry", age: "twenty" }
		it 'passes correct validations', ->
			assert.truthy person { name: "Henry", age: 20 }
		pending 'ignores keys starting with __', ->
		-- Should this also apply to test subjects?
		it 'respects the __extra option', ->
			assert.same { foo: "bar" }, select 2, shapeshift.table(__extra: "keep")(foo: "bar")
			assert.same {  }, select 2, shapeshift.table(__extra: "drop")(foo: "bar")
			
	describe 'default', ->
		it 'Returns the default only when subject is nil', ->
			test = shapeshift.default("default")
			assert.equal "default", select 2, test(nil)
			assert.equal "foo", select 2, test("foo")
			assert.equal false, select 2, test(false)
	pending 'any', ->
	pending 'all', ->
	pending 'default', ->
