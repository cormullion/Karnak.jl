using Karnak
using Luxor
using Colors
using Graphs
using NetworkLayout
using SimpleWeightedGraphs


function edgeweights()
    wg = SimpleWeightedGraph(Graph(4, 6), 4.0)

    #wg = SimpleWeightedGraph(dodecg)
    #swg =SimpleWeightedGraph(Graph(4, 6), 4.0) # assigns weight of 4.0 everywhere

    get_weight(wg, 1, 2)

    #add_edge!(wg, from, to, weight)

    sources = [1,2,1]
    destinations = [2,3,3]
    weights = [0.5, 0.8, 2.0]
    wg1 = SimpleWeightedGraph(sources, destinations, weights)

    adjacency_matrix(wg1)

    @drawsvg begin
    sethue("gold")
    drawgraph(wg1, edgelabels = 1:200)
    end
end


function edgelabeldict()
    n = 8
    g = wheel_digraph(n)
    edgelabel_dict = Dict()
    edgelabel_mat = Array{String}(undef, n, n)
    for i in 1:n
        for j in 1:n
            edgelabel_mat[i, j] = edgelabel_dict[(i, j)] = string("edge ", i, " to ", j)
        end
    end
    @drawsvg begin
      fontsize(10)
      background("black")
      sethue("gold")
      drawgraph(g, edgelabels = edgelabel_dict, edgelabelrotations=π/4, edgelabelcolors=[colorant"red", colorant"blue"])
      #drawgraph(g, edgelabels = (edgenumber, edgesrc, edgedest, from, to) -> text(string(edgenumber), midpoint(from, to)))
    end
end

edgeweights()

#edgelabeldict()
