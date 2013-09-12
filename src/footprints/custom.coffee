## Example row entry
# {
#   start: [-16.5, -3.5]
#   pitch: [1, 0]
#   size: [0.7, 4.2]
#   from: 1
#   step: 2
#   count: 11
#   back: false
#   square: true
# }

class Custom
  constructor: (@dsl) ->

  run: (data) ->
    # Check for data.rows and add to pads
    if data.rows
      data.pads ?= []
      for row in data.rows
        for i in [0...row.count]
          data.pads.push
            num: row.from + i*row.step
            location: [row.start[0] + i*row.pitch[0], 
              row.start[1] + i*row.pitch[1]]
            size: row.size
            back: row.back
            square: row.square
            drill: row.drill
            hole: row.hole       

    data

module.exports = (dsl) ->
  if !dsl.custom
    dsl.custom = new Custom(dsl)