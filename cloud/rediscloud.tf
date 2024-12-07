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

data "rediscloud_essentials_plan" "rediscloud_essentials_plan_30mb" {
  name           = "30MB"
  cloud_provider = "AWS"
  region         = "us-east-1"
}

resource "rediscloud_essentials_subscription" "rediscloud_essentials_plan_30mb" {
  name    = "rediscloud_essentials_plan_30mb"
  plan_id = data.rediscloud_essentials_plan.rediscloud_essentials_plan_30mb.id
}

resource "rediscloud_essentials_database" "hangman_game_redis" {
  subscription_id     = rediscloud_essentials_subscription.rediscloud_essentials_plan_30mb.id
  name                = local.unique_name
  enable_default_user = true
  password            = "See_H0w_Fast_Fee1s"
  data_persistence    = "none"
  replication         = false
}
