using Karnak, Graphs, NetworkLayout

#=
Output a tree graph of a Julia type

This isn't yet working 100%, I still don't
understand the Buchheim layout yet...
=#

add_numbered_vertex!(g) = add_vertex!(g)

function build_type_tree(g, T, level=0)
    add_numbered_vertex!(g)
    push!(labels, T)
    for t in subtypes(T)
        build_type_tree(g, t, level+1)
        add_edge!(g,
            findfirst(isequal(T), labels),
            findfirst(isequal(t), labels))
    end
end

function manhattanline(pt1, pt2)
    mp = midpoint(pt1, pt2)
    poly([pt1,
          Point(pt1.x, mp.y),
          Point(pt1.x, mp.y),
          Point(pt2.x, mp.y),
          Point(pt2.x, mp.y),
          Point(pt2.x, pt2.y - get_fontsize())
          ], :stroke)
end

using Dates
g = DiGraph()
labels = []
build_type_tree(g, Dates.AbstractTime)
labels = map(string, labels)

@drawsvg begin
    background("white")
    sethue("black")
    fontface("JuliaMono")
    setline(1)
    nodesizes = map(t -> textextents(string(t))[3], labels)
    fontsize(10)
    drawgraph(g, margin=50,
        layout = Buchheim(nodesize = nodesizes),
        vertexfunction = (v, c) -> text(labels[v], c[v], halign=:center),
        edgefunction  = (n, s, d, f, t) -> manhattanline(f, t)
    )
end 1200 600
