CREATE OR REPLACE PROCEDURE sp_datos_camion IS

    v_anno_proceso       NUMBER := TO_NUMBER ( to_char(sysdate, 'YYYY') );
    v_valor_garantia_dia camion.valor_garantia_dia%TYPE;
    v_valor_arriendo_dia camion.valor_arriendo_dia%TYPE;
    v_patente            camion.nro_patente%TYPE;
    v_id_camion          camion.id_camion%TYPE;
    v_pct_rebaja         NUMBER := 0.775;
    v_contador           camion.id_camion%TYPE;
    v_contador_arrendado NUMBER;
BEGIN
    SELECT
        COUNT(id_camion),
        MIN(id_camion)
    INTO
        v_contador,
        v_id_camion
    FROM
        camion;
    
    --TRUNCANDO LA TABLA
    EXECUTE IMMEDIATE 'TRUNCATE TABLE hist_arriendo_anual_camion';
    FOR i IN 1..v_contador LOOP
    
        -- OBTENIENDO LOS DATOS DE LOS CAMIONES Y SUS ARRIENDOS A CONTAR DE EL ANNO DEL PROCESO
        SELECT
            c.nro_patente,
            c.valor_arriendo_dia,
            c.valor_garantia_dia,
            COUNT(ac.id_camion)
        INTO
            v_patente,
            v_valor_arriendo_dia,
            v_valor_garantia_dia,
            v_contador_arrendado
        FROM
            camion          c
            LEFT JOIN arriendo_camion ac ON c.id_camion = ac.id_camion
                                            AND ( ac.fecha_ini_arriendo BETWEEN trunc(add_months(sysdate, - 12),
                                                                                      'YEAR') AND trunc(sysdate, 'YEAR') )
        WHERE
            c.id_camion = v_id_camion
        GROUP BY
            c.nro_patente,
            c.valor_arriendo_dia,
            c.valor_garantia_dia;
        
        --INSERTANDO VALORES A LA TABLA HIST_ARRIENDO_ANUAL_CAMION
        INSERT INTO hist_arriendo_anual_camion VALUES (
            v_anno_proceso,
            v_id_camion,
            v_patente,
            v_valor_arriendo_dia,
            v_valor_garantia_dia,
            v_contador_arrendado
        );
    
         --ACTUALIZAR TABLA DE DATOS EN CAMION .... 
        IF v_contador_arrendado < 4 THEN
            UPDATE camion
            SET
                valor_arriendo_dia = v_valor_arriendo_dia * v_pct_rebaja,
                valor_garantia_dia = v_valor_garantia_dia * v_pct_rebaja
            WHERE
                id_camion = v_id_camion;

        END IF;

        v_id_camion := v_id_camion + 1;
    END LOOP;
    COMMIT;
END sp_datos_camion;

--CREE TABLA TEMPORAL DE CAMIONES PARA ASI PRIMERO ACTUALIZAR SUS VALORES Y VER SI ESTAN BIEN Y LUEGO ACTUALIZAR LA TABLA ORIGINAL
--CREATE TABLE camion_temp
--    AS
--        (
--            SELECT
--                *
--            FROM
--                camion
--        );
--set serveroutput on;