using Karnak, Graphs, NetworkLayout

add_numbered_vertex!(g) = add_vertex!(g)

function makegraph(labelstrings)
    g = DiGraph()
    labels = Set{String}()
    add_numbered_vertex!(g)
    push!(labels, "drawgraph()")
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

l = [
"edge",
"edgecurvature",
"edgedashpatterns",
"edgefunction",
"edgegaps",
"edgelabelcolors",
"edgelabelfontfaces",
"edgelabelfontsizes",
"edgelabelrotation",
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

@drawsvg begin
    background("black")
    sethue("white")
    fontface("JuliaMono")
    setline(1)
    nodesizes = map(t -> textextents(string(t))[3], labels)
    fontsize(10)
    setopacity(0.25)
    pts = map(pt -> (pt.x, pt.y), vcat(
        ngon(O - (200, 0), 300, 10, vertices=true),
        ngon(O + (200, 0), 300, 10, vertices=true),
    ))
    drawgraph(g,
        margin=60,
        layout=Stress(initialpos = pts),
        vertexfunction = (v, c) -> begin
            fontsize(12)
            if degree(g, v) == 1
                setopacity(1)
                text(labels[v], c[v], halign=:center)
            end
        end)
    fontsize(20)
    setopacity(1)
    text("drawgraph()", halign=:center, valign=:middle)
end 800 600
