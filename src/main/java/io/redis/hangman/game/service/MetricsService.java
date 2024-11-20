package io.redis.hangman.game.service;

import io.redis.hangman.game.domain.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.redis.core.RedisCallback;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.data.redis.core.ZSetOperations;
import org.springframework.stereotype.Service;
import redis.clients.jedis.bloom.RedisBloomProtocol;

import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;
import java.util.stream.IntStream;

import static io.redis.hangman.game.util.Constants.*;

@Service
public class MetricsService {

    @Autowired
    private RedisTemplate<String, String> redisTemplate;

    public GameMetrics getMetrics() {
        List<Object> pipelinedResults = redisTemplate.executePipelined(
            (RedisCallback<Void>) connection -> {
                connection.zRevRangeWithScores(SCOREBOARD_KEY.getBytes(), 0, -1);
                connection.hGetAll(GUESS_COUNT_KEY.getBytes());
                connection.hGetAll(DURATION_COUNT_KEY.getBytes());
                connection.commands().execute(
                    new String(RedisBloomProtocol.TopKCommand.LIST.getRaw()),
                    FAILED_WORDS_KEY.getBytes(),
                    RedisBloomProtocol.RedisBloomKeyword.WITHCOUNT.getRaw()
                );
                return Void.TYPE.cast(null);
            }
        );

        List<ScoreboardItem> scoreboard = getScoreboard((Set<ZSetOperations.TypedTuple<String>>) pipelinedResults.get(0));
        List<GuessCount> guessCount = getGuessCount((Map<Object, Object>) pipelinedResults.get(1));
        List<DurationCount> durationCount = getDurationCount((Map<Object, Object>) pipelinedResults.get(2));
        List<FailedWord> failedWords = getFailedWords((List<Object>) pipelinedResults.get(3));

        return new GameMetrics(scoreboard, guessCount, durationCount, failedWords);
    }

    private List<ScoreboardItem> getScoreboard(Set<ZSetOperations.TypedTuple<String>> scoreboardData) {
        return scoreboardData.stream()
                .map(entry -> new ScoreboardItem(entry.getValue(), entry.getScore().longValue()))
                .collect(Collectors.toList());
    }

    private List<GuessCount> getGuessCount(Map<Object, Object> guessCount) {
        return IntStream.range(0, GUESS_ATTEMPTS.size())
                .mapToObj(i -> {
                    String guessAttempt = i + "/6 Guesses";
                    String sCount = String.valueOf(guessCount.getOrDefault(GUESS_ATTEMPTS.get(i), "0"));
                    long count = Long.parseLong(sCount);
                    return new GuessCount(guessAttempt, count);
                })
                .collect(Collectors.toList());
    }

    private List<DurationCount> getDurationCount(Map<Object, Object> durationCount) {
        return GAME_DURATIONS.stream()
            .map(duration -> {
                String sCount = String.valueOf(durationCount.getOrDefault(duration, "0"));
                long count = Long.parseLong(sCount);
                if (!duration.equals(GAME_DURATIONS.get(6))) {
                    duration = "Under " + duration + " seconds";
                } else {
                    duration = "Over one minute";
                }
                return new DurationCount(duration, count);
            })
            .collect(Collectors.toList());
    }

    private List<FailedWord> getFailedWords(List<Object> replyList) {
        if (replyList == null) {
            return Collections.emptyList();
        }
        return IntStream.range(0, replyList.size() / 2)
                .mapToObj(i -> {
                    String word = (String) replyList.get(i * 2);
                    Long count = ((Long) replyList.get(i * 2 + 1));
                    return new FailedWord(word, count);
                })
                .collect(Collectors.toList());
    }
}
