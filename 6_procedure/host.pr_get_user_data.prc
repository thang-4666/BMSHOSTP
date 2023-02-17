SET DEFINE OFF;
CREATE OR REPLACE procedure pr_get_user_data(p_refcursor in out pkg_report.ref_cursor, p_username varchar2, p_password varchar2) is
begin
    open p_refcursor for
      select '002C103647' custodycd, 'Phan Minh Thong' fullname from dual;
end pr_get_user_data;

 
 
 
 
 
/
