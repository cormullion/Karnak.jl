using Karnak
using Luxor
using Colors
using Graphs
using NetworkLayout
println("finished compiling")

@drawsvg begin
#	setopacity(0.6)
	setline(10)
	sethue("orange")
	fontsize(15)
	g = complete_digraph(6)
	drawgraph(g,
		margin=100,
		# vertexshapes= (v) -> begin
		# 	randomhue()
		# 	ngon(O, 25, 5, 0, :fill)
		# 	end,
		vertexshapes = :circle,
		#vertexshapes = :square,
		vertexlabelfontfaces = "Bodoni-Poster",
		vertexlabelfontsizes = 50,
		#vertexlabeltextcolors = colorant"white",
		vertexlabels = 1:20,
		vertexfillcolors = (v) -> begin
				setopacity(0.5)
				sethue(HSB(rescale(v, 1, nv(g), 0, 360), 0.9, 0.8))
			end,
		vertexstrokecolors = colorant"purple",
		vertexshapesizes=25:20:120,
		#vertexshaperotations=0:π/12:2π,
		)
end
