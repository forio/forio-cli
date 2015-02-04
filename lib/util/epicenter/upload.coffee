exec  = (require 'child_process').exec

uploadFileAPI = (domain, localPath, simPath, token, callback)->
    file_url = "#{domain}/file/#{simPath}"
    exec """curl --silent -L -H "Authorization: Bearer #{token}" -F content=@#{localPath} -F method=PUT #{file_url}""", callback

uploadZip = (domain, localPath, simPath, token, callback)->
    file_url = "#{domain}/file/#{simPath}"
    exec """curl -L -H "Authorization: Bearer #{token}" -F content=@#{localPath} -F method=PUT #{file_url}""", ->
        zip_file_name = localPath.slice(localPath.lastIndexOf('/'))
        zip_file_url = "#{file_url}#{zip_file_name}"
        exec """curl -L -H "Authorization: Bearer #{token}" -F type=Application/unzip -F method=PATCH #{zip_file_url}""", callback

exports.uploadFileAPI = uploadFileAPI
exports.uploadZip = uploadZip
