module aoc22::d03 {
    use std::debug;
    use std::vector;
    use extralib::vector as evector;
    use aoc22::d03_in;

    const ENOT_FOUND: u64 = 1;

    const ASCII_a: u8 = 97;
    const ASCII_A: u8 = 65;

    fun priority(item: u8): u8 {
        (if (item >= ASCII_a) { item - ASCII_a } else { item - ASCII_A + 26 }) + 1
    }

    fun find_duplicate(ruck: &vector<u8>): u8 {
        let mid = vector::length(ruck) / 2;
        let (ruck1, ruck2) = evector::split_at(ruck, mid);
        let i = 0;

        while (i < mid) {
            let item = *vector::borrow(&ruck1, i);
            if (vector::contains(&ruck2, &item)) {
                return item
            };
            i = i + 1;
        };
        abort ENOT_FOUND
    }

    fun find_common(ruck1: &vector<u8>, ruck2: &vector<u8>, ruck3: &vector<u8>): u8 {
        let i = 0;
        let len = vector::length(ruck1);

        while (i < len) {
            let item = *vector::borrow(ruck1, i);
            if (vector::contains(ruck2, &item) && vector::contains(ruck3, &item)) {
                return item
            };
            i = i + 1;
        };
        abort ENOT_FOUND
    }

    fun total_priorities(v: &vector<vector<u8>>): u64 {
        let p = 0;
        let i = 0;
        let len = vector::length(v);

        while (i < len) {
            let ruck = vector::borrow(v, i);
            p = p + (priority(find_duplicate(ruck)) as u64);
            i = i + 1;
        };
        p
    }

    fun total_priorities2(v: &vector<vector<u8>>): u64 {
        let p = 0;
        let i = 0;
        let len = vector::length(v);

        while (i < len) {
            let ruck1 = vector::borrow(v, i);
            let ruck2 = vector::borrow(v, i + 1);
            let ruck3 = vector::borrow(v, i + 2);
            p = p + (priority(find_common(ruck1, ruck2, ruck3)) as u64);
            i = i + 3;
        };
        p
    }

    public entry fun run() {
        debug::print(&total_priorities(&d03_in::input()));
        debug::print(&total_priorities2(&d03_in::input()));
    }

    #[test_only]
    const TEST_INPUT: vector<vector<u8>> = vector[
        b"vJrwpWtwJgWrhcsFMMfFFhFp",
        b"jqHRNqRjqzjGDLGLrsFMfFZSrLrFZsSL",
        b"PmmdzqPrVvPwwTWBwg",
        b"wMqvLMZHhHMvwLHjbvcjnnSBnvTQFn",
        b"ttgJtRGJQctTZtZT",
        b"CrZsJsPPZsGzwwsLwLmpwMDw",
    ];

    #[test]
    fun test1() {
        assert!(total_priorities(&TEST_INPUT) == 157, 0);
    }

    #[test]
    fun test2() {
        assert!(total_priorities2(&TEST_INPUT) == 70, 0);
    }

    #[test]
    fun test_priority() {
        let azAZ = b"azAZ";
        assert!(priority(*vector::borrow(&azAZ, 0)) == 1, 0);
        assert!(priority(*vector::borrow(&azAZ, 1)) == 26, 0);
        assert!(priority(*vector::borrow(&azAZ, 2)) == 27, 0);
        assert!(priority(*vector::borrow(&azAZ, 3)) == 52, 0);
    }
}
