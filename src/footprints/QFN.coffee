Jt = 0.3
Jh = 0.0
Js = -0.04
court = 0.25  

module.exports = (data, lib) ->
  ['A', 'D', 'E', 'D2', 'E2', 'b', 'L'].forEach (name) ->
    data[name] = stdArray data[name]

  [height, width] = if typeof data.pins == 'number'
    if data.pins % 4 == 0
      [data.pins/4, data.pins/4]
    else
      console.log "Number of pins is not divisible by 4"
      process.exit(1)
  else if typeof data.pins == 'array'
    data.pins
  else
    console.log "Unknown pins type"
    process.exit(1)

  Lminl = data.E[1]
  Lmaxl = data.E[0]
  Ltoll = data.E[0] - data.E[1]

  Lminw = data.D[1]
  Lmaxw = data.D[0]
  Ltolw = data.D[0] - data.D[1]

  Tmin = data.L[1]
  Ttol = data.L[0] - data.L[1]
  Wmin = data.b[1]
  Wtol = data.b[0] - data.b[1]

  Zl = lib.Z(Lminl, Ltoll, Jt)
  Gl = lib.G(Lmaxl, Ltoll, Tmin, Ttol, Jh)
  Zw = lib.Z(Lminw, Ltolw, Jt)
  Gw = lib.G(Lmaxw, Ltolw, Tmin, Ttol, Jh)
  X = lib.X(Wmin, Wtol, Js)

  offsetL = round(Zl/2)
  offsetW = round(Zw/2)
  padLength = round((Zl - Gl)/2)
  X = round X

  #Make an array of pins
  leftTop = -1 * (height-1) * data.e / 2
  left = [0...height].map (a) ->
    {
      pin: a+1
      x: padLength
      x0: padLength/2 - offsetW
      y:  X
      y0: leftTop + a*data.e
    }
  bottomLeft = -1 * (width-1) * data.e / 2
  bottom = [0...width].map (a) ->
    {
      pin: a+1+height
      x: X
      x0: bottomLeft + a*data.e
      y: padLength
      y0: offsetL - padLength/2
    }
  rightBottom = -1 * leftTop
  right = [0...height].map (a) ->
    {
      pin: a+1+height+width
      x: padLength
      x0: offsetW - padLength/2
      y: X
      y0: rightBottom - a*data.e
    }
  topRight = -1 * bottomLeft
  top = [0...width].map (a) ->
    {
      pin: a+1+height+width+height
      x: X
      x0: topRight - a*data.e
      y: padLength
      y0: padLength/2 - offsetL
    }

  pads = left.concat(bottom).concat(right).concat(top)

  #Add thermal if needed
  if data.D2 and data.E2
    tPadWidth = (data.E2[0] + data.E2[1])/4
    tPadLength = (data.D2[0] + data.D2[1])/4
    pin = pads.length + 1
    pads.push {
      pin: pin
      square: true
      x: tPadLength
      x0: tPadLength/2
      y: tPadWidth
      y0: tPadWidth/2
    }
    pads.push {
      pin: pin
      square: true
      x: tPadLength
      x0: tPadLength/2
      y: tPadWidth
      y0: -1*tPadWidth/2
    }
    pads.push {
      pin: pin
      square: true
      x: tPadLength
      x0: -1*tPadLength/2
      y: tPadWidth
      y0: tPadWidth/2
    }
    pads.push {
      pin: pin
      square: true
      x: tPadLength
      x0: -1*tPadLength/2
      y: tPadWidth
      y0: -1*tPadWidth/2
    }

  #Add silk
  cornerX = data.D[0]/2
  cornerY = data.E[0]/2

  silkLength = Math.min(cornerY - rightBottom, cornerX - topRight)
  silkLength -= X/2 + lib.silkWidth*1.5
  silkLength = Math.floor(silkLength*20)/20

  silkCorner = Math.min(offsetL - cornerY - lib.silkWidth/2, silkLength/Math.sqrt(2))
  silkCorner = Math.floor(silkCorner*20)/20

  silk = []
  silk.push {
    x1: -1*cornerX
    y1: -1*cornerY
    x2: silkLength - cornerX
    y2: -1*cornerY
  }
  silk.push {
    x1: -1*cornerX
    y1: -1*cornerY
    x2: -1*cornerX
    y2: silkLength - cornerY
  }
  silk.push {
    x1: -1*cornerX
    y1: -1*cornerY
    x2: -1*cornerX - silkCorner
    y2: -1*cornerY - silkCorner
  }
  silk.push {
    x1: cornerX
    y1: -1*cornerY
    x2: cornerX - silkLength
    y2: -1*cornerY
  }
  silk.push {
    x1: cornerX
    y1: -1*cornerY
    x2: cornerX
    y2: silkLength - cornerY
  }
  silk.push {
    x1: -1*cornerX
    y1: cornerY
    x2: silkLength - cornerX
    y2: cornerY
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
    x2: cornerX - silkLength
    y2: cornerY
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
    y: -1*offsetL - lib.refDesHeight/2 - lib.silkWidth
  }

  #Add courtyard
  courtyard = {
    x1: -1*offsetL - court
    y1: -1*offsetW - court
    x2: offsetL + court
    y2: offsetW + court
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