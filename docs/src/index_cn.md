# LightGraphs

*LightGraphs.jl* 的目标是为网络和图分析提供一个Julia下的高性能平台。  出于这个目的，LightGraphs不仅提供了(a) 一个具体的、简单的“图”的实现-- `SimpleGraph` (无向图) and `SimpleDiGraph` (有向图), 还提供了 (b) 一个可以构建更加复杂图实现的API， `AbstractGraph` 抽象类型。

因此, *LightGraphs.jl* 作为JuliaGraphs生态的核心包。额外的功能，像高级的IO和图文件格式、带权重的图、带属性的图和忧患相关的功能可以在下面的包中找到：
  * [LightGraphsExtras.jl](https://github.com/JuliaGraphs/LightGraphsExtras.jl): 图相关的额外功能。
  * [MetaGraphs.jl](https://github.com/JuliaGraphs/MetaGraphs.jl): 元数据相关的图实现。
  * [SimpleWeightedGraphs.jl](https://github.com/JuliaGraphs/SimpleWeightedGraphs.jl): 带权重的图。
  * [GraphIO.jl](https://github.com/JuliaGraphs/GraphIO.jl): 一个用于导入、导出通用的如edgelists, GraphML、Pajek NET等图对象文件格式的工具。
  * [GraphDataFrameBridge.jl](https://github.com/JuliaGraphs/GraphDataFrameBridge.jl): 一个将DataFrames中以表格形式存储边转为图对象(`MetaGraphs`, `MetaDiGraphs`)的工具。


## Basic library examples

*LightGraphs.jl* 包含了大量极为方便的通用功能，详见[Making and Modifying Graphs](@ref), 比如 `path_graph`可以依据给定的长度，极为便利的生成无向的[路径图](https://en.wikipedia.org/wiki/Path_graph)。
生成的图对象就可以很容易的查询和修改。

```julia
julia> g = path_graph(6)

# Number of vertices
julia> nv(g)

# Number of edges
julia> ne(g)

# Add an edge to make the path a loop
julia> add_edge!(g, 1, 6)
```

了解更多基础功能可以浏览 [Accessing Graph Properties](@ref)和[Making and Modifying Graphs](@ref)。更为详细的教程可以在如下仓库中找到[JuliaGraphs Tutorial Notebooks](https://github.com/JuliaGraphs/JuliaGraphsTutorials)。
