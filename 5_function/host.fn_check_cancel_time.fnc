SET DEFINE OFF;
CREATE OR REPLACE function fn_check_cancel_time(p_codeid   varchar2,
                                                p_orderid  VARCHAR2) return number 
is
  l_result       number := 0;
  l_tradePlace   VARCHAR2(100);
  l_beginTime    NUMBER;
  l_endTime      NUMBER;
  l_currTime     NUMBER;
  l_oodstatus    VARCHAR2(10);
begin
  SELECT tradeplace INTO l_tradePlace FROM sbsecurities WHERE codeid = p_codeid;
  SELECT oodstatus INTO l_oodstatus FROM ood WHERE orgorderid = p_orderid;
  l_currTime := TO_CHAR(SYSDATE,'hh24mi');
  IF l_tradePlace IN ('001') AND l_oodstatus NOT IN ('D','N') THEN
    FOR rec IN (SELECT sy.varvalue from sysvar sy WHERE varname LIKE 'STOP_AMEND_CANCEL_TIME_%' AND grname = 'SYSTEM')
    LOOP
      --0915-0925
      l_beginTime := substr(rec.varvalue, 1, 4);
      l_endTime := substr(rec.varvalue,6,4);
      IF (l_currTime >= l_beginTime AND l_currTime <= l_endTime) THEN
        l_result := -1;
        RETURN l_result;
      END IF;
    END  LOOP;
  END IF;
  RETURN l_result;
EXCEPTION
  WHEN OTHERS THEN
    RETURN l_result;
end fn_check_cancel_time;
 
/
