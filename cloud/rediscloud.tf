terraform {
  required_providers {
    rediscloud = {
      source  = "RedisLabs/rediscloud"
      version = "1.8.1"
    }
  }
}

provider "rediscloud" {
}

data "rediscloud_essentials_plan" "rediscloud_essentials_plan" {
  name           = "30MB"
  cloud_provider = "AWS"
  region         = "us-east-1"
}

resource "rediscloud_essentials_subscription" "hangman_game_redis" {
  name    = local.unique_name
  plan_id = data.rediscloud_essentials_plan.rediscloud_essentials_plan.id
}

resource "rediscloud_essentials_database" "hangman_game_redis" {
  subscription_id     = rediscloud_essentials_subscription.hangman_game_redis.id
  name                = local.unique_name
  enable_default_user = true
  password            = "See_H0w_Fast_Fee1s"
  data_persistence    = "none"
  replication         = false
}
