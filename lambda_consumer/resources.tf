

data "archive_file" "lambda" {
  type        = "zip"
  source_file = "lambda_code/index.mjs"
  output_path = "lambda_code.zip"
}

resource "aws_lambda_function" "consumer" {
  filename      = "lambda_code.zip"
  function_name = "${var.name_prefix}-consumer"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "index.handler"

  source_code_hash = data.archive_file.lambda.output_base64sha256

  runtime = "nodejs18.x"

  environment {
    variables = {
      foo = "bar"
    }
  }
}

resource "aws_sqs_queue" "dead-letter-queue" {
  name                      = "${var.name_prefix}-deadletter-queue"
  max_message_size          = 2048
  message_retention_seconds = 86400
  receive_wait_time_seconds = 10
}

resource "aws_sqs_queue" "queue" {
  name                      = "${var.name_prefix}-queue"
  max_message_size          = 2048
  message_retention_seconds = 86400
  receive_wait_time_seconds = 10
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dead-letter-queue.arn
    maxReceiveCount     = 4
  })
}

resource "aws_lambda_event_source_mapping" "event_source_mapping" {
  event_source_arn = aws_sqs_queue.queue.arn
  function_name    = aws_lambda_function.consumer.arn
  batch_size       = 1
}