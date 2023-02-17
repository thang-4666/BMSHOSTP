SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW V_PAR_GETCIDAYTRANSACTION
(CUSTODYCD, ACCTNO, MNEMONIC, TXNUM, TXTYPE, 
 NAMT, TXDESC, TLTXCD, TLNAME)
BEQUEATH DEFINER
AS 
select cf.custodycd, af.acctno, aft.mnemonic,
txnum, txtype, namt, txdesc, tltxcd, tl.tlname
from vw_citran_gen tr, afmast af, cfmast cf, aftype aft, mrtype mrt, tlprofiles tl
where tr.txdate = getcurrdate and tr.deltd <> 'Y'
and field ='BALANCE' and af.acctno = tr.acctno 
and af.custid = cf.custid
and af.actype = aft.actype 
and aft.mrtype = mrt.actype 
--and mrt.mrtype <>'N'
and tr.tlid = tl.tlid(+)
/
