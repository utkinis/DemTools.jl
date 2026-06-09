using DemTools
using Documenter
using DocumenterVitepress

repo = "github.com/utkinis/DemTools.jl"
devbranch = "main"
devurl = "dev"

makedocs(;
         sitename="DemTools.jl",
         authors="Ivan Utkin",
         modules=[DemTools],
         format=DocumenterVitepress.MarkdownVitepress(; repo, devbranch, devurl, description="Tools for processing digital elevation models in Julia."),
         pages=["Getting started" => "index.md",
                "DEM filtering" => "filtering.md",
                "API reference" => "api.md"],
         checkdocs=:exports)

deploydocs(; repo, devbranch, push_preview=true)
