package io.redis.hangman.game.domain;

import com.fasterxml.jackson.annotation.JsonProperty;

public record ScoreboardItem(
        @JsonProperty("player_name") String playerName,
        @JsonProperty("score") long score) {}
