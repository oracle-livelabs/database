package com.example.formula1;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import oracle.sql.json.OracleJsonObject;

/**
 * This example filters for a race with an OBJECT_ID of FB03C2030200.
 */
public class FetchRaceByObjId {
    public static void main(String[] args) throws Exception {
        try (Connection con = Connections.get(args)) {
            PreparedStatement stmt = con.prepareStatement("""
               SELECT data 
               FROM race_dv t 
               WHERE OBJECT_RESID = ?
            """);
            stmt.setString(1,  "FB03C2030200");
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
