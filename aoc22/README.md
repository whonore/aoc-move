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

##### `vector::sum64_in()`, `vector::sum64()`, `vector::map_sum64()`

All pretty straightforward, but not much to prove except that they don't abort.
Made the `_in()` version in case it's useful at some point to operate on vector slices.
Was able to convince the prover that `vector::sum64_in()` doesn't overflow since
a vector can only be `MAX_U64`-long and every element is at most `MAX_U64` and
`MAX_U64 * MAX_U64 <= MAX_U128`.

##### `vector::max64_in()`, `vector::max64()`, `vector::max128_in()`, `vector::max128()`

Slightly more interesting because the spec can actually express the correctness
property.
The `_in()` version did end up helping for part 2.
Annoying to have to make multiple versions for different bit widths.
Need some sort of generic number trait or macros maybe.

### Day 2

#### Part 1

Pretty easy, just loop through each round, compute the score, and sum.
Would've been nicer to reuse `vector::sum64()`, but would still need the
explicit loop to map `score()` anyway, so it's not really worth it.
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

##### `vector::split_at()`

Create two vectors, while `i < idx` fill up the first one, then fill the second.
Satisfying to be able to prove a pretty much complete specification.

##### `vector::repeat()`

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

### Day 5

#### Part 1

Preprocessed the input into: number of columns of crates, crate columns as byte
strings, triples of `number of crates, from, to`.
Got to use `vector::split_at()` again to parse the input into separate `crates`
and `moves` vectors.
Then reverse each column so it can be used efficiently as a stack with
`vector::push_back()` and `vector::pop_back()` and follow the instructions by
popping/pushing as many times as needed.
Very helpful that `debug::print()` understands strings.

#### Part 2

Minor adjustment to `do_move()` that first moves the crates from `from` to a
temporary stack, then reverses them and concatenates with `to`.
Lots of other potential solutions that would require fewer iterations (e.g.,
combine reverse and append into a single loop), but this is concise and still
executes basically instantaneously.

### Day 6

#### Part 1 and 2

Keep track of a sliding window and iterate until it contains no duplicates.
Parts 1 and 2 are identical except for the size of the window.
`vector::repeat()` ended up being useful to initialize the window and
`vector::is_unique()` made the rest easy.

#### ExtraLib

##### `vector::is_unique()`

For every `i`, check that `v[i]` doesn't equal anything from `i + 1` to the end.
Another one where the specification is pretty much complete.

### Day 7

#### Part 1

Way more involved than previous days.
First time doing some string parsing in Move instead of preprocessing in Python
since it seemed like part of the challenge this time.
Fortunately it's easy to recognize commands vs. directories vs. files by the
first character.
Strategy is to parse the commands, keeping track of the current directory, and
build up the file system every time a directory or file appears.
The file system is a "map" (vector) from indices to paths, plus another map from
indices to "directory entries".
Directory entries keep track of metadata like file size, the parent (index),
children (also indices), etc.
Then compute each directory's size by recursively looping through its children
and summing the file sizes.
Keep only the ones below the cutoff and we're done.

Also added some basic well-formedness struct invariants for `FileSystem` and `DirEntry`.
The prover crashes if `debug::print()` is anywhere so had to write a wrapper
script that first comments those out.

#### Part 2

Figure out the minimum necessary directory size by subtracting the size of the
root directory from the total disk space and then subtract that from the needed
free space.
Compute each directory's size again and find the minimum that meets the cutoff.
Thought about memoizing directory size since they never change and computing the
root's size already requires computing every other directory's size, but it
didn't seem to be necessary performance-wise.

#### ExtraLib

##### `vector::append_new()`

Concatenate two vectors and return a new one instead of updating in-place like
`vector::append()`.

##### `vector::split_by()`, `vector::join_by()`

Split a vector into a vector of vectors around a given delimiter, and its inverse.
Lots of weird corner cases with singleton and empty vectors, mostly follows what
Python does.
The specifications were tricky to get past the prover.
`vector::split_by()` needed the invariant that everything in the input vector is
in some sub-vector of the output stated as "an index exists at which there is a
sub-vector" rather than directly saying "there exists a sub-vector".
It also needed an inline hint that just restates the loop invariant, which seems weird.
`vector::join_by()` was similarly problematic, and I ended up adding an inline
assumption because I couldn't find a way otherwise to convince the prover that,
after `vector::append(v, u)`, `v` contains everything `u` did.

##### `vector::min64_in()`, `vector::min64()`

Just a simple copy-paste and modification of the corresponding `max` functions.

##### `string::parse_u64()`

Read each character, find its offset from ASCII `'0'`, multiply the running
total by 10, add the new digit.
Not much to prove except that it aborts if the input is empty or has any
non-digit characters.

### Day 8

#### Part 1

Check the visibility of a tree at `(r, c)` by seeing if it's the max in any of
`trees[r][0..c]`, `trees[r][c + 1..]`, `trees[0..r][c]`, `trees[r + 1, ..]`.
Use `vector::max8_in()` for the slices and a transposed version of `trees` for
the columns.

#### Part 2

Couldn't reuse Part 1's solution since we need the index of the nearest
greater-or-equal tree in each direction.
Similar idea though, for each row and column, search forwards and backwards for
the first greater-or-equal element, compute the distance, and multiply to get the score.
Gave `find_ge()` a `rev` argument to have it loop backwards instead of writing a
second function or reversing the list.
Lots of off-by-one errors, but that's what tests are for.

#### ExtraLib

##### `vector::transpose()`

Swap the rows and columns of a 2-D vector.
Must be non-empty and rectangular.
Surprisingly easy to verify.
I'm noticing the prover generally prefers loop invariants to use indices rather
than vector slices (e.g., `forall j in 0..i: P(v[i])` rather than `forall x in
v[0..i]: P(x)`).
Seems like it should be able to tell they're equivalent.

##### `math::max64()`, `math::min64()`, `math::minmax64()`, `math::absdiff64()`

Return the bigger or smaller or both of two numbers, and compute the distance
between two numbers.
Easy enough to do without functions, but common enough to be worth it I think.
It looks like `std::compare::cmp_bcs_bytes()` could work for a generic numeric
comparison function.
Maybe I'll try it if I keep having to copy functions for different bit widths.
Not sure how well the prover will handle it though.

##### `vector::max8_in()`, `vector::max8()`

Exactly the same as other `max` functions.

### Day 9

#### Part 1

Basic idea isn't too bad: keep track of head and tail positions, move head
according to instructions, adjust tail if either the x or y coordinate is more
than 1 away, keep a set of the visited tail positions, return the count.
Couple tricky things:
- Can't have negatives so the starting position is important.
  Solved by counting the number of "negative" moves (left and down) and setting
  those as initial x and y, respectively.
- How to avoid double counting already visited positions?
  Implemented another ad-hoc hash map by converting every x-y pair to a unique
  index (`y * width + x`).
  Much faster than using `vector::contains()`, but still kind of slow (~7.5 seconds).
  Some quick experimenting suggests most of that time is initializing the vector
  with `vector::repeat()`.
  Might see if it's possible to get that down without implementing a full-blown
  binary search tree or something.
- Not difficult to fix, but spent a while getting the wrong solution because I
  didn't realize move distances could be more than 1 digit.

##### Update

Switched to using a sparse array for the visited set, which reduced the time for
both parts to ~1.5 seconds.

#### Part 2

Extend Part 1 by keeping a vector of positions.
Move the head the same way as before, then, for each consecutive pair of knots,
move as if they were the head and tail in Part 1, keep track of tail positions, done.

#### ExtraLib

##### `vector::count()`

Count the number of times a given element appears.
Thought this might be useful to count the number of visited positions, but it
ended up being too slow.

##### `string::digit()`

Parse a single character into a digit.
Factored out of `parse_u64()` and used in Part 1 until I realized move distances
can be more than 1 digit.

##### `sparse::new()`, `sparse::get()`, `sparse::set()`, `sparse::is_set()`

A simple sparse array implementation using a vector of "buckets" of fixed size
(currently 1024).
Very helpful for hash maps where the keys might be very spaced out since Move
doesn't seem to do well with building large vectors.
Might even be a good basis for a generic hash map using `hash::sha3_256()` and
`bcs::to_bytes()`.

Also a good demonstration of some of the limitations of global/struct invariants
in Move.
A simple one for `SparseArray` is every bucket has at most `BUCKET_SIZE` elements.
The problem is the prover only checks if the invariant is preserved when the
struct is created or a mutable reference to it is dropped.
The problem is functions like `set()` don't drop the mutable reference inside
the module being verified.
So, it will happily accept an implementation of `set()` that breaks the
invariant only to blow up later in someone else's code when they call it.
A hacky workaround is to define a private function that takes an owned
`SparseArray` and calls `set()` just to trigger the check.
However, in this case it fails due to an unrelated issue where the prover thinks
an invariant in `std::option` is broken (not very modular, these invariants)
even though that doesn't make any sense.
For now we'll just have to trust that the invariant holds.

### Day 10

#### Part 1

Parse the instructions, loop the appropriate number of cycles, check every time
if its one we're interested in, record the current "signal strength" if so, then
adjust the register if the instruction was `addx`.
Finally, sum the signal strengths.
All pretty easy thanks to the `extralib` functions.

#### Part 2

Very similar to Part 1.
Instruction parsing and execution is the same, but this time check if the
current pixel (`cycle % 40`) is contained in the sprite (`[X - 1, X, X + 1]`),
and draw `#` if so and `.` otherwise.

#### ExtraLib

##### `vector::last()`, `vector::last_mut()`

Immutable and mutable borrows of the last element.
Just useful helpers.

##### `string::parse_64_in()`

Parse a string slice.
Made it possible to reuse for `signed64::parse()`.

##### `signed64::pos()`, `signed64::neg()`, `signed64::is_pos()`, `signed64::is_neg()`, `signed64::abs()`, `signed64::opp()`, `signed64::add()`, `signed64::sub()`, `signed64::parse()`

A signed 64-bit integer implementation that wraps a `u64` with a flag for the sign.
Everything is straightforward except a few functions have special cases for `0`
to prevent `-0`, which is also enforced by a struct invariant.

### Day 11

#### Part 1

Similar overall to yesterday: parse the instructions, run them some number of
times, count the number of inspected items.
Parsing is probably the trickiest part, but most of the text in each line can be
ignored, so `vector::split_at()` and `string::parse_u64()` are sufficient.

#### Part 2

Worry values get too big without dividing by 3, but, since we're ultimately only
interested in whether they're divisible by certain values, we can use the fact
that `(x mod (n * m)) mod n = x mod n` ([Coq proof](./proofs/mod-prod.v)) and
take the worry mod the product of all the test divisors.
Noticed the divisors are all prime, but unless I'm missing something, the
property doesn't actually require that, so maybe it was just a hint to get you
to think about them?
The test for Part 2 times out with the default gas limit (1000000), but raising
it to 10000000 works.
Doesn't seem like there's a way of configuring that globally from `Move.toml`.

### Day 12

#### Part 1

It's hash map day.
Problem is to find the shortest distance, which means Djikstra's algorithm,
which means keeping track of distances for coordinates, which means hash maps.
Could've done something similar to Day 9's sparse array + converting coordinates
to index approach, but that's already 90% of the way there, so why not just do
the whole thing?
Opted not to make a priority queue for the unvisited set, but, since the average
number of edges is quite small (`<= 4` and often just 1 or 2), was able to keep
the linear search time for the smallest distance manageable by only adding
neighbors of visited nodes.

#### Part 2

Trivial extension of Part 1 to find the starting point with the shortest path.
Part 1 already found the distance to the end from every point so just look for
the minimum.

#### ExtraLib

##### `hashmap::new()`, `hashmap::get()`, `hashmap::has_key()`, `hashmap::set()`

A generic hash map implemented by maintaining two sparse arrays for keys and values.
The hash function combines `hash::sha3_256()` and `bcs::to_bytes()`.
Collisions are handled by chaining, hence each sparse array stores a vector of
either keys or values.
Struct invariants ensure key and value arrays stay in sync.
Lots of weird, seemingly unnecessary assumptions required for some of the parts
that use mutable references.
Might investigate more later to see if they can be removed.

##### `sparse::get_mut()`

Needed by `hashmap::set()` to add new keys and values.
Also added spec functions for `sparse::get()` and `sparse::is_set()` so they can
be used in `hashmap` specs.

##### `math::max_u64()`

Exposes `(2 << 64) - 1` as a constant.
Will add other sizes as needed.
