

DECLARE
    v_id_camion camion.id_camion%TYPE;
    v_contador camion.id_camion%TYPE;
BEGIN
    select count(id_camion), min(id_camion)
    into v_contador, v_id_camion
    from camion;
    
    for i in 1.. v_contador loop
        dbms_output.put_line(i);
    end loop;
END;

--set serveroutput on;


SELECT
    COUNT(c.id_camion)
FROM
    camion          c
    LEFT JOIN arriendo_camion ac ON c.id_camion = ac.id_camion
                                    AND ( ac.fecha_ini_arriendo BETWEEN trunc(add_months(sysdate, - 12),
                                                                  'YEAR') AND trunc(sysdate, 'YEAR') )
    WHERE c.id_camion = 1000;
    --group by c.id_camion;

SELECT
    trunc(add_months(sysdate, - 12),
          'YEAR')
FROM
    dual;