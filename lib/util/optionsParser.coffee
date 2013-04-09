#!/usr/bin/env coffee

fs = (require "fs")

##Read creds from config
exports.getCreds = (config_file)->
    data = fs.readFileSync(config_file)
    dataObj = JSON.parse(data)

    return [dataObj.user_name, dataObj.password]

exports.parseMapping = (mapping)->
    #Assume local dir by default
    if mapping.indexOf(':') is -1
        local = process.cwd()
        remote = mapping
    else
        [local,remote] =  mapping.split(':')

    #Add trailing slash if not provided
    local += "/" if local.charAt(local.length - 1) isnt "/"

    return [local, remote]
