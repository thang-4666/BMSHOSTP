SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE od0018 (
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
   PV_BANKCODE      IN        VARCHAR2

 )
IS
--Bao cao tong hop gia tri chuyen nhuong CK
-- created by Chaunh at 4:30PM 21/06/2012
-- ---------   ------  -------------------------------------------
   V_STROPTION        VARCHAR2 (5);       -- A: ALL; B: BRANCH; S: SUB-BRANCH
   V_STRBRID          VARCHAR2 (40);        -- USED WHEN V_NUMOPTION > 0
   V_INBRID           VARCHAR2 (4);

   V_STRCUSTOCYCD           VARCHAR2 (20);
   V_STRACCTNO              VARCHAR2(20);
   V_STRCOREBANK             VARCHAR2 (6);
   V_STRBANKCODE            VARCHAR2 (20);


BEGIN
   V_STROPTION := upper(OPT);
   V_INBRID := pv_BRID;

   IF (V_STROPTION = 'A') THEN
      V_STRBRID := '%';
   ELSE if (V_STROPTION = 'B') then
            select brgrp.mapid into V_STRBRID from brgrp where brgrp.brid = V_INBRID;
        else
            V_STRBRID := V_INBRID;
        end if;
   END IF;


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


OPEN PV_REFCURSOR
  FOR
SELECT a.custodycd, a.fullname, a.cmnd, a.gt_chnh, b.tax FROM
    (
    SELECT iod.custodycd, cf.fullname,
            CASE WHEN cf.country <> 234 THEN cf.tradingcode ELSE cf.idcode END cmnd,
            sum(matchqtty*matchprice) gt_chnh
            /*sum(CASE WHEN chd.status = 'C' THEN iod.matchqtty * iod.matchprice * od.taxrate/100
                     ELSE 0 END ) tax*/
    FROM vw_iod_all iod ,  (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf, vw_odmast_all od, afmast af--, vw_stschd_all chd
    WHERE bors = 'S' AND matchqtty*matchprice > 0 AND iod.deltd <> 'Y'
    AND af.acctno = od.afacctno
    AND AF.ACTYPE NOT IN ('0000')
    AND od.orderid = iod.orgorderid
    AND cf.custid = af.custid
    /*AND chd.duetype IN ('RM','SM')
    AND chd.orgorderid = od.orderid*/
    AND iod.txdate >= TO_DATE(F_DATE,'DD/MM/YYYY')
    AND iod.txdate <= TO_DATE(T_DATE,'DD/MM/YYYY')
    AND CF.CUSTODYCD LIKE V_STRCUSTOCYCD
    AND AF.ACCTNO LIKE V_STRACCTNO
    AND AF.COREBANK LIKE V_STRCOREBANK
    AND AF.BANKNAME LIKE V_STRBANKCODE
    AND (SUBSTR(af.acctno,1,4) like  V_STRBRID or instr(V_STRBRID,SUBSTR(af.acctno,1,4)) <> 0)
    GROUP BY iod.custodycd, cf.fullname,
            CASE WHEN cf.country <> 234 THEN cf.tradingcode ELSE cf.idcode END
    HAVING sum(matchqtty*matchprice) > 0
    ORDER BY cf.fullname, iod.custodycd
    ) a,
    (
    SELECT custodycd, sum(taxsellamt) tax FROM
        (
        SELECT DISTINCT od.orderid, iod.custodycd,
            (CASE WHEN od.EXECTYPE IN('NS','SS','MS') AND (cf.VAT = 'Y' OR CF.WHTAX='Y') THEN od.taxsellamt else 0 end) taxsellamt
        FROM vw_iod_all iod , vw_odmast_all od, odtype odt , aftype, afmast af , (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf
        WHERE iod.custodycd LIKE V_STRCUSTOCYCD
        AND AF.ACCTNO LIKE V_STRACCTNO
        AND AF.ACTYPE NOT IN ('0000')
        AND AF.COREBANK LIKE V_STRCOREBANK
        AND AF.BANKNAME LIKE V_STRBANKCODE and af.custid = cf.custid
        AND   (SUBSTR(af.acctno,1,4) like  V_STRBRID or instr(V_STRBRID,SUBSTR(af.acctno,1,4)) <> 0)
        AND odt.actype = od.actype
        AND iod.txdate >= TO_DATE(F_DATE,'DD/MM/YYYY')
        AND iod.txdate <= TO_DATE(T_DATE,'DD/MM/YYYY')
        AND od.orderid = iod.orgorderid
        AND od.afacctno = af.acctno
        AND af.actype = aftype.actype
        )
    GROUP BY custodycd

    ) b
WHERE a.custodycd = b.custodycd(+)
ORDER BY a.custodycd
;




EXCEPTION
   WHEN OTHERS
   THEN

      RETURN;
End;

 
 
 
 
/
