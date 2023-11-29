#!/usr/bin/env python3.9

"""
How to use this script:
    1. Go to nelnet.com and sign in
    2. Click "Documents > Statements"
    3. Click on a statement
    5. Select all the text (ctrl-a)
    6. Run the script, and paste all of the text into the console
    7. Hammer on the enter key a few times to scroll, then hit ctrl-d
"""
from pprint import pprint
import sys

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
    results = []
    for i, line in enumerate(lines):
        line = line.strip()
        debug_log(f"{i=} {line=}")
        # explicitly passing a space forces the resulting list to have len >= 1
        if line.startswith("Account Snapshot for:"):
            loan = {
                    "name": line[-1],
                    "rate": None,
                    "amount": None,
                    }
            while None in (loan["rate"], loan["amount"]):
                i += 1
                line = lines[i].strip()
                debug_log(f"  {i=} {line=}")
                if line.startswith("Interest Rate is "):
                    loan["rate"]  = float(line.removeprefix("Interest Rate is ").removesuffix("%"))
                if line.startswith("Estimated Payoff * through"):
                    dollar_index = line.index("$")
                    star_index = line.rindex("*")
                    debug_log(f"{line[dollar_index:star_index]}")
                    loan["amount"] = parse_money(line[dollar_index:star_index])
            results += [loan]


    return results


def parse_money(money_str):
    return float(money_str.replace(",", "").lstrip("$"))


def print_report(data):
    for loan in sorted(data, key=lambda x: x["rate"], reverse=True):
        print("{:.2f} - {}:     ${:.2f}".format(loan['rate'], loan['name'], loan['amount']))


if __name__ == "__main__":
    main(sys.argv)
