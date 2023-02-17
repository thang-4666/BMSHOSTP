SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW V_GETCREATEDEAL
(TXDATE, CLEARDATE, AUTOID, CUSTODYCD, AFACCTNO, 
 CODEID, QTTY, DTYPE, SYMBOL, TYPENAME, 
 FULLNAME, PRICE, STATUS, BALDEFOVD, CAMASTID)
BEQUEATH DEFINER
AS 
(
select mst.txdate, mst.cleardate, mst.autoid, cf.custodycd, mst.afacctno, mst.codeid, mst.qtty, mst.DTYPE,
sb.symbol, cd.cdcontent TYPENAME, cf.FULLNAME, mst.PRICE, mst.status, mst.BALDEFOVD, mst.camastid
from (
select txdate, cleardate, autoid, afacctno, codeid, (qtty - aqtty) qtty,'R' DTYPE, matchprice price, 'Z' status,
       0 BALDEFOVD, TO_CHAR(cleardate) camastid
from vw_stschd_dealgroup
where duetype ='RS' and qtty - aqtty >0
union
select rf.reportdate txdate, rf.actiondate cleardate, to_char(mst.autoid) autoid, mst.afacctno, decode( RF.ISWFT,'Y',SB.codeid,MST.codeid) CODEID,
    mst.qtty - mst.dfqtty qtty,'P' DTYPE,rf.exprice price,  'X' status,0 BALDEFOVD, MST.camastid
from caschd mst, camast rf ,sbsecurities sb where mst.codeid = sb.refcodeid (+) AND mst.camastid=rf.camastid and
    mst.qtty - mst.dfqtty >0 and mst.status in ('M','S') and isse = 'N' and mst.deltd <>'Y'
union
select cam.reportdate txdate, cam.actiondate cleardate, to_char(cas.autoid) autoid, cas.afacctno, cam.codeid,
    cas.amt-cas.dfamt  qtty, 'T' DTYPE, cam.exprice price,  'X' status,0 BALDEFOVD, cas.camastid
from camast cam, caschd cas,sbsecurities sb where cam.camastid=cas.camastid and cam.codeid=sb.refcodeid (+) and cas.amt>0
    and cas.status in ('S') and cas.deltd<>'Y' AND CAS.ISCI <> 'Y'
/*
union
select rf.reportdate txdate, rf.duedate cleardate, to_char(mst.autoid) autoid, mst.afacctno,decode( RF.ISWFT,'Y',SB.codeid,MST.codeid) CODEID,
    mst.qtty qtty,'P' DTYPE,rf.exprice price,  'W' status, getbaldefovd(mst.afacctno) BALDEFOVD, rf.camastid
from caschd mst, camast rf,sbsecurities sb where mst.codeid = sb.refcodeid (+) and mst.camastid=rf.camastid and mst.qtty > 0 and mst.status in ('A', 'M') and mst.deltd <>'Y'
                                 and rf.duedate >= (select to_date(varvalue, 'DD/MM/RRRR') from sysvar where varname = 'CURRDATE')
*/
/*union
select txdate, sysdate cleardate, txnum || to_char(txdate,'DD/MM/YYYY') autoid,
substr(acctno,1,10) afacctno, substr(acctno,11,6) codeid, qtty - dfqtty qtty, 'B' DTYPE,0 price, 'Z' status,
       0 BALDEFOVD, ACCTNO camastid
from semastdtl
where qtty - dfqtty>0 and deltd <> 'Y' and QTTYTYPE in ('002','003','004','005')
*/
) mst, sbsecurities sb, allcode cd, afmast af, cfmast cf
where mst.codeid = sb.codeid and mst.afacctno = af.acctno and af.custid = cf.custid
and cd.cdtype='DF' and cd.cdname ='DEALTYPE' and cd.cdval=mst.dtype

)
/
