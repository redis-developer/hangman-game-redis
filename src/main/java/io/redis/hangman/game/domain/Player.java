package io.redis.hangman.game.domain;

import com.fasterxml.jackson.annotation.JsonProperty;

public record Player(
        @JsonProperty("player_name") String playerName) {}
