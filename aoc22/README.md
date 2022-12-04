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

### Day 2

#### Part 1

Pretty easy, just loop through each round, compute the score, and sum.
Would've been nicer to reuse `sum64()`, but would still need the explicit loop
to map `score()` anyway, so it's not really worth it.
Apparently constants can't appear in other constants so the inputs have to use
`1`, `2`, etc. instead of `A`, `B`.
Compilation times seem pretty slow, maybe from the giant constant input vectors.
May need to find a workaround if this continues.
One option might be to move the inputs to their own package so they don't get
recompiled every time.

#### Part 2

Only change is to compute our move from the opponent's move and the intended outcome.
I hadn't thought about it before, but I guess Rock-Paper-Scissors forms
something like a group?
It's not closed, but there's some notion of an inverse: `Rock * Paper = Lose`,
`Lose * (Paper^-1) = Rock`, `Win * (Scissors^-1) = Rock`, etc.
Maybe there's a name for that.

### Day 3

#### Part 1

Split each rucksack in half, loop through the left half and look for an item
that's also in the right.
Initially didn't notice there would only be one duplicate and had a slightly
more complicated solution involving an ad-hoc hash map to keep track of already
found duplicates.

#### Part 2

Basically the same, but no need to split anything in half and have to check two
other vectors instead of one.
A dumb linear search (`vector::contains()`) worked fine for now, but I'm
guessing, at some point, some sort of set or sorted vector + binary search will
be necessary.

#### ExtraLib

##### `split_at()`

Create two vectors, while `i < idx` fill up the first one, then fill the second.
Satisfying to be able to prove a pretty much complete specification.

##### `repeat()`

Just call `vector::push_back()` `n` times.
Used to initialize the ad-hoc hash map, but ended up not needing it.
Decided to keep it anyway because I'd already proved the spec and it may be
useful later.

#### Other

Fixed the slow compilation times by loading the inputs from storage instead of
constants.
The scripts in `inputs/` (e.g., `d01.py`) read `$DAY.in`, parse it into a
Move-appropriate data type, and serialize it as `$DAY.bcs`.
Serialization works by just creating a temporary Move script that uses
`bcs::to_bytes()` and `debug::print()`.
Move seems to be able to deserialize BCS from storage much faster than it can
load a constant, at least for large vectors.

### Day 4

#### Part 1 and 2

Basically the same solution for both (4 character difference between
`contains()` and `overlaps()`).
Took a little bit of thought to get the inequalities right, but easy to sanity
check with tests.
