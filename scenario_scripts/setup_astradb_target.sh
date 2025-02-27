#!/bin/bash

while true; do
  read -p "Enter your Astra DB env (dev, test, prod): " ASTRA_DB_ENV
  read -p "Enter your Astra DB token: " ASTRA_DB_TOKEN

  rm -f ~/.astrarc

  if astra setup --env="${ASTRA_DB_ENV^^}" --token "$ASTRA_DB_TOKEN"; then
    echo "Astra-CLI setup successful!"
    break
  else
    echo "Astra-CLI setup failed, please try again."
  fi
done

astra db list

while true; do
  read -p "Enter your Astra DB name: " ASTRA_DB_NAME
  if [[ -z "$ASTRA_DB_NAME" ]]; then
    echo "Error: Astra DB name cannot be empty."
    continue
  fi

  if astra db list | grep ACTIVE | grep -q "${ASTRA_DB_NAME}"; then
    echo "Database ${ASTRA_DB_NAME} found and is active."
    break
  else
    echo "Error: Astra DB name ${ASTRA_DB_NAME} does not exist. Please try again."
  fi
done

ASTRA_DB_CLOUD=$(astra db list --output=json | jq -r --arg name "$ASTRA_DB_NAME" '.data[] | select(.Name == $name) | .Cloud')

if [ -e step3-${ASTRA_DB_CLOUD}.md ]; then
  cp -a step3-${ASTRA_DB_CLOUD}.md step3.md
fi

# Replace all DevOps API URL according to the environment in *.md files
if [[ "${ASTRA_DB_ENV^^}" == "PROD" ]]; then
  new_url="https://api.astra.datastax.com"
elif [[ "${ASTRA_DB_ENV^^}" == "DEV" ]]; then
  new_url="https://api.dev.cloud.datastax.com"
elif [[ "${ASTRA_DB_ENV^^}" == "TEST" ]]; then
  new_url="https://api.test.cloud.datastax.com"
else
  echo "Unknown environment: ${ASTRA_DB_ENV}"
  exit 1
fi

for file in *.md; do
  sed -i -E "s~https://api\..*\.datastax\.com~${new_url}~g" "$file"
done

# Find all *.md files and perform replacements of Astra database names
find . -type f -name "*.md" -exec sed -i -E "
    s|(astra db cqlsh) [^ ]+|\1 ${ASTRA_DB_NAME}|g;
    s|(astra db create.* )[^ ]+|\1${ASTRA_DB_NAME}|g
" {} +

echo "All instructions updated according to the Astra DB inputs."
