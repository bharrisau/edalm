SOP = require './SOP'

module.exports = (data, lib) ->
  data.pins = 2
  data.e = 0
  data.E1 = data.D
  data.b = data.E
  [data.D, data.E] = [data.E, data.D]
  SOP data, lib,
    Jt: if data.E >= 1.6 then 0.35 else 0.1
    Jh: -0.05
    Js: 0
    square: true