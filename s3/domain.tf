# # generate ACM cert for domain :
# resource "aws_acm_certificate" "cert" {
#   domain_name               = var.domain_name
#   subject_alternative_names = ["*.${var.domain_name}"]
#   validation_method         = "DNS"
#   tags = {
#     "Project"   = "stakingpool.cloud"
#     "ManagedBy" = "Terraform"
#   }
# }
# # validate cert:
# resource "aws_route53_record" "certvalidation" {
#   for_each = {
#     for d in aws_acm_certificate.cert.domain_validation_options : d.domain_name => {
#       name   = d.resource_record_name
#       record = d.resource_record_value
#       type   = d.resource_record_type
#     }
#   }
#   allow_overwrite = true
#   name            = each.value.name
#   records         = [each.value.record]
#   ttl             = 60
#   type            = each.value.type
#   zone_id         = data.aws_route53_zone.hosted_zone.zone_id
# }
# resource "aws_acm_certificate_validation" "certvalidation" {
#   certificate_arn         = aws_acm_certificate.cert.arn
#   validation_record_fqdns = [for r in aws_route53_record.certvalidation : r.fqdn]
# }
# # creating A record for domain:
# resource "aws_route53_record" "websiteurl" {
#   name    = var.domain_name
#   zone_id = data.aws_route53_zone.hosted_zone.zone_id
#   type    = "A"
#   alias {
#     name                   = aws_cloudfront_distribution.cf_dist.domain_name
#     zone_id                = aws_cloudfront_distribution.cf_dist.hosted_zone_id
#     evaluate_target_health = true
#   }
# }

# #creating OAI :
# resource "aws_cloudfront_origin_access_identity" "oai" {
#   comment = "OAI for ${var.domain_name}"
# }

# # cloudfront terraform - creating AWS Cloudfront distribution :
# resource "aws_cloudfront_distribution" "cf_dist" {
#   enabled             = true
#   aliases             = [var.domain_name]
#   default_root_object = "index.html"
#   origin {
#     domain_name = aws_s3_bucket.staking-fe-bucket.bucket_regional_domain_name
#     origin_id   = aws_s3_bucket.staking-fe-bucket.id
#     s3_origin_config {
#       origin_access_identity = aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path
#     }
#   }
#   default_cache_behavior {
#     allowed_methods        = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
#     cached_methods         = ["GET", "HEAD", "OPTIONS"]
#     target_origin_id       = aws_s3_bucket.staking-fe-bucket.id
#     viewer_protocol_policy = "redirect-to-https" # other options - https only, http
#     forwarded_values {
#       headers      = []
#       query_string = true
#       cookies {
#         forward = "all"
#       }
#     }
#   }
#   restrictions {
#     geo_restriction {
#       restriction_type = "whitelist"
#       locations        = ["IN", "US", "CA"]
#     }
#   }
#   tags = {
#     "Project"   = "stakingpool.cloud"
#     "ManagedBy" = "Terraform"
#   }
#   viewer_certificate {
#     acm_certificate_arn      = aws_acm_certificate.cert.arn
#     ssl_support_method       = "sni-only"
#     minimum_protocol_version = "TLSv1.2_2018"
#   }
# }
