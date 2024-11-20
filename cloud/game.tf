provider "aws" {
}

###########################################
################# Bucket ##################
###########################################

resource "aws_s3_bucket" "hangman_game_redis" {
  bucket = local.unique_name
}

resource "aws_s3_bucket_website_configuration" "hangman_game_redis" {
  bucket = aws_s3_bucket.hangman_game_redis.id
  index_document {
    suffix = "index.html"
  }
  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_policy" "hangman_game_redis" {
  depends_on = [aws_s3_bucket_public_access_block.hangman_game_redis]
  bucket = aws_s3_bucket.hangman_game_redis.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.hangman_game_redis.arn}/*"
      },
    ]
  })
}

resource "aws_s3_bucket_ownership_controls" "hangman_game_redis" {
  bucket = aws_s3_bucket.hangman_game_redis.id
  rule {
    object_ownership = "ObjectWriter"
  }
}

resource "aws_s3_bucket_public_access_block" "hangman_game_redis" {
  bucket = aws_s3_bucket.hangman_game_redis.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "hangman_game_redis" {
  depends_on = [aws_s3_bucket_ownership_controls.hangman_game_redis]
  bucket = aws_s3_bucket.hangman_game_redis.id
  acl = "public-read"
}

resource "aws_s3_bucket_cors_configuration" "hangman_game_redis" {
  bucket = aws_s3_bucket.hangman_game_redis.id
  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "POST"]
    allowed_origins = ["*"]
  }
}

##########################################
################# HTML ###################
##########################################

resource "aws_s3_object" "index" {
  depends_on = [aws_s3_bucket_ownership_controls.hangman_game_redis]
  bucket       = aws_s3_bucket.hangman_game_redis.bucket
  key          = "index.html"
  content_type = "text/html"
  source       = "../game/index.html"
  etag         = filemd5("../game/index.html")
  acl          = "public-read"
}

resource "aws_s3_object" "error" {
  depends_on = [aws_s3_bucket_ownership_controls.hangman_game_redis]
  bucket       = aws_s3_bucket.hangman_game_redis.bucket
  key          = "error.html"
  content_type = "text/html"
  source       = "../game/error.html"
  etag         = filemd5("../game/error.html")
  acl          = "public-read"
}

resource "aws_s3_object" "style" {
  depends_on = [aws_s3_bucket_ownership_controls.hangman_game_redis]
  bucket       = aws_s3_bucket.hangman_game_redis.bucket
  key          = "style.css"
  content_type = "text/css"
  source       = "../game/style.css"
  etag         = filemd5("../game/style.css")
  acl          = "public-read"
}

###########################################
################### JS ####################
###########################################

resource "aws_s3_object" "apis" {
  depends_on = [aws_s3_bucket_ownership_controls.hangman_game_redis]
  bucket       = aws_s3_bucket.hangman_game_redis.bucket
  key          = "scripts/apis.js"
  content_type = "text/javascript"
  source       = "../game/scripts/apis.js"
  etag         = filemd5("../game/scripts/apis.js")
  acl          = "public-read"
}

resource "aws_s3_object" "local" {
  depends_on = [aws_s3_bucket_ownership_controls.hangman_game_redis]
  bucket       = aws_s3_bucket.hangman_game_redis.bucket
  key          = "scripts/local.js"
  content_type = "text/javascript"
  source       = "../game/scripts/local.js"
  etag         = filemd5("../game/scripts/local.js")
  acl          = "public-read"
}

resource "aws_s3_object" "cloud" {
  depends_on = [aws_s3_bucket_ownership_controls.hangman_game_redis]
  bucket       = aws_s3_bucket.hangman_game_redis.bucket
  key          = "scripts/cloud.js"
  content_type = "text/javascript"
  content = templatefile("../game/scripts/cloud.js", {
    words_api = "${aws_api_gateway_deployment.words_api_prod.invoke_url}${aws_api_gateway_resource.words_resource.path}"
    player_api = "${aws_api_gateway_deployment.player_api_prod.invoke_url}${aws_api_gateway_resource.player_resource.path}"
    game_api = "${aws_api_gateway_deployment.game_api_prod.invoke_url}${aws_api_gateway_resource.game_resource.path}"
    metrics_api = "${aws_api_gateway_deployment.metrics_api_prod.invoke_url}${aws_api_gateway_resource.metrics_resource.path}"
  })
  etag         = filemd5("../game/scripts/cloud.js")
  acl          = "public-read"
}

resource "aws_s3_object" "script" {
  depends_on = [aws_s3_bucket_ownership_controls.hangman_game_redis]
  bucket       = aws_s3_bucket.hangman_game_redis.bucket
  key          = "scripts/script.js"
  content_type = "text/javascript"
  source       = "../game/scripts/script.js"
  etag         = filemd5("../game/scripts/script.js")
  acl          = "public-read"
}

###########################################
################### IMG ###################
###########################################

resource "aws_s3_object" "svg_img_files" {
  depends_on = [aws_s3_bucket_ownership_controls.hangman_game_redis]
  for_each     = fileset(path.module, "../game/images/*.svg")
  bucket       = aws_s3_bucket.hangman_game_redis.bucket
  key          = replace(each.key, "../game/", "")
  content_type = "image/svg+xml"
  source       = each.value
  etag         = filemd5(each.key)
  acl          = "public-read"
}

resource "aws_s3_object" "gif_img_files" {
  depends_on = [aws_s3_bucket_ownership_controls.hangman_game_redis]
  for_each     = fileset(path.module, "../game/images/*.gif")
  bucket       = aws_s3_bucket.hangman_game_redis.bucket
  key          = replace(each.key, "../game/", "")
  content_type = "image/gif"
  source       = each.value
  etag         = filemd5(each.key)
  acl          = "public-read"
}

resource "aws_s3_object" "png_img_files" {
  depends_on = [aws_s3_bucket_ownership_controls.hangman_game_redis]
  for_each     = fileset(path.module, "../game/images/*.png")
  bucket       = aws_s3_bucket.hangman_game_redis.bucket
  key          = replace(each.key, "../game/", "")
  content_type = "image/png"
  source       = each.value
  etag         = filemd5(each.key)
  acl          = "public-read"
}

resource "aws_s3_object" "webp_img_files" {
  depends_on = [aws_s3_bucket_ownership_controls.hangman_game_redis]
  for_each     = fileset(path.module, "../game/images/*.webp")
  bucket       = aws_s3_bucket.hangman_game_redis.bucket
  key          = replace(each.key, "../game/", "")
  content_type = "image/webp"
  source       = each.value
  etag         = filemd5(each.key)
  acl          = "public-read"
}
