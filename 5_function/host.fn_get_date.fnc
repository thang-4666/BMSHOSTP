SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_get_date(p_date date, p_prevnum number)
return VARCHAR2
is
    l_prevdate VARCHAR2 (20);
    L_PDATE  DATE;
BEGIN
    SELECT MAX(SBDATE) INTO L_PDATE
    FROM sbcldr WHERE SBDATE <= p_date AND holiday = 'N';

    select TO_CHAR(sbdate,'DD/MM/RRRR') into l_prevdate from sbcurrdate where numday=(
        select numday from sbcurrdate
        where sbdate= L_PDATE and sbtype='B'
        ) + p_prevnum
    and sbtype='B';
    return l_prevdate;
exception when others then
return TO_CHAR(p_date,'DD/MM/RRRR') ;
end;
 
 
 
 
/
