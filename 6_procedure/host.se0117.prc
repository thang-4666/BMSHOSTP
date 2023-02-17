SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE se0117 (
   PV_REFCURSOR             IN OUT   PKG_REPORT.REF_CURSOR,
   OPT                      IN       VARCHAR2,
   PV_BRID                  IN       VARCHAR2,
   TLGOUPS                  IN       VARCHAR2,
   TLSCOPE                  IN       VARCHAR2,
   F_DATE                   IN       VARCHAR2,
   T_DATE                   IN       VARCHAR2,
   SYMBOL                   IN       VARCHAR2
           )
IS
    V_SYMBOL         varchar2 (20);
    V_FROMDATE       DATE;
    V_TODATE         DATE;
BEGIN
    V_FROMDATE := to_date(F_DATE, 'DD/MM/RRRR');
    V_TODATE   := to_date(T_DATE, 'DD/MM/RRRR');

    V_SYMBOL := replace(SYMBOL,' ', '_');

OPEN PV_REFCURSOR
FOR

select tr.txnum, tr.txdate, tr.custodycd, cf.fullname, mst.shareholdersid, tr.namt qtty, tr.txdesc, nvl(se.unitreq,'')unitreq,
       sb.symbol, iss.fullname issname, V_TODATE TODATE
from cfmast cf, semast mst, sbsecurities sb, issuers iss, vw_setran_gen tr
left join seblocked se on tr.afacctno = se.afacctno and tr.codeid = se.codeid and tr.txnum = se.txnum and tr.txdate = se.txdate
where cf.custid = mst.custid
      and mst.acctno = tr.acctno
      and tr.tltxcd in ('2202','2203') and tr.field in ('EMKQTTY','BLOCKED')
      and mst.codeid = sb.codeid
      and sb.tradeplace = '003'
      and sb.issuerid = iss.issuerid
      and sb.symbol = V_SYMBOL
      and tr.txdate BETWEEN V_FROMDATE and V_TODATE
order by cf.fullname,mst.shareholdersid,tr.txdate,tr.autoid;

EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;
 
/
