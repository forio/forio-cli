#!/usr/bin/env coffee

parser = require("nomnom");

parser
    .script("F")

parser
    .command('sync')
    .help('Auto-upload local changes to remote sim')

parser
    .command('deploy')
    .help('Deploy local dir to Simulate')
    .callback (opts)->
        require("./lib/runnable/#{opts._[0]}")

      # console.log(opts);

parser.parse();

# console.log parser
