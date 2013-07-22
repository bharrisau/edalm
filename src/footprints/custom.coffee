class Custom
  constructor: (@dsl) ->

  run: (data) -> data

module.exports = (dsl) ->
  if !dsl.custom
    dsl.custom = new Custom(dsl)