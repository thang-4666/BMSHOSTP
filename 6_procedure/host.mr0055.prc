SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "MR0055" (
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
--bao cao giao dich thanh toan mua ky quy
--ngocvtt 10/05/2015
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
            select brgrp.mapid into V_STRBRID from brgrp where brgrp.brid = V_INBRID;
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

SELECT lnm.acctno, cf.fullname, br.brname, cf.custodycd, lnm.trfacctno,lns.overduedate,LNS.RLSDATE,
         TL.TXNUM,tl.autoid,tl.txdate,sum(tl.paid) paid, SUM(TL.FEE) FEE,0 GTGT, A0.CDCONTENT PRODUC
FROM vw_lnmast_all  lnm, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf,  afmast af,( SELECT BR.BRID,BR.BRNAME,TL.GRPID CAREBY FROM BRGRP BR, TLGROUPS TL
                   WHERE TL.GRPTYPE='2' AND TL.GRPID NOT IN (SELECT CA.GRPID
                       FROM TRADEPLACE PA, TRADECAREBY CA
                       WHERE  PA.TRAID=CA.TRADEID AND PA.BRID=SUBSTR(BR.BRID,1,4))
                   UNION ALL
                   SELECT BRID||TRAID BRID, TRADENAME BRNAME, CA.GRPID CAREBY
                   FROM TRADEPLACE PA, TRADECAREBY CA WHERE PA.TRAID=CA.TRADEID) BR,vw_lnschd_all lns,AFTYPE AFT,ALLCODE A0,
    (SELECT AUTOID,TXDATE, TXNUM,SUM(PAID) PAID,SUM(INTPAID) INT_MOVE,SUM(FEEPAID) FEE_MOVE,SUM(INTPAID)+SUM(FEEPAID) FEE
      FROM ( --TRA GOC
            SELECT autoid,txnum,txdate,0 nml,0 ovd,paid,0 intpaid,0 feepaid,deltd
            FROM (SELECT * FROM LNSCHDLOG UNION ALL SELECT * FROM LNSCHDLOGHIST )
            WHERE paid  <> 0

            UNION
           --TRA LAI
            SELECT autoid,txnum,txdate,0 nml,0 ovd,0 paid,intpaid, 0 feepaid,deltd
            FROM (SELECT * FROM LNSCHDLOG UNION ALL SELECT * FROM LNSCHDLOGHIST )
            WHERE  intpaid <> 0
                   AND abs(nml)+abs(ovd) +abs(paid) + abs(intpaid) + abs(feepaid) > 0

            UNION
            --TRA PHI+LAI PHI
            SELECT autoid,txnum,txdate,0 nml,0 ovd,0 paid,0 intpaid,feepaid + feeintpaid feepaid,deltd
            FROM (SELECT * FROM LNSCHDLOG UNION ALL SELECT * FROM LNSCHDLOGHIST )
            WHERE  feepaid + feeintpaid <> 0
            AND abs(nml)+abs(ovd) +abs(paid) + abs(intpaid) + abs(feepaid) + abs(feeintpaid) > 0

             ) LNSLOG
    WHERE NVL(DELTD,'N') <>'Y' AND NML<=0 GROUP BY AUTOID, TXDATE,TXNUM)TL
WHERE af.custid=cf.custid
        AND LNM.ACCTNO=LNS.ACCTNO
        AND af.acctno =lnm.trfacctno
        AND CF.BRID=SUBSTR(BR.BRID,1,4)
        and lnm.rlsamt >0
        AND LNM.FTYPE<>'DF'
        AND CF.CAREBY=BR.CAREBY
        AND LNS.RLSDATE IS NOT NULL
        AND TL.AUTOID=LNS.AUTOID
        AND AF.ACTYPE=AFT.ACTYPE
          AND A0.CDTYPE='CF' AND A0.CDNAME='PRODUCTTYPE' AND A0.CDVAL=AFT.PRODUCTTYPE
        AND AFT.PRODUCTTYPE LIKE V_STRAFTYPE
         AND BR.BRID LIKE V_I_BRIDGD
          AND TL.TXDATE>=to_date(F_DATE,'DD/MM/RRRR')
        AND  TL.TXDATE<=to_date(T_DATE,'DD/MM/RRRR')
group by lnm.acctno, cf.fullname, br.brname, cf.custodycd, lnm.trfacctno,LNS.RLSDATE,
       LNS.RLSDATE,lns.overduedate,TL.TXNUM,tl.autoid,tl.txdate,A0.CDCONTENT
       ORDER BY TXDATE,acctno;




 EXCEPTION
   WHEN OTHERS
   THEN
        RETURN;
END;
 
 
 
 
/
