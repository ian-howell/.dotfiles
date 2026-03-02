#!/usr/bin/env python3

"""
AT&T bill splitter -- splits a family plan bill among billing groups.

Default mode fetches the bill automatically via browser automation.
Use --paste to enter bill text manually via stdin.
"""

import argparse
import sys

from calcbill_fetch import fetch_bill_text

mickey_group = {"MICKEY", "KELLY"}
ian_group = {"IAN", "JAMI", "ANDREW", "PAM"}
jenna_group = {"JENNA"}
zac_group = {"ZAC"}
anthony_group = {"ANTHONY"}

TRANSFER_ADJUSTMENTS = {
    "ian_group": 24.30,
    "zac_group": -24.30,
}


def main():
    parser = argparse.ArgumentParser(description="AT&T bill splitter")
    parser.add_argument(
        "--paste",
        action="store_true",
        help="Paste bill text into stdin instead of fetching",
    )
    args = parser.parse_args()

    if args.paste:
        data = parse_bill_text_from_stdin()
    else:
        text = fetch_bill_text()
        data = parse_bill_text(text)

    print_report(data)


def parse_bill_text(text):
    """Parse bill text from a string and return grouped charge data."""
    lines = [line for line in text.splitlines() if len(line) >= 3]
    return _parse_lines(lines)


def parse_bill_text_from_stdin():
    """Parse bill text from stdin (original paste workflow)."""
    lines = [line for line in sys.stdin.readlines() if len(line) >= 3]
    return _parse_lines(lines)


def _parse_lines(lines):
    """Core parsing logic shared by both input methods."""
    results = {
        "mickey_group": {},
        "ian_group": {},
        "jenna_group": {},
        "zac_group": {},
        "anthony_group": {},
    }
    for i, line in enumerate(lines):
        # explicitly passing a space forces the resulting list to have len >= 1
        name = line.split(" ", 1)[0]
        if name in mickey_group:
            results["mickey_group"][line] = parse_money(lines[i + 2])
        elif name in ian_group:
            results["ian_group"][line] = parse_money(lines[i + 2])
        elif name in jenna_group:
            results["jenna_group"][line] = parse_money(lines[i + 2])
        elif name in zac_group:
            results["zac_group"][line] = parse_money(lines[i + 2])
        elif name in anthony_group:
            results["anthony_group"][line] = parse_money(lines[i + 2])
    return results


def parse_money(money_str):
    return float(money_str.lstrip("$"))


def print_report(report):
    total = 0
    for group_name in sorted(report):
        group = report[group_name]
        # strip off the string "_group" from the group name and capitalize the group owner name
        group_owner = group_name[: -len("_group")].title()
        group_total = total_for_group(group_name, group)
        total += group_total

        print("==============={: ^10}===============".format(group_owner))
        if len(group) > 1:
            for person in sorted(group):
                name = person.split()[0].title()
                print("{: <30} {:>.2f}".format(name, group[person]))
            print("-" * 40)
        print("{: <30} {:>.2f}".format("Total", group_total))
        print()

    print("=" * 40)
    print("{:.<30} {:>.2f}".format("Total of totals", total))


def total_for_group(group_name, group):
    total = 0
    for person in group:
        total += group[person]
    return total + TRANSFER_ADJUSTMENTS.get(group_name, 0)


if __name__ == "__main__":
    main()
