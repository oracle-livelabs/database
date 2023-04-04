package com.example.formula1;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import oracle.sql.json.OracleJsonObject;

/**
 * This example shows how an error can be thrown when you try to update a field labeled as NO UPDATE in its duality view.
 */
public class NonupdateableError {

    public static void main(String[] args) throws SQLException {
        String newDriver = """
               {"driverId" : 103,
                "name" : "Charles Leclerc",
                "points" : 25,
                "teamId" : 2,
                "team" : "Ferrari",
                "race" :
                [
                  {
                    "driverRaceMapId" : 3,
                    "raceId" : 201,
                    "name" : "Blue Air Bahrain Grand Prix",
                    "finalPosition" : 1
                  }
                ]
                }
                """;
        try (Connection con = Connections.get(args)) {
            PreparedStatement stmt = con.prepareStatement(
                "UPDATE driver_dv dv SET data = ? WHERE dv.data.driverId = ?");
            stmt.setString(1, newDriver);
            stmt.setInt(2, 103);
            stmt.executeUpdate();
            stmt.close();
            System.out.println("Driver 103 updated.");
        }
    }

}
