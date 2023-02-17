SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "OD0017" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   pv_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2,
   PV_CUSTODYCD      IN       VARCHAR2,
   PV_ACCTNO        IN      VARCHAR2,
   PV_COREBANK       IN       VARCHAR2,
   PV_BANKCODE      IN        VARCHAR2,
   PV_GRCAREBY    IN        VARCHAR2,
   PV_CUSTTYPE      IN      VARCHAR2,
   PV_SECTYPE     IN       VARCHAR2,
   TLID            IN       VARCHAR2,
   TRADEPLACE      IN      VARCHAR2

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
   V_STRTRADEPLACE      VARCHAR2(100);
   V_STRSECTYPE        VARCHAR (40);

BEGIN
   V_STROPTION := upper(OPT);
   V_INBRID := pv_BRID;
   V_STRTLID:= TLID;
   IF (V_STROPTION = 'A') THEN
      V_STRBRID := '%';
   ELSE if (V_STROPTION = 'B') then
            select brgrp.brid into V_STRBRID from brgrp where brgrp.brid = V_INBRID;
        else
            V_STRBRID := V_INBRID;
        end if;
   END IF;

   SELECT TO_DATE(SY.VARVALUE, SYSTEMNUMS.C_DATE_FORMAT) INTO V_CURRDATE
   FROM SYSVAR SY WHERE SY.VARNAME = 'CURRDATE' AND SY.GRNAME = 'SYSTEM';

   IF (PV_CUSTODYCD <> 'ALL')
   THEN
      V_STRCUSTOCYCD := PV_CUSTODYCD;
   ELSE
      V_STRCUSTOCYCD := '%%';
   END IF;

   IF (PV_ACCTNO <> 'ALL')
   THEN
      V_STRACCTNO := PV_ACCTNO;
   ELSE
      V_STRACCTNO := '%%';
   END IF;

   IF (PV_COREBANK <> 'ALL')
   THEN
      V_STRCOREBANK := PV_COREBANK;
   ELSE
      V_STRCOREBANK := '%%';
   END IF;

   IF (PV_BANKCODE <> 'ALL')
   THEN
      V_STRBANKCODE := PV_BANKCODE;
   ELSE
      V_STRBANKCODE := '%%';
   END IF;

    IF (PV_GRCAREBY <> 'ALL')
    THEN
     V_CAREBY := PV_GRCAREBY;
    ELSE
      V_CAREBY:='%';
    END IF;

   IF (PV_CUSTTYPE <> 'ALL')
   THEN
      V_CUSTTYPE := PV_CUSTTYPE;
   ELSE
      V_CUSTTYPE := '%%';
   END IF;

      IF (TRADEPLACE <> 'ALL')
   THEN
      V_STRTRADEPLACE := TRADEPLACE;
   ELSE
      V_STRTRADEPLACE := '%%';
   END IF;

   IF (PV_SECTYPE <> 'ALL')
   THEN
      V_STRSECTYPE := PV_SECTYPE;
   ELSE
      V_STRSECTYPE := '%%';
   END IF;

OPEN PV_REFCURSOR
  FOR
/*SELECT a.fullname, a.custodycd, a.S_qtty, a.S_amt, a.B_qtty, a.B_amt, a.fee, b.vat
FROM
(*/
/*SELECT cf.fullname, cf.custodycd,
       sum(CASE WHEN iod.bors = 'S' THEN iod.matchqtty ELSE 0 END) S_qtty,
       sum(CASE WHEN iod.bors = 'S' THEN iod.matchqtty*iod.matchprice ELSE 0 END) S_amt,
       sum(CASE WHEN iod.bors = 'B' THEN iod.matchqtty ELSE 0 END) B_qtty,
       sum(CASE WHEN iod.bors = 'B' THEN iod.matchqtty*iod.matchprice ELSE 0 END) B_amt,
       sum(CASE WHEN od.execamt = 0 THEN 0 ELSE
            (CASE WHEN od.TXDATE = V_CURRDATE THEN ROUND(IOd.matchqtty * iod.matchprice * odtype.deffeerate / 100, 2)
            ELSE iod.iodfeeacr END)
               END) fee
FROM vw_iod_all iod,
     vw_odmast_all od, afmast af, cfmast cf,aftype, odtype, sbsecurities sb
WHERE od.orderid = iod.orgorderid
    AND iod.deltd <> 'Y' AND od.deltd <> 'Y'
    AND od.afacctno = af.acctno
    AND af.custid = cf.custid
    AND AF.ACTYPE NOT IN ('0000')
    AND af.actype = aftype.actype
    AND odtype.actype = od.actype
    AND od.codeid = sb.codeid
    AND iod.txdate >= TO_DATE(F_DATE,'DD/MM/YYYY')
    AND iod.txdate <= TO_DATE(T_DATE,'DD/MM/YYYY')
    AND CF.CUSTODYCD LIKE V_STRCUSTOCYCD
    AND AF.ACCTNO LIKE V_STRACCTNO
    AND AF.COREBANK LIKE V_STRCOREBANK
    AND AF.BANKNAME LIKE V_STRBANKCODE
    AND cf.custtype LIKE V_CUSTTYPE
    AND af.careby LIKE V_CAREBY
    AND   (SUBSTR(af.acctno,1,4) like  V_STRBRID or instr(V_STRBRID,SUBSTR(af.acctno,1,4)) <> 0)
    and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = V_STRTLID )
GROUP BY cf.fullname, cf.custodycd
HAVING sum(iod.matchprice*iod.matchqtty) > 0
ORDER BY cf.fullname, cf.custodycd*/
SELECT cf.fullname, cf.custodycd,SB.TRADEPLACE,A0.CDCONTENT SAN,
       sum(CASE WHEN OD.exectype IN ('MS','NS','SS') THEN OD.execqtty ELSE 0 END) S_qtty,
       sum(CASE WHEN OD.exectype IN ('MS','NS','SS') THEN OD.execamt ELSE 0 END) S_amt,
       sum(CASE WHEN OD.exectype = 'NB' THEN OD.execqtty ELSE 0 END) B_qtty,
       sum(CASE WHEN OD.exectype = 'NB' THEN OD.execamt ELSE 0 END) B_amt,
       sum(CASE WHEN od.execamt = 0 THEN 0 ELSE
            (CASE WHEN od.TXDATE = V_CURRDATE and OD.feeacr=0 THEN ROUND(OD.execamt * odtype.deffeerate / 100, 2)
            ELSE OD.feeacr END)
        END) fee,
      SUM(CASE WHEN od.EXECTYPE IN('NS','SS','MS')THEN
      (CASE WHEN od.txdate  = V_CURRDATE THEN ROUND((DECODE ( CF.VAT,'Y',TO_NUMBER(SYS.VARVALUE),'N',0) +DECODE ( CF.WHTAX,'Y',TO_NUMBER(SYS1.VARVALUE),'N',0)  )/100*OD.execamt)
        ELSE decode(Cf.vat,'Y', od.taxsellamt,0) END)
      ELSE 0 END) VAT
/*CASE WHEN od.EXECTYPE IN('NS','SS','MS') AND cf.VAT = 'Y' THEN od.taxsellamt else 0 end
        sum(CASE WHEN iod.txdate  = V_CURRDATE
            AND aftype.vat = 'Y' AND b.price IS NOT NULL AND b.price < sb.parvalue THEN 0
                WHEN iod.txdate  = V_CURRDATE AND aftype.vat = 'Y' AND b.price IS NULL THEN  (iod.matchqtty*iod.matchprice*od.taxrate/100)
                ELSE decode(aftype.vat,'Y', od.taxsellamt,0) END ) vat*/
FROM vw_odmast_all od, afmast af,ALLCODE A0, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf,aftype, odtype, sbsecurities sb
, SYSVAR SYS, SYSVAR SYS1
WHERE od.deltd <> 'Y'
    AND od.afacctno = af.acctno
    AND SYS.GRNAME = 'SYSTEM' AND SYS.VARNAME = 'ADVSELLDUTY'
    AND SYS1.GRNAME = 'SYSTEM' AND SYS1.VARNAME = 'WHTAX'
    AND af.custid = cf.custid
    AND AF.ACTYPE NOT IN ('0000')
    AND af.actype = aftype.actype
    AND odtype.actype = od.actype
    AND od.codeid = sb.codeid
     AND A0.CDTYPE='OD' AND A0.CDNAME='TRADEPLACE' AND A0.CDVAL=SB.TRADEPLACE
    AND od.txdate >= TO_DATE(F_DATE,'DD/MM/YYYY')
    AND od.txdate <= TO_DATE(T_DATE,'DD/MM/YYYY')
    AND CF.CUSTODYCD LIKE V_STRCUSTOCYCD
    AND AF.ACCTNO LIKE V_STRACCTNO
    AND AF.COREBANK LIKE V_STRCOREBANK
    AND AF.BANKNAME LIKE V_STRBANKCODE
    AND cf.custtype LIKE V_CUSTTYPE
    AND af.careby LIKE V_CAREBY
    AND OD.execamt > 0
    AND SB.TRADEPLACE LIKE V_STRTRADEPLACE
    AND CASE WHEN V_STRSECTYPE = '%%' THEN 1
         WHEN V_STRSECTYPE <>  '%' AND instr(V_STRSECTYPE, sb.sectype ) <> 0 THEN 1
         ELSE 0 END = 1

GROUP BY cf.fullname, cf.custodycd,SB.TRADEPLACE,A0.CDCONTENT
ORDER BY SB.TRADEPLACE,cf.fullname, cf.custodycd
/*) a ,
(
SELECT custodycd, sum(taxsellamt) vat FROM
    (
    SELECT DISTINCT od.orderid, iod.custodycd,
       (CASE WHEN od.EXECTYPE IN('NS','SS','MS') AND cf.VAT = 'Y' THEN od.taxsellamt else 0 end) taxsellamt
    FROM vw_iod_all iod , vw_odmast_all od, odtype odt , aftype, afmast af, cfmast cf
    WHERE iod.custodycd LIKE V_STRCUSTOCYCD
    AND AF.ACCTNO LIKE V_STRACCTNO and af.custid = cf.custid
    AND AF.ACTYPE NOT IN ('0000')
    AND AF.COREBANK LIKE V_STRCOREBANK
    AND AF.BANKNAME LIKE V_STRBANKCODE
    AND af.careby LIKE V_CAREBY
    AND   (SUBSTR(af.acctno,1,4) like  V_STRBRID or instr(V_STRBRID,SUBSTR(af.acctno,1,4)) <> 0)
    AND odt.actype = od.actype
    AND iod.txdate >= TO_DATE(F_DATE,'DD/MM/YYYY')
    AND iod.txdate <= TO_DATE(T_DATE,'DD/MM/YYYY')
    AND od.orderid = iod.orgorderid
    AND od.afacctno = af.acctno
    AND af.actype = aftype.actype
    and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = V_STRTLID )
    )
GROUP BY custodycd
) b
WHERE a.custodycd = b.custodycd(+)
ORDER BY a.custodycd*/
;



EXCEPTION
   WHEN OTHERS
   THEN

      RETURN;
End;
 
/
