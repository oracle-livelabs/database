-- Task 1: Understanding JSON Schema Validation

-- Create table with named JSON Schema constraint
DROP TABLE IF EXISTS vehicles cascade constraints;

CREATE TABLE vehicles (
    vehicle_id   NUMBER,
    vehicle_info JSON VALIDATE '{
    "type"       : "object",
    "properties" : {"make"    : {"type" : "string"},
                    "model"   : {"type" : "string"},
                    "year"    : {"type" : "integer",
                                "minimum" : 1886,
                                "maximum" : 2024}},
    "required"   : ["make", "model", "year"]
    }',
    CONSTRAINT vehicles_pk PRIMARY KEY (vehicle_id)
);

-- Insert valid JSON data
INSERT INTO vehicles (vehicle_id, vehicle_info) 
VALUES 
    (1, JSON('{"make":"Toyota","model":"Camry","year":2020}')),
    (2, JSON('{"make":"Ford","model":"Mustang","year":1967}'));

-- Test invalid JSON data (these should fail)
-- Invalid: Missing 'year'
INSERT INTO vehicles (vehicle_id, vehicle_info) VALUES (3, JSON('{"make":"Honda","model":"Civic"}'));

-- Invalid: 'year' is out of range
INSERT INTO vehicles (vehicle_id, vehicle_info) VALUES (4, JSON('{"make":"Tesla","model":"Model S","year":1885}'));

-- Enhanced JSON Schema with additional constraints using ALTER TABLE approach
-- First, recreate table with named constraint for better management
DROP TABLE IF EXISTS vehicles cascade constraints;

CREATE TABLE vehicles (
    vehicle_id   NUMBER,
    vehicle_info JSON,
    CONSTRAINT vehicles_json_check CHECK (vehicle_info IS JSON VALIDATE '{
    "type"       : "object",
    "properties" : {"make"    : {"type" : "string"},
                    "model"   : {"type" : "string"},
                    "year"    : {"type" : "integer",
                                "minimum" : 1886,
                                "maximum" : 2024}},
    "required"   : ["make", "model", "year"]
    }'),
    CONSTRAINT vehicles_pk PRIMARY KEY (vehicle_id)
);

-- Insert some valid data
INSERT INTO vehicles (vehicle_id, vehicle_info) 
VALUES 
    (1, JSON('{"make":"Toyota","model":"Camry","year":2020}')),
    (2, JSON('{"make":"Ford","model":"Mustang","year":1967}'));

-- Now enhance the constraint using ALTER TABLE (practical approach)
-- Drop the existing named JSON schema constraint
ALTER TABLE vehicles DROP CONSTRAINT vehicles_json_check;

-- Add the enhanced constraint with additionalProperties: false
ALTER TABLE vehicles ADD CONSTRAINT vehicles_json_enhanced_check 
CHECK (vehicle_info IS JSON VALIDATE '{
"type"       : "object",
"properties" : {"make"    : {"type" : "string"},
                "model"   : {"type" : "string"},
                "year"    : {"type" : "integer",
                            "minimum" : 1886,
                            "maximum" : 2024}},
"required"   : ["make", "model", "year"],
"additionalProperties" : false
}');

-- Verify existing data remains
SELECT * FROM vehicles;

-- Test the new constraint with additional properties (should fail)
INSERT INTO vehicles (vehicle_id, vehicle_info) VALUES (3, JSON('{"make":"BMW","model":"X5","year":2019,"color":"black"}'));

-- Task 2: Querying JSON Data with Schema Validation

-- Create table without VALIDATE constraint for mixed data
DROP TABLE IF EXISTS vehicles cascade constraints;

CREATE TABLE vehicles (
    vehicle_id   NUMBER,
    vehicle_info JSON,
    CONSTRAINT vehicles_pk PRIMARY KEY (vehicle_id)
);

-- Insert a mix of valid and invalid JSON data
INSERT INTO vehicles (vehicle_id, vehicle_info) 
VALUES 
    (1, JSON('{"make":"Nissan","model":"Altima","year":2021}')),
    (2, JSON('{"make":"Chevrolet","model":"Malibu"}')),
    (3, JSON('{"make":"Dodge","model":"Charger","year":2023}')),
    (4, JSON('{"make":"Audi","model":"A4","year":1885}'));

-- Query using IS JSON VALIDATE to filter only valid data
SELECT *
FROM   vehicles
WHERE  vehicle_info IS JSON VALIDATE '{
"type"       : "object",
"properties" : {"make"    : {"type" : "string"},
                "model"   : {"type" : "string"},
                "year"    : {"type" : "integer",
                            "minimum" : 1886,
                            "maximum" : 2024}},
"required"   : ["make", "model", "year"]
}';

-- Clean up
DROP TABLE IF EXISTS vehicles cascade constraints;