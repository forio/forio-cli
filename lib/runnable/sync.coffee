#!/usr/bin/env coffee

chokidar = (require "chokidar")
color = (require "ansi-color").set

authenticate = (require "../util/authenticate").authenicate
# options = (require "../options").options
op = (require '../util/optionsParser')
uploader = (require "../util/upload")

die = ()-> process.kill('SIGTERM')

watch = (local, remote, token, ignored)->
    console.log "Watching", color(local, "white_bg+black") ,"for changes.."
    console.log ""

    watcher = chokidar.watch local,
        ignored: (item) ->
            ignored_extensions = /\.(less|git|coffee|tmpl|DS_Store)/i
            ignored_directories = /node_modules/i
            ignored_files = /grunt.js|cakefile/i

            ignore = item.match(ignored_extensions) or item.match(ignored_directories) or item.match(ignored_files) or (ignored and items.match(ignored))
            # if ignore then console.log item, ignore
            return ignore

        ignoreInitial: true
        persistent: true

    upload = (localPath, stats) ->
        serverPath = localPath.replace(local, '')
        simPath = "#{remote}/#{serverPath}"

        time = process.hrtime()
        uploader.uploadFileAPI localPath, simPath, token, (err, stdout, stderr) ->
            diff = process.hrtime time
            formattedDiff = ((diff[0] * 1e9 + diff[1]) / 1000000).toFixed(0)

            response = JSON.parse stdout
            if +response.status_code is 201
                console.log serverPath, color("\u2192", "cyan"), "#{simPath}", "   #{formattedDiff}ms"
            else if +response.status_code is 401
                console.log "Timed out. Reconnecting.."
                authenicateUser (newtoken)->
                    token = newtoken
                    upload localPath, stats
            else if response.message
                console.error color(response.status_code + ":", "red"), response.message
            else
                console.error color(err, "red"), stderr, stdout


    watcher.on "change", upload
    watcher.on "add", upload
    watcher.close()

authenicateUser = (user, pass, remote, callback)->
    ##Authenticating to make sure wherever you're writing to exists
    authenticate user, pass, remote, (response)->
        if !response.token
            console.error color(response.message, "red+bold")
            die()
        else
            callback(response.token)

# authenicateUser watch


exports.help = "Watch dir for changes and upload to sim"

exports.options =
    mapping:
        abbr: "m"
        position: 1
        required: true
        help: "<local_dir>:<sim_author>/<sim_name>"
    config_file:
        abbr: "c"
        help: "Path to config file"
        default: __dirname + "/../../config.json"
    ignore:
        abbr: "i"
        help: "Regex with pattern of files to ignore for sync"

exports.run = (options)->
    [local, remote] = op.parseMapping options.mapping
    [userName, pass] = op.getCreds options.config_file

    #Assume current author by default
    remote = "#{userName}/#{remote}"  if remote.indexOf('/') is -1

    console.log ""

    authenicateUser userName, pass, remote, (token)->
        watch(local, remote, token)
