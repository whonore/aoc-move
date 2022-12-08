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
