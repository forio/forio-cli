#!/usr/bin/env coffee

chokidar =  require "chokidar"
color = (require "ansi-color").set

authenticate = (require "../util/authenticate").authenicate
op = require "../util/optionsParser"
uploader = require "../util/upload"

config = {}

die = ()-> process.kill("SIGTERM")

watch = (token, conf = config) ->
    console.log "Watching", (color conf.local, "white_bg+black"), "for changes.."
    console.log ""

    watcher = chokidar.watch conf.local,
        ignored: (item) ->
            ignored_extensions = /\.(less|git|coffee|tmpl|DS_Store)/i
            ignored_directories = /node_modules/i
            ignored_files = /grunt.js|cakefile/i

            ignore =
                (item.match ignored_extensions) or
                (item.match ignored_directories) or
                (item.match ignored_files) or
                (conf.ignored and (items.match conf.ignored))
            # if ignore then console.log item, ignore
            return ignore

        ignoreInitial: true
        persistent: true

    upload = (localPath, stats, tryCount = 0) ->
        serverPath = localPath.replace conf.local, ""
        simPath = "#{conf.remote}/#{serverPath}"

        MAX_RETRIES = 3

        time = process.hrtime()
        if tryCount > 0
            console.log "retrying file " + localPath + ", " +
                tryCount + " attempt" + (if tryCount > 1 then "s" else "")

            if tryCount > MAX_RETRIES
                die()

        uploader.uploadFileAPI conf.domain, localPath, simPath, token, (err, stdout, stderr) ->
            diff = process.hrtime time
            formattedDiff = ((diff[0] * 1e9 + diff[1]) / 1000000).toFixed(0)

            try
                #Server sometimes doesn't return json for no reason, ignore and try again
                response = JSON.parse stdout
            catch
                return upload localPath, stats, tryCount + 1

            if +response.status_code is 201
                console.log serverPath, (color "\u2192", "cyan"), "#{simPath}", "   #{formattedDiff}ms"

            else if +response.status_code is 401
                console.log "Timed out. Reconnecting.."
                authenicateUser (newtoken)->
                    token = newtoken
                    upload localPath, stats, tryCount + 1
            else if response.message
                console.error (color "#{response.status_code}:", "red"), response.message, localPath
            else
                console.error (color err, "red"), stderr, stdout


    watcher.on "change", upload
    watcher.on "add", upload
    watcher.close()

authenicateUser = (callback, conf = config)->
    ##Authenticating to make sure wherever you're writing to exists
    authenticate conf.user, conf.pass, conf.domain, conf.remote, (response)->
        if !response.token
            console.error (color response.message, "red+bold")
            die()
        else
            (callback response.token, conf)


exports.help = "Watch dir for changes and upload to simulation"

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
    domain:
        abbr: "d"
        default: "forio.com"
        help: "domain simulate is hosted on"

exports.run = (options)->
    [local, remote] = op.parseMapping options.mapping
    domain = op.parseDomain options.domain

    {user_name, password} = (require options.config_file)

    #Assume current author by default
    remote = "#{user_name}/#{remote}"  if remote.indexOf('/') is -1

    options.domain = "qa.forio.com" if options.domain is "qa"

    config =
        local: local
        remote: remote
        user: user_name
        pass: password
        domain: domain

    authenicateUser watch
