#!/usr/bin/env coffee
exec  = (require 'child_process').exec
spawn  = (require 'child_process').spawn
color = (require "ansi-color").set
fs = (require 'fs')

authenticate = (require '../util/authenticate').authenicate
uploader = (require '../util/upload')

options = (require '../options').options

die = ()-> process.kill('SIGTERM')
basePath = __dirname + "/../.."

getToken = (callback)->
	process.stdout.write "Authenticating as #{options.ftp_user}................"
	authenticate options.ftp_user, options.password, options.sim_path, (response)->
		if !response.token
			process.stdout.write color('  \u2716 \n', "red")
			console.error color(response.status_code + ":", "red+bold"), response.message
			die()
		else
			process.stdout.write color('  \u2713 \n', "green")
			callback(response.token)

uploadFile = (token, callback) ->
	process.stdout.write "Uploading to #{options.sim_path}....."
	uploader.uploadZip "#{basePath}/archive.zip", options.sim_path, token, ()->
		process.stdout.write color('  \u2713 \n', "green")
		callback()

confirm = (str, onYes)->
  process.stdout.write str + " (Y/n) "
  process.stdin.setEncoding 'utf8'
  process.stdin.once 'data', (val)->
    if val.trim() == "Y"
    	process.stdin.resume()
    	onYes()
    else
    	die()

authenticateAndUpload = ()->
	exec "rm #{basePath}/archive.zip", ()->
		exec "zip -r #{basePath}/archive.zip . -x@#{basePath}/exclude.lst", {cwd: options.local_dir}, ()->
			console.log ""
			getToken (token)->
				uploadFile token, ()->
					st = fs.statSync("#{basePath}/archive.zip")
					sizeInMB = (st.size / (1024 * 1024)).toFixed(2)

					console.log ""
					console.log "Uploaded", color(sizeInMB + "MB", "bold+white"), "to", color(options.sim_path, "bold+white"), "in", process.uptime(), "seconds"

					die()

console.log ""
confirm "Are you sure you want to deploy " +  color(options.local_dir, "white") + " to " + color(options.sim_path, "white") + "?", authenticateAndUpload
