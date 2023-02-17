SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE od1028 (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   pv_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2,
   SYMBOL         IN       VARCHAR2
     )
IS
--
-- PURPOSE: BRIEFLY EXPLAIN THE FUNCTIONALITY OF THE PROCEDURE
-- TONG HOP KET QUA KHOP LENH
-- MODIFICATION HISTORY
-- PERSON      DATE    COMMENTS
-- NAMNT   21-NOV-06  CREATED
-- ---------   ------  -------------------------------------------
   V_STRSYMBOL          VARCHAR2 (20);

 CUR            PKG_REPORT.REF_CURSOR;

-- DECLARE PROGRAM VARIABLES AS SHOWN ABOVE
BEGIN
   IF (SYMBOL <> 'ALL')
   THEN
      V_STRSYMBOL := SYMBOL;
   ELSE
      V_STRSYMBOL := '%%';
   END IF;

 -- GET REPORT'S DATA

 OPEN PV_REFCURSOR
   FOR

SELECT
od.typem,od.grm,od.brid,
      SUM  ( CASE WHEN tradeplace ='001' THEN  od.execamt ELSE 0 END) amt_hsx ,
      sum  ( CASE WHEN tradeplace <>'001' THEN  od.execamt ELSE 0 END) amt_hnx ,
      sum  ( CASE WHEN tradeplace ='001' THEN  od.execamt ELSE 0 END)/10000000000000 rate_hsx,
      sum  ( CASE WHEN tradeplace <>'001' THEN  od.execamt ELSE 0 END)/10000000000000 rate_hnx

FROM (
SELECT  max(od.execamt)  execamt,max(sb.tradeplace) tradeplace
,max( nvl( CASE WHEN od.txdate >= re_frdate AND od.txdate <= re_todate AND  od.txdate >= regl_frdate AND od.txdate <= regl_todate THEN re.TYPEM   END,'NULL')) TYPEM
,min( nvl( CASE WHEN od.txdate >= re_frdate AND od.txdate <= re_todate AND  od.txdate >= regl_frdate AND od.txdate <= regl_todate THEN re.GRM   END , '6')) GRM
,max( nvl( CASE WHEN od.txdate >= re_frdate AND od.txdate <= re_todate AND  od.txdate >= regl_frdate AND od.txdate <= regl_todate THEN re.BRID END , decode(substr(od.afacctno,1,4),'0001','A', '0101','B') )) BRID
FROM vw_odmast_all od,sbsecurities sb,afmast af, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf  ,
(
SELECT re.afacctno , REGl.refrecflnkid
,CASE
      --HS
       WHEN REGl.refrecflnkid IN ('107','108','110','111') THEN 'SALE'
       WHEN REGl.refrecflnkid IN ('106','112') THEN 'CTV'
       WHEN REGl.refrecflnkid IN ('109') THEN 'DHT'
       WHEN RE.reacctno =  '00019101071111' THEN 'MGA'
       WHEN REGl.refrecflnkid IN ('103') THEN 'KHTC'
       WHEN cf.custodycd ='002P000001'  THEN 'TD'
      --CN
       WHEN REGl.refrecflnkid IN ('115','117','119','121','114','123') THEN 'SALE'
       WHEN REGl.refrecflnkid IN ('116','120') THEN 'CTV'
       WHEN REGl.refrecflnkid IN ('122') THEN 'DHT'
       WHEN RE.reacctno =  '01019101081112' THEN 'MGA'
       WHEN REGl.refrecflnkid IN ('124') THEN 'KHTC'
  END TYPEM
, CASE
     --HS
       WHEN REGl.refrecflnkid IN ('107','108','110','111','106','112') THEN '1'
       WHEN REGl.refrecflnkid IN ('109') THEN '2'
       WHEN RE.reacctno =  '00019101071111' THEN '3'
       WHEN REGl.refrecflnkid IN ('103') THEN '4'
       WHEN cf.custodycd ='002P000001'  THEN '5'
     --CN
       WHEN REGl.refrecflnkid IN ('115','117','119','121','116','120','114','123') THEN '1'
       WHEN REGl.refrecflnkid IN ('122') THEN '2'
       WHEN RE.reacctno =  '01019101081112' THEN '3'
       WHEN REGl.refrecflnkid IN ('124') THEN '4'
  END GRM
,CASE
     --HS
       WHEN REGl.refrecflnkid IN ('107','108','110','111','106','112','109','103') THEN 'A'
       WHEN RE.reacctno =  '00019101071111' THEN   'A'
       WHEN cf.custodycd ='002P000001'  THEN 'A'
       --HS
       WHEN REGl.refrecflnkid IN ('115','117','119','121','116','120','122','124','114','123') THEN 'B'
       WHEN RE.reacctno =  '01019101081112' THEN   'B'
   END BRID,
   re.frdate re_frdate, nvl(re.clstxdate-1, re.todate) re_todate ,
   REGl.frdate REGl_frdate, nvl(REGl.clstxdate-1, REGl.todate) REGl_todate
FROM reaflnk re, regrplnk REGl,retype,cfmast cf
WHERE re.reacctno = REGl.reacctno(+)
AND  SUBSTR(RE.reacctno,11)=RETYPE.actype
AND retype.rerole ='RM'
AND re.afacctno = cf.custid
) re
WHERE od.codeid = sb.codeid
--AND sb.sectype NOT IN ('003','006')
AND od.afacctno = af.acctno
AND af.custid= cf.custid
AND cf.custid = re.afacctno(+)
AND od.txdate >= to_date(F_DATE,'DD/MM/YYYY')
AND od.txdate <= to_date(T_DATE,'DD/MM/YYYY')
AND od.execamt >0
AND af.custid <>'0001921283'
GROUP BY orderid
)od
GROUP BY od.typem,od.grm,od.brid ;

EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;                                                              -- PROCEDURE
 
/
