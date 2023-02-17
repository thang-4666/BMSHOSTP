SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "PRC_AUTO_MATCH_ORDER"
  IS
  v_automatch varchar2(20);
  V_HOSTATUS varchar2(20);
BEGIN
  return;
  SELECT      VARVALUE
  INTO        V_HOSTATUS
  FROM        SYSVAR
  WHERE       VARNAME = 'HOSTATUS';


/*IF V_HOSTATUS = '1' THEN

  BEGIN
      SELECT sysvalue INTO v_automatch
      from ordersys_ha where sysname='ISPROCESS';
  EXCEPTION WHEN OTHERS THEN
       v_automatch:='N';
  END;
  IF v_automatch='Y' THEN
      txpks_auto.pr_trade_allocating;
  END IF;

END IF;*/
END;

 
 
 
 
/
