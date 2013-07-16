Jt = 0.35
Jh = 0.35
Js_gt625 = 0.03
Js_le625 = -0.02
court = 0.25  

module.exports = (data, lib, factors) ->
  ['A', 'D', 'E', 'E1', 'D2', 'E2', 'b', 'L'].forEach (name) ->
    if data[name]
      data[name] = stdArray data[name]

  uneven = (data.pins % 2 == 1)
  data.pins++ if uneven

  height = data.pins/2

  Lmin = data.E[1]
  Lmax = data.E[0]
  Ltol = data.E[0] - data.E[1]

  Tmin = data.L[1]
  Ttol = data.L[0] - data.L[1]
  Wmin = data.b[1]
  Wtol = data.b[0] - data.b[1]

  Z = lib.Z(Lmin, Ltol, if factors then factors.Jt else Jt)
  G = lib.G(Lmax, Ltol, Tmin, Ttol, if factors then factors.Jh else Jh)
  X = lib.X(Wmin, Wtol, if factors then factors.Js else (if data.e > 0.625 then Js_gt625 else Js_le625))

  offset = round(Z/2)
  padLength = round((Z - G)/2)
  X = round X

  #Make an array of pins
  leftTop = -1 * (height-1) * data.e / 2
  left = [0...height].map (a) ->
    {
      pin: a+1
      x: padLength
      x0: -1*offset + padLength/2
      y: X
      y0: leftTop + a*data.e
      square: factors?.square
    }
  if uneven
    height--
  rightBottom = (height-1) * data.e / 2
  right = [0...height].map (a) ->
    {
      pin: a+1+height
      x: padLength
      x0: offset - padLength/2
      y: X
      y0: rightBottom - a*data.e
      square: factors?.square
    }

  pads = left.concat(right)

  #Add thermal if needed
  if data.D2 and data.E2
    tPadWidth = (data.E2[0] + data.E2[1])/2
    tPadLength = (data.D2[0] + data.D2[1])/8
    pin = pads.length + 1
    pads.push {
      pin: pin
      square: true
      x: tPadWidth
      x0: 0
      y: tPadLength*2
      y0: -1*tPadLength
    }
    pads.push {
      pin: pin
      square: true
      x: tPadWidth
      x0: 0
      y: tPadLength*2
      y0: tPadLength
    }

  #Add silk
  cornerX = data.E1[0]/2
  cornerY = Math.max(data.D[0]/2, -1*leftTop + X/2 + lib.silkWidth*1.5)

  silkLength = cornerY + leftTop - X/2 - lib.silkWidth*1.5
  silkLength = Math.floor(silkLength*20)/20

  silk = []
  silk.push {
    x1: -1*cornerX
    y1: -1*cornerY
    x2: cornerX
    y2: -1*cornerY
  }
  silk.push {
    x1: -1*cornerX
    y1: cornerY
    x2: cornerX
    y2: cornerY
  }
  silk.push {
    x1: -1*cornerX
    y1: leftTop - X/2 - lib.silkWidth*1.5
    x2: -1*offset + lib.silkWidth/2
    y2: leftTop - X/2 - lib.silkWidth*1.5
  }
  silk.push {
    x1: -1*cornerX
    y1: -1*cornerY
    x2: -1*cornerX
    y2: -1*cornerY + silkLength
  }
  silk.push {
    x1: cornerX
    y1: -1*cornerY
    x2: cornerX
    y2: -1*cornerY + silkLength
  }
  silk.push {
    x1: -1*cornerX
    y1: cornerY
    x2: -1*cornerX
    y2: cornerY - silkLength
  }
  silk.push {
    x1: cornerX
    y1: cornerY
    x2: cornerX
    y2: cornerY - silkLength
  }

  #Refdes location
  refDes = {
    x: 0
    y: -1*offset - lib.refDesHeight/2 - lib.silkWidth
  }

  #Add courtyard
  courtyard = {
    x1: -1*offset - court
    y1: -1*cornerY - court
    x2: offset + court
    y2: cornerY + court
  }

  #Add assembly box
  assembly = []

  {
    maskClearance: lib.maskClearance
    refDes: refDes
    pads: pads
    silk: silk
    courtyard: courtyard
    assembly: assembly
  }

stdArray = (val) ->
  if typeof val == 'number'
    [val+0.1, val-0.1]
  else
    val

round = (val) ->
  Math.round(val*20)/20