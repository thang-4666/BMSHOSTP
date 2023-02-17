SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE mr3007 (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   pv_OPT            IN       VARCHAR2,
   pv_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   pv_CUSTDYCD       IN       VARCHAR2,
   pv_AFACCTNO       IN       VARCHAR2,
   I_DATE         IN       VARCHAR2,
   TLID            IN       VARCHAR2
)
IS
--
-- PURPOSE: BRIEFLY EXPLAIN THE FUNCTIONALITY OF THE PROCEDURE
--
-- MODIFICATION HISTORY
-- PERSON      DATE    COMMENTS
-- LINHLNB   11-Apr-2012  CREATED

-- ---------   ------  -------------------------------------------
   l_STROPTION        VARCHAR2 (5);       -- A: ALL; B: BRANCH; S: SUB-BRANCH
   l_STRBRID          VARCHAR2 (4);
   l_AFACCTNO         VARCHAR2 (20);
   v_IDATE           DATE; --ngay lam viec gan ngay idate nhat
   v_CurrDate        DATE;
   V_INBRID        VARCHAR2(4);
   V_STRBRID      VARCHAR2 (50);
   V_STROPTION VARCHAR2(10);
   V_STRTLID           VARCHAR2(6);
  

-- DECLARE PROGRAM VARIABLES AS SHOWN ABOVE
BEGIN


   V_STRTLID:= TLID;
   V_STROPTION := upper(pv_OPT);
   V_INBRID := pv_BRID;
    if(V_STROPTION = 'A') then
        V_STRBRID := '%%';
    else
        if(V_STROPTION = 'B') then
            select br.brid into V_STRBRID from brgrp br where  br.brid = V_INBRID;
        else
            V_STRBRID := V_INBRID;
        end if;
    end if;
   l_AFACCTNO  := replace(pv_AFACCTNO,'.','');

  

 -- END OF GETTING REPORT'S PARAMETERS

   SELECT max(sbdate) INTO v_IDATE  FROM sbcurrdate WHERE sbtype ='B' AND sbdate <= to_date(I_DATE,'DD/MM/RRRR');
   select to_date(varvalue,'DD/MM/RRRR') into v_CurrDate from sysvar where varname = 'CURRDATE' and grname = 'SYSTEM';



IF   v_idate = v_CurrDate THEN
-- GET REPORT'S DATA
    OPEN PV_REFCURSOR
        for
    select af.mrcrlimitmax, ci.balance, ci.depofeeamt, ci.trfbuyamt, nvl(adv.AVLADVANCE,0) AVLADVANCE, nvl(b.SECUREDAMT,0) SECUREDAMT,
    nvl(ln.dfamt,0) dfamt, nvl(ln.dfodamt,0) dfodamt, nvl(ln.t0amt,0) t0amt, nvl(ln.mramt,0) mramt,
    round(abs(least(ci.balance + nvl(adv.AVLADVANCE,0) - nvl(b.SECUREDAMT,0) - ci.trfbuyamt - nvl(ln.t0amt,0) - nvl(ln.mramt,0) /*- ci.depofeeamt*/,0)),0) outstanding,
    round(ci.balance - nvl(b.SECUREDAMT,0) - ci.trfbuyamt + nvl(adv.avladvance,0) + af.advanceline
                            + least(nvl(af.mrcrlimitmax,0)+ nvl(af.mrcrlimit,0)  - ci.dfodamt,nvl(af.mrcrlimit,0) + nvl(sec.seamt,0))
                            - nvl(ci.odamt,0) +  af.clamtlimit /* - ci.depofeeamt*/,0) pp0,
    cf.custodycd, af.acctno afacctno, v.acctno, v.codeid, v.symbol, v.trade,
       v.receiving, v.execqtty, v.buyqtty, v.mortage, v.ratecl,
       v.pricecl, v.callratecl, v.callpricecl, v.callrate74,
       v.callprice74, v.seamt, v.seass, v.sereal, v.mrmaxqtty, v.seqtty,
       round((case when ci.balance + LEAST(nvl(af.MRCRLIMIT,0),nvl(b.SECUREDAMT,0) + ci.trfbuyamt)+ nvl(adv.avladvance,0) - ci.odamt -
    nvl(b.SECUREDAMT,0) - ci.trfbuyamt - ci.ramt>=0 then 100000
    else least( nvl(sec.SEASS,0), af.mrcrlimitmax - ci.dfodamt)
    / abs(ci.balance +LEAST(nvl(af.MRCRLIMIT,0),nvl(b.SECUREDAMT,0) + ci.trfbuyamt)+ nvl(adv.avladvance,0) - ci.odamt - nvl(b.SECUREDAMT,0) -
    ci.trfbuyamt - ci.ramt) end),4) * 100 MARGINRATE
    from (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf, (select * from afmast where acctno = l_AFACCTNO) af,
        (select * from cimast where acctno = l_AFACCTNO)ci,
        (select * from v_getsecmargininfo where afacctno = l_AFACCTNO) sec,
        (select * from vw_getsecmargindetail where afacctno = l_AFACCTNO) v,
        (select afacctno, sum(depoamt) AVLADVANCE
            from v_getaccountavladvance
            where afacctno = l_AFACCTNO group by afacctno) adv,
        (select afacctno, nvl(sum(secureamt),0) SECUREDAMT
            from v_getbuyorderinfo
            where afacctno = l_AFACCTNO group by afacctno) b,
        (select trfacctno,
                nvl(sum(case when ftype = 'DF' then prinnml+prinovd+intnmlacr+intnmlovd+intovdacr+intdue+feeintnmlacr+feeintnmlovd+feeintovdacr+feeintdue else 0 end),0) dfamt,
                nvl(sum(case when ftype = 'DF' then prinnml+prinovd else 0 end),0) dfodamt,
                nvl(sum(case when ftype = 'AF' then oprinnml+oprinovd+ointnmlacr+ointnmlovd+ointovdacr+ointdue else 0 end),0) t0amt,
                nvl(sum(case when ftype = 'AF' then prinnml+prinovd+intnmlacr+intnmlovd+intovdacr+intdue+feeintnmlacr+feeintnmlovd+feeintovdacr+feeintdue else 0 end),0) mramt
            from lnmast where trfacctno = l_AFACCTNO group by trfacctno) ln,AFTYPE AFT
    where cf.custid = af.custid and af.acctno = ci.afacctno
    AND af.status <> 'C'
    and af.acctno = adv.afacctno(+)
    and af.acctno = b.afacctno(+)
    and af.acctno = ln.trfacctno(+)
    and af.acctno = v.afacctno(+)
    and af.acctno = sec.afacctno(+)
    and af.acctno = l_AFACCTNO
    AND AF.ACTYPE =AFT.ACTYPE

    --AND (af.brid LIKE V_STRBRID or instr(V_STRBRID,af.brid) <> 0 )

    order by v.symbol;

ELSE
  -- GET REPORT'S DATA
    OPEN PV_REFCURSOR for
    select v.*
    from tbl_mr3007_log v , AFMAST AF, AFTYPE AFT
    where txdate = v_idate AND v.afacctno = l_AFACCTNO
    AND AF.ACCTNO =V.AFACCTNO
    AND AF.ACTYPE=AFT.ACTYPE
   
---    and v.trade + v.mortage + v.receiving + v.EXECQTTY + v.buyqtty > 0
---    AND af.acctno=v.afacctno
    --AND (af.brid LIKE V_STRBRID or instr(V_STRBRID,af.brid) <> 0 )

    order by v.symbol;

END IF ;


 EXCEPTION
   WHEN OTHERS
   THEN
        RETURN;
END;
 
 
 
 
/
