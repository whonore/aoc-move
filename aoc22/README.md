# aoc-move 2022

## Build/Run Instructions

```
./run.sh [day]
```

## Comments/Notes

### Day 1

#### Part 1

Trivial with the `ExtraLib` functions.
Just compute the sums and take the max.

#### Part 2

Could've implemented a sort or a heap and probably will need to eventually, but,
since the input is pretty small, took the ~lazy~ creative approach and just
found the max index, then the max of everything around that index, and so on.
`O(6n)` is still `O(n)`, so it's fine.

#### ExtraLib

##### `sum64_in()`, `sum64()`, `map_sum64()`

All pretty straightforward, but not much to prove except that they don't abort.
Made the `_in()` version in case it's useful at some point to operate on vector slices.
Was able to convince the prover that `sum_in()` doesn't overflow since a vector
can only be `MAX_U64`-long and every element is at most `MAX_U64` and `MAX_U64 *
MAX_U64 <= MAX_U128`.

##### `max64_in()`, `max64()`, `max128_in()`, `max128()`

Slightly more interesting because the spec can actually express the correctness
property.
The `_in()` version did end up helping for part 2.
Annoying to have to make multiple versions for different bit widths.
Need some sort of generic number trait or macros maybe.
