coffee = require 'coffee-script'
fs = require 'fs'
path = require 'path'

class EDALM
  constructor: (@options) ->
    @lib =
      textHeight: 0.8
      silkWidth: 0.15
      namePrefix: 'edalm'
    require('./utils/ipc')(@lib)
    footprints = path.join(path.dirname(module.filename), 'footprints')
    fs.readdirSync(footprints).forEach (a) =>
      require('./footprints/' + a)(@lib)

  run: () =>
    partsPath = path.resolve @options.baseDir, @options.parts
    fs.readdir partsPath, @processFolder

  handleError: (err) =>
    console.log err
    process.exit(1)

  processFolder: (err, files) =>
    if err
      console.log "Unable to open parts folder: " + err.path
      process.exit(1)

    data = files.map (a) =>
      path.join(@options.baseDir, @options.parts, a)
    .map(@processFile)
    .filter (a) -> a.contents

    @generateSymbols(data) if @options.symbols
    @generateFootprints(data) if @options.footprints

  #Synchronous function, takes a file name - returns the object
  processFile: (file) =>
    ext = path.extname(file)
    name = path.basename file, ext
    ext = ext.slice(1).toLowerCase()

    console.log "Processing #{ name }"

    contents = switch ext
      when 'cson' then @processCSON file
      when 'js', 'json', 'coffee' then require(file)
      else null

    {
      name: name
      contents: contents
    }

  processCSON: (file) =>
    coffee.eval(fs.readFileSync(file).toString(), {sandbox:true})

  generateSymbols: (data) =>
    generator = require('./output/' + @options.symbolTarget)
    data = data.filter (a) -> a.contents.symbol

    processedData = generator data, @options
    processedData.map (a) =>
      filename: path.join @options.symbolDir, a.filename
      contents: a.contents
    .forEach @writeFile

  generateFootprints: (data) =>
    data = data.map (a) =>
      ret = null
      for type of a.contents.package
        if @lib[type]
          ret = @lib[type].run a.contents.package[type]
        else
          console.log "Unknown package: " + type
      {
        name: a.name
        contents: ret
      }
    .filter (a) -> a.contents
          
    generator = require('./output/' + @options.footprintTarget)

    processedData = generator data, @lib
    processedData.map (a) =>
      filename: path.join @options.footprintDir, a.filename
      contents: a.contents
    .forEach @writeFile

  writeFile: (data) =>
    fileName = path.resolve @options.baseDir, data.filename
    fs.writeFile fileName, data.contents

module.exports = (opt) -> new EDALM(opt)