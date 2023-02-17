SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "MR0054" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT         IN       VARCHAR2,
   pv_BRID        IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2,
   I_BRID         IN       VARCHAR2,
   PV_AFTYPE      IN       VARCHAR2
)
IS
--tong hop giao dich mua ky quy
--ngocvtt 30/03/2015
-- ---------   ------  -------------------------------------------
   l_STROPTION        VARCHAR2 (5);       -- A: ALL; B: BRANCH; S: SUB-BRANCH
   l_STRBRID          VARCHAR2 (4);
   V_INBRID         VARCHAR2(4);
   V_STRBRID        VARCHAR2 (50);
   V_STROPTION      VARCHAR2(10);
   V_I_BRIDGD          VARCHAR2(100);
   V_BRNAME            NVARCHAR2(400);
   V_STRAFTYPE         VARCHAR2(100);
-- DECLARE PROGRAM VARIABLES AS SHOWN ABOVE

BEGIN

   V_STROPTION := upper(OPT);
   V_INBRID := pv_BRID;

   IF (V_STROPTION = 'A')
   THEN
      V_STRBRID := '%';
   ELSE if (V_STROPTION = 'B') then
            select brgrp.brid into V_STRBRID from brgrp where brgrp.brid = V_INBRID;
        else
            V_STRBRID := V_INBRID;
        end if;
   END IF;


      IF (I_BRID <> 'ALL' OR I_BRID <> '')
   THEN
      V_I_BRIDGD :=  I_BRID;
   ELSE
      V_I_BRIDGD := '%%';
   END IF;

   IF (I_BRID <> 'ALL' OR I_BRID <> '')
   THEN
      BEGIN
           -- SELECT BRNAME INTO V_BRNAME FROM BRGRP WHERE BRID LIKE I_BRID;
             select max(BR.BRNAME) INTO V_BRNAME from (SELECT BR.BRID,BR.BRNAME,TL.GRPID CAREBY FROM BRGRP BR, TLGROUPS TL
                   WHERE TL.GRPTYPE='2' AND TL.GRPID NOT IN (SELECT CA.GRPID
                       FROM TRADEPLACE PA, TRADECAREBY CA
                       WHERE  PA.TRAID=CA.TRADEID AND PA.BRID=SUBSTR(BR.BRID,1,4))
                         
                   UNION ALL
                   SELECT BRID||TRAID BRID, TRADENAME BRNAME, CA.GRPID CAREBY
                   FROM TRADEPLACE PA, TRADECAREBY CA WHERE PA.TRAID=CA.TRADEID) br
                   where br.brid LIKE I_BRID;
      END;
   ELSE
      V_BRNAME   :=  ' Toàn công ty ';
   END IF;


      IF (PV_AFTYPE <> 'ALL' OR PV_AFTYPE <> '')
   THEN
      V_STRAFTYPE :=  PV_AFTYPE;
   ELSE
      V_STRAFTYPE := '%%';
   END IF;

-- GET REPORT'S DATA
OPEN PV_REFCURSOR FOR

  SELECT V_BRNAME bridm,lnm.acctno, cf.fullname, br.brname, cf.custodycd, lnm.trfacctno, NVL(LNS.RLSDATE,'')NGAY_GN,lns.overduedate,
 TL.NML giai_ngan,NVL(TL.TXNUM,'') TXNUM, lns.autoid,A0.CDCONTENT PRODUCT
   FROM vw_lnmast_all  lnm, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf,
     afmast af,vw_lnschd_all lns, Vw_Lnschdlog_All TL, AFTYPE AFT, ALLCODE A0,
     ( SELECT BR.BRID,BR.BRNAME,TL.GRPID CAREBY FROM BRGRP BR, TLGROUPS TL
                   WHERE TL.GRPTYPE='2' AND TL.GRPID NOT IN (SELECT CA.GRPID
                       FROM TRADEPLACE PA, TRADECAREBY CA
                       WHERE  PA.TRAID=CA.TRADEID AND PA.BRID=SUBSTR(BR.BRID,1,4))
                   UNION ALL
                   SELECT BRID||TRAID BRID, TRADENAME BRNAME, CA.GRPID CAREBY
                   FROM TRADEPLACE PA, TRADECAREBY CA WHERE PA.TRAID=CA.TRADEID) BR
   WHERE  af.custid=cf.custid
        AND LNM.ACCTNO=LNS.ACCTNO
        AND af.acctno =lnm.trfacctno
        and lnm.rlsamt >0
        AND TL.TXDATE=LNS.RLSDATE
        AND TL.AUTOID=LNS.AUTOID
        and lns.RLSDATE is not null
        AND TL.NML>0
        AND LNM.FTYPE<>'DF'
        AND AF.ACTYPE=AFT.ACTYPE
        AND CF.CAREBY=BR.CAREBY
        AND CF.BRID=SUBSTR(BR.BRID,1,4)
        AND A0.CDTYPE='CF' AND A0.CDNAME='PRODUCTTYPE' AND A0.CDVAL=AFT.PRODUCTTYPE
        AND AFT.PRODUCTTYPE LIKE V_STRAFTYPE
        AND lns.rlsdate>=to_date(F_DATE,'DD/MM/RRRR')
        AND lns.rlsdate<=to_date(T_DATE,'DD/MM/RRRR')
        AND BR.BRID LIKE V_I_BRIDGD
                 ORDER BY lnm.acctno,TL.TXDATE
    ;
 EXCEPTION
   WHEN OTHERS
   THEN
        RETURN;
END;
 
 
 
 
/
