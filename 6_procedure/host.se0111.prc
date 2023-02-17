SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE se0111 (
   PV_REFCURSOR             IN OUT   PKG_REPORT.REF_CURSOR,
   OPT                      IN       VARCHAR2,
   PV_BRID                  IN       VARCHAR2,
   TLGOUPS                  IN       VARCHAR2,
   TLSCOPE                  IN       VARCHAR2,
   F_DATE                   IN       VARCHAR2,
   T_DATE                   IN       VARCHAR2,
   PV_SYMBOL                IN       VARCHAR2,
   PV_SHAREHOLDERSID        IN       VARCHAR2,
   PV_OLDSHAREHOLDERSID     IN       VARCHAR2,
   PV_TLID                  IN       VARCHAR2
   )
IS
    v_FRDATE date;
    v_TODATE date;
    v_SYMBOL VARCHAR2(20);
    v_SHAREHOLDERSID VARCHAR2(200);
    v_OLDSHAREHOLDERSID VARCHAR2(200);
BEGIN
    v_FRDATE := to_date(F_DATE, 'DD/MM/RRRR');
    v_TODATE := to_date(T_DATE, 'DD/MM/RRRR');



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

    If (PV_OLDSHAREHOLDERSID IS NULL OR UPPER(PV_OLDSHAREHOLDERSID) = 'ALL')
    then
        v_OLDSHAREHOLDERSID := '%';
    else
        v_OLDSHAREHOLDERSID := replace(PV_OLDSHAREHOLDERSID,' ', '_');
    end if;


OPEN PV_REFCURSOR
FOR

    select so.txdate, so.txnum, tl.busdate, sec.symbol, sec.codeid, so.oldSHAREHOLDERSID, so.SHAREHOLDERSID, cf1.fullname oldcustname, cf2.fullname custname,
        so.trade + so.blocked qtty, sec.parvalue, cf1.idcode oldidcode, cf2.idcode idcode, (so.trade + so.blocked)*sec.parvalue amount, so.series, so.oldseries
    from seotctranlog so, vw_tllog_all tl, sbsecurities sec, afmast af1, afmast af2, cfmast cf1, cfmast cf2
    where so.txdate = tl.txdate
        and so.txnum = tl.txnum
        and tl.CCYUSAGE = sec.codeid
        and SUBSTR2(so.oldseacctno,0,10) = af1.acctno
        and SUBSTR2(so.seacctno,0,10) = af2.acctno
        and af1.custid = cf1.custid
        and af2.custid = cf2.custid
        and sec.symbol like v_SYMBOL
        and so.SHAREHOLDERSID like v_SHAREHOLDERSID
        and so.OLDSHAREHOLDERSID like v_OLDSHAREHOLDERSID
        and tl.busdate BETWEEN v_FRDATE and v_TODATE
        and exists (select gu.grpid from tlgrpusers gu where (af1.careby = gu.grpid or af2.careby = gu.grpid) and gu.tlid = PV_TLID )
    order by so.autoid;



EXCEPTION
   WHEN OTHERS
   THEN
    plog.error ( 'SE0111.error: '||SQLERRM  || dbms_utility.format_error_backtrace);
      RETURN;
END;
 
/
