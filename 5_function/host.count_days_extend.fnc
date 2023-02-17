SET DEFINE OFF;
CREATE OR REPLACE FUNCTION count_days_extend(pv_strAFACCTNO VARCHAR2)
    RETURN VARCHAR2 IS
    v_Result  NUMBER;
    v_currdate DATE;
    v_nextdate DATE;
    v_count NUMBER;

BEGIN
  v_Result:=0;

  SELECT COUNT(*) INTO v_count FROM afmast   WHERE custid =(SELECT custid FROM afmast WHERE acctno=pv_strAFACCTNO) AND status  IN ('A','P');
  if(v_count>1) THEN
  RETURN v_Result;
  ELSE
    v_count:=2;
  END IF;
  select sbdate - currdate into v_Result from sbcurrdate where numday=0 AND sbtype='N' ;
/*            SELECT to_Date(varvalue, 'DD/MM/YYYY')
              INTO v_currdate
              FROM sysvar
             WHERE varname = 'CURRDATE';
             v_nextdate:=v_currdate;

            WHILE (v_count > 0) LOOP
              BEGIN
                SELECT MIN(sbdate)
                  INTO v_nextdate
                  FROM sbcldr
                 WHERE sbdate > v_nextdate
                   AND holiday = 'N'
                   AND cldrtype = '000';
                   v_count:=v_count-1;
              END;
            END LOOP;
            v_Result:=v_nextdate- v_currdate;

*/    RETURN v_Result;

EXCEPTION
   WHEN OTHERS THEN
    RETURN 0;
END;
 
 
 
 
/
