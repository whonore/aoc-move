module aoc22::d12 {
    use std::debug;
    use std::vector;
    use extralib::hashmap::{Self, Map};
    use extralib::math;
    use extralib::vector as evector;

    spec module {
        pragma verify = false;
    }

    struct Input has key {
        input: vector<vector<u8>>
    }

    const ENOT_FOUND: u64 = 1;

    const ASCII_E: u8 = 69;
    const ASCII_S: u8 = 83;
    const ASCII_a: u8 = 97;
    const ASCII_z: u8 = 122;

    fun find(map: &vector<vector<u8>>, x: u8): (u64, u64) {
        let nrows = vector::length(map);
        let r = 0;
        while (r < nrows) {
            let row = vector::borrow(map, r);
            let ncols = vector::length(row);
            let c = 0;
            while (c < ncols) {
                if (*vector::borrow(row, c) == x) {
                    return (r, c)
                };
                c = c + 1;
            };
            r = r + 1;
        };
        abort ENOT_FOUND
    }

    fun can_step(from: u8, to: u8): bool {
        let from = if (from == ASCII_S) {
            ASCII_a
        } else if (from == ASCII_E) {
            ASCII_z
        } else {
            from
        };
        let to = if (to == ASCII_S) {
            ASCII_a
        } else if (to == ASCII_E) {
            ASCII_z
        } else {
            to
        };
        (to <= from || to - from <= 1)
    }

    fun neighbors(map: &vector<vector<u8>>, r: u64, c: u64): vector<vector<u64>> {
        let neighbors = vector[];
        let nrows = vector::length(map);
        let ncols = vector::length(vector::borrow(map, 0));
        // NOTE: `can_step()` takes `h` second, because these are the neighbors
        // that can step to this position, not from.
        let h = *vector::borrow(vector::borrow(map, r), c);
        // Left
        if (c > 0 && can_step(*vector::borrow(vector::borrow(map, r), c - 1), h)) {
            vector::push_back(&mut neighbors, vector[r, c - 1])
        };
        // Right
        if (c < ncols - 1 && can_step(*vector::borrow(vector::borrow(map, r), c + 1), h)) {
            vector::push_back(&mut neighbors, vector[r, c + 1])
        };
        // Up
        if (r > 0 && can_step(*vector::borrow(vector::borrow(map, r - 1), c), h)) {
            vector::push_back(&mut neighbors, vector[r - 1, c])
        };
        // Down
        if (r < nrows - 1 && can_step(*vector::borrow(vector::borrow(map, r + 1), c), h)) {
            vector::push_back(&mut neighbors, vector[r + 1, c])
        };
        neighbors
    }

    fun pop_nearest(
        dists: &Map<vector<u64>, u64>,
        unvisited: &mut vector<vector<u64>>
    ): vector<u64> {
        let nunvisited = vector::length(unvisited);
        let i = 1;
        let min = *hashmap::get(dists, vector::borrow(unvisited, 0));
        let minidx = 0;
        while (i < nunvisited) {
            let dist = *hashmap::get(dists, vector::borrow(unvisited, i));
            if (dist < min) {
                min = dist;
                minidx = i;
            };
            i = i + 1;
        };
        vector::swap_remove(unvisited, minidx)
    }

    fun explore(map: &vector<vector<u8>>): Map<vector<u64>, u64> {
        let (rend, cend) = find(map, ASCII_E);
        let visited = hashmap::new();
        let unvisited = vector[vector[rend, cend]];
        let dists = hashmap::new();
        let nrows = vector::length(map);
        let ncols = vector::length(vector::borrow(map, 0));
        let i = 0;
        while (i < nrows) {
            let j = 0;
            while (j < ncols) {
                hashmap::set(&mut dists, &vector[i, j], math::max_u64());
                j = j + 1;
            };
            i = i + 1;
        };
        hashmap::set(&mut dists, &vector[rend, cend], 0);

        while (!vector::is_empty(&mut unvisited)) {
            let nearest = pop_nearest(&mut dists, &mut unvisited);
            let dist = *hashmap::get(&mut dists, &nearest) + 1;
            let neighbors = neighbors(map, *vector::borrow(&nearest, 0), *vector::borrow(&nearest, 1));
            let nneighbors = vector::length(&neighbors);
            let i = 0;
            while (i < nneighbors) {
                let neighbor = vector::borrow(&neighbors, i);
                if (!hashmap::has_key(&visited, neighbor)) {
                    if (dist < *hashmap::get(&mut dists, neighbor)) {
                        hashmap::set(&mut dists, neighbor, dist);
                        vector::push_back(&mut unvisited, *neighbor);
                    };
                };
                i = i + 1;
            };
            hashmap::set(&mut visited, &nearest, true);
        };
        dists
    }

    fun find_shortest_path(map: &vector<vector<u8>>): u64 {
        let (rstart, cstart) = find(map, ASCII_S);
        let dists = explore(map);
        *hashmap::get(&dists, &vector[rstart, cstart])
    }

    fun find_best_starting(map: &vector<vector<u8>>): u64 {
        let dists = explore(map);
        let nrows = vector::length(map);
        let ncols = vector::length(vector::borrow(map, 0));
        let start_dists = vector[];
        let r = 0;
        while (r < nrows) {
            let c = 0;
            while (c < ncols) {
                if (*vector::borrow(vector::borrow(map, r), c) == ASCII_a) {
                    vector::push_back(&mut start_dists, *hashmap::get(&dists, &vector[r, c]))
                };
                c = c + 1;
            };
            r = r + 1;
        };
        let (_, min) = evector::min64(&start_dists);
        min
    }

    public entry fun run() acquires Input {
        let input = borrow_global<Input>(@0x0);
        debug::print(&find_shortest_path(&input.input));
        debug::print(&find_best_starting(&input.input));
    }

    #[test_only]
    const TEST_INPUT: vector<vector<u8>> = vector[
        b"Sabqponm",
        b"abcryxxl",
        b"accszExk",
        b"acctuvwj",
        b"abdefghi",
    ];

    #[test]
    fun test1() {
        assert!(find_shortest_path(&TEST_INPUT) == 31, 0);
    }

    #[test]
    fun test2() {
        assert!(find_best_starting(&TEST_INPUT) == 29, 0);
    }

    #[test]
    fun test_neighbors() {
        assert!(neighbors(&TEST_INPUT, 2, 5) == vector[vector[2, 4]], 0);
        assert!(neighbors(&TEST_INPUT, 2, 4) == vector[vector[2, 5], vector[1, 4]], 0);
    }

    #[test]
    fun test_find() {
        let (r, c) = find(&TEST_INPUT, ASCII_S);
        assert!(r == 0 && c == 0, 0);
        let (r, c) = find(&TEST_INPUT, ASCII_E);
        assert!(r == 2 && c == 5, 0);
    }
}
