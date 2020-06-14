# 图类型

除了提供和实现`SimpleGraph`和`SimpleDiGraph`外， LightGraphs作为一个框架，也实现了其它的图类型。目前，有几个可供选择的其它的图类型:

- [SimpleWeightedGraphs](https://github.com/JuliaGraphs/SimpleWeightedGraphs.jl) 一种有向图和无向图的实现，能够为边定义权重。
- [MetaGraphs](https://github.com/JuliaGraphs/MetaGraphs.jl) 提供了一个有向图及无向图的数据结构，支持用户在图、顶点和边上定义属性。
- [StaticGraphs](https://github.com/JuliaGraphs/StaticGraphs.jl) 可以减少时空花销的高效实现，支持大规模的图处理。但是像它名字一样，这种类型的图对象一旦被建立，就不可更改。

### 图类型的选择

这里有些准则可以帮助您选择正确的图类型。

- 通常情况下, [LightGraphs.jl](https://github.com/JuliaGraphs/LightGraphs.jl)中原生的`SimpleGraphs`/`SimpleDiGraphs`结构就可以满足大部分需要。
- 如果您需要使用边的权重，并且不需要对图进行大量的修改操作， 那么请使用[SimpleWeightedGraphs](https://github.com/JuliaGraphs/SimpleWeightedGraphs.jl)。
- 如果您需要给图中的边和顶点做标签，那么请使用[MetaGraphs](https://github.com/JuliaGraphs/MetaGraphs.jl)。
- 如果您需要在一个非常大的图(billons to tens of billions of edges) 上面开展工作，并且不需要对图进行修改，那么请使用 [StaticGraphs](https://github.com/JuliaGraphs/StaticGraphs.jl)。
