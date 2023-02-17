SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE pr_table_modify(f_table IN  varchar,
    f_field IN  varchar,
    f_command in varchar)
IS
  v_exists number;
BEGIN
  v_exists := 0;
  Select count(*) into v_exists
    from user_tab_cols
    where column_name = UPPER(f_field) and table_name = UPPER(f_table);
  if (v_exists = 0) then
    execute immediate f_command;
  end if;
end;

 
 
 
 
 
 
 
 
 
 
 
/
