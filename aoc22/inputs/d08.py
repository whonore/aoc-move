from pathlib import Path

from move import BcsScript, Vector

NAME = Path(__file__).stem
INPUT = Path(__file__).with_suffix(".in")
OUTPUT = Path(__file__).with_suffix(".bcs")


def parse(data: str) -> bytes:
    with BcsScript(NAME) as script:
        cmds = Vector(
            [Vector(list(line), type_="u8") for line in data.strip().split("\n")],
            name="INPUT",
            type_="vector<u8>",
        )
        script.write(cmds)
        return script.run()


if __name__ == "__main__":
    data = INPUT.read_text(encoding="utf-8")
    out = parse(data)
    OUTPUT.write_bytes(out)
