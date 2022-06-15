using Karnak, Graphs, Colors

function manhattanline(pt1, pt2, action=:none)
    mp = midpoint(pt1, pt2)
    # fudge - draw a circle at each pt on the edge
    prettypoly([pt1,
          Point(pt1.x, mp.y),
          Point(pt1.x, mp.y),
          Point(pt2.x, mp.y),
          Point(pt2.x, mp.y)], :stroke,
          () -> circle(O, 2.5, :fill))
    arrow(Point(pt2.x, mp.y), Point(pt2.x, pt2.y - 30/2), linewidth=5)
end

@drawsvg begin
background("grey10")
sethue("lemonchiffon")
g = binary_tree(5)
dirg = SimpleDiGraph(collect(edges(g)))
astar = a_star(dirg, 1, 21)
drawgraph(dirg, layout=buchheim,
    vertexlabels = 1:nv(g),
    vertexshapes = (vtx) -> box(O, 30, 20, :fill),
    vertexlabelfontsizes = 16,
    edgelines = (edgenumber, edgesrc, edgedest, from, to) ->
        manhattanline(from, to, :stroke),
    edgegaps=20,
    edgestrokeweights= 5,
    edgestrokecolors = (edgenumber, s, d, f, t) -> (s ∈ src.(astar) && d ∈ dst.(astar)) ?
        colorant"gold" : colorant"grey40",
    vertexfillcolors = (vtx) -> (vtx ∈ src.(astar) ||
        vtx ∈ dst.(astar)) && colorant"gold"
    )
end 800 400
