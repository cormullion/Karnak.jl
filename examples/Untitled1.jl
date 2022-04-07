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
