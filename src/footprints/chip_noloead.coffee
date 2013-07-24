class ChipNolead
  constructor: (@dsl) ->

  run: (data, padData) ->
    data.b = data.D
    @dsl.chip.run data, @dsl.util.noLead(data).X

module.exports = (dsl) ->
  if !dsl.chip_nolead
    dsl.chip_nolead = new ChipNolead(dsl)