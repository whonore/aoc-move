module extralib::signed64 {
    use std::vector;
    use extralib::string as estring;

    const EINVALID_SINT: u64 = 1;

    const ASCII_HYPHEN: u8 = 45;
    const ASCII_0: u8 = 48;

    /// A signed 64-bit integer.
    struct Signed64 has copy, drop {
        val: u64,
        neg: bool,
    }

    spec Signed64 {
        // No negative 0
        invariant val == 0 ==> !neg;
    }

    /// Initialize a positive integer.
    public fun pos(val: u64): Signed64 {
        Signed64 { val, neg: false }
    }

    spec pos {
        aborts_if false;
    }

    /// Initialize a negative integer.
    public fun neg(val: u64): Signed64 {
        if (val != 0) { Signed64 { val, neg: true } } else { pos(val) }
    }

    spec neg {
        aborts_if false;
    }

    /// Check if `x` is positive.
    public fun is_pos(x: &Signed64): bool {
        !x.neg
    }

    spec is_pos {
        aborts_if false;
    }

    /// Check if `x` is negative.
    public fun is_neg(x: &Signed64): bool {
        x.neg
    }

    spec is_neg {
        aborts_if false;
    }

    /// Return the absolute value of `x` as a `u64`.
    public fun abs(x: &Signed64): u64 {
        x.val
    }

    spec abs {
        aborts_if false;
    }

    /// Flip `x`'s sign.
    public fun opp(x: &Signed64): Signed64 {
        if (x.val != 0) { Signed64 { val: x.val, neg: !x.neg } } else { *x }
    }

    spec opp {
        aborts_if false;
    }

    /// Add two signed integers.
    public fun add(x: &Signed64, y: &Signed64): Signed64 {
        if (!x.neg && !y.neg) {
            // (+, +)
            pos(x.val + y.val)
        } else if (!x.neg && y.neg) {
            // (+, -)
            if (x.val > y.val) { pos(x.val - y.val) } else { neg(y.val - x.val) }
        } else if (x.neg && !y.neg) {
            // (-, +)
            if (y.val > x.val) { pos(y.val - x.val) } else { neg(x.val - y.val) }
        } else {
            // (-, -)
            neg(x.val + y.val)
        }
    }

    spec add {
        aborts_if x.neg == y.neg && x.val + y.val > MAX_U64;
    }

    /// Subtract two signed integers.
    public fun sub(x: &Signed64, y: &Signed64): Signed64 {
        add(x, &opp(y))
    }

    spec sub {
        aborts_if x.neg != y.neg && x.val + y.val > MAX_U64;
    }

    /// Compute `|x - y|`.
    public fun absdiff(x: &Signed64, y: &Signed64): u64 {
        abs(&if (lt(x, y)) { sub(y, x) } else { sub(x, y) })
    }

    spec absdiff {
        aborts_if x.neg != y.neg && x.val + y.val > MAX_U64;
    }

    /// Check if `x` is less than `y`.
    public fun lt(x: &Signed64, y: &Signed64): bool {
        // (+, +)
        if (!x.neg && !y.neg) { x.val < y.val }
        // (+, -)
        else if (!x.neg && y.neg) { false }
        // (-, +)
        else if (x.neg && !y.neg) { true }
        // (-, -)
        else { x.val > y.val }
    }

    spec lt {
        aborts_if false;
    }

    /// Check if `x` is less than or equal to `y`.
    public fun le(x: &Signed64, y: &Signed64): bool {
        x == y || lt(x, y)
    }

    spec le {
        aborts_if false;
    }

    /// Check if `x` is greater than `y`.
    public fun gt(x: &Signed64, y: &Signed64): bool {
        lt(y, x)
    }

    spec gt {
        aborts_if false;
    }

    /// Check if `x` is greater than or equal to `y`.
    public fun ge(x: &Signed64, y: &Signed64): bool {
        x == y || gt(x, y)
    }

    spec ge {
        aborts_if false;
    }

    /// Parse a `Signed64` from a string.
    public fun parse(s: &vector<u8>): Signed64 {
        let slen = vector::length(s);
        assert!(slen > 0, EINVALID_SINT);
        if (*vector::borrow(s, 0) != ASCII_HYPHEN) {
            pos(estring::parse_u64(s))
        } else {
            neg(estring::parse_u64_in(s, 1, slen))
        }
    }

    spec parse {
        pragma aborts_if_is_partial;
        aborts_if len(s) == 0;
        aborts_if !(in_range(ASCII_0..ASCII_0 + 10, s[0]) || s[0] == ASCII_HYPHEN);
        aborts_if exists c in s[1..len(s)]: !in_range(ASCII_0..ASCII_0 + 10, c);
    }

    #[test]
    fun test_add() {
        assert!(add(&pos(1), &pos(2)) == pos(3), 0);
        assert!(add(&pos(3), &neg(1)) == pos(2), 0);
        assert!(add(&pos(3), &neg(5)) == neg(2), 0);
        assert!(add(&neg(3), &pos(8)) == pos(5), 0);
        assert!(add(&neg(3), &pos(2)) == neg(1), 0);
        assert!(add(&neg(3), &neg(1)) == neg(4), 0);
        assert!(add(&pos(3), &neg(3)) == pos(0), 0);
        assert!(add(&neg(3), &pos(3)) == pos(0), 0);
    }

    #[test]
    fun test_sub() {
        assert!(sub(&pos(1), &pos(2)) == neg(1), 0);
        assert!(sub(&pos(3), &neg(1)) == pos(4), 0);
        assert!(sub(&pos(3), &neg(5)) == pos(8), 0);
        assert!(sub(&neg(3), &pos(8)) == neg(11), 0);
        assert!(sub(&neg(3), &pos(2)) == neg(5), 0);
        assert!(sub(&neg(3), &neg(1)) == neg(2), 0);
        assert!(sub(&pos(3), &neg(3)) == pos(6), 0);
        assert!(sub(&neg(3), &pos(3)) == neg(6), 0);
    }

    #[test]
    fun test_absdiff() {
        assert!(absdiff(&pos(1), &pos(2)) == 1, 0);
        assert!(absdiff(&pos(3), &neg(1)) == 4, 0);
        assert!(absdiff(&pos(3), &neg(5)) == 8, 0);
        assert!(absdiff(&neg(3), &pos(8)) == 11, 0);
        assert!(absdiff(&neg(3), &pos(2)) == 5, 0);
        assert!(absdiff(&neg(3), &neg(1)) == 2, 0);
        assert!(absdiff(&pos(3), &neg(3)) == 6, 0);
        assert!(absdiff(&neg(3), &pos(3)) == 6, 0);
    }

    #[test]
    fun test_lt() {
        assert!(lt(&pos(1), &pos(2)), 0);
        assert!(!lt(&pos(3), &neg(1)), 0);
        assert!(!lt(&pos(3), &neg(5)), 0);
        assert!(lt(&neg(3), &pos(8)), 0);
        assert!(lt(&neg(3), &pos(2)), 0);
        assert!(lt(&neg(3), &neg(1)), 0);
        assert!(!lt(&pos(3), &neg(3)), 0);
        assert!(lt(&neg(3), &pos(3)), 0);
    }

    #[test]
    fun test_gt() {
        assert!(!gt(&pos(1), &pos(2)), 0);
        assert!(gt(&pos(3), &neg(1)), 0);
        assert!(gt(&pos(3), &neg(5)), 0);
        assert!(!gt(&neg(3), &pos(8)), 0);
        assert!(!gt(&neg(3), &pos(2)), 0);
        assert!(!gt(&neg(3), &neg(1)), 0);
        assert!(gt(&pos(3), &neg(3)), 0);
        assert!(!gt(&neg(3), &pos(3)), 0);
    }

    #[test]
    fun test_le() {
        assert!(le(&pos(1), &pos(2)), 0);
        assert!(!le(&pos(3), &neg(1)), 0);
        assert!(!le(&pos(3), &neg(5)), 0);
        assert!(le(&neg(3), &pos(8)), 0);
        assert!(le(&neg(3), &pos(2)), 0);
        assert!(le(&neg(3), &neg(1)), 0);
        assert!(!le(&pos(3), &neg(3)), 0);
        assert!(le(&neg(3), &pos(3)), 0);
        assert!(le(&neg(3), &neg(3)), 0);
        assert!(le(&pos(3), &pos(3)), 0);
    }

    #[test]
    fun test_ge() {
        assert!(!ge(&pos(1), &pos(2)), 0);
        assert!(ge(&pos(3), &neg(1)), 0);
        assert!(ge(&pos(3), &neg(5)), 0);
        assert!(!ge(&neg(3), &pos(8)), 0);
        assert!(!ge(&neg(3), &pos(2)), 0);
        assert!(!ge(&neg(3), &neg(1)), 0);
        assert!(ge(&pos(3), &neg(3)), 0);
        assert!(!ge(&neg(3), &pos(3)), 0);
        assert!(ge(&neg(3), &neg(3)), 0);
        assert!(ge(&pos(3), &pos(3)), 0);
    }

    #[test]
    fun test_parse() {
        assert!(parse(&b"1") == pos(1), 0);
        assert!(parse(&b"12") == pos(12), 0);
        assert!(parse(&b"120") == pos(120), 0);
        assert!(parse(&b"-120") == neg(120), 0);
    }
}
