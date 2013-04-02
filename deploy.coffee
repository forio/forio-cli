#!/usr/bin/env coffee
exec  = (require 'child_process').exec
spawn  = (require 'child_process').spawn
color = (require "ansi-color").set
fs = (require 'fs')

options = (require './options').options
http = require 'http'

getToken = (callback)->
	process.stdout.write "Authenticating as #{options.ftp_user}................"
	auth_params = "user_action=login&email=#{options.ftp_user}&password=#{options.password}"
	login_connection_param =
		host: 'forio.com'
		path: "/simulate/api/authentication/#{options.sim_path}"
		method: 'POST'
		headers:
		  'Content-Type': 'application/x-www-form-urlencoded'
		  'Content-Length': auth_params.length

	auth_request = http.request login_connection_param, (response) ->
		stack  = ""
		response.on "data", (payload) ->
			stack += payload

		response.on "end", ()->
			response = (JSON.parse stack)

			if !response.token
				process.stdout.write color('  \u2716 \n', "red")
				console.error color(response.status_code + ":", "red+bold"), response.message
			else
				process.stdout.write color('  \u2713 \n', "green")
				callback(response.token)

	auth_request.write auth_params
	auth_request.end()

uploadFile = (token, callback) ->
	file_url = "forio.com/simulate/api/file/#{options.sim_path}"

	process.stdout.write "Uploading to #{options.sim_path}....."
	exec "curl --progress-bar -L -F token=#{token} -F content=@#{__dirname}/archive.zip -F method=PUT -F unzip=true #{file_url}", ()->
		process.stdout.write color('  \u2713 \n', "green")
		callback()
	# upload_params = "token=#{token}"
	# upload_connection_param =
	# 	method: "PUT"
	# 	host: 'forio.com'
	# 	path: "/simulate/api/file/#{options.sim_path}"
	# 	headers:
	# 		'Content-Type': 'multipart/form-data'

	# curl = spawn "curl", ["--progress-bar", "-L", "-F", "token=#{token}", "-F", "content=@#{__dirname}/archive.zip", "-F", "unzip=true", file_url]

	# curl.stdout.on "data", ()->
	# 	console.log "read"
	# 	curl.kill('SIGTERM');

	# curl.stdout.on "end", ()->
	# 	console.log "end"
	# 	curl.kill('SIGTERM');

exec "rm #{__dirname}/archive.zip", ()->
	exec "zip -r #{__dirname}/archive.zip . -x@#{__dirname}/exclude.lst", {cwd: options.watch_dir}, ()->
		console.log ""
		getToken (token)->
			uploadFile token, ()->
				st = fs.statSync("#{__dirname}/archive.zip")
				sizeInMB = (st.size / (1024 * 1024)).toFixed(2)

				console.log ""
				console.log "Uploaded", color(sizeInMB + "MB", "bold+white"), "to", color(options.sim_path, "bold+white")
