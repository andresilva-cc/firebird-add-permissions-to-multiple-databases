# Firebird - Add permissions to multiple databases

## About

A script that add permissions to multiple Firebird databases.

Tested on CentOS 7 with Firebird SuperClassic.

## Setup

1. Add the databases paths to `database.list`
2. Change the user that will be granted permissions on line 2 of `add_permissions.sh`
3. Change the desired permission on line 60 of `add_permissions.sh`. By default, it will grant all permissions

## Execution

Just run `add_permissions.sh`.