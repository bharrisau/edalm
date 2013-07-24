class SOD
  constructor: (@dsl) ->

  run: (data, padData) ->
    @dsl.sop.run data

module.exports = (dsl) ->
  if !dsl.sod
    dsl.sod = new SOD(dsl)