create or replace procedure pa_listado_usuarios is
    v_nombre empleado.nombre_emp%TYPE;
    v_apaterno empleado.appaterno_emp%TYPE;
    v_amaterno empleado.apmaterno_emp%TYPE;
   
    v_numrun empleado.numrut_emp%TYPE;
    v_total_empleados number;
    v_inicial number :=100;
begin

    select COUNT(empleado.numrut_emp)
    into v_total_empleados
    from empleado;
   
    select nombre_emp, appaterno_emp, apmaterno_emp
    into v_nombre, v_apaterno, v_amaterno
    from empleado;
   
    for i in 1 .. v_total_empleados loop
       
        dbms_output.put_line(i || '-' || v_inicial);
        v_inicial := v_inicial + 10;
    end loop;
   
end;

--set serveroutput on;