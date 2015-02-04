#!/usr/bin/env coffee

exec  = (require "child_process").exec
color = (require "ansi-color").set
fs = (require "fs")

authenticate = (require "../util/epicenter/authenticate").authenicate
uploader = (require "../util/epicenter/upload")

# options = (require "../options").options
op = (require "../util/optionsParser")

#Path to root
basePath = __dirname + "/../.."

config = {}
die = ()-> process.kill("SIGTERM")

getToken = (callback)->
    process.stdout.write "Authenticating as #{config.user}................"
    authenticate config.user, config.pass, config.domain, config.remote, (response)->
        if !response.access_token
            process.stdout.write color('  \u2716 \n', "red")
            console.error "#{color "#{response.status_code}:", "red+bold"} #{response.message}"
            die()
        else
            process.stdout.write color('  \u2713 \n', "green")
            callback(response.access_token)

uploadFile = (token, callback) ->
    process.stdout.write "Uploading to #{config.remote}....."
    uploader.uploadZip config.domain, "#{basePath}/archive.zip", config.remote, token, ()->
        # console.log arguments
        process.stdout.write color('  \u2713 \n', "green")
        callback()

confirm = (str, onYes)->
    process.stdout.write "#{str} (Y/n) "
    process.stdin.setEncoding "utf8"
    process.stdin.once "data", (val)->
        if val.trim() is "Y"
            process.stdin.resume()
            onYes()
        else
            die()

createTempZip = (local, tempFile, callback) ->
    exec "rm #{tempFile}", ()->
        exec "zip -r #{tempFile} . -x@#{basePath}/exclude.lst", {cwd: local}, callback


exports.help = "Deploy files to a simulation hosted on Epicenter"

exports.options =
    mapping:
        abbr: "m"
        position: 1
        required: true
        help: "<local_dir>:<account_id>/<project_id>"
    config_file:
        abbr: "c"
        help: "Path to config file"
        default: __dirname + "/../../confige.json"
    domain:
        abbr: "d"
        default: "api.forio.com"
        help: "Domain Epicenter is hosted on"

exports.run = (options)->
    console.log ""

    [local, remote] = op.parseMapping options.mapping
    domain = op.parseDomain options.domain

    {user_name, password} = (require options.config_file)

    #Assume current author by default
    remote = "#{user_name}/#{remote}"  if remote.indexOf("/") is -1

    tempFile = "#{basePath}/archive.zip"

    config =
        local: local
        remote: remote
        user: user_name
        pass: password
        domain: domain

    confirm "Are you sure you want to deploy #{color local, "white"} to #{color remote, "white"}?", ()->
        createTempZip local, tempFile, ()->
            getToken (token)->
                uploadFile token, ()->
                    st = fs.statSync(tempFile)
                    sizeInMB = (st.size / (1024 * 1024)).toFixed(2)

                    console.log ""
                    console.log "Uploaded #{color "#{sizeInMB}MB", "bold+white"} to #{color remote, "bold+white"} in #{process.uptime()} seconds"

                    die()