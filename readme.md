# Forio CLI

Forio CLI is both a set of tools to ease your worflow for working with simulations on Forio Simulate, as well as a framework for making your own.

## Quick Start

    $ git clone https://github.com/forio/forio-cli.git && cd forio-cli
    $ npm install
    $ chmod +x index.coffee
    $ alias F='your/path/index.coffee'
    $ mv config.json.dummy config.json #Use this to manage creds until SIMULATE-6036 is fixed

## Commands
Commands are high-level actions you're allowed to perform. Each command can define its own optional parameters. Invoking the command without specifying any of the required options prints out the usage. The following commands are currently supported

    Usage: F <command>

    command     one of: deploy, sync

### Deploy

    Usage: F deploy <mapping> [options]

    mapping     <local_dir>:<sim_author>/<sim_name>

    Options:
       -c, --config_file   Path to config file  [~/../../config.json]

    Deploy files to a simulation

This will ask for a confirmation before deploying, and also make sure the path you're deploying to exists.

### Sync
    Usage: F sync <mapping> [options]

    mapping     <local_dir>:<sim_author>/<sim_name>

    Options:
       -c, --config_file   Path to config file  [/Users/narenranjit/FPrjs/scripts/lib/runnable/../../config.json]
       -i, --ignore        Regex with pattern of files to ignore for sync

    Watch dir for changes and upload to simulation

Skipping __local_dir__ in the mapping defaults to current working directory. Skipping __sim_author__ defaults to using your account.


## Creating new commands

Creating new commands is fairly straight forward.

1. Create a new .coffee file under lib/runnable
2. Implement the command interface

All commands need to implement the following interface.

- __exports.run__: An object with the options you want to expose. See [nomnom][nom_nom_site] for options.
- __exports.help__: One line description of what the command does
- __exports.run__: This command will be passed a parsed object with any parameters passed from the console. Do with it what you will.


[nom_nom_site]: https://github.com/harthur/nomnom
