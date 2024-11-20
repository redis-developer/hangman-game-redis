package io.redis.hangman.game.app;

import io.redis.hangman.game.util.Constants;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.data.redis.connection.RedisStandaloneConfiguration;
import org.springframework.data.redis.connection.jedis.JedisClientConfiguration;
import org.springframework.data.redis.connection.jedis.JedisConnectionFactory;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.data.redis.serializer.GenericJackson2JsonRedisSerializer;
import org.springframework.data.redis.serializer.StringRedisSerializer;
import org.springframework.lang.NonNull;
import org.springframework.web.servlet.config.annotation.CorsRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;
import redis.clients.jedis.JedisPoolConfig;

import java.net.URI;

import static io.redis.hangman.game.util.Constants.REDIS_CONNECTION_URL;
import static io.redis.hangman.game.util.Constants.ALLOWED_ORIGINS;

@SpringBootApplication
@ComponentScan(basePackages = "io.redis.hangman.game")
public class BackendAPIs {

    public static void main(String[] args) {
        SpringApplication.run(BackendAPIs.class, args);
    }

    @Bean
    public JedisConnectionFactory jedisConnectionFactory() {
        URI redisUri = URI.create(REDIS_CONNECTION_URL);

        RedisStandaloneConfiguration redisConfig = new RedisStandaloneConfiguration();
        redisConfig.setHostName(redisUri.getHost());
        redisConfig.setPort(redisUri.getPort());
        if (redisUri.getUserInfo() != null) {
            String[] userInfo = redisUri.getUserInfo().split(":");
            if (userInfo.length > 0) {
                if  (userInfo[0] != null && !userInfo[0].isEmpty()) {
                    redisConfig.setUsername(userInfo[0]);
                }
                if  (userInfo[1] != null && !userInfo[1].isEmpty()) {
                    redisConfig.setPassword(userInfo[1]);
                }
            }
        }

        JedisPoolConfig jedisPoolConfig = new JedisPoolConfig();
        jedisPoolConfig.setMaxTotal(10);
        jedisPoolConfig.setMaxIdle(5);
        jedisPoolConfig.setMinIdle(1);

        JedisClientConfiguration  jedisClientConfig =
                JedisClientConfiguration.builder()
                        .usePooling()
                        .poolConfig(jedisPoolConfig)
                        .build();

        return new JedisConnectionFactory(redisConfig, jedisClientConfig);
    }

    @Bean
    public RedisTemplate<String, Object> redisTemplate() {
        RedisTemplate<String, Object> redisTemplate = new RedisTemplate<>();
        redisTemplate.setConnectionFactory(jedisConnectionFactory());
        redisTemplate.setKeySerializer(new StringRedisSerializer());
        redisTemplate.setValueSerializer(new StringRedisSerializer());
        redisTemplate.setHashKeySerializer(new GenericJackson2JsonRedisSerializer());
        return redisTemplate;
    }

    @Bean
    public WebMvcConfigurer corsConfigurer() {
        return new WebMvcConfigurer() {
            @Override
            public void addCorsMappings(@NonNull CorsRegistry registry) {
                registry.addMapping("/api/**")
                        .allowedOrigins(ALLOWED_ORIGINS)
                        .allowedHeaders("*")
                        .allowedMethods("POST")
                        .allowCredentials(true)
                        .maxAge(3600);
            }
        };
    }

}
