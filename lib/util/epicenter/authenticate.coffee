http = require 'http'

authenicate = (userName, password, host, simPath, callback)->
    auth_params = """{"userName": "#{userName}", "password": "#{password}"}"""

    host = host.split ':'

    login_connection_param =
        host: host[0]
        path: "/authentication/#{simPath}"
        method: 'POST'
        headers:
            'Content-Type': 'application/json'
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