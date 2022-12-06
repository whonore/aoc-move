module extralib::vector {
    use std::vector;

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
        aborts_if false;
        ensures len(result) == n;
        ensures forall x in result: x == default;
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
    fun test_repeat() {
        assert!(repeat(3, &1) == vector[1,1,1], 0);
        assert!(repeat(2, &true) == vector[true,true], 0);
        assert!(repeat(0, &1) == vector[], 0);
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
    fun test_is_unique() {
        assert!(is_unique<u64>(&vector[]), 0);
        assert!(is_unique(&vector[1]), 0);
        assert!(is_unique(&vector[1,2]), 0);
        assert!(is_unique(&vector[true,false]), 0);
        assert!(!is_unique(&vector[1,1]), 0);
        assert!(!is_unique(&vector[1,2,1]), 0);
    }
}
