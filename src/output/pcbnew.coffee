# pad #   num
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
  name = data.name
  data = data.contents
  console.log "Generating #{ name }"

  ret = """
        (module #{ name } (layer F.Cu)
          (at 0 0)
          (fp_text reference #{ name } (at #{ data.refdes.join(' ') }) (layer F.SilkS)
            (effects (font (size #{ @textHeight } #{ @textHeight }) (thickness #{ @silkWidth })))
          )
          (fp_text value Val** (at 0 0) (layer F.SilkS) hide
            (effects (font (thickness 0.15)))
          )

        """
  if data.mask
    ret += "  (solder_mask_margin #{ data.mask })\n"

  if data.pads
    ret += data.pads.map (a) =>
      a.size ||= a.drill

      num: if a.num == "" then '""' else a.num
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
      lCu: if a.drill then '*.Cu' else if a.back then 'B.Cu' else 'F.Cu'
      lMask: if a.drill then '*.Mask' else if a.back then 'B.Mask' else 'F.Mask'
      lPaste: if a.nopaste then '' else if a.back then 'B.Paste' else 'F.Paste'
      lSilk: if a.drill then 'F.SilkS' else ''
      mask: a.mask
      solder: a.solder
    .map (a) ->
      ret = "  (pad #{ a.num } #{ a.type } #{ a.padShape  }" +
      " (at #{ a.location.join(' ') }) (size #{ a.size.join(' ') })"

      if a.drill
        ret += " (drill #{ if a.drill?[1] then 'oval ' + a.drill.join(' ') else a.drill })"

      ret += "\n    (layers #{ a.lCu } #{ a.lMask } #{ a.lPaste } #{ a.lSilk })\n"
      if a.mask
        ret += "    (solder_mask_margin #{ a.mask })\n"
      if a.solder
        ret += "    (solder_paste_margin_ratio #{ a.solder })\n"
      ret += "  )" 
      ret
    .join('\n') + '\n'

  if data.silk
    ret += data.silk.map (a) =>
      layer = switch a.layer
        when 'backSilk' then 'B.SilkS'
        when 'edge' then 'Edge.Cuts'
        when 'frontCopper' then 'F.Cu'
        when 'backCopper' then 'B.Cu'
        when 'frontMask' then 'F.Mask'
        when 'backMask' then 'B.Mask'
        else 'F.SilkS'
      width = a.width || @silkWidth
      "  (fp_line (start #{ a.start.join(' ') }) (end #{ a.end.join(' ') }) (layer #{ layer }) (width #{ width }))"
    .join('\n') + '\n'

  if data.arc
    ret += data.arc.map (a) =>
      layer = switch a.layer
        when 'backSilk' then 'B.SilkS'
        when 'edge' then 'Edge.Cuts'
        when 'frontCopper' then 'F.Cu'
        when 'backCopper' then 'B.Cu'
        when 'frontMask' then 'F.Mask'
        when 'backMask' then 'B.Mask'
        else 'F.SilkS'
      width = a.width || @silkWidth
      "  (fp_arc (start #{ a.location.join(' ') }) (end #{ a.start.join(' ') }) (angle #{ a.angle }) (layer #{ layer }) (width #{ width }))"
    .join('\n') + '\n'

  #Draw the assembly outline on eco1
  if data.assembly
    ret += data.assembly.map (a) =>
      width = a.width || @silkWidth
      "  (fp_line (start #{ a.start.join(' ') }) (end #{ a.end.join(' ') }) (layer Eco1.User) (width #{ width }))"
    .join('\n') + '\n'

  #Draw the courtyard on eco2
  if data.courtyard
    ret += data.courtyard.map (a) =>
      width = a.width || @silkWidth
      "  (fp_line (start #{ a.start.join(' ') }) (end #{ a.end.join(' ') }) (layer Eco2.User) (width #{ width }))"
    .join('\n') + '\n'

  ret += ")"
  {
    filename: name + '.kicad_mod'
    contents: ret
  }