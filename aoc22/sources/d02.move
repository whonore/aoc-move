module aoc22::d02 {
    use std::debug;
    use std::vector;

    struct Input has key {
        input: vector<u8>
    }

    const A: u8 = 1; // Rock
    const B: u8 = 2; // Paper
    const C: u8 = 3; // Scissors
    const X: u8 = 4; // Rock/Lose
    const Y: u8 = 5; // Paper/Draw
    const Z: u8 = 6; // Scissors/Win

    const WIN: u8 = 6;
    const DRAW: u8 = 3;
    const LOSE: u8 = 0;

    fun compute_move(opp_move: u8, outcome: u8): u8 {
        assert!(A <= opp_move && opp_move <= C, 0);
        assert!(X <= outcome && outcome <= Z, 0);
        if (opp_move == A && outcome == X) { Z }
        else if (opp_move == B && outcome == X) { X }
        else if (opp_move == C && outcome == X) { Y }
        else if (opp_move == A && outcome == Z) { Y }
        else if (opp_move == B && outcome == Z) { Z }
        else if (opp_move == C && outcome == Z) { X }
        else { opp_move + 3 }
    }

    fun win(opp_move: u8, my_move: u8): u8 {
        if (opp_move == A && my_move == Y) { WIN }
        else if (opp_move == B && my_move == Z) { WIN }
        else if (opp_move == C && my_move == X) { WIN }
        else if (opp_move == my_move - 3) { DRAW }
        else { LOSE }
    }

    fun score(opp_move: u8, my_move: u8): u8 {
        assert!(A <= opp_move && opp_move <= C, 0);
        assert!(X <= my_move && my_move <= Z, 0);
        win(opp_move, my_move) + (my_move - 3)
    }

    fun total_score(v: &vector<u8>): u64 {
        let s = 0;
        let i = 0;
        let len = vector::length(v);

        while (i < len) {
            let opp_move = *vector::borrow(v, i);
            let my_move = *vector::borrow(v, i + 1);
            s = s + (score(opp_move, my_move) as u64);
            i = i + 2;
        };
        s
    }

    fun total_score2(v: &vector<u8>): u64 {
        let s = 0;
        let i = 0;
        let len = vector::length(v);

        while (i < len) {
            let opp_move = *vector::borrow(v, i);
            let outcome = *vector::borrow(v, i + 1);
            let my_move = compute_move(opp_move, outcome);
            s = s + (score(opp_move, my_move) as u64);
            i = i + 2;
        };
        s
    }

    public entry fun run() acquires Input {
        let input = borrow_global<Input>(@0x0);
        debug::print(&total_score(&input.input));
        debug::print(&total_score2(&input.input));
    }

    public entry fun init(account: &signer, input: vector<u8>) {
        move_to(account, Input { input });
    }

    #[test_only]
    const TEST_INPUT: vector<u8> = vector[
        1, 5,
        2, 4,
        3, 6,
    ];

    #[test]
    fun test1() {
        assert!(total_score(&TEST_INPUT) == 15, 0);
    }

    #[test]
    fun test2() {
        assert!(total_score2(&TEST_INPUT) == 12, 0);
    }

    #[test]
    fun test_compute_move() {
        let opp_moves = vector[A, B, C];
        let outcomes = vector[X, Y, Z];
        let i = 0;
        let j = 0;

        while (i < 3) {
            let opp_move = *vector::borrow(&opp_moves, i);
            while (j < 3) {
                let outcome = *vector::borrow(&outcomes, j);
                let my_move = compute_move(opp_move, outcome);
                let actual_outcome = win(opp_move, my_move);
                if (outcome == X) {
                    assert!(actual_outcome == LOSE, 0);
                } else if (outcome == Y) {
                    assert!(actual_outcome == DRAW, 1);
                } else {
                    assert!(actual_outcome == WIN, 2);
                };
                j = j + 1;
            };
            i = i + 1;
        }
    }
}
