class Header
  constructor: (@dsl) ->

  run: (data) -> 
    ret = {}

    startX = -1* (data.x-1) * data.e / 2
    startY = -1* (data.y-1) * data.e / 2

    ret.pads = [0...data.y].reduce (prev, row) =>
      prev.concat [0...data.x].map (col) =>
        num: row*data.x + col + 1
        square: row == 0 and col == 0
        drill: data.hole
        size: data.pad
        location: [startX + col*data.e, startY + row*data.e]
    , []

    silkX = data.x * data.e / 2
    silkY = data.y * data.e / 2
    silkLength = data.e / 4

    ret.silk = []
    ret.silk.push
      start: [-1*silkX, -1*silkY]
      end: [-1*silkX - 0.25, -1*silkY - 0.25]
    ret.silk.push
      start: [-1*silkX, -1*silkY]
      end: [-1*silkX, -1*silkY + silkLength]
    ret.silk.push
      start: [-1*silkX, -1*silkY]
      end: [-1*silkX + silkLength, -1*silkY]
    ret.silk.push
      start: [silkX, -1*silkY]
      end: [silkX, -1*silkY + silkLength]
    ret.silk.push
      start: [silkX, -1*silkY]
      end: [silkX - silkLength, -1*silkY]
    ret.silk.push
      start: [-1*silkX, silkY]
      end: [-1*silkX, silkY - silkLength]
    ret.silk.push
      start: [-1*silkX, silkY]
      end: [-1*silkX + silkLength, silkY]
    ret.silk.push
      start: [silkX, silkY]
      end: [silkX, silkY - silkLength]
    ret.silk.push
      start: [silkX, silkY]
      end: [silkX - silkLength, silkY]

    ret.assembly = []
    ret.assembly.push
      start: [-1*silkX, -1*silkY]
      end: [silkX, -1*silkY]
    ret.assembly.push
      start: [silkX, -1*silkY]
      end: [silkX, silkY]
    ret.assembly.push
      start: [silkX, silkY]
      end: [-1*silkX, silkY]
    ret.assembly.push
      start: [-1*silkX, silkY]
      end: [-1*silkX, -1*silkY]

    courtyardX = Math.ceil((silkX + 0.25)*20)/20
    courtyardY = Math.ceil((silkY + 0.25)*20)/20
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
  if !dsl.header
    dsl.header = new Header(dsl)