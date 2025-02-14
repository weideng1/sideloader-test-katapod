#!/bin/bash

# Prompt user for the Astra DB name
read -p "Enter your Astra DB name: " ASTRA_DB_NAME

# Validate input
if [[ -z "$ASTRA_DB_NAME" ]]; then
    echo "Error: Astra DB name cannot be empty."
    exit 1
fi

# Find all *.md files and perform replacements
find . -type f -name "*.md" -exec sed -i -E "
    s|(astra db cqlsh) [^ ]+|\1 $ASTRA_DB_NAME|g;
    s|(astra db create.* )[^ ]+|\1$ASTRA_DB_NAME|g
" {} +

echo "Replacement complete."
echo "- Updated 'astra db cqlsh' references with '$ASTRA_DB_NAME'"
echo "- Updated 'astra db create ...' references, replacing only the last word, with '$ASTRA_DB_NAME' in all *.md files."
