import re
from itertools import zip_longest
from pathlib import Path

from move import BcsScript, Bytes, Vector

NAME = Path(__file__).stem
INPUT = Path(__file__).with_suffix(".in")
OUTPUT = Path(__file__).with_suffix(".bcs")


def parse(data: str) -> bytes:
    with BcsScript(NAME) as script:
        crates, moves = data.split("\n\n")
        crates = (row[1::4] for row in crates.split("\n")[:-1])
        crates = ["".join(col).strip() for col in zip_longest(*crates, fillvalue=" ")]
        moves = [re.findall(r"\d+", move) for move in moves.strip().split("\n")]
        merged = Vector(
            [Vector([len(crates)], type_="u8")]
            + list(map(Bytes, crates))
            + [Vector(move, type_="u8") for move in moves],
            name="INPUT",
            type_="vector<u8>",
        )
        script.write(merged)
        return script.run()


if __name__ == "__main__":
    data = INPUT.read_text(encoding="utf-8")
    out = parse(data)
    OUTPUT.write_bytes(out)
