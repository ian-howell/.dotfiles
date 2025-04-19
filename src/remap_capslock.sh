#!/bin/bash

sudo sed -i '/XKBOPTIONS/c\\XKBOPTIONS="ctrl:nocaps"' /etc/default/keyboard
sudo dpkg-reconfigure -f noninteractive keyboard-configuration
