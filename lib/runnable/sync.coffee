#!/usr/bin/env coffee

chokidar = (require "chokidar")
color = (require "ansi-color").set

authenticate = (require "../util/authenticate").authenicate
options = (require "../options").options
uploader = (require "../util/upload")

token = ""
die = ()-> process.kill('SIGTERM')

watch = ()->
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

    scpUpload = (localPath, stats) ->
        serverPath = localPath.replace(options.local_dir, '')
        simPath = "#{options.sim_path}/#{serverPath}"

        uploader.uploadFile localPath, simPath, options.ftp_user, options.password, (err, stdout, stderr) ->
            if err or stderr
                console.error color(err, "red"), stderr, stdout
            else
                console.log serverPath, color("\u2192", "cyan"), "#{simPath}"

    watcher.on "change", scpUpload
    watcher.on "add", scpUpload
    watcher.close()

##Authenticating to make sure wherever you're writing to exists
authenticate options.ftp_user, options.password, options.sim_path, (response)->
    if !response.token
        console.error color(response.message, "red+bold")
        die()
    else
        watch(response.token)