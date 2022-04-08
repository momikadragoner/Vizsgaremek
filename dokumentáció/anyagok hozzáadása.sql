BEGIN
	DECLARE x INT DEFAULT 1;
	CREATE TEMPORARY TABLE materials(i INT, name VARCHAR(50));
    SET @sql = CONCAT('INSERT INTO materials(i, name) VALUES ', mats);
  	PREPARE stmt FROM @sql;
  	EXECUTE stmt;
  	DEALLOCATE PREPARE stmt;
    WHILE (x < (length + 1)) DO
        SET @currMatName = (SELECT name FROM materials WHERE materials.i = x);
        IF (SELECT EXISTS (SELECT * from material WHERE material.material_name = @currMatName)) THEN
    		INSERT INTO product_material(material_id, product_id) VALUES( (SELECT material_id FROM material WHERE material_name = @currMatName), prodId);
        ELSE
        	INSERT INTO material(material_name) VALUES(@currMatName);
            INSERT INTO product_material(material_id, product_id) VALUES( (SELECT material_id FROM material WHERE material_name = @currMatName), prodId);
    	END IF;
        SET x = x + 1;
    END WHILE;
END