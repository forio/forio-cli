#!/usr/bin/env coffee

fs = (require "fs")
optimist = (require 'optimist')

options = optimist.usage(" local_path:<sim_author>/<sim_path>").argv

if !options._.length or !options._[0]
    optimist.showHelp()
    process.kill 'SIGTERM'

file = options._[0].split(" ")[0]
runnable = require("./lib/runnable/#{file}")

module.exports =


