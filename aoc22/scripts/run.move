script {
    use aoc22::d01;
    use aoc22::d02;

    const EINVALID_DAY: u64 = 1;

    fun run(day: u64) {
        if (day == 1) { d01::run(); }
        else if (day == 2) { d02::run(); }
        else { abort EINVALID_DAY }
    }
}
