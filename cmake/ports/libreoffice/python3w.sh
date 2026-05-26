#!/bin/bash
# Wrapper for MSYS2 Python that converts the script path from a Windows-style
# path (C:/...) to a POSIX path (/c/...) so the MSYS2 Python interpreter can
# find and execute it. Only the first argument (the script path) is converted;
# subsequent arguments are passed through unchanged so that scripts which use
# Windows paths for their own path comparisons (e.g. prefix-stripping) continue
# to work correctly.
if [[ "$1" =~ ^[A-Za-z]:[\\/] ]]; then
    exec /usr/bin/python3 "$(cygpath -u "$1")" "${@:2}"
else
    exec /usr/bin/python3 "$@"
fi
