CREATE DATABASE practice_procedure;
USE practice_procedure;

-- 1.1. Create a table soil_sensors if it does not exist with the following columns:
-- • sensor_id (INT, Primary Key)
-- • moisture_level (INT)
-- • recorded_time (DATETIME)
-- drop table soil_sensors;
CREATE TABLE IF NOT EXISTS soil_sensors (
    sensor_id INT NOT NULL,
    moisture_level INT,
    recorded_time DATETIME,
    PRIMARY KEY (sensor_id)
);

INSERT INTO soil_sensors (sensor_id, moisture_level, recorded_time) VALUES
(1, 30, '2026-1-1'),
(2, 55, '2026-1-2'),
(3, 20, '2026-1-3'),
(4, 75, '2026-1-4'),
(5, 40, '2026-1-5');

-- 1.2. Then Create a stored procedure GetDryFields that:
-- • Accepts a moisture threshold as an input parameter
-- • Displays all sensor records where moisture_level is below the given threshold.
-- DROP PROCEDURE GetDryFields;
DELIMITER $$
CREATE PROCEDURE GetDryFields(IN moisture_threshold INT)
BEGIN
    SELECT sensor_id, moisture_level, recorded_time
    FROM soil_sensors
    WHERE moisture_level < moisture_threshold;
END$$
DELIMITER ;

CALL GetDryFields(50);

-- 2.1. Create a table fields if it does not exist with the following columns:
-- • field_id (INT, Primary Key)
-- • area_sq_meters (INT)
-- • crop_type (VARCHAR(50))
CREATE TABLE IF NOT EXISTS fields (
    field_id INT NOT NULL,
    area_sq_meters INT,
    crop_type VARCHAR(50),
    PRIMARY KEY (field_id)
);

INSERT INTO fields (field_id, area_sq_meters, crop_type) VALUES
(1, 100, 'Rice'),
(2, 200, 'Corn'),
(3, 300, 'Lettuce'),
(4, 400, 'Wheat'),
(5, 500, 'Eggplant');

-- 2.2. Create a stored function CalculateWaterRequirement that:
-- • Accepts area_sq_meters as input
-- • Returns the total water required per irrigation cycle
-- • Assume 5 liters of water per square meter
DELIMITER $$
CREATE FUNCTION CalculateWaterRequirement(area_sq_meters INT)
RETURNS INT DETERMINISTIC
BEGIN
    DECLARE total_water INT;
    SET total_water = area_sq_meters * 5;
    return total_water;
END$$
DELIMITER ;

SELECT CALCULATEWATERREQUIREMENT(1000) AS water_required;

-- calculate water for each field
SELECT field_id, area_sq_meters, 
CalculateWaterRequirement(area_sq_meters) AS water_for_fields
FROM fields;

-- 3.1. Create a table irrigation_logs if it does not exist with the following columns:
-- • log_id (INT, Primary Key)
-- • field_id (INT)
-- • water_used_liters (DECIMAL(10,2))
-- • irrigation_date (DATE)
CREATE TABLE IF NOT EXISTS irrigation_logs (
    log_id INT NOT NULL,
    field_id INT,
    water_used_liters DECIMAL(10,2),
    irrigation_date DATE,
    PRIMARY KEY (log_id)
);

INSERT INTO irrigation_logs (log_id, field_id, water_used_liters, irrigation_date) VALUES
(1, 1, 100, '2026-01-01'),
(2, 2, 200, '2026-01-01'),
(3, 3, 300, '2026-01-02'),
(4, 4, 400, '2026-01-02'),
(5, 1, 500, '2026-01-03'),
(6, 5, 600, '2026-01-04');

-- 3.2. Create a stored procedure GetTotalWaterUsage that:
-- • Accepts a date as an input parameter
-- • Returns the total water used on that date using an OUT parameter.
DELIMITER $$
CREATE PROCEDURE GetTotalWaterUsage(IN p_irrigation_date DATE, OUT total_water_used DECIMAL(10,2)
)
BEGIN
    SELECT IFNULL(SUM(water_used_liters), 0)
    INTO total_water_used
    FROM irrigation_logs
    WHERE irrigation_date = p_irrigation_date;
END$$
DELIMITER ;

CALL GetTotalWaterUsage('2026-01-01', @total);
SELECT @total AS total_water_used_liters;

-- 4.1. Create a table field_status if it does not exist with the following columns:
-- • field_id (INT, Primary Key)
-- • moisture_level (INT)
CREATE TABLE IF NOT EXISTS field_status (
    field_id INT NOT NULL,
    moisture_level INT,
    PRIMARY KEY (field_id)
);

INSERT INTO field_status (field_id, moisture_level) VALUES
(1, 45),
(2, 25),
(3, 60),
(4, 15),
(5, 30),
(6, 10);

-- 4.2. Create a stored procedure CountCriticalFields that:
-- • Uses a cursor
-- • Iterates through all records
-- • Counts how many fields have a moisture level below 30
-- • Displays the total count
DELIMITER $$
CREATE PROCEDURE CountCriticalFields()
BEGIN
    DECLARE done INT DEFAULT 0;
    DECLARE v_moisture INT;
    DECLARE critical_count INT DEFAULT 0;
    -- Cursor declaration
    DECLARE field_cursor CURSOR FOR
        SELECT moisture_level FROM field_status;
    -- Handle cursor end
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
    OPEN field_cursor;
    count_loop: LOOP
        FETCH field_cursor INTO v_moisture;

        IF done = 1 THEN
            LEAVE count_loop;
        END IF;

        IF v_moisture < 30 THEN
            SET critical_count = critical_count + 1;
        END IF;

    END LOOP;
    CLOSE field_cursor;

    -- Display total count
    SELECT critical_count AS total_critical_fields;
END$$
DELIMITER ;

CALL CountCriticalFields();

-- 5.1. Create a table irrigation_schedule if it does not exist with the following columns:
-- • schedule_id (INT, Primary Key)
-- • field_id (INT)
-- • irrigation_duration (INT) (in minutes)

CREATE TABLE IF NOT EXISTS irrigation_schedule (
    schedule_id INT NOT NULL,
    field_id INT,
    irrigation_duration INT,
    PRIMARY KEY (schedule_id)
);

INSERT INTO irrigation_schedule (schedule_id, field_id, irrigation_duration) VALUES
(1, 1, 30),
(2, 2, 40),
(3, 3, 50),
(4, 4, 60),
(5, 5, 70);

-- 5.2. Create a stored procedure AdjustIrrigationDuration that:
-- • Uses a cursor
-- • Increases irrigation duration by 20%
-- • Updates each row individually
DELIMITER $$
CREATE PROCEDURE AdjustIrrigationDuration()
BEGIN
    DECLARE done INT DEFAULT 0;
    DECLARE v_schedule_id INT;
    DECLARE v_duration INT;

    -- Declare cursor
    DECLARE schedule_cursor CURSOR FOR
        SELECT schedule_id, irrigation_duration
        FROM irrigation_schedule;

    -- hadnle cursor end
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
    OPEN schedule_cursor;
    duration_loop: LOOP
        FETCH schedule_cursor INTO v_schedule_id, v_duration;

        IF done = 1 THEN
            LEAVE duration_loop;
        END IF;

        -- Duration increase 20%
        UPDATE irrigation_schedule
        SET irrigation_duration = irrigation_duration * 1.20
        WHERE schedule_id = v_schedule_id;
    END LOOP;
    CLOSE schedule_cursor;
END$$
DELIMITER ;

CALL AdjustIrrigationDuration();
SELECT * FROM irrigation_schedule;
