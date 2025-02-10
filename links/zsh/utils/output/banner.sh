#!/bin/bash

source "$HOME/.dotfiles/links/zsh/utils/output/colors.sh"

# print_banner prints the text cetnered in a banner that is 110 characters wide.
print_banner() {
  local text="$1"
  local text_length=${#text}
  local banner_length=110
  local padding_length=$(((($banner_length - $text_length) / 2) - 1))
  local padding=$(printf "%${padding_length}s")

  echo "+============================================================================================================="
  echo "|$padding$text$padding|"
  echo "+============================================================================================================="
}

print_red_banner() {
  print_banner $1 | black | red_bg
}

print_orange_banner() {
  print_banner $1 | black | orange_bg
}

print_yellow_banner() {
  print_banner $1 | black | yellow_bg
}

print_green_banner() {
  print_banner $1 | black | green_bg
}

print_blue_banner() {
  print_banner $1 | white | blue_bg
}

print_purple_banner() {
  print_banner $1 | black | purple_bg
}

print_cyan_banner() {
  print_banner $1 | black | cyan_bg
}

print_magenta_banner() {
  print_banner $1 | black | magenta_bg
}

print_white_banner() {
  print_banner $1 | black | white_bg
}

print_gray_banner() {
  print_banner $1 | black | gray_bg
}

print_light_gray_banner() {
  print_banner $1 | black | light_gray_bg
}

print_dark_gray_banner() {
  print_banner $1 | black | dark_gray_bg
}
