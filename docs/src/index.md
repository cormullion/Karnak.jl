# Introduction to Karnak

Karnak.jl is a small extension for the Luxor.jl package to
help with drawing some graph-style diagrams.

Karnak relies Graphs.jl for graph construction, and
NetworkLayout.jl for graph layout.

The focus here, unlike other graph visualization packaegs,
is more on decorative and aesthetic uses.

!!! warning

	For mathematical and scientific visualizations, use one of
	the following Julia packages, rather than this one.

	- [TikzGraphs.jl](https://github.com/sisl/TikzGraphs.jl): backend: Tikz/LaTeX

	- [GraphPlot.jl](https://github.com/afternone/GraphPlot.jl): backend: Compose.jl

	- [SGtSNEpi.jl](https://github.com/fcdimitr/SGtSNEpi.jl): backend: Makie.jl

	- [GraphRecipes.jl](https://github.com/JuliaPlots/GraphRecipes.jl): backend: Plots.jl

	- [GraphMakie.jl](https://github.com/JuliaPlots/GraphMakie.jl): backend: Makie.jl

## TODO

- dash patterns
- fontface options
- add colorscheme or normalized option?
- flipycoordinate option?
- binary_tree + buchheim layout?
- remove function options from  vertex kwargs
- squaregrid isn't aligned properly:
		using  Graphs, Karnak, NetworkLayout
		m = [0 1 1 0 0;
		     1 0 0 1 0;
		     1 0 0 1 1;
		     0 1 1 0 1;
		     0 0 1 1 0]

		@drawsvg begin
		hg = Graph(m)
		#translate(boxbottomleft())
		sethue("fuchsia")
		drawgraph(hg, margin=20, layout=squaregrid, vertexlabels = 1:nv(hg))
		end 900 500
