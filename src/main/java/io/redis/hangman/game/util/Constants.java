package io.redis.hangman.game.util;

import java.util.List;
import java.util.Optional;

public interface Constants {
    String REDIS_CONNECTION_URL = System.getenv("REDIS_CONNECTION_URL");
    String ALLOWED_ORIGINS = System.getenv("ALLOWED_ORIGINS");

    String SCOREBOARD_KEY = "scoreboard";
    String GUESS_COUNT_KEY = "guess:count";
    String DURATION_COUNT_KEY = "duration:count";
    String FAILED_WORDS_KEY = "failed:words";

    String FAILED_WORDS_TOPK = Optional.ofNullable(
            System.getenv("FAILED_WORDS_TOPK"))
            .map(String::trim)
            .filter(s -> !s.isEmpty())
            .orElse("7");

    // Guesses:                            0/6     1/6     2/6     3/6     4/6     5/6     6/6
    List<String> GUESS_ATTEMPTS = List.of("1.00", "0.83", "0.67", "0.50", "0.33", "0.17", "0.00");
    List<String> GAME_DURATIONS = List.of("10", "20", "30", "40", "50", "60", "70");
}
