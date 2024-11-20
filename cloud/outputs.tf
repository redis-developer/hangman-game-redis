output "Game" {
  value = "http://${aws_s3_bucket_website_configuration.hangman_game_redis.website_endpoint}"
}
