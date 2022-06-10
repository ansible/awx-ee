#!/bin/bash -e

DIRTY=$(git status --porcelain | wc -l)
if [ "$DIRTY" -ne 0 ]; then
    echo "ERROR: ansible-builder context is out of date, please re-run: "
    echo ""
    echo "    tox -edocker"
    echo ""
    echo "And commit changes."
    git status
    git diff
    exit 1
fi

