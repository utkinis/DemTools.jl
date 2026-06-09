using DemTools
using Documenter
using DocumenterVitepress

DocMeta.setdocmeta!(DemTools, :DocTestSetup, :(using DemTools); recursive = true) # Keep doctest snippets short.

repo = "github.com/utkinis/DemTools.jl"
devbranch = "main"
devurl = "dev"
deploy_url = "https://utkinis.github.io/DemTools.jl/"

makedocs(;
    sitename = "DemTools.jl",
    authors = "Ivan Utkin",
    modules = [DemTools],
    format = DocumenterVitepress.MarkdownVitepress(;
        repo,
        devbranch,
        devurl,
        deploy_url,
        description = "Tools for processing digital elevation models in Julia.",
    ),
    pages = [
        "Getting started" => "index.md",
        "DEM filtering" => "filtering.md",
        "API reference" => "api.md",
    ],
    checkdocs = :exports,
)

DocumenterVitepress.deploydocs(;
    repo,
    target = joinpath(@__DIR__, "build"),
    branch = "gh-pages",
    devbranch,
    push_preview = true,
)
