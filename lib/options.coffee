#!/usr/bin/env coffee

fs = (require "fs")

parser = require("nomnom");
parser.options
    mapping:
        abbr: "m"
        position: 1
        required: true
        help: "<local_dir>:<sim_author>/<sim_name>"
    config_file:
        abbr: "c"
        help: "Path to config file"
        default: __dirname + "/../config.json"
    ignore:
        abbr: "i"
        help: "Regex with pattern of files to ignore for sync"

options = parser.parse()

if !options.mapping
    console.log parser.getUsage()
    process.kill('SIGTERM')

##Read creds from config
data = fs.readFileSync(options.config_file)
dataObj = JSON.parse(data)

#Assume local dir by default
if options.mapping.indexOf(':') is -1
    options.local_dir = process.cwd()
    options.sim_path = options.mapping
else
    [options.local_dir, options.sim_path] = options.mapping.split(':')

#Add trailing slash if not provided
options.local_dir += "/" if options.local_dir.charAt(options.local_dir.length - 1) isnt "/"
#Assume current author by default
options.sim_path = "#{dataObj.user_name}/#{options.sim_path}"  if options.sim_path.indexOf('/') is -1

options.ftp_user = dataObj.user_name
options.password = dataObj.password

exports.options = options
