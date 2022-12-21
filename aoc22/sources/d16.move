module aoc22::d16 {
    use std::debug;
    use std::vector;
    use extralib::math;
    use extralib::pair;
    use extralib::string as estring;
    use extralib::vector as evector;

    spec module {
        pragma verify = false;
    }

    struct Input has key {
        input: vector<vector<u8>>
    }

    struct Room has copy, drop {
        name: vector<u8>,
        rate: u64,
        tunnels: vector<vector<u8>>,
    }

    const EROOM_NOT_FOUND: u64 = 1;

    const ASCII_SPACE: u8 = 32;
    const ASCII_COMMA: u8 = 44;
    const ASCII_EQ: u8 = 61;

    fun parse_rate(rate: &vector<u8>): u64 {
        let parts = evector::split_by(rate, &ASCII_EQ);
        let rate = vector::borrow(&mut parts, 1);
        // Ignore trailing ;
        estring::parse_u64_in(rate, 0, vector::length(rate) - 1)
    }

    fun parse_tunnels(parts: &vector<vector<u8>>): vector<vector<u8>> {
        let tunnels = vector[];
        let nparts = vector::length(parts);
        let i = 9;
        while (i < nparts) {
            let tunnel = *vector::borrow(parts, i);
            // Remove trailing ,
            if (i != nparts - 1) {
                vector::pop_back(&mut tunnel);
            };
            vector::push_back(&mut tunnels, tunnel);
            i = i + 1
        };
        tunnels
    }

    fun parse_room(line: &vector<u8>): Room {
        let parts = evector::split_by(line, &ASCII_SPACE);
        let name = *vector::borrow(&parts, 1);
        let rate = parse_rate(vector::borrow(&parts, 4));
        let tunnels = parse_tunnels(&parts);
        Room { name, rate, tunnels }
    }

    fun parse_graph(lines: &vector<vector<u8>>): vector<Room> {
        let rooms = vector[];
        let nrooms = vector::length(lines);
        let i = 0;
        while (i < nrooms) {
            vector::push_back(&mut rooms, parse_room(vector::borrow(lines, i)));
            i = i + 1;
        };
        rooms
    }

    fun find_room(rooms: &vector<Room>, name: &vector<u8>): u64 {
        let nrooms = vector::length(rooms);
        let i = 0;
        while (i < nrooms) {
            if (&vector::borrow(rooms, i).name == name) {
                return i
            };
            i = i + 1;
        };
        abort EROOM_NOT_FOUND
    }

    fun compute_dists(rooms: &vector<Room>): vector<vector<u64>> {
        let dists = vector[];
        let nrooms = vector::length(rooms);

        let i = 0;
        while (i < nrooms) {
            let room_i = vector::borrow(rooms, i);
            vector::push_back(&mut dists, vector[]);
            let j = 0;
            while (j < nrooms) {
                let room_j = vector::borrow(rooms, j);
                let dist = if (room_i == room_j) {
                    // Self-dist = 0
                    0
                } else if (vector::contains(&room_i.tunnels, &room_j.name)) {
                    // Neighbor-dist = 1
                    1
                } else {
                    // Other = inf
                    math::max_u64()
                };
                vector::push_back(evector::last_mut(&mut dists), dist);
                j = j + 1;
            };
            i = i + 1;
        };


        let k = 0;
        while (k < nrooms) {
            let i = 0;
            while (i < nrooms) {
                let j = 0;
                while (j < nrooms) {
                    let dist_ij = *vector::borrow(vector::borrow(&dists, i), j);
                    let dist_ik = *vector::borrow(vector::borrow(&dists, i), k);
                    let dist_kj = *vector::borrow(vector::borrow(&dists, k), j);
                    if (dist_ik != math::max_u64()
                        && dist_kj != math::max_u64()
                        && dist_ij > dist_ik + dist_kj) {
                        *vector::borrow_mut(vector::borrow_mut(&mut dists, i), j) = dist_ik + dist_kj;
                    };
                    j = j + 1;
                };
                i = i + 1;
            };
            k = k + 1;
        };
        dists
    }

    fun compute_released(
        rooms: &vector<Room>,
        dists: &vector<vector<u64>>,
        path: &vector<u64>,
        remaining: u64,
    ): u64 {
        let p = 0;
        let nrooms = vector::length(path);
        let i = 0;
        while (i < nrooms) {
            let room_idx = *vector::borrow(path, i);
            let room = vector::borrow(rooms, room_idx);
            if (room.rate != 0) {
                remaining = remaining - 1;
                p = p + room.rate * remaining;
            };
            if (i < nrooms - 1) {
                let next_idx = *vector::borrow(path, i + 1);
                let dist = *vector::borrow(vector::borrow(dists, room_idx), next_idx);
                remaining = remaining - dist;
            };
            i = i + 1;
        };
        p
    }

    fun find_max_path(
        rooms: &vector<Room>,
        dists: &vector<vector<u64>>,
        visited: &mut vector<u64>,
        start_idx: u64,
        remaining: u64,
    ): vector<vector<u64>> {
        let sroom = vector::borrow(rooms, start_idx);
        if (sroom.rate != 0) {
            remaining = remaining - 1;
        };

        let paths = vector[];
        let nrooms = vector::length(rooms);
        let i = 0;
        vector::push_back(visited, start_idx);
        while (i < nrooms) {
            let next = vector::borrow(rooms, i);
            if (next.rate != 0 && !vector::contains(visited, &i)) {
                let dist = *vector::borrow(vector::borrow(dists, start_idx), i);
                // No point in visiting if can't open valve
                if (remaining >= dist + 2) {
                    vector::append(&mut paths, find_max_path(
                        rooms,
                        dists,
                        visited,
                        i,
                        remaining - dist
                    ));
                };
            };
            i = i + 1;
        };
        vector::push_back(&mut paths, *visited);
        vector::pop_back(visited);
        paths
    }

    fun max_pressure(lines: &vector<vector<u8>>, mins: u64): u64 {
        let rooms = parse_graph(lines);
        let dists = compute_dists(&rooms);
        let paths = find_max_path(
            &rooms,
            &dists,
            &mut vector[],
            find_room(&rooms, &b"AA"),
            mins
        );

        let maxp = 0;
        let npaths = vector::length(&paths);
        let i = 0;
        while (i < npaths) {
            let p = compute_released(&rooms, &dists, vector::borrow(&paths, i), mins);
            maxp = math::max64(maxp, p);
            i = i + 1;
        };
        maxp
    }

    fun max_pressure2(lines: &vector<vector<u8>>, mins: u64): u64 {
        let rooms = parse_graph(lines);
        let dists = compute_dists(&rooms);
        let paths = find_max_path(
            &rooms,
            &dists,
            &mut vector[],
            find_room(&rooms, &b"AA"),
            mins
        );

        let best_paths = vector[];
        let npaths = vector::length(&paths);
        let i = 0;
        while (i < npaths) {
            let path = vector::borrow(&paths, i);
            let p = compute_released(&rooms, &dists, path, mins);
            let path_perm = *path;
            vector::swap_remove(&mut path_perm, 0); // Ignore AA
            evector::sort64(&mut path_perm);

            let nbest = vector::length(&best_paths);
            let j = 0;
            let found = false;
            while (j < nbest && !found) {
                let best_path = pair::fst(vector::borrow(&best_paths, j));
                let bestp = *pair::snd(vector::borrow(&best_paths, j));
                if (&path_perm == best_path) {
                    found = true;
                    if (p > bestp) {
                        *vector::borrow_mut(&mut best_paths, j) = pair::new(path_perm, p);
                    };
                };
                j = j + 1;
            };
            if (!found) {
                vector::push_back(&mut best_paths, pair::new(path_perm, p));
            };
            i = i + 1;
        };

        let maxp = 0;
        let nbest = vector::length(&best_paths);
        let i = 0;
        while (i < nbest) {
            let path1 = pair::fst(vector::borrow(&best_paths, i));
            let p1 = *pair::snd(vector::borrow(&best_paths, i));
            let j = i + 1;
            while (j < nbest) {
                let path2 = pair::fst(vector::borrow(&best_paths, j));
                let p2 = *pair::snd(vector::borrow(&best_paths, j));
                if (evector::disjoint(path1, path2)) {
                    maxp = math::max64(maxp, p1 + p2);
                };
                j = j + 1;
            };
            i = i + 1;
        };
        maxp
    }

    public entry fun run() acquires Input {
        let input = borrow_global<Input>(@0x0);
        debug::print(&max_pressure(&input.input, 30));
        debug::print(&max_pressure2(&input.input, 26));
    }

    #[test_only]
    const TEST_INPUT: vector<vector<u8>> = vector[
        b"Valve AA has flow rate=0; tunnels lead to valves DD, II, BB",
        b"Valve BB has flow rate=13; tunnels lead to valves CC, AA",
        b"Valve CC has flow rate=2; tunnels lead to valves DD, BB",
        b"Valve DD has flow rate=20; tunnels lead to valves CC, AA, EE",
        b"Valve EE has flow rate=3; tunnels lead to valves FF, DD",
        b"Valve FF has flow rate=0; tunnels lead to valves EE, GG",
        b"Valve GG has flow rate=0; tunnels lead to valves FF, HH",
        b"Valve HH has flow rate=22; tunnel leads to valve GG",
        b"Valve II has flow rate=0; tunnels lead to valves AA, JJ",
        b"Valve JJ has flow rate=21; tunnel leads to valve II",
    ];

    #[test]
    fun test1() {
        assert!(max_pressure(&TEST_INPUT, 30) == 1651, 0);
    }

    #[test]
    fun test2() {
        assert!(max_pressure2(&TEST_INPUT, 26) == 1707, 0);
    }

    #[test]
    fun test_parse_room() {
        let room = parse_room(&b"Valve AA has flow rate=0; tunnels lead to valves DD, II, BB");
        assert!(room == Room { name: b"AA", rate: 0, tunnels: vector[b"DD", b"II", b"BB"] }, 0);
    }
}
