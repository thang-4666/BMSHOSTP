SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW VW_SETRAN_GEN_ALL
(AUTOID, CUSTODYCD, CUSTID, TXNUM, TXDATE, 
 ACCTNO, TXCD, NAMT, CAMT, REF, 
 DELTD, ACCTREF, TLTXCD, BUSDATE, TXDESC, 
 TXTIME, BRID, TLID, OFFID, CHID, 
 AFACCTNO, SYMBOL, SECTYPE, TRADEPLACE, TXTYPE, 
 FIELD, CODEID, TLLOG_AUTOID, TRDESC, TXSTATUS)
BEQUEATH DEFINER
AS 
select tr.autoid, cf.custodycd, cf.custid, tr.txnum, tr.txdate, tr.acctno, tr.txcd, tr.namt, tr.camt, tr.ref, tr.deltd, tr.acctref,
    tl.tltxcd, tl.busdate,
    case when tl.tlid ='6868' then trim(tl.txdesc) || ' (Online)' else tl.txdesc end txdesc,
    tl.txtime, tl.brid, tl.tlid, tl.offid, tl.chid,
    se.afacctno, sb.symbol, sb.sectype, sb.tradeplace, ap.txtype, ap.field, sb.codeid, tl.autoid tllog_autoid,
    case when tr.trdesc is not null
            then (case when tl.tlid ='6868' then trim(tr.trdesc) || ' (Online)' else tr.trdesc end)
            else tr.trdesc end trdesc,tl.txstatus
from setran tr, tllog tl, sbsecurities sb, semast se, cfmast cf, apptx ap
where tr.txdate = tl.txdate and tr.txnum = tl.txnum
    and tr.acctno = se.acctno
    and sb.codeid = se.codeid
    and se.custid = cf.custid
    and tr.txcd = ap.txcd and ap.apptype = 'SE' and ap.txtype in ('D','C')
    and tr.namt <> 0

union all
select "AUTOID","CUSTODYCD","CUSTID","TXNUM","TXDATE","ACCTNO","TXCD","NAMT","CAMT","REF","DELTD","ACCTREF","TLTXCD","BUSDATE","TXDESC","TXTIME","BRID","TLID","OFFID","CHID","AFACCTNO","SYMBOL","SECTYPE","TRADEPLACE","TXTYPE","FIELD","CODEID", "TLLOG_AUTOID", "TRDESC",
'1' "TXSTATUS"
from setran_gen
/
