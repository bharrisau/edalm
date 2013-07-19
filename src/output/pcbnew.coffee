# pad {
#   num
#   location: [x, y]
#   size: d or [x, y]
#   drill: d or [x, y]
#   square: true
#   nopaste: true
#   hole: true
#   back: true
# }

module.exports = (data, lib) -> data.map(each, lib)

each = (data) ->
  ret = """
        (module #{ data.name } (layer F.Cu)
          (at 0 0)
          (fp_text reference #{ data.name } (at 0 0) (layer F.SilkS)
            (effects (font (size #{ data.font || 0.8} #{ data.font || 0.8}) (thickness #{ data.silkWidth || 0.12})))
          )
        """

  if data.pads
    ret += data.pads.map (a) ->
      num: a.num
      type: if a.hole
        'np_thru_hole'
      else if a.drill
        'thru_hole'
      else if a.nopaste
        'connect'
      else
        'smd'
      padShape: if a.square
        'rect'
      else if a.size[0] && a.size[1] && a.size[0] != a.size[1]
        'oval'
      else
        'circle'
      location: a.location
      size: if a.size[1] then a.size else [a.size, a.size]
      drill: a.drill
      lCu: if drill then '*.Cu' else if a.back then 'B.Cu' else 'F.Cu'
      lMask: if drill then '*.Mask' else if a.back then 'B.Mask' else 'F.Mask'
      lPaste: if a.nopaste then '' else if a.back then 'B.Paste' else 'F.Paste'
      lSilk: if a.drill then 'F.Silk' else ''
    .map (a) ->
      """
        (pad #{ a.num } #{ a.type } #{ a.padShape  } (at #{ a.location.join(' ') }) (size #{ a.size.join(' ') }) (drill #{ if a.drill[1] then 'oval ' + a.drill.join(' ') else a.drill })
          (layers #{ a.lCu } #{ a.lMask } #{ a.lPaste } #{ a.lSilk })
        )
      """
    .join('\n') + '\n'

  if data.silk
    ret += data.silk.map (a) ->
      layer = switch a.layer
        when 'backSilk' then 'B.SilkS'
        when 'edge' then 'Edge.Cuts'
        when 'frontCopper' then 'F.Cu'
        when 'backCopper' then 'B.Cu'
        when 'frontMask' then 'F.Mask'
        when 'backMask' then 'B.Mask'
        else 'F.SilkS'
      width = a.width || data.silkWidth || 0.12
      """
        (fp_line (start #{ a.start.join(' ') }) (end #{ a.end.join(' ') }) (layer #{ layer }) (width #{ width }))
      """
    .join('\n') + '\n'

  if data.arc
    ret += data.arc.map (a) ->
      layer = switch a.layer
        when 'backSilk' then 'B.SilkS'
        when 'edge' then 'Edge.Cuts'
        when 'frontCopper' then 'F.Cu'
        when 'backCopper' then 'B.Cu'
        when 'frontMask' then 'F.Mask'
        when 'backMask' then 'B.Mask'
        else 'F.SilkS'
      width = a.width || data.silkWidth || 0.12
      """
        (fp_arc (start #{ a.location.join(' ') }) (end #{ a.start.join(' ') }) (angle #{ a.angle }) (layer #{ layer }) (width #{ width }))
      """
    .join('\n') + '\n'

  ret += ")"
  {
    filename: data.name + '.kicad_mod'
    contents: ret
  }