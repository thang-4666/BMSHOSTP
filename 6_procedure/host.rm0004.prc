SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "RM0004" (
   PV_REFCURSOR           IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   I_DATE         IN       VARCHAR2,
   PV_CUSTODYCD   IN       VARCHAR2,
   COREBANK       IN       VARCHAR2,
   SYMBOL         IN       VARCHAR2
  )
IS
--
-- RP NAME : BAO CAO TRA CO TUC BANG TIEN - TAI KHOAN COREBANK
-- PERSON : QUYET.KIEU
-- DATE :   25/05/2011
-- COMMENTS : CREATE NEWS
-- Chaunh modified 18-07-2011
-- ---------   ------  -------------------------------------------

v_CustodyCD varchar2(20);
V_SYMBOL VARCHAR2(20);
V_COREBANK VARCHAR2(2);


BEGIN

IF  (PV_CUSTODYCD <> 'ALL')
THEN
      v_CustodyCD := replace(upper(PV_CUSTODYCD),' ','_');
ELSE
      v_CustodyCD := '%%';
END IF;

IF  (SYMBOL <> 'ALL')
THEN
      v_SYMBOL := SYMBOL;
ELSE
      v_SYMBOL := '%%';
END IF;

V_COREBANK:=NVL(COREBANK,'Y');
-- Main report
OPEN PV_REFCURSOR FOR

Select
 TL.txnum, TL.txdate, substr(TL.msgacct,0,10) afacctno, cf.custodycd, cf.fullname, cf.idcode, cf.iddate, Ma_CA.Ma_CA , Ma_CK.Ma_CK,
 nvl(ca.devidentrate,0) ty_le_thuc_hien,
  CASE
 WHEN TL.TLTXCD = '3350' THEN NVL(TL.msgamt,0)
 WHEN TL.TLTXCD=  '3354' THEN NVL(TL.msgamt,0) - nvl(thue.thue,0)
 END SL_Tien,
  CASE
 WHEN TL.TLTXCD = '3350' THEN nvl(thue.thue,0)
 WHEN TL.TLTXCD=  '3354' THEN 0
 END  thue
 from
(
Select * from tllog   where  tltxcd in ('3350','3354')  and txdate= to_date(I_DATE,'dd/mm/yyyy')
union all
Select * from tllogall where tltxcd in ('3350','3354') and txdate= to_date(I_DATE,'dd/mm/yyyy')
)TL,
(
Select txnum , txdate , cvalue Ma_CA from
(
Select * from tllogfld where fldcd ='02'      and txdate= to_date(I_DATE,'dd/mm/yyyy')
union all
Select * from tllogfldall where fldcd ='02'  and txdate= to_date(I_DATE,'dd/mm/yyyy')
)
)Ma_CA,
(
Select txnum , txdate , cvalue Ma_CK from
(
Select * from tllogfld where fldcd ='04'      and txdate= to_date(I_DATE,'dd/mm/yyyy')
union all
Select * from tllogfldall where fldcd ='04'   and txdate= to_date(I_DATE,'dd/mm/yyyy')
)
)Ma_CK,
(
Select txnum , txdate , nvalue thue from
(
Select * from tllogfld where fldcd ='20'     and txdate= to_date(I_DATE,'dd/mm/yyyy')
union all
Select * from tllogfldall where fldcd ='20'  and txdate= to_date(I_DATE,'dd/mm/yyyy')
)
)thue,
afmast af,
(SELECT * FROM CFMAST WHERE INSTR(TLGOUPS, CAREBY)>0) cf,
camast ca
WHERE ca.camastid=  Ma_CA.Ma_CA
and CATYPE IN ('010','011')
and substr(TL.msgacct,0,10) = af.acctno
and af.custid = cf.custid
and af.corebank=V_COREBANK
and tl.txnum  = Ma_CA.txnum
and tl.txdate = Ma_CA.txdate
and tl.txnum=  thue.txnum
and tl.txdate= thue.txdate
and tl.txnum  = Ma_CK.txnum
and tl.txdate = Ma_CK.txdate
 and tl.txdate  = to_date(I_DATE,'dd/mm/yyyy')
 and cf.custodycd like v_CustodyCD
 AND CA.optsymbol LIKE V_SYMBOL

;
EXCEPTION
  WHEN OTHERS
   THEN
      RETURN;
END;
 
 
 
 
/
