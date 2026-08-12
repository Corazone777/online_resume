"""
Cloud Resume Challenge - visitor counter Lambda.

Runs behind a Lambda Function URL. On each invocation it atomically
increments a single counter item in DynamoDB and returns the new total
as JSON: {"count": <n>}.
"""

import json
import os

import boto3

# --- configuration (set these as environment variables on the Lambda) ---
DDB_TABLE = os.environ.get("DDB_TABLE", "visitor_counter")
COUNTER_ID = os.environ.get("COUNTER_ID", "visitors")
# The origin allowed to call this endpoint. "*" is fine while testing;
# set it to your real site (e.g. https://yourdomain.com) in production.
ALLOWED_ORIGIN = os.environ.get("ALLOWED_ORIGIN", "cv.atlas-arcade-tech.com")

# Built once per warm container and reused across invocations.
_table = boto3.resource("dynamodb").Table(DDB_TABLE)


def _response(status_code, body):
    return {
        "statusCode": status_code,
        "headers": {
            "Content-Type": "application/json",
            # CORS: the browser needs this because your site and this API
            # live on different origins. Leave the Function URL's own CORS
            # config EMPTY so this header isn't sent twice - a duplicate
            # Access-Control-Allow-Origin makes the browser reject the call.
            "Access-Control-Allow-Origin": ALLOWED_ORIGIN,
        },
        "body": json.dumps(body),
    }


def lambda_handler(event, context):
    try:
        result = _table.update_item(
            Key={"id": COUNTER_ID},
            # `count` is a DynamoDB reserved word, so it's aliased as #c.
            # if_not_exists seeds it to 0 on the very first call, so we
            # never have to pre-create the item by hand.
            UpdateExpression="SET #c = if_not_exists(#c, :zero) + :inc",
            ExpressionAttributeNames={"#c": "count"},
            ExpressionAttributeValues={":inc": 1, ":zero": 0},
            ReturnValues="UPDATED_NEW",
        )
        new_count = int(result["Attributes"]["count"])
        return _response(200, {"count": new_count})
    except Exception as err:  # log it, surface a clean 500 to the caller
        print(f"Error updating visitor count: {err}")
        return _response(500, {"error": "could not update visitor count"})
