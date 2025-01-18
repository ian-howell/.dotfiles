#!/bin/bash

# All of the following can be combined. So for example, to get a red background with white text:
# echo $(red_bg $(white "Hello, World!"))

# These functions return a colorized string
red() { echo -e "\033[38;2;255;0;0m$*\033[0m"; }
orange() { echo -e "\033[38;2;255;165;0m$*\033[0m"; }
yellow() { echo -e "\033[38;2;255;255;0m$*\033[0m"; }
green() { echo -e "\033[38;2;0;255;0m$*\033[0m"; }
blue() { echo -e "\033[38;2;0;0;255m$*\033[0m"; }
purple() { echo -e "\033[38;2;128;0;128m$*\033[0m"; }
cyan() { echo -e "\033[38;2;0;255;255m$*\033[0m"; }
magenta() { echo -e "\033[38;2;255;0;255m$*\033[0m"; }
white() { echo -e "\033[38;2;255;255;255m$*\033[0m"; }
black() { echo -e "\033[38;2;0;0;0m$*\033[0m"; }
light_gray() { echo -e "\033[38;2;128;128;128m$*\033[0m"; }
gray() { echo -e "\033[38;2;64;64;64m$*\033[0m"; }
dark_gray() { grey "$*"; }

# These functions return a string colorized with a background color
red_bg() { echo -e "\033[48;2;255;0;0m$*\033[0m"; }
orange_bg() { echo -e "\033[48;2;255;165;0m$*\033[0m"; }
yellow_bg() { echo -e "\033[48;2;255;255;0m$*\033[0m"; }
green_bg() { echo -e "\033[48;2;0;255;0m$*\033[0m"; }
blue_bg() { echo -e "\033[48;2;0;0;255m$*\033[0m"; }
purple_bg() { echo -e "\033[48;2;128;0;128m$*\033[0m"; }
cyan_bg() { echo -e "\033[48;2;0;255;255m$*\033[0m"; }
magenta_bg() { echo -e "\033[48;2;255;0;255m$*\033[0m"; }
white_bg() { echo -e "\033[48;2;255;255;255m$*\033[0m"; }
black_bg() { echo -e "\033[48;2;0;0;0m$*\033[0m"; }
light_gray_bg() { echo -e "\033[48;2;128;128;128m$*\033[0m"; }
gray_bg() { echo -e "\033[48;2;64;64;64m$*\033[0m"; }
dark_gray_bg() { grey_bg "$*"; }

# These functions return stylized strings
bold() { echo -e "\033[1m$*\033[0m"; }
italic() { echo -e "\033[3m$*\033[0m"; }
underline() { echo -e "\033[4m$*\033[0m"; }
strikethrough() { echo -e "\033[9m$*\033[0m"; }
# I know it sounds like a joke, but this is actually sick. Use it often.
blink() { echo -e "\033[5m$*\033[0m"; }
inverse() { echo -e "\033[7m$*\033[0m"; }
