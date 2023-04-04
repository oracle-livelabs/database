package com.example.formula1.model;

import java.time.LocalDateTime;

public record Race(int raceId, String name, int laps, LocalDateTime date) {

}
