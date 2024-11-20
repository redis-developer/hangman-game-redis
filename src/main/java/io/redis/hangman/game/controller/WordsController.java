package io.redis.hangman.game.controller;

import io.redis.hangman.game.domain.Word;
import io.redis.hangman.game.service.WordsService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/v1")
public class WordsController {

    @Autowired
    private WordsService wordsService;

    @PostMapping("/words")
    public ResponseEntity<List<Word>> getWords() {
        try {
            List<Word> words = wordsService.getWords();
            return ResponseEntity.ok(words);
        } catch (Exception ignored) {
            return ResponseEntity.internalServerError().build();
        }
    }

}
