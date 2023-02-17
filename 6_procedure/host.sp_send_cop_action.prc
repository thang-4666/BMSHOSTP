SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "SP_SEND_COP_ACTION" (pv_refcursor in out pkg_report.ref_cursor,
                                              p_camastid   varchar2) is
begin
  sp_demo_send_cop_action(p_camastid);
  pr_tuning_log('sp_send_cop_action', 'Confirm ' || p_camastid);
  commit;
  open pv_refcursor for
    select sysdate from dual;
end;

 
 
 
 
/
