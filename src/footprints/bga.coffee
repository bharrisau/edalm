class BGA
  constructor: (@dsl) ->

  mapping: [
    'A'
    'B'
    'C'
    'D'
    'E'
    'F'
    'G'
    'H'
    'J'
    'K'
    'L'
    'M'
    'N'
    'P'
    'R'
    'T'
    'U'
    'V'
    'W'
    'Y'
  ]

  getRow: (r) =>
    prefix = if r >= @mapping.length
      @getRow(Math.floor(r/@mapping.length))
    else
      ''
    prefix + @mapping[r % @mapping.length]

  run: (data, padData) =>
    ret = {}

    if not data.pins instanceof Array
      console.log "pins must be an array in BGA package"
      return {}

    padData ?= @dsl.util.bga data

    ret.mask = padData.mask

    odd = data.pins % 4 == 2
    pinsAcross = data.pins[0]
    pinsDown = data.pins[1]

    firstPinX = -1* (pinsAcross-1) * data.e / 2
    firstPinY = -1* (pinsDown-1) * data.e / 2

    ret.pads = [0...pinsAcross].reduce (prev, col) =>
      prev.concat [0...pinsDown].map (a) =>
        row = @getRow(a)
        pin = row + (col+1)
        return null if data.skip?.test pin

        num: pin
        location: [firstPinX + data.e*col, firstPinY + data.e*a]
        size: padData.size
    , []

    ret.pads = ret.pads.filter (a) -> a
    
    #Add themal pads if needed
    if data.E2 && data.D2
      ret.pads ret.pads.concat @dsl.util.thermal(pinsAcross*pinsDown + 1, data.E2[0], data.D2[0])

    #Add the silk data
    maxXBody = (data.E1?[0] || data.E[0])/2
    maxYBody = (data.D1?[0] || data.D[0])/2
    silkLength = Math.max 1, Math.min(maxXBody/3, maxYBody/3)
    silkLength2 = padData.courtyard
    silkLength = Math.ceil(silkLength*20)/20
    ret.silk = []

    ret.silk.push
      start: [-1*maxXBody, -1*maxYBody]
      end: [-1*maxXBody - silkLength2, -1*maxYBody - silkLength2]
    ret.silk.push
      start: [-1*maxXBody, -1*maxYBody]
      end: [-1*maxXBody + silkLength, -1*maxYBody]
    ret.silk.push
      start: [-1*maxXBody, -1*maxYBody]
      end: [-1*maxXBody, -1*maxYBody + silkLength]

    ret.silk.push
      start: [maxXBody, -1*maxYBody]
      end: [maxXBody - silkLength, -1*maxYBody]
    ret.silk.push
      start: [maxXBody, -1*maxYBody]
      end: [maxXBody, -1*maxYBody + silkLength]

    ret.silk.push
      start: [-1*maxXBody, maxYBody]
      end: [-1*maxXBody + silkLength, maxYBody]
    ret.silk.push
      start: [-1*maxXBody, maxYBody]
      end: [-1*maxXBody, maxYBody - silkLength]

    ret.silk.push
      start: [maxXBody, maxYBody]
      end: [maxXBody - silkLength, maxYBody]
    ret.silk.push
      start: [maxXBody, maxYBody]
      end: [maxXBody, maxYBody - silkLength]


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
    courtyardX = Math.ceil((maxXBody + padData.courtyard)*20)/20
    courtyardY = Math.ceil((maxYBody + padData.courtyard)*20)/20
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
    ret.refdes = [0, -1*(maxYBody + @dsl.textHeight/2 + @dsl.silkWidth)]

    ret

module.exports = (dsl) ->
  if !dsl.bga
    dsl.bga = new BGA(dsl)