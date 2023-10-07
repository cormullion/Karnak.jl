using Karnak, Graphs, Colors, NetworkLayout

function drawlittlegraph(pos, w)
    @layer begin
        translate(pos)
        drawgraph(star_graph(12),
            layout = stress,
            vertexfillcolors = [RGB(Karnak.Luxor.julia_purple...),RGB(Karnak.Luxor.julia_green...),RGB(Karnak.Luxor.julia_red...)],
            vertexshapesizes = 8,
            boundingbox = BoundingBox(box(O, w, w)))
    end
end

function set_gold_blend()
    gblend = blend(O, 0, O, 140, "gold", "gold3")
    setblend(gblend)
end

Drawing(500, 600, "/tmp/logo.svg")
    origin()
    width = 180
    height= 240

    setopacity(1.0)
    setline(20)
    setlinecap("butt")
    setlinejoin("round")
    width = 200
    height= 280

    sethue(0,0.1,0.2)
    squircle(O, width, height-5, rt=0.4, action=:fill)

    set_gold_blend()
    squircle(O, width, height-5, rt=0.4, action=:path)
    strokepath()

    pts = Point[
        Point(-80, -160),
        Point(-80, 0),
        Point(-80, 160),
        Point(85, -160),
        Point(85, 160),
    ]

    g = Graph(length(pts))
    add_edge!(g, 1, 2)
    add_edge!(g, 2, 3)
    add_edge!(g, 2, 4)
    add_edge!(g, 2, 5)
    sethue("gold")
    setline(2)
    setlinecap("butt")

    drawgraph(g,
        layout=pts,
        edgestrokeweights = 20,
        vertexshapesizes = 60,
        vertexshapes = :square
        )

    drawgraph(g,
        layout=pts,
        vertexfillcolors = colorant"black",
        vertexshapes = :square,
        vertexshapesizes = 50,
    )

    drawgraph(g,
        layout=pts,
        vertexfillcolors = colorant"black",
        edgestrokeweights = 0,
        vertexfunction = (v, c) -> drawlittlegraph(c[v], 120),
        )
finish()
preview()
