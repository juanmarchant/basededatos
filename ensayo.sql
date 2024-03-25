DECLARE
    v_n_suc sucursal.nombre_suc%TYPE;
    v_dia_operacion cirugias.fecha_operacion%TYPE;
    v_max cirugias.folio%TYPE ;
    v_min cirugias.folio%TYPE ;
    v_total number := 0;
    v_pct  number(4,1);
BEGIN
    
    select MIN(c.folio), MAX(C.folio)
    into v_min, v_max
    from cirugias c;
    
    for i in v_min  ..  v_max LOOP
    
        SELECT NOMBRE_SUC
        into v_n_suc
        FROM sucursal join medico
        on medico.codigo_suc = sucursal.codigo_suc
        join cirugias
        on cirugias.id_medico = medico.id_medico
        where folio= i;
    
        select SUM(s.precio)
        into v_total
        from det_servicio de join servicio s
        on  s.codigo_serv = de.codigo_serv
        where folio = i;
        
        select porc_desc
        into v_pct
        from descuento
        where v_total between valor_ini and valor_fin;
        
        
        select TO_CHAR(fecha_operacion, 'dd/mm/yyyy')
        into v_dia_operacion
        from cirugias
        where folio= i;
        
        dbms_output.put_line('Folio' || i || '-' || v_total || '-' || v_pct || '-' || v_dia_operacion || '-' || v_n_suc);
        if (RTRIM(TO_CHAR(v_dia_operacion, 'DAY'))  = 'MARTES' ) OR (RTRIM(TO_CHAR(v_dia_operacion, 'DAY'))  = 'JUEVES' ) then 
            v_pct := v_pct + 5;
        end if;
        
        if (RTRIM(TO_CHAR(v_dia_operacion, 'DAY'))  = 'DOMINGO' ) AND (v_pct > 20) then 
            v_pct := v_pct - 10;
        end if;
        
        if (RTRIM(TO_CHAR(v_dia_operacion, 'DAY'))  = 'SÁBADO' ) AND (v_pct > 20) then 
            v_pct := v_pct - 5;
        end if;
        
        
        dbms_output.put_line('Folio' || i || '-' || v_total || '-' || v_pct || '-' || v_dia_operacion || '-' || v_n_suc);
        dbms_output.put_line('----------');
    end loop;
END;


--set serveroutput on;