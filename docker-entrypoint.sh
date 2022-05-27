#!/bin/sh

# import seed.sql if exists
SEED=seed.sql
if [ -f $SEED ]
  then
    mkdir .tmp && cat $SEED | sqlite .tmp/data.db
    echo "Imported data from $SEED"
fi

exec "$@"
