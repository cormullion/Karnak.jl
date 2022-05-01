using Karnak, Graphs, NetworkLayout, Colors

#=
animating NetWorkLayout's Stress and Spring algorithms while
increasing the number of iterations.

should really store all the iterations and then animate them,
rather than generating them repeatedly!
=#

function frame(scene, framenumber, g, w)
    setline(0.5)
    background("black")
    panes = Tiler(600, 400, 1, 2)
    sethue("gold")
    colors = [HSV(360h, 0.7, 0.7) for h in range(0, 1, length = ne(g))]
    @layer begin
        translate(first(panes[1]))
        bbox = BoundingBox(box(O, panes.tilewidth, panes.tileheight))
        drawgraph(
            g,
            boundingbox=bbox,
            layout = Stress(iterations = framenumber, weights = w),
            vertexshapesizes = rescale(framenumber, 1, 150, 10, 2),
            edgestrokecolors = colors,
        )
        text("Stress", boxbottomcenter(bbox))
    end
    @layer begin
        translate(first(panes[2]))
        sethue("cyan")
        bbox = BoundingBox(box(O, panes.tilewidth, panes.tileheight))
        drawgraph(
            g,
            boundingbox=bbox,
            layout = Spring(iterations = framenumber, initialtemp = 2),
            vertexshapesizes = rescale(framenumber, 1, 150, 10, 2),
            edgestrokecolors = colors,
        )
        text("Spring", boxbottomcenter(bbox))
    end
    text(string(framenumber), boxtopleft() + (10, 10))
end

function main()
    amovie = Movie(600, 400, "graphs")
    g = complete_graph(8)
    weights = rand(1:2, nv(g), nv(g))
    @show weights
    animate(
        amovie,
        Scene(amovie, (s, f) -> frame(s, f, g, weights), 1:100),
        framerate = 5,
        creategif = true,
        pathname = "/tmp/graph-iteration-animation.gif",
    )
end

main()
