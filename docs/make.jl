using Karnak
using Documenter
using DocumenterVitepress

DocMeta.setdocmeta!(Karnak, :DocTestSetup, :(using Karnak); recursive = true)

makedocs(
    # debug=true,
    authors = "cormullion",
    repo = Remotes.GitHub("Cormullion", "Karnak.jl"),
    sitename = "Karnak.jl",
    modules = [Karnak],
    format = DocumenterVitepress.MarkdownVitepress( 
        deploy_url = "github.com/cormullion/Karnak.jl",
        repo = "github.com/cormullion/Karnak.jl",
        devbranch = "master",
        devurl = "dev"),
    source = "src",
    build = "build",
    linkcheck = true,
    warnonly = true,
    pages    = [
        "Introduction to Karnak"  =>  "index.md",
        "Basic graphs"            =>  "basics.md",
        "Syntax"                  =>  "syntax.md",
        "Examples"                =>  "examples.md",
        "Reference" => [
            "Alphabetical function list"   =>  "reference/functionindex.md"
            "Function reference"           =>  "reference/api.md"
            ],
        ]
    )

deploydocs(
    repo = "github.com/cormullion/Karnak.jl",
    target = "build",
    branch = "gh-pages",
    devbranch = "master",
    push_preview = true,
    forcepush = true
)
