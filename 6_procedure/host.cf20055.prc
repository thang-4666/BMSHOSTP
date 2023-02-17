SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "CF20055" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2,
   PV_CUSTATCOM   IN       VARCHAR2
 )
IS
--Bao cao tong hop phi giao dich toan cong ty
-- created by Chaunh at 10:07AM 21/06/2012
-- ---------   ------  -------------------------------------------
   V_STROPTION        VARCHAR2 (5);       -- A: ALL; B: BRANCH; S: SUB-BRANCH
   V_STRBRID          VARCHAR2 (40);        -- USED WHEN V_NUMOPTION > 0
   V_INBRID           VARCHAR2 (4);

   V_STRCUSTOCYCD           VARCHAR2 (20);
   V_STRACCTNO              VARCHAR2(20);
   V_STRCOREBANK             VARCHAR2 (6);
   V_STRBANKCODE            VARCHAR2 (20);
   V_CURRDATE               DATE;
   V_CAREBY         varchar(20);
   V_CUSTTYPE       varchar(5);
   V_STRTLID           VARCHAR2(6);
   v_strcustatcom   varchar2(10);

BEGIN
   V_STROPTION := upper(OPT);
   V_INBRID := BRID;
   IF (V_STROPTION = 'A') THEN
      V_STRBRID := '%';
   ELSE if (V_STROPTION = 'B') then
            select brgrp.mapid into V_STRBRID from brgrp where brgrp.brid = V_INBRID;
        else
            V_STRBRID := V_INBRID;
        end if;
   END IF;

   SELECT TO_DATE(SY.VARVALUE, SYSTEMNUMS.C_DATE_FORMAT) INTO V_CURRDATE
   FROM SYSVAR SY WHERE SY.VARNAME = 'CURRDATE' AND SY.GRNAME = 'SYSTEM';
   
   if PV_CUSTATCOM = 'Y' then
      V_strcustatcom := '%';
      else
        V_strcustatcom := 'Y';
        end if;

OPEN PV_REFCURSOR
  FOR

SELECT SUM(CASE WHEN tradeplace = '001' THEN FEE ELSE 0 END ) FEEHCM,
       SUM(CASE WHEN tradeplace = '002' THEN FEE ELSE 0 END ) FEEHN,
       SUM(CASE WHEN tradeplace NOT IN ('001','002') THEN FEE ELSE 0 END ) FEEOTHER
FROM
(
    SELECT SB.CODEID, SB.SYMBOL, SB.tradeplace, iod.iodfeeacr fee
    FROM vw_iod_all iod, sbsecurities sb
    WHERE iod.deltd <> 'Y' AND iod.codeid = sb.codeid
        AND iod.txdate >= TO_DATE(F_DATE,'DD/MM/RRRR')
        AND iod.txdate <= TO_DATE(T_DATE,'DD/MM/RRRR')
)
;

EXCEPTION
   WHEN OTHERS
   THEN

      RETURN;
End;

 
 
 
 
/
