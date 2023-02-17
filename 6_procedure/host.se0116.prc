SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE se0116 (
   PV_REFCURSOR             IN OUT   PKG_REPORT.REF_CURSOR,
   OPT                      IN       VARCHAR2,
   PV_BRID                  IN       VARCHAR2,
   TLGOUPS                  IN       VARCHAR2,
   TLSCOPE                  IN       VARCHAR2,
   T_DATE                   IN       VARCHAR2,
   PV_TLID                  IN       VARCHAR2
           )
IS
BEGIN

OPEN PV_REFCURSOR
FOR

    select so.txdate, so.txnum, tl.busdate, sec.symbol, sec.codeid, so.oldSHAREHOLDERSID, so.SHAREHOLDERSID, cf1.fullname oldcustname, cf2.fullname custname,
        so2.qtty qtty, sec.parvalue, cf1.idcode oldidcode, cf2.idcode idcode, so2.qtty*sec.parvalue amount,
        T_DATE monthdate, so.series series, so.oldseries oldseries
    from seotctranlog so, vw_tllog_all tl, sbsecurities sec, afmast af1, afmast af2, cfmast cf1, cfmast cf2,
        (
        select oldshareholdersid, shareholdersid, sum(trade) + sum(blocked) qtty
        from seotctranlog
        where oldshareholdersid is not null and shareholdersid is not null
        group by oldshareholdersid, shareholdersid
        )so2
    where so.txdate = tl.txdate
        and so.txnum = tl.txnum
        and tl.CCYUSAGE = sec.codeid
        and SUBSTR2(so.oldseacctno,0,10) = af1.acctno
        and SUBSTR2(so.seacctno,0,10) = af2.acctno
        and af1.custid = cf1.custid
        and af2.custid = cf2.custid
        and so.oldshareholdersid = so2.oldshareholdersid
        and so.shareholdersid = so2.shareholdersid
        and SUBSTR(to_char(tl.busdate,'DD/MM/RRRR'),4,2) = SUBSTR(T_DATE,1,2)
        and SUBSTR(to_char(tl.busdate,'DD/MM/RRRR'),8,4) = SUBSTR(T_DATE,4,4)
        and exists (select gu.grpid from tlgrpusers gu where (af1.careby = gu.grpid or af2.careby = gu.grpid) and gu.tlid = PV_TLID )
    order by so.autoid;



EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;
 
 
 
/
