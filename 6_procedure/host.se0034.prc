SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "SE0034" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   pv_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2,
   PV_CUSTODYCD   IN       VARCHAR2,
   PV_AFACCTNO    IN       VARCHAR2
       )
IS

-- RP NAME : BAO CAO BANG KE CHUNG KHOAN GIAO DICH LO LE SUM GROUP THEO MA CHUNG KHOAN
-- PERSON :  QUYET.KIEU
-- DATE :    27/04/2011
-- COMMENTS : CREATE NEW
-- ---------   ------  -------------------------------------------
   V_STRAFACCTNO  VARCHAR2 (15);
   V_CUSTODYCD VARCHAR2 (15);
BEGIN
-- GET REPORT'S PARAMETERS


   IF  (PV_CUSTODYCD <> 'ALL')
   THEN
         V_CUSTODYCD := PV_CUSTODYCD;
   ELSE
        V_CUSTODYCD := '%';
   END IF;


   IF  (PV_AFACCTNO <> 'ALL')
   THEN
         V_STRAFACCTNO := PV_AFACCTNO;
   ELSE
      V_STRAFACCTNO := '%';
   END IF;

-- GET REPORT'S DATA
 OPEN PV_REFCURSOR
 FOR
SELECT
    (case when sb.tradeplace='002' then '1. HNX'
          when sb.tradeplace='001' then '2. HOSE'
          when sb.tradeplace='005' then '2. UPCOM' else '' end) san,
SUBSTR (TL.msgacct, 11, 6) codeid,
sb.symbol symbol ,
Sum(TL.msgamt) SL_Lole ,
Sum(TL.msgamt*sb.Parvalue ) Tongmenhgia ,
sum(msgamt*fld.nvalue) Tong_Gia_tri

FROM

(
Select txdate ,txnum ,msgamt,msgacct  from TLLOG where tltxcd='8815'
   AND txdate >= TO_DATE (F_DATE  ,'DD/MM/YYYY')
    AND FNC_VALIDATE_SCOPE(BRID, '', TLSCOPE, PV_BRID, TLGOUPS)=0
   AND txdate <= TO_DATE (T_DATE  ,'DD/MM/YYYY')
Union all
Select txdate ,txnum ,msgamt , msgacct  from TLLOGALL where tltxcd='8815'
   AND txdate >= TO_DATE (F_DATE  ,'DD/MM/YYYY')
    AND FNC_VALIDATE_SCOPE(BRID, '', TLSCOPE, PV_BRID, TLGOUPS)=0
   AND txdate <= TO_DATE (T_DATE  ,'DD/MM/YYYY')
) TL ,
(
Select  txdate ,txnum ,nvalue from tllogfld  where fldcd='11'
union all
Select  txdate ,txnum ,nvalue from tllogfldall where fldcd='11'
)fld,sbsecurities sb
where TL.txnum=fld.txnum
and TL.txdate = fld.txdate
and sb.codeid=SUBSTR (TL.msgacct, 11, 6)
group by SUBSTR (TL.msgacct, 11, 6) , sb.tradeplace ,sb.symbol ;

EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;
 
 
 
 
/
