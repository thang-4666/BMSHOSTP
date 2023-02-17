SET DEFINE OFF;
CREATE OR REPLACE FUNCTION expdate  (busdate IN DATE
)
  RETURN  DATE IS

   duedate  DATE;
   v_holiday varchar2(200);
   v_err varchar2(200);

BEGIN

SELECT holiday INTO v_holiday FROM SBCLDR WHERE CLDRTYPE ='001' AND SBDATE = busdate;

IF v_holiday ='N' THEN


duedate :=busdate;

ELSE

duedate:=  getduedate(busdate,'B','001',1);

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
