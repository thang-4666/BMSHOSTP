SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE getbrokerorder
(
    PV_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR,
    TLID IN VARCHAR2,
    PV_DATE IN VARCHAR2
)
IS
  v_TLID VARCHAR2(20);
  V_TXDATE DATE;
  V_CURRDATE DATE;

BEGIN

v_TLID := TLID;
V_TXDATE := to_date(PV_DATE,'dd/mm/rrrr');
select max(to_date(varvalue,'dd/mm/rrrr')) into V_CURRDATE
from sysvar where grname = 'SYSTEM' and varname = 'CURRDATE';

OPEN PV_REFCURSOR FOR
select od.txdate, od.txtime, cf.custodycd, af.acctno|| '-' ||AFT.mnemonic afacctno, CF.FULLNAME,
    al.cdcontent extype, sb.symbol, od.orderqtty, od.quoteprice,
    tlp.tlname, tlg.grpname carebyname, rm.rmname
from
    (
        select * from vw_odmast_all
        where exectype in ('NB','NS') and reforderid is null
            and txdate = V_TXDATE
        union all
        select * from vw_odmast_all
        where exectype in ('AB','AS','CB','CS')
            and txdate = V_TXDATE
    )od, sbsecurities sb, cfmast cf, afmast af, allcode al,
    vw_tllog_all tl,
    (
        select DISTINCT afacctno, reu.tlid
        from reaflnk re, reuserlnk reu
        where re.frdate <= V_CURRDATE and re.todate >= V_CURRDATE
            and re.deltd <> 'Y' and re.status = 'A'
            AND RE.refrecflnkid = reu.refrecflnkid
            AND reu.tlid = v_TLID
    ) RE, tlprofiles tlp, tlgroups tlg,
    (
        select re.afacctno, max(case when retype.rerole ='RM' then  cf.fullname end) rmname
        from reaflnk re,retype, cfmast cf
        where SUBSTR(REACCTNO,11) = retype.actype
            and retype.rerole = 'RM' AND RE.STATUS ='A'
            and cf.custid = SUBSTR(REACCTNO,1,10)
        group by re.afacctno
    ) RM, AFTYPE AFT
where od.codeid = sb.codeid and od.afacctno = af.acctno
    and af.custid = cf.custid and al.cdname = 'EXECTYPE'
    and al.cdtype = 'OD' and od.exectype = al.cdval
    and od.txnum = tl.txnum and od.txdate = tl.txdate
    and tl.tlid = tlp.tlid(+) and cf.careby = tlg.grpid(+)
    and af.custid = re.afacctno and af.custid = rm.afacctno(+) AND AF.ACTYPE = AFT.ACTYPE
ORDER BY OD.TXTIME
    ;


EXCEPTION
    WHEN others THEN
        return;
END;

 
 
 
 
/
