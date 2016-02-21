{BufferedProcess, CompositeDisposable} = require 'atom'
path = require 'path'
helpers = require 'atom-linter'
fs = require 'fs'

module.exports =
  config:
    checkstyleExecutablePath:
      type: 'string'
      title: 'Path to the checkstyle executable'
      default: 'checkstyle'
    checkConfiguration:
      type: 'string'
      title: "Check configuration file to use"
      default: path.join __dirname, "..", "data", "default-checkstyle.xml"
    lintOnlyCurrentFile:
      type: 'boolean'
      title: "Lint only current file"
      default: false

  activate: ->
    require('atom-package-deps').install('linter-checkstyle')
    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.config.observe 'linter-checkstyle.checkstyleExecutablePath',
      (newValue) =>
        @checkstyleExecutablePath = newValue
    @subscriptions.add atom.config.observe 'linter-checkstyle.checkConfiguration',
      (newValue) =>
        @checkConfigurationPath = newValue.trim()
    @subscriptions.add atom.config.observe 'linter-checkstyle.lintOnlyCurrentFile',
      (newValue) =>
        @lintOnlyCurrentFile = newValue

  deactivate: ->
    @subscriptions.dispose()

  provideLinter: ->
    grammarScopes: ['source.java']
    scope: 'project'
    lintOnFly: false       # Only lint on save
    lint: (textEditor) =>
      filePath = textEditor.getPath()
      wd = path.dirname filePath

      if @lintOnlyCurrentFile
        files = [filePath]
      else
        files = @getFilesEndingWith(@getProjectRootDir(), ".java")

      # ConfigurationPath
      cp = @checkConfigurationPath

      # Arguments to checkstyle
      args = []
      args = args.concat(["-c", cp]) if cp?
      args.push.apply(args, files)

      # Execute checkstyle
      helpers.exec(@checkstyleExecutablePath, args, {stream: 'stdout', cwd: wd, throwOnStdErr: false})
        .then (val) => return @parse(val, textEditor)

  parse: (checkstyleOutput, textEditor) ->
    # Regex to match the error/warning line
    regex = /^(.*\.java):(\d+):([\w \-]+): (warning:|)(.+)/

    # Split into lines
    lines = checkstyleOutput.split /\r?\n/
    messages = []
    for line in lines

      if line.match regex
        [file, lineNum, colNum, typeStr, mess] = line.match(regex)[1..5]

        console.log(typeStr)

        # checkstyle warning is error; info is warning
        type = "warning"
        if line.indexOf("warning") isnt -1
          type = "error"

        messages.push
          type: type       # Should be "error" or "warning"
          text: mess       # The error message
          filePath: file   # Full path to file
          range: [[lineNum - 1, 0], [lineNum - 1, 0]]
    return messages

  getProjectRootDir: ->
    return atom.project.rootDirectories[0].path

  getFilesEndingWith: (startPath, endsWith) ->
    foundFiles = []
    if !fs.existsSync(startPath)
      return foundFiles
    files = fs.readdirSync(startPath)
    i = 0
    while i < files.length
      filename = path.join(startPath, files[i])
      stat = fs.lstatSync(filename)
      if stat.isDirectory()
        foundFiles.push.apply(foundFiles, @getFilesEndingWith(filename, endsWith))
      else if filename.indexOf(endsWith, filename.length - (endsWith.length)) >= 0
        foundFiles.push.apply(foundFiles, [filename])
        #Array::push.apply foundFiles, filename
      i++
    return foundFiles
