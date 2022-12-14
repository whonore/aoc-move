module aoc22::d14 {
    use std::debug;
    use std::vector;
    use extralib::hashmap::{Self, Map};
    use extralib::math;
    use extralib::string as estring;
    use extralib::vector as evector;

    spec module {
        pragma verify = false;
    }

    struct Input has key {
        input: vector<vector<u8>>
    }

    const EUNREACHABLE: u64 = 1;

    const ASCII_SPACE: u8 = 32;
    const ASCII_COMMA: u8 = 44;

    const SAND_C: u64 = 500;

    const ROCK: u8 = 1;
    const SAND: u8 = 2;

    fun interpolate(lines: &vector<vector<u64>>): vector<vector<u64>> {
        let coords = vector[];
        let nlines = vector::length(lines);
        let i = 1;
        while (i < nlines) {
            let prev = vector::borrow(lines, i - 1);
            let cur = vector::borrow(lines, i);
            let r = *vector::borrow(prev, 0);
            let c = *vector::borrow(prev, 1);
            let rmax = *vector::borrow(cur, 0);
            let cmax = *vector::borrow(cur, 1);
            assert!(r == rmax || c == cmax, 0);
            while (r != rmax || c != cmax) {
                vector::push_back(&mut coords, vector[r, c]);
                if (r < rmax) {
                    r = r + 1;
                } else if (r > rmax) {
                    r = r - 1;
                } else if (c < cmax) {
                    c = c + 1;
                } else if (c > cmax) {
                    c = c - 1;
                };
            };
            i = i + 1;
        };
        vector::push_back(&mut coords, *evector::last(lines));
        coords
    }

    fun parse_rock(rock: &vector<u8>): vector<vector<u64>> {
        let coords = vector[];
        let parts = evector::split_by(rock, &ASCII_SPACE);
        let nparts = vector::length(&parts);
        let i = 0;
        while (i < nparts) {
            let coord = evector::split_by(vector::borrow(&parts, i), &ASCII_COMMA);
            let c = estring::parse_u64(vector::borrow(&coord, 0));
            let r = estring::parse_u64(vector::borrow(&coord, 1));
            vector::push_back(&mut coords, vector[r, c]);
            i = i + 2; // Skip ->
        };
        coords
    }

    fun parse_map(paths: &vector<vector<u8>>): (Map<vector<u64>, u8>, u64) {
        let rmax = 0;
        let map = hashmap::new();
        let npaths = vector::length(paths);
        let i = 0;
        while (i < npaths) {
            let lines = parse_rock(vector::borrow(paths, i));
            let coords = interpolate(&lines);
            let ncoords = vector::length(&coords);
            let j = 0;
            while (j < ncoords) {
                let coord = vector::borrow(&coords, j);
                let r = *vector::borrow(coord, 0);
                let c = *vector::borrow(coord, 1);
                hashmap::set(&mut map, &vector[r, c], ROCK);
                rmax = math::max64(rmax, r);
                j = j + 1;
            };
            i = i + 1;
        };
        (map, rmax + 1)
    }

    fun simulate(map: &mut Map<vector<u64>, u8>, rvoid: u64): bool {
        let (rsand, csand) = (0, SAND_C);
        while (rsand < rvoid) {
            if (!hashmap::has_key(map, &vector[rsand + 1, csand])) {
                // Down
                rsand = rsand + 1;
            } else if (!hashmap::has_key(map, &vector[rsand + 1, csand - 1])) {
                // Down-left
                rsand = rsand + 1;
                csand = csand - 1;
            } else if (!hashmap::has_key(map, &vector[rsand + 1, csand + 1])) {
                // Down-right
                rsand = rsand + 1;
                csand = csand + 1;
            } else {
                // At rest
                hashmap::set(map, &vector[rsand, csand], SAND);
                return true
            };
        };
        false
    }

    fun simulate_with_floor(map: &mut Map<vector<u64>, u8>, rfloor: u64): bool {
        let (rsand, csand) = (0, SAND_C);
        while (rsand < rfloor) {
            let at_floor = rsand + 1 == rfloor;
            if (!at_floor && !hashmap::has_key(map, &vector[rsand + 1, csand])) {
                // Down
                rsand = rsand + 1;
            } else if (!at_floor && !hashmap::has_key(map, &vector[rsand + 1, csand - 1])) {
                // Down-left
                rsand = rsand + 1;
                csand = csand - 1;
            } else if (!at_floor && !hashmap::has_key(map, &vector[rsand + 1, csand + 1])) {
                // Down-left
                rsand = rsand + 1;
                csand = csand + 1;
            } else {
                hashmap::set(map, &vector[rsand, csand], SAND);
                return !(rsand == 0 && csand == SAND_C)
            };
        };
        abort EUNREACHABLE
    }

    fun count_sand(paths: &vector<vector<u8>>): u64 {
        let nsand = 0;
        let (map, rvoid) = parse_map(paths);
        while (simulate(&mut map, rvoid)) {
            nsand = nsand + 1;
        };
        nsand
    }

    fun count_sand_with_floor(paths: &vector<vector<u8>>): u64 {
        let nsand = 0;
        let (map, rvoid) = parse_map(paths);
        while (simulate_with_floor(&mut map, rvoid + 1)) {
            nsand = nsand + 1;
        };
        nsand + 1
    }

    public entry fun run() acquires Input {
        let input = borrow_global<Input>(@0x0);
        debug::print(&count_sand(&input.input));
        debug::print(&count_sand_with_floor(&input.input));
    }

    #[test_only]
    const TEST_INPUT: vector<vector<u8>> = vector[
        b"498,4 -> 498,6 -> 496,6",
        b"503,4 -> 502,4 -> 502,9 -> 494,9",
    ];

    #[test]
    fun test1() {
        assert!(count_sand(&TEST_INPUT) == 24, 0);
    }

    #[test]
    fun test2() {
        assert!(count_sand_with_floor(&TEST_INPUT) == 93, 0);
    }

    #[test]
    fun test_parse_rock() {
        assert!(parse_rock(&b"498,4 -> 498,6 -> 496,6") == vector[
            vector[4,498], vector[6,498], vector[6,496]
        ], 0);
        assert!(parse_rock(&b"503,4 -> 502,4 -> 502,9 -> 494,9") == vector[
            vector[4,503], vector[4,502], vector[9,502], vector[9,494]
        ], 0);
    }

    #[test]
    fun test_interpolate() {
        assert!(interpolate(&vector[vector[4,498],vector[6,498],vector[6,496]]) == vector[
            vector[4,498], vector[5,498], vector[6,498], vector[6,497], vector[6,496],
        ], 0);
        assert!(interpolate(&vector[vector[4,503],vector[4,502],vector[9,502],vector[9,494]]) == vector[
            vector[4,503], vector[4,502], vector[5,502], vector[6,502], vector[7,502],
            vector[8,502], vector[9,502], vector[9,501], vector[9,500], vector[9,499],
            vector[9,498], vector[9,497], vector[9,496], vector[9,495], vector[9,494],
        ], 0);
    }
}
