class SOP
  constructor: (@dsl) ->

  run: (data, padData) ->
    ret = {}

    padData ?= @dsl.util.gullWing data

    odd = data.pins % 2 == 1
    pinsLeft = (data.pins + (if odd then 1 else 0)) / 2
    pinsRight = data.pins - pinsLeft

    topLeftY = (pinsLeft-1) * data.e / 2 * -1
    bottomRightY = (pinsRight-1) * data.e / 2
    #Left pads run down the left
    #Right pads run up the right
    ret.pads = [0...pinsLeft].map (a) ->
      num: a+1
      location: [padData.X.offset*-1, topLeftY + a*data.e]
      size: [padData.X.padLength, padData.X.padWidth]
      square: true
    .concat [0...pinsRight].map (a) ->
      num: a+pinsLeft+1
      location: [padData.X.offset, bottomRightY - a*data.e]
      size: [padData.X.padLength, padData.X.padWidth]
      square: true

    #Add themal pads if needed
    if data.E2 && data.D2
      ret.pads.push @dsl.util.thermal(data.pins+1, data.E2[0], data.D2[0])

    #Add the silk data
    maxXPin = padData.X.offset + padData.X.padLength/2
    maxXBody = (data.E1?[0] || data.E[0])/2
    maxYPinLeft = (-1*topLeftY) + padData.X.padWidth/2
    maxYPinRight = bottomRightY + padData.X.padWidth/2
    maxYBody = data.D[0]/2
    maxY = Math.max maxYBody, maxYPinLeft + @dsl.silkWidth*1.5
    ret.silk = []

    ret.silk.push
      start: [-1*maxXBody, -1*maxY]
      end: [0, -1*maxY]

    if maxYPinLeft + @dsl.silkWidth*1.5 < maxY - 0.2
      ret.silk.push
        start: [-1*maxXBody, maxY]
        end: [0, maxY]
      ret.silk.push
        start: [-1*maxXBody, maxY]
        end: [-1*maxXBody, maxYPinLeft + @dsl.silkWidth*1.5]
      ret.silk.push
        start: [-1*maxXBody, -1*maxY]
        end: [-1*maxXBody, -1*maxYPinLeft - @dsl.silkWidth*1.5]
      ret.silk.push
        start: [-1*maxXBody, -1*maxYPinLeft - @dsl.silkWidth*1.5]
        end: [-1*maxXPin, -1*maxYPinLeft - @dsl.silkWidth*1.5]
    else
      ret.silk.push
        start: [-1*maxXPin + padData.X.padLength, maxY]
        end: [0, maxY]
      ret.silk.push
        start: [-1*maxXBody, -1*maxY]
        end: [-1*maxXPin, -1*maxY]

    if maxYPinRight + @dsl.silkWidth*1.5 < maxY - 0.2
      ret.silk.push
        start: [maxXBody, -1*maxY]
        end: [0, -1*maxY]
      ret.silk.push
        start: [maxXBody, maxY]
        end: [0, maxY]
      ret.silk.push
        start: [maxXBody, maxY]
        end: [maxXBody, maxYPinRight + @dsl.silkWidth*1.5]
      ret.silk.push
        start: [maxXBody, -1*maxY]
        end: [maxXBody, -1*maxYPinRight - @dsl.silkWidth*1.5]
    else
      ret.silk.push
        start: [maxXPin - padData.X.padLength, -1*maxY]
        end: [0, -1*maxY]
      ret.silk.push
        start: [maxXPin - padData.X.padLength, maxY]
        end: [0, maxY]

    #Add the assembly outline
    ret.assembly = []
    ret.assembly.push
      start: [-1*(maxXBody-0.5), -1*maxYBody]
      end: [-1*maxXBody, -1*(maxYBody-0.5)]
    ret.assembly.push
      start: [-1*(maxXBody-0.5), -1*maxYBody]
      end: [maxXBody, -1*maxYBody]
    ret.assembly.push
      start: [maxXBody, -1*maxYBody]
      end: [maxXBody, maxYBody]
    ret.assembly.push
      start: [maxXBody, maxYBody]
      end: [-1*maxXBody, maxYBody]
    ret.assembly.push
      start: [-1*maxXBody, maxYBody]
      end: [-1*maxXBody, -1*(maxYBody-0.5)]

    #Add the part courtyard
    courtyardX = Math.ceil((maxXPin + padData.X.courtyard)*20)/20
    courtyardY = Math.ceil((maxYBody + padData.X.courtyard)*20)/20
    ret.courtyard = []
    ret.courtyard.push
      start: [-1*courtyardX, -1*courtyardY]
      end: [-1*courtyardX, courtyardY]
    ret.courtyard.push
      start: [-1*courtyardX, courtyardY]
      end: [courtyardX, courtyardY]
    ret.courtyard.push
      start: [courtyardX, courtyardY]
      end: [courtyardX, -1*courtyardY]
    ret.courtyard.push
      start: [courtyardX, -1*courtyardY]
      end: [-1*courtyardX, -1*courtyardY]

    #Place the refdes
    ret.refdes = [0, -1*(maxY + @dsl.textHeight/2 + @dsl.silkWidth*1.5)]

    ret

module.exports = (dsl) ->
  if !dsl.sop
    dsl.sop = new SOP(dsl)