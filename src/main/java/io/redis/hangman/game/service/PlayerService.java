package io.redis.hangman.game.service;

import io.redis.hangman.game.domain.Player;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Service;

import java.util.Objects;

import static io.redis.hangman.game.util.Constants.SCOREBOARD_KEY;

@Service
public class PlayerService {

    @Autowired
    private RedisTemplate<String, String> redisTemplate;

    public boolean addPlayer(Player player) {
        Objects.requireNonNull(player, "player cannot be null");
        return redisTemplate.opsForZSet().addIfAbsent(SCOREBOARD_KEY, player.playerName(), 0);
    }

}
