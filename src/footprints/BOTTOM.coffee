SOP = require './SOP'

module.exports = (data, lib) ->
  data.pins = 2
  data.e = 0
  data.E1 = data.D
  data.b = data.E
  [data.D, data.E] = [data.E, data.D]
  SOP data, lib,
    Jt: 0.35
    Jh: 0.35
    Js: 0.03
    square: true