using Graphs, Karnak, NetworkLayout, Colors

dg = Graph(30, [
[2, 5, 7],
[1, 3, 9],
[2, 4, 11],
[3, 5, 13],
[1, 4, 15],
[7, 15, 20],
[1, 6, 8],
[7, 9, 16],
[2, 8, 10],
[9, 11, 17],
[3, 10, 12],
[11, 13, 18],
[4, 12, 14],
[13, 15, 19],
[5, 6, 14],
[8, 17, 20],
[10, 16, 18],
[12, 17, 19],
[14, 18, 20],
[6, 16, 19]])

cycles = cycle_basis(dg)

@drawsvg begin # hide
    sethue("black")
    setopacity(0.8)
    sethue("orange")
    drawgraph(dg,
        vertexfunction = (v, c) -> ngon(c[v], 30, 6, 0, :fill),
        # vertexshapes=:circle,
        edgefunction = (from, to) -> arrow(from, to, linewidth=10),
        boundingbox = BoundingBox() * 1, layout = stress)

#     drawgraph(dg,
#             layout = stress,
#             vertexshapesizes= 10,
#             #vertexfillcolors = RGB(1, rand(), rand()),
#             vertexfillcolors = (v, c) -> RGB(rescale(v, 1, nv(dg)), rand(), rand()),
#             #vertexshapes = (v, c) -> ngon(c[v], rand(10:35), 6, 0, :fill),
#  #           edgelines  = range(1, nv(g), step=1),
#             edgecurvature= -10,
# #            edgestrokeweights = [1, 2, 13],
#             edgestrokecolors=[colorant"cyan", colorant"red", colorant"blue", colorant"gold"],
#             #edgestrokecolors = [colorant"gold", colorant"blue", :none],
#             )
end 800 500 # hide
