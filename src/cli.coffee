###
 AssemBot CLI!
###

path= require 'path'
fs= require 'fs'
_= require './util'
builder= require './builder'
server= require './server'
defaults= require './defaults'
optparse = require 'optparse'

# process.on 'uncaughtException', (ex)->
#   _.log "DANGER!"
#   _.pp ex

module.exports=
  run: ->
    command= 'help'
    buildTo= source:null, js:null, css:null
    project_root= process.cwd()
    assembot_info= require '../package'
    nfo= try
      require "#{project_root}#{path.sep}package"
    catch ex
      _.puts "No 'package.json' file found, using defaults!"
      empty=
        assembot: _.extend {}, defaults.assembot
    assbot_conf= unless nfo.assembot?
      _.puts "No 'assembot' block in your package.json file found, using defaults!"
      _.extend {}, defaults.assembot
    else
      nfo.assembot
    options= _.defaults {}, (assbot_conf.options || {}),  defaults.options
    delete assbot_conf.options

    parser = new optparse.OptionParser [
      ['-b', '--build', 'Run build']
      ['-s', '--serve', 'Run dev server']
      ['-f', '--files', 'Shows the build targets and associated files']
      ['-d', '--debug', 'Shows internal build config data']
      ['-p', '--port [PORT]', "Set dev server port"]
      ['-r', '--root [PATH]', 'Set dev server root path']
      ['-m', '--minify [LEVEL]', 'Force minification 0=none 1=minify 2=mangle']
      ['-c', '--modules', 'Shows the commonjs modules for .js build targets']
      ['-v', '--version', 'Shows version number']
      ['-h', '--help', 'Shows help']
      [      '--init', 'Creates a package.json, if missing']
      [      '--source [PATH]', 'Set source folder']
      [      '--js [PATH]', 'Export js package from source']
      [      '--css [PATH]', 'Export jcss package from source']
      # [      '--out', 'Build to STDOUT']
    ]

    parser.banner = 'Usage: assembot [options]';

    parser.on 'build',   (name, value)-> command= name
    parser.on 'help',    (name, value)-> command= name
    parser.on 'debug',   (name, value)-> command= name
    parser.on 'files',   (name, value)-> command= name
    parser.on 'init',    (name, value)-> command= name
    parser.on 'minify',  (name, value)-> options.minify= parseInt value || "1"
    parser.on 'modules', (name, value)-> command= name
    parser.on 'port',    (name, value)-> options.port= value
    parser.on 'serve',   (name, value)-> command= name
    parser.on 'version', (name, value)-> command= name
    parser.on 'js',      (name, value)-> buildTo[name]= value
    parser.on 'css',     (name, value)-> buildTo[name]= value
    parser.on '*',       (name, value)-> _.puts "Unknown option: #{name}"
    parser.on 'root',    (name, value)-> 
      newRoot= path.resolve(value)
      if fs.existsSync newRoot
        options.wwwRoot= newRoot
      else
        _.log "Not a valid path: #{ newRoot }"
    parser.on 'source',  (name, value)-> 
      command= name
      buildTo.source= value

    parser.parse process.argv

    if command is 'serve'
      server.serve assbot_conf, options

    else if command is 'build'
      builder.build assbot_conf, options

    else if command is 'files'
      builder.displayTargetTree assbot_conf, options

    else if command is 'modules'
      builder.displayModuleTree assbot_conf, options

    else if command is 'debug'
      builder.prepConfig assbot_conf, options
      _.pp assbot_conf

    else if command is 'version'
      _.puts assembot_info.version

    else if command is 'init'
      _.puts """
      ASSEMBOT! Bleep, bloop!
      v#{ assembot_info.version }

      """
      if fs.existsSync './package.json'
        _.puts "package.json already exists."
      else
        _.puts "Creating a default package.json for you..."
        assembot_conf.options= defaults.options
        template=
          name: path.basename(process.cwd())
          version: "1.0.0"
          license: ""
          description: ""
          author: ""
          assembot: assbot_conf
        # _.puts JSON.stringify(template, null, 2)
        fs.writeFileSync path.resolve('./package.json'), JSON.stringify(template, null, 2)
        _.puts 'Done.'


    else if command is 'source'
      config={}
      if buildTo.js?
        config[buildTo.js]= _.extend {}, defaults.config, source:buildTo.source
      if buildTo.css?
        config[buildTo.css]= _.extend {}, defaults.config, source:buildTo.source
        builder.build config, options

    else
      _.puts """
      ASSEMBOT! Bleep, bloop!
      v#{ assembot_info.version }

      """
      _.puts parser.toString()

