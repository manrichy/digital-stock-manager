package com.digitalstockmanager.infrastructure.config;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;
import org.springframework.boot.autoconfigure.domain.EntityScan;

@SpringBootApplication(scanBasePackages = "com.digitalstockmanager")
@EnableJpaRepositories(basePackages = "com.digitalstockmanager.infrastructure.secondary.persistence.jpa")
@EntityScan(basePackages = "com.digitalstockmanager.infrastructure.secondary.persistence.jpa")
public class DigitalStockManagerApplication {
    public static void main(String[] args) {
        SpringApplication.run(DigitalStockManagerApplication.class, args);
    }
}
