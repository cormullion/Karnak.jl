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

g = barbell_graph(8, 8)

g = complete_graph(12)

cycles = cycle_basis(g)

@draw begin # hide
    background("black")
    setopacity(0.9)
    sethue("orange")
    #drawgraph(g, edgestrokeweights=1.5, layout = stress, boundingbox = BoundingBox()/1.2)
    fontsize(40)
    drawgraph(g,
            layout = stress,
            boundingbox = BoundingBox()/1.2,
            vertexshapes = 2:13,
            vertexshapesizes = 30,
            vertexlabels = 1:ne(g),
            vertexfillcolors=[colorant"cyan", colorant"purple"],
            edgelines  = :none, #range(1, ne(g), step=1),
            # vertexfillcolors = (v, c) -> begin
            #     sethue(rand(), rand(), rand())
            #     circle(c[v], 6, :fill)
            #     end,
            # vertexstrokecolors = (v, c) -> begin
            #     sethue(rand(), rand(), rand())
            #     circle(c[v], 20, :fill)
            #     end,
            #edgestrokecolors=[colorant"cyan", colorant"red", colorant"blue"],
            #edgestrokeweights=[2, 1],
            #edgetextcolors=colorant"cyan",
            #edgelabels = 1:89,
            )
end 1000 1000 # hide
