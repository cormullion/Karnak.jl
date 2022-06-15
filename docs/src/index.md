# Introduction to Karnak

![karnak splash image](assets/figures/karnak-social-media-preview.png)

Karnak.jl is a small extension for the Luxor.jl package to
help with visualizing graphs and networks.

Karnak also relies on
[Graphs.jl](https://github.com/JuliaGraphs/Graphs.jl) for
graph construction, and on
[NetworkLayout.jl](https://juliagraphs.org/NetworkLayout.jl/)
for graph layout.

!!! note

    There's a good selection of Julia packages for visualizing graphs:

    - [TikzGraphs.jl](https://github.com/sisl/TikzGraphs.jl): backend: Tikz/LaTeX

    - [GraphPlot.jl](https://github.com/afternone/GraphPlot.jl): backend: Compose.jl

    - [SGtSNEpi.jl](https://github.com/fcdimitr/SGtSNEpi.jl): backend: Makie.jl

    - [GraphRecipes.jl](https://github.com/JuliaPlots/GraphRecipes.jl): backend: Plots.jl

    - [GraphMakie.jl](https://github.com/JuliaPlots/GraphMakie.jl): backend: Makie.jl

## Quick start

```@example
using Karnak
using Graphs
using NetworkLayout
g = barabasi_albert(100, 1)
@drawsvg begin
    background("black")
    sethue("white")
    drawgraph(g, layout=stress, vertexlabels = 1:nv(g))
end
```

!!! note

    Karnak.jl contains just one function: `drawgraph()`, and
    re-exports Luxor.jl. So all graphics and drawing
    functions are from Luxor. See the [documentation of
    Luxor.jl](http://juliagraphics.github.io/Luxor.jl/stable/)
    for details.
