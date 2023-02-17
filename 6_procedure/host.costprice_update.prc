SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "COSTPRICE_UPDATE" (
   PV_AFACCTNO      IN       VARCHAR2 ,
   PV_SYMBOL        IN       VARCHAR2,
   PV_PRICE         IN       NUMBER,
   PV_TXDATE        IN       VARCHAR2
       )
IS

--
-- PURPOSE: BAO CAO IN HOP DONG MO TIEU KHOAN GIAO DICH KY QUY
-- MODIFICATION HISTORY
-- PERSON       DATE        COMMENTS
-- THENN        05-APR-2012 CREATED
-- ---------    ------      -------------------------------------------
L_COUNT         NUMBER;
L_PREVCOSTPRICE NUMBER(30,7);
L_SEACCTNO      VARCHAR2(20);


BEGIN
    -- GET REPORT'S PARAMETERS
    L_COUNT := 0;
---    L_prevcostprice := 0;
    FOR REC IN (
        SELECT SEC.*
        FROM SEMAST SE, sbsecurities SB, secostprice SEC
        WHERE SE.acctno = SEC.acctno AND SE.codeid = SB.codeid
            AND SB.symbol = PV_SYMBOL AND SE.AFACCTNO = PV_AFACCTNO
            AND SEC.TXDATE >=
                (
                    SELECT MAX(SEC.TXDATE)
                    FROM SEMAST SE, sbsecurities SB, secostprice SEC
                    WHERE SE.acctno = SEC.acctno AND SE.codeid = SB.codeid
                        AND SB.symbol = PV_SYMBOL AND SE.AFACCTNO = PV_AFACCTNO
                        AND TXDATE <= TO_DATE(PV_TXDATE,'DD/MM/RRRR')
                )
        ORDER BY TXDATE
        )
    LOOP
        IF(L_COUNT > 0) THEN
            UPDATE secostprice SET prevcostprice = NVL(L_prevcostprice,0),
                costprice = ROUND(((prevqtty-ddroutqtty)*NVL(L_prevcostprice,0)+dcramt)
                /(prevqtty-ddroutqtty+dcrqtty),6)
            WHERE AUTOID = REC.AUTOID;
                COMMIT;
        ELSE
            UPDATE secostprice SET costprice = PV_PRICE
            WHERE AUTOID = REC.AUTOID;
                COMMIT;
        END IF;

        SELECT ROUND(costprice,6) INTO L_PREVCOSTPRICE FROM secostprice
        WHERE AUTOID = REC.AUTOID;

        L_COUNT := L_COUNT+1;
        L_SEACCTNO := REC.acctno;
    END LOOP;
    UPDATE SEMAST SET costprice = NVL(L_PREVCOSTPRICE,0) WHERE ACCTNO = L_SEACCTNO;
    COMMIT;

EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;

 
 
 
 
/
