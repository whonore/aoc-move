module extralib::math {
    /// Return the larger of `x` and `y`.
    public fun max64(x: u64, y: u64): u64 {
        if (x > y) { x } else { y }
    }

    spec max64 {
        aborts_if false;
        ensures x <= y ==> result == y;
        ensures x >= y ==> result == x;
    }

    /// Return the smaller of `x` and `y`.
    public fun min64(x: u64, y: u64): u64 {
        if (x < y) { x } else { y }
    }

    spec min64 {
        aborts_if false;
        ensures x <= y ==> result == x;
        ensures x >= y ==> result == y;
    }

    /// Return the minimum and maximum of `x` and `y`.
    public fun minmax64(x: u64, y: u64): (u64, u64) {
        (min64(x, y), max64(x, y))
    }

    spec minmax64 {
        aborts_if false;
        ensures x <= y ==> result_1 == x && result_2 == y;
        ensures x >= y ==> result_1 == y && result_2 == x;
    }

    /// Compute `|x - y|`.
    public fun absdiff64(x: u64, y: u64): u64 {
        let (min, max) = minmax64(x, y);
        max - min
    }

    spec absdiff64 {
        aborts_if false;
        ensures x <= y ==> result == y - x;
        ensures y <= x ==> result == x - y;
    }

    #[test]
    fun test_max64() {
        assert!(max64(1, 3) == 3, 0);
        assert!(max64(3, 1) == 3, 0);
        assert!(max64(3, 3) == 3, 0);
    }

    #[test]
    fun test_min64() {
        assert!(min64(1, 3) == 1, 0);
        assert!(min64(3, 1) == 1, 0);
        assert!(min64(3, 3) == 3, 0);
    }

    #[test]
    fun test_minmax64() {
        let (min, max) = minmax64(1, 3);
        assert!(min == 1 && max == 3, 0);
        let (min, max) = minmax64(3, 1);
        assert!(min == 1 && max == 3, 0);
        let (min, max) = minmax64(3, 3);
        assert!(min == 3 && max == 3, 0);
    }

    #[test]
    fun test_absdiff64() {
        assert!(absdiff64(1, 3) == 2, 0);
        assert!(absdiff64(3, 1) == 2, 0);
        assert!(absdiff64(3, 3) == 0, 0);
    }
}
