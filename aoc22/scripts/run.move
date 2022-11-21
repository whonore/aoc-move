script {
    use aoc22::d01;

    const EINVALID_DAY: u64 = 1;

    const COMPLETED_DAY: u64 = 1;

    fun run(day: u64) {
        assert!(1 <= day && day <= COMPLETED_DAY, EINVALID_DAY);
        if (day == 1) { d01::run(); }
    }
}
