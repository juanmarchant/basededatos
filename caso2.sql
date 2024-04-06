CREATE OR REPLACE PROCEDURE SP_CREAR_USUARIO IS
    v_dvrun_emp           empleado.dvrun_emp%TYPE;
    v_pnombre_emp         empleado.pnombre_emp%TYPE;
    v_snombre_emp         empleado.snombre_emp%TYPE;
    v_appaterno_emp       empleado.appaterno_emp%TYPE;
    v_apmaterno_emp       empleado.apmaterno_emp%TYPE;
    v_numrun_emp          empleado.numrun_emp%TYPE;
    v_sueldo_base         empleado.sueldo_base%TYPE;
    v_id_emp              empleado.id_emp%TYPE;
    v_nombre_estado_civil estado_civil.nombre_estado_civil%TYPE;
    v_fecha_contrato      empleado.fecha_contrato%TYPE;
    v_fecha_nac           empleado.fecha_nac%TYPE;
    v_dos                 VARCHAR(2);
    v_nombre_usuario      VARCHAR(10);
    v_contrasena          VARCHAR(20);
    v_nombre_completo     VARCHAR(70);
    v_id_estado_civil     empleado.id_estado_civil%TYPE;
    v_total_emp           NUMBER;
BEGIN
    
    
    -- TOTAL DE EMPLEADOS Y NUMERO ID INICIAL
    SELECT
        COUNT(id_emp),
        MIN(id_emp)
    INTO
        v_total_emp,
        v_id_emp
    FROM
        empleado;
        
    -- TRUNCANDO TABLA
    EXECUTE IMMEDIATE 'TRUNCATE TABLE usuario_clave';
    
    FOR i IN 1..v_total_emp LOOP
        SELECT
            e.numrun_emp,
            e.dvrun_emp,
            e.pnombre_emp,
            e.snombre_emp,
            e.appaterno_emp,
            e.apmaterno_emp,
            ec.nombre_estado_civil,
            e.fecha_contrato,
            e.fecha_nac,
            e.sueldo_base,
            e.id_estado_civil
        INTO
            v_numrun_emp,
            v_dvrun_emp,
            v_pnombre_emp,
            v_snombre_emp,
            v_appaterno_emp,
            v_apmaterno_emp,
            v_nombre_estado_civil,
            v_fecha_contrato,
            v_fecha_nac,
            v_sueldo_base,
            v_id_estado_civil
        FROM
                 empleado e
            JOIN estado_civil ec ON e.id_estado_civil = ec.id_estado_civil
        WHERE
            e.id_emp = v_id_emp;
        
        -- CREANDO NOMBRE COMPLETO
        v_nombre_completo := v_pnombre_emp
                             || ' '
                             || v_snombre_emp
                             || ' '
                             || v_appaterno_emp
                             || ' '
                             || v_apmaterno_emp;
        
        
        -- CREANDO NOMBRE DE USUARIO 
        v_nombre_usuario := lower(substr(v_nombre_estado_civil, 1, 1))
                            || ''
                            || substr(v_pnombre_emp, 1, 3)
                            || ''
                            || length(v_pnombre_emp)
                            || '*'
                            || substr(v_sueldo_base, -1)
                            || ''
                            || v_dvrun_emp
                            || ''
                            || round(months_between(sysdate, v_fecha_contrato) / 12);

        IF round(months_between(sysdate, v_fecha_contrato) / 12) < 10 THEN
            v_nombre_usuario := v_nombre_usuario || 'X';
        END IF;
        
        --CREANDO CONTRASENA
        v_contrasena := substr(v_numrun_emp, 3, 1)
                        || ''
                        || to_char(add_months(TO_DATE(v_fecha_nac), 24), 'YYYY')
                        || ''
                        || substr(v_sueldo_base - 1, -3);
                        
        --AGREGANDO 
        v_dos :=
            CASE
                WHEN v_id_estado_civil IN ( 10, 60 ) THEN
                    lower(substr(v_appaterno_emp, 1, 2))
                WHEN v_id_estado_civil IN ( 20, 30 ) THEN
                    lower(substr(v_appaterno_emp, 1, 1)
                          || ''
                          || substr(v_appaterno_emp, -1))
                WHEN v_id_estado_civil = 40 THEN
                    lower(substr(v_appaterno_emp, -3, 1)
                          || ''
                          || substr(v_appaterno_emp, -2, 1))
                WHEN v_id_estado_civil = 50 THEN
                    lower(substr(v_appaterno_emp, -2))
            END;
            
        --COMPLETANDO CONTRASENA
        v_contrasena := v_contrasena
                        || ''
                        || v_dos
                        || v_id_emp
                        || to_char(sysdate, 'MMYYYY');
        
        insert into usuario_clave values(v_id_emp, v_numrun_emp, v_dvrun_emp, v_nombre_completo, v_nombre_usuario, v_contrasena);
        v_id_emp := v_id_emp + 10;
    END LOOP;
    COMMIT;
END SP_CREAR_USUARIO;

