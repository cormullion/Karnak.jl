using Graphs
using MetaGraphs
using TOML
using Karnak
using Colors

# change this to your path to General registry repo

path_to_general = expanduser("~/.julia/registries/General")

registry_file = Pkg.TOML.parsefile(joinpath(path_to_general, "Registry.toml"))

packages_info = registry_file["packages"];

# Julia v1.6 ?
pkg_paths = map(values(packages_info)) do d
    (name = d["name"], path = d["path"])
end

# Julia v1.7

pkg_paths = map(values(Pkg.Registry.reachable_registries()[1].pkgs)) do d
    (name = d.name, path = d.path)
end

"""
Find the packages directly depending on a source package.
Julia v1.6
"""
function find_direct_deps(registry_path, pkg_paths, source)
    filter(pkg_paths) do pkg_path
        deps_file = joinpath(registry_path, pkg_path.path, "Deps.toml")
        isfile(deps_file) && begin
            deps_struct = Pkg.TOML.parsefile(deps_file)
            any(values(deps_struct)) do d
                source in keys(d)
            end
        end
    end
end

find_direct_deps(path_to_general, pkg_paths, "Colors")

## Time do build a directed tree

function build_tree(registry_path, pkg_paths, root)
    g = MetaDiGraph()
    add_vertex!(g)
    set_prop!(g, 1, :name, root)
    i = 1
    explored_nodes = String[]
    push!(explored_nodes, root)
    @info length(pkg_paths)
    while true
        i % 50 == 0 && print(i, " ")
        current_node = get_prop(g, i, :name)
        direct_deps = find_direct_deps(registry_path, pkg_paths, current_node)
        filter!(d -> d.name ∉ explored_nodes, direct_deps)
        if isempty(direct_deps) && i >= nv(g)
           break
        end
        for ddep in direct_deps
           push!(explored_nodes, ddep.name)
           add_vertex!(g)
           set_prop!(g, nv(g), :name, ddep.name)
           add_edge!(g, i, nv(g))
        end
        i += 1
    end
    return g
end

### this takes some time

@info "start building the tree"

g = build_tree(path_to_general, pkg_paths, "Colors")

@info " built the tree"

get_prop.(Ref(g), outneighbors(g, 1), :name)

spath_result = dijkstra_shortest_paths(g, 1)

spath_result.dists

get_prop(g, nv(g), :name)

# "QuantumESPRESSOExpress"

for idx in eachindex(spath_result.dists)
    if spath_result.dists[idx] == 7
        @show get_prop(g, idx, :name)
    end
end

#get_prop(g, idx, :name) = "Recommenders"
#get_prop(g, idx, :name) = "QuantumESPRESSOExpress"

## computing a full subgraph

all_packages = get_prop.(Ref(g), vertices(g), :name)

#=
Vector{String}:
 "Colors"
 "TopologyPreprocessing"
 "DynamicGrids"
 "SimpleSDMLayers"
 "UnderwaterAcoustics"
 "ColorSchemeTools"
 ⋮
 "ReservoirComputing"
 "TreeParzen"
 "GeoStatsImages"
 "StoppingInterface"
 "QuantumESPRESSO"
 "Recommenders"
 "QuantumESPRESSOExpress"
 =#

full_graph = MetaDiGraph(length(all_packages))
# {1375, 0} directed Int64 metagraph with Float64 weights defined by :weight (default weight 1.0)

@info "set properties"
for v in vertices(full_graph)
    set_prop!(full_graph, v, :name, all_packages[v])
end

@info "compute full graph"
for v in vertices(full_graph)
    pkg_name = get_prop(full_graph, v, :name)
    dependent_packages = find_direct_deps(path_to_general, pkg_paths, pkg_name)
    for dep_pkg in dependent_packages
        pkg_idx = findfirst(==(dep_pkg.name), all_packages)
        # only packages in graph
        if pkg_idx !== nothing
            add_edge!(full_graph, pkg_idx, v)
        end
    end
end

savegraph("full_graph.lg", full_graph)

savegraph("g.lg", g)

## Page Rank

ranks = pagerank(full_graph)
#=
1375-element Vector{Float64}:
 0.15339826572024867
 0.00020384989099126913
 0.00043081071431843264
 0.0002471787754446367
 0.0005504809666182096
 0.00020384989099126913
 0.00020384989099126913
 0.00034105802509359976
 0.0012284800170342895
 ⋮
 0.00020384989099126913
 0.00020384989099126913
 0.00042629607921470863
 0.00020384989099126913
 0.0002616217369290926
 =#

sorted_indices = sort(eachindex(ranks), by=i->ranks[i], rev=true)
#=
1375-element Vector{Int64}:
   1
 543
 137
 112
 144
 164
   ⋮
 259
 258
 729
 730
 688
 =#

get_prop.(Ref(full_graph), sorted_indices, :name)

#=
1375-element Vector{String}:
 "Colors"
 "Plots"
 "ImageCore"
 "PlotUtils"
 "ColorSchemes"
 "ColorVectorSpace"
 ⋮
 "TopOptMakie"
 "VTKDataIO"
 "EFTfitter"
 "SpmGrids"
 "ElectronTests"
=#


## Most dependencies, most depended on

in_sorted_indices = sort(vertices(full_graph), by=i->indegree(full_graph, i) , rev=true)
#=
1375-element Vector{Int64}:
 543
   1
  65
  98
 133
 137
   ⋮
 287
 743
 744
 285
 688
 =#

get_prop.(Ref(full_graph), in_sorted_indices, :name)
#=
1375-element Vector{String}:
 "Plots"
 "Colors"
 "Flux"
 "Images"
 "PyPlot"
 "ImageCore"
 ⋮
 "PolaronMobility"
 "CineFiles"
 "MadNLPGraph"
 "MicroscopyLabels"
 "ElectronTests"
=#

out_sorted_indices = sort(vertices(full_graph), by=i->outdegree(full_graph, i) , rev=true)

#=
1375-element Vector{Int64}:
 372
  98
  35
  24
 300
 153
   ⋮
 776
 777
 778
 779
   1
 =#

get_prop.(Ref(full_graph), out_sorted_indices, :name)

#=
1375-element Vector{String}:
 "StatisticalRethinking"
 "Images"
 "Makie"
 "MakieGallery"
 "PredictMDExtra"
 "GLMakie"
 ⋮
 "MimiPAGE2020"
 "MimiSNEASY"
 "OptiMimi"
 "SyntheticNetworks"
 "Colors"
=#


ranks_betweenness = betweenness_centrality(full_graph)

#=
1375-element Vector{Float64}:
 0.0
 0.0
 3.1186467511475384e-5
 5.300816007616213e-7
 5.830897608377834e-5
 0.0
 ⋮
 0.0
 0.0
 4.24065280609297e-6
 0.0
 1.0601632015232426e-6
=#

sorted_indices_betweenness = sort(vertices(full_graph), by=i->ranks_betweenness[i], rev=true)

#=
1375-element Vector{Int64}:
 144
  98
 112
 543
 461
  35
   ⋮
 562
 563
 564
 565
   1
=#

get_prop.(Ref(full_graph), sorted_indices_betweenness, :name)

#=
1375-element Vector{String}:
 "ColorSchemes"
 "Images"
 "PlotUtils"
 "Plots"
 "ImageIO"
 "Makie"
 ⋮
 "BridgeDiffEq"
 "BridgeLandmarks"
 "FCA"
 "BEASTDataPrep"
 "Colors"

=#

## Deoendencies are acyclic?

is_cyclic(full_graph)

#=
true
=#

for cycle in simplecycles(full_graph)
    names = get_prop.(Ref(full_graph), cycle, :name)
    @info names
end

#=
[ Info: ["ImageCore", "MosaicViews"]
[ Info: ["Images", "ImageSegmentation"]
[ Info: ["Makie", "GLMakie"]
[ Info: ["POMDPPolicies", "BeliefUpdaters", "POMDPModels", "POMDPSimulators"]
[ Info: ["BeliefUpdaters", "POMDPModels"]
[ Info: ["BeliefUpdaters", "POMDPModels", "POMDPSimulators"]
[ Info: ["ReinforcementLearning", "ReinforcementLearningEnvironmentDiscrete"]
[ Info: ["Modia3D", "Modia"]
[ Info: ["RasterDataSources", "GeoData"]
[ Info: ["DSGE", "StateSpaceRoutines"]
=#

## drawing

@info "start drawing"

@pdf begin
    background("black")
    sethue("gold")
    setline(0.3)
    drawgraph(g,
        layout = stress,
        edgefunction = (k, s, d, f, t) -> begin
            @layer begin
                sl = slope(O, t)
                sethue(HSVA(rescale(sl, 0, 2π, 0, 360), 0.7, 0.7, .9))
                line(f, t, :stroke)
            end
        end,
        vertexfunction = (v, c) -> begin
            @layer begin
                t = get_prop(g, v, :name)
                te = textextents(t)
                setopacity(0.7)
                sethue("grey10")
                fontsize(3)
                box(c[v], te[3]/2, te[4]/2, :fill)
                setopacity(1)
                sethue("white")
                text(t, c[v], halign=:center, valign=:middle)
            end
        end
    )
    @info " finish drawing"
end 2500 2500 "/tmp/graph-dependencies-colors-1.pdf"

@pdf begin
    background("black")
    sethue("gold")
    setline(0.3)
    drawgraph(full_graph,
        layout = stress,
        edgefunction = (k, s, d, f, t) -> begin
            @layer begin
                #   randomhue()
                sl = slope(O, t)
                sethue(HSVA(rescale(sl, 0, 2π, 0, 360), 0.7, 0.7, .9))
                line(f, t, :stroke)
            end
        end ,
        vertexfunction = (v, c) -> begin
            @layer begin
                t = get_prop(g, v, :name)
                te = textextents(t)
                setopacity(0.7)
                sethue("grey10")
                fontsize(3)
                box(c[v], te[3]/2, te[4]/2, :fill)
                setopacity(1)
                sethue("white")
                text(t, c[v], halign=:center, valign=:middle)
            end
        end
    )
    @info " finish drawing"
end 2500 2500 "/tmp/graph-dependencies-colors-full_graph-stress.pdf"

@pdf begin
    background("black")
    sethue("gold")
    setline(0.3)
    drawgraph(full_graph,
        layout = spring,
        edgefunction = (k, s, d, f, t) -> begin
            @layer begin
                #   randomhue()
                sl = slope(O, t)
                sethue(HSVA(rescale(sl, 0, 2π, 0, 360), 0.7, 0.7, .9))
                line(f, t, :stroke)
            end
        end ,
        vertexfunction = (v, c) -> begin
            @layer begin
                t = get_prop(g, v, :name)
                te = textextents(t)
                setopacity(0.7)
                sethue("grey10")
                fontsize(3)
                box(c[v], te[3]/2, te[4]/2, :fill)
                setopacity(1)
                sethue("white")
                text(t, c[v], halign=:center, valign=:middle)
            end
        end
    )
    @info " finish drawing"
end 2500 2500 "/tmp/graph-dependencies-colors-full_graph-spring.pdf"
