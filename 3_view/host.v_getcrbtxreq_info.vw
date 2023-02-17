SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW V_GETCRBTXREQ_INFO
(REQID, TRFCODE, REFCODE, TXDATE, OBJKEY, 
 CUSTODYCD, AFACCTNO, ACCNAME, TXAMT, BANKCODE, 
 BANKACCT, BANKNAME, BANKCITY, DESACCTNO, DESACCTNAME, 
 STATUS, NOTES, ERRORDESC, ORGSTATUS)
BEQUEATH DEFINER
AS 
SELECT mst.REQID,mst.TRFCODE,mst.REFCODE,TO_CHAR(mst.TXDATE,'DD/MM/RRRR') TXDATE,mst.OBJKEY, cf.custodycd, mst.AFACCTNO,
    mst.diraccname accname,mst.TXAMT, mst.DIRBANKCODE BANKCODE,mst.BANKACCT,  mst.dirbankname BANKNAME, mst.dirbankcity BANKCITY,
    fn_gettcdtdesbankacc(substr(mst.AFACCTNO,1,4)) DESACCTNO,  fn_gettcdtdesbankname(substr(mst.AFACCTNO,1,4)) DESACCTNAME, A1.CDCONTENT STATUS,
    mst.NOTES, MST.ERRORDESC,MST.STATUS ORGSTATUS
FROM CRBTXREQ MST,CIREMITTANCE rm, afmast af, cfmast cf, ALLCODE A1, vw_tllog_all tl
WHERE MST.OBJTYPE = 'T' AND MST.VIA = 'DIR' and mst.afacctno = af.acctno and af.custid = cf.custid
and mst.txdate = tl.txdate and mst.objkey = tl.txnum and tl.txstatus ='1'
and mst.txdate = rm.txdate (+) and rm.txnum(+) = mst.objkey
and nvl(rm.rmstatus,'P') ='P' and mst.status  not in ('C','D')
AND MST.STATUS = A1.CDVAL AND A1.CDTYPE = 'RM' AND A1.CDNAME = 'CRBSTATUS'
order by mst.reqid
/
