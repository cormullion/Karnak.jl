using Luxor, Karnak, Graphs, Colors, NetworkLayout

@draw begin
    background("black")

    pts = Point[
        Point(-100, -200),
        Point(-100, 0),
        Point(-100, 200),
        Point(150, -200),
        Point(150, 200),
    ]
    g = Graph(length(pts))
    add_edge!(g, 1, 2)
    add_edge!(g, 2, 3)
    add_edge!(g, 2, 4)
    add_edge!(g, 2, 5)
    sethue("gold")
    setline(0.3)
    drawgraph(g,
        layout=pts,
#        edgecurvature = 10,
        edgestrokeweights = 60,
        vertexshapesizes = 140,
        vertexshapes = :square,
        )

    sethue("black")

    drawgraph(g,
        layout=pts,
#        edgecurvature = 10,
        edgestrokeweights = 40,
        vertexshapesizes = 120,
        vertexshapes = :square,
        )

    sethue("gold")
    drawgraph(g,
        layout=pts,
#        edgecurvature = 10,
        edgestrokeweights = 10,
        vertexshapesizes = 80,
        #vertexshapes = :square,
        vertexshapes = (v) -> ngon(O, 40, 6, 0, :fill)
        )
end
