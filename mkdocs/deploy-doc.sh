#!/bin/bash

docker run --rm -it -v "$PWD":/docs squidfunk/mkdocs-material build
# python3 -m http.server 3000 --directory ~/mkdocs/site --bind 0.0.0.0 &


