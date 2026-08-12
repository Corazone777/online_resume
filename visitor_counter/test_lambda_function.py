"""
Tests for the visitor-counter Lambda.

DynamoDB is mocked with moto, so these run offline and never touch real
AWS. Run them from this folder with:  pytest -v
"""

import importlib
import json

import boto3
import pytest
from moto import mock_aws

TABLE_NAME = "cloud-resume-counter"
COUNTER_ID = "visitors"
REGION = "eu-central-1"


@pytest.fixture
def handler(monkeypatch):
    # Point the Lambda at the test table + a fake region/credentials.
    monkeypatch.setenv("DDB_TABLE", TABLE_NAME)
    monkeypatch.setenv("COUNTER_ID", COUNTER_ID)
    monkeypatch.setenv("AWS_DEFAULT_REGION", REGION)
    monkeypatch.setenv("AWS_ACCESS_KEY_ID", "testing")
    monkeypatch.setenv("AWS_SECRET_ACCESS_KEY", "testing")

    with mock_aws():
        boto3.resource("dynamodb", region_name=REGION).create_table(
            TableName=TABLE_NAME,
            KeySchema=[{"AttributeName": "id", "KeyType": "HASH"}],
            AttributeDefinitions=[{"AttributeName": "id", "AttributeType": "S"}],
            BillingMode="PAY_PER_REQUEST",
        )
        # Import the module *inside* the mock so its module-level DynamoDB
        # resource binds to the mocked backend. reload() rebinds it for
        # each test, since the module stays cached in sys.modules.
        import lambda_function

        importlib.reload(lambda_function)
        yield lambda_function


def test_first_visit_returns_one(handler):
    resp = handler.lambda_handler({}, None)
    assert resp["statusCode"] == 200
    assert json.loads(resp["body"])["count"] == 1


def test_count_increments_each_call(handler):
    handler.lambda_handler({}, None)
    handler.lambda_handler({}, None)
    resp = handler.lambda_handler({}, None)
    assert json.loads(resp["body"])["count"] == 3


def test_response_is_json_with_cors_header(handler):
    resp = handler.lambda_handler({}, None)
    assert resp["headers"]["Content-Type"] == "application/json"
    assert "Access-Control-Allow-Origin" in resp["headers"]
    assert isinstance(json.loads(resp["body"])["count"], int)
