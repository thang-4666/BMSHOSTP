SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_gen_report_log(p_RPTID varchar2)
  RETURN  BOOLEAN IS
--
-- To modify this template, edit file FUNC.TXT in TEMPLATE
-- directory of SQL Navigator
--
-- Purpose: Briefly explain the functionality of the function
--
-- MODIFICATION HISTORY
-- Person      Date    Comments
-- ---------   ------  -------------------------------------------
-- variable_name                 datatype;
   -- Declare program variables as shown above
BEGIN
    -- TXDATE: Log theo ngay CurrDate
    if p_RPTID = 'MR3012' or p_RPTID = 'MR3013' or p_RPTID = 'ALL' then
        delete report_rskmngt_log
        where txdate = (select to_date(varvalue,'DD/MM/RRRR') from sysvar where varname = 'CURRDATE' and grname = 'SYSTEM');

        insert into report_rskmngt_log
            (afacctno, mrirate, mrmrate,mrlrate, MARGINRATE, navaccount, outstanding, recustid, txdate)
        select af.acctno afacctno, af.mriratio mrirate, af.mrmratio mrmrate, af.mrlratio mrlrate, sec74.marginrate74 marginrate,
            nvl(sec74.sereal,0) navaccount,
            greatest(nvl(marginamt,0) - nvl(sec.avladvance,0) - balance,0) outstanding,
            recustid, to_date(varvalue,'DD/MM/RRRR') TXDATE

        from v_getsecmarginratio_74 sec74,v_getsecmarginratio sec, afmast af, cimast ci,
            (select trfacctno, sum(prinnml+prinovd+intnmlacr+intnmlovd+intdue+intovdacr+fee+feeovd+feedue+feeintnmlacr+feeintnmlovd+feeintdue+feeintovdacr) marginamt
                    from lnmast ln, lntype lnt
                    where ln.actype = lnt.actype
                    and ln.ftype = 'AF'
                    and lnt.chksysctrl = 'Y'
                    group by ln.trfacctno) ln,
            (select re.afacctno, cf.custid recustid
                    from reaflnk re, sysvar sys, cfmast cf
                    where to_date(varvalue,'DD/MM/RRRR') between re.frdate and re.todate
                    and substr(re.reacctno,0,10) = cf.custid
                    and varname = 'CURRDATE' and grname = 'SYSTEM'
                    and re.status <> 'C' and re.deltd <> 'Y') re,
            sysvar sydt
        where af.acctno = sec74.afacctno(+)
            and af.acctno = sec.afacctno(+)
            and af.acctno = ln.trfacctno(+)
            and af.acctno = ci.acctno and af.acctno = re.afacctno(+)
            and sydt.varname = 'CURRDATE' and sydt.grname = 'SYSTEM'
            and sec74.marginrate74 <= af.mrmratio
        order by af.acctno;
    end if;

    RETURN true;
EXCEPTION
   WHEN others THEN
       return false;
END;
 
 
 
 
 
 
 
 
 
 
 
/
