coffee = require 'coffee-script'
fs = require 'fs'
path = require 'path'
options = {}

module.exports =
  run: (opt) ->
    options = opt
    partsPath = path.resolve options.baseDir, options.parts
    fs.readdir partsPath, processFolder.bind({partsPath: partsPath})

handleError = (err) ->
  console.log err
  process.exit(1)

processFolder = (err, files) ->
  return handleError(err) if err

  data = files.map (a) =>
    path.join(@partsPath, a)
  .map(processFile)
  .filter (a) -> a.contents

  generateSymbols(data) if options.symbolTarget

#Synchronous function, takes a file name - returns the object
processFile = (file) ->
  ext = path.extname(file)
  name = path.basename file, ext
  ext = ext.slice(1).toLowerCase()

  contents = switch ext
    when 'cson' then processCSON file
    when 'js', 'json', 'coffee' then require(file)
    else null

  {
    name: name
    contents: contents
  }

processCSON = (file) ->
  coffee.eval(fs.readFileSync(file).toString(), {sandbox:true})

generateSymbols = (data) ->
  generator = require('./output/' + options.symbolTarget)

  processedData = generator data, options
  processedData.forEach writeFile

writeFile = (data) ->
  fileName = path.resolve options.baseDir, options.symbols, data.filename
  fs.writeFile fileName, data.contents