http = require 'https'

authenicate = (userName, password, host, simPath, callback)->
    auth_params = {userName, password}

    host = host.split ':'

    login_connection_param =
        host: host[0]
        path: "/authentication"
        method: 'POST'
        headers:
            'Content-Type': 'application/json'
    if host[1]
        login_connection_param.port = host[1]

    auth_request = http.request login_connection_param, (response) ->
        stack  = ""
        response.on "data", (payload) ->
            stack += payload

        response.on "end", ()->
            response = (JSON.parse stack)
            callback (response)

    auth_request.write (JSON.stringify auth_params)
    auth_request.end()

exports.authenicate = authenicate
