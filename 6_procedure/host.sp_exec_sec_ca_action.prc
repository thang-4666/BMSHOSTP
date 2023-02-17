SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "SP_EXEC_SEC_CA_ACTION" (pv_refcursor in out pkg_report.ref_cursor,
                                              p_camastid   varchar2) is
begin
  sp_demo_exec_cop_action(p_camastid,'SE');
  open pv_refcursor for
    select sysdate from dual;
end;

 
 
 
 
/
