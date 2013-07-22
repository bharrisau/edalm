class SON
  constructor: (@dsl) ->

  run: (data, padData) ->
    @dsl.sop.run data, @dsl.util.noLead data

module.exports = (dsl) ->
  if !dsl.son
    dsl.son = new SON(dsl)