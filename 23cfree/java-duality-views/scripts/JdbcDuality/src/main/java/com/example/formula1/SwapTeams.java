package com.example.formula1;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import oracle.sql.json.OracleJsonObject;

/**
 * This example swaps the teams that Charles Leclerc and George Russell are on.
 * 
 */
public class SwapTeams {

    public static void main(String[] args) throws SQLException {
        String newMercedesTeam = """
               {"teamId" : 2,
                "name"   : "Mercedes",
                "points" : 40,
                "driver" : [ {"driverId" : 106,
                              "name"     : "Lewis Hamilton",
                              "points"   : 15},
                             {"driverId" : 103,
                              "name"     : "Charles Leclerc",
                              "points"   : 25} ]}
                """;
        String newFerrariTeam = """
                {"teamId" : 302,
                "name"   : "Ferrari",
                "points" : 30,
                "driver" : [ {"driverId" : 105,
                              "name"     : "George Russell",
                              "points"   : 12},
                             {"driverId" : 104,
                              "name"     : "Carlos Sainz Jr",
                              "points"   : 18} ]}
                """;
        try (Connection con = Connections.get(args)) {
            
            PreparedStatement selectTeam = con.prepareStatement("SELECT data FROM team_dv dv WHERE dv.data.name LIKE ?");
            selectTeam.setString(1, "Mercedes%");
            ResultSet rs = selectTeam.executeQuery();
            rs.next();
            OracleJsonObject team = rs.getObject(1, OracleJsonObject.class);
            System.out.println("Team name: " + team.getString("name") + ", ID: " + team.getInt("teamId"));            
            rs.close();

            selectTeam.setString(1, "Ferrari%");
            rs = selectTeam.executeQuery();
            rs.next();
            team = rs.getObject(1, OracleJsonObject.class);
            System.out.println("Team name: " + team.getString("name") + ", ID: " + team.getInt("teamId")); 
            rs.close();
            selectTeam.close();

            PreparedStatement selectDriver = con.prepareStatement("SELECT data FROM driver_dv dv WHERE dv.data.name LIKE ?");
            selectDriver.setString(1, "Charles Leclerc%");
            rs = selectDriver.executeQuery();
            rs.next();
            OracleJsonObject driver = rs.getObject(1, OracleJsonObject.class);
            System.out.println("Driver name: " + driver.getString("name") + ", ID: " + driver.getInt("teamId"));
            rs.close();

            selectDriver.setString(1, "George Russell%");
            rs = selectDriver.executeQuery();
            rs.next();
            driver = rs.getObject(1, OracleJsonObject.class);
            System.out.println("Driver name: " + driver.getString("name") + " " + driver.getInt("teamId"));
            rs.close();
            
            PreparedStatement updateTeam = con.prepareStatement("UPDATE team_dv t SET data = ? WHERE t.data.name LIKE ?");
            updateTeam.setString(1, newMercedesTeam);
            updateTeam.setString(2,  "Mercedes");
            updateTeam.executeUpdate();
            System.out.println("Success! Updated Charles Leclerc to be under Mercedes");
            
            updateTeam.setString(1, newFerrariTeam);
            updateTeam.setString(2,  "Ferrari%");
            updateTeam.executeUpdate();
            System.out.println("Success! Updated George Russell to be under Ferrari");
            updateTeam.close();
            

            selectDriver.setString(1, "Charles Leclerc%");
            rs = selectDriver.executeQuery();
            rs.next();
            driver = rs.getObject(1, OracleJsonObject.class);
            System.out.println("Driver name: " + driver.getString("name") + ", ID: " + driver.getInt("teamId"));
            rs.close();

            selectDriver.setString(1, "George Russell%");
            rs = selectDriver.executeQuery();
            rs.next();
            driver = rs.getObject(1, OracleJsonObject.class);
            System.out.println("Driver name: " + driver.getString("name") + ", ID: " + driver.getInt("teamId"));
            rs.close();
            selectDriver.close();
            
        }
    }

}
