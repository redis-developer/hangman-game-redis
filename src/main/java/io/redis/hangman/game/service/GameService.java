package io.redis.hangman.game.service;

import io.redis.hangman.game.domain.GameData;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataAccessException;
import org.springframework.data.redis.core.*;
import org.springframework.stereotype.Service;
import redis.clients.jedis.bloom.RedisBloomProtocol;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.Objects;

import static io.redis.hangman.game.util.Constants.*;

@Service
public class GameService {

    @Autowired
    private RedisTemplate<String, String> redisTemplate;

    public void updateData(GameData gameData) {
        Objects.requireNonNull(gameData, "gameData cannot be null");

        String guessAttempt = BigDecimal.valueOf(
                gameData.guessAttempt()).setScale(
                2, RoundingMode.HALF_UP).toString();

        redisTemplate.execute(new SessionCallback<Object>() {
            @Override
            public <K, V> Object execute(RedisOperations<K, V> redisOperations) throws DataAccessException {
                @SuppressWarnings("unchecked")
                RedisOperations<String, String> redisOps = (RedisOperations<String, String>) redisOperations;
                redisOps.multi();

                // Update the scoreboard
                redisOps.opsForZSet().incrementScore(
                        SCOREBOARD_KEY,
                        gameData.playerName(),
                        gameData.score());

                // Update the guess count
                redisOps.opsForHash().increment(
                        GUESS_COUNT_KEY,
                        guessAttempt,
                        1);

                // Update the duration count
                redisOps.opsForHash().increment(
                        DURATION_COUNT_KEY,
                        String.valueOf(gameData.duration()),
                        1);

                // Update the failed words only if
                // the player hasn't won the game
                if (gameData.score() == 0) {
                    redisOps.execute((RedisCallback<Void>) redisConnection -> {
                        redisConnection.execute(
                                new String(RedisBloomProtocol.TopKCommand.INCRBY.getRaw()),
                                FAILED_WORDS_KEY.getBytes(),
                                gameData.word().getBytes(),
                                "1".getBytes()
                        );
                        return Void.TYPE.cast(null);
                    });
                }

                return redisOps.exec();
            }
        });

    }

}
