using Documenter, Karkak

makedocs(
    modules = [Karkak],
    sitename = "Karkak",
    format = Documenter.HTML(
        prettyurls = get(ENV, "CI", nothing) == "true",
        assets = ["assets/karnak-docs.css"],
        warn_outdated = true,
        collapselevel=1,
        ),
    pages    = [
        "Introduction to Karkak"            =>  "index.md",
        ]
    )

deploydocs(
    repo = "github.com/cormullion/Karkak.jl.git",
    target = "build",
    forcepush = true
)
