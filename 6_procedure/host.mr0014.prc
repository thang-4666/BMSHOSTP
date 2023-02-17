SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "MR0014" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   pv_OPT            IN       VARCHAR2,
   pv_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   I_DATE         IN       VARCHAR2
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

   v_IDATE           DATE; --ngay lam viec gan ngay idate nhat
   v_CurrDate        DATE;
   V_INBRID        VARCHAR2(4);
   V_STRBRID      VARCHAR2 (50);
   V_STROPTION VARCHAR2(10);


-- DECLARE PROGRAM VARIABLES AS SHOWN ABOVE
BEGIN



   V_STROPTION := upper(pv_OPT);
   V_INBRID := pv_BRID;
    if(V_STROPTION = 'A') then
        V_STRBRID := '%%';
    else
        if(V_STROPTION = 'B') then
            select br.mapid into V_STRBRID from brgrp br where  br.brid = V_INBRID;
        else
            V_STRBRID := V_INBRID;
        end if;
    end if;

 -- END OF GETTING REPORT'S PARAMETERS

   SELECT max(sbdate) INTO v_IDATE  FROM sbcurrdate WHERE sbtype ='B' AND sbdate <= to_date(I_DATE,'DD/MM/RRRR');

   select to_date(varvalue,'DD/MM/RRRR') into v_CurrDate from sysvar where varname = 'CURRDATE' and grname = 'SYSTEM';

IF v_idate = v_CurrDate THEN
-- GET REPORT'S DATA
    OPEN PV_REFCURSOR FOR
    SELECT to_char(v_IDATE,'DD/MM/YYYY') indate, CUSTODYCD, FULLNAME, MNEMONIC, BRID, SEREAL, MRAMT, MARGINRATE
    from
    (
    select cf.custodycd, cf.fullname, aft.mnemonic, cf.brid, sum(v.sereal) sereal, avg(nvl(ln.mramt,0)) mramt,
        /*avg(round((case when ci.balance + LEAST(nvl(af.MRCRLIMIT,0),nvl(sec.bamt,0))+ nvl(adv.avladvance,0) - ci.odamt -
        nvl(sec.bamt,0) - ci.ramt>=0 then 100000
        else least( nvl(sec.SEASS,0), af.mrcrlimitmax - ci.dfodamt)
        /abs(ci.balance +LEAST(nvl(af.MRCRLIMIT,0),nvl(sec.bamt,0))+ nvl(adv.avladvance,0) - ci.odamt -
        nvl(sec.bamt,0) - ci.ramt) end),4) * 100)  MARGINRATE*/
        sec. MARGINRATE
    from (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf, afmast af, cimast ci, aftype aft,
        --v_getsecmargininfo sec,
        buf_ci_account sec,
        --vw_getsecmargindetail v,
        (select afacctno,sum(basicprice * (trade + secured + securities_receiving_t0 + securities_receiving_t1 +
         securities_receiving_t2 + securities_receiving_t3 + securities_receiving_tn + buyingqtty
         - securities_sending_t3)) sereal
         from buf_se_account  group by afacctno) v,
        /*(select afacctno, sum(depoamt) AVLADVANCE
            from v_getaccountavladvance group by afacctno) adv,*/
        /*(select afacctno, nvl(sum(secureamt),0) SECUREDAMT
            from v_getbuyorderinfo group by afacctno) b,*/
        (select trfacctno,
                nvl(sum(case when ftype = 'DF' then prinnml+prinovd+intnmlacr+intnmlovd+intovdacr+intdue+feeintnmlacr+feeintnmlovd+feeintovdacr+feeintdue else 0 end),0) dfamt,
                nvl(sum(case when ftype = 'DF' then prinnml+prinovd else 0 end),0) dfodamt,
                nvl(sum(case when ftype = 'AF' then oprinnml+oprinovd+ointnmlacr+ointnmlovd+ointovdacr+ointdue else 0 end),0) t0amt,
                nvl(sum(case when ftype = 'AF' then prinnml+prinovd+intnmlacr+intnmlovd+intovdacr+intdue+feeintnmlacr+feeintnmlovd+feeintovdacr+feeintdue else 0 end),0) mramt
            from lnmast group by trfacctno) ln
    where cf.custid = af.custid and af.acctno = ci.afacctno
        and af.actype = aft.actype
        --and af.acctno = adv.afacctno(+)
        --and af.acctno = b.afacctno(+)
        and af.acctno = ln.trfacctno(+)
        and af.acctno = v.afacctno(+)
        and af.acctno = sec.afacctno(+) and aft.mnemonic = 'Margin'
    group by  cf.custodycd, cf.fullname, aft.mnemonic, cf.brid,sec. MARGINRATE
    having sum(nvl(ln.mramt,0)) <> 0
    order by MARGINRATE
    )
    where ROWNUM <= 10
    ;

ELSE
  -- GET REPORT'S DATA
    OPEN PV_REFCURSOR for
    select to_char(v_IDATE,'DD/MM/YYYY') indate, custodycd, fullname, mnemonic, brid, sereal, mramt, MARGINRATE
    from
    (
        select cf.custodycd, cf.fullname, aft.mnemonic, cf.brid, sum(v.sereal) sereal, sum(nvl(v.mramt,0)) mramt,
            avg(nvl(v.MARGINRATE,0)) MARGINRATE
        from tbl_mr3007_log v, afmast af, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf, aftype aft
        where txdate = v_idate
            and v.mramt <> 0 AND af.acctno = v.afacctno
            and v.custodycd = cf.custodycd and af.actype = aft.actype
        group by cf.custodycd, cf.fullname, aft.mnemonic, cf.brid
        having sum(nvl(v.mramt,0)) <> 0  and aft.mnemonic = 'Margin'
    )
    where rownum <= 10
    ;

END IF ;


 EXCEPTION
   WHEN OTHERS
   THEN
        RETURN;
END;

 
 
 
 
/
