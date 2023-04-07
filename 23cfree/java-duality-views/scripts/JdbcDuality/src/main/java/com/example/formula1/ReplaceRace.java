package com.example.formula1;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import oracle.sql.json.OracleJsonObject;

/**
 * This example replaces/updates the contents of race 201 
 */
public class ReplaceRace {

    public static void main(String[] args) throws SQLException {
        String newRace = """
               {
                "raceId" : 201,
                "name"   : "Bahrain Grand Prix",
                "laps"   : 57,
                "date"   : "2022-03-20T00:00:00",
                "podium" :
                  {"winner"         : {"name" : "Charles Leclerc",
                                       "time" : "01:37:33.584"},
                   "firstRunnerUp"  : {"name" : "Carlos Sainz Jr",
                                       "time" : "01:37:39.182"},
                   "secondRunnerUp" : {"name" : "Lewis Hamilton",
                                       "time" : "01:37:43.259"}},
                "result" : [ {"driverRaceMapId" : 3,
                              "position"        : 1,
                              "driverId"        : 103,
                              "name"            : "Charles Leclerc"},
                             {"driverRaceMapId" : 4,
                              "position"        : 2,
                              "driverId"        : 104,
                              "name"            : "Carlos Sainz Jr"},
                             {"driverRaceMapId" : 9,
                              "position"        : 3,
                              "driverId"        : 106,
                              "name"            : "Lewis Hamilton"},
                             {"driverRaceMapId" : 10,
                              "position"        : 4,
                              "driverId"        : 105,
                              "name"            : "George Russell"} ]}
                """;
        try (Connection con = Connections.get(args)) {
            PreparedStatement update = con.prepareStatement(
                "UPDATE race_dv t SET data = ? WHERE object_resid = ?");
            update.setString(1, newRace);
            update.setString(2,  "FB03C2030200");
            update.executeUpdate();
            update.close();
            System.out.println("Success! Race 201 updated.");
            
            PreparedStatement select = con.prepareStatement("SELECT data FROM race_dv WHERE object_resid = ?");
            select.setString(1, "FB03C2030200");
            ResultSet rs = select.executeQuery();
            rs.next();
            OracleJsonObject race = rs.getObject(1, OracleJsonObject.class);
            OracleJsonObject podium = race.get("podium").asJsonObject();
            OracleJsonObject winner = podium.get("winner").asJsonObject();
            System.out.println("Winner of the race: " + winner.getString("name"));
            rs.close();
            select.close();
        }
    }
}
