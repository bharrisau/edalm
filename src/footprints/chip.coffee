class Chip
  constructor: (@dsl) ->

  run: (data, padData) ->
    ret = {}

    padData ?= @dsl.util.chip data

    ret.pads = [
      {
        num: 1
        location: [-1*padData.offset, 0]
        size: [padData.padLength, padData.padWidth]
        square: true
      }
      {
        num: 2
        location: [padData.offset, 0]
        size: [padData.padLength, padData.padWidth]
        square: true
      }
    ]

    silkY = Math.max data.E[0]/2, padData.padWidth/2 + @dsl.silkWidth*1.5
    endX = padData.offset - padData.padLength/2
    startX = -1*endX - if data.polarised then padData.padLength else 0

    ret.silk = [
      {
        start: [startX, -1*silkY]
        end: [endX, -1*silkY]
      }
      {
        start: [startX, silkY]
        end: [endX, silkY]
      }
    ]

    maxXBody = data.D[0]/2
    maxYBody = data.E[0]/2

    ret.assembly = []
    ret.assembly.push
      start: [-1*(maxXBody-0.25), -1*maxYBody]
      end: [-1*maxXBody, -1*(maxYBody-0.25)]
    ret.assembly.push
      start: [-1*(maxXBody-0.25), -1*maxYBody]
      end: [maxXBody, -1*maxYBody]
    ret.assembly.push
      start: [maxXBody, -1*maxYBody]
      end: [maxXBody, maxYBody]
    ret.assembly.push
      start: [maxXBody, maxYBody]
      end: [-1*maxXBody, maxYBody]
    ret.assembly.push
      start: [-1*maxXBody, maxYBody]
      end: [-1*maxXBody, -1*(maxYBody-0.25)]

    courtyardX = Math.ceil((padData.offset + padData.padLength/2 +
      padData.courtyard)*20)/20
    maxY = Math.max maxYBody, padData.padWidth/2
    courtyardY = Math.ceil((maxY + padData.courtyard)*20)/20
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
    ret.refdes = [0, -1*(silkY + @dsl.textHeight/2 + @dsl.silkWidth*1.5)]

    ret


module.exports = (dsl) ->
  if !dsl.chip
    dsl.chip = new Chip(dsl)