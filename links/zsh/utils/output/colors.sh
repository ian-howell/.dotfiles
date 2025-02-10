#!/bin/bash

# The following variables represent the "start" of a sequence. All sequences must end with FMT_ENG.
# Variables can be combined to create a sequence. For example, to create a red background with white text:
# echo "${FMT_RED_BG}${FG_WHITE}Hello, World!${FMT_END}"
FMT_END="\033[0m"
FMT_RED="\033[38;2;255;0;0m"
FMT_ORANGE="\033[38;2;255;165;0m"
FMT_YELLOW="\033[38;2;255;255;0m"
FMT_GREEN="\033[38;2;0;255;0m"
FMT_BLUE="\033[38;2;0;0;255m"
FMT_PURPLE="\033[38;2;128;0;128m"
FMT_CYAN="\033[38;2;0;255;255m"
FMT_MAGENTA="\033[38;2;255;0;255m"
FMT_WHITE="\033[38;2;255;255;255m"
FMT_BLACK="\033[38;2;0;0;0m"
FMT_LIGHT_GRAY="\033[38;2;128;128;128m"
FMT_GRAY="\033[38;2;64;64;64m"
FMT_DARK_GRAY="\033[38;2;64;64;64m"

FMT_BOLD="\033[1m"
FMT_ITALIC="\033[3m"
FMT_UNDERLINE="\033[4m"
FMT_STRIKETHROUGH="\033[9m"
FMT_BLINK="\033[5m"
FMT_INVERSE="\033[7m"

FMT_RED_BG="\033[48;2;255;0;0m"
FMT_ORANGE_BG="\033[48;2;255;165;0m"
FMT_YELLOW_BG="\033[48;2;255;255;0m"
FMT_GREEN_BG="\033[48;2;0;255;0m"
FMT_BLUE_BG="\033[48;2;0;0;255m"
FMT_PURPLE_BG="\033[48;2;128;0;128m"
FMT_CYAN_BG="\033[48;2;0;255;255m"
FMT_MAGENTA_BG="\033[48;2;255;0;255m"
FMT_WHITE_BG="\033[48;2;255;255;255m"
FMT_BLACK_BG="\033[48;2;0;0;0m"
FMT_LIGHT_GRAY_BG="\033[48;2;128;128;128m"
FMT_GRAY_BG="\033[48;2;64;64;64m"
FMT_DARK_GRAY_BG="\033[48;2;64;64;64m"

# All of the following can be combined. So for example, to get a red background with white text:
# echo $(red_bg $(white "Hello, World!"))

# These functions return a colorized string
red() { while IFS= read -r line; do echo -e "$FMT_RED$line$FMT_END"; done; }
orange() { while IFS= read -r line; do echo -e "$FMT_ORANGE$line$FMT_END"; done; }
yellow() { while IFS= read -r line; do echo -e "$FMT_YELLOW$line$FMT_END"; done; }
green() { while IFS= read -r line; do echo -e "$FMT_GREEN$line$FMT_END"; done; }
blue() { while IFS= read -r line; do echo -e "$FMT_BLUE$line$FMT_END"; done; }
purple() { while IFS= read -r line; do echo -e "$FMT_PURPLE$line$FMT_END"; done; }
cyan() { while IFS= read -r line; do echo -e "$FMT_CYAN$line$FMT_END"; done; }
magenta() { while IFS= read -r line; do echo -e "$FMT_MAGENTA$line$FMT_END"; done; }
white() { while IFS= read -r line; do echo -e "$FMT_WHITE$line$FMT_END"; done; }
black() { while IFS= read -r line; do echo -e "$FMT_BLACK$line$FMT_END"; done; }
light_gray() { while IFS= read -r line; do echo -e "$FMT_LIGHT_GRAY$line$FMT_END"; done; }
gray() { while IFS= read -r line; do echo -e "$FMT_GRAY$line$FMT_END"; done; }
dark_gray() { grey "$*"; }

# These functions return a string colorized with a background color
red_bg() { while IFS= read -r line; do echo -e "$FMT_RED_BG$line$FMT_END"; done; }
orange_bg() { while IFS= read -r line; do echo -e "$FMT_ORANGE_BG$line$FMT_END"; done; }
yellow_bg() { while IFS= read -r line; do echo -e "$FMT_YELLOW_BG$line$FMT_END"; done; }
green_bg() { while IFS= read -r line; do echo -e "$FMT_GREEN_BG$line$FMT_END"; done; }
blue_bg() { while IFS= read -r line; do echo -e "$FMT_BLUE_BG$line$FMT_END"; done; }
purple_bg() { while IFS= read -r line; do echo -e "$FMT_PURPLE_BG$line$FMT_END"; done; }
cyan_bg() { while IFS= read -r line; do echo -e "$FMT_CYAN_BG$line$FMT_END"; done; }
magenta_bg() { while IFS= read -r line; do echo -e "$FMT_MAGENTA_BG$line$FMT_END"; done; }
white_bg() { while IFS= read -r line; do echo -e "$FMT_WHITE_BG$line$FMT_END"; done; }
black_bg() { while IFS= read -r line; do echo -e "$FMT_BLACK_BG$line$FMT_END"; done; }
light_gray_bg() { while IFS= read -r line; do echo -e "$FMT_LIGHT_GRAY_BG$line$FMT_END"; done; }
gray_bg() { while IFS= read -r line; do echo -e "$FMT_GRAY_BG$line$FMT_END"; done; }
dark_gray_bg() { while IFS= read -r line; do echo -e "$FMT_DARK_GRAY_BG$line$FMT_END"; done; }

# These functions return stylized strings
bold() { while IFS= read -r line; do echo -e "$FMT_BOLD$line$FMT_END"; done; }
italic() { while IFS= read -r line; do echo -e "$FMT_ITALIC$line$FMT_END"; done; }
underline() { while IFS= read -r line; do echo -e "$FMT_UNDERLINE$line$FMT_END"; done; }
strikethrough() { while IFS= read -r line; do echo -e "$FMT_STRIKETHROUGH$line$FMT_END"; done; }
# I know it sounds like a joke, but this is actually sick. Use it often.
blink() { while IFS= read -r line; do echo -e "$FMT_BLINK$line$FMT_END"; done; }
inverse() { while IFS= read -r line; do echo -e "$FMT_INVERSE$line$FMT_END"; done; }
