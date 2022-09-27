#!/bin/bash

# EXIT CODES

# back up database
sqlite3 "$BITWARDEN_DIR/data/db.sqlite3" ".backup '/path/to/backups/db_$(date '+%Y-%m-%d_%H-%M').sqlite3'"

# backup up attachments
cp "$BITWARDEN_DIR/data/attachments"

# back up sends
cp "$BITWARDEN_DIR/data/sends"

