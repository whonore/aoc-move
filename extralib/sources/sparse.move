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
        pragma opaque;
        let rem = if (size % BUCKET_SIZE != 0) { 1 } else { 0 };
        aborts_if false;
        ensures len(result.buckets) * BUCKET_SIZE >= size;
        ensures len(result.buckets) == size / BUCKET_SIZE + rem;
        ensures forall v in result.buckets: v == vec();
    }

    /// Get the element at position `i`.
    public fun get<T>(a: &SparseArray<T>, i: u64): &T {
        let (bidx, off) = idx_to_bucket(i);
        let bucket = vector::borrow(&a.buckets, bidx);
        let v = vector::borrow(bucket, off);
        option::borrow(v)
    }

    spec fun spec_get<T>(a: SparseArray<T>, i: u64): T {
        let bidx = i / BUCKET_SIZE;
        let off = i % BUCKET_SIZE;
        option::borrow(a.buckets[bidx][off])
    }

    spec get {
        pragma opaque;
        aborts_if !spec_is_set(a, i);
        ensures result == spec_get(a, i);
    }

    /// Get the element at position `i` or `option::none()`.
    public fun try_get<T: copy>(a: &SparseArray<T>, i: u64): Option<T> {
        let (bidx, off) = idx_to_bucket(i);
        if (bidx < vector::length(&a.buckets)) {
            let bucket = vector::borrow(&a.buckets, bidx);
            if (off < vector::length(bucket)) {
                *vector::borrow(bucket, off)
            } else {
                option::none()
            }
        } else {
            option::none()
        }
    }

    spec fun spec_try_get<T>(a: SparseArray<T>, i: u64): Option<T> {
        let bidx = i / BUCKET_SIZE;
        let off = i % BUCKET_SIZE;
        if (bidx < len(a.buckets) && off < len(a.buckets[bidx])) {
            a.buckets[bidx][off]
        } else {
            option::none()
        }
    }

    spec try_get {
        pragma opaque;
        aborts_if false;
        ensures result == spec_try_get(a, i);
    }

    /// Get a mutable reference to the element at position `i`.
    public fun get_mut<T>(a: &mut SparseArray<T>, i: u64): &mut T {
        let (bidx, off) = idx_to_bucket(i);
        let bucket = vector::borrow_mut(&mut a.buckets, bidx);
        let v = vector::borrow_mut(bucket, off);
        option::borrow_mut(v)
    }

    spec get_mut {
        pragma opaque;
        aborts_if !spec_is_set(a, i);
        ensures result == spec_get(a, i);
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

    spec fun spec_is_set<T>(a: SparseArray<T>, i: u64): bool {
        let bidx = i / BUCKET_SIZE;
        let off = i % BUCKET_SIZE;
        in_range(a.buckets, bidx)
        && in_range(a.buckets[bidx], off)
        && option::is_some(a.buckets[bidx][off])
    }

    spec is_set {
        pragma opaque;
        let bidx = i / BUCKET_SIZE;
        aborts_if !in_range(a.buckets, bidx);
        ensures result == spec_is_set(a, i);
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

    // NOTE: This complains that the invariant from `std::option` that
    // `len(vec) <= 1` is broken, which doesn't make any sense since it's
    // impossible to build a malformed `Option` with the provided API.
    // See: https://github.com/move-language/move/issues/716.
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
        assert!(try_get(&v, 0) == option::none(), 0);
        set(&mut v, 0, 1);
        assert!(is_set(&v, 0), 0);
        assert!(get(&v, 0) == &1, 0);
        assert!(try_get(&v, 0) == option::some(1), 0);
        set(&mut v, 0, 2);
        assert!(get(&v, 0) == &2, 0);
        assert!(try_get(&v, 0) == option::some(2), 0);
        assert!(!is_set(&v, BUCKET_SIZE + 5), 0);
        assert!(try_get(&v, BUCKET_SIZE + 5) == option::none(), 0);
        set(&mut v, BUCKET_SIZE + 5, 3);
        assert!(is_set(&v, BUCKET_SIZE + 5), 0);
        assert!(get(&v, BUCKET_SIZE + 5) == &3, 0);
        assert!(try_get(&v, BUCKET_SIZE + 5) == option::some(3), 0);
    }

    #[test]
    fun test_get_mut() {
        let v = new<u8>(2 * BUCKET_SIZE);
        set(&mut v, 0, 1);
        let x = get_mut(&mut v, 0);
        assert!(*x == 1, 0);
        *x = 2;
        assert!(get(&v, 0) == &2, 0);
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
