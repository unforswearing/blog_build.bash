#!/usr/bin/env bash

pushd /var/www
git pull https://thisdoesntexistanymore.com/unforswearing/unforswearing.com
popd
dirs -c
