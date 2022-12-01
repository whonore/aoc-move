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
const INPUT{i}: {const.type} = {str(const)};
public(friend) fun input{i}(): {const.type} {{ INPUT{i} }}
            """.strip() for i, const in enumerate(self.consts, start=1)
        )
        return f"""
module aoc22::{self.name}_in {{
    friend aoc22::{self.name};
    {consts}
}}
        """.strip()


class Vector:
    def __init__(self, vals: list[Any], type_: str) -> None:
        self.type = type_
        self.vals = vals

    def __str__(self) -> str:
        vals = ",".join(map(str, self.vals))
        return f"vector[\n{vals}\n]".strip()
