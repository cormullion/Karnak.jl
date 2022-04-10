using Karnak, Luxor, Graphs, NetworkLayout, Colors

function drawlittlegraph(pos, w)
    @layer begin
        translate(pos)
        drawgraph(star_graph(rand(6:13)),
            layout = stress,
            boundingbox = BoundingBox(box(O, w, w))
            )
    end 
end

@drawsvg begin
    background("grey10")
    sethue("gold")
    for (n, pt) in enumerate(star(O, 230, 12, 0.6, vertices=true))
        drawlittlegraph(pt, rescale(distance(O, pt), 50, 200, 80, 120))
    end
end 800 600
