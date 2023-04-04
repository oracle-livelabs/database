package com.example.formula1;

import java.io.BufferedReader;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.sql.Connection;
import java.sql.PreparedStatement;

import oracle.jdbc.OracleTypes;

public class LoadData {
         
    public static void main(String[] args) throws Exception {
        try (Connection con = Connections.get(args)) {
            con.setAutoCommit(false);
            loadJson(con, "INSERT INTO team_dv VALUES (?)", "resources/teams.ndjson");
            loadJson(con, "INSERT INTO race_dv VALUES (?)", "resources/races.ndjson");
            con.commit();
        }
    }

    private static void loadJson(Connection con, String sql, String file) throws Exception {
        String jzn;
        try (PreparedStatement stmt = con.prepareStatement(sql)) {
            try (BufferedReader reader = Files.newBufferedReader(Paths.get(file))) {
                while ((jzn = reader.readLine()) != null) {
                    stmt.setObject(1, jzn, OracleTypes.JSON);
                    stmt.addBatch();
                }
            }
            stmt.executeBatch();
        }
        System.out.println("Loaded " + file);
    }

}
