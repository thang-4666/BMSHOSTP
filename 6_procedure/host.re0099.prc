SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE re0099 (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   pv_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2,
   GROUPID         IN       VARCHAR2,
   RECUSTID    IN       VARCHAR2
 )
IS
--bao cao hoa hong
--created by DoNT at 19/09/2016
    V_STROPTION        VARCHAR2 (5);       -- A: ALL; B: BRANCH; S: SUB-BRANCH
    V_STRBRID          VARCHAR2 (40);    -- USED WHEN V_NUMOPTION > 0
    V_INBRID     VARCHAR2 (5);
    VF_DATE DATE;
    VT_DATE DATE;
    V_GROUPID varchar2(10);
    V_CUSTID VARCHAR2(10);
    V_STRRECUSTID   VARCHAR2(20);
    V_CURRDATE DATE;

BEGIN

   V_STROPTION := upper(OPT);
   V_INBRID := pv_BRID;

   if(V_STROPTION = 'A') then
        V_STRBRID := '%';
    else
        if(V_STROPTION = 'B') then
            select br.mapid into V_STRBRID from brgrp br where  br.brid = V_INBRID;
        else
            V_STRBRID := pv_BRID;
        end if;
    end if;

   IF GROUPID <> 'ALL' THEN
        V_GROUPID := GROUPID;
   ELSE V_GROUPID := '%';
   END IF;

   IF (upper(RECUSTID) = 'ALL' or LENGTH(RECUSTID) < 1)  THEN
    V_STRRECUSTID := '%';
   ELSE
    V_STRRECUSTID := UPPER(RECUSTID);
   END IF;
   ------------------------
   VF_DATE := to_date(F_DATE,'DD/MM/RRRR');
   VT_DATE := to_date(T_DATE,'DD/MM/RRRR');

    select to_date(varvalue,'dd/mm/rrrr') into V_CURRDATE from sysvar where varname = 'CURRDATE';

      OPEN PV_REFCURSOR FOR
          SELECT '1' grouprp, reacctno, afacctno, custid, ten_MG, sum(amt) execamt, sum(freeamt) /*(sum(amt) * 0.0015)*/ feetrans,sum(freeamt*ICRATE/100) /*(sum(amt)* 0.000525)*/ feepartner,
        fullname, custodycd, idcode, iddate, idplace
        FROM
            (SELECT MG.reacctno, MG.afacctno, MG.custid, MG.ten_MG, nvl(KH.amt, 0) amt, nvl(KH.freeamt, 0) freeamt, MG.fullname, MG.custodycd,
                    MG.idcode, MG.iddate, MG.idplace,mg.ICRATE
             FROM
            (SELECT lnk.reacctno, lnk.afacctno, cf.custid, cf.fullname ten_mg,
                cf2.fullname, cf2.custodycd, cf2.idcode, cf2.iddate,
                cf2.idplace,icc.ICRATE
            FROM reaflnk lnk, cfmast cf, remast re, cfmast cf2, retype ret, iccftypedef iccf,ICCFTYPEDEF ICC,
                (SELECT lnk.refrecflnkid ma_nhom, lnk.reacctno reacctno, lnk.custid, lnk.frdate, NVL (lnk.clstxdate - 1, lnk.todate) todate
                                  FROM regrplnk lnk
                                 WHERE lnk.status = 'A') grp
                WHERE  lnk.reacctno = grp.reacctno
                    AND lnk.reacctno = re.acctno
                    AND re.custid = cf.custid
                    AND lnk.afacctno = cf2.custid
                    AND re.actype = ret.actype
                    and icc.modcode = 'RE'
                    AND ret.actype = icc.actype
                    AND ret.rerole = 'RD'
                    AND ret.actype = iccf.actype
                    AND iccf.ruletype <> 'C'
                    AND re.custid like V_STRRECUSTID
                    AND grp.ma_nhom LIKE V_GROUPID
                    AND ((lnk.frdate >= to_date(F_DATE, 'DD/MM/RRRR') AND lnk.frdate <= to_date(T_DATE, 'DD/MM/RRRR'))
                        OR (nvl(lnk.clstxdate, lnk.todate) >= to_date(F_DATE, 'DD/MM/RRRR') AND nvl(lnk.clstxdate, lnk.todate) <= to_date(T_DATE, 'DD/MM/RRRR'))
                        OR (lnk.frdate <= to_date(F_DATE, 'DD/MM/RRRR') AND nvl(lnk.clstxdate, lnk.todate) >= to_date(T_DATE, 'DD/MM/RRRR')))
                )MG
            LEFT OUTER join
            (SELECT (lg.reacctno||lg.reactype) reacctno, lg.amt, lg.freeamt, af.custid, lg.txdate
                 FROM reaf_log lg, afmast af
            WHERE lg.txdate >= to_date(F_DATE, 'DD/MM/RRRR')
            AND lg.txdate <= to_date(T_DATE, 'DD/MM/RRRR')
            AND lg.afacctno = af.acctno
            )KH
            ON MG.reacctno = KH.reacctno
            AND MG.afacctno = KH.custid)
            GROUP BY reacctno, afacctno, custid, ten_MG,
                    fullname, custodycd, idcode, iddate, idplace
            ORDER BY custodycd;
EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
End;

 
 
 
 
/
