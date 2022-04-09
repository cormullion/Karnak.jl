using Karnak, Luxor, Graphs, NetworkLayout, Colors

@drawsvg begin
	background("grey10")
	g = smallgraph(:sedgewickmaze)

	@show ne(g)
	sethue("slateblue")
	V = Point[]
	setline(2)
	drawgraph(g, layout = stress,
		vertexshapes = :circle,
		vertexshapesizes = 0,
		#edgefunction = (f, t) -> (push!(V, f); push!(V, t))
	)
	astar = a_star(g, 1, 4)

	@show collect(astar)
	sethue("red")
	drawgraph(g,
	 	vertexshapes = :none,
		layout=stress,
		edgelines = collect(astar),
		edgestrokecolors=colorant"red",
		)
	# for i in 1:length(V)
	# 	setcolor(HSVA(rescale(i, 0, length(V), 0, 359), .7, .8, 0.8))
	# 	arrow(V[i], V[mod1(i + 1, end)], linewidth=10)
	# end
end 600 600
