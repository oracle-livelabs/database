package com.example.formula1;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import oracle.sql.json.OracleJsonObject;

/**
 * This example deletes race with an ID of 201.
 */
public class DeleteById {

    public static void main(String[] args) throws SQLException {
        try (Connection con = Connections.get(args)) {
        	PreparedStatement selectRace = con.prepareStatement("SELECT data FROM race_dv dv WHERE dv.data.raceId = ?");
        	selectRace.setInt(1, 201);
            ResultSet rs = selectRace.executeQuery();
            while (rs.next()) {
                OracleJsonObject race = rs.getObject(1, OracleJsonObject.class);
                System.out.println(race.toString());
            }
            rs.close();
            System.out.println("\n");

            PreparedStatement selectDriver = con.prepareStatement("SELECT data FROM driver_dv dv");
            rs = selectDriver.executeQuery();
            while (rs.next()) {
                OracleJsonObject driver = rs.getObject(1, OracleJsonObject.class);
                System.out.println(driver.toString());
            }
            rs.close();

            
            PreparedStatement delete = con.prepareStatement(
                    """
                    DELETE FROM race_dv dv
                    WHERE dv.data.raceId = ?
                    """);
            delete.setInt(1, 201);
            delete.executeUpdate();
            delete.close();
            System.out.println("\nSuccess! Race with ID of 201 deleted.\n");
            
            selectRace = con.prepareStatement("SELECT data FROM race_dv");
            
            rs = selectRace.executeQuery();
            while (rs.next()) {
                OracleJsonObject race = rs.getObject(1, OracleJsonObject.class);
                System.out.println(race.toString());
            }
            rs.close();
            System.out.println("\n");

            selectDriver = con.prepareStatement("SELECT data FROM driver_dv");
            
            rs = selectDriver.executeQuery();
            while (rs.next()) {
                OracleJsonObject driver = rs.getObject(1, OracleJsonObject.class);
                System.out.println(driver.toString());
            }
            rs.close();
            
        }
    }

}