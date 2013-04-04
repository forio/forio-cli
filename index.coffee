#!/usr/bin/env coffee

parser = require("nomnom");

parser.command('browser')
   .callback((opts)->
      console.log(opts.url);
   )
   .help("run browser tests");

parser
    .command('deploy')
    .help('deploy to forio.com')
    .options(
        mapping:
            position: 0
            required: true
            help: "local_path:<sim_author>/<sim_path>"
        config_file:
            abbr: "c"
            help: "Path to config file with sftp creds"
            default: __dirname + "/config.json"
    )
    .callback( (opts)->
      console.log(opts);
    )

parser.parse();

# console.log parser