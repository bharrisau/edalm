coffee = require 'coffee-script'
ee = require './output/eeSchema'
fs = require 'fs'
path = require 'path'

F = 0.01
P = 0.1

data = coffee.eval(fs.readFileSync(process.argv[2]).toString(), {sandbox:true})

modName = data.name || path.basename(process.argv[2], path.extname(process.argv[2]))
data.name = modName

lib = {
  Z: (Lmin, Ltol, Jt) -> Lmin + 2*Jt + Math.sqrt(Ltol*Ltol + F*F + P*P)
  G: (Lmax, Ltol, Tmin, Ttol, Jh) -> Lmax - 2*Tmin - 2*Jh -
    Math.sqrt(Ltol*Ltol + 2*(Ttol*Ttol) + F*F + P*P)
  X: (Wmin, Wtol, Js) -> Wmin + 2*Js + Math.sqrt(Wtol*Wtol + F*F + P*P)
  thermal: (Lmin, Ltol) -> Lmin + Math.sqrt(Ltol*Ltol + F*F + P*P)

  to100Mil: (val) -> Math.round(val * 3937)
  toMM: (val) -> "" + Math.round(val*1000)/1000 + "mm"

  toPath: (pad) ->
    horizontal = pad.x >= pad.y
    width = if horizontal then pad.y else pad.x
    length = if horizontal then pad.x else pad.y
    midline = if horizontal then pad.y0 else pad.x0
    point = if horizontal then pad.x0 else pad.y0

    if horizontal
      {
        width: width
        x1: point - (length-width)/2
        y1: midline
        x2: point + (length-width)/2
        y2: midline
      }
    else
      {
        width: width
        x1: midline
        y1: point - (length-width)/2
        x2: midline
        y2: point + (length-width)/2
      }

  silkWidth: 0.12
  refDesHeight: 1
  clearance: 0.15
  maskClearance: 0
}

#dat = require('./'+data.package.type)(data['package'], lib)
fs.writeFile path.join(process.argv[3], (modName + '.' + ee.ext)), ee(data, lib)