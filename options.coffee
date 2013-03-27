options = (require 'optimist')
    .usage("Watches for changes on provided directory and uploads to simulate")
    .options("c", {
        alias: "config_file"
        describe: "Path to config file"
        default: __dirname + "/config.json"
    })
    .options("w", {
        alias: "watch_dir"
        describe: "Directory to watch. Defaults to current."
        default: process.cwd()
    })
    .options("s", {
        alias: "sim_path"
        describe: "Path to simulation in author/sim_path format"
        demand: true
    })
    .options("i", {
        alias: "ignore"
        describe: "Regex with pattern of files to ignore for sync"
    })
    .argv

#Assume current author by default
if options.sim_path.indexOf('/') is -1 then  options.sim_path = "#{dataObj.user_name}" + "/" + options.sim_path.trim()
#Add trailing slash if not provided
if options.watch_dir.charAt(options.watch_dir.length - 1) != "/" then  options.watch_dir = "#{options.watch_dir}/"

##Read creds from config
data = fs.readFileSync(options.config_file)
dataObj = JSON.parse(data)

options.ftp_user = dataObj.user_name
options.password = dataObj.password

exports = options
