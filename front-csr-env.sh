#!/bin/sh

## Set react env
ENV_FILE=/home/service/templates/.env
ENV_JS_FILE=/home/service/templates/build/static/js/env-config.js

# Create env-config.js
echo "window._env_ = {" > "${ENV_JS_FILE}"

# Read each line in .env file
while IFS='=' read -r name value || [[ -n "$name" ]];
do
  # Ignore if line is empty or starts with #
  if [ -z "$name" ] || [ "${name#\#}" != "$name" ]; then
    continue
  fi
  ## Check if environment variable is set
  # Bash shell
  # if [ -n "${!name}" ]; then
  #   value="${!name}"
  # fi
  # Bourne shell
  if [ -n "$(eval echo \$$name)" ]; then
    value=$(eval echo \$$name)
  fi

  # Write each env variable to the JS file
  echo "  $name: \"$value\"," >> "${ENV_JS_FILE}"
done < "${ENV_FILE}"

# Close the JavaScript object
echo "}" >> "${ENV_JS_FILE}"
