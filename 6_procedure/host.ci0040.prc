SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "CI0040" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   pv_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   I_BRIDGD       IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2
)
IS
--
-- PHIEU TINH LAI TOAN CONG TY
-- MODIFICATION HISTORY
-- PERSON         DATE           COMMENTS
-- QUOCTA      16/01/2012      EDIT FOR BVS
-- ---------   ------  -------------------------------------------

   V_STROPTION         VARCHAR2 (5);            -- A: ALL; B: BRANCH; S: SUB-BRANCH
   V_STRBRID           VARCHAR2 (40);            -- USED WHEN V_NUMOPTION > 0
   V_INBRID            VARCHAR2 (4);

   V_I_BRIDGD          VARCHAR2(100);
   V_BRNAME            NVARCHAR2(400);

   V_FROMDATE          DATE;
   V_TODATE            DATE;


BEGIN

   V_STROPTION := upper(OPT);
   V_INBRID := pv_BRID;

    IF V_STROPTION = 'A' then
        V_STRBRID := '%';
    ELSIF V_STROPTION = 'B' then
        select brgrp.mapid into V_STRBRID from brgrp where brgrp.brid = V_INBRID;
    else
        V_STRBRID:=pv_BRID;
    END IF;

-- GET REPORT'S PARAMETERS

    IF (I_BRIDGD <> 'ALL' OR I_BRIDGD <> '')
    THEN
         V_I_BRIDGD :=  I_BRIDGD;
    ELSE
         V_I_BRIDGD := '%';
    END IF;

    IF (I_BRIDGD <> 'ALL' OR I_BRIDGD <> '')
    THEN
      BEGIN
            SELECT BRNAME INTO V_BRNAME FROM BRGRP WHERE BRID LIKE I_BRIDGD;
      END;
    ELSE
         V_BRNAME   :=  'ALL';
    END IF;

    V_FROMDATE        := TO_DATE(F_DATE, SYSTEMNUMS.C_DATE_FORMAT);
    V_TODATE          := TO_DATE(T_DATE, SYSTEMNUMS.C_DATE_FORMAT);

-- GET REPORT'S DATA
      OPEN PV_REFCURSOR
      FOR

         SELECT 'VND' MNT, V_BRNAME BRNAME, CF.FULLNAME, CF.CUSTODYCD, AF.ACCTNO, SUM(NVL(CIT.INTAMT, 0)) INTAMT,
                SUM(NVL(CIT.BALANCE, 0)) BALANCE,SUM(NVL(CIT.EMKAMT, 0)) EMKAMT,SUM(NVL(CIT.INTBUYAMT, 0)) INTBUYAMT,
                SUM(NVL(CIT.INTCAAMT, 0)) INTCAAMT,SUM(NVL(CIT.INTBAL, 0)) INTBAL
         FROM   AFMAST AF, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF, (SELECT * FROM CIINTTRAN UNION ALL SELECT * FROM CIINTTRANA) CIT
         WHERE  AF.CUSTID        =   CF.CUSTID
         AND    AF.ACCTNO        =   CIT.ACCTNO
         AND    CIT.INTTYPE      =   'CR'
         AND    CIT.FRDATE       BETWEEN V_FROMDATE AND V_TODATE
         AND cf.brid LIKE V_I_BRIDGD
       -- AND (af.brid LIKE V_STRBRID or INSTR(V_STRBRID,af.brid) <> 0 )
         GROUP  BY CF.CUSTODYCD, AF.ACCTNO, CF.FULLNAME
         ORDER  BY CF.CUSTODYCD, AF.ACCTNO
         ;
 EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;

 
 
 
 
/
