--DECLARE
CREATE OR REPLACE PROCEDURE SP_CASO1 IS
    v_dvrun_emp          empleado.dvrun_emp%TYPE;
    v_pnombre_emp        empleado.pnombre_emp%TYPE;
    v_snombre_emp        empleado.snombre_emp%TYPE;
    v_appaterno_emp      empleado.appaterno_emp%TYPE;
    v_apmaterno_emp      empleado.apmaterno_emp%TYPE;
    v_numrun_emp         empleado.numrun_emp%TYPE;
    v_nombre_comuna      comuna.nombre_comuna%TYPE;
    v_sueldo_base        empleado.sueldo_base%TYPE;
    v_id_emp             empleado.id_emp%TYPE;
    v_nombre_completo    VARCHAR(70);
    v_porc_movil_normal  NUMBER;
    v_valor_movil_normal NUMBER;
    v_valor_movil_extra  NUMBER;
    v_valor_total_movil  NUMBER;
    v_total_emp          NUMBER;
BEGIN

    -- CANTIDAD DE EMPLEADOS Y CONTADOR MINIMO
    SELECT
        COUNT(id_emp),
        MIN(id_emp)
    INTO
        v_total_emp,
        v_id_emp
    FROM
        empleado;
        
     --FORMATEAMOS LA TABLA
    EXECUTE IMMEDIATE 'TRUNCATE TABLE PROY_MOVILIZACION';
    FOR i IN 1..v_total_emp LOOP
        
        -- OBTENIENDO DATOS DEL EMPLEADO NOMBRE, DV SUELDO BASE
        SELECT
            e.numrun_emp,
            e.dvrun_emp,
            e.pnombre_emp,
            e.snombre_emp,
            e.appaterno_emp,
            e.apmaterno_emp,
            c.nombre_comuna,
            e.sueldo_base
        INTO
            v_numrun_emp,
            v_dvrun_emp,
            v_pnombre_emp,
            v_snombre_emp,
            v_appaterno_emp,
            v_apmaterno_emp,
            v_nombre_comuna,
            v_sueldo_base
        FROM
                 empleado e
            JOIN comuna c ON e.id_comuna = c.id_comuna
        WHERE
            e.id_emp = v_id_emp;
            
        -- CALCULANDO PORCENTAJE MOVIL NORMAL
        v_porc_movil_normal := floor(v_sueldo_base / 100000);
        
        -- CALCULANDO VALOR MOVIL NORMAL UTILIZANDO PORCENTAJE ANTERIOR
        v_valor_movil_normal := round(v_sueldo_base *(v_porc_movil_normal / 100));
        
        
        -- CALCULANDO VALOR MOVIL EXTRA
        IF v_nombre_comuna = 'Buin' THEN
            v_valor_movil_extra := 40000;
        ELSIF v_nombre_comuna = 'El Monte' THEN
            v_valor_movil_extra := 35000;
        ELSIF v_nombre_comuna = 'Talagante' THEN
            v_valor_movil_extra := 30000;
        ELSIF v_nombre_comuna = 'Curacaví' THEN
            v_valor_movil_extra := 25000;
        ELSIF v_nombre_comuna = 'María Pinto' THEN
            v_valor_movil_extra := 20000;
        ELSE
            v_valor_movil_extra := 0;
        END IF;
        
        -- CREANDO NOMBRE COMPLETO
        v_nombre_completo := v_pnombre_emp
                             || v_snombre_emp
                             || v_appaterno_emp
                             || v_apmaterno_emp;
        
        -- CALCULANDO VALOR TOTAL MOVIL
        v_valor_total_movil := v_valor_movil_extra + v_valor_movil_normal;
        
       
        
        --INSERTAMOS VALORES A LA TABLA
        INSERT INTO proy_movilizacion VALUES (
            to_char(sysdate, 'YYYY'),
            v_id_emp,
            v_numrun_emp,
            v_dvrun_emp,
            v_nombre_completo,
            v_nombre_comuna,
            v_sueldo_base,
            v_porc_movil_normal,
            v_valor_movil_normal,
            v_valor_movil_extra,
            v_valor_total_movil
        );

        v_id_emp := v_id_emp + 10;
    END LOOP;
    COMMIT;
END SP_CASO1;
--END;