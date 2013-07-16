
module.exports = (data, lib) ->
  ret = ''

  ret += 'Element["" "" "" "" 0 0 0 ' + lib.toMM(data.refDes.y) + ' 0 100 ""] (\n'

  if data.pins
    ret += data.pins.map (a) ->
      flags = []
      flags.push('square') if a.square
      flags.push('hole') if a.hole
      '  Pin[' + lib.toMM(a.x0) + ' ' + lib.toMM(a.y0) + ' ' +
      lib.toMM(a.pad) + ' ' + lib.toMM(lib.clearance*2) + ' ' +
      lib.toMM(data.maskClearance || lib.maskClearance) + ' ' +
      lib.toMM(a.drill) + ' "' + a.pin + '" "' + a.pin + '" "' +
      flags.join(',') + '"]'
    .join '\n'
    ret += '\n'

  if data.pads
    ret += data.pads.map (a) ->
      flags = []
      flags.push('square') if a.square
      flags.push('onsolder') if a.back
      path = lib.toPath a
      '  Pad[' + lib.toMM(path.x1) + ' ' + lib.toMM(path.y1) + ' ' +
      lib.toMM(path.x2) + ' ' + lib.toMM(path.y2) + ' ' +
      lib.toMM(path.width) + ' ' + lib.toMM(lib.clearance*2) + ' ' +
      lib.toMM(data.maskClearance || lib.maskClearance) + ' "' + a.pin + '" "' + a.pin + '" "' +
      flags.join(',') + '"]'
    .join '\n'
    ret += '\n'

  if data.silk
    ret += data.silk.map (a) ->
      '  ElementLine[' + lib.toMM(a.x1) + ' ' + lib.toMM(a.y1) + ' ' +
      lib.toMM(a.x2) + ' ' + lib.toMM(a.y2) + ' ' +
      lib.toMM(lib.silkWidth) + ']'
    .join '\n'
    ret += '\n'

  if data.arc
    ret += data.arc.map (a) ->
      '  ElementArc[' + lib.toMM(a.x0) + ' ' + lib.toMM(a.y0) + ' ' +
      lib.toMM(a.x) + ' ' + lib.toMM(a.y) + ' ' + a.start + ' ' + 
      a.sweep + ' ' + lib.toMM(lib.silkWidth) + ']'
    .join '\n'
    ret += '\n'

  ret += ")"