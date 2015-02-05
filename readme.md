# Forio CLI

Forio CLI is both a set of tools to ease your worflow for working with simulations on Forio Epicenter or Forio Simulate, as well as a framework for making your own.

## Quick Start

    $ npm install -g coffee-script #If you don't already have it
    $ git clone https://github.com/forio/forio-cli.git
    $ cd forio-cli
    $ npm install
    $ chmod +x index.coffee
    $ alias F='~/PROJECT_PATH/forio-cli/index.coffee'
    $ cp config-sample.json config.json #Use this to manage creds until SIMULATE-6036 is fixed

## Commands

Commands are high-level actions you're allowed to perform. Each command can define its own optional parameters. Invoking the command without specifying any of the required options prints out the usage. The following commands are currently supported

    Usage: F <command>

    command     one of: deploy, sync

### `F deploy` - Deploy

    Usage: F deploy <mapping> [options]

    mapping     <local_dir>:<account>/<project>

    Options:
       -p, --platform      Platform (epicenter or simulate)  [epicenter]
       -c, --config_file   Path to config file  [./config.json]
       -d, --domain        Domain Epicenter or Simulate is hosted on  [api.forio.com or forio.com]

    Deploy files to a simulation

This will ask for a confirmation before deploying, and also make sure the path you're deploying to exists.

Skipping `local_dir` in the mapping defaults to current working directory. Skipping `account` defaults to using your account.

### `F sync` - Sync

    Usage: F sync <mapping> [options]

    mapping     <local_dir>:<account>/<project>

    Options:
       -p, --platform      Platform (epicenter or simulate)  [epicenter]
       -c, --config_file   Path to config file  [./config.json]
       -d, --domain        Domain Epicenter or Simulate is hosted on  [api.forio.com or forio.com]
       -i, --ignore        Regex with pattern of files to ignore for sync

    Watch dir for changes and upload to a simulation

Skipping `local_dir` in the mapping defaults to current working directory. Skipping `account` defaults to using your account.

This command may crash on OS X when uploading a large number of files simultaneously. This can be fixed by running this command in your terminal, or putting it in your `~/.bash_profile` file:

    ulimit -n 10000

## Creating new commands

Creating new commands is fairly straight forward.

1. Create a new .coffee file under lib/runnable
2. Implement the command interface

All commands need to implement the following interface.

- `exports.help`: One line description of what the command does
- `exports.options`: An object with the options you want to expose. See [nomnom][nom_nom_site] for options.
- `exports.run`: This command will be passed a parsed object with any parameters passed from the console. Do with it what you will.

## Other utilities

The "misc" directory contains utilities that could not be integrated with the `F` command. Right now, the only thing in it is `makeSymlink`.


[nom_nom_site]: https://github.com/harthur/nomnom
