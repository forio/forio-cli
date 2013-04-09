#!/usr/bin/env coffee

chokidar = (require "chokidar")
color = (require "ansi-color").set

authenticate = (require "../util/authenticate").authenicate
# options = (require "../options").options
uploader = (require "../util/upload")

die = ()-> process.kill('SIGTERM')

watch = (token)->
    console.log ""
    console.log "Watching", color(options.local_dir, "white_bg+black") ,"for changes.."
    console.log ""

    watcher = chokidar.watch options.local_dir,
        ignored: (item) ->
            ignored_extensions = /\.(less|git|coffee|tmpl|DS_Store)/i
            ignored_directories = /node_modules/i
            ignored_files = /grunt.js|cakefile/i

            ignore = item.match(ignored_extensions) or item.match(ignored_directories) or item.match(ignored_files) or (options.ignore and items.match(options.ignore))
            # if ignore then console.log item, ignore
            return ignore

        ignoreInitial: true
        persistent: true

    upload = (localPath, stats) ->
        serverPath = localPath.replace(options.local_dir, '')
        simPath = "#{options.sim_path}/#{serverPath}"

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

authenicateUser = (callback)->
    ##Authenticating to make sure wherever you're writing to exists
    authenticate options.ftp_user, options.password, options.sim_path, (response)->
        if !response.token
            console.error color(response.message, "red+bold")
            die()
        else
            callback(response.token)

# authenicateUser watch


exports.help = "deploy files to simulate"

exports.options = {}

exports.run = ()->
    console.log ""
