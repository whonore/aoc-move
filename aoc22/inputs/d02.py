from pathlib import Path

from move import Module, Vector

NAME = Path(__file__).stem
INPUT = Path(__file__).with_suffix(".in")
OUTPUT = INPUT.parent / f"../sources/{NAME}_in.move"


def parse(data: str) -> str:
    mod = Module(NAME)
    varmap = {"A": 1, "B": 2, "C": 3, "X": 4, "Y": 5, "Z": 6}
    chunks = Vector(
        [
            Vector([varmap[x] for x in line.split(" ")], type_="u8")
            for line in data.strip().split("\n")
        ],
        name="INPUT",
        type_="vector<u8>",
    )
    mod.add_const(chunks)
    return str(mod)


if __name__ == "__main__":
    data = INPUT.read_text(encoding="utf-8")
    out = parse(data)
    OUTPUT.write_text(out, encoding="utf-8")
