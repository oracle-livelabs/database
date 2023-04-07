package com.example.formula1;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import org.eclipse.yasson.YassonJsonb;

import com.example.formula1.model.Driver;
import com.example.formula1.model.Team;
import com.example.formula1.model.Race;

import jakarta.json.bind.JsonbBuilder;
import jakarta.json.stream.JsonParser;
import oracle.sql.json.OracleJsonArray;
import oracle.sql.json.OracleJsonObject;
import oracle.sql.json.OracleJsonValue;

/**
 * This shows the contents of driver_dv.
 */
public class ReadDriversDv {
    public static void main(String[] args) throws Exception {

        try (Connection con = Connections.get(args)) {
            PreparedStatement stmt = con.prepareStatement("SELECT object_resid, data FROM driver_dv");
            
            System.out.println("\nObject_ResID\tJSON Data\n--------------------------");
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                String resid = rs.getString(1);
                OracleJsonObject driver = rs.getObject(2, OracleJsonObject.class);
                System.out.println(resid + "\t" + driver.toString());
            }
            rs.close();
            stmt.close();
        }
    }
}
