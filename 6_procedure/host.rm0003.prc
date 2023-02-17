SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "RM0003" (
   PV_REFCURSOR           IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2,
   I_DATE         IN       VARCHAR2,
   PV_CUSTODYCD   IN       VARCHAR2
  )
IS
--
-- RP NAME : BAO CAO HUY DANG KY QUYEN MUA - TAI KHOAN COREBANK
-- PERSON : QUYET.KIEU
-- DATE :   26/05/2011
-- COMMENTS : CREATE NEWS
-- ---------   ------  -------------------------------------------

v_CustodyCD varchar2(20);


BEGIN

IF  (PV_CUSTODYCD <> 'ALL')
THEN
      v_CustodyCD := replace(upper(PV_CUSTODYCD),' ','_');
ELSE
      v_CustodyCD := '%%';
END IF;

-- Main report
OPEN PV_REFCURSOR FOR

Select
 TL.txnum,
 TL.txdate,
 TL.txdesc,
 substr(TL.msgacct,0,10) afacctno,
 M_CK.M_CK symbol,
 cf.custodycd,
 cf.fullname,
 cf.idcode,
 cf.iddate,
 nvl(SL.SL,0) KL_GD,
 nvl(gia.gia,0) Gia,
(nvl(gia.gia,0)*nvl(SL.SL,0)) Gia_tri
from
(
Select * from tllog   where  tltxcd='3386'  and txdate= to_date(I_DATE,'dd/mm/yyyy')
union all
Select * from tllogall where tltxcd='3386' and txdate = to_date(I_DATE,'dd/mm/yyyy')
)TL,
(
Select txnum , txdate , cvalue M_CK from
(
Select * from tllogfld where fldcd ='04' and txdate= to_date(I_DATE,'dd/mm/yyyy')
union all
Select * from tllogfldall where fldcd ='04' and txdate= to_date(I_DATE,'dd/mm/yyyy')
)
)M_CK,
(
Select txnum , txdate , nvalue SL from
(
Select * from tllogfld where fldcd ='21'and txdate= to_date(I_DATE,'dd/mm/yyyy')
union all
Select * from tllogfldall where fldcd ='21' and txdate= to_date(I_DATE,'dd/mm/yyyy')
)
)
SL ,
(
Select txnum , txdate , nvalue GIA from
(
Select * from tllogfld where fldcd ='05'  and txdate= to_date(I_DATE,'dd/mm/yyyy')
union all
Select * from tllogfldall where fldcd ='05'  and txdate= to_date(I_DATE,'dd/mm/yyyy')
)
)GIA,
afmast af,
(SELECT * FROM CFMAST WHERE INSTR(TLGOUPS, CAREBY)>0) cf
where
substr(TL.msgacct,0,10) = af.acctno
and af.custid = cf.custid
and af.corebank='Y'
and tl.txnum = M_CK.txnum
and tl.txdate = M_CK.txdate
and tl.txnum= SL.txnum
and tl.txdate= SL.txdate
and tl.txnum= gia.txnum
and tl.txdate= gia.txdate
and tl.txdate  = to_date(I_DATE,'dd/mm/yyyy')
and cf.custodycd like v_CustodyCD
;
EXCEPTION
  WHEN OTHERS
   THEN
      RETURN;
END;
 
 
 
 
/
