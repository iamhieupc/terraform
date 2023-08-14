
resource "aws_sns_topic" "results_updates" {
  name = "results-updates-topic"
}

resource "aws_sqs_queue" "results_updates_queue" {
  name                       = "results-updates-queue"
  redrive_policy             = "{\"deadLetterTargetArn\":\"${aws_sqs_queue.results_updates_dl_queue.arn}\",\"maxReceiveCount\":5}"
  visibility_timeout_seconds = 300

  tags = {
    Environment = "dev"
  }
}

resource "aws_sqs_queue" "results_updates_dl_queue" {
  name = "results-updates-dl-queue"
}

resource "aws_sns_topic_subscription" "results_updates_sqs_target" {
  topic_arn = aws_sns_topic.results_updates.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.results_updates_queue.arn
}

resource "aws_sqs_queue_policy" "results_updates_queue_policy" {
  queue_url = aws_sqs_queue.results_updates_queue.id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "sqspolicy",
  "Statement": [
    {
      "Sid": "First",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "sqs:SendMessage",
      "Resource": "${aws_sqs_queue.results_updates_queue.arn}",
      "Condition": {
        "ArnEquals": {
          "aws:SourceArn": "${aws_sns_topic.results_updates.arn}"
        }
      }
    }
  ]
}
POLICY
}


