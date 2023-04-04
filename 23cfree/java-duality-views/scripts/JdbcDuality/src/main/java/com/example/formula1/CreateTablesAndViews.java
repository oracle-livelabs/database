package com.example.formula1;

import java.io.FileInputStream;
import java.nio.charset.StandardCharsets;
import java.sql.Connection;
import java.sql.SQLException;
import java.sql.Statement;


public class CreateTablesAndViews {

    public static void main(String[] args) throws Exception {
        FileInputStream fis = new FileInputStream("resources/formula1.sql");
        String queries = new String(fis.readAllBytes(), StandardCharsets.UTF_8);
        try (Connection con = Connections.get(args)) {
            Statement stmt = con.createStatement();
            for (String query : queries.split("\\s*;\\s*")) {
                System.out.println("\n\nExecuting: \n" + query.trim());
                try {
                    stmt.execute(query);
                } catch (SQLException e) {
                    System.out.println(e.getMessage());
                }
            }
            stmt.executeUpdate("""
                CREATE OR REPLACE TRIGGER driver_race_map_trigger
                  BEFORE INSERT ON driver_race_map
                  FOR EACH ROW
                  DECLARE
                    v_points  INTEGER;
                    v_team_id INTEGER;
                BEGIN
                  SELECT team_id INTO v_team_id FROM driver WHERE driver_id = :NEW.driver_id;
                
                  IF :NEW.position = 1 THEN
                    v_points := 25;
                  ELSIF :NEW.position = 2 THEN
                    v_points := 18;
                  ELSIF :NEW.position = 3 THEN
                    v_points := 15;
                  ELSIF :NEW.position = 4 THEN
                    v_points := 12;
                  ELSIF :NEW.position = 5 THEN
                    v_points := 10;
                  ELSIF :NEW.position = 6 THEN
                    v_points := 8;
                  ELSIF :NEW.position = 7 THEN
                    v_points := 6;
                  ELSIF :NEW.position = 8 THEN
                    v_points := 4;
                  ELSIF :NEW.position = 9 THEN
                    v_points := 2;
                  ELSIF :NEW.position = 10 THEN
                    v_points := 1;
                  ELSE
                    v_points := 0;
                  END IF;
                
                  UPDATE driver SET points = points + v_points
                    WHERE driver_id = :NEW.driver_id;
                  UPDATE team SET points = points + v_points
                    WHERE team_id = v_team_id;
                END;
            """);
            stmt.close();
        }
        fis.close();
    }

}
