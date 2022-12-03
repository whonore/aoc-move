from pathlib import Path

from move import Bytes, Module, Vector

NAME = Path(__file__).stem
INPUT = Path(__file__).with_suffix(".in")
OUTPUT = INPUT.parent / f"../sources/{NAME}_in.move"


def parse(data: str) -> str:
    mod = Module(NAME)
    chunks = Vector(
        [Bytes(line) for line in data.strip().split("\n")],
        name="INPUT",
        type_="vector<u8>",
    )
    mod.add_const(chunks)
    return str(mod)


if __name__ == "__main__":
    data = INPUT.read_text(encoding="utf-8")
    out = parse(data)
    OUTPUT.write_text(out, encoding="utf-8")
