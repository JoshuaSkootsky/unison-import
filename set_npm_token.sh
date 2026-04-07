#!/bin/bash

# Check if NPM_AUTH_TOKEN is unset or empty
if [ -z "$NPM_AUTH_TOKEN" ]; then
  echo "Error: NPM_AUTH_TOKEN environment variable is not set."
  echo ""
  echo "Please set your token in the terminal before running this script:"
  echo "  export NPM_AUTH_TOKEN=your_token_here"
  echo ""
  echo "Instructions to get a token:"
  echo "1. Log in to https://www.npmjs.com"
  echo "2. Go to Access Tokens -> Generate New Token -> Classic -> Automation"
  echo "3. Copy the token and paste it into the command above."
  
  # Exit with a failure code
  exit 1
fi

# If the variable is set, configure npm
npm config set //registry.npmjs.org/:_authToken="$NPM_AUTH_TOKEN"

echo "Success: NPM authentication token has been configured."
