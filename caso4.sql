DECLARE
    v_contador_1 NUMBER:=0;
    v_contador_2 NUMBER:=0;
    v_contador_3 NUMBER:=0;
    v_contador_4 NUMBER:=0;
    v_contador_5 NUMBER:=0;
    v_ganancias    NUMBER := 200000000;
    v_pct_ganancias NUMBER := 30;
    v_id_emp       empleado.id_emp%TYPE;
    v_sueldo_base  empleado.sueldo_base%TYPE;
    v_contador_max NUMBER;
BEGIN
    SELECT
        COUNT(id_emp),
        MIN(id_emp)
    INTO
        v_contador_max,
        v_id_emp
    FROM
        empleado;

    FOR i IN 1..v_contador_max LOOP
        SELECT
            sueldo_base
        INTO v_sueldo_base
        FROM
            empleado
        WHERE
            id_emp = v_id_emp;

        CASE
            WHEN v_sueldo_base BETWEEN 320000 AND 600000  THEN v_contador_1 := v_contador_1 +1;
            WHEN v_sueldo_base BETWEEN 600001 AND 1300000  THEN v_contador_2 := v_contador_2 +1;
            WHEN v_sueldo_base BETWEEN 1300001 AND 1800000  THEN v_contador_3 := v_contador_3 +1;
            WHEN v_sueldo_base BETWEEN 1800001 AND 2200000  THEN v_contador_4 := v_contador_4 +1;
            WHEN v_sueldo_base >= 2200001   THEN v_contador_5 := v_contador_5 +1;
        END case;

        dbms_output.put_line(v_id_emp
                             || '-'
                             || v_sueldo_base
                             || '-'
                             || v_contador_1);
        v_id_emp := v_id_emp + 10;
    END LOOP;

END;


--SET SERVEROUTPUT ON;