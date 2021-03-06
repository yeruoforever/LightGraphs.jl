"""
    sample!([rng, ]a, k)

Sample `k` element from array `a` without repetition and eventually excluding elements in `exclude`.

### Optional Arguments
- `exclude=()`: elements in `a` to exclude from sampling.

### Implementation Notes
Changes the order of the elements in `a`. For a non-mutating version, see [`sample`](@ref).
"""
function sample!(rng::AbstractRNG, a::AbstractVector, k::Integer; exclude=())
    minsize = k + length(exclude)
    length(a) < minsize && throw(ArgumentError("vector must be at least size $minsize"))
    res = Vector{eltype(a)}()
    sizehint!(res, k)
    n = length(a)
    i = 1
    while length(res) < k
        r = rand(rng, 1:(n - i + 1))
        if !(a[r] in exclude)
            push!(res, a[r])
            a[r], a[n - i + 1] = a[n - i + 1], a[r]
            i += 1
        end
    end
    res
end

sample!(a::AbstractVector, k::Integer; exclude=()) = sample!(getRNG(), a, k; exclude=exclude)

"""
    sample([rng,] r, k)

Sample `k` element from unit range `r` without repetition and eventually excluding elements in `exclude`.

### Optional Arguments
- `exclude=()`: elements in `a` to exclude from sampling.

### Implementation Notes
Unlike [`sample!`](@ref), does not produce side effects.
"""
sample(a::AbstractRange, k::Integer; exclude=()) = sample!(getRNG(), collect(a), k; exclude=exclude)

getRNG(seed::Integer=-1) = seed >= 0 ? MersenneTwister(seed) : GLOBAL_RNG

"""
    insorted(item, collection; rev=false)

Return true if `item` is in sorted collection `collection`.

### Implementation Notes
Does not verify that `collection` is sorted.
"""
function insorted(item, collection; rev=false)
    index = searchsorted(collection, item, rev=rev)
    return !isempty(index)
end

"""
    findall!(A, B)

Set the `B[1:|I|]` to `I` where `I` is the set of indices `A[I]` returns true.

Assumes `length(B) >= |I|`.
"""
function findall!(A::Union{BitVector, Vector{Bool}}, B::Vector{T}) where {T<:Integer}
    len = 0
    @inbounds for (i, a) in enumerate(A)
        if a
            len += 1
            B[len] = i
        end
    end
    return B
end

"""
    unweighted_contiguous_partition(num_items, required_partitions)

Partition `1:num_items` into `required_partitions` number of partitions such that the
difference in length of the largest and smallest partition is atmost 1.

### Performance
Time: O(required_partitions)
"""
function unweighted_contiguous_partition(
    num_items::Integer,
    required_partitions::Integer
    )

    left = 1
    part = Vector{UnitRange}(undef, required_partitions)
    for i in 1:required_partitions
        len = fld(num_items+i-1, required_partitions)
        part[i] = left:(left+len-1)
        left += len
    end
    return part
end

"""
    greedy_contiguous_partition(weight, required_partitions, num_items=length(weight))

Partition `1:num_items` into atmost `required_partitions` number of contiguous partitions with
the objective of minimising the largest partition.
The size of a partition is equal to the num of the weight of its elements.
`weight[i] > 0`.

### Performance
Time: O(num_items+required_partitions)
Requires only one iteration over `weight` but may not output the optimal partition.

### Implementation Notes
`Balance(wt, left, right, n_items, n_part) =
max(sum(wt[left:right])*(n_part-1), sum(wt[right+1:n_items]))`.
Find `right` that minimises `Balance(weight, 1, right, num_items, required_partitions)`.
Set the first partition as `1:right`.
Repeat on indices `right+1:num_items` and one less partition.
"""
function greedy_contiguous_partition(
    weight::Vector{<:Integer},
    required_partitions::Integer,
    num_items::U=length(weight)
   ) where {U<:Integer}

    suffix_sum = cumsum(reverse(weight))
    reverse!(suffix_sum)
    push!(suffix_sum, 0) #Eg. [2, 3, 1] => [6, 4, 1, 0]

    partitions = Vector{UnitRange{U}}()
    sizehint!(partitions, required_partitions)

    left = one(U)
    for partitions_remain in reverse(1:(required_partitions-1))

        left >= num_items && break

        partition_size = weight[left]*partitions_remain #At least one item in each partition
        right = left

        #Find right: sum(wt[left:right])*partitions_remain and sum(wt[(right+1):num_items]) is balanced
        while right+one(U) < num_items && partition_size < suffix_sum[right+one(U)]
            right += one(U)
            partition_size += weight[right]*partitions_remain
        end
        #max( sum(wt[left:right]), sum(wt[(right+1):num_items]) ) = partition_size
        #max( sum(wt[left:(right-1)]), sum(wt[right:num_items]) ) = suffix_sum[right]
        if left != right && partition_size > suffix_sum[right]
            right -= one(U)
        end

        push!(partitions, left:right)
        left = right + one(U)
    end
    push!(partitions, left:num_items)

    return partitions
end

"""
    optimal_contiguous_partition(weight, required_partitions, num_items=length(weight))

Partition `1:num_items` into atmost `required_partitions` number of contiguous partitions such
that the largest partition is minimised.
The size of a partition is equal to the sum of the weight of its elements.
`weight[i] > 0`.

### Performance
Time: O(num_items*log(sum(weight)))

### Implementation Notes
Binary Search for the partitioning over `[fld(sum(weight)-1, required_partitions), sum(weight)]`.
"""
function optimal_contiguous_partition(
    weight::Vector{<:Integer},
    required_partitions::Integer,
    num_items::U=length(weight)
   ) where {U<:Integer}

    item_it = Iterators.take(weight, num_items)

    up_bound = sum(item_it) # Smallest known possible value
    low_bound = fld(up_bound-1, required_partitions) # Largest known impossible value

    # Find optimal balance
    while up_bound > low_bound+1
        search_for = fld(up_bound+low_bound, 2)

        sum_part = 0
        remain_part = required_partitions

        possible = true
        for w in item_it
            sum_part += w
            if sum_part > search_for
                sum_part = w
                remain_part -= 1
                if remain_part == 0
                    possible = false
                    break
                end
            end
        end
        if possible
            up_bound = search_for
        else
            low_bound = search_for
        end
    end
    best_balance = up_bound

    # Find the partition with optimal balance
    partitions = Vector{UnitRange{U}}()
    sizehint!(partitions, required_partitions)
    sum_part = 0
    left = 1
    for (i, w) in enumerate(item_it)
        sum_part += w
        if sum_part > best_balance
            push!(partitions, left:(i-1))
            sum_part = w
            left = i
        end
    end
    push!(partitions, left:num_items)

    return partitions
end

"""
    isbounded(n)

Returns true if `typemax(n)` of an integer `n` exists.
"""
isbounded(n::Integer) = true
isbounded(n::BigInt) = false

"""
    isbounded(T)

Returns true if `typemax(T)` of a type `T <: Integer` exists.
"""
isbounded(::Type{T}) where {T<:Integer} = isconcretetype(T)
isbounded(::Type{BigInt}) = false

"""
    range_shuffle!(r, a; seed=-1)

Fast shuffle Array `a` in UnitRange `r`.
Uses `seed` to initialize the random number generator, defaulting to `Random.GLOBAL_RNG` for `seed=-1`.
"""
function range_shuffle!(r::UnitRange, a::AbstractVector; seed::Int=-1)
    rng = getRNG(seed)
    (r.start > 0 && r.stop <= length(a)) || throw(DomainError(r, "range indices are out of bounds"))
    @inbounds for i = length(r):-1:2
        j = rand(rng, 1:i)
        ii = i + r.start - 1
        jj = j + r.start - 1
        a[ii], a[jj] = a[jj], a[ii]
    end
end

"""
    randbn(n, p, seed=-1)

Return a binomally-distribted random number with parameters `n` and `p` and optional `seed`.

### References
- "Non-Uniform Random Variate Generation," Luc Devroye, p. 522. Retrieved via http://www.eirene.de/Devroye.pdf.
- http://stackoverflow.com/questions/23561551/a-efficient-binomial-random-number-generator-code-in-java
"""
function randbn(n::Integer, p::Real, rng::AbstractRNG)
    log_q = log(1.0 - p)
    x = 0
    sum = 0.0
    while true
        sum += log(rand(rng)) / (n - x)
        sum < log_q && break
        x += 1
    end
    return x
end

"""
    is_graphical(degs)

Return `true` if the degree sequence `degs` is graphical.
A sequence of integers is called graphical, if there exists a graph where the degrees of its vertices form that same sequence.

### Performance
Time complexity: ``\\mathcal{O}(|degs|*\\log(|degs|))``.

### Implementation Notes
According to Erdös-Gallai theorem, a degree sequence ``\\{d_1, ...,d_n\\}`` (sorted in descending order) is graphical iff the sum of vertex degrees is even and the sequence obeys the property -
```math
\\sum_{i=1}^{r} d_i \\leq r(r-1) + \\sum_{i=r+1}^n min(r,d_i)
```
for each integer r <= n-1
"""
function is_graphical(degs::Vector{<:Integer})
    iseven(sum(degs)) || return false
    sorted_degs = sort(degs, rev = true)
    n = length(sorted_degs)
    cur_sum = zero(UInt64)
    mindeg = Vector{UInt64}(undef, n)
    @inbounds for i = 1:n
        mindeg[i] = min(i, sorted_degs[i])
    end
    cum_min = sum(mindeg)
    @inbounds for r = 1:(n - 1)
        cur_sum += sorted_degs[r]
        cum_min -= mindeg[r]
        cond = cur_sum <= (r * (r - 1) + cum_min)
        cond || return false
    end
    return true
end

"""
    distributed_generate_min_set(g, gen_func, comp, reps)

Distributed implementation of [`LightGraphs.generate_reduce`](@ref).
"""
function distributed_generate_reduce(
    g::AbstractGraph{T},
    gen_func::Function,
    comp::Comp,
    reps::Integer
)::Vector{T} where {T<:Integer, Comp}
    # Type assert required for type stability
    min_set::Vector{T} = @distributed ((x, y)->comp(x, y) ? x : y) for _ in 1:reps
        gen_func(g)
    end
    return min_set
end

"""
    threaded_generate_reduce(g, gen_func, comp reps)

Multi-threaded implementation of [`LightGraphs.generate_reduce`](@ref).
"""
function threaded_generate_reduce(
    g::AbstractGraph{T},
    gen_func::Function,
    comp::Comp,
    reps::Integer
)::Vector{T} where {T<:Integer, Comp}
    n_t = Base.Threads.nthreads()
    is_undef = ones(Bool, n_t)
    min_set = [Vector{T}() for _ in 1:n_t]
    Base.Threads.@threads for _ in 1:reps
        t = Base.Threads.threadid()
        next_set = gen_func(g)
        if is_undef[t] || comp(next_set, min_set[t])
            min_set[t] = next_set
            is_undef[t] = false
        end
    end

    min_ind = 0
    for i in filter((j)->!is_undef[j], 1:n_t)
        if min_ind == 0 || comp(min_set[i], min_set[min_ind])
            min_ind = i
        end
    end

    return min_set[min_ind]
end
