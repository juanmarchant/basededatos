CREATE OR REPLACE PROCEDURE sp_prueba1 (
    p_fecha_proceso DATE
) IS

    CURSOR c_vendedor IS
    SELECT
        numrut_vend      AS rut,
        sueldo_base_vend AS sueldo,
        id_ciudad  as comuna,
        id_categoria_vend as tipo_vendedor
    FROM
        vendedor
    ORDER BY
        1;

    v_cont    NUMBER := 0;
    v_truncar VARCHAR2(100) := 'TRUNCATE TABLE haberes_periodo';
BEGIN
    EXECUTE IMMEDIATE v_truncar;
    FOR v_fila IN c_vendedor LOOP
        INSERT INTO haberes_periodo VALUES (
            v_fila.rut,
            EXTRACT(MONTH FROM p_fecha_proceso),
            EXTRACT(YEAR FROM p_fecha_proceso),
            v_fila.sueldo,
            0,
            fn_asign_familiar(v_fila.rut, 3800),
            fn_movilizacion(v_fila.rut, v_fila.comuna, fn_asign_familiar(v_fila.rut, 3800), v_fila.tipo_vendedor),
            55000,
            fn_comis_vta(v_fila.rut, p_fecha_proceso),
            0
        );

        v_cont := v_cont + 1;
    END LOOP;

    dbms_output.put_line('Proceso Finalizado ');
    COMMIT;
END sp_prueba1;

CREATE OR REPLACE FUNCTION fn_asign_familiar (
    p_rut         NUMBER,
    p_monto_carga NUMBER
) RETURN NUMBER IS
    v_plata NUMBER := 0;
BEGIN
    SELECT
        COUNT(carga_familiar.numrut_vend) * p_monto_carga
    INTO v_plata
    FROM
        carga_familiar
    WHERE
        carga_familiar.numrut_vend = p_rut;

    RETURN v_plata;
END fn_asign_familiar;

CREATE OR REPLACE FUNCTION fn_comis_vta (
    p_rut           NUMBER,
    p_fecha_proceso DATE
) RETURN NUMBER IS
    v_monto_comision NUMBER := 0;
BEGIN
    SELECT
        SUM(c.valor_comision)
    INTO v_monto_comision
    FROM
             venta_tickets v
        JOIN com_venta_ticket c ON ( v.nro_ticket = c.nro_ticket )
                                   AND ( EXTRACT(MONTH FROM v.fecha_ticket) ) = EXTRACT(MONTH FROM p_fecha_proceso)
                                   AND ( EXTRACT(YEAR FROM v.fecha_ticket) ) = EXTRACT(YEAR FROM p_fecha_proceso)
    WHERE
        v.numrut_vend = p_rut;

    IF v_monto_comision IS NULL THEN
        v_monto_comision := 0;
    END IF;
    RETURN v_monto_comision;
END fn_comis_vta;


CREATE OR REPLACE FUNCTION FN_MOVILIZACION (
    p_rut NUMBER,
    p_id_ciudad NUMBER,
    p_monto_com NUMBER,
    p_tipo_vendedor NUMBER
) RETURN NUMBER IS
    v_monto_movilizacion NUMBER :=0;
BEGIN
    
    SELECT
        (v.sueldo_base_vend + p_monto_com )
    INTO v_monto_movilizacion
    from vendedor v
    where v.numrut_vend = p_rut;
    
    IF p_id_ciudad in (87,92,107,123) AND p_tipo_vendedor = 3 then
        v_monto_movilizacion:= v_monto_movilizacion + 15000;
    END IF;
    
    v_monto_movilizacion:= v_monto_movilizacion * 0.126;
    RETURN v_monto_movilizacion;
end fn_movilizacion;