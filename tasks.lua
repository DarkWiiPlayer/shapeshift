local spooder = require 'spooder'

spooder.task "test" {
	description = "Runs tests";
	function(helper)
		helper.run([[
			rm luacov.stats.out
			luacheck . || exit
			busted --coverage --lpath '?.lua' || exit
			luacov -r html shapeshift.lua
		]])
	end
}

spooder.task "documentation" {
	description = "Builds and pushes the documentation";
	depends = { "test"};
	function(helper)
		helper.run([[
			hash=$(git log -1 --format=%h)
			mkdir -p doc/coverage
			cp -r luacov-html/* doc/coverage
			ldoc .
			cd doc
				find . | treh -c
				git add --all
				if git log -1 --format=%s | grep "$hash$"
				then git commit --amend --no-edit
				else git commit -m "Update documentation to $hash"
				fi
				git push --force origin doc
			cd ../
			git stash pop || true
		]])
	end;
}
