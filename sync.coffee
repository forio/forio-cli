#!/usr/bin/env coffee

chokidar = (require "chokidar")
fs = (require "fs")
exec  = (require 'child_process').exec
color = (require "ansi-color").set

options = (require 'optimist')
    .usage("Watches for changes on provided directory and uploads to simulate")
    .options("c", {
        alias: "config_file"
        describe: "Path to config file"
        default: __dirname + "/config.json"
    })
    .options("w", {
        alias: "watch_dir"
        describe: "Directory to watch. Defaults to current."
        default: process.cwd()
    })
    .options("s", {
        alias: "sim_path"
        describe: "Path to simulation in author/sim_path format"
        demand: true
    })
    .options("i", {
        alias: "ignore"
        describe: "Regex with pattern of files to ignore for sync"
    })
    .argv

##Read creds from config
data = fs.readFileSync(options.config_file)
dataObj = JSON.parse(data)

#Assume current author by default
if options.sim_path.indexOf('/') is -1 then  options.sim_path = "#{dataObj.user_name}" + "/" + options.sim_path.trim()
#Add trailing slash if not provided
if options.watch_dir.charAt(options.watch_dir.length - 1) != "/" then  options.watch_dir = "#{options.watch_dir}/"

console.log "Watching", color(options.watch_dir, "white_bg+black") ,"for changes.."
console.log ""

watcher = chokidar.watch options.watch_dir,
    ignored: (item) ->
        ignored_extensions = /\.(less|git|coffee|tmpl)/i
        ignored_directories = /node_modules|templates/i
        ignored_files = /grunt.js|cakefile/i

        ignore = item.match(ignored_extensions) or item.match(ignored_directories) or item.match(ignored_files) or (options.ignore and items.match(options.ignore))
        # if ignore then console.log item, ignore
        return ignore

    ignoreInitial: true
    persistent: true

upload = (path_to_file, stats) ->
    list = path_to_file.split('/')
    folder = if list.length > 1 then list[0..(list.length - 2)].join('/') else ''

    serverPath = path_to_file.replace(options.watch_dir, '')
    simPath = "#{options.sim_path}/#{serverPath}"

    exec "#{__dirname}/upload.sh #{path_to_file} #{simPath} #{dataObj.user_name} #{dataObj.password}", (err, stdout, stderr) ->
        if err or stderr
            console.error color(err, "red"), stderr, stdout
        else
            console.log serverPath, color("\u2192", "cyan"), "#{simPath}"

watcher.on "change", upload
watcher.on "add", upload

# Only needed if watching is persistent.
watcher.close()