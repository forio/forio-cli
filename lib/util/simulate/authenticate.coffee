http = require 'http'

authenicate = (userName, password, host, simPath, callback)->
    auth_params = "user_action=login&email=#{userName}&password=#{password}"

    host = host.split ':'

    login_connection_param =
        host: host[0]
        path: "/simulate/api/authentication/#{simPath}"
        method: 'POST'
        headers:
            'Content-Type': 'application/x-www-form-urlencoded'
            'Content-Length': auth_params.length
    if host[1]
        login_connection_param.port = host[1]

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
