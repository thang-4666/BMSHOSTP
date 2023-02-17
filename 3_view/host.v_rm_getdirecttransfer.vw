SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW V_RM_GETDIRECTTRANSFER
(REQID, TRFCODE, REFCODE, OBJKEY, TXDATE, 
 BANKCODE, DIRBANKCODE, BANKACCT, ACCNAME, AFACCTNO, 
 TXAMT, NOTES, CUSTODYCD, BANKNAME, BANKCITY, 
 DESACCTNO, DESACCTNAME, VCBSEQ)
BEQUEATH DEFINER
AS 
SELECT mst.REQID,mst.TRFCODE,mst.REFCODE,mst.OBJKEY,TO_CHAR(mst.TXDATE,'DD/MM/RRRR') TXDATE,mst.BANKCODE, mst.DIRBANKCODE DIRBANKCODE,
mst.BANKACCT,mst.diraccname accname,mst.AFACCTNO,mst.TXAMT,substr(fn_convert_to_vn(mst.NOTES),1,128) NOTES,
cf.custodycd, mst.dirbankname BANKNAME, mst.dirbankcity BANKCITY,
fn_gettcdtdesbankacc(substr(mst.AFACCTNO,1,4)) DESACCTNO,
fn_gettcdtdesbankname(substr(mst.AFACCTNO,1,4)) DESACCTNAME,
vcb.vcbseq
FROM CRBTXREQ MST, afmast af, cfmast cf, vw_tllog_all tl, vcbseqmap vcb
WHERE MST.OBJTYPE = 'T' AND MST.VIA = 'DIR' AND mst.STATUS ='P' --and mst.reqid =101
and mst.txdate = tl.txdate and mst.objkey = tl.txnum and tl.txstatus ='1'
and mst.afacctno = af.acctno and af.custid = cf.custid
And vcb.reqid = mst.reqid And vcb.txdate = mst.txdate
And mst.txdate = getcurrdate
order by mst.reqid
/
