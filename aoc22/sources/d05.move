module aoc22::d05 {
    use std::debug;
    use std::string;
    use std::vector;
    use extralib::vector as evector;

    struct Input has key {
        input: vector<vector<u8>>
    }

    fun parse_instructions(instructions: &vector<vector<u8>>): (vector<vector<u8>>, vector<vector<u8>>) {
        let ncrates = (*vector::borrow(vector::borrow(instructions, 0), 0) as u64);
        let (crates, moves) = evector::split_at(instructions, ncrates + 1);
        vector::remove(&mut crates, 0);

        // Reverse columns for use as a stack
        let i = 0;
        while (i < ncrates) {
            vector::reverse(vector::borrow_mut(&mut crates, i));
            i = i + 1;
        };

        (crates, moves)
    }

    fun do_move(crates: &mut vector<vector<u8>>, move_: &vector<u8>) {
        let n = (*vector::borrow(move_, 0) as u64);
        let from = (*vector::borrow(move_, 1) - 1 as u64);
        let to = (*vector::borrow(move_, 2) - 1 as u64);
        let i = 0;

        while (i < n) {
            let crate = vector::pop_back(vector::borrow_mut(crates, from));
            vector::push_back(vector::borrow_mut(crates, to), crate);
            i = i + 1;
        };
    }

    fun do_move2(crates: &mut vector<vector<u8>>, move_: &vector<u8>) {
        let n = (*vector::borrow(move_, 0) as u64);
        let from = (*vector::borrow(move_, 1) - 1 as u64);
        let to = (*vector::borrow(move_, 2) - 1 as u64);
        let i = 0;
        let tmp = vector[];

        while (i < n) {
            let crate = vector::pop_back(vector::borrow_mut(crates, from));
            vector::push_back(&mut tmp, crate);
            i = i + 1;
        };
        vector::reverse(&mut tmp);
        vector::append(vector::borrow_mut(crates, to), tmp);
    }

    fun run_crates(crates: &mut vector<vector<u8>>, moves: &vector<vector<u8>>) {
        let i = 0;
        let nmoves = vector::length(moves);
        while (i < nmoves) {
            do_move(crates, vector::borrow(moves, i));
            i = i + 1;
        }
    }

    fun run_crates2(crates: &mut vector<vector<u8>>, moves: &vector<vector<u8>>) {
        let i = 0;
        let nmoves = vector::length(moves);
        while (i < nmoves) {
            do_move2(crates, vector::borrow(moves, i));
            i = i + 1;
        }
    }

    fun tops(crates: &mut vector<vector<u8>>): vector<u8> {
        let top = vector[];
        let i = 0;
        let len = vector::length(crates);
        while (i < len) {
            vector::push_back(
                &mut top,
                vector::pop_back(vector::borrow_mut(crates, i))
            );
            i = i + 1;
        };
        top
    }

    fun top_crates(instructions: &vector<vector<u8>>): vector<u8> {
        let (crates, moves) = parse_instructions(instructions);
        run_crates(&mut crates, &moves);
        tops(&mut crates)
    }

    fun top_crates2(instructions: &vector<vector<u8>>): vector<u8> {
        let (crates, moves) = parse_instructions(instructions);
        run_crates2(&mut crates, &moves);
        tops(&mut crates)
    }

    public entry fun run() acquires Input {
        let input = borrow_global<Input>(@0x0);
        debug::print(&string::utf8(top_crates(&input.input)));
        debug::print(&string::utf8(top_crates2(&input.input)));
    }

    #[test_only]
    const TEST_INPUT: vector<vector<u8>> = vector[
        vector[3],
        b"NZ",
        b"DCM",
        b"P",
        vector[1,2,1],
        vector[3,1,3],
        vector[2,2,1],
        vector[1,1,2],
    ];

    #[test]
    fun test1() {
        assert!(top_crates(&TEST_INPUT) == b"CMZ", 0);
    }

    #[test]
    fun test2() {
        assert!(top_crates2(&TEST_INPUT) == b"MCD", 0);
    }

    #[test]
    fun test_do_move() {
        let crates = vector[b"CBA", b"FED"];
        do_move(&mut crates, &vector[1,1,2]);
        assert!(crates == vector[b"CB", b"FEDA"], 0);
        do_move(&mut crates, &vector[2,2,1]);
        assert!(crates == vector[b"CBAD", b"FE"], 0);
    }

    #[test]
    fun test_do_move2() {
        let crates = vector[b"CBA", b"FED"];
        do_move2(&mut crates, &vector[1,1,2]);
        assert!(crates == vector[b"CB", b"FEDA"], 0);
        do_move2(&mut crates, &vector[2,2,1]);
        assert!(crates == vector[b"CBDA", b"FE"], 0);
    }
}
