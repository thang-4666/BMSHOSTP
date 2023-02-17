SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE pr_gentable_count
is
v_count number;
v_sql   varchar2(1000);
begin
    delete from table_count;
    for rec in (
    select object_name from user_objects where object_type ='TABLE' and object_name <> 'TABLE_COUNT'
    and object_name not like 'AQ$%'
    and object_name not like 'SYS%'
    and object_name not like 'FSS%'
    )
    loop
        v_sql:='insert into table_count (table_name, record_num, table_type ) 
                    select  ''' || rec.object_name || ''',(select nvl(count(1),0) from ' 
                    || rec.object_name || '),'''' from dual';
                    
        --dbms_output.put_line('v_sql:' || v_sql);
        EXECUTE IMMEDIATE v_sql;
        commit;
    end loop;

    update table_count a set a.table_type = (select b.table_type from table_count_fix b where a.table_name=b.table_name);
    commit;
end; 
 
 
 
 
/
