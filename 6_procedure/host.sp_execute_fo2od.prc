SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "SP_EXECUTE_FO2OD" IS

BEGIN

    while(cspks_system.fn_get_sysvar('SYSTEM','GXJBS_STATUS')='Y') loop

        dbms_lock.sleep(1/10);

        begin
            txpks_auto.pr_fo2od;
        end;

    end loop;

END;

 
 
 
 
/
