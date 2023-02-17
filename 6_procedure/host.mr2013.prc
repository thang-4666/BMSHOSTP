SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "MR2013" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   p_OPT            IN       VARCHAR2,
   pv_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE           in       VARCHAR2,
   T_DATE           in       VARCHAR2,
   p_RESTYPE        in       VARCHAR2,
   p_CUSTODYCD      IN       VARCHAR2,
   p_AFACCTNO    IN       VARCHAR2,
   PV_AFTYPE      IN       VARCHAR2
    )
IS
--

-- PURPOSE: BRIEFLY EXPLAIN THE FUNCTIONALITY OF THE PROCEDURE
--
-- MODIFICATION HISTORY
-- PERSON      DATE    COMMENTS
-- NAMNT   12-APR-2012  CREATE
-- ---------   ------  -------------------------------------------

    l_OPT varchar2(10);
    l_BRID varchar2(1000);
    l_BRID_FILTER varchar2(1000);
    l_CUSTODYCD varchar2(10);
    l_AFACCTNO varchar2(10);
    v_strAFTYPE      VARCHAR2(20);
    l_ISVSD varchar2(10);
    V_STRTLID           VARCHAR2(6);
    l_companyshortname varchar2(10);

    V_CURRDATE          date;
    V_CAREBY    varchar2(10);
    v_GROUPID   varchar2(10);

BEGIN

-- Prepare Parameters

    l_OPT:=p_OPT;

    IF (l_OPT = 'A') THEN
      l_BRID_FILTER := '%';
    ELSE if (l_OPT = 'B') then
            select brgrp.mapid into l_BRID_FILTER from brgrp where brgrp.brid = pv_BRID;
        else
            l_BRID_FILTER := pv_BRID;
        end if;
    END IF;

    if p_CUSTODYCD = 'A' or p_CUSTODYCD = 'ALL' then
        l_CUSTODYCD:= '%%';
    else
        l_CUSTODYCD:= p_CUSTODYCD;
    end if;

    if p_AFACCTNO = 'A' or p_AFACCTNO = 'ALL' then
        l_AFACCTNO:= '%%';
    else
        l_AFACCTNO:= p_AFACCTNO;
    end if;

    if PV_AFTYPE = 'ALL' then
        v_strAFTYPE := '%%';
    elsIF TRIM(PV_AFTYPE) = '001' then
        v_strAFTYPE := 'Margin';
    elsIF TRIM(PV_AFTYPE) = '002' then
        v_strAFTYPE := 'T3';
    ELSE
        v_strAFTYPE := 'Thường';
    end if ;



    l_companyshortname:=cspks_system.fn_get_sysvar('SYSTEM','COMPANYSHORTNAME');

    select to_date(varvalue,'DD/MM/RRRR') into V_CURRDATE
    from sysvar where varname = 'CURRDATE' and grname = 'SYSTEM';---V_CURRDATE



delete from tbl_gl_mr2013_temp;
BEGIN
FOR REC IN (select DISTINCT  txdate  FROM TLLOGALL WHERE TXDATE >=to_date(F_DATE,'dd/mm/yyyy') and txdate <= to_date(T_DATE,'dd/mm/yyyy') )
LOOP
DELETE FROM tbl_gl_mr2013_temp WHERE i_date =REC.txdate;

INSERT INTO  tbl_gl_mr2013_temp
SELECT  REC.TXDATE i_date , rlstype, custodycd, afacctno, rlsdate, overduedate, lnschdid, rlsprin, paid, lnprin, intamt, feeintamt ,fullname, mnemonic,brid,lname,typename
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
            cf.fullname, ln.acctno lnacctno, aft.mnemonic,substr(af.acctno,1,4) brid,re.lname,re.typename
        from vw_lnmast_all ln, vw_lnschd_all ls, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf, afmast af,aftype aft, cfmast cfb,
            (select autoid, sum(nml) nml, sum(ovd) ovd, sum(paid) paid,
                sum(intnmlacr) intnmlacr, sum(intdue) intdue, sum(intovd) intovd, sum(intovdprin) intovdprin,
                sum(feeintnmlacr) feeintnmlacr, sum(feeintdue) feeintdue, sum(feeintovd) feeintnmlovd, sum(feeintovdprin) feeintovdacr,sum(feeovd) feeovd
            from (select * from lnschdlog union all select * from lnschdloghist) lg
            where lg.txdate > REC.TXDATE
            group by autoid) lg,
            (
            SELECT   re.afacctno , MAX(cfl.FULLNAME)LNAME,max(retype.typename) typename
                FROM reaflnk re, regrplnk REGl,retype,regrp,cfmast cfl
                WHERE re.reacctno = REGl.reacctno(+)
                AND  SUBSTR(RE.reacctno,11)=RETYPE.actype
                AND retype.rerole ='RM'
                AND REGl.refrecflnkid = regrp.autoid(+)
                and regrp.custid = cfl.custid
                AND REC.TXDATE BETWEEN re.frdate AND  nvl(re.clstxdate-1, re.todate)
                AND REC.TXDATE BETWEEN REGl.frdate AND  nvl(REGl.clstxdate-1, REGl.todate)
                GROUP BY re.afacctno
                ) re,

            (select lnacctno, df.actype dftype, dft.isvsd  from dfgroup df, dftype dft where df.actype=dft.actype) df
        where ln.acctno = ls.acctno and instr(ls.reftype,'P') <> 0
            and ln.trfacctno = af.acctno and af.custid = cf.custid
            and ln.custbank = cfb.custid(+)
            and ls.autoid = lg.autoid(+)
            and ln.acctno = df.lnacctno(+)
            and ln.trfacctno = re.afacctno(+)
            and af.actype = aft.actype
            and case when p_RESTYPE = 'ALL' then 1
                    when ln.rrtype = 'C' and p_RESTYPE = l_companyshortname then 1
                    when ln.rrtype = 'B' and p_RESTYPE = nvl(cfb.shortname,l_companyshortname) then 1

                    else 0 end <> 0
           -- AND upper(AFT.MNEMONIC) LIKE 'T3'
            and ls.rlsdate <= rec.txdate
    ) A
    WHERE a.lnprin >0
    order by custodycd, afacctno, lnacctno, rlsdate, lnschdid;
END LOOP;
END ;

   OPEN PV_REFCURSOR
    FOR
   select * from   tbl_gl_mr2013_temp  where custodycd like l_CUSTODYCD
  /* AND(   TO_CHAR(SYSDATE,'24HH')>=15 OR TO_CHAR(SYSDATE,'HH')<=8)*/
   AND  TO_DATE(T_DATE,'DD/MM/YYYY')-TO_DATE(F_DATE,'DD/MM/YYYY') <35
    ORDER BY i_date,custodycd;

   -- delete from tbl_gl_mr2013_temp;
    commit;
EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;-- PROCEDURE

 
 
 
 
/
