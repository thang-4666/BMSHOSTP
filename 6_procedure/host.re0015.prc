SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "RE0015" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT             IN       VARCHAR2,
   pv_BRID         IN       VARCHAR2,
   TLGOUPS         IN       VARCHAR2,
   TLSCOPE         IN       VARCHAR2,
   F_DATE          IN       VARCHAR2,
   T_DATE          IN       VARCHAR2,
   I_BRIDGD        IN       VARCHAR2,
   PV_CUSTODYCD    IN       VARCHAR2

 )
IS

--BAO CAO DOANH SO VA PHI CUA KHACH HANG CHUA GAN MOI GIOI
--NGOCVTT 04/08/2015
-- ---------   ------  -------------------------------------------
   V_STROPT     VARCHAR2 (50);            -- A: ALL; B: BRANCH; S: SUB-BRANCH
   V_STRBRID       VARCHAR2 (40);            -- USED WHEN V_NUMOPTION > 0
   V_INBRID         VARCHAR2 (50);

   V_TODATE         DATE;
   V_FROMDATE          DATE;
   V_CUDATE        DATE;
   V_I_BRIDGD          VARCHAR2(100);
   V_BRNAME            NVARCHAR2(400);
   V_STRCUSTODYCD    VARCHAR2(100);

BEGIN


    V_STROPT := OPT;

    IF (V_STROPT <> 'A') AND (pv_BRID <> 'ALL')
    THEN
      V_STRBRID := pv_BRID;
    ELSE
      V_STRBRID := '%%';
    END IF;
    -- GET REPORT'S PARAMETERS

       IF (UPPER(I_BRIDGD) <> 'ALL' OR I_BRIDGD <> '')
   THEN
      V_I_BRIDGD :=  I_BRIDGD;
   ELSE
      V_I_BRIDGD := '%%';
   END IF;


    IF PV_CUSTODYCD = 'ALL' OR PV_CUSTODYCD IS NULL THEN
        V_STRCUSTODYCD := '%%';
    ELSE
        V_STRCUSTODYCD := PV_CUSTODYCD;
    END IF;



   V_FROMDATE:=TO_DATE(F_DATE,'DD/MM/YYYY');
   V_TODATE:=TO_DATE(T_DATE,'DD/MM/YYYY');
 SELECT TO_DATE(VARVALUE,'DD/MM/RRRR') INTO V_CUDATE FROM SYSVAR WHERE VARNAME='CURRDATE';

   -- GET REPORT'S DATA
    OPEN  PV_REFCURSOR
     FOR
SELECT * FROM (
SELECT CF.CUSTID, CF.CUSTODYCD, CF.FULLNAME, BR.BRID, BR.BRNAME,
       NVL(OD.AMT,0)-NVL(MG.execamt,0) AMT, NVL(OD.FEE,0)-NVL(MG.feeacr,0) FEE

   FROM (SELECT * FROM CFMAST /*WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0*/) CF,
                (SELECT BR.BRID,BR.BRNAME,TL.GRPID CAREBY FROM BRGRP BR, TLGROUPS TL
                WHERE TL.GRPTYPE='2' AND TL.GRPID NOT IN (SELECT CA.GRPID
                FROM TRADEPLACE PA, TRADECAREBY CA
                WHERE  PA.TRAID=CA.TRADEID AND PA.BRID=SUBSTR(BR.BRID,1,4))
                UNION ALL
                SELECT BRID||TRAID BRID, TRADENAME BRNAME, CA.GRPID CAREBY
                FROM TRADEPLACE PA, TRADECAREBY CA WHERE PA.TRAID=CA.TRADEID) BR,
                (SELECT AF.CUSTID,
                SUM(OD.EXECAMT) AMT,
                SUM( OD.feeacr) FEE
                FROM AFMAST AF,vw_odmast_all OD
                WHERE AF.ACCTNO=OD.AFACCTNO
                AND OD.DELTD<>'Y'
                AND OD.TXDATE BETWEEN V_FROMDATE AND V_TODATE
                AND OD.EXECTYPE IN ('NS','SS','MS','NB','BC')
                GROUP BY AF.CUSTID) OD,
         

                ( SELECT CUSTID, SUM(execamt) execamt,SUM(feeacr) feeacr FROM(
                 SELECT  CF1.CUSTID,od.execamt execamt, od.feeacr feeacr
                FROM reaflnk kh, recflnk mg,
                    afmast af, CFMAST cf1,
          
                 (
                      SELECT afacctno, txdate, execamt EXECAMT, feeacr FROM odmast WHERE deltd <> 'Y'
                          and txdate = V_CUDATE
                          and txdate between V_FROMDATE and V_TODATE
                      /*UNION ALL
                      SELECT afacctno, txdate, execamt EXECAMT, feeacr FROM odmasthist WHERE deltd <> 'Y'*/
                  ) OD
             WHERE kh.refrecflnkid = mg.autoid
                    AND OD.afacctno = af.acctno
                    AND (CASE WHEN V_FROMDATE >= kh.frdate THEN V_FROMDATE ELSE kh.frdate end) <= OD.txdate
                    AND (CASE WHEN V_TODATE <= kh.todate THEN V_TODATE ELSE kh.todate END) >= OD.txdate
                    AND kh.deltd <> 'Y'
                    AND OD.txdate < nvl(kh.clstxdate ,'01-Jan-2222')
                    AND cf1.custid = af.custid AND af.custid = kh.afacctno
                    and V_FROMDATE <= kh.todate
                    AND V_TODATE >= kh.frdate
                union all
                SELECT CF.CUSTID, max(lg.amt) execamt, max(lg.freeamt) feeacr
                from reaf_log lg, afmast af, CFMAST cf
                where lg.txdate >= V_FROMDATE and lg.txdate <= V_TODATE
                    and lg.afacctno = af.acctno and af.custid = cf.custid
                    group by LG.TXDATE,CF.CUSTID,lg.afacctno
                    )
                group by CUSTID
      ) MG
  WHERE  CF.CUSTID=OD.CUSTID
      AND CF.CUSTID=MG.CUSTID(+)
      AND CF.BRID=SUBSTR(BR.BRID,1,4)
      AND CF.CAREBY=BR.CAREBY
      AND BR.BRID LIKE V_I_BRIDGD
      AND CF.CUSTODYCD LIKE V_STRCUSTODYCD
      )
      WHERE AMT+FEE>0
      ORDER BY BRID, CUSTODYCD;

EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;                                                              -- PROCEDURE

 
 
 
 
/
