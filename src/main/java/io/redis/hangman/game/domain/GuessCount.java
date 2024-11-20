package io.redis.hangman.game.domain;

import com.fasterxml.jackson.annotation.JsonProperty;

public record GuessCount(
        @JsonProperty("guess_attempt") String guessAttempt,
        @JsonProperty("count") long count) {}
