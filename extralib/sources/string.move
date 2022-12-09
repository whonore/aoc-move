module extralib::string {
    use std::vector;

    const EINVALID_UINT: u64 = 1;

    const ASCII_0: u8 = 48;

    public fun digit(c: u8): u8 {
        c - ASCII_0
    }

    public fun parse_u64(s: &vector<u8>): u64 {
        let x = 0;
        let slen = vector::length(s);
        assert!(slen > 0, EINVALID_UINT);
        let i = 0;
        while ({
            spec {
                invariant i <= slen;
                invariant forall j in 0..i: in_range(ASCII_0..ASCII_0 + 10, s[j]);
            };
            i < slen
        }) {
            let c = *vector::borrow(s, i);
            assert!(ASCII_0 <= c && c <= ASCII_0 + 9, EINVALID_UINT);
            x = (x * 10) + (digit(c) as u64);
            i = i + 1;
        };
        x
    }

    spec parse_u64 {
        pragma aborts_if_is_partial;
        aborts_if len(s) == 0;
        aborts_if exists c in s: !in_range(ASCII_0..ASCII_0 + 10, c);
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
