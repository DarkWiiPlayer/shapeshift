shapeshift = require 'shapeshift'

describe 'shapeshift', ->
	pending 'table', ->
	describe 'default', ->
		it 'Returns the default only when subject is nil', ->
			test = shapeshift.default("default")
			assert.equal "default", test(nil)
			assert.equal "foo", test("foo")
			assert.equal false, test(false)
	pending 'any', ->
	pending 'all', ->
