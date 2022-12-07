module aoc22::d07 {
    use std::debug;
    use std::option::{Self, Option};
    use std::vector;
    use extralib::string as estring;
    use extralib::vector as evector;

    struct Input has key {
        input: vector<vector<u8>>
    }

    const ENOT_DIR: u64 = 1;
    const EINVALID_IDX: u64 = 2;
    const EPATH_NOT_FOUND: u64 = 3;
    const EDUPLICATE_ENTRY: u64 = 4;

    const DIR_SIZE_CUTOFF: u64 = 100000;
    const DISK_SIZE: u64 = 70000000;
    const NEEDED_SIZE: u64 = 30000000;

    const ASCII_SPACE: u8 = 32;
    const ASCII_SLASH: u8 = 47;

    const ROOT_IDX: u64 = 0;

    struct FileSystem has drop {
        dirmap: vector<DirEntry>,
        paths: vector<vector<u8>>,
        next_idx: u64,
    }

    spec FileSystem {
        invariant len(dirmap) == len(paths);
        invariant len(dirmap) == next_idx;
        invariant forall entry in dirmap:
            in_range(dirmap, entry.idx)
            && dirmap[entry.idx] == entry
            && paths[entry.idx] == entry.path;
        invariant forall entry in dirmap: in_range(dirmap, entry.parent);
        invariant forall entry in dirmap: forall child in entry.children:
            in_range(dirmap, child);
    }

    struct DirEntry has copy, drop {
        path: vector<u8>,
        idx: u64,
        parent: u64,
        children: vector<u64>,
        size: Option<u64>,
        is_dir: bool,
    }

    spec DirEntry {
        invariant !is_dir ==> len(children) == 0;
        invariant is_dir <==> option::is_none(size);
    }

    fun root(): DirEntry {
        DirEntry {
            path: b"/",
            idx: ROOT_IDX,
            parent: ROOT_IDX,
            children: vector[],
            size: option::none(),
            is_dir: true,
        }
    }

    fun dir(path: vector<u8>, idx: u64, parent: u64): DirEntry {
        DirEntry {
            path,
            idx,
            parent,
            children: vector[],
            size: option::none(),
            is_dir: true,
        }
    }

    fun file(path: vector<u8>, idx: u64, parent: u64, size: u64): DirEntry {
        DirEntry {
            path,
            idx,
            parent,
            children: vector[],
            size: option::some(size),
            is_dir: false,
        }
    }

    fun init_fs(): FileSystem {
        let dirmap = vector[root()];
        FileSystem {
            dirmap,
            paths: vector[b"/"],
            next_idx: 1,
        }
    }

    fun lookup_idx(fs: &FileSystem, idx: u64): DirEntry {
        *vector::borrow(&fs.dirmap, idx)
    }

    fun lookup_path(fs: &FileSystem, path: &vector<u8>): DirEntry {
        let (found, idx) = vector::index_of(&fs.paths, path);
        assert!(found, EPATH_NOT_FOUND);
        lookup_idx(fs, idx)
    }

    fun add_entry(fs: &mut FileSystem, entry: DirEntry, parent: u64) {
        assert!(!vector::contains(&fs.paths, &entry.path), EDUPLICATE_ENTRY);
        let par_entry = vector::borrow_mut(&mut fs.dirmap, parent);
        assert!(par_entry.is_dir, ENOT_DIR);
        vector::push_back(&mut par_entry.children, entry.idx);
        vector::push_back(&mut fs.paths, entry.path);
        assert!(vector::length(&fs.dirmap) == entry.idx, EINVALID_IDX);
        vector::push_back(&mut fs.dirmap, entry);
        fs.next_idx = fs.next_idx + 1;
    }

    fun add_dir(fs: &mut FileSystem, name: &vector<u8>, parent: &DirEntry) {
        let path = join_path(&parent.path, name);
        let idx = fs.next_idx;
        add_entry(fs, dir(path, idx, parent.idx), parent.idx);
    }

    fun add_file(fs: &mut FileSystem, name: &vector<u8>, parent: &DirEntry, size: u64) {
        let path = join_path(&parent.path, name);
        let idx = fs.next_idx;
        add_entry(fs, file(path, idx, parent.idx, size), parent.idx);
    }

    fun dir_size(fs: &FileSystem, dir: &DirEntry): u64 {
        let nchildren = vector::length(&dir.children);
        let i = 0;
        let size = 0;

        while (i < nchildren) {
            let ch_idx = *vector::borrow(&dir.children, i);
            let ch_entry = lookup_idx(fs, ch_idx);
            size = size + if (option::is_some(&ch_entry.size)) {
                *option::borrow(&ch_entry.size)
            } else {
                dir_size(fs, &ch_entry)
            };
            i = i + 1;
        };
        size
    }

    spec dir_size {
        pragma opaque;
    }

    fun chdir(fs: &FileSystem, curdir: &DirEntry, dir: &vector<u8>): DirEntry {
        if (dir == &b"..") {
            lookup_idx(fs, curdir.parent)
        } else {
            let path = join_path(&curdir.path, dir);
            lookup_path(fs, &path)
        }
    }

    fun join_path(curdir: &vector<u8>, name: &vector<u8>): vector<u8> {
        if (vector::is_empty(curdir))  {
            *name
        } else if (vector::is_empty(name)) {
            *curdir
        } else if (*vector::borrow(name, 0) == ASCII_SLASH) {
            *name
        } else if (curdir == &b"/") {
            evector::append_new(curdir, name)
        } else {
            evector::join_by(&vector[*curdir, *name], &ASCII_SLASH)
        }
    }

    fun run_cmds(cmds: &vector<vector<u8>>): FileSystem {
        let ncmds = vector::length(cmds);
        let i = 0;
        let fs = init_fs();
        let curdir = lookup_path(&fs, &b"/");

        while (i < ncmds) {
            let cmd = vector::borrow(cmds, i);
            let pieces = evector::split_by(cmd, &ASCII_SPACE);
            let fst = vector::borrow(&pieces, 0);
            if (fst == &b"$") {
                // A command
                let cmd = vector::borrow(&pieces, 1);
                if (cmd == &b"cd") {
                    // Change curdir
                    let dir = vector::borrow(&pieces, 2);
                    curdir = chdir(&fs, &curdir, dir);
                } else {
                    // Ignore ls
                }
            } else if (fst == &b"dir") {
                // A directory
                let name = vector::borrow(&pieces, 1);
                add_dir(&mut fs, name, &curdir);
            } else {
                // A file
                let size = estring::parse_u64(fst);
                let name = vector::borrow(&pieces, 1);
                add_file(&mut fs, name, &curdir, size);
            };
            i = i + 1;
        };
        fs
    }

    spec run_cmds {
        pragma verify = false;
    }

    fun sum_dirs(cmds: &vector<vector<u8>>): u64 {
        let fs = run_cmds(cmds);
        let nentries = vector::length(&fs.dirmap);
        let i = 0;
        let sum = 0;

        while (i < nentries) {
            let entry = lookup_idx(&fs, i);
            let size = dir_size(&fs, &entry);
            if (size <= DIR_SIZE_CUTOFF) {
                sum = sum + size;
            };
            i = i + 1;
        };
        sum
    }

    spec sum_dirs {
        pragma verify = false;
    }

    fun size_to_free(cmds: &vector<vector<u8>>): u64 {
        let fs = run_cmds(cmds);
        let nentries = vector::length(&fs.dirmap);
        let i = 0;
        let sizes = vector[];
        let total_size = dir_size(&fs, &lookup_path(&fs, &b"/"));
        let total_free = DISK_SIZE - total_size;
        let needed_free = NEEDED_SIZE - total_free;

        while (i < nentries) {
            let entry = lookup_idx(&fs, i);
            let size = dir_size(&fs, &entry);
            if (size >= needed_free) {
                vector::push_back(&mut sizes, size);
            };
            i = i + 1;
        };
        let (_, size) = evector::min64(&sizes);
        size
    }

    spec size_to_free {
        pragma verify = false;
    }

    public entry fun run() acquires Input {
        let input = borrow_global<Input>(@0x0);
        debug::print(&sum_dirs(&input.input));
        debug::print(&size_to_free(&input.input));
    }

    #[test_only]
    const TEST_INPUT: vector<vector<u8>> = vector[
        b"$ cd /",
        b"$ ls",
        b"dir a",
        b"14848514 b.txt",
        b"8504156 c.dat",
        b"dir d",
        b"$ cd a",
        b"$ ls",
        b"dir e",
        b"29116 f",
        b"2557 g",
        b"62596 h.lst",
        b"$ cd e",
        b"$ ls",
        b"584 i",
        b"$ cd ..",
        b"$ cd ..",
        b"$ cd d",
        b"$ ls",
        b"4060174 j",
        b"8033020 d.log",
        b"5626152 d.ext",
        b"7214296 k",
    ];

    #[test_only]
    fun test_fs(): FileSystem {
        // /
        // | a.txt (100)
        // | b.jpeg (200)
        // | c/
        // --|
        // | | a.txt (300)
        // | | c (400)
        // | d/
        // --|
        //   | x/
        //   | y/
        //   --| abc.g (500)
        let fs = init_fs();
        let curdir = lookup_path(&fs, &b"/");
        add_file(&mut fs, &b"a.txt", &curdir, 100);
        add_file(&mut fs, &b"b.jpeg", &curdir, 200);
        add_dir(&mut fs, &b"c", &curdir);
        add_dir(&mut fs, &b"d", &curdir);
        let curdir = lookup_path(&fs, &b"/c");
        add_file(&mut fs, &b"a.txt", &curdir, 300);
        add_file(&mut fs, &b"c", &curdir, 400);
        let curdir = lookup_path(&fs, &b"/d");
        add_dir(&mut fs, &b"x", &curdir);
        add_dir(&mut fs, &b"y", &curdir);
        let curdir = lookup_path(&fs, &b"/d/y");
        add_file(&mut fs, &b"abc.g", &curdir, 500);
        fs
    }

    #[test]
    fun test1() {
        assert!(sum_dirs(&TEST_INPUT) == 95437, 0);
    }

    #[test]
    fun test2() {
        assert!(size_to_free(&TEST_INPUT) == 24933642, 0);
    }

    #[test]
    fun test_join_path() {
        assert!(join_path(&b"abc", &b"def") == b"abc/def", 0);
        assert!(join_path(&b"abc/def", &b"g") == b"abc/def/g", 0);
        assert!(join_path(&b"abc", &b"") == b"abc", 0);
        assert!(join_path(&b"", &b"def") == b"def", 0);
        assert!(join_path(&b"/", &b"abc") == b"/abc", 0);
        assert!(join_path(&b"abc", &b"/def") == b"/def", 0);
        assert!(join_path(&b"/abc", &b"def") == b"/abc/def", 0);
    }

    #[test]
    fun test_dir_size() {
        let fs = test_fs();
        assert!(dir_size(&fs, &lookup_path(&fs, &b"/c")) == 300 + 400, 0);
        assert!(dir_size(&fs, &lookup_path(&fs, &b"/d/x")) == 0, 0);
        assert!(dir_size(&fs, &lookup_path(&fs, &b"/d/y")) == 500, 0);
        assert!(dir_size(&fs, &lookup_path(&fs, &b"/d")) == 0 + 500, 0);
        assert!(dir_size(&fs, &lookup_path(&fs, &b"/")) == 100 + 200 + 300 + 400 + 0 + 500, 0);
    }

    #[test]
    fun test_run_cmds() {
        let fs = run_cmds(&TEST_INPUT);
        assert!(lookup_path(&fs, &b"/a/e/i").size == option::some(584), 0);
        assert!(lookup_path(&fs, &b"/d/d.log").size == option::some(8033020), 0);
        assert!(vector::length(&lookup_path(&fs, &b"/a").children) == 4, 0);
    }
}
