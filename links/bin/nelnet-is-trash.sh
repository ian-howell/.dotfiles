#!/bin/bash

# To use: go to nelnet, select a statement, ctrl-a, then run the following:
#
# echo "ctr-v" | nelnet-is-trash.sh

grep -e "Account Snapshot for" -e "Payoff \*" /tmp/f | paste -d' ' - - | sed -n 's/.*Group \([A-Z]*\) Estimated Payoff \* through [0-9/]* \. \(\$.[0-9,.]*\)\*.*This estimated amount is subject to change based on loan status, repayment plan, and other factors./\1:       \2/p'
