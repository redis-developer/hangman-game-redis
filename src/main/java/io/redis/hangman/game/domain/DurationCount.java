package io.redis.hangman.game.domain;

import com.fasterxml.jackson.annotation.JsonProperty;

public record DurationCount(
        @JsonProperty("duration") String duration,
        @JsonProperty("count") long count) {}
