SET DEFINE OFF;
CREATE OR REPLACE FUNCTION getduedate_NEW  (busdate IN DATE,
    clearcd IN VARCHAR2,
    tradeplace IN VARCHAR2,
    clearday IN NUMBER)
  RETURN  DATE IS

   duedate  DATE;
   v_err varchar2(200);

BEGIN

    IF clearday=0 THEN
        duedate:=busdate;
    ELSE
        IF  clearcd='B' THEN
            /*SELECT SBDATE INTO duedate
                FROM (SELECT ROWNUM DAY, SBDATE
                FROM (SELECT * FROM SBCLDR WHERE CLDRTYPE=tradeplace AND SBDATE>busdate AND HOLIDAY='N' ORDER BY SBDATE) CLDR) RL
                WHERE DAY=clearday;*/
                SELECT SBDATE INTO duedate
                FROM sbcurrdate
                WHERE sbtype='B' AND NUMDAY=clearday;

        ELSE
           /* SELECT SBDATE INTO duedate
                FROM (SELECT ROWNUM DAY, SBDATE
                FROM (SELECT * FROM SBCLDR WHERE CLDRTYPE='000' AND SBDATE>busdate ORDER BY SBDATE) CLDR) RL
                WHERE DAY=clearday;*/
                 SELECT SBDATE INTO duedate
                FROM sbcurrdate
                WHERE sbtype='N' AND NUMDAY=clearday;
        END IF;
    END IF;


    RETURN duedate ;
/*
If busdate ='26-JUN-2009' then
    RETURN '01-JUL-2009';
Else
    RETURN '02-JUL-2009';
END if;
*/
EXCEPTION when others then
   v_err:=substr(sqlerrm,1,199);
       RETURN '01-JAN-2000';
END;
 
 
 
 
/
