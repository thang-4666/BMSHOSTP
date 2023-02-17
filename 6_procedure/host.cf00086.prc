SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "CF00086" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   PV_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   I_DATE         IN       VARCHAR2,
   PV_CUSTODYCD   IN       VARCHAR2,
   PV_AFACCTNO    IN       VARCHAR2,
   PV_AFTYPE      IN      VARCHAR2
 )
IS
--
-- PURPOSE: BRIEFLY EXPLAIN THE FUNCTIONALITY OF THE PROCEDURE
--
-- MODIFICATION HISTORY
-- PERSON      DATE       COMMENTS
-- Diennt      30/09/2011 Create
-- ---------   ------     -------------------------------------------
   V_STROPTION        VARCHAR2 (5);       -- A: ALL; B: BRANCH; S: SUB-BRANCH

   -- DECLARE PROGRAM VARIABLES AS SHOWN ABOVE
   V_STRPV_CUSTODYCD VARCHAR2(20);
   V_STRPV_AFACCTNO VARCHAR2(20);
   V_INBRID        VARCHAR2(4);
   V_STRBRID      VARCHAR2 (50);
   V_STRTLID           VARCHAR2(6);
   V_BALANCE        number;
   V_BALDEFOVD      number;
   V_IN_DATE        date;
   V_CURRDATE       date;
   V_STRAFTYPE      VARCHAR2(100);
BEGIN
/*
   V_STROPTION := OPT;

   IF (V_STROPTION <> 'A') AND (BRID <> 'ALL')
   THEN
      V_STRBRID := BRID;
   ELSE
      V_STRBRID := '%%';
   END IF;*/

--   V_STRTLID:=TLID;
   /*IF(TLID <> 'ALL' AND TLID IS NOT NULL)
   THEN
        V_STRTLID := TLID;
   ELSE
        V_STRTLID := 'ZZZZZZZZZ';
   END IF;
*/
    V_STROPTION := upper(OPT);
    V_INBRID := PV_BRID;
    if(V_STROPTION = 'A') then
        V_STRBRID := '%%';
    else
        if(V_STROPTION = 'B') then
            select br.BRID into V_STRBRID from brgrp br where  br.brid = V_INBRID;
        else
            V_STRBRID := V_INBRID;
        end if;
    end if;


    V_STRPV_CUSTODYCD  := upper(PV_CUSTODYCD);
   IF(PV_AFACCTNO <> 'ALL' AND PV_AFACCTNO IS NOT NULL)
   THEN
        V_STRPV_AFACCTNO := PV_AFACCTNO;
   ELSE
        V_STRPV_AFACCTNO := '%';
   END IF;
    V_IN_DATE       := to_date(I_DATE,'dd/mm/rrrr');
    select to_date(varvalue,'dd/mm/rrrr') into V_CURRDATE from sysvar where varname = 'CURRDATE';

      IF (PV_AFTYPE <> 'ALL' OR PV_AFTYPE <> '')
   THEN
      V_STRAFTYPE :=  PV_AFTYPE;
   ELSE
      V_STRAFTYPE := '%%';
   END IF;

OPEN PV_REFCURSOR
  FOR
   SELECT  V_IN_DATE i_date , rlstype, custodycd, afacctno, rlsdate, overduedate, lnschdid, rlsprin, paid, lnprin, intamt, feeintamt ,fullname, mnemonic,brid,rate
    FROM (
        select NVL(DF.ISVSD,'N') ISVSD,
            decode (NVL(DF.ISVSD,'N'),'Y', decode(ln.ftype||ls.reftype,'AFGP','BL','AFP','CL','DFP','DF','')||'-VSD', decode(ln.ftype||ls.reftype,'AFGP','BL','AFP','CL','DFP','DF','') ) rlstype,
            cf.custodycd, af.acctno afacctno, ls.rlsdate, ls.overduedate, ls.autoid lnschdid,
            ls.nml + ls.ovd +ls.paid rlsprin,
            ls.paid - nvl(lg.paid,0) paid, ls.nml + ls.ovd - nvl(lg.nml,0) - nvl(lg.ovd,0) lnprin,
            ls.intnmlacr + ls.intdue + ls.intovd + ls.intovdprin
            - nvl(lg.intnmlacr,0)- nvl(lg.intdue,0)- nvl(lg.intovd,0)- nvl(lg.intovdprin,0) intamt,
            ls.feeintnmlacr + ls.feeintdue + ls.feeintnmlovd + ls.feeintovdacr+ls.feeovd
            - nvl(lg.feeintnmlacr,0)- nvl(lg.feeintdue,0)- nvl(lg.feeintnmlovd,0)- nvl(lg.feeintovdacr,0) - nvl(lg.feeovd,0) feeintamt,
            cf.fullname, ln.acctno lnacctno, aft.mnemonic,substr(af.acctno,1,4) brid, ln.rate2  rate
        from vw_lnmast_all ln, vw_lnschd_all ls, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf,--RAO CHO HOME
         afmast af,aftype aft, cfmast cfb,
            (select autoid, sum(nml) nml, sum(ovd) ovd, sum(paid) paid,
                sum(intnmlacr) intnmlacr, sum(intdue) intdue, sum(intovd) intovd, sum(intovdprin) intovdprin,
                sum(feeintnmlacr) feeintnmlacr, sum(feeintdue) feeintdue, sum(feeintovd) feeintnmlovd, sum(feeintovdprin) feeintovdacr,sum(feeovd) feeovd
            from (select * from lnschdlog union all select * from lnschdloghist) lg
            where lg.txdate > V_IN_DATE
            group by autoid) lg,
            (/*select re.afacctno, cf.custid recustid
                from reaflnk re, sysvar sys, cfmast cf
                where to_date(varvalue,'DD/MM/RRRR') between re.frdate and re.todate
                and substr(re.reacctno,0,10) = cf.custid
                and varname = 'CURRDATE' and grname = 'SYSTEM'
                and re.status <> 'C' and re.deltd <> 'Y'
                GROUP BY re.afacctno, cf.custid*/

                 select re.afacctno, MAX(cf.custid) recustid
                        from reaflnk re, sysvar sys, cfmast cf,RETYPE
                        where to_date(varvalue,'DD/MM/RRRR') between re.frdate and re.todate
                        and substr(re.reacctno,0,10) = cf.custid
                        and varname = 'CURRDATE' and grname = 'SYSTEM'
                        and re.status <> 'C' and re.deltd <> 'Y'
                        AND   substr(re.reacctno,11) = RETYPE.ACTYPE
                        AND  rerole IN ( 'RM','BM')
                        GROUP BY AFACCTNO

                ) re,
            (select lnacctno, df.actype dftype, dft.isvsd  from dfgroup df, dftype dft where df.actype=dft.actype) df
        where ln.acctno = ls.acctno and instr(ls.reftype,'P') <> 0
            and ln.trfacctno = af.acctno and af.custid = cf.custid
            and ln.custbank = cfb.custid(+)
            and ls.autoid = lg.autoid(+)
            and ln.acctno = df.lnacctno(+)
            and ln.trfacctno = re.afacctno(+)
            and af.actype = aft.actype
            and ls.rlsdate <= V_IN_DATE
            AND AFT.PRODUCTTYPE LIKE V_STRAFTYPE
            and ln.trfacctno  LIKE v_strpv_afacctno
            and cf.custodycd like  v_strpv_custodycd
    ) A
   WHERE a.lnprin+ a.intamt>0
    order by custodycd, afacctno, lnacctno, rlsdate, lnschdid;


EXCEPTION
   WHEN OTHERS
   THEN

      RETURN;
End;
 
 
 
 
/
