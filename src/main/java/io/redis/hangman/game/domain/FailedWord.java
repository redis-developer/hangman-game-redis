package io.redis.hangman.game.domain;

import com.fasterxml.jackson.annotation.JsonProperty;

public record FailedWord(
        @JsonProperty("word") String word,
        @JsonProperty("count") long count) {}
