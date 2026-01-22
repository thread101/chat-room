#!/usr/bin/env bash

get_python() {
    if ! which python && ! which python3;then
        echo "python does not exist"
    fi
}

(exec `get_python` ./app.py)
