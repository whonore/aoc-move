module aoc22::d09 {
    use std::debug;
    use std::vector;
    use extralib::math;
    use extralib::sparse;
    use extralib::string as estring;
    use extralib::vector as evector;

    spec module {
        pragma verify = false;
    }

    struct Input has key {
        input: vector<vector<u8>>
    }

    const ASCII_SPACE: u8 = 32;
    const ASCII_D: u8 = 68;
    const ASCII_L: u8 = 76;
    const ASCII_R: u8 = 82;
    const ASCII_U: u8 = 85;

    fun parse_move(move_: &vector<u8>): (u8, u64) {
        let parts = evector::split_by(move_, &ASCII_SPACE);
        let dir = *vector::borrow(move_, 0);
        let dist = estring::parse_u64(vector::borrow(&parts, 1));
        (dir, dist)
    }

    fun find_extent(moves: &vector<vector<u8>>): (u64, u64, u64, u64) {
        let nleft = 0;
        let nright = 0;
        let ndown = 0;
        let nup = 0;
        let nmoves = vector::length(moves);
        let i = 0;

        while (i < nmoves) {
            let (dir, dist) = parse_move(vector::borrow(moves, i));
            if (dir == ASCII_L) {
                nleft = nleft + dist;
            } else if (dir == ASCII_R) {
                nright = nright + dist;
            } else if (dir == ASCII_D) {
                ndown = ndown + dist;
            } else if (dir == ASCII_U) {
                nup = nup + dist;
            };
            i = i + 1;
        };
        (nleft, nright, ndown, nup)
    }

    fun move_tail(hx: u64, hy: u64, tx: u64, ty: u64): (u64, u64) {
        if (math::absdiff64(hx, tx) > 1 || math::absdiff64(hy, ty) > 1) {
            // Not touching
            if (hy == ty) {
                // Horizontal
                assert!(math::absdiff64(hx, tx) == 2, 0);
                (if (hx < tx) { tx - 1 } else { tx + 1 }, ty)
            } else if (hx == tx) {
                // Vertical
                assert!(math::absdiff64(hy, ty) == 2, 0);
                (tx, if (hy < ty) { ty - 1 } else { ty + 1 })
            } else {
                // Diagonal
                (
                    if (hx < tx) { tx - 1 } else { tx + 1 },
                    if (hy < ty) { ty - 1 } else { ty + 1 }
                )
            }
        } else {
            // Touching, no movement
            (tx, ty)
        }
    }

    fun count_visited(moves: &vector<vector<u8>>, nknots: u64): u64 {
        let nmoves = vector::length(moves);
        let i = 0;
        let (nleft, nright, ndown, nup) = find_extent(moves);
        let knots = evector::repeat(nknots, &vector[nleft, ndown]);
        let (width, height) = (nleft + nright + 1, ndown + nup + 1);
        let visited = sparse::new(width * height);
        let nvisited = 1;
        sparse::set(&mut visited, ndown * width + nleft, true);

        while (i < nmoves) {
            let (dir, dist) = parse_move(vector::borrow(moves, i));
            let j = 0;
            while (j < dist) {
                // Move the head
                let head = vector::borrow_mut(&mut knots, 0);
                let hx = *vector::borrow(head, 0);
                let hy = *vector::borrow(head, 1);
                if (dir == ASCII_L) {
                    *vector::borrow_mut(head, 0) = hx - 1;
                } else if (dir == ASCII_R) {
                    *vector::borrow_mut(head, 0) = hx + 1;
                } else if (dir == ASCII_D) {
                    *vector::borrow_mut(head, 1) = hy - 1;
                } else if (dir == ASCII_U) {
                    *vector::borrow_mut(head, 1) = hy + 1;
                };

                // Move the rest of the rope
                let k = 1;
                while (k < nknots) {
                    let prev = vector::borrow(&knots, k - 1);
                    let knot = vector::borrow(&knots, k);
                    let px = *vector::borrow(prev, 0);
                    let py = *vector::borrow(prev, 1);
                    let kx = *vector::borrow(knot, 0);
                    let ky = *vector::borrow(knot, 1);
                    let (x, y) = move_tail(px, py, kx, ky);
                    *vector::borrow_mut(vector::borrow_mut(&mut knots, k), 0) = x;
                    *vector::borrow_mut(vector::borrow_mut(&mut knots, k), 1) = y;

                    if (k == nknots - 1) {
                        let idx = y * width + x;
                        if (!sparse::is_set(&visited, idx)) {
                            nvisited = nvisited + 1;
                        };
                        sparse::set(&mut visited, idx, true);
                    };
                    k = k + 1;
                };
                j = j + 1;
            };
            i = i + 1;
        };
        nvisited
    }

    public entry fun run() acquires Input {
        let input = borrow_global<Input>(@0x0);
        debug::print(&count_visited(&input.input, 2));
        debug::print(&count_visited(&input.input, 10));
    }

    #[test_only]
    const TEST_INPUT1: vector<vector<u8>> = vector[
        b"R 4",
        b"U 4",
        b"L 3",
        b"D 1",
        b"R 4",
        b"D 1",
        b"L 5",
        b"R 2",
    ];

    #[test_only]
    const TEST_INPUT2: vector<vector<u8>> = vector[
        b"R 5",
        b"U 8",
        b"L 8",
        b"D 3",
        b"R 17",
        b"D 10",
        b"L 25",
        b"U 20",
    ];

    #[test]
    fun test1() {
        assert!(count_visited(&TEST_INPUT1, 2) == 13, 0);
    }

    #[test]
    fun test2() {
        assert!(count_visited(&TEST_INPUT1, 10) == 1, 0);
        assert!(count_visited(&TEST_INPUT2, 10) == 36, 0);
    }

    #[test]
    fun test_parse_move() {
        let (dir, dist) = parse_move(&b"L 2");
        assert!(dir == ASCII_L && dist == 2, 0);
        let (dir, dist) = parse_move(&b"R 4");
        assert!(dir == ASCII_R && dist == 4, 0);
        let (dir, dist) = parse_move(&b"U 7");
        assert!(dir == ASCII_U && dist == 7, 0);
        let (dir, dist) = parse_move(&b"D 1");
        assert!(dir == ASCII_D && dist == 1, 0);
        let (dir, dist) = parse_move(&b"D 10");
        assert!(dir == ASCII_D && dist == 10, 0);
    }

    #[test]
    fun test_find_extent() {
        let (nleft, nright, ndown, nup) = find_extent(&TEST_INPUT1);
        assert!(nleft == 8 && nright == 10 && ndown == 2 && nup == 4, 0);
    }

    #[test]
    fun test_move_tail() {
        let (tx, ty) = move_tail(2, 1, 1, 1);
        assert!(tx == 1 && ty == 1, 0);
        let (tx, ty) = move_tail(1, 2, 2, 1);
        assert!(tx == 2 && ty == 1, 0);
        let (tx, ty) = move_tail(1, 1, 1, 1);
        assert!(tx == 1 && ty == 1, 0);
        let (tx, ty) = move_tail(3, 1, 1, 1);
        assert!(tx == 2 && ty == 1, 0);
        let (tx, ty) = move_tail(1, 1, 1, 3);
        assert!(tx == 1 && ty == 2, 0);
        let (tx, ty) = move_tail(2, 3, 1, 1);
        assert!(tx == 2 && ty == 2, 0);
        let (tx, ty) = move_tail(3, 2, 1, 1);
        assert!(tx == 2 && ty == 2, 0);
    }
}
