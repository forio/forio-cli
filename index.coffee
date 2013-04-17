#!/usr/bin/env coffee
fs =  require "fs"
parser = require "nomnom"

parser.script "F"
pluginsDir = "#{__dirname}/lib/runnable"

files = fs.readdirSync pluginsDir
files.forEach (file) ->
    [moduleName] = file.split "."
    module = require "#{pluginsDir}/#{moduleName}"

    parser
        .command(moduleName)
        .help(module.help)
        .options(module.options)
        .callback(module.run)

options = parser.parse()
