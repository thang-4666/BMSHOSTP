SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "OD0031" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   I_DATE         IN       VARCHAR2,
   vn_index       IN       VARCHAR2,
   VN_VAR         IN       VARCHAR2, --Gia tri khop lenh luy ke
   VN_VAR_PER     IN       VARCHAR2, --Thi phan
   HO_index       IN       VARCHAR2,
   HO_VAR         IN       VARCHAR2, --Gia tri khop lenh luy ke
   HO_VAR_PER     IN       VARCHAR2, --Thi phan
   GTKL_HO        IN       VARCHAR2,
   GTKL_LK_HO     IN       VARCHAR2,
   GTKL_HA        IN       VARCHAR2,
   GTKL_LK_HA     IN       VARCHAR2
)
IS
--
-- PURPOSE: BRIEFLY EXPLAIN THE FUNCTIONALITY OF THE PROCEDURE
-- BAO CAO TINH HINH HOAT DONG TRONG NGAY CUA CTY
-- MODIFICATION HISTORY
-- PERSON      DATE    COMMENTS
-- NAMNT   21-NOV-06  CREATED
-- ---------   ------  -------------------------------------------
   V_STROPTION              VARCHAR2 (5);               -- A: ALL; B: BRANCH; S: SUB-BRANCH
   V_STRBRID                VARCHAR2 (4);               -- USED WHEN V_NUMOPTION > 0
   CUR         PKG_REPORT.REF_CURSOR;
   V_NUMOD                  NUMBER;     --TONG SO LENH TRONG NGAY
   V_NUMODHOSTC             NUMBER;     --TONG SO LENH SAN HA NOI
   V_NUMODHASTC             NUMBER;     -- TONG SO LENH SAN HCM

   --BIEN LAY GIA TRI CHO KHOI 1: GIA TRI KHOP
   V_GTK_HO                 NUMBER;
   V_GTK_HA                 NUMBER;
   V_GTK_HO_LK              NUMBER;
   V_GTK_HA_LK              NUMBER;
   V_FEE_HO                 NUMBER;
   V_FEE_HA                 NUMBER;
   V_FEE_HO_LK              NUMBER;
   V_FEE_HA_LK              NUMBER;
   --KET THUC KHAI BAO BIEN CHO KHOI 1.

   --BIEN LAY GIA TRI CHO KHOI 2: THONG KE LENH DAT
   V_NUMOD_HN_F             NUMBER;     -- TONG SO LENH DAT-HN- SAN
   V_NUMOD_HN_O             NUMBER;     -- TONG SO LENH DAT-HN-ONLINE
   V_NUMOD_HN_T             NUMBER;     -- TONG SO LENH DAT-HN-TELE
   V_NUMOD_HCM_F            NUMBER;     -- TONG SO LENH DAT-HN- SAN
   V_NUMOD_HCM_O            NUMBER;     -- TONG SO LENH DAT-HN-ONLINE
   V_NUMOD_HCM_T            NUMBER;     -- TONG SO LENH DAT-HN-TELE
   V_NUMFEEACR_HN           NUMBER;     -- PHI-HN
   V_NUMFEEACR_HCM          NUMBER;     -- PHI-HCM
   V_NUMFEEACR_HN_LK        NUMBER;     -- PHI-HN-LK
   V_NUMFEEACR_HCM_LK       NUMBER;     -- PHI-HCM-LK
   V_NUMIO_HN_F             NUMBER;     -- TONG SO LENH KHOP-HN- SAN
   V_NUMIO_HN_O             NUMBER;     -- TONG SO LENH KHOP-HN-ONLINE
   V_NUMIO_HN_T             NUMBER;     -- TONG SO LENH KHOP-HN-TELE
   V_NUMIO_HCM_F            NUMBER;     -- TONG SO LENH KHOP-HCM- SAN
   V_NUMIO_HCM_O            NUMBER;     -- TONG SO LENH KHOP-HCM-ONLINE
   V_NUMIO_HCM_T            NUMBER;     -- TONG SO LENH KHOP-HCM-TELE
   --KET THUC KHAI BAO BIEN LAY GIA TRI CHO KHOI 2.

   --BIEN LAY GIA TRI CHO KHOI 3: THONG KE LENH DAT, KHOP CUA HO, HA
   V_NUMOD_HCM              NUMBER;     -- TONG SO LENH DAT SAN HCM
   V_NUMOD_HN               NUMBER;     -- TONG SO LENH DAT SAN HN
   V_NUMOD_OTC              NUMBER;     -- TONG SO LENH DAT OTC
   V_NUMIO_HCM              NUMBER;     -- TONG SO LENH KHOP SAN HCM
   V_NUMIO_HN               NUMBER;     -- TONG SO LENH KHOP SAN HN
   V_NUMIO_OTC              NUMBER;     -- TONG SO LENH KHOP OTC
   --KET THUC KHAI BAO BIEN LAY GIA TRI CHO KHOI 3.

   --KHAI BAO BIEN LAY GIA TRI CHO KHOI 4: THONG KE HOP DONG MO TRONG NGAY
   V_NUMCOUNT_OPENT         NUMBER;                     -- SO KHACH HANG MO HD
   V_NUMCOUNT_CLOSE         NUMBER;                     -- SO KHACH HANG DONG HD
   V_NUMCOUNT               NUMBER;     -- TONG SO KH
   V_NUMCOUT_TRA            NUMBER;     -- TONG SO KH GIAO DICH TRONG  NGAY
   --KET THUC KHAI BAO BIEN LAY GIA TRI CHO KHOI 4.

   -- DECLARE PROGRAM VARIABLES AS SHOWN ABOVE
BEGIN

--GIA TRI KHOP LENH

OPEN CUR
FOR
SELECT SUM(VAL_GTK_HA.EXECAMT), SUM(VAL_GTK_HO.EXECAMT),SUM(VAL_HO_LK.EXECAMT) , SUM(VAL_HA_LK.EXECAMT),
SUM(FEE_HO.FEEACR),SUM(FEE_HA.FEEACR),SUM(FEE_HO_LK.FEEACR),SUM(FEE_HA_LK.FEEACR)
FROM
    (SELECT SUM(OD.EXECAMT ) EXECAMT FROM  ODMAST OD ,SBSECURITIES SB
    WHERE OD.codeid = SB.codeid  AND OD.DELTD<>'Y' AND SB.tradeplace ='001'
    AND  OD.TXDATE = TO_DATE(I_DATE ,'DD/MM/YYYY')
    UNION all
    SELECT SUM(OD.EXECAMT ) EXECAMT FROM  ODMASTHIST OD ,SBSECURITIES SB
    WHERE OD.codeid = SB.codeid  AND OD.DELTD<>'Y' AND SB.tradeplace ='001'
    AND  OD.TXDATE = TO_DATE(I_DATE ,'DD/MM/YYYY')
    )VAL_GTK_HO,
    (SELECT SUM(OD.EXECAMT) EXECAMT FROM  ODMAST OD ,SBSECURITIES SB
    WHERE OD.codeid =SB.codeid  AND OD.DELTD<>'Y' AND SB.tradeplace ='002'
    AND  OD.TXDATE =TO_DATE(I_DATE ,'DD/MM/YYYY')
    UNION ALL
    SELECT SUM(OD.EXECAMT) EXECAMT FROM  ODMASTHIST OD ,SBSECURITIES SB
    WHERE OD.codeid =SB.codeid  AND OD.DELTD<>'Y' AND SB.tradeplace ='002'
    AND  OD.TXDATE =TO_DATE(I_DATE ,'DD/MM/YYYY')
    )VAL_GTK_HA,

    (SELECT SUM(OD.EXECAMT) EXECAMT FROM  ODMAST OD ,SBSECURITIES SB
    WHERE OD.codeid =SB.codeid  AND OD.DELTD<>'Y' AND SB.tradeplace ='001'
    AND TO_CHAR(OD.TXDATE,'YYYY') = TO_CHAR(to_date(I_DATE,'dd/mm/yyyy') ,'YYYY')
    UNION ALL
    SELECT SUM(OD.EXECAMT) EXECAMT FROM  ODMASTHIST OD ,SBSECURITIES SB
    WHERE OD.codeid =SB.codeid  AND OD.DELTD<>'Y' AND SB.tradeplace ='001'
    AND TO_CHAR(OD.TXDATE,'YYYY') = TO_CHAR(to_date(I_DATE,'dd/mm/yyyy') ,'YYYY')
    )VAL_HO_LK, --VAL_HO_Y,

    (SELECT SUM(OD.EXECAMT) EXECAMT FROM  ODMAST OD ,SBSECURITIES SB
    WHERE OD.codeid =SB.codeid  AND OD.DELTD<>'Y' AND SB.tradeplace ='002'
    AND TO_CHAR(OD.TXDATE,'YYYY') = TO_CHAR(to_date(I_DATE,'dd/mm/yyyy') ,'YYYY')
    UNION ALL
    SELECT SUM(OD.EXECAMT) EXECAMT FROM  ODMASTHIST OD ,SBSECURITIES SB
    WHERE OD.codeid =SB.codeid  AND OD.DELTD<>'Y' AND SB.tradeplace ='002'
    AND TO_CHAR(OD.TXDATE,'YYYY') = TO_CHAR(to_date(I_DATE,'dd/mm/yyyy') ,'YYYY')
    )VAL_HA_LK,--VAL_HCM_Y,

    (SELECT SUM(OD.FEEACR ) FEEACR FROM  ODMAST OD ,SBSECURITIES SB
    WHERE OD.codeid = SB.codeid  AND OD.DELTD<>'Y' AND SB.tradeplace ='001'
    AND  OD.TXDATE = TO_DATE(I_DATE ,'DD/MM/YYYY')
    UNION ALL
    SELECT SUM(OD.FEEACR ) FEEACR FROM  ODMAST OD ,SBSECURITIES SB
    WHERE OD.codeid = SB.codeid  AND OD.DELTD<>'Y' AND SB.tradeplace ='001'
    AND  OD.TXDATE = TO_DATE(I_DATE ,'DD/MM/YYYY')
    )FEE_HO,

    (SELECT SUM(OD.FEEACR) FEEACR FROM  ODMAST OD ,SBSECURITIES SB
    WHERE OD.codeid =SB.codeid  AND OD.DELTD<>'Y' AND SB.tradeplace ='002'
    AND  OD.TXDATE =TO_DATE(I_DATE ,'DD/MM/YYYY')
    UNION ALL
    SELECT SUM(OD.FEEACR) FEEACR FROM  ODMASTHIST OD ,SBSECURITIES SB
    WHERE OD.codeid =SB.codeid  AND OD.DELTD<>'Y' AND SB.tradeplace ='002'
    AND  OD.TXDATE =TO_DATE(I_DATE ,'DD/MM/YYYY')
    )FEE_HA,--FEE_HCM,

    (SELECT SUM(OD.FEEACR) FEEACR FROM  ODMAST OD ,SBSECURITIES SB
    WHERE OD.codeid =SB.codeid  AND OD.DELTD<>'Y' AND SB.tradeplace ='001'
    AND TO_CHAR(OD.TXDATE,'YYYY') =TO_CHAR(to_date(I_DATE,'dd/mm/yyyy') ,'YYYY')
    UNION ALL
    SELECT SUM(OD.FEEACR) FEEACR FROM  ODMASTHIST OD ,SBSECURITIES SB
    WHERE OD.codeid =SB.codeid  AND OD.DELTD<>'Y' AND SB.tradeplace ='001'
    AND TO_CHAR(OD.TXDATE,'YYYY') =TO_CHAR(to_date(I_DATE,'dd/mm/yyyy') ,'YYYY')
    )FEE_HO_LK,--FEE_HO_Y,

    (SELECT SUM(OD.FEEACR) FEEACR FROM  ODMAST OD ,SBSECURITIES SB
    WHERE OD.codeid =SB.codeid  AND OD.DELTD<>'Y' AND SB.tradeplace ='002'
    AND TO_CHAR(OD.TXDATE,'YYYY') =TO_CHAR(to_date(I_DATE,'dd/mm/yyyy') ,'YYYY')
    UNION ALL
    SELECT SUM(OD.FEEACR) FEEACR FROM  ODMASTHIST OD ,SBSECURITIES SB
    WHERE OD.codeid =SB.codeid  AND OD.DELTD<>'Y' AND SB.tradeplace ='002'
    AND TO_CHAR(OD.TXDATE,'YYYY') = TO_CHAR(to_date(I_DATE,'dd/mm/yyyy') ,'YYYY')
    )FEE_HA_LK --FEE_HCM_Y
;
LOOP
  FETCH CUR
  INTO
        V_GTK_HO, V_GTK_HA, V_GTK_HO_LK, V_GTK_HA_LK, V_FEE_HO, V_FEE_HA, V_FEE_HO_LK,
        V_FEE_HA_LK;
       EXIT WHEN CUR%NOTFOUND;
  END LOOP;
  CLOSE CUR;
-- KET THUC PHAN LAY GIA TRI KHOP LENH

--------------------------------------------------------------------------------

-- KHOI 2: THONG KE LENH DAT
--THONG KE SL LENH
OPEN CUR
FOR

select  sum(OD_HN_F.ORDERID ),sum(OD_HN_O.ORDERID ),sum(OD_HN_T.ORDERID ),
        SUM(OD_HCM_F.ORDERID ),sum(OD_HCM_O.ORDERID ),sum(OD_HCM_T.ORDERID ),
        SUM(FEEACR_HN.FEEACR),SUM(FEEACR_HCM.FEEACR),
        SUM(FEEACR_HN_LK.FEEACR),SUM(FEEACR_HCM_LK.FEEACR),
        SUM(IO_HN_F.ORGORDERID ),sum(IO_HN_O.ORGORDERID ),sum(IO_HN_T.ORGORDERID ),
        sum(IO_HCM_F.ORGORDERID ),sum(IO_HCM_O.ORGORDERID ),sum(IO_HCM_T.ORGORDERID )
from
(
select count (ORDERID) ORDERID from  odmast od
where  substr(od.orderid,1,4) like  '0001' and od.via ='F'  and deltd <>'Y'
AND OD.TXDATE =TO_DATE(I_DATE ,'DD/MM/YYYY')
union all
select count (ORDERID) ORDERID  from  odmasthist od
where  substr(od.orderid,1,4) like  '0001' and od.via ='F' and deltd <>'Y'
AND OD.TXDATE =TO_DATE(I_DATE ,'DD/MM/YYYY')
)OD_HN_F,
(
select count (ORDERID) ORDERID from  odmast od
where  substr(od.orderid,1,4) like  '0001' and od.via ='O'  and deltd <>'Y'AND OD.TXDATE =TO_DATE(I_DATE ,'DD/MM/YYYY')
union all
select count (ORDERID) ORDERID  from  odmasthist od
where  substr(od.orderid,1,4) like  '0001' and od.via ='O' and deltd <>'Y'AND OD.TXDATE =TO_DATE(I_DATE ,'DD/MM/YYYY')
)OD_HN_O,
(
select count (ORDERID) ORDERID from  odmast od
where  substr(od.orderid,1,4) like  '0001' and od.via ='T'  and deltd <>'Y'AND OD.TXDATE =TO_DATE(I_DATE ,'DD/MM/YYYY')
union all
select count (ORDERID) ORDERID  from  odmasthist od
where  substr(od.orderid,1,4) like  '0001' and od.via ='T' and deltd <>'Y'AND OD.TXDATE =TO_DATE(I_DATE ,'DD/MM/YYYY')
)OD_HN_T,
(
select count (ORDERID) ORDERID from  odmast od
where  substr(od.orderid,1,4) like  '0101' and od.via ='F'  and deltd <>'Y'
AND OD.TXDATE =TO_DATE(I_DATE ,'DD/MM/YYYY')
union all
select count (ORDERID) ORDERID  from  odmasthist od
where  substr(od.orderid,1,4) like  '0101' and od.via ='F' and deltd <>'Y'
AND OD.TXDATE =TO_DATE(I_DATE ,'DD/MM/YYYY')
)OD_HCM_F,
(
select count (ORDERID) ORDERID from  odmast od
where  substr(od.orderid,1,4) like  '0101' and od.via ='O'  and deltd <>'Y'
AND OD.TXDATE =TO_DATE(I_DATE ,'DD/MM/YYYY')
union all
select count (ORDERID) ORDERID  from  odmasthist od , sbsecurities sb
where  substr(od.orderid,1,4) like  '0101' and od.via ='O' and deltd <>'Y'
AND OD.TXDATE =TO_DATE(I_DATE ,'DD/MM/YYYY')
)OD_HCM_O,
(
select count (ORDERID) ORDERID from  odmast od
where  substr(od.orderid,1,4) like  '0101' and od.via ='T'  and deltd <>'Y'
AND OD.TXDATE =TO_DATE(I_DATE ,'DD/MM/YYYY')
union all
select count (ORDERID) ORDERID  from  odmasthist od
where  substr(od.orderid,1,4) like  '0101' and od.via ='T' and deltd <>'Y'
AND OD.TXDATE =TO_DATE(I_DATE ,'DD/MM/YYYY')
)OD_HCM_T,
(
SELECT sum(FEEACR)  FEEACR FROM ODMASTHIST where  substr(orderid,1,4) like  '0001'
AND TXDATE =TO_DATE(I_DATE ,'DD/MM/YYYY')
union all
SELECT sum(FEEACR)  FEEACR FROM ODMAST where  substr(orderid,1,4) like  '0001'
AND TXDATE =TO_DATE(I_DATE ,'DD/MM/YYYY')
) FEEACR_HN
,
(
SELECT sum(FEEACR) FEEACR FROM ODMASTHIST where  substr(orderid,1,4) like  '0101'
AND TXDATE =TO_DATE(I_DATE ,'DD/MM/YYYY')
union all
SELECT sum(FEEACR) FEEACR FROM ODMAST where  substr(orderid,1,4) like  '0101'
AND TXDATE =TO_DATE(I_DATE ,'DD/MM/YYYY')
) FEEACR_HCM
,
(
SELECT sum(FEEACR)  FEEACR FROM ODMASTHIST where  substr(orderid,1,4) like  '0001'
AND TO_CHAR(TXDATE,'YYYY') =TO_CHAR(to_date(I_DATE,'dd/mm/yyyy') ,'YYYY')
union all
SELECT sum(FEEACR)  FEEACR FROM ODMAST where  substr(orderid,1,4) like  '0001'
AND TO_CHAR(TXDATE,'YYYY') =TO_CHAR(to_date(I_DATE,'dd/mm/yyyy') ,'YYYY')
)FEEACR_HN_LK --FEEACR_HN_Y
,
(SELECT sum(FEEACR) FEEACR FROM ODMASTHIST where  substr(orderid,1,4) like  '0101'
AND TO_CHAR(TXDATE,'YYYY') =TO_CHAR(to_date(I_DATE,'dd/mm/yyyy') ,'YYYY')
union all
SELECT sum(FEEACR) FEEACR FROM ODMAST where  substr(orderid,1,4) like  '0101'
AND TO_CHAR(TXDATE,'YYYY') =TO_CHAR(to_date(I_DATE,'dd/mm/yyyy') ,'YYYY')
)FEEACR_HCM_LK --FEEACR_HCM_Y
,
(select  count (distinct(io.ORGORDERID)) ORGORDERID from (select * from  odmast union all select * from odmasthist ) od,
(select * from iod union all select * from iodhist )io
where  od.orderid = io.orgorderid and  substr(od.orderid,1,4) like  '0001' and od.via ='F'  and od.deltd <>'Y' and io.deltd<>'Y'
AND  OD.TXDATE =TO_DATE(I_DATE ,'DD/MM/YYYY')
)IO_HN_F
,
(select  count (distinct(io.ORGORDERID)) ORGORDERID from (select * from  odmast union all select * from odmasthist ) od,
(select * from iod union all select * from iodhist )io
where  od.orderid = io.orgorderid and  substr(od.orderid,1,4) like  '0001' and od.via ='O'  and od.deltd <>'Y' and io.deltd<>'Y'
AND  OD.TXDATE =TO_DATE(I_DATE ,'DD/MM/YYYY')
)IO_HN_O
,
(select  count (distinct(io.ORGORDERID)) ORGORDERID from (select * from  odmast union all select * from odmasthist ) od,
(select * from iod union all select * from iodhist )io
where  od.orderid = io.orgorderid and  substr(od.orderid,1,4) like  '0001' and od.via ='T'  and od.deltd <>'Y' and io.deltd<>'Y'
AND  OD.TXDATE =TO_DATE(I_DATE ,'DD/MM/YYYY')
)IO_HN_T
,
(select  count (distinct(io.ORGORDERID)) ORGORDERID from (select * from  odmast union all select * from odmasthist ) od,
(select * from iod union all select * from iodhist )io
where  od.orderid = io.orgorderid and  substr(od.orderid,1,4) like  '0101' and od.via ='F'  and od.deltd <>'Y' and io.deltd<>'Y'
AND  OD.TXDATE =TO_DATE(I_DATE ,'DD/MM/YYYY')
)IO_HCM_F
,
(select  count (distinct(io.ORGORDERID)) ORGORDERID from (select * from  odmast union all select * from odmasthist ) od,
(select * from iod union all select * from iodhist )io
where  od.orderid = io.orgorderid and  substr(od.orderid,1,4) like  '0101' and od.via ='O'  and od.deltd <>'Y' and io.deltd<>'Y'
AND  OD.TXDATE =TO_DATE(I_DATE ,'DD/MM/YYYY')
)IO_HCM_O
,
(select  count (distinct(io.ORGORDERID)) ORGORDERID from (select * from  odmast union all select * from odmasthist ) od,
(select * from iod union all select * from iodhist )io
where  od.orderid = io.orgorderid and  substr(od.orderid,1,4) like  '0101' and od.via ='T'  and od.deltd <>'Y' and io.deltd<>'Y'
AND  OD.TXDATE =TO_DATE(I_DATE ,'DD/MM/YYYY')
)IO_HCM_T;


LOOP
  FETCH CUR
  INTO
   V_NUMOD_HN_F , V_NUMOD_HN_O , V_NUMOD_HN_T ,  V_NUMOD_HCM_F , V_NUMOD_HCM_O , V_NUMOD_HCM_T ,
   V_NUMFEEACR_HN ,V_NUMFEEACR_HCM , V_NUMFEEACR_HN_LK , V_NUMFEEACR_HCM_LK,
   V_NUMIO_HN_F, V_NUMIO_HN_O  , V_NUMIO_HN_T, V_NUMIO_HCM_F, V_NUMIO_HCM_O  , V_NUMIO_HCM_T
     ;
       EXIT WHEN CUR%NOTFOUND;
  END LOOP;
  CLOSE CUR;

-- KET THUC KHOI 2: THONG KE LENH DAT

----------------------------------------------------------------------------------------------------

-- KHOI 3:
OPEN CUR
FOR

select  sum(OD_HCM.ORDERID ),sum(OD_HN.ORDERID ),sum(OD_OTC.ORDERID ),
        SUM(IO_HCM.ORGORDERID),sum(IO_HN.ORGORDERID),sum(IO_OTC.ORGORDERID)
from
(
select count (ORDERID) ORDERID from  odmast od, sbsecurities sb where od.codeid =sb.codeid
and  sb.tradeplace ='001' and deltd <>'Y' AND OD.TXDATE =TO_DATE(I_DATE ,'DD/MM/YYYY')
union all
select count (ORDERID) ORDERID  from  odmasthist od , sbsecurities sb  where od.codeid =sb.codeid
and  sb.tradeplace ='001' and deltd <>'Y' AND OD.TXDATE =TO_DATE(I_DATE ,'DD/MM/YYYY')
)OD_HCM,
(
select count (ORDERID) ORDERID from  odmast od, sbsecurities sb where od.codeid =sb.codeid
and  sb.tradeplace ='002' and deltd <>'Y' AND OD.TXDATE =TO_DATE(I_DATE ,'DD/MM/YYYY')
union all
select count (ORDERID) ORDERID  from  odmasthist od , sbsecurities sb where od.codeid =sb.codeid
and  sb.tradeplace ='002' and deltd <>'Y' AND OD.TXDATE =TO_DATE(I_DATE ,'DD/MM/YYYY')
)OD_HN,
(
select count (ORDERID) ORDERID from  odmast od, sbsecurities sb where od.codeid =sb.codeid
and  sb.tradeplace ='003' and deltd <>'Y' AND OD.TXDATE =TO_DATE(I_DATE ,'DD/MM/YYYY')
union all
select count (ORDERID) ORDERID  from  odmasthist od , sbsecurities sb where od.codeid =sb.codeid
and  sb.tradeplace ='003' and deltd <>'Y' AND OD.TXDATE =TO_DATE(I_DATE ,'DD/MM/YYYY')
)OD_OTC
,
(
select  count (distinct(ORGORDERID)) ORGORDERID from iod io ,sbsecurities sb where io.codeid =sb.codeid
and  sb.tradeplace ='001' and deltd <>'Y' AND IO.TXDATE =TO_DATE(I_DATE ,'DD/MM/YYYY')
union all
select  count (distinct(ORGORDERID)) ORGORDERID from iodhist io,sbsecurities sb where io.codeid =sb.codeid
and  sb.tradeplace ='001' and deltd <>'Y' AND IO.TXDATE =TO_DATE(I_DATE ,'DD/MM/YYYY')
)IO_HCM,
(
select  count (distinct(ORGORDERID)) ORGORDERID from iod io ,sbsecurities sb where io.codeid =sb.codeid
and  sb.tradeplace ='002' and deltd <>'Y' AND IO.TXDATE =TO_DATE(I_DATE ,'DD/MM/YYYY')
union all
select  count (distinct(ORGORDERID)) ORGORDERID from iodhist io,sbsecurities sb where io.codeid =sb.codeid
and  sb.tradeplace ='002' and deltd <>'Y' AND IO.TXDATE =TO_DATE(I_DATE ,'DD/MM/YYYY')
)IO_HN,
(
select  count (distinct(ORGORDERID)) ORGORDERID from iod io ,sbsecurities sb where io.codeid =sb.codeid
and  sb.tradeplace ='003' and deltd <>'Y'AND IO.TXDATE =TO_DATE(I_DATE ,'DD/MM/YYYY')
union all
select  count (distinct(ORGORDERID)) ORGORDERID from iodhist io,sbsecurities sb where io.codeid =sb.codeid
and  sb.tradeplace ='003' and deltd <>'Y' AND IO.TXDATE =TO_DATE(I_DATE ,'DD/MM/YYYY')
)IO_OTC;

 LOOP
      FETCH CUR
       INTO  V_NUMOD_HCM , V_NUMOD_HN,  V_NUMOD_OTC ,
            V_NUMIO_HCM  ,V_NUMIO_HN , V_NUMIO_OTC        ;
       EXIT WHEN CUR%NOTFOUND;
  END LOOP;
  CLOSE CUR;
-- KET THUC KHOI 3.

------------------------------------------------------------------------------------------------

-- KHOI 4: THONG KE KHACH HANG MO TAI KHOAN TRONG NGAY

 OPEN CUR
 FOR

SELECT OPE.COUCUS COUNT_OPENT,CLS.COUCUS COUNT_CLOSE,TOT.COUCUS ,COUT_TRA.COUCUS COUT_TRA
FROM
( SELECT COUNT(ROWNUM)  COUCUS FROM AFMAST WHERE OPNDATE = TO_DATE(I_DATE ,'DD/MM/YYYY')
)OPE
,(SELECT SUM(COUCUS) COUCUS
    FROM(
    SELECT COUNT(ROWNUM) COUCUS  FROM TLLOGALL WHERE TLTXCD =  '0075' AND TXDATE =TO_DATE(I_DATE ,'DD/MM/YYYY')
    UNION ALL
    SELECT COUNT(ROWNUM) COUCUS FROM TLLOG WHERE TLTXCD =  '0075' AND TXDATE =TO_DATE(I_DATE ,'DD/MM/YYYY'))
)CLS
,
(SELECT COUNT(ROWNUM) COUCUS FROM  AFMAST)TOT
,
(SELECT SUM(COUCUS) COUCUS FROM
    (
    SELECT COUNT(DISTINCT(AFACCTNO)) COUCUS FROM ODMAST WHERE TXDATE =TO_DATE(I_DATE ,'DD/MM/YYYY')
    UNION ALL
    SELECT COUNT(DISTINCT(AFACCTNO)) COUCUS FROM ODMASTHIST WHERE TXDATE =TO_DATE(I_DATE ,'DD/MM/YYYY')
    )
)COUT_TRA
 ;
 LOOP
      FETCH CUR
       INTO V_NUMCOUNT_OPENT,V_NUMCOUNT_CLOSE,V_NUMCOUNT,V_NUMCOUT_TRA ;
       EXIT WHEN CUR%NOTFOUND;
 END LOOP;
 CLOSE CUR;
-- KETH THUC KHOI 4: THONG KE KHACH HANG MO HOP DONG TRONG NGAY


-- GET REPORT'S PARAMETERS
-- END OF GETTING REPORT'S PARAMETERS

-- GET REPORT'S DATA

      OPEN PV_REFCURSOR
       FOR

    SELECT  to_number(vn_index)  vn_index, to_number(VN_VAR)  VN_VAR, to_number(VN_VAR_PER) VN_VAR_PER ,
            to_number(HO_index)    HO_index,to_number(HO_VAR) HO_VAR,to_number(HO_VAR_PER)  HO_VAR_PER,
            to_number(GTKL_HO) GTKL_HO, to_number(GTKL_LK_HO) GTKL_LK_HO, to_number(GTKL_HA) GTKL_HA,
            to_number(GTKL_LK_HA) GTKL_LK_HA,
            --KHOI 1
            NVL(V_GTK_HO,0)V_GTK_HO , NVL(V_GTK_HA,0) V_GTK_HA,  NVL(V_GTK_HO_LK,0) V_GTK_HO_LK,
            NVL(V_GTK_HA_LK,0) V_GTK_HA_LK, NVL(V_FEE_HO,0) V_FEE_HO , NVL(V_FEE_HA,0) V_FEE_HA,
            NVL(V_FEE_HO_LK,0) V_FEE_HO_LK , NVL(V_FEE_HA_LK,0) V_FEE_HA_LK,
            --KHOI 2
            NVL(V_NUMOD_HN_F,0) V_NUMOD_HN_F, NVL(V_NUMOD_HN_O,0) V_NUMOD_HN_O, NVL(V_NUMOD_HN_T,0) V_NUMOD_HN_T,
            NVL(V_NUMOD_HCM_F,0) V_NUMOD_HCM_F, NVL(V_NUMOD_HCM_O,0) V_NUMOD_HCM_O, NVL(V_NUMOD_HCM_T,0) V_NUMOD_HCM_T,
            NVL(V_NUMFEEACR_HN,0) V_NUMFEEACR_HN, NVL(V_NUMFEEACR_HCM,0) V_NUMFEEACR_HCM,
            NVL(V_NUMFEEACR_HN_LK,0) V_NUMFEEACR_HN_LK, NVL(V_NUMFEEACR_HCM_LK,0) V_NUMFEEACR_HCM_LK,
            NVL(V_NUMIO_HN_F,0) V_NUMIO_HN_F, NVL(V_NUMIO_HN_O,0) V_NUMIO_HN_O, NVL(V_NUMIO_HN_T,0) V_NUMIO_HN_T,
            NVL(V_NUMIO_HCM_F,0) V_NUMIO_HCM_F, NVL(V_NUMIO_HCM_O,0) V_NUMIO_HCM_O, NVL(V_NUMIO_HCM_T,0) V_NUMIO_HCM_T,
            --KHOI 3
            NVL(V_NUMOD_HCM,0) V_NUMOD_HCM, NVL(V_NUMOD_HN,0) V_NUMOD_HN, NVL(V_NUMOD_OTC,0) V_NUMOD_OTC,
            NVL(V_NUMIO_HCM,0) V_NUMIO_HCM, NVL(V_NUMIO_HN,0) V_NUMIO_HN, NVL(V_NUMIO_OTC,0) V_NUMIO_OTC,
            --KHOI 4
            NVL(V_NUMCOUNT_OPENT,0) V_NUMCOUNT_OPENT, NVL(V_NUMCOUNT_CLOSE,0) V_NUMCOUNT_CLOSE,
            NVL(V_NUMCOUNT,0) V_NUMCOUNT, NVL(V_NUMCOUT_TRA,0) V_NUMCOUT_TRA
        FROM DUAL;

 EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;                                                              -- PROCEDURE

 
 
 
 
/
