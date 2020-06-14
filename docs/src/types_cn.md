# LightGraphs的图类型

*LightGraphs.jl* 支持抽象的图类型`AbstractGraph`和有具体实现的两种简单图类型——无向图[`SimpleGraph`](@ref)和有向图[`SimpleDiGraph`](@ref)——他们都是`AbstractGraph`的subtype。

## 具体类型

*LightGraphs.jl* 提供了两种有具体实现的图类型: 无向图`SimpleGraph`和有向图`SimpleDiGraph`。
这两种类型都能够被参数化，指定如何来表示节点（默认的， `SimpleGraph`和`SimpleDiGraph`使用系统默认的整数类型，通常为`Int64`）。

一个图*G*使用顶点的集合*V*和边的集合*E*来描述: *G = {V, E}*. *V* 的用整数范围`1:n`来表示; *E* 则使用一个由顶点做索引的正向邻接链表（对有向图而言，还有反向的）表示。边的集合可以使用一个产生`Edge`（这个类型是一个源顶点和目标定点的二元组`(src<:Integer, dst<:Integer)`来表示）类型的迭代器来访问。 顶点和边的类型可以是整数型的任意类型，并且推荐使用适合数据的最小类型来节省存储花销。

图可以使用`SimpleGraph()`或者`SimpleDiGraph()`来创建，并且有几个可选选项 (有关示例，请参阅教程)。

对于确定的两个顶点，重边是不被允许的： 但是向图中添加一个早已存在的边是不会引发错误的。这种情况可以通过[`add_edge!`](@ref)的返回值来识别。

需要注意的是，在一个图中，顶点数等于或者接近于这个图中表示顶点的类型的`typemax`时(_e.g._, a `SimpleGraph{UInt8}` with 127 vertices)，在某些函数处理过程中，可能会遇到溢出的情况，它应当被视为一项bug。出于安全的考虑，在选择图的类型参数时，请确保这个类型参数有一些备用容量。

## 抽象类型

*LightGraphs.jl* 可以允许开发者使用少数几个抽象类型构建自己的图类型。关于实现图类型要实现的最小方法，请参阅[构建一个可选的图类型](@ref)。

```@index
Order = [:type]
Pages   = ["types.md"]
```

为了鼓励JuliaGraphs生态系统中的实验和开发，*LightGraphs.jl* 定义了`AbstractGraph`类型，它已经被一些库使用，比如[MetaGraphs.jl](https://github.com/JuliaGraphs/MetaGraphs.jl) （关联有元数据的图）和[SimpleWeightedGraphs.jl](https://github.com/JuliaGraphs/SimpleWeightedGraphs.jl) （带权重的图）。 这些`AbstractGraph`的子类型必须实现下面所列的方法(在[图属性的访问](@ref)[创建和修改图](@ref)中，这些函数中的大多数都有更为详细的描述):

```@index
Order = [:function]
Pages   = ["types.md"]
```

## 抽象图类型和函数的完整文档

```@autodocs
Modules = [LightGraphs]
Pages   = ["interface.jl"]
Private = false
```

```@docs
zero(::Type{<:AbstractGraph})
```
