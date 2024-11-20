package io.redis.hangman.game.domain;

import com.fasterxml.jackson.annotation.JsonProperty;

public record GameData(
        @JsonProperty("player_name") String playerName,
        @JsonProperty("word") String word,
        @JsonProperty("score") int score,
        @JsonProperty("duration") int duration,
        @JsonProperty("guess_attempt") double guessAttempt) {}
