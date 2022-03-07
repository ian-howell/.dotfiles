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

mickey_group = {"MICKEY", "KELLY", "ZAC", "ANTHONY"}
pam_group = {"PAM", "PAMELA", "JENNA", "ANDREW"}
ian_group = {"IAN", "JAMI"}


def main():
    data = get_data_from_stdin()
    print_report(data)


def get_data_from_stdin():
    lines = sys.stdin.readlines()
    results = {
            "mickey_group": {},
            "pam_group": {},
            "ian_group": {},
            }
    for i, line in enumerate(lines):
        # explicitly passing a space forces the resulting list to have len >= 1
        name = line.split(" ", 1)[0]
        if name in mickey_group:
            results["mickey_group"][line] = parse_money(lines[i+1])
        elif name in pam_group:
            results["pam_group"][line] = parse_money(lines[i+1])
        elif name in ian_group:
            results["ian_group"][line] = parse_money(lines[i+1])
    return results


def parse_money(money_str):
    return float(money_str.lstrip("$"))


def print_report(report):
    total = 0
    for group_name in sorted(report):
        group = report[group_name]
        # strip off the string "_group" from the group name and capitalize the group owner name
        group_owner = group_name[:-len('_group')].title()
        group_total = total_for_group(group)
        total += group_total

        print("==============={: ^10}===============".format(group_owner))
        for person in sorted(group):
            name = person.split()[0].title()
            print("{: <30} {:>.2f}".format(name, group[person]))
        print('-' * 40)
        print("{: <30} {:>.2f}".format("Total", group_total))
        print()

    print()

    print("{:.<30} {:>.2f}".format("Total of totals", total))


def total_for_group(group):
    total = 0
    for person in group:
        total += group[person]
    return total


if __name__ == "__main__":
    main()
