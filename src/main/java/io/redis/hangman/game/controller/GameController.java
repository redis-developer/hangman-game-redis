package io.redis.hangman.game.controller;

import io.redis.hangman.game.domain.GameData;
import io.redis.hangman.game.service.GameService;
import io.redis.hangman.game.util.ApiResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1")
public class GameController {

    @Autowired
    private GameService gameService;

    @PostMapping("/game")
    public ResponseEntity<ApiResponse> updateData(@RequestBody GameData gameData) {
        try {
            gameService.updateData(gameData);
            return ResponseEntity.ok(
                    new ApiResponse("Scoreboard and statistics data updated successfully"));
        } catch (Exception ex) {
            return ResponseEntity.internalServerError().body(
                    new ApiResponse("Error updating data: " + ex.getMessage()));
        }
    }

}
