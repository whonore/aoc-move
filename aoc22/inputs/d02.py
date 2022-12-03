from pathlib import Path

from move import BcsScript, Vector

NAME = Path(__file__).stem
INPUT = Path(__file__).with_suffix(".in")
OUTPUT = Path(__file__).with_suffix(".bcs")


def parse(data: str) -> bytes:
    with BcsScript(NAME) as script:
        varmap = {"A": 1, "B": 2, "C": 3, "X": 4, "Y": 5, "Z": 6}
        chunks = Vector(
            [varmap[x] for x in data.strip().split()],
            name="INPUT",
            type_="u8",
        )
        script.write(chunks)
        return script.run()


if __name__ == "__main__":
    data = INPUT.read_text(encoding="utf-8")
    out = parse(data)
    OUTPUT.write_bytes(out)
