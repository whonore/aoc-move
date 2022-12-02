module aoc22::d01 {
    use std::debug;
    use std::vector;
    use extralib::vector as evector;
    use aoc22::d01_in;

    fun max_calories(v: &vector<vector<u64>>): u128 {
        let sums = evector::map_sum64(v);
        let (_max_idx, max) = evector::max128(&sums);
        max
    }

    fun top3_calories(v: &vector<vector<u64>>): u128 {
        let sums = evector::map_sum64(v);
        let len = vector::length(&sums);

        // Max in v
        let (max1_idx, max1) = evector::max128(&sums);

        // Max in v[..max1_idx] and v[max1_idx+1..]
        let (max2_l_idx, max2_l) = evector::max128_in(&sums, 0, max1_idx);
        let (max2_r_idx, max2_r) = evector::max128_in(&sums, max1_idx + 1, len);
        let (max2_idx, max2) = if (max2_l > max2_r) {
            (max2_l_idx, max2_l)
        } else {
            (max2_r_idx, max2_r)
        };

        // Sort max1_idx, max2_idx
        let (max1_idx, max2_idx) = if (max1_idx < max2_idx) {
            (max1_idx, max2_idx)
        } else {
            (max2_idx, max1_idx)
        };

        // Max in v[..max1_idx] and v[max1_idx+1..max2_idx] and v[max2_idx..]
        let (max3_l_idx, max3_l) = evector::max128_in(&sums, 0, max1_idx);
        let (max3_m_idx, max3_m) = evector::max128_in(&sums, max1_idx + 1, max2_idx);
        let (max3_r_idx, max3_r) = evector::max128_in(&sums, max2_idx + 1, len);
        let (_max3_idx, max3) = if (max3_l > max3_m) {
            if (max3_l > max3_r) {
                (max3_l_idx, max3_l)
            } else {
                (max3_r_idx, max3_r)
            }
        } else {
            if (max3_m > max3_r) {
                (max3_m_idx, max3_m)
            } else {
                (max3_r_idx, max3_r)
            }
        };

        max1 + max2 + max3
    }

    public entry fun run() {
        debug::print(&max_calories(&d01_in::input()));
        debug::print(&top3_calories(&d01_in::input()));
    }

    #[test_only]
    const TEST_INPUT: vector<vector<u64>> = vector[
        vector[1000, 2000, 3000],
        vector[4000],
        vector[5000, 6000],
        vector[7000, 8000, 9000],
        vector[10000],
    ];

    #[test]
    fun test1() {
        assert!(max_calories(&TEST_INPUT) == 24000, 0);
    }

    #[test]
    fun test2() {
        assert!(top3_calories(&TEST_INPUT) == 45000, 0);
    }
}
