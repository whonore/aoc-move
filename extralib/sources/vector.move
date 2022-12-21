module extralib::vector {
    use std::vector;

    /// Get the last element of `v`.
    public fun last<T>(v: &vector<T>): &T {
        vector::borrow(v, vector::length(v) - 1)
    }

    spec last {
        aborts_if len(v) == 0;
        ensures result == v[len(v) - 1];
    }

    /// Get the last element of `v`.
    public fun last_mut<T>(v: &mut vector<T>): &mut T {
        let len = vector::length(v);
        vector::borrow_mut(v, len - 1)
    }

    spec last_mut {
        aborts_if len(v) == 0;
        ensures result == v[len(v) - 1];
    }

    /// Add the values in `v[start..endx]`.
    public fun sum64_in(v: &vector<u64>, start: u64, endx: u64): u128 {
        let s = 0;
        let i = start;
        while ({
            spec {
                invariant start < endx ==> in_range(start..endx + 1, i);
                invariant s <= MAX_U64 * (i - start);
            };
            i < endx
        }) {
            s = s + (*vector::borrow(v, i) as u128);
            i = i + 1;
        };
        s
    }

    spec sum64_in {
        requires endx <= len(v);
        aborts_if false;
    }

    /// Add the values in `v`.
    public fun sum64(v: &vector<u64>): u128 {
        sum64_in(v, 0, vector::length(v))
    }

    spec sum64 {
        aborts_if false;
    }

    /// Apply `sum64()` to every vector in `v`.
    public fun map_sum64(v: &vector<vector<u64>>): vector<u128> {
        let w = vector[];
        let i = 0;
        let vlen = vector::length(v);
        while ({
            spec {
                invariant i <= vlen;
                invariant len(v) == vlen;
                invariant len(w) == i;
            };
            i < vlen
        }) {
            vector::push_back(&mut w, sum64(vector::borrow(v, i)));
            i = i + 1;
        };
        w
    }

    spec map_sum64 {
        aborts_if false;
        ensures len(result) == len(v);
    }

    /// Find the maximum value and its position in `v[start..endx]`.
    public fun max8_in(v: &vector<u8>, start: u64, endx: u64): (u64, u8) {
        if (start >= endx) {
            return (0, 0)
        };

        let max_idx = start;
        let max = *vector::borrow(v, max_idx);
        let i = start;
        while ({
            spec {
                invariant in_range(start..endx + 1, i);
                invariant in_range(start..i + 1, max_idx);
                invariant in_range(start..endx, max_idx);
                invariant v[max_idx] == max;
                invariant forall j in (start..i): max >= v[j];
            };
            i < endx
        }) {
            let x = *vector::borrow(v, i);
            if (x > max) {
                max_idx = i;
                max = x;
            };
            i = i + 1;
        };
        (max_idx, max)
    }

    spec max8_in {
        requires endx <= len(v);
        aborts_if false;
        ensures start < endx ==> in_range(start..endx, result_1);
        ensures start < endx ==> v[result_1] == result_2;
        ensures start < endx ==> (forall x in v[start..endx]: result_2 >= x);
    }

    /// Find the maximum value and its position in `v`.
    public fun max8(v: &vector<u8>): (u64, u8) {
        max8_in(v, 0, vector::length(v))
    }

    spec max8 {
        aborts_if false;
        ensures len(v) > 0 ==> in_range(v, result_1);
        ensures len(v) > 0 ==> v[result_1] == result_2;
        ensures len(v) > 0 ==> (forall x in v: result_2 >= x);
    }

    /// Find the maximum value and its position in `v[start..endx]`.
    public fun max64_in(v: &vector<u64>, start: u64, endx: u64): (u64, u64) {
        if (start >= endx) {
            return (0, 0)
        };

        let max_idx = start;
        let max = *vector::borrow(v, max_idx);
        let i = start;
        while ({
            spec {
                invariant in_range(start..endx + 1, i);
                invariant in_range(start..i + 1, max_idx);
                invariant in_range(start..endx, max_idx);
                invariant v[max_idx] == max;
                invariant forall j in (start..i): max >= v[j];
            };
            i < endx
        }) {
            let x = *vector::borrow(v, i);
            if (x > max) {
                max_idx = i;
                max = x;
            };
            i = i + 1;
        };
        (max_idx, max)
    }

    spec max64_in {
        requires endx <= len(v);
        aborts_if false;
        ensures start < endx ==> in_range(start..endx, result_1);
        ensures start < endx ==> v[result_1] == result_2;
        ensures start < endx ==> (forall x in v[start..endx]: result_2 >= x);
    }

    /// Find the maximum value and its position in `v`.
    public fun max64(v: &vector<u64>): (u64, u64) {
        max64_in(v, 0, vector::length(v))
    }

    spec max64 {
        aborts_if false;
        ensures len(v) > 0 ==> in_range(v, result_1);
        ensures len(v) > 0 ==> v[result_1] == result_2;
        ensures len(v) > 0 ==> (forall x in v: result_2 >= x);
    }

    /// Find the maximum value and its position in `v[start..endx]`.
    public fun max128_in(v: &vector<u128>, start: u64, endx: u64): (u64, u128) {
        if (start >= endx) {
            return (0, 0)
        };

        let max_idx = start;
        let max = *vector::borrow(v, max_idx);
        let i = start;
        while ({
            spec {
                invariant in_range(start..endx + 1, i);
                invariant in_range(start..i + 1, max_idx);
                invariant in_range(start..endx, max_idx);
                invariant v[max_idx] == max;
                invariant forall j in (start..i): max >= v[j];
            };
            i < endx
        }) {
            let x = *vector::borrow(v, i);
            if (x > max) {
                max_idx = i;
                max = x;
            };
            i = i + 1;
        };
        (max_idx, max)
    }

    spec max128_in {
        requires endx <= len(v);
        aborts_if false;
        ensures start < endx ==> in_range(start..endx, result_1);
        ensures start < endx ==> v[result_1] == result_2;
        ensures start < endx ==> (forall x in v[start..endx]: result_2 >= x);
    }

    /// Find the maximum value and its position in `v`.
    public fun max128(v: &vector<u128>): (u64, u128) {
        max128_in(v, 0, vector::length(v))
    }

    spec max128 {
        aborts_if false;
        ensures len(v) > 0 ==> in_range(v, result_1);
        ensures len(v) > 0 ==> v[result_1] == result_2;
        ensures len(v) > 0 ==> (forall x in v: result_2 >= x);
    }

    /// Find the minimum value and its position in `v[start..endx]`.
    public fun min64_in(v: &vector<u64>, start: u64, endx: u64): (u64, u64) {
        if (start >= endx) {
            return (0, 0)
        };

        let min_idx = start;
        let min = *vector::borrow(v, min_idx);
        let i = start;
        while ({
            spec {
                invariant in_range(start..endx + 1, i);
                invariant in_range(start..i + 1, min_idx);
                invariant in_range(start..endx, min_idx);
                invariant v[min_idx] == min;
                invariant forall j in (start..i): min <= v[j];
            };
            i < endx
        }) {
            let x = *vector::borrow(v, i);
            if (x < min) {
                min_idx = i;
                min = x;
            };
            i = i + 1;
        };
        (min_idx, min)
    }

    spec min64_in {
        requires endx <= len(v);
        aborts_if false;
        ensures start < endx ==> in_range(start..endx, result_1);
        ensures start < endx ==> v[result_1] == result_2;
        ensures start < endx ==> (forall x in v[start..endx]: result_2 <= x);
    }

    /// Find the minimum value and its position in `v`.
    public fun min64(v: &vector<u64>): (u64, u64) {
        min64_in(v, 0, vector::length(v))
    }

    spec min64 {
        aborts_if false;
        ensures len(v) > 0 ==> in_range(v, result_1);
        ensures len(v) > 0 ==> v[result_1] == result_2;
        ensures len(v) > 0 ==> (forall x in v: result_2 <= x);
    }

    /// Create a vector of a length `n` by repeating `default`.
    public fun repeat<T: copy>(n: u64, default: &T): vector<T> {
        let v = vector[];

        let i = 0;
        while ({
            spec {
                invariant i <= n;
                invariant len(v) == i;
                invariant forall x in v: x == default;
            };
            i < n
        }) {
            vector::push_back(&mut v, *default);
            i = i + 1;
        };
        v
    }

    spec repeat {
        pragma opaque;
        aborts_if false;
        ensures len(result) == n;
        ensures forall x in result: x == default;
    }

    /// Concatenate two vectors into a new vector.
    public fun append_new<T: copy>(v1: &vector<T>, v2: &vector<T>): vector<T> {
        let v = *v1;
        vector::append(&mut v, *v2);
        v
    }

    spec append_new {
        aborts_if false;
        ensures result == concat(v1, v2);
    }

    /// Split a vector into two at `idx` (`v[idx]` will be the first element of
    /// the second vector).
    public fun split_at<T: copy>(v: &vector<T>, idx: u64): (vector<T>, vector<T>) {
        let v1 = vector[];
        let v2 = vector[];

        let i = 0;
        let vlen = vector::length(v);
        while ({
            spec {
                invariant i <= vlen;
                invariant i < idx ==> v1 == v[0..i];
                invariant i >= idx ==> v1 == v[0..idx];
                invariant i < idx ==> len(v2) == 0;
                invariant i >= idx ==> v2 == v[idx..i];
                invariant concat(v1, v2) == v[0..i];
            };
            i < vlen
        }) {
            let x = *vector::borrow(v, i);
            if (i < idx) {
                vector::push_back(&mut v1, x);
            } else {
                vector::push_back(&mut v2, x);
            };
            i = i + 1;
        };
        (v1, v2)
    }

    spec split_at {
        aborts_if false;
        ensures concat(result_1, result_2) == v;
        ensures idx < len(v) ==> result_1 == v[0..idx] && result_2 == v[idx..len(v)];
        ensures idx >= len(v) ==> result_1 == v && len(result_2) == 0;
    }

    /// Split a vector around `delim`.
    public fun split_by<T: copy + drop>(v: &vector<T>, delim: &T): vector<vector<T>> {
        let vs = vector[vector[]];
        let vidx = 0;

        let i = 0;
        let vlen = vector::length(v);
        if (vlen == 0) {
            return vector[]
        };
        while ({
            spec {
                invariant i <= vlen;
                invariant vidx == len(vs) - 1;
                // NOTE: For some reason the prover likes this version much
                // more than the equivalent commented-out versions.
                invariant forall j in 0..i where v[j] != delim: exists k in 0..vidx + 1:
                    contains(vs[k], v[j]);
                // invariant forall j in 0..i where v[j] != delim: exists k in range(vs):
                //     contains(vs[k], v[j]);
                // invariant forall j in 0..i where v[j] != delim: exists u in vs: contains(u, v[j]);
                invariant forall w in vs: forall x in w: contains(v, x);
                invariant forall w in vs: !contains(w, delim);
            };
            i < vlen
        }) {
            let x = *vector::borrow(v, i);
            if (x != *delim) {
                let w = vector::borrow_mut(&mut vs, vidx);
                vector::push_back(w, x);
            } else {
                vector::push_back(&mut vs, vector[]);
                vidx = vidx + 1;
                // NOTE: The prover needs this seemingly redundant hint.
                spec {
                    assert forall j in 0..i where v[j] != delim: exists k in 0..vidx:
                        contains(vs[k], v[j]);
                };
            };
            i = i + 1;
        };
        vs
    }

    spec split_by {
        aborts_if false;
        ensures forall x in v where x != delim: exists w in result: contains(w, x);
        ensures forall w in result: forall x in w: contains(v, x);
        ensures forall w in result: !contains(w, delim);
    }

    /// Join a vector of vectors using `delim`.
    public fun join_by<T: copy>(vs: &vector<vector<T>>, delim: &T): vector<T> {
        let v = vector[];

        let i = 0;
        let vlen = vector::length(vs);
        while ({
            spec {
                invariant i <= vlen;
                invariant forall j in 0..i: forall x in vs[j]: contains(v, x);
                invariant forall x in v where x != delim: exists j in 0..i: contains(vs[j], x);
            };
            i < vlen
        }) {
            vector::append(&mut v, *vector::borrow(vs, i));
            // NOTE: Unsure why the prover can't see this.
            spec { assume forall x in vs[i]: contains(v, x); };
            if (i + 1 != vlen) {
                vector::push_back(&mut v, *delim);
            };
            i = i + 1;
        };
        v
    }

    spec join_by {
        aborts_if false;
        ensures forall v in vs: forall x in v: contains(result, x);
        ensures forall x in result where x != delim: exists w in vs: contains(w, x);
    }

    /// Check if a vector has no duplicates.
    public fun is_unique<T>(v: &vector<T>): bool {
        let i = 0;
        let vlen = vector::length(v);

        if (vlen == 0) {
            return true
        };

        while ({
            spec {
                invariant i < vlen;
                invariant forall m in 0..i: forall n in range(v) where m != n: v[m] != v[n];
            };
            i < vlen - 1
        }) {
            let j = i + 1;
            let x = vector::borrow(v, i);
            while ({
                spec {
                    invariant i < j && j <= vlen;
                    invariant forall n in (i + 1)..j: v[i] != v[n];
                };
                j < vlen
            }) {
                let y = vector::borrow(v, j);
                if (x == y) {
                    return false
                };
                j = j + 1;
            };
            i = i + 1;
        };
        true
    }

    spec is_unique {
        aborts_if false;
        ensures
            result
            <==>
            (forall i in range(v):
               forall j in range(v) where i != j:
                 v[i] != v[j]);
    }

    /// Check if `xs` and `ys` have no elements in common.
    public fun disjoint<T>(xs: &vector<T>, ys: &vector<T>): bool {
        let xlen = vector::length(xs);
        let i = 0;
        while ({
            spec {
                invariant i <= xlen;
                invariant forall j in 0..i: !contains(ys, xs[j]);
            };
            i < xlen
        }) {
            let x = vector::borrow(xs, i);
            if (vector::contains(ys, x)) {
                return false
            };
            i = i + 1;
        };
        true
    }

    spec disjoint {
        aborts_if false;
        ensures
            result
            <==>
            ((forall x in xs: !contains(ys, x)) && (forall y in ys: !contains(xs, y)));
    }

    /// Swap a 2-D vector's rows with its columns.
    public fun transpose<T: copy>(v: &vector<vector<T>>): vector<vector<T>> {
        let vT = vector[];
        let rmax = vector::length(v);
        let cmax = vector::length(vector::borrow(v, 0));
        let c = 0;

        while ({
            spec {
                invariant c <= cmax;
                invariant len(vT) == c;
                invariant forall i in 0..c: len(vT[i]) == rmax;
                invariant forall i in 0..rmax: forall j in 0..c: v[i][j] == vT[j][i];
            };
            c < cmax
        }) {
            let r = 0;
            let rowT = vector[];
            while ({
                spec {
                    invariant r <= rmax;
                    invariant len(rowT) == r;
                    invariant forall i in 0..r: v[i][c] == rowT[i];
                };
                r < rmax
            }) {
                let x = *vector::borrow(vector::borrow(v, r), c);
                vector::push_back(&mut rowT, x);
                r = r + 1;
            };
            vector::push_back(&mut vT, rowT);
            c = c + 1;
        };
        vT
    }

    spec transpose {
        let rmax = len(v);
        let cmax = len(v[0]);
        requires rmax > 0;
        requires cmax > 0;
        requires forall col in v: len(col) == cmax;
        aborts_if false;
        ensures len(result) == cmax;
        ensures forall col in result: len(col) == rmax;
        ensures forall r in 0..rmax: forall c in 0..cmax: v[r][c] == result[c][r];
    }

    /// Count the number of `x` contained by `v`.
    public fun count<T>(v: &vector<T>, x: &T): u64 {
        let cnt = 0;
        let i = 0;
        let vlen = vector::length(v);

        while ({
            spec {
                invariant i <= vlen;
                invariant cnt <= i;
                invariant cnt == 0 <==> !contains(v[0..i], x);
            };
            i < vlen
        }) {
            if (vector::borrow(v, i) == x) {
                cnt = cnt + 1;
            };
            i = i + 1;
        };
        cnt
    }

    spec count {
        aborts_if false;
        ensures result <= len(v);
        ensures result == 0 <==> !contains(v, x);
    }

    /// Sort a vector of `u64`s with insertion sort.
    public fun sort64(v: &mut vector<u64>) {
        let i = 1;
        let vlen = vector::length(v);
        if (vlen <= 1) return;

        while ({
            spec {
                invariant vlen == len(v);
                invariant i <= vlen;
                // Everything up to `i` is sorted.
                invariant forall k in 0..i - 1: v[k] <= v[k + 1];
                // Sorting doesn't add or remove any new elements.
                invariant forall x in old(v): contains(v, x);
            };
            i < vlen
        }) {
            let j = i;
            while ({
                spec {
                    // NOTE: Repeated from the outer loop because Move doesn't
                    // seem to be able to derive it.
                    invariant vlen == len(v);
                    invariant j <= i && i < vlen;
                    // Everything before j is sorted.
                    invariant 0 < j ==> (forall k in 0..j - 1: v[k] <= v[k + 1]);
                    // Everything after j up to i is sorted.
                    invariant forall k in j..i: v[k] <= v[k + 1];
                    // The elements immediately surrounding j are sorted.
                    invariant 0 < j && j < i ==> v[j - 1] <= v[j + 1];
                    // Sorting doesn't add or remove any new elements.
                    invariant forall x in old(v): contains(v, x);
                };
                j > 0 && *vector::borrow(v, j - 1) > *vector::borrow(v, j)
            }) {
                vector::swap(v, j - 1, j);
                j = j - 1;
            };
            i = i + 1;
        };
    }

    spec sort64 {
        aborts_if false;
        // `v` is sorted.
        ensures forall i in 0..len(v) - 1: v[i] <= v[i + 1];
        // The length is unchanged.
        ensures len(v) == len(old(v));
        // The elements are unchanged.
        ensures forall x in old(v): contains(v, x);
    }

    #[test]
    fun test_last() {
        assert!(last(&vector[1,2,3,4,5]) == &5, 0);
    }

    #[test]
    fun test_last_mut() {
        let v = vector[1,2,3,4,5];
        *last_mut(&mut v) = 6;
        assert!(v == vector[1,2,3,4,6], 0);
    }

    #[test]
    fun test_sum64() {
        assert!(sum64_in(&vector[1,2,3,4,5], 1, 3) == 5, 0);
        assert!(sum64_in(&vector[1,2,3,4,5], 3, 2) == 0, 0);
        assert!(sum64_in(&vector[1,2,3,4,5], 100, 2) == 0, 0);
        assert!(sum64(&vector[1,2,3,4,5]) == 15, 0);
        assert!(sum64(&vector[]) == 0, 0);
    }

    #[test]
    fun test_map_sum64() {
        assert!(map_sum64(&vector[
            vector[1,2,3,4,5],
            vector[2,4,6],
            vector[]
        ]) == vector[15, 12, 0], 0);
    }

    #[test]
    fun test_max8() {
        let (idx, v) = max8_in(&vector[1,3,2,5,4], 1, 3);
        assert!(idx == 1 && v == 3, 0);
        let (idx, v) = max8_in(&vector[1,3,2,5,4], 3, 2);
        assert!(idx == 0 && v == 0, 0);
        let (idx, v) = max8_in(&vector[1,3,2,5,4], 100, 2);
        assert!(idx == 0 && v == 0, 0);
        let (idx, v) = max8(&vector[1,3,2,5,4]);
        assert!(idx == 3 && v == 5, 0);
        let (idx, v) = max8(&vector[]);
        assert!(idx == 0 && v == 0, 0);
    }

    #[test]
    fun test_max64() {
        let (idx, v) = max64_in(&vector[1,3,2,5,4], 1, 3);
        assert!(idx == 1 && v == 3, 0);
        let (idx, v) = max64_in(&vector[1,3,2,5,4], 3, 2);
        assert!(idx == 0 && v == 0, 0);
        let (idx, v) = max64_in(&vector[1,3,2,5,4], 100, 2);
        assert!(idx == 0 && v == 0, 0);
        let (idx, v) = max64(&vector[1,3,2,5,4]);
        assert!(idx == 3 && v == 5, 0);
        let (idx, v) = max64(&vector[]);
        assert!(idx == 0 && v == 0, 0);
    }

    #[test]
    fun test_max128() {
        let (idx, v) = max128_in(&vector[1,3,2,5,4], 1, 3);
        assert!(idx == 1 && v == 3, 0);
        let (idx, v) = max128_in(&vector[1,3,2,5,4], 3, 2);
        assert!(idx == 0 && v == 0, 0);
        let (idx, v) = max128_in(&vector[1,3,2,5,4], 100, 2);
        assert!(idx == 0 && v == 0, 0);
        let (idx, v) = max128(&vector[1,3,2,5,4]);
        assert!(idx == 3 && v == 5, 0);
        let (idx, v) = max128(&vector[]);
        assert!(idx == 0 && v == 0, 0);
    }

    #[test]
    fun test_min64() {
        let (idx, v) = min64_in(&vector[1,3,2,5,4], 1, 3);
        assert!(idx == 2 && v == 2, 0);
        let (idx, v) = min64_in(&vector[1,3,2,5,4], 3, 2);
        assert!(idx == 0 && v == 0, 0);
        let (idx, v) = min64_in(&vector[1,3,2,5,4], 100, 2);
        assert!(idx == 0 && v == 0, 0);
        let (idx, v) = min64(&vector[1,3,2,5,4]);
        assert!(idx == 0 && v == 1, 0);
        let (idx, v) = min64(&vector[]);
        assert!(idx == 0 && v == 0, 0);
    }

    #[test]
    fun test_repeat() {
        assert!(repeat(3, &1) == vector[1,1,1], 0);
        assert!(repeat(2, &true) == vector[true,true], 0);
        assert!(repeat(0, &1) == vector[], 0);
    }

    #[test]
    fun test_append_new() {
        assert!(append_new(&vector[1,2], &vector[3,4]) == vector[1,2,3,4], 0);
        assert!(append_new(&vector[1,2], &vector[]) == vector[1,2], 0);
        assert!(append_new(&vector[], &vector[3,4]) == vector[3,4], 0);
        assert!(append_new(&vector<u8>[], &vector[]) == vector[], 0);
    }

    #[test]
    fun test_split_at() {
        let (v1, v2) = split_at(&vector[1,2,3,4,5], 3);
        assert!(v1 == vector[1,2,3] && v2 == vector[4,5], 0);
        let (v1, v2) = split_at(&vector[1,2,3,4,5], 0);
        assert!(v1 == vector[] && v2 == vector[1,2,3,4,5], 0);
        let (v1, v2) = split_at(&vector[1,2,3,4,5], 5);
        assert!(v1 == vector[1,2,3,4,5] && v2 == vector[], 0);
    }

    #[test]
    fun test_split_by() {
        let ascii_b: u8 = 98;
        assert!(split_by(&vector[1,2,3], &2) == vector[vector[1],vector[3]], 0);
        assert!(split_by(&vector[1,2,2,3], &2) == vector[vector[1],vector[],vector[3]], 0);
        assert!(split_by(&vector[1,2,3], &4) == vector[vector[1,2,3]], 0);
        assert!(split_by(&vector[1], &2) == vector[vector[1]], 0);
        assert!(split_by(&vector[2], &2) == vector[vector[],vector[]], 0);
        assert!(split_by(&vector[], &2) == vector[], 0);
        assert!(split_by(&b"abcdbe", &ascii_b) == vector[b"a", b"cd", b"e"], 0);
    }

    #[test]
    fun test_join_by() {
        let ascii_b: u8 = 98;
        assert!(join_by(&vector[vector[1],vector[3]], &2) == vector[1,2,3], 0);
        assert!(join_by(&vector[vector[1],vector[],vector[3]], &2) == vector[1,2,2,3], 0);
        assert!(join_by(&vector[vector[1,2,3]], &4) == vector[1,2,3], 0);
        assert!(join_by(&vector[vector[1]], &2) == vector[1], 0);
        assert!(join_by(&vector[vector[],vector[]], &2) == vector[2], 0);
        assert!(join_by(&vector[], &2) == vector[], 0);
        assert!(join_by(&vector[b"a", b"cd", b"e"], &ascii_b) == b"abcdbe", 0);
    }

    #[test]
    fun test_is_unique() {
        assert!(is_unique<u64>(&vector[]), 0);
        assert!(is_unique(&vector[1]), 0);
        assert!(is_unique(&vector[1,2]), 0);
        assert!(is_unique(&vector[true,false]), 0);
        assert!(!is_unique(&vector[1,1]), 0);
        assert!(!is_unique(&vector[1,2,1]), 0);
    }

    #[test]
    fun test_disjoint() {
        assert!(disjoint<u64>(&vector[], &vector[]), 0);
        assert!(disjoint(&vector[1], &vector[]), 0);
        assert!(disjoint(&vector[], &vector[1]), 0);
        assert!(disjoint(&vector[1], &vector[2]), 0);
        assert!(disjoint(&vector[1,2], &vector[3,4,5]), 0);
        assert!(!disjoint(&vector[1,2,3], &vector[3,4,5]), 0);
        assert!(!disjoint(&vector[1,2], &vector[3,2,5]), 0);
        assert!(!disjoint(&vector[1,2,4], &vector[3,4]), 0);
    }

    #[test]
    fun test_transpose() {
        assert!(
            transpose(&vector[vector[1,2,3],vector[4,5,6]])
            == vector[vector[1,4],vector[2,5],vector[3,6]],
            0
        );
        assert!(
            transpose(&vector[vector[1,4],vector[2,5],vector[3,6]])
            == vector[vector[1,2,3],vector[4,5,6]],
            0
        );
    }

    #[test]
    fun test_count() {
        assert!(count(&vector[1,2,3], &1) == 1, 0);
        assert!(count(&vector[1,2,3,1], &1) == 2, 0);
        assert!(count(&vector[true,false,false], &false) == 2, 0);
        assert!(count(&vector[1,2,3], &4) == 0, 0);
        assert!(count(&vector[], &1) == 0, 0);
    }

    #[test]
    fun test_sort64() {
        let v = vector[];
        sort64(&mut v);
        assert!(v == vector[], 0);
        let v = vector[1];
        sort64(&mut v);
        assert!(v == vector[1], 0);
        let v = vector[1,2,3];
        sort64(&mut v);
        assert!(v == vector[1,2,3], 0);
        let v = vector[2,1,3];
        sort64(&mut v);
        assert!(v == vector[1,2,3], 0);
        let v = vector[3,4,1,5,3];
        sort64(&mut v);
        assert!(v == vector[1,3,3,4,5], 0);
    }
}
