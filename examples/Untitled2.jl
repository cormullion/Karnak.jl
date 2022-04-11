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

@drawsvg begin # hide
    sethue("black")
    sethue("orange")
    drawgraph(dg,
            layout = stress,
            vertexshapesizes= 10,
            #vertexfillcolors = RGB(1, rand(), rand()),
            vertexfillcolors = (v) -> RGB(rescale(v, 1, nv(dg)), rand(), rand()),
            vertexshapes = (v) -> ngon(O, rand(5:15), 6, 0, :fill),
            edgelines  = range(1, nv(dg), step=1),
            edgecurvature= -10,
            edgestrokeweights = [1, 2, 23],
            edgestrokecolors=[colorant"cyan", colorant"red", colorant"blue", colorant"gold"],
            )
end 800 500 # hide
