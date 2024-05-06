CREATE OR REPLACE PROCEDURE sp_principal (
    p_fecha_proceso DATE
) IS

    CURSOR c_profesional IS
    SELECT
        numrun_prof   AS rut,
        sueldo        AS sueldo,
        cod_comuna    AS comuna_prof,
        cod_profesion AS profesion_prof
    FROM
        profesional
    ORDER BY
        1;

    v_mes      NUMBER := extract(MONTH FROM p_fecha_proceso);
    v_año_proc NUMBER := extract(YEAR FROM p_fecha_proceso);
    v_msg      VARCHAR2(255);
    v_sql1     VARCHAR2(255) := 'TRUNCATE TABLE detalle_asignacion_mes';
    v_sql2     VARCHAR2(255) := 'TRUNCATE TABLE errores_proceso';
BEGIN
    EXECUTE IMMEDIATE v_sql1;
    EXECUTE IMMEDIATE v_sql2;
    FOR v_fila IN c_profesional LOOP
        dbms_output.put_line(fn_cont_asesoria(v_fila.rut, p_fecha_proceso)
                             || p_fecha_proceso);
    END LOOP;

    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        v_msg := sqlerrm;  --MENSAJE DE ORACLE
        sp_inserta_errores('SP_PRINCIPAL', v_msg);
END sp_principal;


--CONTADOR DE ASESORIAS
CREATE OR REPLACE FUNCTION fn_cont_asesoria (
    p_numrun_prof   NUMBER,
    p_fecha_proceso DATE
) RETURN NUMBER IS
    v_msg            VARCHAR2(255);
    v_cont_asesorias NUMBER;
BEGIN
    SELECT
        COUNT(ase.numrun_prof)
    INTO v_cont_asesorias
    FROM
             profesional pro
        JOIN asesoria ase ON pro.numrun_prof = ase.numrun_prof
    WHERE
            pro.numrun_prof = p_numrun_prof
        AND ( EXTRACT(MONTH FROM ase.inicio_asesoria) ) = EXTRACT(MONTH FROM p_fecha_proceso)
        AND ( EXTRACT(YEAR FROM ase.inicio_asesoria) ) = EXTRACT(YEAR FROM p_fecha_proceso)
    GROUP BY
        pro.nombre;

    RETURN v_cont_asesorias;
EXCEPTION --MANEJAR EL ERROR DE ESTE PROCESO FN ASIGNACION 
    WHEN OTHERS THEN
        v_msg := sqlerrm
                 || ' para el rut  '
                 || p_numrun_prof;  --
        sp_inserta_errores('fn_cont_asesoria', v_msg);
        RETURN 0;
END fn_cont_asesoria;



CREATE OR REPLACE FUNCTION fn_honorario (
    p_numrun_prof   NUMBER,
    p_fecha_proceso DATE
) RETURN NUMBER IS
    v_msg            VARCHAR2(255);
    v_total_honorario NUMBER;
BEGIN
    SELECT
        sum(ase.honorario)
    INTO v_total_honorario
    FROM
             profesional pro
        JOIN asesoria ase ON pro.numrun_prof = ase.numrun_prof
    WHERE
            pro.numrun_prof = p_numrun_prof
        AND ( EXTRACT(MONTH FROM ase.inicio_asesoria) ) = EXTRACT(MONTH FROM p_fecha_proceso)
        AND ( EXTRACT(YEAR FROM ase.inicio_asesoria) ) = EXTRACT(YEAR FROM p_fecha_proceso)
    GROUP BY
        pro.nombre;

    RETURN v_total_honorario;
EXCEPTION --MANEJAR EL ERROR DE ESTE PROCESO FN ASIGNACION 
    WHEN OTHERS THEN
        v_msg := sqlerrm
                 || ' para el rut  '
                 || p_numrun_prof;  --
        sp_inserta_errores('fn_honorario', v_msg);
        RETURN 0;
END fn_honorario;


-- MANEJO DE ERRORES FUNCION
CREATE OR REPLACE PROCEDURE sp_inserta_errores (
    p_rutina VARCHAR2,
    p_error  VARCHAR2
) IS
    v_instruccion VARCHAR2(100);
BEGIN
    v_instruccion := 'INSERT INTO errores_proceso VALUES (sq_error.nextval, :p1 , :p2)';
    EXECUTE IMMEDIATE v_instruccion
        USING p_rutina, p_error;
    COMMIT;
END sp_inserta_errores;