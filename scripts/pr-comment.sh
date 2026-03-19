#!/bin/bash

if [ "$#" -ne 5 ]; then
    echo "Usage: $0 <PR_NUMBER> <FILE_PATH> <LINE_NUMBER> <COMMENT_BODY> <REPO_WITH_OWNER>"
    exit 1
fi

PR_NUMBER=$1
FILE_PATH=$2
LINE_NUMBER=$3
COMMENT_BODY=$4
REPO_WITH_OWNER=$5

echo "Submitting inline comment to PR #$PR_NUMBER in $REPO_WITH_OWNER at $FILE_PATH:$LINE_NUMBER..."

# Create the JSON payload. We omit commit_id so GitHub handles it automatically.
JSON_PAYLOAD=$(jq -n \
  --arg path "$FILE_PATH" \
  --argjson line "$LINE_NUMBER" \
  --arg body "$COMMENT_BODY" \
  '{
    event: "COMMENT",
    comments: [
      {
        path: $path,
        line: $line,
        side: "RIGHT",
        body: $body
      }
    ]
  }')

# Send to the Reviews API
echo "$JSON_PAYLOAD" | gh api \
  --method POST \
  -H "Accept: application/vnd.github+json" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  "/repos/$REPO_WITH_OWNER/pulls/$PR_NUMBER/reviews" \
  --input -

echo "Done."
