class QFP
  constructor: (@dsl) ->

  run: (data, padData) ->
    ret = {}

    if data.pins % 4 == 1 or data.pins % 4 == 3
      console.log "Unsupported number of pins in quad package"
      return {}

    padData ?= @dsl.util.gullWing data

    odd = data.pins % 4 == 2
    pinsLeft = (data.pins + (if odd then 2 else 0)) / 4
    pinsTop = data.pins/2 - pinsLeft

    bottomRightY = (pinsLeft-1) * data.e / 2
    topLeftY = -1*bottomRightY
    topRightX = (pinsTop-1) * data.e / 2
    bottomLeftX = -1*topRightX
    #Left pads run down the left
    #Right pads run up the right
    #Bottom pads run to the right
    #Top pads run to the left
    ret.pads = [0...pinsLeft].map (a) ->
      num: a+1
      location: [padData.X.offset*-1, topLeftY + a*data.e]
      size: [padData.X.padLength, padData.X.padWidth]
      square: true
    .concat [0...pinsLeft].map (a) ->
      num: a+pinsLeft+pinsTop+1
      location: [padData.X.offset, bottomRightY - a*data.e]
      size: [padData.X.padLength, padData.X.padWidth]
      square: true
    .concat [0...pinsTop].map (a) ->
      num: a+pinsLeft+1
      location: [bottomLeftX + a*data.e, padData.Y.offset]
      size: [padData.Y.padWidth, padData.Y.padLength]
      square: true
    .concat [0...pinsTop].map (a) ->
      num: a+pinsLeft+pinsLeft+pinsTop+1
      location: [topRightX - a*data.e, padData.Y.offset*-1]
      size: [padData.Y.padWidth, padData.Y.padLength]
      square: true

    #Add themal pads if needed
    if data.E2 && data.D2
      ret.pads = ret.pads.concat @dsl.util.thermal(data.pins+1, data.E2[0], data.D2[0])

    #Add the silk data
    maxXPin = padData.X.offset + padData.X.padLength/2
    maxXBody = (data.E1?[0] || data.E[0])/2
    maxYPin = padData.Y.offset + padData.Y.padLength/2
    maxYBody = (data.D1?[0] || data.D[0])/2
    yPin = bottomRightY + padData.X.padWidth/2 + @dsl.silkWidth*1.5
    xPin = topRightX + padData.Y.padWidth/2 + @dsl.silkWidth*1.5
    ret.silk = []

    ret.silk.push
      start: [-1*maxXBody, -1*maxYBody]
      end: [-1*maxXPin + @dsl.silkWidth/2, -1*maxYPin + @dsl.silkWidth/2]
    ret.silk.push
      start: [-1*maxXBody, -1*maxYBody]
      end: [-1*xPin, -1*maxYBody]
    ret.silk.push
      start: [-1*maxXBody, -1*maxYBody]
      end: [-1*maxXBody, -1*yPin]

    ret.silk.push
      start: [maxXBody, -1*maxYBody]
      end: [xPin, -1*maxYBody]
    ret.silk.push
      start: [maxXBody, -1*maxYBody]
      end: [maxXBody, -1*yPin]

    ret.silk.push
      start: [-1*maxXBody, maxYBody]
      end: [-1*xPin, maxYBody]
    ret.silk.push
      start: [-1*maxXBody, maxYBody]
      end: [-1*maxXBody, yPin]

    ret.silk.push
      start: [maxXBody, maxYBody]
      end: [xPin, maxYBody]
    ret.silk.push
      start: [maxXBody, maxYBody]
      end: [maxXBody, yPin]


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
    courtyardY = Math.ceil((maxYPin + padData.Y.courtyard)*20)/20
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
    ret.refdes = [0, -1*(maxYPin + @dsl.textHeight/2 + @dsl.silkWidth)]

    ret

module.exports = (dsl) ->
  if !dsl.qfp
    dsl.qfp = new QFP(dsl)