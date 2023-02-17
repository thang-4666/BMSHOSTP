SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW VW_CITRAN_GEN_DELT
(AUTOID, CUSTODYCD, CUSTID, TXNUM, TXDATE, 
 ACCTNO, TXCD, NAMT, CAMT, REF, 
 DELTD, ACCTREF, TLTXCD, BUSDATE, TXDESC, 
 TXTIME, BRID, TLID, OFFID, CHID, 
 DFACCTNO, OLD_DFACCTNO, TXTYPE, FIELD, TLLOG_AUTOID, 
 TRDESC, COREBANK)
BEQUEATH DEFINER
AS 
select ci.autoid, cf.custodycd, cf.custid,
    ci.txnum, ci.txdate, ci.acctno, ci.txcd, ci.namt,
    ci.camt, ci.ref, nvl(ci.deltd,'N') deltd, ci.acctref,
    tl.tltxcd, tl.busdate,
    case when tl.tlid ='6868' then trim(tl.txdesc) || ' (Online)' else tl.txdesc end txdesc,
    tl.txtime, tl.brid, tl.tlid, tl.offid, tl.chid,
    ''  dfacctno,
    ''  old_dfacctno,
    app.txtype, app.field, tl.autoid tllog_autoid,
    case when ci.trdesc is not null
            then (case when tl.tlid ='6868' then trim(ci.trdesc) || ' (Online)' else ci.trdesc end)
            else ci.trdesc end trdesc, ci.corebank
from citran ci, tllog tl, cfmast cf, afmast af, apptx app
where ci.txdate = tl.txdate and ci.txnum = tl.txnum
    and cf.custid = af.custid
    and ci.acctno = af.acctno
    and ci.txcd = app.txcd and app.apptype = 'CI' and app.txtype in ('D','C')
    and ci.namt <> 0

union all
select "AUTOID","CUSTODYCD","CUSTID","TXNUM","TXDATE","ACCTNO","TXCD","NAMT","CAMT","REF","DELTD","ACCTREF","TLTXCD","BUSDATE","TXDESC","TXTIME","BRID","TLID","OFFID","CHID","DFACCTNO","OLD_DFACCTNO","TXTYPE","FIELD", "TLLOG_AUTOID", "TRDESC", "COREBANK"
from citran_gen
/
