SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_get_se_fee_2244( PV_TRTYPE IN VARCHAR2, PV_TYPE IN VARCHAR2, PV_QTTY IN VARCHAR2, PV_PARVALUE IN NUMBER)
    RETURN NUMBER IS
-- Purpose: Phi giao dich 2244
-- MODIFICATION HISTORY
-- Person      Date         Comments
-- ---------   ------       -------------------------------------------
-- NAMNT   09/09/2013     Created
    V_RESULT NUMBER;
    V_STRTYPE VARCHAR2(30);
    PV_STRTRTYPE  VARCHAR2(30);
BEGIN
V_STRTYPE:= REPLACE( PV_TYPE,'''','');
PV_STRTRTYPE:= REPLACE( PV_TRTYPE,'''','');
V_RESULT := 0;
IF V_STRTYPE ='002' then

    if PV_STRTRTYPE='002' THEN
        V_RESULT := PV_QTTY*PV_PARVALUE*0.1/100;
    end if;

    if PV_STRTRTYPE='011' THEN

        V_RESULT := PV_QTTY*PV_PARVALUE*0.001;
    end if;



ELSE
    if PV_STRTRTYPE='002' THEN
        V_RESULT := PV_QTTY*PV_PARVALUE*0.1/100;
    else
        V_RESULT := 0;
    end if;

END IF ;

    if PV_STRTRTYPE='014' THEN

        V_RESULT := case when  PV_QTTY*0.5 < 500000 then  PV_QTTY*0.5 else 500000 end   ;
    end if;

RETURN V_RESULT;
EXCEPTION
   WHEN OTHERS THEN
    RETURN 0;
END;

 
 
 
 
 
 
/
