module aoc22::d11 {
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

    const E_INVALID_INSTR: u64 = 1;

    const ASCII_SPACE: u8 = 32;

    const O_ADD: u8 = 0;
    const O_MUL: u8 = 1;
    const O_SQR: u8 = 2;

    struct Monkey has copy, drop {
        items: vector<u64>,
        opcode: u8,
        opval: u64,
        test: u64,
        iftrue: u64,
        iffalse: u64,
        ninspected: u64,
    }

    struct Monkeys has copy, drop {
        monkeys: vector<Monkey>,
        testprod: u64,
    }

    // Expect:
    //   Starting items: <list u64>
    fun parse_items(line: &vector<u8>): vector<u64> {
        let items = vector[];
        let parts = evector::split_by(line, &ASCII_SPACE);
        let nparts = vector::length(&parts);
        let i = 4;
        while (i < nparts) {
            let item = vector::borrow(&parts, i);
            // Ignore comma on all but last
            let item = if (i != nparts - 1) {
                estring::parse_u64_in(item, 0, vector::length(item) - 1)
            } else {
                estring::parse_u64(item)
            };
            vector::push_back(&mut items, item);
            i = i + 1;
        };
        items
    }

    // Expect:
    //   Operation: new = old <+ | *> <u64 | old>
    fun parse_op(line: &vector<u8>): (u8, u64) {
        let parts = evector::split_by(line, &ASCII_SPACE);
        let op = vector::borrow(&parts, 6);
        let opval = vector::borrow(&parts, 7);

        let opval = if (opval == &b"old") { 0 } else { estring::parse_u64(opval) };
        let opcode = if (op == &b"+") {
            O_ADD
        } else if (op == &b"*" && opval != 0) {
            O_MUL
        } else if (op == &b"*" && opval == 0) {
            O_SQR
        } else {
            abort E_INVALID_INSTR
        };
        (opcode, opval)
    }

    // Expect:
    //   Test: divisble by <u64>
    fun parse_test(line: &vector<u8>): u64 {
        let parts = evector::split_by(line, &ASCII_SPACE);
        estring::parse_u64(vector::borrow(&parts, 5))
    }

    // Expect:
    //     If <true | false>: throw to monkey <u64>
    fun parse_if(line: &vector<u8>): u64 {
        let parts = evector::split_by(line, &ASCII_SPACE);
        estring::parse_u64(vector::borrow(&parts, 9))
    }

    fun parse_monkey(lines: &vector<vector<u8>>): Monkey {
        let items = parse_items(vector::borrow(lines, 1));
        let (opcode, opval) = parse_op(vector::borrow(lines, 2));
        let test = parse_test(vector::borrow(lines, 3));
        let iftrue = parse_if(vector::borrow(lines, 4));
        let iffalse = parse_if(vector::borrow(lines, 5));
        Monkey { items, opcode, opval, test, iftrue, iffalse, ninspected: 0 }
    }

    fun parse_monkeys(lines: &vector<vector<u8>>): Monkeys {
        let monkeys = vector[];
        let testprod = 1;
        let parts = evector::split_by(lines, &b"");
        let nmonkeys = vector::length(&parts);
        let i = 0;
        while (i < nmonkeys) {
            let monkey = parse_monkey(vector::borrow(&parts, i));
            testprod = testprod * monkey.test;
            vector::push_back(&mut monkeys, monkey);
            i = i + 1;
        };
        Monkeys {
            monkeys,
            testprod,
        }
    }

    fun do_monkey(monkeys: &mut Monkeys, idx: u64, part2: bool) {
        let nitems = vector::length(&vector::borrow(&monkeys.monkeys, idx).items);
        let i = 0;

        while (i < nitems) {
            let monkey = vector::borrow(&monkeys.monkeys, idx);
            let worry = *vector::borrow(&monkey.items, i);
            if (monkey.opcode == O_ADD) {
                worry = worry + monkey.opval;
            } else if (monkey.opcode == O_MUL) {
                worry = worry * monkey.opval;
            } else if (monkey.opcode == O_SQR) {
                worry = worry * worry;
            };
            if (!part2) { worry = worry / 3; };
            worry = worry % monkeys.testprod;
            let passto = if (worry % monkey.test == 0) {
                monkey.iftrue
            } else {
                monkey.iffalse
            };
            assert!(passto != idx, 0);
            vector::push_back(&mut vector::borrow_mut(&mut monkeys.monkeys, passto).items, worry);
            i = i + 1;
        };
        let monkey = vector::borrow_mut(&mut monkeys.monkeys, idx);
        monkey.items = vector[];
        monkey.ninspected = monkey.ninspected + nitems;
    }

    fun do_round(monkeys: &mut Monkeys, part2: bool) {
        let nmonkeys = vector::length(&monkeys.monkeys);
        let i = 0;
        while (i < nmonkeys) {
            do_monkey(monkeys, i, part2);
            i = i + 1;
        };
    }

    fun do_rounds(monkeys: &mut Monkeys, nrounds: u64, part2: bool) {
        let i = 0;
        while (i < nrounds) {
            do_round(monkeys, part2);
            i = i + 1;
        };
    }

    fun compute_monkey(lines: &vector<vector<u8>>, nrounds: u64, part2: bool): u64 {
        let monkeys = parse_monkeys(lines);
        do_rounds(&mut monkeys, nrounds, part2);
        let max1 = 0;
        let max2 = 0;
        let nmonkeys = vector::length(&monkeys.monkeys);
        let i = 0;

        while (i < nmonkeys) {
            let ninspected = vector::borrow(&monkeys.monkeys, i).ninspected;
            if (ninspected > max1) {
                max2 = max1;
                max1 = ninspected;
            } else if (ninspected > max2) {
                max2 = ninspected;
            };
            i = i + 1;
        };
        max1 * max2
    }

    public entry fun run() acquires Input {
        let input = borrow_global<Input>(@0x0);
        debug::print(&compute_monkey(&input.input, 20, false));
        debug::print(&compute_monkey(&input.input, 10000, true));
    }

    #[test_only]
    const TEST_INPUT: vector<vector<u8>> = vector[
        b"Monkey 0:",
        b"  Starting items: 79, 98",
        b"  Operation: new = old * 19",
        b"  Test: divisible by 23",
        b"    If true: throw to monkey 2",
        b"    If false: throw to monkey 3",
        b"",
        b"Monkey 1:",
        b"  Starting items: 54, 65, 75, 74",
        b"  Operation: new = old + 6",
        b"  Test: divisible by 19",
        b"    If true: throw to monkey 2",
        b"    If false: throw to monkey 0",
        b"",
        b"Monkey 2:",
        b"  Starting items: 79, 60, 97",
        b"  Operation: new = old * old",
        b"  Test: divisible by 13",
        b"    If true: throw to monkey 1",
        b"    If false: throw to monkey 3",
        b"",
        b"Monkey 3:",
        b"  Starting items: 74",
        b"  Operation: new = old + 3",
        b"  Test: divisible by 17",
        b"    If true: throw to monkey 0",
        b"    If false: throw to monkey 1",
    ];

    #[test]
    fun test1() {
        assert!(compute_monkey(&TEST_INPUT, 20, false) == 10605, 0);
    }

    #[test]
    fun test2() {
        assert!(compute_monkey(&TEST_INPUT, 10000, true) == 2713310158, 0);
    }

    #[test]
    fun test_parse_monkeys() {
        assert!(parse_monkeys(&TEST_INPUT) == Monkeys {
            monkeys: vector[
                Monkey {
                    items: vector[79, 98],
                    opcode: O_MUL,
                    opval: 19,
                    test: 23,
                    iftrue: 2,
                    iffalse: 3,
                    ninspected: 0,
                },
                Monkey {
                    items: vector[54, 65, 75, 74],
                    opcode: O_ADD,
                    opval: 6,
                    test: 19,
                    iftrue: 2,
                    iffalse: 0,
                    ninspected: 0,
                },
                Monkey {
                    items: vector[79, 60, 97],
                    opcode: O_SQR,
                    opval: 0,
                    test: 13,
                    iftrue: 1,
                    iffalse: 3,
                    ninspected: 0,
                },
                Monkey {
                    items: vector[74],
                    opcode: O_ADD,
                    opval: 3,
                    test: 17,
                    iftrue: 0,
                    iffalse: 1,
                    ninspected: 0,
                },
            ],
            testprod: 23 * 19 * 13 * 17,
        }, 0);
    }

    #[test]
    fun test_do_round1() {
        let monkeys = parse_monkeys(&TEST_INPUT);
        do_round(&mut monkeys, false);
        assert!(vector::borrow(&monkeys.monkeys, 0).items == vector[20, 23, 27, 26], 0);
        assert!(vector::borrow(&monkeys.monkeys, 1).items == vector[2080, 25, 167, 207, 401, 1046], 0);
        assert!(vector::borrow(&monkeys.monkeys, 2).items == vector[], 0);
        assert!(vector::borrow(&monkeys.monkeys, 3).items == vector[], 0);
        do_round(&mut monkeys, false);
        assert!(vector::borrow(&monkeys.monkeys, 0).items == vector[695, 10, 71, 135, 350], 0);
        assert!(vector::borrow(&monkeys.monkeys, 1).items == vector[43, 49, 58, 55, 362], 0);
        assert!(vector::borrow(&monkeys.monkeys, 2).items == vector[], 0);
        assert!(vector::borrow(&monkeys.monkeys, 3).items == vector[], 0);
    }

    #[test]
    fun test_do_round2() {
        let monkeys = parse_monkeys(&TEST_INPUT);
        do_round(&mut monkeys, true);
        assert!(vector::borrow(&monkeys.monkeys, 0).ninspected == 2, 0);
        assert!(vector::borrow(&monkeys.monkeys, 1).ninspected == 4, 0);
        assert!(vector::borrow(&monkeys.monkeys, 2).ninspected == 3, 0);
        assert!(vector::borrow(&monkeys.monkeys, 3).ninspected == 6, 0);
        do_rounds(&mut monkeys, 19, true);
        assert!(vector::borrow(&monkeys.monkeys, 0).ninspected == 99, 0);
        assert!(vector::borrow(&monkeys.monkeys, 1).ninspected == 97, 0);
        assert!(vector::borrow(&monkeys.monkeys, 2).ninspected == 8, 0);
        assert!(vector::borrow(&monkeys.monkeys, 3).ninspected == 103, 0);
        do_rounds(&mut monkeys, 980, true);
        assert!(vector::borrow(&monkeys.monkeys, 0).ninspected == 5204, 0);
        assert!(vector::borrow(&monkeys.monkeys, 1).ninspected == 4792, 0);
        assert!(vector::borrow(&monkeys.monkeys, 2).ninspected == 199, 0);
        assert!(vector::borrow(&monkeys.monkeys, 3).ninspected == 5192, 0);
    }
}
