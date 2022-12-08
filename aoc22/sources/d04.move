module aoc22::d04 {
    use std::debug;
    use std::vector;

    spec module {
        pragma verify = false;
    }

    struct Input has key {
        input: vector<u8>
    }

    fun contains(lo1: u8, hi1: u8, lo2: u8, hi2: u8): bool {
        (lo1 <= lo2 && hi2 <= hi1) || (lo2 <= lo1 && hi1 <= hi2)
    }

    fun overlaps(lo1: u8, hi1: u8, lo2: u8, hi2: u8): bool {
        (lo1 <= lo2 && lo2 <= hi1) || (lo2 <= lo1 && lo1 <= hi2)
    }

    fun total_contains(pairs: &vector<u8>): u64 {
        let total = 0;
        let i = 0;
        let len = vector::length(pairs);

        while (i < len) {
            let lo1 = *vector::borrow(pairs, i);
            let hi1 = *vector::borrow(pairs, i + 1);
            let lo2 = *vector::borrow(pairs, i + 2);
            let hi2 = *vector::borrow(pairs, i + 3);
            if (contains(lo1, hi1, lo2, hi2)) {
                total = total + 1;
            };
            i = i + 4;
        };
        total
    }

    fun total_overlaps(pairs: &vector<u8>): u64 {
        let total = 0;
        let i = 0;
        let len = vector::length(pairs);

        while (i < len) {
            let lo1 = *vector::borrow(pairs, i);
            let hi1 = *vector::borrow(pairs, i + 1);
            let lo2 = *vector::borrow(pairs, i + 2);
            let hi2 = *vector::borrow(pairs, i + 3);
            if (overlaps(lo1, hi1, lo2, hi2)) {
                total = total + 1;
            };
            i = i + 4;
        };
        total
    }

    public entry fun run() acquires Input {
        let input = borrow_global<Input>(@0x0);
        debug::print(&total_contains(&input.input));
        debug::print(&total_overlaps(&input.input));
    }

    #[test_only]
    const TEST_INPUT: vector<u8> = vector[
        2,4, 6,8,
        2,3, 4,5,
        5,7, 7,9,
        2,8, 3,7,
        6,6, 4,6,
        2,6, 4,8,
    ];

    #[test]
    fun test1() {
        assert!(total_contains(&TEST_INPUT) == 2, 0);
    }

    #[test]
    fun test2() {
        assert!(total_overlaps(&TEST_INPUT) == 4, 0);
    }

    #[test]
    fun test_contains() {
        assert!(contains(2, 8, 3, 8), 0);
        assert!(contains(6, 6, 4, 6), 0);
        assert!(!contains(2, 4, 6, 8), 0);
        assert!(!contains(2, 6, 4, 8), 0);
    }

    #[test]
    fun test_overlaps() {
        assert!(overlaps(2, 8, 3, 8), 0);
        assert!(overlaps(5, 6, 6, 9), 0);
        assert!(!overlaps(2, 4, 6, 8), 0);
        assert!(!overlaps(2, 3, 4, 5), 0);
    }
}
