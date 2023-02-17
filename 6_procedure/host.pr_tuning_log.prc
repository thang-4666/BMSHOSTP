SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE pr_tuning_log (p_object_name varchar2,p_description varchar2)
is
begin
    insert into tuning_log (object_name,description,log_time) values (p_object_name,p_description, SYSTIMESTAMP);
    commit;
end; 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
/
