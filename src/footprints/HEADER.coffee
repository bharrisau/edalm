module.exports = (data, lib) ->
  x0 = round((data.x-1)*data.e/-2)
  y0 = round((data.y-1)*data.e/-2)

  pins = [0...data.x*data.y].map (a) ->
    col = Math.floor(a/data.y)
    row = a % data.y
    {
      pin: a+1
      x0: x0+col*data.e
      y0: y0+row*data.e
      drill: data.hole
      pad: data.pad
      square: a==0
    }

  silk = []

  refDes = {
    x: 0
    y: -1*data.y*data.e/2 - lib.refDesHeight/2 - lib.silkWidth
  }
  courtyard = {}
  assembly = {}
  {
    refDes: refDes
    pins: pins
    silk: silk
    courtyard: courtyard
    assembly: assembly
  }

round = (val) ->
  Math.round(val*100)/100