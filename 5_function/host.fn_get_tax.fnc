SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_get_tax (pv_qtty IN VARCHAR2, pv_price IN VARCHAR2,P_CUSTODYCD IN VARCHAR2 )
RETURN NUMBER
iS
    v_result NUMBER(20);
    V_CUSTTYPE NUMBER(20);
    V_DBLTAXRATE NUMBER ;
    V_DBLWHTAX NUMBER ;
BEGIN

    V_DBLTAXRATE := TO_NUMBER(CSPKS_SYSTEM.FN_GET_SYSVAR('SYSTEM',
                                                         'ADVSELLDUTY'));

   V_DBLWHTAX := TO_NUMBER(CSPKS_SYSTEM.FN_GET_SYSVAR('SYSTEM',
                                                         'WHTAX'));

SELECT  (DECODE(VAT,'Y',V_DBLTAXRATE,'N',0)+ DECODE(WHTAX,'Y',V_DBLWHTAX,'N',0))  * pv_qtty *pv_price/100  INTO v_result  FROM CFMAST  WHERE CUSTODYCD = REPLACE( P_CUSTODYCD,'''','');

--SELECT TO_number( varvalue)* pv_qtty *pv_price*V_CUSTTYPE/100 INTO v_result FROM sysvar WHERE varname ='ADVSELLDUTY';

    RETURN v_result;
EXCEPTION WHEN OTHERS THEN
    RETURN 0;
END;

 
 
 
 
/
