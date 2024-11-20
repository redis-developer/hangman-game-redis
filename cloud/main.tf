resource "random_string" "generated" {
  length  = 8
  special = false
  upper   = false
  lower   = true
  numeric = false
}

locals {
  unique_name = "hangman-game-redis-${random_string.generated.result}"
}
