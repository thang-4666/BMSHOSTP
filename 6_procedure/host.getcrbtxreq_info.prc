SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "GETCRBTXREQ_INFO" (PV_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR, v_TABLE IN VARCHAR2)
  IS


BEGIN


OPEN PV_REFCURSOR FOR
/*SELECT mst.REQID,mst.TRFCODE,mst.REFCODE,TO_CHAR(mst.TXDATE,'DD/MM/RRRR') TXDATE,mst.OBJKEY, cf.custodycd, mst.AFACCTNO,
    mst.diraccname accname,mst.TXAMT, mst.DIRBANKCODE BANKCODE,mst.BANKACCT,  mst.dirbankname BANKNAME, mst.dirbankcity BANKCITY,
    fn_gettcdtdesbankacc(substr(mst.AFACCTNO,1,4)) DESACCTNO,  fn_gettcdtdesbankname(substr(mst.AFACCTNO,1,4)) DESACCTNAME, A1.CDCONTENT STATUS,
    mst.NOTES, MST.ERRORDESC
FROM CRBTXREQ MST,CIREMITTANCE rm, afmast af, cfmast cf, ALLCODE A1
WHERE MST.OBJTYPE = 'T' AND MST.VIA = 'DIR' and mst.afacctno = af.acctno and af.custid = cf.custid
and mst.txdate = rm.txdate (+) and rm.txnum(+) = mst.objkey and nvl(rm.rmstatus,'P') ='P' and mst.status  not in ('C','D')
AND MST.STATUS = A1.CDVAL AND A1.CDTYPE = 'RM' AND A1.CDNAME = 'CRBSTATUS'
order by mst.reqid;*/

SELECT mst.REQID,mst.TRFCODE,mst.REFCODE,TO_CHAR(mst.TXDATE,'DD/MM/RRRR') TXDATE,mst.OBJKEY, cf.custodycd, mst.AFACCTNO,
    mst.diraccname accname,mst.TXAMT, mst.DIRBANKCODE BANKCODE,mst.BANKACCT,  mst.dirbankname BANKNAME, mst.dirbankcity BANKCITY,
    fn_gettcdtdesbankacc(substr(mst.AFACCTNO,1,4)) DESACCTNO,  fn_gettcdtdesbankname(substr(mst.AFACCTNO,1,4)) DESACCTNAME, A1.CDCONTENT STATUS,
    mst.NOTES, MST.ERRORDESC
FROM CRBTXREQ MST,CIREMITTANCE rm, afmast af, cfmast cf, ALLCODE A1, vw_tllog_all tl
WHERE MST.OBJTYPE = 'T' AND MST.VIA = 'DIR' and mst.afacctno = af.acctno and af.custid = cf.custid
and mst.txdate = tl.txdate and mst.objkey = tl.txnum and tl.txstatus ='1'
and mst.txdate = rm.txdate (+) and rm.txnum(+) = mst.objkey
and nvl(rm.rmstatus,'P') ='P' and mst.status  not in ('C','D')
AND MST.STATUS = A1.CDVAL AND A1.CDTYPE = 'RM' AND A1.CDNAME = 'CRBSTATUS'
order by mst.reqid;


EXCEPTION
    WHEN others THEN
        return;
END;

 
 
 
 
/
