package com.example.formula1.model;

import java.util.List;

public record Team(int teamId, String name, int points, List<Driver> driver) {

}
