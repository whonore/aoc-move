module aoc22::d06 {
    use std::debug;
    use std::vector;
    use extralib::vector as evector;

    spec module {
        pragma verify = false;
    }

    struct Input has key {
        input: vector<u8>
    }

    const ENO_MARKER: u64 = 1;

    fun find_marker(stream: &vector<u8>, wsize: u64): u64 {
        let window = evector::repeat(wsize, &0);
        let widx = 0;
        let i = 0;
        let len = vector::length(stream);

        while (i < len) {
            let c = *vector::borrow(stream, i);
            *vector::borrow_mut(&mut window, widx) = c;
            if (i >= wsize - 1 && evector::is_unique(&window)) {
                return i + 1
            };
            widx = (widx + 1) % wsize;
            i = i + 1;
        };
        abort ENO_MARKER
    }

    public entry fun run() acquires Input {
        let input = borrow_global<Input>(@0x0);
        debug::print(&find_marker(&input.input, 4));
        debug::print(&find_marker(&input.input, 14));
    }

    #[test_only]
    const TEST_INPUT1: vector<u8> = b"mjqjpqmgbljsphdztnvjfqwrcgsmlb";

    #[test_only]
    const TEST_INPUT2: vector<u8> = b"bvwbjplbgvbhsrlpgdmjqwftvncz";

    #[test_only]
    const TEST_INPUT3: vector<u8> = b"nppdvjthqldpwncqszvftbrmjlhg";

    #[test_only]
    const TEST_INPUT4: vector<u8> = b"nznrnfrfntjfmvfwmzdfjlvtqnbhcprsg";

    #[test_only]
    const TEST_INPUT5: vector<u8> = b"zcfzfwzzqfrljwzlrfnpqdbhtmscgvjw";

    #[test]
    fun test1() {
        assert!(find_marker(&TEST_INPUT1, 4) == 7, 0);
        assert!(find_marker(&TEST_INPUT2, 4) == 5, 0);
        assert!(find_marker(&TEST_INPUT3, 4) == 6, 0);
        assert!(find_marker(&TEST_INPUT4, 4) == 10, 0);
        assert!(find_marker(&TEST_INPUT5, 4) == 11, 0);
    }

    #[test]
    fun test2() {
        assert!(find_marker(&TEST_INPUT1, 14) == 19, 0);
        assert!(find_marker(&TEST_INPUT2, 14) == 23, 0);
        assert!(find_marker(&TEST_INPUT3, 14) == 23, 0);
        assert!(find_marker(&TEST_INPUT4, 14) == 29, 0);
        assert!(find_marker(&TEST_INPUT5, 14) == 26, 0);
    }
}
