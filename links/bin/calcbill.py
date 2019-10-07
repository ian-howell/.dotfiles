#!/usr/bin/env python3

""" How to use this script:

    1. Go to att.com/my and sign in
    2. Click the blue plus bubble under "My bills"
    3. Click "See my bill"
    4. Under the "Bill total section, click the "Print" link
    5. On this page, select all the text (ctrl-a)
    6. Run the script, and paste all of the text into the console
    7. Hammer on the enter key a few times to scroll, then hit ctrl-d
"""
import sys

mickey_group = {"MICKEY", "KELLY", "ZAC", "ANTHONY"}
pam_group = {"PAM", "JENNA", "ANDREW"}
ian_group = {"IAN", "JAMI"}


def main():
    data = get_data_from_stdin()
    print_report(data)


def get_data_from_stdin():
    saving = False
    lines = sys.stdin.readlines()
    i = 0
    results = {
            "mickey_group": {},
            "pam_group": {},
            "ian_group": {},
            }
    while i < len(lines):
        line = lines[i]
        if line == "9 devices\n":
            saving = True
            results['monthly'] = parse_money(lines[i+1])
        if saving:
            name = line.split(" ", 1)[0]
            if name in mickey_group:
                results["mickey_group"][line.strip()] = parse_money(lines[i+1])
            if name in pam_group:
                results["pam_group"][line.strip()] = parse_money(lines[i+1])
            if name in ian_group:
                results["ian_group"][line.strip()] = parse_money(lines[i+1])
        i += 1
    return results


def parse_money(money_str):
    return float(money_str[1:-1])


def print_report(report):
    total = report['monthly']
    for group_name in report:
        if not group_name.endswith('group'):
            continue
        group = report[group_name]
        group_owner = group_name[:-len('_group')].title()
        group_total = total_for_group(group)
        total += group_total

        print("==============={: ^10}===============".format(group_owner))
        for person in group:
            name = person.split()[0].title()
            print("{: <30} {:>.2f}".format(name, group[person]))
        if group_owner == 'Ian':
            print("{: <30} {:>.2f}".format("Month charge", report['monthly']))
            group_total += report['monthly']
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
