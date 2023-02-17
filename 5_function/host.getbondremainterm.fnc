SET DEFINE OFF;
CREATE OR REPLACE FUNCTION getbondremainterm (pv_codeid           VARCHAR2,
                                              pv_sellvaluedate    VARCHAR2)
    RETURN NUMBER
IS
    l_return   NUMBER (20, 2);
BEGIN
    SELECT   NVL (
                 ROUND (
                     (TO_DATE (expdate, 'dd/mm/rrrr')
                      - TO_DATE (pv_sellvaluedate, 'dd/mm/rrrr'))
                     / 365,
                     2),
                 0)
      INTO   l_return
      FROM   sbsecurities
     WHERE   SYMBOL = pv_codeid;

    RETURN l_return;
EXCEPTION
    WHEN OTHERS
    THEN
        RETURN 0;
END;
 
 
 
 
/
