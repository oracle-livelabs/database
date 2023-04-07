package com.example.formula1;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import oracle.sql.json.OracleJsonFactory;
import oracle.sql.json.OracleJsonObject;

/**
 * This example replaces the name of race 201.
 */
public class UpdateField {

    public static void main(String[] args) throws SQLException {
        try (Connection con = Connections.get(args)) {
        	
        	PreparedStatement select = con.prepareStatement("SELECT data FROM race_dv WHERE json_value(data, '$.name') LIKE ?");
        	select.setString(1, "%Bahrain%");
            ResultSet rs = select.executeQuery();
            rs.next();
            
            OracleJsonObject race = rs.getObject(1, OracleJsonObject.class);
            System.out.println("Race name: " + race.getString("name") + ", Race ID: " + race.getInt("raceId"));
            rs.close();
          
            PreparedStatement transform = con.prepareStatement(
                    """
                    UPDATE race_dv dv 
                    SET data = json_transform(data, SET '$.name' = ?)
                    WHERE dv.data.name LIKE ?
                    """);
            transform.setString(1, "Blue Air Bahrain Grand Prix");
            transform.setString(2, "Bahrain %");
            transform.executeUpdate();
            transform.close();
            System.out.println("Success! Race name updated with json_transform.");
            
            rs = select.executeQuery();
            rs.next();
            
            race = rs.getObject(1, OracleJsonObject.class);
            System.out.println("Race name: " + race.getString("name") + ", Race ID: " + race.getInt("raceId"));
            rs.close();
            
            PreparedStatement merge = con.prepareStatement(
                    """
                    UPDATE race_dv dv
                    SET data = json_mergepatch(data, ?)
                    WHERE OBJECT_RESID = ?
                    """);
            OracleJsonFactory fact = new OracleJsonFactory();
            OracleJsonObject patch = fact.createObject();
            patch.put("name", "Blue Air Bahrain Grand Prix 2");
            merge.setObject(1, patch);
            
            // Alternatively, the patch could be set as JSON text
            // stmt.setString(1, "{\"name\" : \"Blue Air Bahrain Grand Prix\"}");
            
            merge.setString(2, "FB03C2030200");
            merge.executeUpdate();
            merge.close();
            System.out.println("Success! Race name updated with json_mergepatch.");
            
            rs = select.executeQuery();
            rs.next();
             
            race = rs.getObject(1, OracleJsonObject.class);
            System.out.println("Race name: " + race.getString("name") + ", Race ID: " + race.getInt("raceId"));
            select.close();
        }
    }

}