/*
 * load_customers.sql
 * 2000 customers across US metro areas
 */

SET SERVEROUTPUT ON
PROMPT Loading customers...

DECLARE
    TYPE t_city IS RECORD (
        city VARCHAR2(100), state VARCHAR2(100), lat NUMBER, lon NUMBER, zip VARCHAR2(10)
    );
    TYPE t_city_arr IS TABLE OF t_city;
    v_cities t_city_arr := t_city_arr();

    TYPE t_str IS TABLE OF VARCHAR2(100);
    v_fnames t_str := t_str(
        'James','Mary','John','Patricia','Robert','Jennifer','Michael','Linda',
        'William','Elizabeth','David','Barbara','Richard','Susan','Joseph','Jessica',
        'Thomas','Sarah','Christopher','Karen','Charles','Lisa','Daniel','Nancy',
        'Matthew','Betty','Anthony','Margaret','Mark','Sandra','Donald','Ashley',
        'Steven','Kimberly','Andrew','Emily','Paul','Donna','Joshua','Michelle',
        'Kenneth','Carol','Kevin','Amanda','Brian','Dorothy','George','Melissa',
        'Timothy','Deborah','Aiden','Sofia','Liam','Olivia','Noah','Emma',
        'Ethan','Ava','Mason','Isabella','Lucas','Mia','Logan','Charlotte',
        'Jackson','Amelia','Sebastian','Harper','Mateo','Evelyn','Henry','Luna',
        'Owen','Camila','Wyatt','Aria','Jack','Scarlett','Leo','Penelope',
        'Asher','Layla','Ezra','Chloe','Benjamin','Riley','Caleb','Zoey',
        'Samuel','Nora','Dylan','Lily','Gabriel','Eleanor','Elijah','Hannah'
    );
    v_lnames t_str := t_str(
        'Smith','Johnson','Williams','Brown','Jones','Garcia','Miller','Davis',
        'Rodriguez','Martinez','Hernandez','Lopez','Gonzalez','Wilson','Anderson',
        'Thomas','Taylor','Moore','Jackson','Martin','Lee','Perez','Thompson',
        'White','Harris','Sanchez','Clark','Ramirez','Lewis','Robinson','Walker',
        'Young','Allen','King','Wright','Scott','Torres','Nguyen','Hill',
        'Flores','Green','Adams','Nelson','Baker','Hall','Rivera','Campbell',
        'Mitchell','Carter','Roberts','Gomez','Phillips','Evans','Turner','Diaz',
        'Parker','Cruz','Edwards','Collins','Reyes','Stewart','Morris','Morales',
        'Murphy','Cook','Rogers','Gutierrez','Ortiz','Morgan','Cooper','Peterson',
        'Bailey','Reed','Kelly','Howard','Ramos','Kim','Cox','Ward','Richardson',
        'Watson','Brooks','Chavez','Wood','James','Bennett','Gray','Mendoza',
        'Ruiz','Hughes','Price','Alvarez','Castillo','Sanders','Patel','Myers'
    );
    v_tiers t_str := t_str('new','standard','standard','standard','preferred','preferred','vip');
    v_c t_city;
    v_count     NUMBER := 0;
    v_email     VARCHAR2(300);
    v_ltv       NUMBER;
    v_fname_idx NUMBER;
    v_lname_idx NUMBER;
    v_tier_idx  NUMBER;

    PROCEDURE add_city(p_city VARCHAR2, p_state VARCHAR2, p_lat NUMBER, p_lon NUMBER, p_zip VARCHAR2) IS
        v_rec t_city;
    BEGIN
        v_rec.city := p_city; v_rec.state := p_state; v_rec.lat := p_lat;
        v_rec.lon := p_lon; v_rec.zip := p_zip;
        v_cities.EXTEND; v_cities(v_cities.COUNT) := v_rec;
    END;
BEGIN
    add_city('New York','New York',40.7128,-74.0060,'10001');
    add_city('Los Angeles','California',34.0522,-118.2437,'90001');
    add_city('Chicago','Illinois',41.8781,-87.6298,'60601');
    add_city('Houston','Texas',29.7604,-95.3698,'77001');
    add_city('Phoenix','Arizona',33.4484,-112.0740,'85001');
    add_city('Philadelphia','Pennsylvania',39.9526,-75.1652,'19101');
    add_city('San Antonio','Texas',29.4241,-98.4936,'78201');
    add_city('San Diego','California',32.7157,-117.1611,'92101');
    add_city('Dallas','Texas',32.7767,-96.7970,'75201');
    add_city('San Jose','California',37.3382,-121.8863,'95101');
    add_city('Austin','Texas',30.2672,-97.7431,'73301');
    add_city('Jacksonville','Florida',30.3322,-81.6557,'32099');
    add_city('Fort Worth','Texas',32.7555,-97.3308,'76101');
    add_city('Columbus','Ohio',39.9612,-82.9988,'43085');
    add_city('Charlotte','North Carolina',35.2271,-80.8431,'28201');
    add_city('Indianapolis','Indiana',39.7684,-86.1581,'46201');
    add_city('San Francisco','California',37.7749,-122.4194,'94101');
    add_city('Seattle','Washington',47.6062,-122.3321,'98101');
    add_city('Denver','Colorado',39.7392,-104.9903,'80201');
    add_city('Nashville','Tennessee',36.1627,-86.7816,'37201');
    add_city('Portland','Oregon',45.5152,-122.6784,'97201');
    add_city('Las Vegas','Nevada',36.1699,-115.1398,'89101');
    add_city('Miami','Florida',25.7617,-80.1918,'33101');
    add_city('Atlanta','Georgia',33.7490,-84.3880,'30301');
    add_city('Boston','Massachusetts',42.3601,-71.0589,'02101');
    add_city('Minneapolis','Minnesota',44.9778,-93.2650,'55401');
    add_city('Salt Lake City','Utah',40.7608,-111.8910,'84101');
    add_city('Detroit','Michigan',42.3314,-83.0458,'48201');
    add_city('Tampa','Florida',27.9506,-82.4572,'33601');
    add_city('Brooklyn','New York',40.6782,-73.9442,'11201');
    add_city('Raleigh','North Carolina',35.7796,-78.6382,'27601');
    add_city('Scottsdale','Arizona',33.4942,-111.9261,'85251');
    add_city('Honolulu','Hawaii',21.3069,-157.8583,'96801');
    add_city('Boulder','Colorado',40.0150,-105.2705,'80301');
    add_city('Savannah','Georgia',32.0809,-81.0912,'31401');

    FOR i IN 1..2000 LOOP
        v_c := v_cities(MOD(i, v_cities.COUNT) + 1);

        v_email := LOWER(v_fnames(MOD(i, v_fnames.COUNT) + 1)) || '.' ||
                   LOWER(v_lnames(MOD(FLOOR(i/2), v_lnames.COUNT) + 1)) ||
                   i || '@example.com';

        v_ltv := CASE v_tiers(MOD(i, v_tiers.COUNT) + 1)
            WHEN 'vip'       THEN ROUND(DBMS_RANDOM.VALUE(5000, 50000), 2)
            WHEN 'preferred' THEN ROUND(DBMS_RANDOM.VALUE(1000, 8000), 2)
            WHEN 'standard'  THEN ROUND(DBMS_RANDOM.VALUE(100, 2000), 2)
            ELSE ROUND(DBMS_RANDOM.VALUE(0, 200), 2)
        END;

        v_fname_idx := MOD(i, v_fnames.COUNT) + 1;
        v_lname_idx := MOD(FLOOR(i/2), v_lnames.COUNT) + 1;
        v_tier_idx  := MOD(i, v_tiers.COUNT) + 1;

        BEGIN
            INSERT INTO customers (
                email, first_name, last_name, city, state_province, postal_code,
                latitude, longitude, customer_tier, lifetime_value
            ) VALUES (
                v_email,
                v_fnames(v_fname_idx),
                v_lnames(v_lname_idx),
                v_c.city,
                v_c.state,
                v_c.zip,
                v_c.lat + DBMS_RANDOM.VALUE(-0.05, 0.05),
                v_c.lon + DBMS_RANDOM.VALUE(-0.05, 0.05),
                v_tiers(v_tier_idx),
                v_ltv
            );
            v_count := v_count + 1;
        EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN NULL;
        END;
    END LOOP;

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Customers loaded: ' || v_count);
END;
/
