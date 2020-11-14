package = "shapeshift"
version = "dev-1"
source = {
   url = "git+https://github.com/darkwiiplayer/shapeshift"
}
description = {
   homepage = "https://github.com/darkwiiplayer/shapeshift",
   license = "Public Domain"
}
dependencies = {
   "lua >= 5.1"
}
build = {
   type = "builtin",
   modules = {
      shapeshift = "shapeshift/init.lua"
   },
}
