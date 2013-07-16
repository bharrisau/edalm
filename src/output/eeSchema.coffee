
module.exports = (data, lib) ->
  pins = data.symbol.pins.reduce (last, a) ->
    last ||= {}
    side = a[3]
    last[side] ||= []

    type = switch a[2]
      when 'in' then 'I'
      when 'out' then 'O'
      when 'io' then 'B'
      when 'tri' then 'T'
      when 'passive' then 'P'
      when 'power' then 'W'
      when 'supply' then 'w'
      when 'oc' then 'C'
      when 'oe' then 'E'
      when 'nc' then 'N'
      else 'U'

    last[side].push
      number: a[0]
      name: a[1]
      type: type
    last

  hSpacing = data.symbol.hSpacing || data.symbol.spacing || 100
  vSpacing = data.symbol.vSpacing || data.symbol.spacing || 100
  pinLength = data.symbol.pinLength || 300
  quad = if pins.t or pins.b then true else false
  widthPins = Math.max((pins.t || []).length, (pins.b || []).length)
  width = Math.max(data.symbol.width || 1400, (widthPins+1)*hSpacing)
  heightPins = Math.max((pins.l || []).length, (pins.r || []).length)
  topPins = Math.round((heightPins-1)*vSpacing/2)
  top = Math.max(topPins + vSpacing, Math.round((data.symbol.height || 0)/2))
  right = Math.round(width/2)

  ret = 'EESchema-LIBRARY Version 2.3  Date: '
  ret += (new Date()).toUTCString() + '\n'
  ret += [
    'DEF'
    data.name
    data.ref || 'U'
    0
    30
    'Y'
    'Y'
    1
    'F'
    'N'
  ].join(' ') + '\n'

  ret += [
    'F0'
    '"' + (data.ref || 'U') + '"'
    right
    top + 50
    60
    'H'
    'V'
    'R'
    'CNN'
  ].join(' ') + '\n'

  ret += [
    'F1'
    '"' + data.name + '"'
    if quad then 0 else -1*right
    if quad then 0 else top + 50
    60
    'H'
    'V'
    if quad then 'C' else 'L'
    'CNN'
  ].join(' ') + '\n'

  ret += [
    'F2'
    '"' + data.name + '"'
    0
    -1*vSpacing
    60
    'H'
    'I'
    'C'
    'CNN'
  ].join(' ') + '\n'

  ret += [
    'F3'
    '"' + (data.documentation || '~') + '"'
    0
    vSpacing
    60
    'H'
    'I'
    'C'
    'CNN'
  ].join(' ') + '\n'

  ret += 'DRAW\n'

# Bounding square
  ret += [
    'S'
    -1*right
    -1*top
    right
    top
    0
    1
    0
    'N'
  ].join(' ') + '\n'

#Pins
  if pins.l
    ret += pins.l.map (a, i) ->
      [
        'X'
        a.name
        a.number
        -1*(right+pinLength)
        topPins - i*vSpacing
        pinLength
        'R'
        40
        40
        1
        1
        a.type + if a.flag then ' ' + a.flag else ''
      ].join(' ')
    .join '\n'
    ret += '\n'

  if pins.r
    ret += pins.r.map (a, i) ->
      [
        'X'
        a.name
        a.number
        right+pinLength
        topPins - i*vSpacing
        pinLength
        'L'
        40
        40
        1
        1
        a.type + if a.flag then ' ' + a.flag else ''
      ].join(' ')
    .join '\n'
    ret += '\n'

  if pins.t
    start = -1*Math.round((pins.t.length - 1)*hSpacing/2)
    ret += pins.t.map (a, i) ->
      [
        'X'
        a.name
        a.number
        start + i*hSpacing
        top+pinLength
        pinLength
        'D'
        40
        40
        1
        1
        a.type + if a.flag then ' ' + a.flag else ''
      ].join(' ')
    .join '\n'
    ret += '\n'

  if pins.b
    start = -1*Math.round((pins.b.length - 1)*hSpacing/2)
    ret += pins.b.map (a, i) ->
      [
        'X'
        a.name
        a.number
        start + i*hSpacing
        -1*(top+pinLength)
        pinLength
        'U'
        40
        40
        1
        1
        a.type + if a.flag then ' ' + a.flag else ''
      ].join(' ')
    .join '\n'
    ret += '\n'

  if pins.n
    ret += pins.n.map (a, i) ->
      [
        'X'
        a.name
        a.number
        hSpacing
        vSpacing*2
        pinLength
        'L'
        40
        40
        1
        1
        a.type
        'N'
      ].join(' ')
    .join '\n'
    ret += '\n'

  ret += "ENDDRAW\nENDDEF"
  ret

module.exports.ext = "lib"