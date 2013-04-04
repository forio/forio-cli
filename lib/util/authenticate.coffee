http = require 'http'

authenicate = (userName, password, simPath, callback)->
	auth_params = "user_action=login&email=#{userName}&password=#{password}"
	login_connection_param =
		host: 'forio.com'
		path: "/simulate/api/authentication/#{simPath}"
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
			callback (response)

	auth_request.write auth_params
	auth_request.end()

exports.authenicate = authenicate