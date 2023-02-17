SET DEFINE OFF;
CREATE OR REPLACE FUNCTION getpdate  (busdate IN DATE,
    clearday IN NUMBER)
  RETURN  DATE IS

   pdate  DATE;
BEGIN
    IF clearday=0 THEN
        pdate:=busdate;
    ELSE
/* Formatted on 2009/04/28 15:32 (Formatter Plus v4.8.6) */
SELECT sbdate
  INTO pdate
  FROM (SELECT ROWNUM DAY, cldr.sbdate
          FROM (SELECT   sbdate
                    FROM sbcldr
                   WHERE sbdate < busdate
                     AND holiday = 'N'
                     AND cldrtype = '001'
                ORDER BY sbdate DESC) cldr) rl
 WHERE rl.DAY = clearday;


    END IF;
    RETURN pdate;
EXCEPTION
   WHEN OTHERS THEN
    RETURN SYSDATE;
END;
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
/
