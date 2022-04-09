module Karnak

using Reexport
using Graphs
using Colors
using NetworkLayout
using Luxor

#@reexport using Luxor
@reexport using NetworkLayout

export drawgraph

function _normalize_layout_coordinates(rawcoordinates, boundingbox, margin)
    if length(rawcoordinates[1]) == 3
        @warn "3D coordinates returned by layout function"
    end
    bb = BoundingBox(map(p -> Point(p[1], p[2]), rawcoordinates))
    BB = boundingbox - margin
    offset = boxmiddlecenter(BB) - boxmiddlecenter(bb)
    ar = boxaspectratio(bb)
    AR = boxaspectratio(BB)
    if ar <= 1.0 && AR < 1.0
        sf = boxheight(BB) / boxheight(bb)
    elseif ar > 1 && AR <= 1.0
        sf = boxheight(BB) / boxheight(bb)
    elseif ar > 1 && AR > 1
        sf = boxwidth(BB) / boxwidth(bb)
    else
        ar <= 1.0 && AR > 1
        sf = boxwidth(BB) / boxwidth(bb)
    end
    return [-offset + sf * (Point(first(p), last(p))) for p in rawcoordinates]
end

function _drawedgelines(from, to;
        edgenumber=1,
        edgelines=nothing,
        edgestrokecolors=nothing,
        edgestrokeweights=nothing,
        edgedashpatterns=nothing,
        digraph=false,
        edgecurvature=0.0)

    # decide whether or not to draw this edge

    edgeline = nothing

    if edgelines isa Vector
        # only draw edges that are in the vector
        if edgenumber in edgelines
            edgeline = true
        end
    elseif edgelines isa AbstractRange
        if edgenumber in edgelines
            edgeline = true
        end
    elseif edgelines isa Int
        if edgenumber == edgelines
            edgeline = true
        end
    elseif edgelines == :none

    elseif edgelines isa Function
        # an edgeline function is f(from, to)
        edgeline = edgelines(from, to)
    else
        edgeline = true
    end

    strokecolor = Luxor.get_current_color()

    # set edge stroke color

    if isnothing(edgestrokecolors)
        # default - use current color
    elseif edgestrokecolors isa Array && !isempty(edgestrokecolors)
        if edgestrokecolors[mod1(edgenumber, end)] isa Colorant
            strokecolor = edgestrokecolors[mod1(edgenumber, end)]
        else
            if edgestrokecolors[mod1(edgenumber, end)] == :none
                strokecolor = :none
            end
        end
    elseif edgestrokecolors isa Colorant
        strokecolor = edgestrokecolors
    elseif edgestrokecolors isa Function
        # (from, to)
        strokecolor = edgestrokecolors(edgenumber, from, to)
    elseif edgestrokecolors == :none
        strokecolor = :none
    end

    # set the stroke weight
    # default to Luxor default
    linewidth = 2
    if isnothing(edgestrokeweights)
        # by default, do nothing
    elseif edgestrokeweights isa Array
        if !isempty(edgestrokeweights)
            if edgestrokeweights[mod1(edgenumber, end)] != :none
                linewidth = edgestrokeweights[mod1(edgenumber, end)]
            else
                linewidth = 0
            end
        end
    elseif edgestrokeweights isa AbstractRange
        linewidth = edgestrokeweights[mod1(edgenumber, end)]
    elseif edgestrokeweights isa Real
        linewidth = edgestrokeweights
    elseif edgestrokeweights == :none
        # do nothing
    end

    # set dash pattern
    dashpattern = Float64[]
    if isnothing(edgedashpatterns)
        # by default, do nothing
    elseif all(a -> a isa Vector, edgedashpatterns)
        # choose the appropriate dash pattern
        dashpattern = edgedashpatterns[mod1(edgenumber, end)]
    elseif edgedashpatterns isa Array
        dashpattern = edgedashpatterns
    elseif edgedashpatterns == :none
        # do nothing
    end

    # finally time to draw the edge
    # edgeline = nothing | true | function
    @layer begin
        setline(linewidth)
        if strokecolor isa Function
            strokecolor(edgenumber, from, to)
        else
            sethue(strokecolor)
        end
        if !isempty(dashpattern)
            setdash(dashpattern)
        end

        # use fontsize as a reasonable basis for the gap
        # between vertex center and arrow tip

        d = distance(from, to)
        f = get_fontsize()
        if edgeline isa Function
            edgeline(from, to)
        elseif edgeline == true
            if digraph == true && abs(edgecurvature) > 0.0
                # digraph and curvey lines
                if abs(edgecurvature) > 0.0
                    arrow(between(from, to, f/d), between(from, to, 1 - f/d), [edgecurvature, edgecurvature], linewidth=linewidth)
                else
                    arrow(between(from, to, f/d), between(from, to, 1 - f/d), [12, 12], linewidth=linewidth)
                end
            elseif digraph == false && abs(edgecurvature) > 0.0
                arrow(between(from, to, f/d), between(from, to, 1 - f/d), [edgecurvature, edgecurvature], linewidth=linewidth)
            elseif digraph == true && isapprox(edgecurvature, 0.0)
                midpt = midpoint(from, to)
                circle(midpt, 2linewidth, :fill)
                arrow(midpt, between(midpt, to, 1 - f/d), linewidth=linewidth)
                arrow(midpt, between(midpt, from, 1 - f/d), linewidth=linewidth)
            else
                # straight, no digraph
                line(from, to, :stroke)
            end
        else
        end
    end
end

function _drawedgelabels(from, to;
        edgenumber=1,
        edgesrc=1,
        edgedest=nothing,
        digraph=false,
        straight=true,
        edgelabels=nothing,
        edgelabelcolors=nothing,
        edgelabelrotations=nothing,
        edgelabelfontsizes=nothing,
        edgelabelfontfaces=nothing)

    # edge labels

    textcolor = Luxor.get_current_color()

    # set edge text color

    if isnothing(edgelabelcolors)
        # default - use current color
    elseif edgelabelcolors isa Array
        textcolor = edgelabelcolors[mod1(edgenumber, end)]
    elseif edgelabelcolors isa Colorant
        textcolor = edgelabelcolors
    elseif edgelabelcolors == :none
        textcolor = :none
    end

    # set text rotation

    textrotation = 0

    if isnothing(edgelabelrotations)
        # by default, do nothing
    elseif edgelabelrotations isa Array
        if !isempty(edgelabelrotations)
            if edgelabelrotations[mod1(edgenumber, end)] != :none
                textrotation = edgelabelrotations[mod1(edgenumber, end)]
            end
        end
    elseif edgelabelrotations isa AbstractRange
        textrotation = edgelabelrotations[mod1(edgenumber, end)]
    elseif edgelabelrotations isa Real
        textrotation = edgelabelrotations
    elseif edgelabelrotations == :none
        # do nothing
    end

    # TODO refactor
    # finally draw label text with textcolor and rotations
    if (edgelabels isa Vector && !isempty(edgelabels)) || edgelabels isa AbstractRange
        @layer begin
            if edgelabels[mod1(edgenumber, end)] == :none
            else
                str = string(collect(edgelabels)[mod1(edgenumber, end)])
                if textcolor != :none
                    sethue(textcolor)
                    text(str, midpoint(from, to), angle = textrotation)
                end
            end
        end
    elseif edgelabels isa Function
        edgelabels(edgenumber, edgesrc, edgedest, from, to)
    elseif edgelabels isa Dict
        # edgelabels can be dict with (src, dst) => "labeltext"
        if haskey(edgelabels, (edgesrc, edgedest))
            edgelabel = string(edgelabels[(edgesrc, edgedest)])
            # TODO don't repeat this code!!!
            @layer begin
            if textcolor != :none
                sethue(textcolor)
                text(edgelabel, midpoint(from, to), angle = textrotation)
            end
            end
        end
    elseif edgelabels == :none
        # edgelabels
    elseif isnothing(edgelabels)
        # default is do nothing
    end
end

function _drawvertexshapes(vertex, coordinates::Array{Point,1};
        vertexshapes=nothing,
        vertexshapesizes=nothing,
        vertexfillcolors=nothing,
        vertexstrokecolors=nothing,
        vertexstrokeweights=nothing,
        vertexshaperotations=nothing
        )

    # decide whether or not to draw a shape at this vertex

    # set rotation angle
    vertexshaperotation = 0
    if isnothing(vertexshaperotations)
        # by default, do nothing
    elseif vertexshaperotations isa Array
        if !isempty(vertexshaperotations)
            if vertexshaperotations[mod1(vertex, end)] != :none
                vertexshaperotation = vertexshaperotations[mod1(vertex, end)]
            end
        end
    elseif vertexshaperotations isa AbstractRange
        vertexshaperotation = vertexshaperotations[mod1(vertex, end)]
    elseif vertexshaperotations isa Real
        vertexshaperotation = vertexshaperotations
    elseif vertexshaperotations == :none
        # do nothing
    end

    vertexshape = nothing
    if vertexshapes isa Array
        if vertexshapes[mod1(vertex, end)] == :square
            vertexshape = :square
        elseif vertexshapes[mod1(vertex, end)] == :circle
            vertexshape = :circle
        elseif vertex in vertexshapes
            vertexshape = true
        end
    elseif vertexshapes isa Function
        # a vertexshapes function is vertexshape(vertex) ->
        vertexshape = vertexshapes
    elseif vertexshapes isa AbstractRange
        if vertex in vertexshapes
            vertexshape = true
        end
    elseif vertexshapes == :circle
        vertexshape = :circle
    elseif vertexshapes == :square
        vertexshape = :square
    elseif vertexshapes == :none
        vertexshape = :square
    elseif vertexshapes isa Int64
        if vertexshapes == vertex
            vertexshape = true
        end
    end

    if vertexshape == :none
        return
    end

    # so now we can draw this vertex

    # vertexshape is hopefully one of true, square, circle, or can be a function

    # work out fill and stroke colors

    previouscolor = Luxor.get_current_color()
    fillcolorfunction = nothing
    strokecolorfunction = nothing

    # set the fill color
    # if :none, don't draw it (will override other specs)

    fillcolor = :none

    if vertexfillcolors isa Array && !isempty(vertexfillcolors)
        if vertexfillcolors[mod1(vertex, end)] isa Colorant
            fillcolor = vertexfillcolors[mod1(vertex, end)]
        else
            fillcolor = :none
        end
    elseif vertexfillcolors isa Colorant
        fillcolor = vertexfillcolors
    elseif vertexfillcolors == :none
        fillcolor = :none
    elseif vertexfillcolors isa Function
        # a vertexfillcolors function is vertexfillcolors(vertex) ->
        fillcolorfunction = vertexfillcolors(vertex)
    else
        # default - use current color
        fillcolor = Luxor.get_current_color()
    end

    # set the stroke color
    strokecolor = :none

    if isnothing(vertexstrokecolors)
        # default - get current color
        strokecolor = Luxor.get_current_color()
    elseif vertexstrokecolors isa Array && !isempty(vertexstrokecolors)
        if vertexstrokecolors[mod1(vertex, end)] isa Colorant
            strokecolor = vertexstrokecolors[mod1(vertex, end)]
        end
    elseif vertexstrokecolors isa Colorant
        strokecolor = vertexstrokecolors
    elseif vertexstrokecolors isa Function
        # a vertexstrokecolors function is vertexstrokecolors(vertex) ->
        strokecolorfunction = vertexstrokecolors(vertex)
    elseif vertexstrokecolors == :none
        strokecolor = :none
    else
        strokecolor = Luxor.get_current_color()
    end

    # set the stroke weight
    # default to Luxor default
    linewidth = 2

    if isnothing(vertexstrokeweights)
        # by default, do nothing
    elseif vertexstrokeweights isa Array
        if !isempty(vertexstrokeweights)
            if vertexstrokeweights[mod1(vertex, end)] != :none
                linewidth = vertexstrokeweights[mod1(vertex, end)]
            end
        end
    elseif vertexstrokeweights isa AbstractRange
        linewidth = vertexstrokeweights[mod1(vertex, end)]
    elseif vertexstrokeweights == :none
        # do nothing
    end

    # set shape sizes
    # vertexshape size is going to be a radius rather than a diameter

    if isnothing(vertexshapesizes)
        vertexshapesize = 6
    elseif vertexshapesizes isa Array
        if !isempty(vertexshapesizes)
            if vertexshapesizes[mod1(vertex, end)] != :none
                vertexshapesize = vertexshapesizes[mod1(vertex, end)]
            end
        end
    elseif vertexshapesizes isa AbstractRange
        vertexshapesize = vertexshapesizes[mod1(vertex, end)]
    elseif vertexshapesizes isa Real
        vertexshapesize = vertexshapesizes
    elseif vertexshapesizes == :none
        # don't draw it
    end

    # finally do some drawing
    # vertexshape is one of true, square, circle, function

   @layer begin
        if fillcolorfunction isa Function
            # a vertexfillcolors function is f(vertex) ->
            fillcolorfunction(vertex)
            fillcolor = Luxor.get_current_color()
        end
        if strokecolor isa Function
            # a vertexstrokecolors function is f(vertex) ->
            strokecolorfunction(vertex)
            strokecolor = Luxor.get_current_color()
        end
        translate(coordinates[vertex])
        rotate(vertexshaperotation)
        setline(linewidth)
        if vertexshape isa Function
            # we just doing fill color or stroke color priority?
            strokecolor != :none && sethue(strokecolor)
            fillcolor != :none && sethue(fillcolor)
            vertexshape(vertex)
        elseif vertexshape == :circle
            fillcolor != :none && sethue(fillcolor)
            circle(O, vertexshapesize, :fill)
            strokecolor != :none && sethue(strokecolor)
            circle(O, vertexshapesize, :stroke)
        elseif vertexshape == :square
            fillcolor != :none && sethue(fillcolor)
            box(O, vertexshapesize, vertexshapesize, :fill)
            strokecolor != :none && sethue(strokecolor)
            box(O, vertexshapesize, vertexshapesize, :stroke)
        else # default is a circle
            fillcolor != :none && sethue(fillcolor)
            circle(O, vertexshapesize, :fill)
            strokecolor != :none && sethue(strokecolor)
            circle(O, vertexshapesize, :stroke)
        end
    end
    # restore previous color - I don't know why this is needed
    sethue(previouscolor)
end

function _drawvertexlabels(vertex, coordinates::Array{Point,1};
        vertexlabels=nothing,
        vertexlabeltextcolors=nothing,
        vertexlabelfontsizes=nothing,
        vertexlabelfontfaces=nothing,
        vertexlabelrotations=nothing,
        vertexlabeloffsetangles=nothing,
        vertexlabeloffsetdistances=nothing,
        )

    # decide whether to draw this vertex

    vertexlabel = nothing
    if isnothing(vertexlabels)
        # by default, no labels
    elseif vertexlabels isa Array
        if vertexlabels[mod1(vertex, end)] != :none
            vertexlabel = string(vertexlabels[mod1(vertex, end)])
        end
    elseif vertexlabels isa AbstractRange
        vertexlabel = string(vertexlabels[mod1(vertex, end)])
    elseif vertexlabels isa AbstractString
            vertexlabel = vertexlabels
    elseif vertexlabels == :none
        # er
    end

    # set font size
    font_size = 0
    if isnothing(vertexlabelfontsizes)
        # use default fontsize
        font_size = get_fontsize()
    elseif vertexlabelfontsizes isa Array
        if !isempty(vertexlabelfontsizes)
            if vertexlabelfontsizes[mod1(vertex, end)] != :none
                font_size = vertexlabelfontsizes[mod1(vertex, end)]
            end
        end
    elseif vertexlabelfontsizes isa AbstractRange
        font_size = vertexlabelfontsizes[mod1(vertex, end)]
    elseif vertexlabelfontsizes isa Real
        font_size = vertexlabelfontsizes[mod1(vertex, end)]
    elseif vertexlabelfontsizes == :none
    end

    # set font face
    font_face = ""
    if isnothing(vertexlabelfontfaces)
        # use default fontsize
    elseif vertexlabelfontfaces isa Array
        if !isempty(vertexlabelfontfaces)
            if vertexlabelfontfaces[mod1(vertex, end)] != :none
                font_face = vertexlabelfontfaces[mod1(vertex, end)]
            end
        end
    elseif vertexlabelfontfaces isa AbstractRange
        font_face = vertexlabelfontfaces[mod1(vertex, end)]
    elseif vertexlabelfontfaces isa String
        font_face = vertexlabelfontfaces
    elseif vertexlabelfontfaces == :none
    end

    # set the colors for all labels
    textcolor = Luxor.get_current_color()
    if isnothing(vertexlabeltextcolors)
        # default - use current color
    elseif vertexlabeltextcolors isa Array
        textcolor = vertexlabeltextcolors[mod1(vertex, end)]
    elseif vertexlabeltextcolors isa Colorant
        textcolor = vertexlabeltextcolors
    elseif vertexlabeltextcolors == :none
        textcolor = :none
    end

    # set rotation angle

    textrotation = 0
    if isnothing(vertexlabelrotations)
        # by default, do nothing
    elseif vertexlabelrotations isa Array
        if !isempty(vertexlabelrotations)
            if vertexlabelrotations[mod1(vertex, end)] != :none
                textrotation = vertexlabelrotations[mod1(vertex, end)]
            end
        end
    elseif vertexlabelrotations isa AbstractRange
        textrotation = vertexlabelrotations[mod1(vertex, end)]
    elseif vertexlabelrotations isa Real
        textrotation = vertexlabelrotations
    elseif vertexlabelrotations == :none
        # do nothing
    end

    # set label offsets
    # set label offset angles

    textoffsetangle = 0
    if isnothing(vertexlabeloffsetangles)
        # by default, 0 is ok
    elseif vertexlabeloffsetangles isa Array
        if !isempty(vertexlabeloffsetangles)
            if vertexlabeloffsetangles[mod1(vertex, end)] != :none
                textoffsetangle = vertexlabeloffsetangles[mod1(vertex, end)]
            end
        end
    elseif vertexlabeloffsetangles isa AbstractRange
        textoffsetangle = vertexlabeloffsetangles[mod1(vertex, end)]
    elseif vertexlabeloffsetangles isa Real
        textoffsetangle = vertexlabeloffsetangles
    end

    # set label offset distances

    textoffsetdistance = 0
    if isnothing(vertexlabeloffsetdistances)
        # by default, 0 is ok
    elseif vertexlabeloffsetdistances isa Array
        if !isempty(vertexlabeloffsetdistances)
            if vertexlabeloffsetdistances[mod1(vertex, end)] != :none
                textoffsetdistance = vertexlabeloffsetdistances[mod1(vertex, end)]
            end
        end
    elseif vertexlabeloffsetdistances isa AbstractRange
        textoffsetdistance = vertexlabeloffsetdistances[mod1(vertex, end)]
    elseif vertexlabeloffsetdistances isa Real
        textoffsetdistance = vertexlabeloffsetdistances
    end

    # draw the label
    if !isnothing(vertexlabel)
        @layer begin
            pt = coordinates[vertex]
            translate(pt)
            rotate(textrotation)
            sethue(textcolor)
            fontsize(font_size)
            fontface(font_face)
            text(vertexlabel, halign=:center, valign=:middle, O + polar(textoffsetdistance, textoffsetangle))
        end
    end
end

function drawedge(from::Point, to::Point;
        graph::AbstractGraph,
        edgenumber::Int64,
        edgesrc::Int64,
        edgedest::Int64,
        edgefunction=nothing,
        edgelabels=nothing,
        edgelines=nothing,
        edgedashpatterns=nothing,
        edgecurvature=nothing,
        edgestrokecolors=nothing,
        edgelabelcolors=nothing,
        edgelabelfontsizes=nothing,
        edgelabelfontfaces=nothing,
        edgestrokeweights=nothing,
        edgelabelrotations=nothing
        )

    # is completely specified by function?
    if edgefunction isa Function
        edgefunction(from, to)
    else
        _drawedgelines(from, to;
            edgenumber,
            edgelines,
            edgestrokecolors,
            edgestrokeweights,
            edgedashpatterns,
            digraph=graph isa DiGraph,
            edgecurvature=edgecurvature)
        _drawedgelabels(from, to;
            edgenumber,
            edgesrc,
            edgedest,
            edgelabels,
            edgelabelcolors,
            edgelabelfontsizes,
            edgelabelfontfaces,
            edgelabelrotations)
    end
end

function drawvertex(vertex, coordinates::Array{Point,1};
        vertexfunction=nothing,
        vertexlabels=nothing,
        vertexshapes=nothing,
        vertexshapesizes=nothing,
        vertexshaperotations=nothing,
        vertexstrokecolors=nothing,
        vertexstrokeweights=nothing,
        vertexfillcolors=nothing,
        vertexlabeltextcolors=nothing,
        vertexlabelfontsizes=nothing,
        vertexlabelfontfaces=nothing,
        vertexlabelrotations=nothing,
        vertexlabeloffsetangles=nothing,
        vertexlabeloffsetdistances=nothing,
        )

    # is completely specified by function?
    if vertexfunction isa Function
        vertexfunction(vertex, coordinates)
    else
        _drawvertexshapes(vertex, coordinates::Array{Point,1};
            vertexshapes,
            vertexshapesizes,
            vertexshaperotations,
            vertexstrokecolors,
            vertexstrokeweights,
            vertexfillcolors)
        _drawvertexlabels(vertex, coordinates::Array{Point,1};
            vertexlabels,
            vertexlabeltextcolors,
            vertexlabelfontsizes,
            vertexlabelfontfaces,
            vertexlabelrotations,
            vertexlabeloffsetangles,
            vertexlabeloffsetdistances,
            )
    end
end

"""
Draw a graph `g` using coordinates in `layout` to fit in a
Luxor `boundingbox`.

## Keyword arguments

`g`
- the graph to be drawn

`boundingbox`
- the drawing fits in this BoundingBox

`layout`
- the layout method or coordinates to be used. Examples:
    layout = squaregrid

    layout = shell

    layout = vcat(
        between.(O + (-W/2, H), O + (W/2, H), range(0, 1, length=N)),
        between.(O + (-W/2, -H), O + (W/2, -H), range(0, 1, length=N)))

    layout = stress

    layout = (g) -> spectral(adjacency_matrix(g), dim=2)

    layout = shell ∘ adjacency_matrix

    layout = (g) -> sfdp(g, Ptype=Float64, dim=2, tol=0.05, C=0.4, K=2)

    layout = Shell(nlist=[6:10,])

    Refer to the NetworkLayout.jl documentation for more.

`margin = 20`
- a margin added to the graph diagram before fitting to boundingbox

`vertexfunction`
- a function `vertexfunction(vertex, coordinates)` that
  completely specifies the appearance of every vertex. None
  of the other vertex- keyword arguments will be used. Example:

    vertexfunction = (v, c) -> ngon(c[v], 30, 6, 0, :fill)

`edgefunction`
- a function `edgefunction(from, to)` that
  completely specifies the appearance of every vertex. None
  of the other edge- keyword arguments are used.

`vertexlabels`
- the text labels for each vertex. Vertex labels are not drawn by default.

`vertexshapes`
- the shape of each vertex; can be :circle :square, or a function
   function vertexshape(vertex) -> Vertex center is at 0/0,
   `vertex` is vertex number, using current vertex rotation
   (`vertextshaperotations`) The function can override
   rotations and colors.
   default is ?

`vertexshapesizes`
- the size of each vertex shape for :circle :square...

`vertexshaperotations`
- relative to vertex locations

`vertexstrokecolors`
- can be function: f(vertex) -> sethue("blue").

`vertexstrokeweights`
-

`vertexfillcolors`
- can be function: f(vertex) -> sethue("blue")
  if both vertexfillcolors and vertexstrokecolors are
  functions that change Luxor's current color, fill takes
  priority

`vertexlabeltextcolors`
-

`vertexlabelfontsizes`
-

`vertexlabelfontfaces`
-

`vertexlabelrotations`
-

- `vertexlabeloffsetangles`

- `vertexlabeldistances`

`edgelabels`
- can be function: `edgelabels(edgenumber, edgesrc, edgedest, from::Point, to::Point)`
   can be Dict
   can be array of strings
   can be a range
   not drawn by default, nust be specified

`edgelines`
-  can be function

`edgecurvature=0.0`

`edgestrokecolors`
- can be array, colorant, function: `edgestrokecolors(edgenumber, from, to)`
  `edgestrokecolors = (n, from, to) -> sethue(HSB(rescale(n, 1, ne(g), 0, 360), 0.9, 0.8))`

`edgestrokeweights`

`edgedashpatterns`
- a dash pattern or an array of dash patterns for the edge lines:
    edgedashpatterns = [[10, 30], [1]]) # lines alternate between dots and lines

`edgelabelcolors`
- the colors of the label text

`edgelabelrotations`
- the rotation of the label text

"""
function drawgraph(g::AbstractGraph;
        boundingbox::BoundingBox=BoundingBox(),
        layout=nothing,
        margin::Real=30,
        vertexfunction=nothing,
        vertexlabels=nothing,
        vertexshapes=nothing,
        vertexshapesizes=nothing,
        vertexshaperotations=nothing,
        vertexstrokecolors=nothing,
        vertexstrokeweights=nothing,
        vertexfillcolors=nothing,
        vertexlabeltextcolors=nothing,
        vertexlabelfontsizes=nothing,
        vertexlabelfontfaces=nothing,
        vertexlabelrotations=nothing,
        vertexlabeloffsetangles=nothing,
        vertexlabeloffsetdistances=nothing,
        edgefunction=nothing,
        edgelabels=nothing,
        edgelines=nothing,
        edgecurvature=0.0,
        edgestrokecolors=nothing,
        edgestrokeweights=nothing,
        edgedashpatterns=nothing,
        edgelabelcolors=nothing,
        edgelabelrotations=nothing)

    # so, do we need some coordinates for the vertices?
    # do we have a layout function to call?
    if isnothing(layout)
        # no, make some random points up, a circle should do
        coordinates = [polar(min(boxwidth(boundingbox - margin), boxheight(boundingbox - margin)) / 2, θ) for θ in range(0, step=2π / nv(g), length=nv(g))]
    elseif layout isa Array{Point,1}
        coordinates = layout
    else
        # great, let's run layout function
        rawpts = layout(g)
        # convert to Luxor Points and resize to fit boundingbox
        coordinates = _normalize_layout_coordinates(rawpts, boundingbox, margin)
    end
    for (n, edge) in enumerate(edges(g))
        s, d = src(edge), dst(edge)
        drawedge(
            coordinates[s],
            coordinates[d],
            graph=g,
            edgefunction=edgefunction,
            edgelabels=edgelabels,
            edgenumber=n,
            edgesrc=s,
            edgedest=d,
            edgelines=edgelines,
            edgecurvature=edgecurvature,
            edgestrokecolors=edgestrokecolors,
            edgestrokeweights=edgestrokeweights,
            edgedashpatterns= edgedashpatterns,
            edgelabelcolors=edgelabelcolors,
            edgelabelrotations=edgelabelrotations
        )
    end
    for vertex in vertices(g)
        drawvertex(vertex, coordinates,
            vertexfunction=vertexfunction,
            vertexlabels=vertexlabels,
            vertexshapes=vertexshapes,
            vertexshapesizes=vertexshapesizes,
            vertexshaperotations=vertexshaperotations,
            vertexstrokecolors=vertexstrokecolors,
            vertexstrokeweights=vertexstrokeweights,
            vertexfillcolors=vertexfillcolors,
            vertexlabeltextcolors=vertexlabeltextcolors,
            vertexlabelfontsizes=vertexlabelfontsizes,
            vertexlabelfontfaces=vertexlabelfontfaces,
            vertexlabelrotations=vertexlabelrotations,
            vertexlabeloffsetangles=vertexlabeloffsetangles,
            vertexlabeloffsetdistances=vertexlabeloffsetdistances,
        )
    end
end

end
