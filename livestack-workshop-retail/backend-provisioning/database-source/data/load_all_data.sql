/*
 * load_all_data.sql
 * Master data loader — runs all data scripts in order
 * Generates ~5000 social posts, ~187 products, 50 brands,
 * 30 fulfillment centers, ~483 influencers, 2000 customers, 3000 orders
 *
 * NOTE: Uses individual INSERTs (not INSERT ALL) for tables with identity
 * columns to avoid ORA-00001 duplicate identity values on Oracle 23ai.
 */

SET SERVEROUTPUT ON
SET DEFINE OFF

PROMPT =====================================================
PROMPT Loading Retail LiveStack return data
PROMPT =====================================================

-- ============================================================
-- BRANDS (50) — individual INSERTs to avoid identity dup issue
-- ============================================================
PROMPT Loading brands...

INSERT INTO brands (brand_name,brand_slug,brand_category,headquarters_city,headquarters_lat,headquarters_lon,founded_year,annual_revenue,social_tier) VALUES ('UrbanPulse','urbanpulse','Fashion','New York',40.7128,-74.0060,2018,45000000,'premium');
INSERT INTO brands (brand_name,brand_slug,brand_category,headquarters_city,headquarters_lat,headquarters_lon,founded_year,annual_revenue,social_tier) VALUES ('TechNova','technova','Electronics','San Francisco',37.7749,-122.4194,2015,120000000,'premium');
INSERT INTO brands (brand_name,brand_slug,brand_category,headquarters_city,headquarters_lat,headquarters_lon,founded_year,annual_revenue,social_tier) VALUES ('GlowKin','glowkin','Beauty','Los Angeles',34.0522,-118.2437,2020,28000000,'emerging');
INSERT INTO brands (brand_name,brand_slug,brand_category,headquarters_city,headquarters_lat,headquarters_lon,founded_year,annual_revenue,social_tier) VALUES ('PeakForm','peakform','Fitness','Denver',39.7392,-104.9903,2017,67000000,'standard');
INSERT INTO brands (brand_name,brand_slug,brand_category,headquarters_city,headquarters_lat,headquarters_lon,founded_year,annual_revenue,social_tier) VALUES ('NestCraft','nestcraft','Home','Portland',45.5152,-122.6784,2019,32000000,'standard');
INSERT INTO brands (brand_name,brand_slug,brand_category,headquarters_city,headquarters_lat,headquarters_lon,founded_year,annual_revenue,social_tier) VALUES ('VoltEdge','voltedge','Electronics','Austin',30.2672,-97.7431,2016,89000000,'premium');
INSERT INTO brands (brand_name,brand_slug,brand_category,headquarters_city,headquarters_lat,headquarters_lon,founded_year,annual_revenue,social_tier) VALUES ('AuraScent','aurascent','Beauty','Miami',25.7617,-80.1918,2021,15000000,'emerging');
INSERT INTO brands (brand_name,brand_slug,brand_category,headquarters_city,headquarters_lat,headquarters_lon,founded_year,annual_revenue,social_tier) VALUES ('TrailBlaze','trailblaze','Outdoor','Seattle',47.6062,-122.3321,2014,95000000,'premium');
INSERT INTO brands (brand_name,brand_slug,brand_category,headquarters_city,headquarters_lat,headquarters_lon,founded_year,annual_revenue,social_tier) VALUES ('LuxeThread','luxethread','Fashion','New York',40.7128,-74.0060,2012,210000000,'luxury');
INSERT INTO brands (brand_name,brand_slug,brand_category,headquarters_city,headquarters_lat,headquarters_lon,founded_year,annual_revenue,social_tier) VALUES ('ByteBite','bytebite','Food Tech','Chicago',41.8781,-87.6298,2020,18000000,'emerging');
INSERT INTO brands (brand_name,brand_slug,brand_category,headquarters_city,headquarters_lat,headquarters_lon,founded_year,annual_revenue,social_tier) VALUES ('CloudStep','cloudstep','Footwear','Portland',45.5152,-122.6784,2019,42000000,'standard');
INSERT INTO brands (brand_name,brand_slug,brand_category,headquarters_city,headquarters_lat,headquarters_lon,founded_year,annual_revenue,social_tier) VALUES ('ZenBrew','zenbrew','Beverages','Portland',45.5152,-122.6784,2018,25000000,'standard');
INSERT INTO brands (brand_name,brand_slug,brand_category,headquarters_city,headquarters_lat,headquarters_lon,founded_year,annual_revenue,social_tier) VALUES ('IronCore','ironcore','Fitness','Nashville',36.1627,-86.7816,2016,55000000,'standard');
INSERT INTO brands (brand_name,brand_slug,brand_category,headquarters_city,headquarters_lat,headquarters_lon,founded_year,annual_revenue,social_tier) VALUES ('PixelCraft','pixelcraft','Gaming','San Jose',37.3382,-121.8863,2017,78000000,'premium');
INSERT INTO brands (brand_name,brand_slug,brand_category,headquarters_city,headquarters_lat,headquarters_lon,founded_year,annual_revenue,social_tier) VALUES ('EverGreen','evergreen','Sustainability','San Francisco',37.7749,-122.4194,2020,22000000,'emerging');
INSERT INTO brands (brand_name,brand_slug,brand_category,headquarters_city,headquarters_lat,headquarters_lon,founded_year,annual_revenue,social_tier) VALUES ('SonicWave','sonicwave','Audio','Los Angeles',34.0522,-118.2437,2015,110000000,'premium');
INSERT INTO brands (brand_name,brand_slug,brand_category,headquarters_city,headquarters_lat,headquarters_lon,founded_year,annual_revenue,social_tier) VALUES ('PureRoots','pureroots','Wellness','Boulder',40.0150,-105.2705,2019,35000000,'standard');
INSERT INTO brands (brand_name,brand_slug,brand_category,headquarters_city,headquarters_lat,headquarters_lon,founded_year,annual_revenue,social_tier) VALUES ('VelvetLine','velvetline','Fashion','Atlanta',33.7490,-84.3880,2021,12000000,'emerging');
INSERT INTO brands (brand_name,brand_slug,brand_category,headquarters_city,headquarters_lat,headquarters_lon,founded_year,annual_revenue,social_tier) VALUES ('AquaFit','aquafit','Fitness','Miami',25.7617,-80.1918,2018,40000000,'standard');
INSERT INTO brands (brand_name,brand_slug,brand_category,headquarters_city,headquarters_lat,headquarters_lon,founded_year,annual_revenue,social_tier) VALUES ('CrystalView','crystalview','Eyewear','New York',40.7128,-74.0060,2016,65000000,'premium');
INSERT INTO brands (brand_name,brand_slug,brand_category,headquarters_city,headquarters_lat,headquarters_lon,founded_year,annual_revenue,social_tier) VALUES ('MoonGlow','moonglow','Beauty','Nashville',36.1627,-86.7816,2022,8000000,'emerging');
INSERT INTO brands (brand_name,brand_slug,brand_category,headquarters_city,headquarters_lat,headquarters_lon,founded_year,annual_revenue,social_tier) VALUES ('TerraGear','terragear','Outdoor','Denver',39.7392,-104.9903,2013,88000000,'premium');
INSERT INTO brands (brand_name,brand_slug,brand_category,headquarters_city,headquarters_lat,headquarters_lon,founded_year,annual_revenue,social_tier) VALUES ('NeonNight','neonnight','Fashion','Las Vegas',36.1699,-115.1398,2021,19000000,'emerging');
INSERT INTO brands (brand_name,brand_slug,brand_category,headquarters_city,headquarters_lat,headquarters_lon,founded_year,annual_revenue,social_tier) VALUES ('FrostByte','frostbyte','Electronics','Seattle',47.6062,-122.3321,2018,52000000,'standard');
INSERT INTO brands (brand_name,brand_slug,brand_category,headquarters_city,headquarters_lat,headquarters_lon,founded_year,annual_revenue,social_tier) VALUES ('WildRoam','wildroam','Travel','Austin',30.2672,-97.7431,2019,30000000,'standard');
INSERT INTO brands (brand_name,brand_slug,brand_category,headquarters_city,headquarters_lat,headquarters_lon,founded_year,annual_revenue,social_tier) VALUES ('OmniWear','omniwear','Wearables','San Francisco',37.7749,-122.4194,2017,145000000,'luxury');
INSERT INTO brands (brand_name,brand_slug,brand_category,headquarters_city,headquarters_lat,headquarters_lon,founded_year,annual_revenue,social_tier) VALUES ('FlexiHome','flexihome','Home','Dallas',32.7767,-96.7970,2020,27000000,'standard');
INSERT INTO brands (brand_name,brand_slug,brand_category,headquarters_city,headquarters_lat,headquarters_lon,founded_year,annual_revenue,social_tier) VALUES ('BoldBrew','boldbrew','Beverages','Brooklyn',40.6782,-73.9442,2019,16000000,'emerging');
INSERT INTO brands (brand_name,brand_slug,brand_category,headquarters_city,headquarters_lat,headquarters_lon,founded_year,annual_revenue,social_tier) VALUES ('AtomFit','atomfit','Wearables','Boston',42.3601,-71.0589,2016,92000000,'premium');
INSERT INTO brands (brand_name,brand_slug,brand_category,headquarters_city,headquarters_lat,headquarters_lon,founded_year,annual_revenue,social_tier) VALUES ('CoralReef','coralreef','Sustainability','Honolulu',21.3069,-157.8583,2021,11000000,'emerging');
INSERT INTO brands (brand_name,brand_slug,brand_category,headquarters_city,headquarters_lat,headquarters_lon,founded_year,annual_revenue,social_tier) VALUES ('StridePro','stridepro','Footwear','Boston',42.3601,-71.0589,2015,75000000,'premium');
INSERT INTO brands (brand_name,brand_slug,brand_category,headquarters_city,headquarters_lat,headquarters_lon,founded_year,annual_revenue,social_tier) VALUES ('NovaSkin','novaskin','Beauty','San Francisco',37.7749,-122.4194,2020,33000000,'standard');
INSERT INTO brands (brand_name,brand_slug,brand_category,headquarters_city,headquarters_lat,headquarters_lon,founded_year,annual_revenue,social_tier) VALUES ('ThunderLift','thunderlift','Fitness','Dallas',32.7767,-96.7970,2017,48000000,'standard');
INSERT INTO brands (brand_name,brand_slug,brand_category,headquarters_city,headquarters_lat,headquarters_lon,founded_year,annual_revenue,social_tier) VALUES ('HaloVision','halovision','Electronics','San Jose',37.3382,-121.8863,2019,200000000,'luxury');
INSERT INTO brands (brand_name,brand_slug,brand_category,headquarters_city,headquarters_lat,headquarters_lon,founded_year,annual_revenue,social_tier) VALUES ('RusticHome','rustichome','Home','Nashville',36.1627,-86.7816,2018,38000000,'standard');
INSERT INTO brands (brand_name,brand_slug,brand_category,headquarters_city,headquarters_lat,headquarters_lon,founded_year,annual_revenue,social_tier) VALUES ('ElectraVibe','electravibe','Audio','Chicago',41.8781,-87.6298,2020,20000000,'emerging');
INSERT INTO brands (brand_name,brand_slug,brand_category,headquarters_city,headquarters_lat,headquarters_lon,founded_year,annual_revenue,social_tier) VALUES ('ZephyrWind','zephyrwind','Outdoor','Salt Lake City',40.7608,-111.8910,2016,60000000,'standard');
INSERT INTO brands (brand_name,brand_slug,brand_category,headquarters_city,headquarters_lat,headquarters_lon,founded_year,annual_revenue,social_tier) VALUES ('QuantumLeap','quantumleap','Electronics','Boston',42.3601,-71.0589,2014,180000000,'luxury');
INSERT INTO brands (brand_name,brand_slug,brand_category,headquarters_city,headquarters_lat,headquarters_lon,founded_year,annual_revenue,social_tier) VALUES ('SilkVeil','silkveil','Fashion','New York',40.7128,-74.0060,2020,23000000,'emerging');
INSERT INTO brands (brand_name,brand_slug,brand_category,headquarters_city,headquarters_lat,headquarters_lon,founded_year,annual_revenue,social_tier) VALUES ('FlameCook','flamecook','Kitchen','Houston',29.7604,-95.3698,2019,31000000,'standard');
INSERT INTO brands (brand_name,brand_slug,brand_category,headquarters_city,headquarters_lat,headquarters_lon,founded_year,annual_revenue,social_tier) VALUES ('MindfulTech','mindfultech','Wellness','San Francisco',37.7749,-122.4194,2021,14000000,'emerging');
INSERT INTO brands (brand_name,brand_slug,brand_category,headquarters_city,headquarters_lat,headquarters_lon,founded_year,annual_revenue,social_tier) VALUES ('ApexRide','apexride','Sports','Phoenix',33.4484,-112.0740,2017,56000000,'standard');
INSERT INTO brands (brand_name,brand_slug,brand_category,headquarters_city,headquarters_lat,headquarters_lon,founded_year,annual_revenue,social_tier) VALUES ('DarkMatter','darkmatter','Gaming','Los Angeles',34.0522,-118.2437,2018,70000000,'premium');
INSERT INTO brands (brand_name,brand_slug,brand_category,headquarters_city,headquarters_lat,headquarters_lon,founded_year,annual_revenue,social_tier) VALUES ('GoldenHarvest','goldenharvest','Food','Minneapolis',44.9778,-93.2650,2016,85000000,'premium');
INSERT INTO brands (brand_name,brand_slug,brand_category,headquarters_city,headquarters_lat,headquarters_lon,founded_year,annual_revenue,social_tier) VALUES ('NightOwl','nightowl','Beverages','Seattle',47.6062,-122.3321,2020,17000000,'emerging');
INSERT INTO brands (brand_name,brand_slug,brand_category,headquarters_city,headquarters_lat,headquarters_lon,founded_year,annual_revenue,social_tier) VALUES ('ClearPath','clearpath','Wellness','Scottsdale',33.4942,-111.9261,2019,28000000,'standard');
INSERT INTO brands (brand_name,brand_slug,brand_category,headquarters_city,headquarters_lat,headquarters_lon,founded_year,annual_revenue,social_tier) VALUES ('SteelGrip','steelgrip','Tools','Detroit',42.3314,-83.0458,2014,62000000,'standard');
INSERT INTO brands (brand_name,brand_slug,brand_category,headquarters_city,headquarters_lat,headquarters_lon,founded_year,annual_revenue,social_tier) VALUES ('LunaWear','lunawear','Fashion','Miami',25.7617,-80.1918,2022,9000000,'emerging');
INSERT INTO brands (brand_name,brand_slug,brand_category,headquarters_city,headquarters_lat,headquarters_lon,founded_year,annual_revenue,social_tier) VALUES ('RapidCharge','rapidcharge','Electronics','Austin',30.2672,-97.7431,2019,44000000,'standard');
INSERT INTO brands (brand_name,brand_slug,brand_category,headquarters_city,headquarters_lat,headquarters_lon,founded_year,annual_revenue,social_tier) VALUES ('VerdeLife','verdelife','Sustainability','Portland',45.5152,-122.6784,2021,13000000,'emerging');
COMMIT;
PROMPT Brands loaded: 50

-- ============================================================
-- FULFILLMENT CENTERS (30) — individual INSERTs
-- ============================================================
PROMPT Loading fulfillment centers...

INSERT INTO fulfillment_centers (center_name,center_type,city,state_province,postal_code,country,latitude,longitude,capacity_units) VALUES ('NYC Metro Hub','distribution','Edison','New Jersey','08817','US',40.5187,-74.4121,500000);
INSERT INTO fulfillment_centers (center_name,center_type,city,state_province,postal_code,country,latitude,longitude,capacity_units) VALUES ('LA Mega Center','warehouse','Ontario','California','91761','US',34.0633,-117.6509,750000);
INSERT INTO fulfillment_centers (center_name,center_type,city,state_province,postal_code,country,latitude,longitude,capacity_units) VALUES ('Chicago Midwest Hub','distribution','Joliet','Illinois','60435','US',41.5250,-88.0817,400000);
INSERT INTO fulfillment_centers (center_name,center_type,city,state_province,postal_code,country,latitude,longitude,capacity_units) VALUES ('Dallas South Central','warehouse','Lancaster','Texas','75134','US',32.5921,-96.7561,350000);
INSERT INTO fulfillment_centers (center_name,center_type,city,state_province,postal_code,country,latitude,longitude,capacity_units) VALUES ('Atlanta Southeast','distribution','Union City','Georgia','30291','US',33.5871,-84.5421,450000);
INSERT INTO fulfillment_centers (center_name,center_type,city,state_province,postal_code,country,latitude,longitude,capacity_units) VALUES ('Seattle Pacific NW','warehouse','Kent','Washington','98032','US',47.3809,-122.2348,300000);
INSERT INTO fulfillment_centers (center_name,center_type,city,state_province,postal_code,country,latitude,longitude,capacity_units) VALUES ('Miami Southeast','distribution','Hialeah','Florida','33012','US',25.8576,-80.2781,250000);
INSERT INTO fulfillment_centers (center_name,center_type,city,state_province,postal_code,country,latitude,longitude,capacity_units) VALUES ('Denver Mountain West','warehouse','Aurora','Colorado','80011','US',39.7294,-104.8319,200000);
INSERT INTO fulfillment_centers (center_name,center_type,city,state_province,postal_code,country,latitude,longitude,capacity_units) VALUES ('Phoenix Desert Hub','warehouse','Goodyear','Arizona','85338','US',33.4353,-112.3577,280000);
INSERT INTO fulfillment_centers (center_name,center_type,city,state_province,postal_code,country,latitude,longitude,capacity_units) VALUES ('Boston Northeast','distribution','Fall River','Massachusetts','02720','US',41.7015,-71.1550,220000);
INSERT INTO fulfillment_centers (center_name,center_type,city,state_province,postal_code,country,latitude,longitude,capacity_units) VALUES ('Minneapolis North Central','warehouse','Shakopee','Minnesota','55379','US',44.7974,-93.5272,180000);
INSERT INTO fulfillment_centers (center_name,center_type,city,state_province,postal_code,country,latitude,longitude,capacity_units) VALUES ('Portland Pacific','micro','Troutdale','Oregon','97060','US',45.5390,-122.3872,80000);
INSERT INTO fulfillment_centers (center_name,center_type,city,state_province,postal_code,country,latitude,longitude,capacity_units) VALUES ('Nashville Central','warehouse','Lebanon','Tennessee','37087','US',36.2081,-86.2911,250000);
INSERT INTO fulfillment_centers (center_name,center_type,city,state_province,postal_code,country,latitude,longitude,capacity_units) VALUES ('San Francisco Bay','micro','Fremont','California','94538','US',37.5485,-121.9886,120000);
INSERT INTO fulfillment_centers (center_name,center_type,city,state_province,postal_code,country,latitude,longitude,capacity_units) VALUES ('Detroit Great Lakes','warehouse','Romulus','Michigan','48174','US',42.2223,-83.3963,200000);
INSERT INTO fulfillment_centers (center_name,center_type,city,state_province,postal_code,country,latitude,longitude,capacity_units) VALUES ('Philadelphia Mid-Atlantic','distribution','Middletown','Delaware','19709','US',39.4496,-75.7163,350000);
INSERT INTO fulfillment_centers (center_name,center_type,city,state_province,postal_code,country,latitude,longitude,capacity_units) VALUES ('Houston Gulf Coast','warehouse','Missouri City','Texas','77459','US',29.6186,-95.5377,300000);
INSERT INTO fulfillment_centers (center_name,center_type,city,state_province,postal_code,country,latitude,longitude,capacity_units) VALUES ('Salt Lake Mountain','warehouse','West Jordan','Utah','84084','US',40.6097,-111.9391,180000);
INSERT INTO fulfillment_centers (center_name,center_type,city,state_province,postal_code,country,latitude,longitude,capacity_units) VALUES ('Charlotte Southeast','micro','Concord','North Carolina','28027','US',35.4088,-80.5795,100000);
INSERT INTO fulfillment_centers (center_name,center_type,city,state_province,postal_code,country,latitude,longitude,capacity_units) VALUES ('Indianapolis Heartland','warehouse','Plainfield','Indiana','46168','US',39.7043,-86.3994,250000);
INSERT INTO fulfillment_centers (center_name,center_type,city,state_province,postal_code,country,latitude,longitude,capacity_units) VALUES ('Las Vegas West','warehouse','North Las Vegas','Nevada','89030','US',36.1989,-115.1175,200000);
INSERT INTO fulfillment_centers (center_name,center_type,city,state_province,postal_code,country,latitude,longitude,capacity_units) VALUES ('Kansas City Central','distribution','Edwardsville','Kansas','66111','US',39.0614,-94.8193,320000);
INSERT INTO fulfillment_centers (center_name,center_type,city,state_province,postal_code,country,latitude,longitude,capacity_units) VALUES ('Columbus Midwest','warehouse','Etna','Ohio','43018','US',39.9576,-82.6818,220000);
INSERT INTO fulfillment_centers (center_name,center_type,city,state_province,postal_code,country,latitude,longitude,capacity_units) VALUES ('Reno West Hub','warehouse','Sparks','Nevada','89431','US',39.5349,-119.7527,280000);
INSERT INTO fulfillment_centers (center_name,center_type,city,state_province,postal_code,country,latitude,longitude,capacity_units) VALUES ('Tampa Florida','micro','Brandon','Florida','33510','US',27.9378,-82.2859,90000);
INSERT INTO fulfillment_centers (center_name,center_type,city,state_province,postal_code,country,latitude,longitude,capacity_units) VALUES ('Baltimore East Coast','warehouse','Aberdeen','Maryland','21001','US',39.5096,-76.1641,240000);
INSERT INTO fulfillment_centers (center_name,center_type,city,state_province,postal_code,country,latitude,longitude,capacity_units) VALUES ('San Antonio South TX','micro','New Braunfels','Texas','78130','US',29.7030,-98.1245,100000);
INSERT INTO fulfillment_centers (center_name,center_type,city,state_province,postal_code,country,latitude,longitude,capacity_units) VALUES ('Memphis Logistics','distribution','Olive Branch','Mississippi','38654','US',34.9618,-89.8295,400000);
INSERT INTO fulfillment_centers (center_name,center_type,city,state_province,postal_code,country,latitude,longitude,capacity_units) VALUES ('Honolulu Pacific','micro','Kapolei','Hawaii','96707','US',21.3350,-158.0581,50000);
INSERT INTO fulfillment_centers (center_name,center_type,city,state_province,postal_code,country,latitude,longitude,capacity_units) VALUES ('Anchorage Alaska','micro','Anchorage','Alaska','99501','US',61.2181,-149.9003,40000);
COMMIT;
PROMPT Fulfillment centers loaded: 30

@@load_products.sql
@@load_influencers.sql
@@load_customers.sql
@@load_social_posts.sql
@@load_orders.sql
@@load_graph_data.sql
@@load_app_users.sql
@@load_demand_regions.sql
@@load_demand_forecasts.sql

BEGIN
    EXECUTE IMMEDIATE q'[
        MERGE INTO app_dataset_state target
        USING (
            SELECT
                1 AS state_id,
                'demo' AS active_source,
                'Demo Data' AS active_label,
                'v1' AS active_version
            FROM dual
        ) incoming
        ON (target.state_id = incoming.state_id)
        WHEN MATCHED THEN UPDATE SET
            target.active_source = incoming.active_source,
            target.active_label = incoming.active_label,
            target.active_version = incoming.active_version,
            target.updated_at = SYSTIMESTAMP
        WHEN NOT MATCHED THEN INSERT (
            state_id,
            active_source,
            active_label,
            active_version,
            updated_at
        ) VALUES (
            incoming.state_id,
            incoming.active_source,
            incoming.active_label,
            incoming.active_version,
            SYSTIMESTAMP
        )
    ]';
    DBMS_OUTPUT.PUT_LINE('Dataset metadata set to demo.');
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN
            RAISE;
        END IF;
        DBMS_OUTPUT.PUT_LINE('app_dataset_state not present; skipping dataset metadata seed.');
END;
/

PROMPT =====================================================
PROMPT All data loaded successfully!
PROMPT =====================================================
