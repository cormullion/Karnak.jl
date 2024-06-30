using Karnak, Graphs

# draw tree diagram of `drawgraph()`'s keywords

l = [
"edge",
"edgearrows",
"edgecurvature",
"edgedashpatterns",
"edgefunction",
"edgegaps",
"edgelabelcolors",
"edgelabelfontfaces",
"edgelabelfontsizes",
"edgelabelrotations",
"edgelabels",
"edgelines",
"edgelist",
"edgestrokecolors",
"edgestrokeweights",
"vertex",
"vertexfillcolors",
"vertexfunction",
"vertexlabelfontfaces",
"vertexlabelfontsizes",
"vertexlabeloffsetangles",
"vertexlabeloffsetdistances",
"vertexlabelrotations",
"vertexlabels",
"vertexlabeltextcolors",
"vertexshaperotations",
"vertexshapes",
"vertexshapesizes",
"vertexstrokecolors",
"vertexstrokeweights",
]

add_numbered_vertex!(g) = add_vertex!(g)

function makegraph(labelstrings)
    g = DiGraph()
    labels = String[]
    push!(labels, "drawgraph()")
    add_numbered_vertex!(g)
    for (n, label) in enumerate(labelstrings)
        if label ∈ labels
            label = label * string(n)
        end
        add_vertex!(g)
        push!(labels, label)
    end
    if length(labels) != length(unique(labels))
        throw(error("labels aren't unique"))
    end
    return (g, collect(labels))
end

function addedges(g, labels, prs)
   for pr in prs
       if first(pr) !=  last(pr)
           add_edge!(g,
               findfirst(isequal(first(pr)), labels),
               findfirst(isequal(last(pr)), labels))
       end
   end
end

g, labels = makegraph(l)

addedges(g, labels, [
"drawgraph()" => "vertex",
"drawgraph()" => "edge",
])

for l in labels
    if startswith(l, "vertex")
        addedges(g, labels, ["vertex" => l])
    end
    if startswith(l, "edge")
        addedges(g, labels, ["edge" => l])
    end
end

@svg begin
    background("black")
    sethue("white")
    fontface("JuliaMono")
    setline(1)
    rotate(-π/2)
    nodesizes = fill(0.2, length(labels))
    fontsize(10)
    setopacity(0.25)
    pts = map(pt -> (pt.x, pt.y), vcat(
        ngon(O - (200, 0), 300, 15, vertices=true),
        ngon(O + (200, 0), 300, 15, vertices=true),
    ))
    drawgraph(g,
        margin=20,
#        layout=Stress(initialpos = pts),
        layout = Buchheim(nodesize=nodesizes),
        vertexfunction = (v, c) -> begin
            fontsize(12)
            if degree(g, v) == 1
                setopacity(1)
                text(labels[v], c[v], angle=π/2, halign=:left)
            else
                setcolor("cyan")
                text("[$(labels[v])]", c[v], angle=π/2, halign=:center)
            end
        end)
@show pwd()
end 600 600 "docs/src/assets/figures/drawgraphkeywords.svg"
