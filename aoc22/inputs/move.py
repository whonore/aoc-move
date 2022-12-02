from typing import Any


class Module:
    def __init__(self, name: str) -> None:
        self.name = name
        self.consts: list[Any] = []

    def add_const(self, const: Any) -> None:
        self.consts.append(const)

    def __str__(self) -> str:
        consts = "\n".join(
            f"""
const {const.name}: {const.type} = {str(const)};
public(friend) fun {const.name.lower()}(): {const.type} {{ {const.name} }}
            """.strip()
            for const in self.consts
        )
        return f"""
module aoc22::{self.name}_in {{
    friend aoc22::{self.name};
    {consts}
}}
        """.strip()


class Vector:
    def __init__(self, vals: list[Any], type_: str, *, name: str | None = None) -> None:
        self.name = name
        self.type = f"vector<{type_}>"
        self.vals = vals

    def __str__(self) -> str:
        vals = ",".join(map(str, self.vals))
        return f"vector[\n{vals}\n]"
