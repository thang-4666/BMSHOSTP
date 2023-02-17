SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE df0002 (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   PV_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   I_DATE         IN       VARCHAR2,
   PV_CUSTODYCD   IN       VARCHAR2,
   SYMBOL         IN       VARCHAR2,
   BORKERID       IN       VARCHAR2
   )
IS
--

-- PURPOSE: BRIEFLY EXPLAIN THE FUNCTIONALITY OF THE PROCEDURE
--
-- MODIFICATION HISTORY
-- PERSON      DATE    COMMENTS
-- THANHNM   12-APR-2012  CREATE
-- ---------   ------  -------------------------------------------

   V_STROPTION      VARCHAR2 (5);            -- A: ALL; B: BRANCH; S: SUB-BRANCH
   V_STRBRID        VARCHAR2 (4);            -- USED WHEN V_NUMOPTION > 0

   V_STRCUSTODYCD   VARCHAR2 (20);
   V_STRSYMBOL      VARCHAR2 (20);
   V_STRBORKERID    VARCHAR2 (10);
   V_IDATE          DATE;

    BEGIN
    V_STROPTION := OPT;

   IF V_STROPTION = 'A' THEN     -- TOAN HE THONG
      V_STRBRID := '%';
   ELSIF V_STROPTION = 'B' THEN
      V_STRBRID := SUBSTR(PV_BRID,1,2) || '__' ;
   ELSE
      V_STRBRID := PV_BRID;
   END IF;

   V_IDATE := to_date (I_DATE,'DD/MM/RRRR');
   V_STRCUSTODYCD := PV_CUSTODYCD;


   if(upper(SYMBOL) = 'ALL' or SYMBOL is null) then
        V_STRSYMBOL := '%';
   else
        V_STRSYMBOL := SYMBOL;
   end if;

   if(upper(BORKERID) = 'ALL' or BORKERID is null) then
        V_STRBORKERID := '%';
   else
        V_STRBORKERID := BORKERID;
   end if;

    OPEN PV_REFCURSOR
    FOR
    select I_DATE indate, 1 orderid, goc.custodycd, goc.fullname, goc.opndate, goc.expdate, null symbol, null qttytype, 0 qtty_i, 0 dfrate, 0 basicprice,
        sum(goc.orgamt+goc.ovd - goc.prinpaid + nvl(prinpaid_mov.amt_prinpaid,0) - nvl(prinpaid_mov.amt_prinovd,0)) no_goc,
        goc.rate, goc.brid, goc.grpname
    from
    ---------tong goc vay, goc da tra, no goc qua han, no phi hien tai, no lai hien tai, tong tien tren loan ht
    (
        select a.groupid, a.afacctno,  a.expdate, a.opndate,
            a.fullname, a.custodycd, a.rate, a.grpname, a.brid,
            sum(a.prinpaid) prinpaid, sum(a.orgamt) orgamt, sum(ovd) ovd
        from
            (
                select dg.groupid, dg.afacctno, ln.expdate, ln.opndate,
                    cf.fullname, cf.custodycd, dg.mrate rate, gl.grpname, af.brid,
                    sum(orgamt) orgamt,sum(ln.prinpaid) prinpaid, sum(prinovd) ovd
                from (SELECT * FROM dfgroup UNION ALL SELECT * FROM dfgrouphist) dg, vw_lnmast_all ln,
                    (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, PV_BRID, TLGOUPS)=0)  cf, afmast af, tlgroups gl
                where dg.lnacctno = ln.acctno and cf.custid = af.custid
                    and dg.afacctno = af.acctno
                    and af.careby = gl.grpid (+)
                    and af.careby like V_STRBORKERID
                    and ln.opndate <= V_IDATE
                    and cf.custodycd like V_STRCUSTODYCD
                group by dg.groupid, dg.afacctno, ln.expdate, ln.opndate, cf.fullname, cf.custodycd, dg.mrate, gl.grpname, af.brid
            ) a, v_getgrpdealformular b
        where a.afacctno = b.afacctno(+) and a.groupid = b.groupid(+)
        group by a.groupid, a.afacctno, a.expdate, a.opndate, a.fullname, a.custodycd, a.rate, a.grpname, a.brid
    ) goc
    -- tong goc vay phat sinh tu today
    left join
    (
        select dg.groupid, dg.afacctno,
            sum(case when ap.field = 'PRINPAID' then (case when ap.txtype = 'D' then -tran.namt else tran.namt end) else 0 end) amt_prinpaid,
            sum(case when ap.field = 'PRINOVD' then (case when ap.txtype = 'D' then -tran.namt else tran.namt end) else 0 end) amt_prinovd
        from vw_lntran_all tran, (SELECT * FROM dfgroup UNION ALL SELECT * FROM dfgrouphist) dg, apptx ap
        where ap.txcd = tran.txcd and tran.acctno = dg.lnacctno and tran.deltd <> 'Y'
            and ap.apptype = 'LN' and ap.txtype in ('D','C') and ap.field in ('PRINPAID','PRINOVD')
            and dg.txdate <=  V_IDATE
            and tran.txdate > V_IDATE
        group by dg.groupid, dg.afacctno
    ) prinpaid_mov
     on prinpaid_mov.groupid = goc.groupid and prinpaid_mov.afacctno = goc.afacctno
    group by goc.custodycd, goc.fullname, goc.opndate, goc.expdate, goc.rate, goc.brid, goc.grpname
    having sum(goc.orgamt+goc.ovd - goc.prinpaid + nvl(prinpaid_mov.amt_prinpaid,0) - nvl(prinpaid_mov.amt_prinovd,0)) <> 0

    UNION ALL

    select I_DATE indate, 2 orderid, cf.custodycd, cf.fullname, null opndate, null expdate,
        sec.symbol symbol, df.qttytype, (DF.df_qtty - nvl(TR.namt,0)) qtty_i, df.dfrate, nvl(sec.basicprice,0) basicprice,
        0 no_goc,0 rate,null brid,null grpname
    from
    (
        select qt.qttytype, df.acctno, df.afacctno, df.dfrate, df.codeid,
            DECODE(qt.qttytype, 'DFQTTY', DF.dfqtty, 'RCVQTTY',DF.rcvqtty, 'CACASHQTTY',DF.cacashqtty, 'CARCVQTTY',DF.carcvqtty, DF.blockqtty ) df_qtty
        from
        (Select * from dfmast union all select * from dfmasthist) df,
        (
            select 'DFQTTY' qttytype from dual
            union all
            select 'RCVQTTY' qttytype from dual
            union all
            select 'CACASHQTTY' qttytype from dual
            union all
            select 'CARCVQTTY' qttytype from dual
            union all
            select 'BLOCKQTTY' qttytype from dual
        ) qt
    ) df
    left join
    (
        select tran.acctno, ap.field,
            sum(case when ap.txtype = 'D' then -tran.namt else tran.namt end) namt
        from vw_dftran_all tran, apptx ap, vw_tllog_all tl
        where ap.apptype = 'DF' and ap.txtype in ('D','C') and ap.txcd = tran.txcd and tran.deltd <> 'Y'
            and ap.field in ('DFQTTY','RCVQTTY','CACASHQTTY','CARCVQTTY','BLOCKQTTY')
            and tran.txnum = tl.txnum and tran.txdate = tl.txdate
            and tran.txdate > V_IDATE
        group by tran.acctno, ap.field
    ) tr
    on df.acctno = tr.acctno and df.qttytype = tr.field
    inner join securities_info sec
    on df.codeid = sec.codeid and sec.symbol like V_STRSYMBOL
    inner join
    (
        select cf.custodycd, cf.fullname, af.acctno
        from cfmast cf, afmast af
        where cf.custid = af.custid
    ) cf
    on df.afacctno = cf.acctno
    where (DF.df_qtty - nvl(TR.namt,0)) <> 0
    ;
EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;                                                              -- PROCEDURE
 
/
