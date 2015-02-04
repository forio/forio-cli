fs = (require "fs")

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

exports.parseDomain = (domain)->
    mapping =
        "qa": "qa.forio.com"
        "www.forio.com": "forio.com"
        "forio": "forio.com"

    if mapping[domain] then domain = mapping[domain]

    return domain

