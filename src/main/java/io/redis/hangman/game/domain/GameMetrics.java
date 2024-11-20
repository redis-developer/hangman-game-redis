package io.redis.hangman.game.domain;

import com.fasterxml.jackson.annotation.JsonProperty;

import java.util.List;

public record GameMetrics(
        @JsonProperty("scoreboard") List<ScoreboardItem> scoreboard,
        @JsonProperty("guess_count") List<GuessCount> guessCount,
        @JsonProperty("duration_count") List<DurationCount> durationCount,
        @JsonProperty("failed_words") List<FailedWord> failedWords) {}
