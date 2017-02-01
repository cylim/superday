var exec = require('child_process').exec;
var echo = console.log

var argv = process.argv.slice(2)
var verb = argv[0]

var commands = {
	build : { description: "increments build number", execute: bumpBuild },
	hotfix : { description: "increments maintenance version and build number", execute: bumpHotfix },
	minor : { description: "increments minor version and build number", execute: bumpMinor },
}

var command = commands[verb]

if (command){
	command.execute()
} else {
	if (verb != undefined) {
		echo(`Unknown command '${verb}'`)
	}
	echo("Usage:")
	for (command in commands)
	{
		echo(`bump ${command} -> ${commands[command].description}`)
	}
}


function bumpBuild() {
	exec("agvtool next-version -all", function(error, stdout, stderr) {
		if (error) {
			echo("Something went wrong: \n" + stderr)
			return
		}
		var lines = stdout.split("\n")
		var version = lines[1].match(/\d+/)[0]
		echo(`Bump build to ${version}`)
	})
}

function bumpHotfix() {
	getVersionComponents(function(major, minor, maintenance) {
		maintenance += 1
		setVersion(major, minor, maintenance, bumpBuild)
	})
}

function bumpMinor() {
	getVersionComponents(function(major, minor, maintenance) {
		minor += 1
		setVersion(major, minor, 0, bumpBuild)
	})
}

function setVersion(major, minor, maintenance, callback) {
	var versionString = `${major}.${minor}` + (maintenance ? `.${maintenance}` : "")
	exec(`agvtool new-marketing-version ${versionString}`, function(error, stdout, stderr){
		if (error) {
			echo("Something went wrong: \n" + stderr)
			return
		}
		echo(`Set version to ${versionString}`)
		callback()
	})
}

function getVersionComponents(callback) {
	getVersionString(function(versionString){
		var components = versionString.split('.')
		callback(
			parseInt(components[0]),
			parseInt(components[1] || 0),
			parseInt(components[2] || 0)
			)
	})
}

function getVersionString(callback) {
	exec("agvtool what-marketing-version", function(error, stdout, stderr){
		if (error) {
			echo("Something went wrong: \n" + stderr)
			return
		}
		var version = stdout.match(/\d+(\.\d+(\.\d+)?)?/)[0]
		echo(`Current version is ${version}`)
		callback(version)
	})
}