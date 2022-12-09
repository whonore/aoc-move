module extralib::sparse {
    use std::option::{Self, Option};
    use std::vector;
    use extralib::vector as evector;

    const EINDEX_OUT_OF_BOUNDS: u64 = 1;

    const BUCKET_SIZE: u64 = 1024;

    /// A sparse, fixed-size array.
    struct SparseArray<T> has copy, drop {
        buckets: vector<vector<Option<T>>>,
    }

    spec SparseArray {
        invariant forall b in buckets: len(b) <= BUCKET_SIZE;
    }

    /// Initialize a new sparse array of a given size.
    public fun new<T: copy>(size: u64): SparseArray<T> {
        let empty = vector<Option<T>>[];
        let nbuckets = size / BUCKET_SIZE;
        if (size % BUCKET_SIZE != 0) {
            nbuckets = nbuckets + 1;
        };
        let buckets = evector::repeat(nbuckets, &empty);
        vector::destroy_empty(empty);
        SparseArray { buckets }
    }

    spec new {
        aborts_if false;
        ensures len(result.buckets) * BUCKET_SIZE >= size;
        ensures forall v in result.buckets: len(v) == 0;
    }

    /// Get the element at position `i`.
    public fun get<T>(a: &SparseArray<T>, i: u64): &T {
        let (bidx, off) = idx_to_bucket(i);
        let bucket = vector::borrow(&a.buckets, bidx);
        let v = vector::borrow(bucket, off);
        option::borrow(v)
    }

    spec get {
        let bidx = i / BUCKET_SIZE;
        let off = i % BUCKET_SIZE;
        aborts_if !in_range(a.buckets, bidx);
        aborts_if !in_range(a.buckets[bidx], off);
        aborts_if option::is_none(a.buckets[bidx][off]);
        ensures option::spec_contains(a.buckets[bidx][off], result);
    }

    /// Check if there is an element at position `i`.
    public fun is_set<T>(a: &SparseArray<T>, i: u64): bool {
        let (bidx, off) = idx_to_bucket(i);
        let bucket = vector::borrow(&a.buckets, bidx);
        if (off < vector::length(bucket)) {
            let v = vector::borrow(bucket, off);
            option::is_some(v)
        } else {
            false
        }
    }

    spec is_set {
        let bidx = i / BUCKET_SIZE;
        let off = i % BUCKET_SIZE;
        aborts_if !in_range(a.buckets, bidx);
        ensures result <==> (in_range(a.buckets[bidx], off) && option::is_some(a.buckets[bidx][off]));
    }

    /// Set the element at position `i`.
    public fun set<T: drop>(a: &mut SparseArray<T>, i: u64, v: T) {
        let (bidx, off) = idx_to_bucket(i);
        let bucket = vector::borrow_mut(&mut a.buckets, bidx);
        let blen = vector::length(bucket);
        while ({
            spec {
                invariant len(bucket) == blen;
                invariant blen <= BUCKET_SIZE;
            };
            blen <= off
        }) {
            vector::push_back(bucket, option::none());
            blen = blen + 1;
        };
        *vector::borrow_mut(bucket, off) = option::some(v);
    }

    spec set {
        let bidx = i / BUCKET_SIZE;
        let off = i % BUCKET_SIZE;
        aborts_if !in_range(a.buckets, bidx);
        ensures option::spec_contains(a.buckets[bidx][off], v);
    }

    // NOTE: this complains that the invariant from `std::option` that
    // `len(vec) <= 1` is broken, which doesn't make any sense since it's
    // impossible to build a malformed `Option` with the provided API.
    // /// Confirm `set()` preserves the global invariants.
    // fun spec_set_invariant<T: drop>(a: SparseArray<T>, i: u64, v: T) {
    //     set(&mut a, i, v);
    // }

    /// Compute the bucket index and offset for `i`.
    fun idx_to_bucket(i: u64): (u64, u64) {
        let bidx = i / BUCKET_SIZE;
        let off = i % BUCKET_SIZE;
        (bidx, off)
    }

    spec idx_to_bucket {
        aborts_if false;
        ensures result_1 * BUCKET_SIZE + result_2 == i;
        ensures result_2 < BUCKET_SIZE;
    }

    #[test]
    fun test_new() {
        let v = new<u8>(0);
        assert!(vector::length(&v.buckets) == 0, 0);
        let v = new<u8>(1);
        assert!(vector::length(&v.buckets) == 1, 0);
        let v = new<u8>(BUCKET_SIZE);
        assert!(vector::length(&v.buckets) == 1, 0);
        let v = new<u8>(3 * BUCKET_SIZE + 10);
        assert!(vector::length(&v.buckets) == 4, 0);
    }

    #[test]
    fun test_set_get() {
        let v = new<u8>(2 * BUCKET_SIZE);
        assert!(!is_set(&v, 0), 0);
        set(&mut v, 0, 1);
        assert!(is_set(&v, 0), 0);
        assert!(get(&v, 0) == &1, 0);
        set(&mut v, 0, 2);
        assert!(get(&v, 0) == &2, 0);
        assert!(!is_set(&v, BUCKET_SIZE + 5), 0);
        set(&mut v, BUCKET_SIZE + 5, 3);
        assert!(is_set(&v, BUCKET_SIZE + 5), 0);
        assert!(get(&v, BUCKET_SIZE + 5) == &3, 0);
    }

    #[test]
    #[expected_failure]
    fun test_get_oob1() {
        let v = new<u8>(2 * BUCKET_SIZE);
        get(&v, 0);
    }

    #[test]
    #[expected_failure]
    fun test_get_oob2() {
        let v = new<u8>(2 * BUCKET_SIZE);
        get(&v, 2 * BUCKET_SIZE);
    }

    #[test]
    #[expected_failure]
    fun test_get_oob3() {
        let v = new<u8>(2 * BUCKET_SIZE);
        set(&mut v, BUCKET_SIZE - 1, 1);
        get(&v, 1);
    }

    #[test]
    fun test_idx_to_bucket() {
        let (bidx, off) = idx_to_bucket(0);
        assert!(bidx == 0 && off == 0, 0);
        let (bidx, off) = idx_to_bucket(10);
        assert!(bidx == 0 && off == 10, 0);
        let (bidx, off) = idx_to_bucket(3 * BUCKET_SIZE + 5);
        assert!(bidx == 3 && off == 5, 0);
    }
}
