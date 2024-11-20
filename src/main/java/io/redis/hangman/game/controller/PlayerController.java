package io.redis.hangman.game.controller;

import io.redis.hangman.game.domain.Player;
import io.redis.hangman.game.service.PlayerService;
import io.redis.hangman.game.util.ApiResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1")
public class PlayerController {

    @Autowired
    private PlayerService playerService;

    @PostMapping("/players")
    public ResponseEntity<ApiResponse> addPlayer(@RequestBody Player player) {
        boolean added = playerService.addPlayer(player);
        if (added) {
            return ResponseEntity.ok(new ApiResponse("Player added successfully"));
        } else {
            return ResponseEntity.status(HttpStatus.CONFLICT)
                    .body(new ApiResponse("Player already exists"));
        }
    }

}
