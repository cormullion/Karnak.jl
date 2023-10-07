using Karnak, Graphs, NetworkLayout, Colors

function whiten(col::Color, f=0.5)
    hsl = convert(HSL, col)
    h, s, l = hsl.h, hsl.s, hsl.l
    return convert(RGB, HSL(h, s, f))
end

function drawball(pos, ballradius, col::Color;
        fromlum=0.2,
        tolum=1.0)
    gsave()
    translate(pos)
    for i in ballradius:-0.25:1
        sethue(whiten(col, rescale(i, ballradius, 0.5, fromlum, tolum)))
        offset = rescale(i, ballradius, 0.5, 0, -ballradius/2)
        circle(O + (offset, offset), i, :fill)
    end
    grestore()
end

@drawsvg begin
background("grey10")

g = grid((10, 10))

A = []

drawgraph(g,
    layout = squaregrid,
    edgelines = 0,
    vertexshapes = (v) -> begin
            c = rand(1:3)
            col = RGB([Karnak.Luxor.julia_red, Karnak.Luxor.julia_purple, Karnak.Luxor.julia_green][c]...)
            drawball(O, 25, col)
            c == 1 && push!(A, v)
        end
    )

drawgraph(g,
    layout = squaregrid,
    edgelines = 0,
    vertexshapes = :none,
    vertexlabels = (v) -> v ∈ A && "red")

end 600 600
