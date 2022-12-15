module aoc22::d15 {
    use std::debug;
    use std::vector;
    use extralib::hashmap;
    use extralib::math;
    use extralib::pair::{Self, Pair};
    use extralib::signed64::{Self, Signed64};
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
    const ASCII_EQ: u8 = 61;

    const FREQ_MUL: u64 = 4000000;

    fun parse_xy(xy: &vector<u8>): Signed64 {
        let parts = evector::split_by(xy, &ASCII_EQ);
        let xy = vector::borrow_mut(&mut parts, 1);
        if (!estring::is_digit(*evector::last(xy))) {
            vector::pop_back(xy);
        };
        signed64::parse(xy)
    }

    fun parse_sensor(line: &vector<u8>): Pair<Pair<Signed64, Signed64>, Pair<Signed64, Signed64>> {
        let parts = evector::split_by(line, &ASCII_SPACE);
        let sx = parse_xy(vector::borrow(&parts, 2));
        let sy = parse_xy(vector::borrow(&parts, 3));
        let bx = parse_xy(vector::borrow(&parts, 8));
        let by = parse_xy(vector::borrow(&parts, 9));
        pair::new(pair::new(sx, sy), pair::new(bx, by))
    }

    fun parse_sensors(lines: &vector<vector<u8>>): vector<Pair<Pair<Signed64, Signed64>, Pair<Signed64, Signed64>>> {
        let sensors = vector[];
        let nsensors = vector::length(lines);
        let i = 0;
        while (i < nsensors) {
            vector::push_back(&mut sensors, parse_sensor(vector::borrow(lines, i)));
            i = i + 1;
        };
        sensors
    }

    fun sort_sensors(sensors: &mut vector<Pair<Pair<Signed64, Signed64>, Pair<Signed64, Signed64>>>) {
        let i = 1;
        let nsensors = vector::length(sensors);
        while (i < nsensors) {
            let j = i;
            while (j > 0) {
                let x1 = pair::fst(pair::fst(vector::borrow(sensors, j - 1)));
                let x2 = pair::fst(pair::fst(vector::borrow(sensors, j)));
                if (signed64::le(x1, x2)) {
                    break
                };
                vector::swap(sensors, j - 1, j);
                j = j - 1;
            };
            i = i + 1;
        };
    }

    fun dist(xy1: &Pair<Signed64, Signed64>, xy2: &Pair<Signed64, Signed64>): u64 {
        signed64::absdiff(pair::fst(xy1), pair::fst(xy2))
        + signed64::absdiff(pair::snd(xy1), pair::snd(xy2))
    }

    fun extent_along_line(sensor: &Pair<Signed64, Signed64>, dy: u64, r: u64): (Signed64, Signed64) {
        let x = *pair::fst(sensor);
        let minx = signed64::sub(&x, &signed64::pos(r - dy));
        let maxx = signed64::add(&x, &signed64::pos(r - dy));
        (minx, maxx)
    }

    fun count_no_beacons(lines: &vector<vector<u8>>, y: Signed64): u64 {
        let minx = signed64::pos(math::max_u64());
        let maxx = signed64::neg(math::max_u64());
        let nbeacons = 0;
        let beacons = hashmap::new();
        let sensors = parse_sensors(lines);
        let nsensors = vector::length(&sensors);
        let i = 0;
        while (i < nsensors) {
            let sensor = pair::fst(vector::borrow(&sensors, i));
            let beacon = pair::snd(vector::borrow(&sensors, i));
            let r = dist(sensor, beacon);
            let dy = signed64::absdiff(pair::snd(sensor), &y);

            // Ignore sensors that can't overlap with `y`.
            if (dy <= r) {
                let (emin, emax) = extent_along_line(sensor, dy, r);
                if (signed64::lt(&emin, &minx)) {
                    minx = emin;
                };
                if (signed64::gt(&emax, &maxx)) {
                    maxx = emax;
                };
                if (*pair::snd(beacon) == y && !hashmap::has_key(&beacons, beacon)) {
                    hashmap::set(&mut beacons, beacon, true);
                    nbeacons = nbeacons + 1;
                };
            };
            i = i + 1;
        };
        signed64::absdiff(&maxx, &minx) + 1 - nbeacons
    }

    fun find_beacon(lines: &vector<vector<u8>>, maxxy: u64): u64 {
        let sensors = parse_sensors(lines);
        // Optimization: sort sensors by x-coordinate so early ones don't have
        // to be rechecked in the `x` loop.
        sort_sensors(&mut sensors);
        let nsensors = vector::length(&sensors);

        // Micro-optimization: pre-compute sensor distances.
        let dists = vector[];
        let i = 0;
        while (i < nsensors) {
            let sensor = pair::fst(vector::borrow(&sensors, i));
            let beacon = pair::snd(vector::borrow(&sensors, i));
            vector::push_back(&mut dists, dist(sensor, beacon));
            i = i + 1;
        };

        let y = 0;
        while (y < maxxy) {
            // Optimization: pre-compute extents since they don't depend on
            // `x`.
            let extents = vector[];
            let i = 0;
            while (i < nsensors) {
                let sensor = pair::fst(vector::borrow(&sensors, i));
                let r = *vector::borrow(&dists, i);
                let dy = signed64::absdiff(pair::snd(sensor), &signed64::pos(y));
                if (dy <= r) {
                    let (emin, emax) = extent_along_line(sensor, dy, r);
                    // Micro-optimization: don't consider ranges outside of
                    // [0, maxxy].
                    if ((signed64::is_pos(&emin) && signed64::abs(&emin) <= maxxy)
                        || (signed64::is_pos(&emax) && signed64::abs(&emax) <= maxxy)) {
                        vector::push_back(&mut extents, pair::new(emin, emax));
                    };
                };
                i = i + 1;
            };
            let nextents = vector::length(&extents);

            let x = 0;
            let i = 0;
            while (x < maxxy) {
                let found = true;
                while (i < nextents) {
                    let emin = pair::fst(vector::borrow(&extents, i));
                    let emax = pair::snd(vector::borrow(&extents, i));
                    // Micro-optimization: short-circuit comparisons with negatives.
                    // if (signed64::le(&emin, &signed64::pos(x)) && signed64::le(&signed64::pos(x), &emax)) {
                    if ((signed64::is_neg(emin) || signed64::abs(emin) <= x)
                        && (signed64::is_pos(emax) && x <= signed64::abs(emax))) {
                        x = signed64::abs(emax);
                        found = false;
                        i = i + 1;
                        break
                    };
                    i = i + 1;
                };

                if (found) {
                    return x * FREQ_MUL + y
                };
                x = x + 1;
            };
            y = y + 1;
        };
        abort EUNREACHABLE
    }

    public entry fun run() acquires Input {
        let input = borrow_global<Input>(@0x0);
        debug::print(&count_no_beacons(&input.input, signed64::pos(2000000)));
        debug::print(&find_beacon(&input.input, 4000000));
    }

    #[test_only]
    const TEST_INPUT: vector<vector<u8>> = vector[
        b"Sensor at x=2, y=18: closest beacon is at x=-2, y=15",
        b"Sensor at x=9, y=16: closest beacon is at x=10, y=16",
        b"Sensor at x=13, y=2: closest beacon is at x=15, y=3",
        b"Sensor at x=12, y=14: closest beacon is at x=10, y=16",
        b"Sensor at x=10, y=20: closest beacon is at x=10, y=16",
        b"Sensor at x=14, y=17: closest beacon is at x=10, y=16",
        b"Sensor at x=8, y=7: closest beacon is at x=2, y=10",
        b"Sensor at x=2, y=0: closest beacon is at x=2, y=10",
        b"Sensor at x=0, y=11: closest beacon is at x=2, y=10",
        b"Sensor at x=20, y=14: closest beacon is at x=25, y=17",
        b"Sensor at x=17, y=20: closest beacon is at x=21, y=22",
        b"Sensor at x=16, y=7: closest beacon is at x=15, y=3",
        b"Sensor at x=14, y=3: closest beacon is at x=15, y=3",
        b"Sensor at x=20, y=1: closest beacon is at x=15, y=3",
    ];

    #[test]
    fun test1() {
        assert!(count_no_beacons(&TEST_INPUT, signed64::pos(10)) == 26, 0);
    }

    #[test]
    fun test2() {
        assert!(find_beacon(&TEST_INPUT, 20) == 56000011, 0);
    }

    #[test]
    fun test_parse_sensor() {
        assert!(
            parse_sensor(&b"Sensor at x=1, y=2: closest beacon is at x=-1, y=-2") ==
            pair::new(
                pair::new(signed64::pos(1), signed64::pos(2)),
                pair::new(signed64::neg(1), signed64::neg(2),
            )
        ), 0);
    }

    #[test]
    fun test_dist() {
        assert!(
            dist(
                &pair::new(signed64::pos(2), signed64::pos(18)),
                &pair::new(signed64::neg(2), signed64::pos(15)),
            ) == 7,
        0);
        assert!(
            dist(
                &pair::new(signed64::pos(12), signed64::pos(14)),
                &pair::new(signed64::pos(10), signed64::pos(16)),
            ) == 4,
        0);
    }

    #[test]
    fun test_extent_along_line() {
        let (minx, maxx) = extent_along_line(
            &pair::new(signed64::pos(8), signed64::pos(7)),
            3,
            9
        );
        assert!(minx == signed64::pos(2), 0);
        assert!(maxx == signed64::pos(14), 0);
    }
}
