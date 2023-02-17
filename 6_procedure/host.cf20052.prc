SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "CF20052" (
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
--

   V_STROPTION    VARCHAR2 (5);            -- A: ALL; B: BRANCH; S: SUB-BRANCH
   V_STRBRID      VARCHAR2 (40);            -- USED WHEN V_NUMOPTION > 0
   V_INBRID     VARCHAR2 (5);      -- USED WHEN V_NUMOPTION > 0

   V_TODATE     DATE;
   V_FROMDATE   DATE;
   v_strcustatcom   varchar2(10);

BEGIN
-- INSERT INTO TEMP_BUG(TEXT) VALUES('CF0001');COMMIT;
   V_STROPTION := upper(OPT);
   V_INBRID := BRID;

   if(V_STROPTION = 'A') then
        V_STRBRID := '%';
    else
        if(V_STROPTION = 'B') then
            select br.mapid into V_STRBRID from brgrp br where  br.brid = V_INBRID;
        else
            V_STRBRID := BRID;
        end if;
    end if;

    V_FROMDATE := to_date(F_DATE,'DD/MM/RRRR');
    V_TODATE := to_date(T_DATE,'DD/MM/RRRR');
    if PV_CUSTATCOM = 'Y' then
      V_strcustatcom := '%';
      else
        V_strcustatcom := 'Y';
        end if;
OPEN PV_REFCURSOR FOR

SELECT 0 UT_DK_TN, 0 UT_DK_NN, 0 UT_TK_TN_CREDIT, 0 UT_TK_TN_DEBIT, 0 UT_TK_NN_CREDIT, 0 UT_TK_NN_DEBIT,
        0 UT_CK_TN, 0 UT_CK_NN, 0 UT_VALUE,  0 UT_FEE FROM DUAL
;

EXCEPTION
   WHEN OTHERS
   THEN

      RETURN;
End;

 
 
 
 
/
