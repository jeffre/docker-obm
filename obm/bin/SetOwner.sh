#!/bin/sh

run()
{
    CMD="ls -ald \"$1\" | awk '{ system(\"chown -R \" \$3 \":\" \$4 \" $1\") }'"
    echo $CMD
    eval $CMD
}

run $1
