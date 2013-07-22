class QFN
  constructor: (@dsl) ->

  run: (data, padData) ->
    @dsl.qfp.run data, @dsl.util.noLead data

module.exports = (dsl) ->
  if !dsl.qfn
    dsl.qfn = new QFN(dsl)