package io.redis.hangman.game.domain;

import com.fasterxml.jackson.annotation.JsonProperty;

public record Word(
        @JsonProperty("word") String word,
        @JsonProperty("hint") String hint) {}
