module aoc22::d10 {
    use std::debug;
    use std::option::{Self, Option};
    use std::string;
    use std::vector;
    use extralib::signed64::{Self, Signed64};
    use extralib::vector as evector;

    spec module {
        pragma verify = false;
    }

    struct Input has key {
        input: vector<vector<u8>>
    }

    const E_INVALID_INSTR: u64 = 1;

    const ASCII_SPACE: u8 = 32;
    const ASCII_POUND: u8 = 35;
    const ASCII_DOT: u8 = 46;

    const I_NOOP: u8 = 0;
    const I_ADDX: u8 = 1;

    const CYCLE_START: u64 = 20;
    const CYCLE_PERIOD: u64 = 40;

    fun parse_instruction(instr: &vector<u8>): (u8, Option<Signed64>) {
        let parts = evector::split_by(instr, &ASCII_SPACE);
        let op = vector::borrow(&parts, 0);
        let opcode = if (op == &b"noop") {
            I_NOOP
        } else if (op == &b"addx") {
            I_ADDX
        } else {
            abort E_INVALID_INSTR
        };
        let amt = option::none();
        if (opcode == I_ADDX) {
            let num = vector::borrow(&parts, 1);
            amt = option::some(signed64::parse(num));
        };
        (opcode, amt)
    }

    fun sum_signals(instrs: &vector<vector<u8>>): u128 {
        let ninstrs = vector::length(instrs);
        let i = 0;
        let cycle = 1;
        let reg_X = signed64::pos(1);
        let signals = vector[];

        while (i < ninstrs) {
            let (opcode, amt) = parse_instruction(vector::borrow(instrs, i));
            let ncycles = if (opcode == I_NOOP) { 1 } else { 2 };
            while (ncycles > 0) {
                if (cycle % CYCLE_PERIOD == CYCLE_START) {
                    vector::push_back(&mut signals, cycle * signed64::abs(&reg_X));
                };
                cycle = cycle + 1;
                ncycles = ncycles - 1;
            };
            if (opcode == I_ADDX) {
                reg_X = signed64::add(&reg_X, option::borrow(&amt));
            };
            i = i + 1;
        };
        evector::sum64(&signals)
    }

    fun draw(instrs: &vector<vector<u8>>): vector<vector<u8>> {
        let ninstrs = vector::length(instrs);
        let i = 0;
        let cycle = 0;
        let reg_X = signed64::pos(1);
        let sprite = vector[signed64::pos(0), signed64::pos(1), signed64::pos(2)];
        let img = vector[];

        while (i < ninstrs) {
            let (opcode, amt) = parse_instruction(vector::borrow(instrs, i));
            let ncycles = if (opcode == I_NOOP) { 1 } else { 2 };
            while (ncycles > 0) {
                if (cycle % CYCLE_PERIOD == 0) {
                    vector::push_back(&mut img, evector::repeat(CYCLE_PERIOD, &ASCII_DOT));
                };
                let pixel = cycle % CYCLE_PERIOD;
                if (vector::contains(&sprite, &signed64::pos(pixel))) {
                    *vector::borrow_mut(evector::last_mut(&mut img), pixel) = ASCII_POUND;
                };
                cycle = cycle + 1;
                ncycles = ncycles - 1;
            };
            if (opcode == I_ADDX) {
                reg_X = signed64::add(&reg_X, option::borrow(&amt));
                *vector::borrow_mut(&mut sprite, 0) = signed64::sub(&reg_X, &signed64::pos(1));
                *vector::borrow_mut(&mut sprite, 1) = reg_X;
                *vector::borrow_mut(&mut sprite, 2) = signed64::add(&reg_X, &signed64::pos(1));
            };
            i = i + 1;
        };
        img
    }

    public entry fun run() acquires Input {
        let input = borrow_global<Input>(@0x0);
        debug::print(&sum_signals(&input.input));
        let img = draw(&input.input);
        let nlines = vector::length(&img);
        let i = 0;
        while (i < nlines) {
            debug::print(&string::utf8(*vector::borrow(&img, i)));
            i = i + 1;
        }
    }

    #[test_only]
    const TEST_INPUT: vector<vector<u8>> = vector[
        b"addx 15",
        b"addx -11",
        b"addx 6",
        b"addx -3",
        b"addx 5",
        b"addx -1",
        b"addx -8",
        b"addx 13",
        b"addx 4",
        b"noop",
        b"addx -1",
        b"addx 5",
        b"addx -1",
        b"addx 5",
        b"addx -1",
        b"addx 5",
        b"addx -1",
        b"addx 5",
        b"addx -1",
        b"addx -35",
        b"addx 1",
        b"addx 24",
        b"addx -19",
        b"addx 1",
        b"addx 16",
        b"addx -11",
        b"noop",
        b"noop",
        b"addx 21",
        b"addx -15",
        b"noop",
        b"noop",
        b"addx -3",
        b"addx 9",
        b"addx 1",
        b"addx -3",
        b"addx 8",
        b"addx 1",
        b"addx 5",
        b"noop",
        b"noop",
        b"noop",
        b"noop",
        b"noop",
        b"addx -36",
        b"noop",
        b"addx 1",
        b"addx 7",
        b"noop",
        b"noop",
        b"noop",
        b"addx 2",
        b"addx 6",
        b"noop",
        b"noop",
        b"noop",
        b"noop",
        b"noop",
        b"addx 1",
        b"noop",
        b"noop",
        b"addx 7",
        b"addx 1",
        b"noop",
        b"addx -13",
        b"addx 13",
        b"addx 7",
        b"noop",
        b"addx 1",
        b"addx -33",
        b"noop",
        b"noop",
        b"noop",
        b"addx 2",
        b"noop",
        b"noop",
        b"noop",
        b"addx 8",
        b"noop",
        b"addx -1",
        b"addx 2",
        b"addx 1",
        b"noop",
        b"addx 17",
        b"addx -9",
        b"addx 1",
        b"addx 1",
        b"addx -3",
        b"addx 11",
        b"noop",
        b"noop",
        b"addx 1",
        b"noop",
        b"addx 1",
        b"noop",
        b"noop",
        b"addx -13",
        b"addx -19",
        b"addx 1",
        b"addx 3",
        b"addx 26",
        b"addx -30",
        b"addx 12",
        b"addx -1",
        b"addx 3",
        b"addx 1",
        b"noop",
        b"noop",
        b"noop",
        b"addx -9",
        b"addx 18",
        b"addx 1",
        b"addx 2",
        b"noop",
        b"noop",
        b"addx 9",
        b"noop",
        b"noop",
        b"noop",
        b"addx -1",
        b"addx 2",
        b"addx -37",
        b"addx 1",
        b"addx 3",
        b"noop",
        b"addx 15",
        b"addx -21",
        b"addx 22",
        b"addx -6",
        b"addx 1",
        b"noop",
        b"addx 2",
        b"addx 1",
        b"noop",
        b"addx -10",
        b"noop",
        b"noop",
        b"addx 20",
        b"addx 1",
        b"addx 2",
        b"addx 2",
        b"addx -6",
        b"addx -11",
        b"noop",
        b"noop",
        b"noop",
    ];

    #[test]
    fun test1() {
        assert!(sum_signals(&TEST_INPUT) == 13140, 0);
    }

    #[test]
    fun test2() {
        let img = vector[
            b"##..##..##..##..##..##..##..##..##..##..",
            b"###...###...###...###...###...###...###.",
            b"####....####....####....####....####....",
            b"#####.....#####.....#####.....#####.....",
            b"######......######......######......####",
            b"#######.......#######.......#######.....",
        ];
        assert!(draw(&TEST_INPUT) == img, 0);
    }

    #[test]
    fun test_parse_instruction() {
        let (opcode, amt) = parse_instruction(&b"noop");
        assert!(opcode == I_NOOP && amt == option::none(), 0);
        let (opcode, amt) = parse_instruction(&b"addx 4");
        assert!(opcode == I_ADDX && amt == option::some(signed64::pos(4)), 0);
        let (opcode, amt) = parse_instruction(&b"addx -10");
        assert!(opcode == I_ADDX && amt == option::some(signed64::neg(10)), 0);
    }
}
