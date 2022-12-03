import subprocess
from pathlib import Path
from typing import Any

SCRIPTS = Path(__file__).parent.parent / "scripts"


class BcsScript:
    def __init__(self, name: str) -> None:
        self.path = SCRIPTS / f"{name}.move"

    def __enter__(self) -> "BcsScript":
        self.path.open("w", encoding="utf-8")
        return self

    def __exit__(self, exc_type: Any, exc_value: Any, traceback: Any) -> None:
        self.path.unlink(missing_ok=True)

    def write(self, data: "MoveData") -> None:
        assert data.name is not None
        script = f"""
script {{
    use std::bcs;
    use std::debug;

    const {data.name}: {data.type} = {str(data)};

    fun init() {{
        debug::print(&bcs::to_bytes(&{data.name}));
    }}
}}
        """.strip()
        self.path.write_text(script, encoding="utf-8")

    def run(self) -> bytes:
        assert self.path.exists()
        out = subprocess.run(
            ["move", "sandbox", "run", str(self.path)],
            capture_output=True,
            check=True,
            encoding="utf-8",
        ).stdout
        return bytes.fromhex(out.strip().split("x")[1])


class MoveData:
    def __init__(self, type_: str, *, name: str | None = None) -> None:
        self.name = name
        self.type = type_

    def __str__(self) -> str:
        raise NotImplementedError


class Vector(MoveData):
    def __init__(self, vals: list[Any], type_: str, *, name: str | None = None) -> None:
        super().__init__(name=name, type_=f"vector<{type_}>")
        self.vals = vals

    def __str__(self) -> str:
        vals = ",".join(map(str, self.vals))
        return f"vector[\n{vals}\n]"


class Bytes(MoveData):
    def __init__(self, bytes: str, *, name: str | None = None) -> None:
        super().__init__(name=name, type_="vector<u8>")
        self.bytes = bytes

    def __str__(self) -> str:
        return f'b"{self.bytes}"'
