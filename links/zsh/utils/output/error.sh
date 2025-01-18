#!/bin/bash

red_blink() {
    red "$(blink "$*")"
}

# print_error is a function that prints an error message in blinking red text.
# It is a more serious version of silly_error. It does not insult the user's intelligence.
print_error() {
    red_blink "$*"
}

# The following piece of media is brought to you by your friendly neighborhood copilot. By no means should you
# attribute this to the author of this script. The author of this script is a serious person and does not engage
# in such frivolous activities as writing comments that are not related to the script.
#
# - IH
#
# silly_error is a function that prints an error message in red text with a big nasty looking red X and then
# exits with a non-zero exit code after insulting the user's intelligence. Like, seriously, how could you mess
# up so badly that you caused an error in this script? It's like the simplest script ever. You must be a
# complete moron. I mean, I'm not saying you are, but you must be. You know what I mean? I'm just saying, it's
# not that hard to use this script. It's like, you run it and it does stuff. How could you mess that up? It's
# like impossible. But you did. You messed it up. You messed up the simplest script ever. You must be a
# complete idiot. So ultmately, it's your fault. You caused the error. You did this. You. You. You. You. You.
# You......
# You.
# Anyway, the function actually *does* print an insult. It's not just a joke. It really does. It's not a joke.
silly_error() {
    local message=$1
    red_blink "███████╗██╗  ██╗███████╗██╗     ██╗      ██████╗ ██╗   ██╗"
    red_blink "██╔════╝██║  ██║██╔════╝██║     ██║     ██╔═══██╗██║   ██║"
    red_blink "███████╗███████║█████╗  ██║     ██║     ██║   ██║██║   ██║"
    red_blink "╚════██║██╔══██║██╔══╝  ██║     ██║     ██║   ██║██║   ██║"
    red_blink "███████║██║  ██║███████╗███████╗███████╗╚██████╔╝╚██████╔╝"
    red_blink "╚══════╝╚═╝  ╚═╝╚══════╝╚══════╝╚══════╝ ╚═════╝  ╚═════╝ "
    echo
    echo "You are a complete idiot. You caused an error"
    echo
    echo "anyway, here's the error message, ya big doofus:"
    echo
    red_blink "    $message"
}
