using Karnak, Graphs, NetworkLayout, Colors, Test

#=
TODO
vertexshapes
vertexshapesizes
vertexstrokecolors
vertexstrokeweights
=#

@info "starting func tests"
@drawsvg begin
    background("grey10")
    g = smallgraph(:octahedral)
    sethue("gold")
    drawgraph(g, layout=stress,
        vertexlabels = 1:nv(g),
        vertexshapes = :none,
        edgelabelrotations = (n, s, d, from, to) -> begin
                sethue("green")
                circle(from, 10, :fill)
                sethue("red")
                circle(to, 15, :fill)
            end
        )
end 600 300

@drawsvg begin
    background("grey10")
    g = smallgraph(:octahedral)
    sethue("gold")
    drawgraph(g, layout=stress,
        vertexlabels = 1:nv(g),
        vertexshapes = :none,
        edgelabels = (n, s, d, from, to) -> begin
                text(string("Edge $n: $s -> $d"), midpoint(from, to))
            end
        )
end 600 300

@drawsvg begin
    background("grey10")
    g = smallgraph(:octahedral)
    sethue("gold")
    drawgraph(g, layout=stress,
        vertexshapes = :none,
        edgelines = (n, s, d, from, to) -> begin
                randomhue()
                arrow(from, to)
            end
        )
end 600 300

@drawsvg begin
    background("grey10")
    g = smallgraph(:octahedral)
    sethue("gold")
    drawgraph(g, layout=stress,
        vertexshapes = :none,
        edgestrokecolors = (n, s, d, from, to) -> begin
                c = Karnak.Luxor.get_current_color()
                if isodd(n)
                    RGB(c.g, c.b, c.r)
                else
                    c
                end
            end
        )
end 600 300

@drawsvg begin
    background("grey10")
    g = smallgraph(:octahedral)
    sethue("gold")
    drawgraph(g, layout=stress,
        vertexshapes = :none,
        edgestrokeweights = (n, s, d, from, to) -> begin
                rescale((s + d), 2, 12, 10, 0.2)
            end
        )
end 600 300

@drawsvg begin
    background("grey10")
    g = smallgraph(:octahedral)
    sethue("gold")
    drawgraph(g, layout=stress,
        vertexshapesizes=30,
        vertexfillcolors = (v) -> begin
            RGB(rescale(v, 1, nv(g), 0, 1), rescale(v, 1, nv(g), 1, 0), .7)
        end
        )
end 600 300

@drawsvg begin
    background("grey10")
    g = smallgraph(:octahedral)
    sethue("gold")
    drawgraph(g, layout=stress,
        vertexshapesizes=20,
        vertexlabels = (v) -> begin
            string("vertex $v")
        end
        )
end 600 300

@drawsvg begin
    background("grey10")
    g = smallgraph(:octahedral)
    sethue("gold")
    drawgraph(g, layout=stress,
        vertexshapesizes=20,
        vertexshapes = :square,
        vertexlabels = 1:nv(g),
        vertexshaperotations = (v) -> begin
            v * π/6
        end
        )
end 600 300
@info "finishing func tests"
