exec  = (require 'child_process').exec


uploadFile = ()->



uploadZip = (localPath, simPath, token, callback)->
	file_url = "forio.com/simulate/api/file/#{simPath}"
	exec "curl --progress-bar -L -F token=#{token} -F content=@#{localPath} -F method=PUT -F unzip=true #{file_url}", ()->
		callback()

exports.uploadZip = uploadZip
