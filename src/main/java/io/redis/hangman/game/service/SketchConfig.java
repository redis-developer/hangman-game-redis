package io.redis.hangman.game.service;

import jakarta.annotation.PostConstruct;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.redis.core.RedisCallback;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Component;
import redis.clients.jedis.bloom.RedisBloomProtocol;

import static io.redis.hangman.game.util.Constants.*;

@Component
public class SketchConfig {

    @Autowired
    private RedisTemplate<String, String> redisTemplate;

    @PostConstruct
    public void init() {
        redisTemplate.execute((RedisCallback<Void>) connection -> {
            if (Boolean.FALSE.equals(connection.keyCommands().exists(FAILED_WORDS_KEY.getBytes()))) {
                connection.commands().execute(
                        new String(RedisBloomProtocol.TopKCommand.RESERVE.getRaw()),
                        FAILED_WORDS_KEY.getBytes(),
                        FAILED_WORDS_TOPK.getBytes());
            }

            return null;
        });
    }

}
