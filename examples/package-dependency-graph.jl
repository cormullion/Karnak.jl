using Graphs
using MetaGraphs
using TOML
using Karnak
using Colors

# change this to your path to General registry repo

path_to_general = expanduser("~/.julia/registries/General")

registry_file = Pkg.TOML.parsefile(joinpath(path_to_general, "Registry.toml"))

packages_info = registry_file["packages"];

pkg_paths = map(values(packages_info)) do d
    (name = d["name"], path = d["path"])
end

first(pkg_paths)

"""
Find the packages directly depending on a source package.
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

find_direct_deps(path_to_general, pkg_paths, "Luxor")

## Time do build a directed tree

## WHo depends on Package,  then how dpends on those dependents, until we get a package that noone depends on

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

for idx in eachindex(spath_result.dists)
    if spath_result.dists[idx] == 5
        get_prop(g, idx, :name)
    end
end

## computing a full subgraph

all_packages = get_prop.(Ref(g), vertices(g), :name);

full_graph = MetaDiGraph(length(all_packages))

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

ranks = pagerank(full_graph)
sorted_indices = sort(eachindex(ranks), by=i->ranks[i], rev=true)
get_prop.(Ref(full_graph), sorted_indices, :name)

## Most dependencies, most depended on

in_sorted_indices = sort(vertices(full_graph), by=i->indegree(full_graph, i) , rev=true)
get_prop.(Ref(full_graph), in_sorted_indices, :name)

out_sorted_indices = sort(vertices(full_graph), by=i->outdegree(full_graph, i) , rev=true)
get_prop.(Ref(full_graph), out_sorted_indices, :name)

ranks_betweenness = betweenness_centrality(full_graph)
sorted_indices_betweenness = sort(vertices(full_graph), by=i->ranks_betweenness[i], rev=true)
get_prop.(Ref(full_graph), sorted_indices_betweenness, :name)

## Deoendencies are acyclic?

is_cyclic(full_graph)

for cycle in simplecycles(full_graph)
    names = get_prop.(Ref(full_graph), cycle, :name)
    @info names
end

@info "start drawing"

@pdf begin
    background("black")
    sethue("gold")
    setline(0.3)
        drawgraph(g,
         layout = stress,
         edgefunction = (k, s, d, f, t) -> begin
            @layer begin
#                randomhue()
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
end 2500 2500 "/tmp/graph-dependencies-colors.pdf"
