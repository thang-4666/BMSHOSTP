SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_get_todate (p_FROMDATE varchar2, p_TDTERM NUMBER)
return VARCHAR2
is
    V_TODATE DATE;
begin

    V_TODATE := TO_DATE(p_FROMDATE,'DD/MM/RRRR') + p_TDTERM;

    /*SELECT MIN(SBDATE) INTO V_TODATE FROM SBCLDR
    WHERE SBDATE >= V_TODATE AND holiday <> 'Y';*/

    return V_TODATE;
exception when others then
       return '01/01/2015';
end;

 
 
 
 
/
