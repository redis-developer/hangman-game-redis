package io.redis.hangman.game.controller;

import io.redis.hangman.game.domain.GameMetrics;
import io.redis.hangman.game.service.MetricsService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1")
public class MetricsController {

    @Autowired
    private MetricsService metricsService;

    @PostMapping("/metrics")
    public ResponseEntity<GameMetrics> getMetrics() {
        try {
            GameMetrics metrics = metricsService.getMetrics();
            return ResponseEntity.ok(metrics);
        } catch (Exception ex) {
            return ResponseEntity.internalServerError()
                    .build();
        }
    }

}
