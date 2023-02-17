SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE se0110 (
   PV_REFCURSOR             IN OUT   PKG_REPORT.REF_CURSOR,
   OPT                      IN       VARCHAR2,
   PV_BRID                  IN       VARCHAR2,
   TLGOUPS                  IN       VARCHAR2,
   TLSCOPE                  IN       VARCHAR2,
   I_DATE                   IN       VARCHAR2,
   PV_SYMBOL                IN       VARCHAR2,
   PV_CUSTODYCD             IN       VARCHAR2,
   PV_SHAREHOLDERSID        IN       VARCHAR2 --,
   --PV_PURPOSE               IN       VARCHAR2
           )
IS
    v_DATE date;
    v_SYMBOL VARCHAR2(20);
    v_CUSTODYCD VARCHAR2(15);
    v_SHAREHOLDERSID VARCHAR2(15);
    v_PURPOSE varchar2(150);
BEGIN
    v_DATE := to_date(I_DATE, 'DD/MM/RRRR');
    v_PURPOSE := '';


    IF (PV_CUSTODYCD IS NULL OR UPPER(PV_CUSTODYCD) = 'ALL')
    THEN
        v_CUSTODYCD := '%';
    ELSE
        v_CUSTODYCD := PV_CUSTODYCD;
    END IF;

    If (PV_SYMBOL IS NULL OR UPPER(PV_SYMBOL) = 'ALL')
    then
        v_SYMBOL := '%';
    else
        v_SYMBOL := replace(PV_SYMBOL,' ', '_');
    end if;

    If (PV_SHAREHOLDERSID IS NULL OR UPPER(PV_SHAREHOLDERSID) = 'ALL')
    then
        v_SHAREHOLDERSID := '%';
    else
        v_SHAREHOLDERSID := replace(PV_SHAREHOLDERSID,' ', '_');
    end if;
/*trade
mortage
emkqtty
blocked
*/--tong CP = 4 cai nay cong lai
OPEN PV_REFCURSOR
FOR
/*select(se.tradeC + se.mortageC + se.emkqttyC + se.blockedC) - (se.tradeD + se.mortageD + se.emkqttyD + se.blockedD) tongCP,
log.shareholdersid,sbse.parvalue parvalue, seif.listingqtty listingqtty,
cft.cdcontent custtype, cf.fullname fullname, cf.address address,
cf.idcode idcode, cf.iddate iddate, cf.idplace idplace,cf.custodycd custodycd, iss.fullname, sbse.symbol, v_date ngaychot, iss.operatedate ngayphathanh
FROM
(
    select acctno,txnum,txdate,
           nvl(sum(case when field = 'TRADE' and txtype = 'C' then namt end),0) tradeC,
           nvl(sum(case when field = 'TRADE' and txtype = 'D' then namt end),0) tradeD,
           nvl(sum(case when field = 'MORTAGE' and txtype = 'C' then namt end),0) mortageC,
           nvl(sum(case when field = 'MORTAGE' and txtype = 'D' then namt end),0) mortageD,
           nvl(sum(case when field = 'EMKQTTY' and txtype = 'C' then namt end),0) emkqttyC,
           nvl(sum(case when field = 'EMKQTTY' and txtype = 'D' then namt end),0) emkqttyD,
           nvl(sum(case when field = 'BLOCKED' and txtype = 'C' then namt end),0) blockedC,
           nvl(sum(case when field = 'BLOCKED' and txtype = 'D' then namt end),0) blockedD
    from vw_setran_gen_all
    where txdate <= v_DATE
    group by acctno,txnum,txdate
)se,seotctranlog log, sbsecurities sbse,securities_info seif,afmast af,cfmast cf,issuers iss,
(select cdval,cdcontent from allcode where cdname like 'CUSTTYPE') cft
where se.txdate = log.txdate
and se.txnum = log.txnum
and log.SEACCTNO is not null
and sbse.codeid = SUBSTR(se.acctno,11)
and sbse.codeid = seif.codeid
and af.acctno = SUBSTR(se.acctno,1,10)
and af.custid = cf.custid
and cf.custtype = cft.cdval
and sbse.issuerid = iss.issuerid
and sbse.symbol like v_SYMBOL
and cf.custodycd like v_CUSTODYCD
and log.txdate <= v_DATE
and ((se.tradeC + se.mortageC + se.emkqttyC + se.blockedC) - (se.tradeD + se.mortageD + se.emkqttyD + se.blockedD)) > 0
order by se.txdate;*/
/*select se.tongCP,
se.shareholdersid,sbse.parvalue parvalue, seif.listingqtty listingqtty,
cft.cdcontent custtype, cf.fullname fullname, cf.address address,
cf.idcode idcode, cf.iddate iddate, cf.idplace idplace,cf.custodycd custodycd, iss.fullname, sbse.symbol, --v_date ngaychot,
iss.operatedate ngayphathanh
FROM
(
    select se2.acctno,log.shareholdersid, sum(se2.tongCP) tongCP
    from
    (
        select acctno,txnum,txdate,
               (nvl(sum(case when field = 'TRADE' and txtype = 'C' then namt end),0)  +
               nvl(sum(case when field = 'MORTAGE' and txtype = 'C' then namt end),0)  +
               nvl(sum(case when field = 'EMKQTTY' and txtype = 'C' then namt end),0)  +
               nvl(sum(case when field = 'BLOCKED' and txtype = 'C' then namt end),0) ) -
               (nvl(sum(case when field = 'MORTAGE' and txtype = 'D' then namt end),0)  +
               nvl(sum(case when field = 'EMKQTTY' and txtype = 'D' then namt end),0)  +
               nvl(sum(case when field = 'TRADE' and txtype = 'D' then namt end),0)  +
               nvl(sum(case when field = 'BLOCKED' and txtype = 'D' then namt end),0) ) tongCP
        from vw_setran_gen_all
        where txdate <= v_DATE
        group by acctno,txnum,txdate
    )se2,seotctranlog log
    where se2.txdate = log.txdate
    and se2.txnum = log.txnum
    group by se2.acctno,log.shareholdersid
)se, sbsecurities sbse,securities_info seif,afmast af,cfmast cf,issuers iss,
(select cdval,cdcontent from allcode where cdname like 'CUSTTYPE') cft
where sbse.codeid = SUBSTR(se.acctno,11)
and sbse.codeid = seif.codeid
and af.acctno = SUBSTR(se.acctno,1,10)
and af.custid = cf.custid
and cf.custtype = cft.cdval
and sbse.issuerid = iss.issuerid
and sbse.symbol like v_SYMBOL
and cf.custodycd like v_CUSTODYCD
and se.tongCP > 0
;*/
select (se.trade + se.mortage + se.emkqtty + se.blocked - nvl(scr.qtty,0) + nvl(sdr.qtty,0)) tongCP, se.shareholdersid, sb.parvalue,
    seif.listingqtty listingqtty, cft.cdcontent custtype, cf.fullname fullname, cf.address address,
    cf.idcode idcode, cf.iddate iddate, cf.idplace idplace,cf.country custodycd, iss.fullname, sb.symbol, v_date ngaychot, sb.issuedate ngayphathanh,
    v_PURPOSE PURPOSE
from semast se, sbsecurities sb, afmast af, (SELECT * FROM CFMAST  WHERE custatcom ='Y' AND  FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf, issuers iss, securities_info seif,
    (select cdval,cdcontent from allcode where cdname = 'CUSTTYPE' and cdtype = 'CF') cft,
    (   --Tong phat sinh tang sau ngay tao bao cao
        select so.seacctno, so.shareholdersid, sum(so.amount) qtty
        from seotctranlog so
        where so.txdate > v_DATE
        group by so.seacctno, so.shareholdersid
    )scr,
    (   --Tong phat sinh giam sau ngay tao bao cao
        select so.oldseacctno seacctno, so.oldshareholdersid shareholdersid, sum(so.amount) qtty
        from seotctranlog so
        where so.txdate > v_DATE
        group by so.oldseacctno, so.oldshareholdersid
    )sdr
where se.shareholdersid is not null
    and se.afacctno = af.acctno
    and af.custid = cf.custid
    and se.codeid = sb.codeid
    and sb.issuerid = iss.issuerid
    and cf.custtype = cft.cdval
    and sb.codeid = seif.codeid
    and se.acctno = scr.seacctno(+)
    and se.shareholdersid = scr.shareholdersid(+)
    and se.acctno = sdr.seacctno(+)
    and se.shareholdersid = sdr.shareholdersid(+)
    and sb.symbol like v_SYMBOL
    and cf.custodycd like v_CUSTODYCD
    and se.shareholdersid like v_SHAREHOLDERSID
    and (se.trade + se.mortage + se.emkqtty + se.blocked - nvl(scr.qtty,0) + nvl(sdr.qtty,0)) > 0
order by cf.custodycd, se.shareholdersid
;
EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;
 
/
