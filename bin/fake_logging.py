#!/usr/bin/python3
#
# Created by Ian Howell on 02/19/18.
# File name: fake_logging.py
import random
import sys
import time

def main():
    while True:
        fake_log()
        time.sleep(random.uniform(0, 3))


def fake_log():
    pull_from = "abcdefghijklmnopqrstuvwzyzABCDEFGHIJKLMNOPQRSTUVWZYZ1234567890"
    my_str = ""
    for i in range(random.randrange(50, 60)):
        my_str += random.choice(pull_from)
    print("[INFO]: reading {}".format(my_str))
    if random.uniform(0, 1) < 0.1:
        print("[WARN]: couldn't read {}".format(my_str))
    sys.stdout.flush()


if __name__ == "__main__":
    main()
