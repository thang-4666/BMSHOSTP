SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "SE0032" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   PV_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2,
   PV_CUSTODYCD   IN       VARCHAR2,
   PV_AFACCTNO    IN       VARCHAR2,
   PLSENT         in       varchar2,
   PV_TOCUSTODYCD   IN       VARCHAR2
)
IS

-- RP NAME : BAO CAO BANG KE CHUNG KHOAN GIAO DICH LO LE
-- PERSON --------------DATE---------------------COMMENTS
-- QUYET.KIEU           11/02/2011               CREATE NEW
-- DIENNT               09/01/2012               EDIT
-- ---------   ------  -------------------------------------------
   V_STRAFACCTNO  VARCHAR2 (15);
   V_CUSTODYCD VARCHAR2 (15);
   V_RECUSTODYCD VARCHAR2 (15);
   V_TYPE  VARCHAR2(10);
   V_FROMDATE DATE;
   V_TODATE DATE;
   V_INBRID        VARCHAR2(4);
   V_STRBRID      VARCHAR2 (50);
   V_STROPTION    VARCHAR2(5);
   --V_CURRDATE date;

BEGIN
-- GET REPORT'S PARAMETERS
   V_STROPTION := upper(OPT);
   V_INBRID := PV_BRID;
    if(V_STROPTION = 'A') then
        V_STRBRID := '%%';
    else
        if(V_STROPTION = 'B') then
            select br.brid into V_STRBRID from brgrp br where  br.brid = V_INBRID;
        else
            V_STRBRID := V_INBRID;
        end if;
    end if;

    V_CUSTODYCD := upper( PV_CUSTODYCD);
    /*select to_date(varvalue,'DD/MM/RRRR') into V_CURRDATE
     from sysvar where varname = 'CURRDATE' and grname = 'SYSTEM';*/

     V_FROMDATE := TO_DATE(F_DATE, 'DD/MM/RRRR');
     V_TODATE := TO_DATE(T_DATE, 'DD/MM/RRRR');

   IF  (PV_AFACCTNO <> 'ALL')
   THEN
         V_STRAFACCTNO := PV_AFACCTNO;
   ELSE
         V_STRAFACCTNO := '%';
   END IF;

   IF(upper(PV_TOCUSTODYCD) = 'ALL' or length(PV_TOCUSTODYCD) < 1) THEN
        V_RECUSTODYCD := '%';
   ELSE
        V_RECUSTODYCD := upper(PV_TOCUSTODYCD);
   END IF;

-- GET REPORT'S DATA
 OPEN PV_REFCURSOR
 FOR
SELECT CF.FULLNAME SENDER, CF.CUSTODYCD SENDER_CUSTCD, AF.ACCTNO SENDER_ACC , SB2.SYMBOL SYMBOL,
       OU.RECUSTODYCD, OU.RECUSTNAME, OU.outward,
       trade /*+  caqtty*/ + strade /*+  scaqtty*/ + ctrade /*+  ccaqtty*/ MSGAMT, SB.parvalue,
       CASE WHEN SB.refcodeid IS NOT NULL AND TRADE /*+ CAQTTY*/ + STRADE /*+ SCAQTTY*/ + CTRADE /*+ CCAQTTY*/ > 0 THEN '7'
            WHEN SB.REFCODEID IS NULL AND TRADE /*+ CAQTTY*/ + STRADE /*+ SCAQTTY */+ CTRADE /*+ CCAQTTY*/ >0 THEN  '1'
            END LOAI_CK,
       CASE  when sb2.tradeplace='002' then ' HNX'
          when sb2.tradeplace='001' then ' HOSE'
          when sb2.tradeplace='005' then ' UPCOM'
          when sb2.tradeplace='007' then ' TRÁI PHIÊU CHUYÊN BIỆT'
          when sb2.tradeplace='008' then ' TÍN PHIẾU'
          when sb2.tradeplace='009' then  ' ĐCCNY'
          else ''END SAN, PLSENT SENTO, MEM.FULLNAME DEPOSITNAME,

            to_number(ou.trtype) LD_CK
FROM SESENDOUT OU,  (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF, AFMAST AF, sbsecurities SB, sbsecurities SB2, deposit_member MEM,
(SELECT * FROM VW_TLLOGFLD_ALL WHERE FLDCD='99') FLD
WHERE OU.DELTD <> 'Y'
AND CF.CUSTID = AF.CUSTID
AND SUBSTR(OU.ACCTNO,1,10) = AF.ACCTNO
AND OU.CODEID = SB.CODEID
AND OU.TXDATE <= V_TODATE AND  OU.TXDATE >= V_FROMDATE
AND OU.DELTD<>'Y'
AND NVL(SB.refcodeid,SB.codeid) = SB2.CODEID
AND OU.outward = MEM.depositid (+)
--AND OU.ID2255 IS NOT NULL
AND CF.CUSTODYCD = V_CUSTODYCD
AND AF.ACCTNO LIKE V_STRAFACCTNO
AND OU.TXDATE=FLD.TXDATE
AND OU.TXNUM=FLD.TXNUM
AND FLD.CVALUE='001'
AND OU.TRTYPE IN ('001','002','003','005','006','007','008','009','013')
AND  TRADE /*+ CAQTTY*/ + STRADE /*+ SCAQTTY*/ + CTRADE /*+ CCAQTTY*/ > 0
AND (af.brid LIKE V_STRBRID or instr(V_STRBRID,af.brid) <> 0 )
AND upper(OU.RECUSTODYCD) LIKE upper(V_RECUSTODYCD)
UNION ALL
SELECT CF.FULLNAME SENDER, CF.CUSTODYCD SENDER_CUSTCD, AF.ACCTNO SENDER_ACC , SB2.SYMBOL SYMBOL,
       OU.RECUSTODYCD, OU.RECUSTNAME, OU.outward,
       blocked + sblocked + cblocked  MSGAMT, SB.parvalue,
       CASE WHEN SB.refcodeid IS NOT NULL AND BLOCKED + SBLOCKED + CBLOCKED > 0 THEN '8'
            WHEN SB.REFCODEID IS NULL AND BLOCKED + SBLOCKED + CBLOCKED > 0 THEN '2'
            END LOAI_CK,
        CASE  when sb2.tradeplace='002' then ' HNX'
          when sb2.tradeplace='001' then ' HOSE'
          when sb2.tradeplace='005' then ' UPCOM'
          when sb2.tradeplace='007' then ' TRÁI PHIÊU CHUYÊN BIỆT'
          when sb2.tradeplace='008' then ' TÍN PHIẾU'
          when sb2.tradeplace='009' then ' ĐCCNY'
          else ''END SAN, PLSENT SENTO, MEM.FULLNAME DEPOSITNAME,

            to_number(ou.trtype) LD_CK
FROM SESENDOUT OU,  (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF, AFMAST AF, sbsecurities SB, sbsecurities SB2, deposit_member MEM,
(SELECT * FROM VW_TLLOGFLD_ALL WHERE FLDCD='99') FLD
WHERE OU.DELTD <> 'Y'
AND CF.CUSTID = AF.CUSTID
--AND OU.ID2255 IS NOT NULL
AND SUBSTR(OU.ACCTNO,1,10) = AF.ACCTNO
AND OU.CODEID = SB.CODEID
AND OU.TXDATE <= V_TODATE AND  OU.TXDATE >= V_FROMDATE
AND OU.DELTD<>'Y'
AND NVL(SB.refcodeid,SB.codeid) = SB2.CODEID
AND OU.outward = MEM.depositid (+)
AND CF.CUSTODYCD = V_CUSTODYCD
AND AF.ACCTNO LIKE V_STRAFACCTNO
AND  BLOCKED + SBLOCKED + CBLOCKED > 0
AND OU.TXDATE=FLD.TXDATE
AND OU.TXNUM=FLD.TXNUM
AND FLD.CVALUE='001'
AND OU.TRTYPE IN ('001','002','003','005','006','007','008','009','013')
AND (af.brid LIKE V_STRBRID or instr(V_STRBRID,af.brid) <> 0 )
AND upper(OU.RECUSTODYCD) LIKE upper(V_RECUSTODYCD)
;

EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;

 
 
 
 
/
