package com.example.formula1;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import org.eclipse.yasson.YassonJsonb;

import com.example.formula1.model.Driver;
import com.example.formula1.model.Team;

import jakarta.json.bind.JsonbBuilder;
import jakarta.json.stream.JsonParser;
import oracle.sql.json.OracleJsonArray;
import oracle.sql.json.OracleJsonObject;
import oracle.sql.json.OracleJsonValue;

/**
 * This example shows three different ways that you can read the contents of
 * teams_dv.
 */
public class ReadTeamsDv {
    public static void main(String[] args) throws Exception {

        try (Connection con = Connections.get(args)) {
            PreparedStatement stmt = con.prepareStatement("SELECT object_resid, data FROM team_dv");
            
            // Output each team object as JSON text
            System.out.println("\nJSON Text\n-------------------");
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                System.out.println(rs.getString(1) + "\t" + rs.getString(2));
            }
            rs.close();

            // Output each team using the JSON API in package oracle.sql.json
            System.out.println("\nJSON API\n-------------------");
            rs = stmt.executeQuery();
            while (rs.next()) {
                OracleJsonObject obj = rs.getObject(2, OracleJsonObject.class);
                String name = obj.getString("name");
                int teamId = obj.getInt("teamId");
                System.out.println(name + " (" + teamId + ")");
                OracleJsonArray drivers = obj.get("driver").asJsonArray();
                for (OracleJsonValue value : drivers) {
                    OracleJsonObject driver = value.asJsonObject();
                    String driverName = driver.getString("name");
                    System.out.println(" * " + driverName);
                }
            }
            rs.close();
            
            // Output each team object as a Java record sing JSON-B
            System.out.println("\nJava Objects\n-------------------");
            YassonJsonb jsonb = (YassonJsonb) JsonbBuilder.create();
            rs = stmt.executeQuery();
            while (rs.next()) {
                JsonParser parser = rs.getObject(2, JsonParser.class);
                Team team = jsonb.fromJson(parser, Team.class);
                System.out.println(team.name() + " (" + team.teamId() + ")");
                for (Driver driver : team.driver()) {
                    System.out.println(" * " + driver.name());
                }
            }
            rs.close();
            stmt.close();
        }
    }
}
