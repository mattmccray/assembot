require 'coffee-script'
_= require '../util'
log= require '../log'
defaults= require '../defaults'
path= require 'path'
{spawn}= require('child_process')
{test, cat, cd, mkdir, exec}= require 'shelljs'
{loadOptions}= require '../index'

build_project= (name)->
  projectpath= path.resolve "./#{ name }"
  if test '-e', projectpath
    log.say "#{ name} already exists at this location!"
  else

    log.say "create: #{ name }"
    mkdir projectpath
    cd projectpath

    create_dir= (filepath)->
      log.say "create: #{ name }/#{ filepath }"
      mkdir filepath

    create_file= (filepath, contentName)->
      log.say "create: #{ name }/#{ filepath }"
      String(content[contentName]).replace(/APPNAME/g, name).to filepath

    create_dir  "source"
    create_file "source/main.coffee", 'mainCoffee'
    create_file "source/main.styl", 'mainStylus'
    create_dir  "public"
    create_file "public/index.html", 'indexHtml'
    create_dir  "docs"
    create_file "docs/ideas.md", 'ideas'
    create_file "docs/todos.md", 'todos'
    create_dir  "test"
    create_dir  "test/fixtures"
    create_file "test/mocha.opts", 'mochaOpts'
    create_file "test/helpers.coffee", 'testHelpers'
    create_file "test/test_app.coffee", 'projectTest'
    create_file ".gitignore", 'gitIgnore'
    create_file "Makefile", 'makefile'
    create_file "readme.md", 'readme'
    settings=
      name: name
      version: "1.0.0"
      license: ""
      description: ""
      author: ""
      assembot: defaults
      devDependencies: 
        assembot: "*"
        "coffee-script": "*"
        mocha: "*"
        chai: "*"
    for t,v of settings.assembot.targets
      if t.indexOf('.js') > 0
        v.autoLoad= "main"
    content.packageJSON= JSON.stringify settings, null, 2
    create_file "package.json", 'packageJSON'
    exec "npm install"
    log.say ""
    log.say "OK, you can have fun!"
    log.say ""
    log.say "   cd #{name}"
    log.say ""
    log.say "Done!"

content=
  readme: """
    # APPNAME

    ## Remember

    If you're having problems compiling or testing, you might need to run:

        npm install

    And yeah, you should probably delete all this and say a few words about APPNAME here.
    """

  mainCoffee: """
    # APPNAME main

    this.onload= ->
      console.log "Ready."
      document.body.innerHTML= "Ready."

    """

  mainStylus: """
    // APPNAME
    @import 'nib'

    global-reset()

    body
      font-family "Helvetica Neue", Helvetica, Sans-Serif
    """

  ideas: """
    # APPNAME Ideas

    - Do cool stuff!
    """

  todos: """
    # APPNAME Todos

    - Write docs
    - Flesh out readme.md
    - Release APPNAME!
    """

  indexHtml: """<!DOCTYPE html>
    <html lang="en"  class="nojs">
      <head>
        <meta charset="utf-8" />
        <title>APPNAME</title>
        <link rel="stylesheet" type="text/css" href="app.css">
      </head>
      <body>
        Loading...
      </body>
      <script src="app.js"></script>
    </html>"""

  mochaOpts: """
    --ignore-leaks
    --compilers coffee:coffee-script
    --reporter spec
    --require coffee-script
    --require test/helpers.coffee
    --colors
    """

  testHelpers: """
    # Insert your test helpers here...
    """

  projectTest: """
    should= require('chai').should()
    # this is the compiled output from assembot, 
    # use it like you would the 'window' object:
    buildenv= require('../public/app')

    describe 'APPNAME', ->
      #beforeEach ->
      #afterEach ->

      it 'should exist', ->
        should.exist buildenv

      it 'should contain the module loader', ->
        buildenv.require.should.exist
        buildenv.require.should.be.a.function

      describe 'main', ->

        it 'should exist', ->
          main= buildenv.require('main')
          should.exist main
    """

  gitIgnore: "node_modules"

  # The hard way, cause Makefile's have to have tabs, not spaces!
  makefile: "build:\n\t./node_modules/.bin/assembot build\n\ntest:\n\t@NODE_ENV=test\n\t@clear\n\t@./node_modules/.bin/mocha\n\n.PHONY: build test\n"

# cli
#   .parse(process.argv);

# log.level 0 if cli.quiet
# log.level 2 if cli.verbose


module.exports= (cli, pkg)->
  cli
    .command('new')
    .description("project directory name")
    .action((name)->
      if process.argv.length < 4
        log.say "I am an advanced Bot, yes. But my telepathic circuits aren't ready yet.\n"
        log.say "Please enter a project name!"
        return
      build_project name     
    )
