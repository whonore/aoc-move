module aoc22::d08 {
    use std::debug;
    use std::vector;
    use extralib::math;
    use extralib::vector as evector;

    spec module {
        pragma verify = false;
    }

    struct Input has key {
        input: vector<vector<u8>>
    }

    fun is_visible(trees: &vector<vector<u8>>, treesT: &vector<vector<u8>>, r: u64, c: u64): bool {
        let rmax = vector::length(trees);
        let cmax = vector::length(treesT);
        if (r == 0 || r == rmax - 1 || c == 0 || c == cmax - 1) {
            true
        } else {
            let row = vector::borrow(trees, r);
            let col = vector::borrow(treesT, c);
            // From left
            let (_, maxl) = evector::max8_in(row, 0, c);
            if (maxl < *vector::borrow(vector::borrow(trees, r), c)) { return true };
            // From right
            let (_, maxr) = evector::max8_in(row, c + 1, cmax);
            if (maxr < *vector::borrow(vector::borrow(trees, r), c)) { return true };
            // From top
            let (_, maxt) = evector::max8_in(col, 0, r);
            if (maxt < *vector::borrow(vector::borrow(trees, r), c)) { return true };
            // From bottom
            let (_, maxb) = evector::max8_in(col, r + 1, rmax);
            if (maxb < *vector::borrow(vector::borrow(trees, r), c)) { return true };
            false
        }
    }

    fun find_ge(v: &vector<u8>, start: u64, rev: bool): u64 {
        let len = vector::length(v);
        if ((!rev && start == len - 1) || (rev && start == 0)) { return start };
        let i = if (!rev) { start + 1 } else { start - 1 };
        let x = *vector::borrow(v, start);

        while ((!rev && i < len) || (rev && i > 0)) {
            let y = *vector::borrow(v, i);
            if (y >= x) {
                return i
            };
            i = if (!rev) { i + 1 } else { i - 1 };
        };
        if (!rev) { len - 1 } else { 0 }
    }

    fun scenic_score(trees: &vector<vector<u8>>, treesT: &vector<vector<u8>>, r: u64, c: u64): u64 {
        let row = vector::borrow(trees, r);
        let col = vector::borrow(treesT, c);

        let lview_idx = find_ge(row, c, true);
        let rview_idx = find_ge(row, c, false);
        let tview_idx = find_ge(col, r, true);
        let bview_idx = find_ge(col, r, false);

        math::absdiff64(lview_idx, c)
        * math::absdiff64(rview_idx, c)
        * math::absdiff64(tview_idx, r)
        * math::absdiff64(bview_idx, r)
    }

    fun count_visible(trees: &vector<vector<u8>>): u64 {
        let treesT = evector::transpose(trees);
        let rmax = vector::length(trees);
        let cmax = vector::length(&treesT);
        let cnt = 0;
        let r = 0;

        while (r < rmax) {
            let c = 0;
            while (c < cmax) {
                cnt = cnt + if (is_visible(trees, &treesT, r, c)) { 1 } else { 0 };
                c = c + 1
            };
            r = r + 1;
        };
        cnt
    }

    fun find_scenic(trees: &vector<vector<u8>>): u64 {
        let treesT = evector::transpose(trees);
        let rmax = vector::length(trees);
        let cmax = vector::length(&treesT);
        let scores = vector[];
        let r = 0;

        while (r < rmax) {
            let c = 0;
            while (c < cmax) {
                vector::push_back(&mut scores, scenic_score(trees, &treesT, r, c));
                c = c + 1
            };
            r = r + 1;
        };
        let (_, max_score) = evector::max64(&scores);
        max_score
    }

    public entry fun run() acquires Input {
        let input = borrow_global<Input>(@0x0);
        debug::print(&count_visible(&input.input));
        debug::print(&find_scenic(&input.input));
    }

    #[test_only]
    const TEST_INPUT: vector<vector<u8>> = vector[
        vector[3,0,3,7,3],
        vector[2,5,5,1,2],
        vector[6,5,3,3,2],
        vector[3,3,5,4,9],
        vector[3,5,3,9,0],
    ];

    #[test]
    fun test1() {
        assert!(count_visible(&TEST_INPUT) == 21, 0);
    }

    #[test]
    fun test2() {
        assert!(find_scenic(&TEST_INPUT) == 8, 0);
    }
}
