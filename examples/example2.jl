println("starting execution\n\n\n")
using Graphs
println("using graphs")

using Luxor
println("using Luxor")

using Karnak
println("using Karnak")

using NetworkLayout
println("using NetworkLayout")

using Colors
println("using Colors")

#g = barbell_graph(8, 8)

g = complete_graph(12)


@draw begin # hide
    background("black")
    setopacity(0.9)
    sethue("orange")
    #drawgraph(g, edgestrokeweights=1.5, layout = stress, boundingbox = BoundingBox()/1.2)
    fontsize(40)
    drawgraph(g,
            layout = squaregrid,
            boundingbox = BoundingBox()/1.2,
            vertexshapes = (v) -> star(O, 80, 6, 0.5, 0, :stroke),
            #vertexshapesizes = 44,
            #vertexlabels = 1:ne(g),
            #vertexfillcolors=[colorant"cyan", colorant"purple"],
            #edgelist  = [Edge(2=>8)],
            edgelines = 1:100, #:none, #range(1, ne(g), step=1),
            edgelabels = ["GRID"],# vertexfillcolors = (v, c) -> begin
            #edgelabels = 1:89,
            #     sethue(rand(), rand(), rand())
            #     circle(c[v], 6, :fill)
            #     end,
            # vertexstrokecolors = (v, c) -> begin
            #     sethue(rand(), rand(), rand())
            #     circle(c[v], 20, :fill)
            #     end,
            #edgestrokecolors=[colorant"cyan", colorant"red"],
            #edgestrokeweights=[1, 2.5],
            edgelabelcolors=colorant"cyan",
            )
end 1000 1000 # hide
