#!/usr/bin/env coffee

fs = (require "fs")
optimist = (require 'optimist')

options = optimist.usage(" local_path:<sim_author>/<sim_path>",
    "config_file":
        short: "c"
        describe: "Path to config file"
        default: __dirname + "/../config.json"
    "ignore":
        short: "i"
        describe: "Regex with pattern of files to ignore for sync"
    ).argv

if options._.length < 1 or !options._[1]
    optimist.showHelp()
    process.kill 'SIGTERM'

##Read creds from config
data = fs.readFileSync(options.config_file)
dataObj = JSON.parse(data)

firstParam = options._[0].split(' ')[0].trim() ## directory:server_path

#Assume local dir by default
if firstParam.indexOf(':') is -1
    options.local_dir = process.cwd()
    options.sim_path = firstParam
else
    [options.local_dir, options.sim_path] = firstParam.split(':')

#Add trailing slash if not provided
options.local_dir += "/" if options.local_dir.charAt(options.local_dir.length - 1) isnt "/"
#Assume current author by default
options.sim_path = "#{dataObj.user_name}/#{options.sim_path}"  if options.sim_path.indexOf('/') is -1

options.ftp_user = dataObj.user_name
options.password = dataObj.password

exports.options = options
