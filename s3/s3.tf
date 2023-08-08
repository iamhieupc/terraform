variable "bucket_name" {
  default = "staking-fe-bucket"
}

resource "aws_s3_bucket" "staking-fe-bucket" {
  bucket = "${var.bucket_name}"
} 

resource "aws_s3_bucket_website_configuration" "example" {
  bucket = aws_s3_bucket.staking-fe-bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }
}

resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.staking-fe-bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_ownership_controls" "example" {
  bucket = aws_s3_bucket.staking-fe-bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "example" {
  depends_on = [
	aws_s3_bucket_public_access_block.example,
	aws_s3_bucket_ownership_controls.example,
  ]

  bucket = aws_s3_bucket.staking-fe-bucket.id
  acl    = "public-read"
}

resource "aws_s3_bucket_policy" "allow_access_from_another_account" {
  bucket = aws_s3_bucket.staking-fe-bucket.id
  policy = data.aws_iam_policy_document.allow_access_from_another_account.json
}

data "aws_iam_policy_document" "allow_access_from_another_account" {
  statement {
    principals {
      type = "*"
	    identifiers = ["*"]
    }
    actions = [
      "s3:GetObject",
      "s3:ListBucket",
    ]
    resources = [
      aws_s3_bucket.staking-fe-bucket.arn,
      "${aws_s3_bucket.staking-fe-bucket.arn}/*",
    ]
  }
}

output "website_domain" {
  value = aws_s3_bucket.staking-fe-bucket.website_domain
}

output "website_endpoint" {
  value = aws_s3_bucket.staking-fe-bucket.website_endpoint
}