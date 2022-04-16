using Luxor, Karnak, Graphs, Colors, NetworkLayout

function test1()
    Drawing(600, 600, :png)
    origin()
    background("grey10")

    tiles = Tiler(600, 600, 4, 4)

    for (pos, n) in tiles
        println(n)
        @layer begin
            randomhue()
            translate(pos)
            bb = BoundingBox(box(O, tiles.tilewidth, tiles.tileheight))
            box(bb, :stroke)
            if n == 1
                g = complete_graph(5)
                box(bb, :stroke)
                drawgraph(g, layout=shell, boundingbox=bb, edgelines=(edgenumber, edgesrc, edgedest, from, to) -> begin
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
                drawgraph(g, margin=10, vertexshapes=(vertex) -> begin
                        for i in 1:5:30
                            randomhue()
                            circle(O, i, :stroke)
                        end
                    end, boundingbox=bb,
                    # layout=(g) -> spectral(adjacency_matrix(g), dim=2)
                    )
            elseif n == 8
                g = complete_digraph(15)
                drawgraph(g, layout=shell, margin=0, boundingbox=bb,
                    edgelabels=(n, s, d, f, t) ->
                        begin
                            randomhue()
                            label(string(n), :n, midpoint(f, t) + Point(isodd(n) ? -10 : 20, 0), offset=20)
                            line(f, t, :stroke)
                        end)
            elseif n == 10
                g = clique_graph(4, 10)
                drawgraph(g,
                    boundingbox=bb,
                    vertexlabeltextcolors=["red", "blue"],
                    vertexfillcolors=["green", :none, "blue"],
                    vertexshapes=[:circle, :square],
                    vertexlabels=1:nv(g),
                    layout=shell)
            elseif n == 11
                g = barbell_graph(5, 5)
                drawgraph(g,
                    boundingbox=bb,
                    vertexlabeltextcolors=["red", "blue"],
                    vertexfillcolors=["green", :none, "blue"],
                    vertexshapes=[:circle, :square],
                    vertexlabels=1:nv(g),
                    layout=stress)
            elseif n == 12
                g = ladder_graph(7)
                drawgraph(g,
                    boundingbox=bb,
                    vertexlabeltextcolors=["red", "blue"],
                    vertexfillcolors=["green", :none, "blue"],
                    vertexshapes=[:circle, :square],
                    vertexlabels=1:nv(g),
                    layout=squaregrid)
            elseif n == 13
                g, dists = euclidean_graph(5, 2)
                drawgraph(g,
                    boundingbox=bb,
                    vertexlabels=1:nv(g),
                    layout=stress)


            else
                g = lollipop_graph(12, 3)
                drawgraph(g, margin=20, boundingbox=bb, layout=stress)
            end
        end
    end
    finish()
    preview()
end

function test2()
    @drawsvg begin
        background("black")
        sethue("grey50")
        fontsize(30)
        setline(10)
        #g = complete_graph(10)

        #g = complete_graph(20)

        #drawgraph(g)

        #drawgraph(g, vertexfunction  = (v, coords) -> circle(coords[v], 5, :fill), edgefunction = (n, f, t, s, d) -> arrow(f, t, linewidth=0.5))

        setopacity(0.85)
        setline(3)
        g = complete_graph(6)
        drawgraph(g,
            #vertexfunction = (v, c) -> circle(c[v], 15, :fill),  # this overrides everything
            # vertexshapes=(v, c) -> circle(c[v], 10, :stroke),
            vertexshapes= [:circle, :square],
            #vertexfillcolors = :none, # colorant"blue",
            vertexfillcolors=colorant"orange",
            vertexstrokecolors=[colorant"red", :none, colorant"cyan"],
            #vertexlabeltextcolors = [colorant"red", :none, colorant"cyan"],
            #vertexlabels = 1:10,
            #vertexlabeltextcolors = [colorant"red", :none],
            #vertexlabels = 1:10,
            vertexlabels=1:nv(g),
            vertexstrokeweights = [0.3, 20, :none],
            #vertexlabels = ["Buckle my shoe", :none],
            #vertexlabels = (v, c) -> text("string(rand(100:200))", c[v]),
            #layout=(g) -> spectral(adjacency_matrix(g), dim=2),
            edgelabels=[1, 2, 3],
            edgestrokecolors=[colorant"red", colorant"blue"],
            layout=stress,
            margin=50)

        #	drawgraph(g, layout=shell)
        #	drawgraph(g, vertexlabels = 1:nv(g), layout=shell)
        #	drawgraph(g, vertexlabels = ["A", "B", "C", "P", "Q"], layout=shell)

        # 	drawgraph(g, vertexlabels = (v, c) -> (text(string(v), c[v])), vertexlabeltextcolors=["red", "blue"], layout=shell)

        #drawgraph(g, vertexlabeltextcolors=["red", "blue"], vertexfillcolors=["green", "blue"], vertexshapes = [:circle, :square], vertexlabels = 1:6, layout=shell)

        #drawgraph(g, vertexlabels = (v, c) -> (fontsize(30); sethue(get(ColorSchemes.leonardo, rand())); text(string(nv(g), v), c[v])), edgelabels = 1:10, layout=stress)

        # drawgraph(g, vertexshapes = [:circle, :square], edgelabels = 1:10, layout=shell)
        #g = path_graph(6)
        #bb = BoundingBox()
        #drawgraph(g, margin=20, vertexlabels=["a", "b", "c"], edgelabels=1:10, layout=shell)
    end 600 650
end


function test3()
    d1 = @drawsvg begin
        background("black")
        sethue("gold")
        drawgraph(smallgraph(:house), vertexshapes=[:circle], vertexlabels=1:20, layout=(g) -> spectral(adjacency_matrix(g), dim=2), margin=0)
    end 1800 300

    d2 = @drawsvg begin
        background("black")
        sethue("gold")
        drawgraph(smallgraph(:house), vertexshapes=[:circle], vertexlabels=1:20, layout=spectrallayout, margin=10)
    end 300 1800
    vcat(d1, d2)
end

spectrallayout(g) = NetworkLayout.spectral(adjacency_matrix(g), dim=2)

function test4()
    d1 = @drawsvg begin
        background("black")
        sethue("gold")
        # drawgraph(wheel_graph(12), layout=(g) -> spectral(adjacency_matrix(g), dim=2), margin=0)
        drawgraph(smallgraph(:icosahedral), vertexshapesizes = collect(rand(10:30, 10)), vertexshapes=:circle, vertexfillcolors = [RGB(Luxor.julia_green...), RGB(Luxor.julia_purple...), RGB(Luxor.julia_red...)],
        edgestrokeweights = 3:-1:1, layout=stress, margin=10)
    end 600 600
end

test1()
#test2()
#test3()
#test4()
