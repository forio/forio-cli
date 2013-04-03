fs = (require "fs")
options = require('commander')

options
    .usage("Watches for changes on provided directory and uploads to simulate")
    .option("-c, --config_file <file>", "Path to config file", "#{__dirname}/config.json")
    .option("-s, --sim_path [path]", "Path to simulation in author/sim_path format", String)
    .option("-w, --watch_dir", "Directory to watch. Defaults to current.", process.cwd())
    .option("-i, --ignore",  "Regex with pattern of files to ignore for sync", "")

options.parse(process.argv);

##Read creds from config
data = fs.readFileSync(options.config_file)
dataObj = JSON.parse(data)

options.ftp_user = dataObj.user_name
options.password = dataObj.password

#Assume current author by default
if options.sim_path.indexOf('/') is -1 then  options.sim_path = "#{dataObj.user_name}" + "/" + options.sim_path.trim()
#Add trailing slash if not provided
if options.watch_dir.charAt(options.watch_dir.length - 1) != "/" then  options.watch_dir = "#{options.watch_dir}/"

exports.options = options
