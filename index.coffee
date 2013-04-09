#!/usr/bin/env coffee
fs = (require 'fs')
parser = require("nomnom");

parser
    .script("F")

files = fs.readdirSync "#{__dirname}/lib/runnable"
files.forEach (file) ->
    moduleName = file.split('.')[0]
    module = require("#{__dirname}/lib/runnable/#{moduleName}")

    parser
        .command(moduleName)
        .help(module.help)
        .options(module.options)
        .callback(module.run)

options = parser.parse();

        # console.log file
# parser
#     .command('sync')
#     .help('Auto-upload local changes to remote sim')

# parser
#     .command('deploy')
#     .help('Deploy local dir to Simulate')
#     .callback (opts)->
#         require("./lib/runnable/#{opts._[0]}")

#       # console.log(opts);


# console.log parser
