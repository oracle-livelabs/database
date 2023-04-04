package com.example.formula1;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import oracle.sql.json.OracleJsonObject;

/**
 * This example filters for the race with an ID of 201.
 */
public class FindRaceById {
    public static void main(String[] args) throws Exception {
        try (Connection con = Connections.get(args)) {
            PreparedStatement stmt = con.prepareStatement("""
               SELECT data 
               FROM race_dv t 
               WHERE t.data.raceId = ?
            """);
            stmt.setInt(1, 201);
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                OracleJsonObject race = rs.getObject(1, OracleJsonObject.class);
                System.out.println(race.toString());
            }
            rs.close();
            stmt.close();
        }
    }
}
