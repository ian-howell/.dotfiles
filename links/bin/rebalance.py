#!/usr/bin/python3

import sys


def main():
    if len(sys.argv) != 4:
        print(f'Usage: {sys.argv[0]} <total> <fzrox> <fzilx>')
        return

    # Remove decimals to make these number of cents
    # Also remove commas, since they come over in copy/paste
    current_total = int(sys.argv[1].replace('.', '').replace(',', ''))
    current_fzrox = int(sys.argv[2].replace('.', '').replace(',', ''))
    current_fzilx = int(sys.argv[3].replace('.', '').replace(',', ''))

    want_fzrox = int(0.75 * current_total)
    want_fzilx = current_total - want_fzrox

    need_to_buy_fzrox = round((want_fzrox - current_fzrox) / 100, 2)
    need_to_buy_fzilx = round((want_fzilx - current_fzilx) / 100, 2)

    print(f'Purchase the following:')
    print(f'FZROX: {need_to_buy_fzrox}')
    print(f'FZILX: {need_to_buy_fzilx}')


main()
