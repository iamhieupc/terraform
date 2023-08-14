output "sqs_url" {
  value = aws_sqs_queue.results_updates_queue.id
}
