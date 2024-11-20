package io.redis.hangman.game.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import io.redis.hangman.game.domain.Word;
import jakarta.annotation.PostConstruct;
import org.springframework.core.io.ClassPathResource;
import org.springframework.stereotype.Service;

import java.io.IOException;
import java.util.Collections;
import java.util.List;
import java.util.Base64;

@Service
public class WordsService {
    private List<Word> words;

    @PostConstruct
    public void init() {
        try {
            ObjectMapper objectMapper = new ObjectMapper();
            ClassPathResource resource = new ClassPathResource("words.data");
            byte[] encodedBytes = resource.getInputStream().readAllBytes();
            byte[] decodedBytes = Base64.getDecoder().decode(encodedBytes);
            String dataAsJson = new String(decodedBytes);

            words = Collections.unmodifiableList(
                    objectMapper.readValue(dataAsJson,
                    objectMapper.getTypeFactory().constructCollectionType(
                            List.class, Word.class)));
        } catch (IOException ex) {
            throw new WordInitializationException("Failed to initialize words from JSON", ex);
        }
    }

    public List<Word> getWords() {
        return words;
    }

}

class WordInitializationException extends RuntimeException {
    public WordInitializationException(String message, Throwable cause) {
        super(message, cause);
    }
}
