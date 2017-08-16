exec = (require 'child_process').exec
path = require 'path'

uploadFileAPI = (domain, localPath, simPath, token, callback) ->
    file_url = "https://#{domain}/file/#{path.dirname simPath}"
    file_name = path.basename localPath
    exec """curl --silent -L -H "Authorization: Bearer #{token}" -F file=@#{localPath} -F name=#{file_name} -X PUT #{file_url}""", callback

uploadZip = (domain, localPath, simPath, token, callback) ->
    file_url = "#{domain}/simulate/api/file/#{simPath}"
    file_name = path.basename localPath
    unzip_params =
        contentType: "application/unzip"
    exec """curl -L -H "Authorization: Bearer #{token}" -F file=@#{localPath} -F name=#{file_name} -X PUT #{file_url}""", ->
        process.stdout.write " unzipping....."
        exec """curl -L -H "Authorization: Bearer #{token}" -H "Content-Type: application/json" -d '#{JSON.stringify unzip_params}' -X PATCH #{file_url}/#{file_name}""", callback

exports.uploadFileAPI = uploadFileAPI
exports.uploadZip = uploadZip
