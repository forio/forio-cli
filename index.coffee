#!/usr/bin/env coffee

fs =  require "fs"
parser = require "nomnom"

parser.script "F"
pluginsDir = "#{__dirname}/lib/runnable"

files = fs.readdirSync pluginsDir
files.forEach (file) ->
    [moduleName] = file.split "."
    if moduleName is "" then return # skip .DS_Store

    mod = require "#{pluginsDir}/#{moduleName}"

    parser
        .command(moduleName)
        .help(mod.help)
        .options(mod.options)
        .callback(mod.run)

options = parser.parse()
