module extralib::string {
    use std::vector;

    const EINVALID_UINT: u64 = 1;

    const ASCII_0: u8 = 48;

    /// Check if a character is an ASCII digit.
    public fun is_digit(c: u8): bool {
        ASCII_0 <= c && c < ASCII_0 + 10
    }

    spec is_digit {
        aborts_if false;
        ensures result <==> in_range(ASCII_0..ASCII_0 + 10, c);
    }

    /// Convert an ASCII character to a digit.
    public fun digit(c: u8): u8 {
        c - ASCII_0
    }

    spec digit {
        aborts_if c < ASCII_0;
    }

    /// Parse a `u64` from a string within `[start, endx)`.
    public fun parse_u64_in(s: &vector<u8>, start: u64, endx: u64): u64 {
        let x = 0;
        assert!(endx > start, EINVALID_UINT);
        let i = start;
        while ({
            spec {
                invariant i <= endx;
                invariant forall j in start..i: in_range(ASCII_0..ASCII_0 + 10, s[j]);
            };
            i < endx
        }) {
            let c = *vector::borrow(s, i);
            assert!(is_digit(c), EINVALID_UINT);
            x = (x * 10) + (digit(c) as u64);
            i = i + 1;
        };
        x
    }

    spec parse_u64_in {
        pragma aborts_if_is_partial;
        aborts_if !(endx > start);
        aborts_if exists c in s[start..endx]: !is_digit(c);
    }

    /// Parse a `u64` from a string.
    public fun parse_u64(s: &vector<u8>): u64 {
        parse_u64_in(s, 0, vector::length(s))
    }

    spec parse_u64 {
        pragma aborts_if_is_partial;
        aborts_if len(s) == 0;
        aborts_if exists c in s: !is_digit(c);
    }

    #[test]
    fun test_is_digit() {
        let digits = b"0123456789";
        let i = 0;
        while (i < 10) {
            assert!(is_digit(*vector::borrow(&digits, i)), 0);
            i = i + 1;
        };
        let nondigits = b"a!- @";
        let i = 0;
        while (i < vector::length(&nondigits)) {
            assert!(!is_digit(*vector::borrow(&nondigits, i)), 0);
            i = i + 1;
        };
    }

    #[test]
    fun test_digit() {
        let digits = b"0123456789";
        let i = 0;
        while (i < 10) {
            assert!(digit(*vector::borrow(&digits, i)) == (i as u8), 0);
            i = i + 1;
        };
    }

    #[test]
    fun test_parse_u64() {
        assert!(parse_u64_in(&b"a1b", 1, 2) == 1, 0);
        assert!(parse_u64_in(&b"a12b", 1, 3) == 12, 0);
        assert!(parse_u64(&b"1") == 1, 0);
        assert!(parse_u64(&b"12") == 12, 0);
        assert!(parse_u64(&b"120") == 120, 0);
    }

    #[test]
    #[expected_failure]
    fun test_parse_u64_invalid_empty() {
        parse_u64(&b"");
    }

    #[test]
    #[expected_failure]
    fun test_parse_u64_invalid_char() {
        parse_u64(&b"a");
    }
}
