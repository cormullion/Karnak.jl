using Karnak
using Luxor
using Colors
using Graphs
using NetworkLayout

@drawsvg begin
	background("black")
	sethue("gold")
	g = complete_digraph(16)

	setline(0.3)
	drawgraph(g, margin=70,
		edgestrokecolors = (n, from, to, s, d) -> HSB(rescale(n, 1, ne(g), 0, 360), 0.6, 0.7),
		edgecurvature = 23)
end
