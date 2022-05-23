using Karnak
using Test
using Luxor
using Graphs
using NetworkLayout
using Colors

@testset "Karnak.jl" begin
    @info "starting basic test"
    Drawing(600, 600, :svg)
    origin()
    background("grey10")

    tiles = Tiler(600, 600, 4, 4)

    for (pos, n) in tiles
        @layer begin
            randomhue()
            translate(pos)
            bb = BoundingBox(box(O, tiles.tilewidth, tiles.tileheight))
            box(bb, :stroke)
            if n == 1
                g = complete_graph(5)
                box(bb, :stroke)
                drawgraph(g, layout=shell, boundingbox=bb, edgelines=(edgenumber, edgesrc, edgedest, from, to)  -> begin
                    randomhue()
                    setline(rand() * 5)
                    line(from, to, :stroke)
                end)
            elseif n == 2
                g = smallgraph(:petersen)
                drawgraph(g, vertexlabels=10:30, boundingbox=bb, layout=shell ∘ adjacency_matrix)
            elseif n == 3
                g = wheel_graph(5)
                drawgraph(g, vertexlabels=["fee", "fi", "fo", "fum", 5], boundingbox=bb, layout=shell ∘ adjacency_matrix)
            elseif n == 4
                g = complete_bipartite_graph(5, 6)
                drawgraph(
                g,
                vertexlabels=1:20,
                layout=shell ∘ adjacency_matrix,
                boundingbox=bb,
                )
            elseif n == 5
                g = smallgraph(:truncatedtetrahedron)
                drawgraph(
                g,
                layout=(g) -> sfdp(g, Ptype=Float64, dim=2, tol=0.05, C=0.4, K=2),
                boundingbox=bb,
                margin=10
                )
            elseif n == 6
                g = complete_digraph(6)
                drawgraph(g, vertexshapes=:square, boundingbox=bb, margin=10, layout=(g) -> spectral(adjacency_matrix(g), dim=3))
            elseif n == 7
                g = complete_digraph(5)
                drawgraph(g, margin=10, vertexshapes=(v) -> begin
                    for i in 1:5:30
                        randomhue()
                        circle(O, i, :stroke)
                    end
                end, boundingbox=bb, layout=(g) -> spectral(adjacency_matrix(g), dim=2))
            elseif n == 8
                g = complete_digraph(15)
                drawgraph(g, layout=shell, margin=0, boundingbox=bb,
                edgelabels=(n, src, dst, f, t) ->
                begin
                    randomhue()
                    label(string(n), :n, midpoint(f, t) + Point(isodd(n) ? -10 : 20, 0), offset=20)
                    line(f, t, :stroke)
                end)
            elseif n == 10
                g = path_graph(6)
                drawgraph(g, boundingbox=bb, vertexlabeltextcolors=["red", "blue"], vertexfillcolors=["green", :none, "blue"], vertexshapes=[:circle, :square], vertexlabels=1:6, layout=shell)
            else
                g = path_graph(12)
                drawgraph(g, margin=20, boundingbox=bb, layout=shell)
            end
        end
    end
    @test finish() == true
    @info " finishing basic test"
end


@testset "functions" begin
    include("ftests.jl")
end
