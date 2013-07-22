class SOT
  constructor: (@dsl) ->

  run: (data, padData) ->
    @dsl.sop.run data

module.exports = (dsl) ->
  if !dsl.sot
    dsl.sot = new SOT(dsl)