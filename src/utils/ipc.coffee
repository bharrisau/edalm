class IPC
  F = 0.1
  P = 0.1
  dims = 1

  fillets:
    gullWing_g625:
      jT: [0.15, 0.35, 0.55]
      jH: [0.25, 0.35, 0.45]
      jS: [0.01, 0.03, 0.05]
      c: [0.1, 0.25, 0.5]
      round: [5, 5, 20]
    gullWing_le25:
      jT: [0.15, 0.35, 0.55]
      jH: [0.25, 0.35, 0.45]
      jS: [-0.04, -0.02, 0.01]
      c: [0.1, 0.25, 0.5]
      round: [5, 10, 20]
    gullWing_g625_tall:
      jT: [0.15, 0.35, 0.55]
      jH: [0.05, 0.15, 0.25]
      jS: [0.01, 0.03, 0.05]
      c: [0.1, 0.25, 0.5]
      round: [5, 5, 20]
    gullWing_le25_tall:
      jT: [0.15, 0.35, 0.55]
      jH: [0.05, 0.15, 0.25]
      jS: [-0.04, -0.02, 0.01]
      c: [0.1, 0.25, 0.5]
      round: [5, 10, 20]
    noLead:
      jT: [0.2, 0.3, 0.4]
      jH: [0, 0, 0]
      jS: [-0.04, -0.04, -0.04]
      c: [0.1, 0.25, 0.5]
      round: [20, 20, 20]

  process: (data, useD) ->
    E = if useD then data.D else data.E 

    Lmin: E[1]
    Lmax: E[0]
    Ltol: E[0] - E[1]
    Smin: E[1] - 2*data.L[0]
    Smax: E[0] - 2*data.L[1]
    Stol: Math.sqrt(
      Math.pow(E[0] - E[1], 2) +
      2*Math.pow(data.L[0] - data.L[1], 2))
    Wmin: data.b[1]
    Wmax: data.b[0]
    Wtol: data.b[0] - data.b[1]

  round: (val, scale) -> Math.round(val*scale)/scale

  landGen: (data, fillet, input) =>
    Z = @round(data.Lmin + 2*fillet.jT[dims] +
      Math.sqrt(Math.pow(data.Ltol, 2) + F*F + P*P), fillet.round[0])
    G = @round(data.Smax - 2*fillet.jH[dims] -
      Math.sqrt(Math.pow(data.Stol, 2) + F*F + P*P), fillet.round[1])
    X = @round(data.Wmin + 2*fillet.jS[dims] +
      Math.sqrt(Math.pow(data.Wtol, 2) + F*F + P*P), fillet.round[2])

    #Use thermal data to ensure minimum (0.2mm) gap between heel and thermal
    if input.E2
      G = Math.max G, input.E2[0] + 0.4

    {
      padWidth: X
      padLength: @round((Z - G)/2, 100)
      offset: @round((Z+G)/4, 100)
      courtyard: fillet.c[dims]
    }

  gullWing: (data) ->
    extra = @process data
    extra2 = @process data, true
    wide = (data.e || 1) > 0.625
    tall = (data.L[0] - data.L[1]) <= 0.5 and data.A and extra.Smin < data.A[0]

    d = switch
      when wide and !tall then @fillets.gullWing_g625
      when wide and !tall then @fillets.gullWing_le25
      when wide and tall then @fillets.gullWing_g625_tall
      else @fillets.gullWing_le25_tall

    {
      X: @landGen extra, d, data
      Y: @landGen extra2, d, data
    }

  noLead: (data) ->
    extra = @process data
    extra2 = @process data, true
    {
      X: @landGen extra, @fillets.noLead, data
      Y: @landGen extra2, @fillets.noLead, data
    }

  thermal: (pin, x, y) ->
    #Work out number of pads in x and y dir (max 2mm)
    #Return array of pads with correct solder amount
    {
      num: pin
      location: [0, 0]
      size: [x, y]
      square: true
    }

module.exports = (dsl) ->
  if !dsl.util
    dsl.util = new IPC(dsl)