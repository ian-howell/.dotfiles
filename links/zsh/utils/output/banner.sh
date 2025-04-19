#!/bin/bash

source "$HOME/.dotfiles/links/zsh/utils/output/colors.sh"

# print_banner prints the text centered in a banner of a specified width.
print_banner() {
    local text="$1"
    local banner_length="${2:-110}" # Default to 110 if no width is provided
    local text_length=${#text}
    local total_padding=$((banner_length - text_length))
    local left_padding_length=$((total_padding / 2))
    local right_padding_length=$((total_padding - left_padding_length))
    local left_padding=$(printf "%*s" "$left_padding_length" "")
    local right_padding=$(printf "%*s" "$right_padding_length" "")

    echo "+$(printf '=%.0s' $(seq 1 $banner_length))+"
    echo "|${left_padding}${text}${right_padding}|"
    echo "+$(printf '=%.0s' $(seq 1 $banner_length))+"
}

print_red_banner() {
  print_banner "$1" | black | red_bg
}

print_orange_banner() {
  print_banner "$1" | black | orange_bg
}

print_yellow_banner() {
  print_banner "$1" | black | yellow_bg
}

print_green_banner() {
  print_banner "$1" | black | green_bg
}

print_blue_banner() {
  print_banner "$1" | white | blue_bg
}

print_purple_banner() {
  print_banner "$1" | black | purple_bg
}

print_cyan_banner() {
  print_banner "$1" | black | cyan_bg
}

print_magenta_banner() {
  print_banner "$1" | black | magenta_bg
}

print_white_banner() {
  print_banner "$1" | black | white_bg
}

print_gray_banner() {
  print_banner "$1" | black | gray_bg
}

print_light_gray_banner() {
  print_banner "$1" | black | light_gray_bg
}

print_dark_gray_banner() {
  print_banner "$1" | black | dark_gray_bg
}
