#!/usr/bin/env python3

"""
How to use this script:
    1. Go to att.com/my and sign in
    2. Click "See charges and Payments"
    3. Click "Show bill details"
    5. Select all the text (ctrl-a)
    6. Run the script, and paste all of the text into the console
    7. Hammer on the enter key a few times to scroll, then hit ctrl-d
"""

import sys

mickey_group = {"MICKEY", "KELLY"}
ian_group = {"IAN", "JAMI", "ANDREW", "PAM"}
jenna_group = {"JENNA"}
zac_group = {"ZAC"}
anthony_group = {"ANTHONY"}


def main(args):
    debug_log = lambda x: None
    if len(args) == 2 and args[1] == "--debug":
        debug_log = lambda msg: print(f"DEBUG: {msg}")
    data = get_data_from_stdin(debug_log=debug_log)
    print_report(data)


def get_data_from_stdin(debug_log=lambda: None):
    # line length limiter is "mostly arbitrary". This should filter out empty lines and lines that only have
    # white space, but should retain the valuable lines with real data
    lines = [line for line in sys.stdin.readlines() if len(line) >= 3]
    results = {
        "mickey_group": {},
        "ian_group": {},
        "jenna_group": {},
        "zac_group": {},
        "anthony_group": {},
    }
    for i, line in enumerate(lines):
        debug_log(f"{i=} {line=}")
        # explicitly passing a space forces the resulting list to have len >= 1
        name = line.split(" ", 1)[0]
        if name in mickey_group:
            debug_log(f"matched 'mickey_group', parsing {lines[i+2]=}")
            results["mickey_group"][line] = parse_money(lines[i + 2])
        elif name in ian_group:
            debug_log(f"matched 'ian_group', parsing {lines[i+2]=}")
            results["ian_group"][line] = parse_money(lines[i + 2])
        elif name in jenna_group:
            debug_log(f"matched 'jenna_group', parsing {lines[i+2]=}")
            results["jenna_group"][line] = parse_money(lines[i + 2])
        elif name in zac_group:
            debug_log(f"matched 'zac_group', parsing {lines[i+2]=}")
            results["zac_group"][line] = parse_money(lines[i + 2])
        elif name in anthony_group:
            debug_log(f"matched 'anthony_group', parsing {lines[i+2]=}")
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
        group_total = total_for_group(group)
        total += group_total

        print("==============={: ^10}===============".format(group_owner))
        for person in sorted(group):
            name = person.split()[0].title()
            print("{: <30} {:>.2f}".format(name, group[person]))
        print("-" * 40)
        print("{: <30} {:>.2f}".format("Total", group_total))
        print()

    print("=" * 40)
    print("{:.<30} {:>.2f}".format("Total of totals", total))


def total_for_group(group):
    total = 0
    for person in group:
        total += group[person]
    return total


if __name__ == "__main__":
    main(sys.argv)
