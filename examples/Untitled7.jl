using Karnak, Luxor, Graphs, NetworkLayout, Colors

function drawlittlegraph(pos, w)
    if w < 100
        drawgraph(star_graph(6),

            vertexshapes = :circle,
            boundingbox = BoundingBox(box(O, w, w))
            )
        return
    end
    @layer begin
        translate(pos)
        sethue(0.5, 0.5, rand(0.5:0.1:1.0))
        circle(O, 2, :fill)
        drawgraph(star_graph(6),

            boundingbox = BoundingBox(box(O, w, w)),
            edgelines  = :none,
            vertexfunction = (v, c) -> drawlittlegraph(c[v], w * 0.55)
            )
    end
end

@drawsvg begin
    background("grey10")
    sethue("gold")
    setline(.5)
 #   setopacity(0.5)
    drawgraph(star_graph(8), layout = stress,
        boundingbox  = BoundingBox()/2,
        vertexfunction = (v, c) -> drawlittlegraph(c[v], 300))

    # for (n, pt) in enumerate(star(O, 230, 12, 0.6, vertices=true))
    #     drawlittlegraph(pt, rescale(distance(O, pt), 50, 200, 80, 120))
    # end

end 800 600
