#!/bin/sh

# import seed.sql if exists
SEED=seed.sql
[ -f $SEED ] && mkdir .tmp && cat $SEED | sqlite .tmp/data.db

exec "$@"
