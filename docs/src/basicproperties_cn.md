# 图属性的访问
以下是用于访问图形属性的函数的概述。有关修改图形的函数，请参阅[创建和修改图](@ref)。

## 图相关属性:

- `nv`: 返回图中节点的个数。
- `ne`: 返回图中边的个数。
- `vertices`: 返回图中所有节点的迭代器对象。
- `edges`: 返回图中所有边的可迭代对象。
- `has_vertex`: 检测图中是否包含给定的节点。
- `has_edge(g, s, d)`: 判读图`g`中是否存在一个由`s`指向`d`的边。
- `has_edge(g, e)` 对于任意`f ∈ edges(g)`，若图`g`中存在一条这样的边`e == f`，那么返回true。这是一个严格的相等测试，它要求`e`的所有属性都相同。这种相等的定义取决于实现。 对于检测两个节点`s,d`间是否存在边，使用了`has_edge(g, s, d)`。
注意: 要安全的使用`has_edge(g, e)` 方法, 请务必了解边在何条件下彼此相等。 这些条件由图类型`G`定义的`has_edge(g::G,e)`方法**所定义**。 它默认的行为是去检查`has_edge(g,src(e),dst(e))`。 存在这种区别是为了允许新的图类型（像MetaGraphs或者MultiGraphs）能够区分源节点和目的节点相同但属性不同的边。
- `has_self_loops` 检查是否存在自循环。
- `is_directed` 检测图是否为有向图。
- `eltype` 返回图中元素的类型。
- `has_contiguous_vertices` 检测图是不是一个节点从`1`到`nv(g)`连续的节点组成的图。

## 节点相关属性

- `neighbors`: 返回节点的邻接数组。如果图是有向的，输出等价于 `outneighbors`。
- `all_neighbors`: 返回一个数组，包含节点的所有邻居(包含`inneighbors`和`outneighbors`)。对无向图来说，等价于`neighbors`。
- `inneighbors`: 返回节点in-neighbors的数组。 对无向图来说等价于`neighbors`。
- `outneighbors`:返回节点out-neighbors的数组。对于无向图来说，等价于`neighbors`。

## 边相关属性

- `src`: 得到一条边中的源节点。
- `dst`: 获得一条边中的目的节点。
- `reverse`: 创建一条与给定边相反方向的边。
