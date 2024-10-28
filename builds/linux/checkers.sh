#!/bin/sh
echo -ne '\033c\033]0;9_10_24_checkers\a'
base_path="$(dirname "$(realpath "$0")")"
"$base_path/checkers.x86_64" "$@"
