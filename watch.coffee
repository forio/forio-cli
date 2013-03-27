#!/usr/bin/env coffee

chokidar = (require "chokidar")
fs = (require "fs")
exec  = (require 'child_process').exec
color = (require "ansi-color").set

options = (require 'optimist')
    .usage("DFgdf")
    .options("c", {
        alias: "config_file"
        describe: "Path to config file"
        default: "./config.json"
    })
    .options("w", {
        alias: "watch_dir"
        describe: "Directory to watch"
        demand: true
    })
    .options("s", {
        alias: "sim_name"
        describe: "Name of simulation"
        demand: true
    })
    .options("i", {
        alias: "ignore"
        describe: "Regex with pattern of files to ignore of simulation"
    })
    .argv

data = fs.readFileSync(options.config_file)
dataObj = JSON.parse(data)

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

    exec "./upload.sh #{path_to_file} #{options.sim_name} #{dataObj.user_name} #{serverPath} #{dataObj.password}", (err, stdout, stderr) ->
        if err or stderr
            console.error color(err, "red"), stderr, stdout
        else
            console.log serverPath, color("\u2192", "cyan"), "#{dataObj.user_name}/#{options.sim_name}/#{serverPath}"

watcher.on "change", upload
watcher.on "add", upload

# Only needed if watching is persistent.
watcher.close()