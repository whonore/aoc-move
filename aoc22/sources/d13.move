module aoc22::d13 {
    use std::debug;
    use std::vector;
    use extralib::string as estring;
    use extralib::vector as evector;

    spec module {
        pragma verify = false;
    }

    struct Input has key {
        input: vector<vector<u8>>
    }

    const ASCII_COMMA: u8 = 44;
    const ASCII_LBRACK: u8 = 91;
    const ASCII_RBRACK: u8 = 93;

    const SEP: u8 = 255;

    const C_LT: u8 = 0;
    const C_EQ: u8 = 1;
    const C_GT: u8 = 2;

    fun parse_list(line: &vector<u8>): vector<u8> {
        let list = vector[];
        let lens = vector[];
        let lenidxs = vector[];
        let len = vector::length(line);
        let i = 0;
        while (i < len) {
            let c = *vector::borrow(line, i);
            if (c == ASCII_LBRACK) {
                if (!vector::is_empty(&lens)) {
                    *evector::last_mut(&mut lens) = *evector::last(&lens) + 1;
                };
                vector::push_back(&mut list, SEP);
                vector::push_back(&mut list, 0);
                vector::push_back(&mut lens, 0);
                vector::push_back(&mut lenidxs, vector::length(&list) - 1);
            } else if (c == ASCII_RBRACK) {
                let len = vector::pop_back(&mut lens);
                let lenidx = vector::pop_back(&mut lenidxs);
                *vector::borrow_mut(&mut list, lenidx) = len;
            } else if (c != ASCII_COMMA) {
                let start = i;
                let endx = i + 1;
                let endchars = vector[ASCII_COMMA, ASCII_RBRACK];
                while (!vector::contains(&endchars, vector::borrow(line, endx))) {
                    endx = endx + 1;
                };
                vector::push_back(&mut list, (estring::parse_u64_in(line, start, endx) as u8));
                *evector::last_mut(&mut lens) = *evector::last(&lens) + 1;
                i = endx - 1;
            };
            i = i + 1;
        };
        assert!(vector::length(&lens) == 0, 0);
        assert!(vector::length(&lenidxs) == 0, 0);
        list
    }

    fun next(list: &mut vector<u8>): vector<u8> {
        assert!(*vector::borrow(list, 0) == SEP, 0);
        let len = *vector::borrow(list, 1);
        if (len <= 1) {
            vector::remove(list, 0); // SEP
            vector::remove(list, 0); // len
            let new = *list;
            while (!vector::is_empty(list)) {
                vector::pop_back(list);
            };
            new
        } else {
            // Decrement len
            *vector::borrow_mut(list, 1) = len - 1;
            let fst = vector::remove(list, 2); // SEP or int
            if (fst != SEP) {
                vector[fst]
            } else {
                let len = vector::remove(list, 2); // len
                let new = vector[SEP, len];
                while (len > 0) {
                    let item = vector::remove(list, 2); // SEP or int
                    vector::push_back(&mut new, item);
                    if (item == SEP) {
                        let newlen = vector::remove(list, 2); // len
                        vector::push_back(&mut new, newlen);
                        len = len + newlen - 1;
                    } else {
                        len = len - 1;
                    };
                };
                new
            }
        }
    }

    fun ordered(left: &mut vector<u8>, right: &mut vector<u8>): u8 {
        while (!vector::is_empty(left) && !vector::is_empty(right)) {
            let lnxt = next(left);
            let rnxt = next(right);
            let lislist = vector::is_empty(&lnxt) || *vector::borrow(&lnxt, 0) == SEP;
            let rislist = vector::is_empty(&rnxt) || *vector::borrow(&rnxt, 0) == SEP;

            if (!lislist && !rislist) {
                assert!(vector::length(&lnxt) == 1, 0);
                assert!(vector::length(&rnxt) == 1, 0);
                let lval = *vector::borrow(&lnxt, 0);
                let rval = *vector::borrow(&rnxt, 0);
                // int vs int
                if (lval < rval) {
                    return C_LT
                } else if (lval > rval) {
                    return C_GT
                };
            } else {
                // list vs list
                if (!lislist) {
                    assert!(vector::length(&lnxt) == 1, 0);
                    lnxt = vector[SEP, 1, *vector::borrow(&lnxt, 0)];
                };
                if (!rislist) {
                    assert!(vector::length(&rnxt) == 1, 0);
                    rnxt = vector[SEP, 1, *vector::borrow(&rnxt, 0)];
                };
                let cmp = ordered(&mut lnxt, &mut rnxt);
                if (cmp != C_EQ) {
                    return cmp
                };
            }
        };
        // empty(right) ==> empty(left)
        if (vector::is_empty(left) && vector::is_empty(right)) {
            C_EQ
        } else if (vector::is_empty(left)) {
            C_LT
        } else {
            C_GT
        }
    }

    fun sort(lists: &mut vector<vector<u8>>) {
        let i = 1;
        let nlists = vector::length(lists);
        while (i < nlists) {
            let j = i;
            while (j > 0) {
                let x = *vector::borrow(lists, j - 1);
                let y = *vector::borrow(lists, j);
                if (ordered(&mut x, &mut y) != C_GT) {
                    break
                };
                vector::swap(lists, j - 1, j);
                j = j - 1;
            };
            i = i + 1;
        };
    }

    fun check_ordered(lines: &vector<vector<u8>>): u64 {
        let idxs = 0;
        let nlines = vector::length(lines);
        let i = 0;
        while (i < nlines) {
            let left = parse_list(vector::borrow(lines, i));
            let right = parse_list(vector::borrow(lines, i + 1));
            if (ordered(&mut left, &mut right) == C_LT) {
                idxs = idxs + (i / 3) + 1;
            };
            i = i + 3;
        };
        idxs
    }

    fun decoder_key(lines: &vector<vector<u8>>): u64 {
        let lists = vector[];
        let div1 = parse_list(&b"[[2]]");
        let div2 = parse_list(&b"[[6]]");
        let nlines = vector::length(lines);
        let i = 0;
        while (i < nlines) {
            let line = vector::borrow(lines, i);
            if (line != &b"") {
                vector::push_back(&mut lists, parse_list(line));
            };
            i = i + 1;
        };
        vector::push_back(&mut lists, copy div1);
        vector::push_back(&mut lists, copy div2);
        sort(&mut lists);

        let (has, idx1) = vector::index_of(&lists, &div1);
        assert!(has, 0);
        let (has, idx2) = vector::index_of(&lists, &div2);
        assert!(has, 0);
        (idx1 + 1) * (idx2 + 1)
    }

    public entry fun run() acquires Input {
        let input = borrow_global<Input>(@0x0);
        debug::print(&check_ordered(&input.input));
        debug::print(&decoder_key(&input.input));
    }

    #[test_only]
    const TEST_INPUT: vector<vector<u8>> = vector[
        b"[1,1,3,1,1]",
        b"[1,1,5,1,1]",
        b"",
        b"[[1],[2,3,4]]",
        b"[[1],4]",
        b"",
        b"[9]",
        b"[[8,7,6]]",
        b"",
        b"[[4,4],4,4]",
        b"[[4,4],4,4,4]",
        b"",
        b"[7,7,7,7]",
        b"[7,7,7]",
        b"",
        b"[]",
        b"[3]",
        b"",
        b"[[[]]]",
        b"[[]]",
        b"",
        b"[1,[2,[3,[4,[5,6,7]]]],8,9]",
        b"[1,[2,[3,[4,[5,6,0]]]],8,9]",
    ];

    #[test]
    fun test1() {
        assert!(check_ordered(&TEST_INPUT) == 13, 0);
    }

    #[test]
    fun test2() {
        assert!(decoder_key(&TEST_INPUT) == 140, 0);
    }

    #[test]
    fun test_ordered() {
        assert!(ordered(
            &mut parse_list(&b"[1,1,3,1,1]"),
            &mut parse_list(&b"[1,1,5,1,1]")
        ) == C_LT, 0);
        assert!(ordered(
            &mut parse_list(&b"[[1],[2,3,4]]"),
            &mut parse_list(&b"[[1],4]")
        ) == C_LT, 0);
        assert!(ordered(
            &mut parse_list(&b"[9]"),
            &mut parse_list(&b"[[8,7,6]]")
        ) == C_GT, 0);
        assert!(ordered(
            &mut parse_list(&b"[[4,4],4,4]"),
            &mut parse_list(&b"[[4,4],4,4,4]")
        ) == C_LT, 0);
        assert!(ordered(
            &mut parse_list(&b"[7,7,7,7]"),
            &mut parse_list(&b"[7,7,7]")
        ) == C_GT, 0);
        assert!(ordered(
            &mut parse_list(&b"[]"),
            &mut parse_list(&b"[3]")
        ) == C_LT, 0);
        assert!(ordered(
            &mut parse_list(&b"[1,[2,[3,[4,[5,6,7]]]],8,9]"),
            &mut parse_list(&b"[1,[2,[3,[4,[5,6,0]]]],8,9]")
        ) == C_GT, 0);
        assert!(ordered(
            &mut parse_list(&b"[1,[2,[3,[4,[5,6,7]]]],8,9]"),
            &mut parse_list(&b"[1,[2,[3,[4,[5,6,7]]]],8,9]")
        ) == C_EQ, 0);
    }

    #[test]
    fun test_parse_list() {
        assert!(parse_list(&b"[1,2,3]") == vector[SEP,3,1,2,3], 0);
        assert!(parse_list(&b"[[1],2,3]") == vector[SEP,3,SEP,1,1,2,3], 0);
        assert!(parse_list(&b"[1,[2,[3]]]") == vector[SEP,2,1,SEP,2,2,SEP,1,3], 0);
        assert!(parse_list(&b"[1,[2,[3]],4]") == vector[SEP,3,1,SEP,2,2,SEP,1,3,4], 0);
        assert!(parse_list(&b"[]") == vector[SEP,0], 0);
    }

    #[test]
    fun test_next() {
        // [1,2,3] => ([1], [2,3])
        let rest = vector[SEP,3,1,2,3];
        let nxt = next(&mut rest);
        assert!(nxt == vector[1] && rest == vector[SEP,2,2,3], 0);
        // [2,3] => ([2], [3])
        let nxt = next(&mut rest);
        assert!(nxt == vector[2] && rest == vector[SEP,1,3], 0);
        // [3] => ([3], [])
        let nxt = next(&mut rest);
        assert!(nxt == vector[3] && rest == vector[], 0);

        // [[1],2,3] => ([[1]], [2,3])
        let rest = vector[SEP,3,SEP,1,1,2,3];
        let nxt = next(&mut rest);
        assert!(nxt == vector[SEP,1,1] && rest == vector[SEP,2,2,3], 0);
        // [[1]] => ([1], [])
        let rest = nxt;
        let nxt = next(&mut rest);
        assert!(nxt == vector[1] && rest == vector[], 0);

        // [1,[2,[3]]] => ([1], [[2,[3]]])
        let rest = vector[SEP,2,1,SEP,2,2,SEP,1,3];
        let nxt = next(&mut rest);
        assert!(nxt == vector[1] && rest == vector[SEP,1,SEP,2,2,SEP,1,3], 0);
        // [[2,[3]]] => ([2,[3]], [])
        let nxt = next(&mut rest);
        assert!(nxt == vector[SEP,2,2,SEP,1,3] && rest == vector[], 0);
        // [2,[3]] => ([2], [[3]])
        let rest = nxt;
        let nxt = next(&mut rest);
        assert!(nxt == vector[2] && rest == vector[SEP,1,SEP,1,3], 0);
        // [[3]] => ([3], [])
        let nxt = next(&mut rest);
        assert!(nxt == vector[SEP,1,3] && rest == vector[], 0);
        // [3] => ([3], [])
        let rest = nxt;
        let nxt = next(&mut rest);
        assert!(nxt == vector[3] && rest == vector[], 0);

        // [1,[2,[3]],4] => ([1], [[2,[3]],4])
        let rest = vector[SEP,3,1,SEP,2,2,SEP,1,3,4];
        let nxt = next(&mut rest);
        assert!(nxt == vector[1] && rest == vector[SEP,2,SEP,2,2,SEP,1,3,4], 0);
        // [[2,[3]],4] => ([2,[3]], [4])
        let nxt = next(&mut rest);
        assert!(nxt == vector[SEP,2,2,SEP,1,3] && rest == vector[SEP,1,4], 0);

        // [] => ([], [])
        let rest = vector[SEP,0];
        let nxt = next(&mut rest);
        assert!(nxt == vector[] && rest == vector[], 0);
    }
}
