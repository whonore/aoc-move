module extralib::pair {
    /// A generic pair.
    struct Pair<T, U> has copy, drop {
        fst: T,
        snd: U,
    }

    /// Initialize a new pair.
    public fun new<T, U>(fst: T, snd: U): Pair<T, U> {
        Pair { fst, snd }
    }

    spec new {
        aborts_if false;
    }

    /// Get the first element of `p`.
    public fun fst<T, U>(p: &Pair<T, U>): &T {
        &p.fst
    }

    spec fst {
        aborts_if false;
    }

    /// Get a mutable reference to the first element of `p`.
    public fun fst_mut<T, U>(p: &mut Pair<T, U>): &mut T {
        &mut p.fst
    }

    spec fst_mut {
        aborts_if false;
    }

    /// Get the second element of `p`.
    public fun snd<T, U>(p: &Pair<T, U>): &U {
        &p.snd
    }

    spec snd {
        aborts_if false;
    }

    /// Get a mutable reference to the second element of `p`.
    public fun snd_mut<T, U>(p: &mut Pair<T, U>): &mut U {
        &mut p.snd
    }

    spec snd_mut {
        aborts_if false;
    }

    #[test]
    fun test_fst_snd() {
        let p = new(true, vector[1,2,3]);
        assert!(fst(&p) == &true, 0);
        assert!(snd(&p) == &vector[1,2,3], 0);
        *fst_mut(&mut p) = false;
        *snd_mut(&mut p) = vector[3,2,1];
        assert!(fst(&p) == &false, 0);
        assert!(snd(&p) == &vector[3,2,1], 0);
    }
}
