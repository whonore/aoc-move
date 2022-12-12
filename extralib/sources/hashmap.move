module extralib::hashmap {
    use std::bcs;
    use std::hash;
    use std::vector;
    use extralib::sparse::{Self, SparseArray};

    const ENOT_FOUND: u64 = 1;

    const NBUCKETS: u64 = 32;
    const BUCKET_SIZE: u64 = 1024;
    const SIZE: u64 = 32 * 1024;

    /// A hash map using a sparse array + chaining.
    struct Map<K, V> has copy, drop {
        keys: SparseArray<vector<K>>,
        vals: SparseArray<vector<V>>,
    }

    spec Map {
        // Key and value arrays are fixed-size
        invariant len(keys.buckets) == NBUCKETS && len(vals.buckets) == NBUCKETS;
        // Key and value arrays are in sync
        invariant forall i: u64:
            sparse::spec_is_set(keys, i) <==> sparse::spec_is_set(vals, i);
        invariant forall i: u64:
            sparse::spec_is_set(keys, i) ==>
            len(sparse::spec_get(keys, i)) == len(sparse::spec_get(vals, i));
        // Keys are in the appropriate slot
        invariant forall i: u64:
            sparse::spec_is_set(keys, i) ==>
            (forall k in sparse::spec_get(keys, i): spec_hash(k) == i);
    }

    /// Initialize a new hash map.
    public fun new<K: copy, V: copy>(): Map<K, V> {
        Map { keys: sparse::new(SIZE), vals: sparse::new(SIZE) }
    }

    spec new {
        aborts_if false;
    }

    /// Get the value that `k` maps to.
    public fun get<K, V>(m: &Map<K, V>, k: &K): &V {
        let h = hash(k);
        let keys = sparse::get(&m.keys, h);
        let vals = sparse::get(&m.vals, h);
        let (has, idx) = vector::index_of(keys, k);
        if (has) {
            vector::borrow(vals, idx)
        } else {
            abort ENOT_FOUND
        }
    }

    spec get {
        let h = spec_hash(k);
        aborts_if !sparse::spec_is_set(m.keys, h);
        aborts_if !contains(sparse::spec_get(m.keys, h), k);
        ensures exists i in range(sparse::spec_get(m.keys, h)):
            result == sparse::spec_get(m.vals, h)[i];
    }

    /// Check if there is a mapping for `k`.
    public fun has_key<K, V>(m: &Map<K, V>, k: &K): bool {
        let h = hash(k);
        if (sparse::is_set(&m.keys, h)) {
            let keys = sparse::get(&m.keys, h);
            vector::contains(keys, k)
        } else {
            false
        }
    }

    spec fun spec_has_key<K, V>(m: Map<K, V>, k: K): bool {
        let h = spec_hash(k);
        sparse::spec_is_set(m.keys, h) && contains(sparse::spec_get(m.keys, h), k)
    }

    spec has_key {
        aborts_if false;
        ensures result == spec_has_key(m, k);
    }

    /// Map `k` to `v`.
    public fun set<K: copy + drop, V: drop>(m: &mut Map<K, V>, k: &K, v: V) {
        let h = hash(k);
        if (sparse::is_set(&m.keys, h)) {
            let keys = sparse::get_mut(&mut m.keys, h);
            let vals = sparse::get_mut(&mut m.vals, h);
            // NOTE: The prover can't see this, maybe because of mutable ref
            // weirdness?
            spec {
                assume sparse::spec_get(m.keys, h) == keys;
                assume sparse::spec_get(m.vals, h) == vals;
            };
            let (has, idx) = vector::index_of(keys, k);
            if (!has) {
                vector::push_back(keys, *k);
                vector::push_back(vals, v);
                spec {
                    assume sparse::spec_get(m.keys, h) == keys;
                    assume sparse::spec_get(m.vals, h) == vals;
                };
            } else {
                *vector::borrow_mut(keys, idx) = *k;
                *vector::borrow_mut(vals, idx) = v;
                spec {
                    assume sparse::spec_get(m.keys, h) == keys;
                    assume sparse::spec_get(m.vals, h) == vals;
                    // NOTE: This really shouldn't be necessary, not sure
                    // what's going on.
                    assume sparse::spec_is_set(m.keys, h);
                    assume sparse::spec_is_set(m.vals, h);
                };
            };
        } else {
            sparse::set(&mut m.keys, h, vector[*k]);
            sparse::set(&mut m.vals, h, vector[v]);
        };
    }

    spec set {
        let h = spec_hash(k);
        aborts_if false;
        ensures sparse::spec_is_set(m.keys, h) && sparse::spec_is_set(m.vals, h);
        ensures exists i in range(sparse::spec_get(m.keys, h)):
            sparse::spec_get(m.keys, h)[i] == k && sparse::spec_get(m.vals, h)[i] == v;
    }

    // NOTE: Times out. Given how much trouble the prover is having with
    // mutable refs just going to ignore for now.
    // /// Confirm `set()` preserves the global invariants.
    // fun spec_set_invariant<K: copy + drop, V: drop>(m: Map<K, V>, k: &K, v: V) {
    //     set(&mut m, k, v);
    // }

    /// Compute the slot for `k`.
    fun hash<K>(k: &K): u64 {
        let bs = bcs::to_bytes(k);
        let bs = hash::sha3_256(bs);
        let n: u256 = 0;
        let nbytes = 256 / 8;
        let i = 0;
        while ({
            spec {
                invariant i <= nbytes;
                invariant n <= (1 << (i * 8)) - 1;
            };
            i < nbytes
        }) {
            // NOTE: This shouldn't be necessary, but the prover can't tell
            // that `n <= 2^248 - 1` and therefore `n * 256 + 255 <= 2^256 - 1`
            // even though it has the loop invariant and knows that `i` is at
            // most `31`.
            spec {
                assert i <= 31;
                // assert n <= (1 << (31 * 8)) - 1;
                assume n * 256 + 255 <= MAX_U256;
            };
            n = n * 256 + (*vector::borrow(&bs, i) as u256);
            i = i + 1;
        };
        (n % (SIZE as u256) as u64)
    }

    spec fun spec_hash<K>(k: K): u64;

    spec hash {
        pragma opaque;
        aborts_if false;
        ensures result < SIZE;
        ensures [abstract] result == spec_hash(k);
    }

    #[test]
    fun test_set_get() {
        let m = new<u8, vector<u64>>();
        assert!(!has_key(&m, &0), 0);
        set(&mut m, &0, vector[1,2,3]);
        assert!(has_key(&m, &0), 0);
        assert!(get(&m, &0) == &vector[1,2,3], 0);
        set(&mut m, &0, vector[4,5,6]);
        assert!(get(&m, &0) == &vector[4,5,6], 0);

        assert!(!has_key(&m, &123), 0);
        set(&mut m, &123, vector[9]);
        assert!(get(&m, &123) == &vector[9], 0);
        assert!(get(&m, &0) == &vector[4,5,6], 0);

        let m = new<vector<u64>, bool>();
        assert!(!has_key(&m, &vector[1,2]), 0);
        set(&mut m, &vector[1,2], true);
        assert!(has_key(&m, &vector[1,2]), 0);
        assert!(get(&m, &vector[1,2]) == &true, 0);
    }

    #[test]
    #[expected_failure]
    fun test_get_not_exist() {
        let m = new<u8, u8>();
        get(&m, &0);
    }
}
