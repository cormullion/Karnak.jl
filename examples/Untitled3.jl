using Karnak
using Colors
using Graphs
using NetworkLayout

@drawsvg begin
	sethue("orange")
	gd = DiGraph()
	add_vertices!(gd, 4)
	add_edge!(gd, 1, 2)
	add_edge!(gd, 1, 3)
	add_edge!(gd, 2, 3)
	add_edge!(gd, 1, 4) # vertex 1 to vertex 4
	add_edge!(gd, 4, 1) # vertex 4 to vertex 1
	fontsize(50)
	drawgraph(gd, vertexlabels = [1, 2, 3, 4])
end

g = Graph([1 0 1 0;
           0 1 1 1;
           1 1 0 0;
		   0 1 0 0])

@drawsvg begin # hide
	sethue("fuchsia")
	drawgraph(g, vertexlabels=1:4, edgecurvature=10, layout=shell)
end 300 300 # hide
