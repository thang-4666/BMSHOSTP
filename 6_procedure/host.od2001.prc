SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "OD2001" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   pv_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2
 )
IS
--bao cao phan bo thuong truc tiep moi gioi cham soc tai khoan
--created by Chaunh at 11/09/2012
    V_STROPTION    VARCHAR2 (5);            -- A: ALL; B: BRANCH; S: SUB-BRANCH
    V_STRBRID      VARCHAR2 (40);            -- USED WHEN V_NUMOPTION > 0
    V_INBRID     VARCHAR2 (5);
    VF_DATE DATE;
    VT_DATE DATE;
    V_HNX_UP_GT NUMBER;
     V_HNX_UP_DT NUMBER;
     V_HOSE_GT NUMBER;
     V_HOSE_DT NUMBER;


BEGIN

   V_STROPTION := upper(OPT);
   V_INBRID := pv_BRID;

   if(V_STROPTION = 'A') then
        V_STRBRID := '%';
    else
        if(V_STROPTION = 'B') then
            select br.mapid into V_STRBRID from brgrp br where  br.brid = V_INBRID;
        else
            V_STRBRID := pv_BRID;
        end if;
    end if;

    ------------------------
   VF_DATE := to_date(F_DATE,'DD/MM/RRRR');
   VT_DATE := to_date(T_DATE,'DD/MM/RRRR');

   SELECT sum(CASE WHEN  sb.tradeplace IN ('002','005') THEN od.execamt ELSE 0 END) hnx_up_GT,
        sum(CASE WHEN  sb.tradeplace IN ('002','005') THEN od.feeacr ELSE 0 END) hnx_up_DT,
        sum(CASE WHEN  sb.tradeplace = '001' THEN od.execamt ELSE 0 END) hose_GT,
        sum(CASE WHEN  sb.tradeplace = '001' THEN od.feeacr ELSE 0 END) hose_DT
        INTO  V_HNX_UP_GT, V_HNX_UP_DT, V_HOSE_GT, V_HOSE_DT
        FROM vw_odmast_all od, sbsecurities sb
        WHERE txdate <=  VT_DATE AND txdate >=  VF_DATE AND deltd <> 'Y' AND EXECTYPE IN ('NB','NS','MS')
        AND od.codeid = sb.codeid
        AND sb.tradeplace IN ('001','002','005')
       ;


OPEN PV_REFCURSOR FOR
SELECT * FROM
(
SELECT nhom_cha, nhom_con, fullname,  ma_nhom
,  SUM(hnx_up_GT) hnx_up_GT, SUM(hnx_up_DT) hnx_up_DT, SUM(hose_GT) hose_GT,SUM(hose_DT) hose_DT
,V_HNX_UP_GT P_HNX_UP_GT, V_HNX_UP_DT P_HNX_UP_DT, V_HOSE_GT P_HOSE_GT, V_HOSE_DT P_HOSE_DT
from
(
SELECT
case
     WHEN SP_FORMAT_REGRP_MAPCODE(ma_nhom) LIKE '000018.000017%' THEN 'A. Tổng trụ sở'
     WHEN SP_FORMAT_REGRP_MAPCODE(ma_nhom) LIKE '000018.000019%' THEN 'B. Tổng chi nhánh'
     WHEN ma_nhom is NOT NULL AND brid LIKE '000%' THEN 'A. Tổng trụ sở'
     WHEN ma_nhom is NOT NULL AND brid LIKE '010%' THEN 'B. Tổng chi nhánh'
     WHEN  ma_nhom is NULL AND brid LIKE '000%' THEN 'A. Tổng trụ sở'
     WHEN  ma_nhom is NULL AND brid LIKE '010%' THEN 'B. Tổng chi nhánh'
     WHEN brid is NULL AND  afacctno LIKE '000%' THEN 'A. Tổng trụ sở'
     WHEN  brid is NULL AND  afacctno LIKE '010%' THEN 'B. Tổng chi nhánh'
     ELSE 'sid'
END nhom_cha,
case
    WHEN SP_FORMAT_REGRP_MAPCODE(ma_nhom) = '000018.000017' THEN 'A. Tổng trụ sở'
    WHEN SP_FORMAT_REGRP_MAPCODE(ma_nhom) = '000018.000019' THEN 'B. Tổng chi nhánh'
    WHEN SP_FORMAT_REGRP_MAPCODE(ma_nhom) LIKE '000018.000017.000001.000014%' THEN '4. Đại lý Sông Lam'
    WHEN SP_FORMAT_REGRP_MAPCODE(ma_nhom) LIKE '000018.000017.000001%' THEN '1. Giao dịch trụ sở'

    WHEN SP_FORMAT_REGRP_MAPCODE(ma_nhom) LIKE '000018.000017.000021%' THEN '3. Khách hàng tổ chức'
    WHEN SP_FORMAT_REGRP_MAPCODE(ma_nhom) LIKE '000018.000017.000020%' THEN '5. Phòng giao dịch Mỹ Ðình'
    WHEN SP_FORMAT_REGRP_MAPCODE(ma_nhom) LIKE '000018.000017.000005%' THEN '6. Phòng giao dịch 94 Bà Triệu'
    WHEN SP_FORMAT_REGRP_MAPCODE(ma_nhom) LIKE '000018.000019.000016%' THEN '2. Khách hàng TCCN'
    WHEN SP_FORMAT_REGRP_MAPCODE(ma_nhom) LIKE '000018.000019.000023%' THEN '1. Giao dịch CN'
    WHEN SP_FORMAT_REGRP_MAPCODE(ma_nhom) LIKE '000018.000019.000012%' THEN '1. Giao dịch CN'
    WHEN ma_nhom is NULL AND brid LIKE '000%' THEN '9.TK tự do va MG tự do'
    WHEN ma_nhom is NULL AND brid LIKE '010%' THEN '3.TK tự do va MG tự do'
    WHEN brid is NULL AND  afacctno LIKE '000%' THEN '9.TK tự do va MG tự do'
    WHEN brid is NULL AND  afacctno LIKE '010%' THEN '3.TK tự do va MG tự do'
    ELSE '8. Khách hàng khác'
END nhom_con,
case WHEN fullname IS NOT NULL THEN fullname
     WHEN brid is NOT NULL THEN 'MG tự do'
     WHEN brid is NULL THEN 'TK tự do'
END fullname, SP_FORMAT_REGRP_MAPCODE(ma_nhom) ma_nhom
,  (hnx_up_GT) hnx_up_GT, (hnx_up_DT) hnx_up_DT, (hose_GT) hose_GT,(hose_DT) hose_DT
,
V_HNX_UP_GT P_HNX_UP_GT, V_HNX_UP_DT P_HNX_UP_DT, V_HOSE_GT P_HOSE_GT, V_HOSE_DT P_HOSE_DT
FROM
    (
    SELECT
    sum(CASE WHEN  a.tradeplace IN ('002','005') THEN a.execamt ELSE 0 END) hnx_up_GT,
    sum(CASE WHEN  a.tradeplace IN ('002','005') THEN a.feeacr ELSE 0 END) hnx_up_DT,
    sum(CASE WHEN  a.tradeplace = '001' THEN a.execamt ELSE 0 END) hose_GT,
    sum(CASE WHEN  a.tradeplace = '001' THEN a.feeacr ELSE 0 END) hose_DT
    , b.brid ,  b.autoid ma_nhom ,  a.afacctno, b.fullname
    FROM
    (
        SELECT od.execamt, sb.tradeplace, od.feeacr , od.afacctno, od.orderid
        FROM vw_odmast_all od, sbsecurities sb, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf, afmast af
        WHERE txdate <=  VT_DATE AND txdate >=  VF_DATE
        AND deltd <> 'Y' AND EXECTYPE IN ('NB','NS','MS')
        AND od.codeid = sb.codeid
        AND sb.tradeplace IN ('001','002','005')
        AND cf.custid = af.custid AND cf.custodycd NOT LIKE '___P%'
        AND od.afacctno = af.acctno
        AND AF.ACTYPE NOT IN ('0000')
    ) a

    LEFT JOIN

    ( SELECT x.orderid,x.reacctno, x.brid,y.autoid, y.fullname
    FROM (
        SELECT  OD.orderid, od.afacctno, kh.reacctno, od.txdate, recflnk.brid
            FROM reaflnk kh,  sbsecurities sb,
                 cfmast cf, afmast af, recflnk,
                vw_odmast_all OD
            WHERE
                 OD.afacctno = kh.afacctno
                AND kh.orgreacctno is NULL --chi lay cho moi gioi chinh
                AND od.afacctno = af.acctno AND af.custid = cf.custid
                AND AF.ACTYPE NOT IN ('0000')
                AND sb.codeid = od.codeid
                AND sb.tradeplace IN ('001','002','005')
                AND OD.txdate <=  to_date(VT_DATE,'DD/MM/RRRR')
                AND OD.txdate >=  to_date(VF_DATE,'DD/MM/RRRR')
                AND OD.txdate <= nvl(kh.clstxdate -1 ,kh.todate)
                AND od.txdate >= kh.frdate
                AND OD.deltd <> 'Y' AND OD.EXECTYPE IN ('NB','NS','MS')
                AND SUBSTR(kh.reacctno,1,10) = recflnk.custid(+)
                AND cf.custodycd NOT LIKE '___P%'
            ) x
          LEFT JOIN
          (
           SELECT  OD.orderid,  regrp.autoid, regrp.fullname
            FROM reaflnk kh, regrplnk nhom, sbsecurities sb,
                 cfmast cf, afmast af, regrp,
                vw_odmast_all OD
            WHERE
                 OD.afacctno = kh.afacctno
                AND kh.orgreacctno is NULL
                AND od.afacctno = af.acctno AND af.custid = cf.custid
                AND AF.ACTYPE NOT IN ('0000')
                AND sb.codeid = od.codeid
                AND sb.tradeplace IN ('001','002','005')
                AND kh.reacctno = nhom.reacctno
                AND OD.txdate <=  to_date(VT_DATE,'DD/MM/RRRR')
                AND OD.txdate >=  to_date(VF_DATE,'DD/MM/RRRR')
                AND OD.txdate <= nvl(kh.clstxdate -1 ,kh.todate)
                AND od.txdate >= kh.frdate
                AND OD.txdate <= nvl(nhom.clstxdate -1 ,nhom.todate)
                AND od.txdate >= nhom.frdate
                AND OD.deltd <> 'Y' AND OD.EXECTYPE IN ('NB','NS','MS')
                AND regrp.autoid = nhom.refrecflnkid
                AND cf.custodycd NOT LIKE '___P%'
          ) y
          ON x.orderid = y.orderid
    ) b
    ON a.orderid = b.orderid
    GROUP BY a.afacctno, b.autoid , b.brid , b.fullname
  )
)
GROUP BY   nhom_cha, nhom_con, fullname,  ma_nhom


union ALL

SELECT 'A. Tổng trụ sở' nhom_cha,'7. Tự doanh' nhom_con,'Tự doanh' fullname,'Tự doanh' ma_nhom,
        sum(CASE WHEN  sb.tradeplace IN ('002','005') THEN od.execamt ELSE 0 END) hnx_up_GT,
        sum(CASE WHEN  sb.tradeplace IN ('002','005') THEN od.feeacr ELSE 0 END) hnx_up_DT,
        sum(CASE WHEN  sb.tradeplace = '001' THEN od.execamt ELSE 0 END) hose_GT,
        sum(CASE WHEN  sb.tradeplace = '001' THEN od.feeacr ELSE 0 END) hose_DT
        ,V_HNX_UP_GT P_HNX_UP_GT, V_HNX_UP_DT P_HNX_UP_DT, V_HOSE_GT P_HOSE_GT, V_HOSE_DT P_HOSE_DT
FROM
(SELECT afacctno, codeid, execamt, feeacr, txdate FROM odmast WHERE deltd <> 'Y'
        UNION ALL
        SELECT afacctno, codeid, execamt, feeacr, txdate FROM odmasthist WHERE deltd <> 'Y') OD, cfmast cf, afmast af, sbsecurities sb
WHERE OD.afacctno = af.acctno AND cf.custid = af.custid AND AF.ACTYPE NOT IN ('0000') AND cf.custodycd LIKE '___P%'
AND sb.codeid = OD.codeid
AND od.txdate >= VF_DATE AND od.txdate <= VT_DATE
)

WHERE hnx_up_GT +  hnx_up_DT +  hose_GT  + hose_DT <> 0
ORDER BY ma_nhom

/*SELECT * FROM
(
SELECT
case --WHEN SP_FORMAT_REGRP_MAPCODE(regrp.autoid) = '000018' THEN '---'
     WHEN SP_FORMAT_REGRP_MAPCODE(ma_nhom) LIKE '000018.000017%' THEN 'A. Tổng trụ sở'
     WHEN SP_FORMAT_REGRP_MAPCODE(ma_nhom) LIKE '000018.000019%' THEN 'B. Tổng chi nhánh'
     WHEN  ma_nhom is NULL AND brid LIKE '000%' THEN 'A. Tổng trụ sở'
     WHEN  ma_nhom is NULL AND brid LIKE '010%' THEN 'B. Tổng chi nhánh'
     WHEN brid is NULL AND  afacctno LIKE '000%' THEN 'A. Tổng trụ sở'
     WHEN  brid is NULL AND  afacctno LIKE '010%' THEN 'B. Tổng chi nhánh'
     ELSE 'sid'
END nhom_cha,
case   -- WHEN SP_FORMAT_REGRP_MAPCODE(regrp.autoid) = '000018' THEN '---'
    WHEN SP_FORMAT_REGRP_MAPCODE(ma_nhom) = '000018.000017' THEN 'A. Tổng trụ sở'
    WHEN SP_FORMAT_REGRP_MAPCODE(ma_nhom) = '000018.000019' THEN 'B. Tổng chi nhánh'
    WHEN SP_FORMAT_REGRP_MAPCODE(ma_nhom) LIKE '000018.000017.000001.000014%' THEN '4. Đại lý Sông Lam'
    WHEN SP_FORMAT_REGRP_MAPCODE(ma_nhom) LIKE '000018.000017.000001%' THEN '1. Giao dịch trụ sở'

    WHEN SP_FORMAT_REGRP_MAPCODE(ma_nhom) LIKE '000018.000017.000021%' THEN '3. Khách hàng tổ chức'
    WHEN SP_FORMAT_REGRP_MAPCODE(ma_nhom) LIKE '000018.000017.000020%' THEN '5. Phòng giao dịch Mỹ Ðình'
    WHEN SP_FORMAT_REGRP_MAPCODE(ma_nhom) LIKE '000018.000017.000005%' THEN '6. Phòng giao dịch 94 Bà Triệu'
    WHEN SP_FORMAT_REGRP_MAPCODE(ma_nhom) LIKE '000018.000019.000016%' THEN '2. Khách hàng TCCN'
    WHEN SP_FORMAT_REGRP_MAPCODE(ma_nhom) LIKE '000018.000019.000023%' THEN '1. Giao dịch CN'
    WHEN SP_FORMAT_REGRP_MAPCODE(ma_nhom) LIKE '000018.000019.000012%' THEN '1. Giao dịch CN'
    WHEN ma_nhom is NULL AND brid LIKE '000%' THEN '9.TK tự do va MG tự do'
    WHEN ma_nhom is NULL AND brid LIKE '010%' THEN '3.TK tự do va MG tự do'
    WHEN brid is NULL AND  afacctno LIKE '000%' THEN '9.TK tự do va MG tự do'
    WHEN brid is NULL AND  afacctno LIKE '010%' THEN '3.TK tự do va MG tự do'
    ELSE '8. Khách hàng khác'
END nhom_con,
case WHEN regrp.fullname IS NOT NULL THEN regrp.fullname
     WHEN brid is NOT NULL THEN 'MG tự do'
     WHEN brid is NULL THEN 'TK tự do'
END fullname ,SP_FORMAT_REGRP_MAPCODE(regrp.autoid) ma_nhom, hnx_up_GT,
hnx_up_DT, hose_GT ,hose_DT, b.refrecflnkid
,
V_HNX_UP_GT P_HNX_UP_GT, V_HNX_UP_DT P_HNX_UP_DT, V_HOSE_GT P_HOSE_GT, V_HOSE_DT P_HOSE_DT
FROM regrp,
(
SELECT  sum(CASE WHEN  sb.tradeplace IN ('002','005') THEN od.execamt ELSE 0 END) hnx_up_GT,
        sum(CASE WHEN  sb.tradeplace IN ('002','005') THEN od.feeacr ELSE 0 END) hnx_up_DT,
        sum(CASE WHEN  sb.tradeplace = '001' THEN od.execamt ELSE 0 END) hose_GT,
        sum(CASE WHEN  sb.tradeplace = '001' THEN od.feeacr ELSE 0 END) hose_DT,
         nhom.refrecflnkid
    FROM reaflnk kh, regrplnk nhom, sbsecurities sb,
         cfmast cf, afmast af,
        vw_odmast_all OD
    WHERE
         OD.afacctno = kh.afacctno
        AND od.afacctno = af.acctno AND af.custid = cf.custid
        AND sb.codeid = od.codeid
        AND sb.tradeplace IN ('001','002','005')
        AND kh.reacctno = nhom.reacctno
        AND OD.txdate <=  to_date(VT_DATE,'DD/MM/RRRR')
        AND OD.txdate >=  to_date(VF_DATE,'DD/MM/RRRR')
        AND OD.txdate <= nvl(kh.clstxdate -1 ,kh.todate)
        AND od.txdate >= kh.frdate
        AND OD.txdate <= nvl(nhom.clstxdate -1 ,nhom.todate)
        AND od.txdate >= nhom.frdate
        AND OD.deltd <> 'Y' AND OD.EXECTYPE IN ('NB','NS','MS')
        AND cf.custodycd NOT LIKE '___P%'
        GROUP BY  nhom.refrecflnkid
) b
WHERE regrp.autoid = b.refrecflnkid(+)

UNION ALL

SELECT 'A. Tổng trụ sở' nhom_cha,'7. Tự doanh' nhom_con,'Tự doanh' fullname,'Tự doanh' ma_nhom,
        sum(CASE WHEN  sb.tradeplace IN ('002','005') THEN od.execamt ELSE 0 END) hnx_up_GT,
        sum(CASE WHEN  sb.tradeplace IN ('002','005') THEN od.feeacr ELSE 0 END) hnx_up_DT,
        sum(CASE WHEN  sb.tradeplace = '001' THEN od.execamt ELSE 0 END) hose_GT,
        sum(CASE WHEN  sb.tradeplace = '001' THEN od.feeacr ELSE 0 END) hose_DT,
        99 refrecflnkid
        ,
V_HNX_UP_GT P_HNX_UP_GT, V_HNX_UP_DT P_HNX_UP_DT, V_HOSE_GT P_HOSE_GT, V_HOSE_DT P_HOSE_DT
FROM
(SELECT afacctno, codeid, execamt, feeacr, txdate FROM odmast WHERE deltd <> 'Y'
        UNION ALL
        SELECT afacctno, codeid, execamt, feeacr, txdate FROM odmasthist WHERE deltd <> 'Y') OD, cfmast cf, afmast af, sbsecurities sb
WHERE OD.afacctno = af.acctno AND cf.custid = af.custid AND cf.custodycd LIKE '___P%'
AND sb.codeid = OD.codeid
AND od.txdate >= VF_DATE AND od.txdate <= VT_DATE

)
WHERE hnx_up_GT +  hnx_up_DT +  hose_GT  + hose_DT <> 0
ORDER BY refrecflnkid*/
;
EXCEPTION
   WHEN OTHERS
   THEN
    --dbms_output.put_line(dbms_utility.format_error_backtrace);
      RETURN;
End;

 
 
 
 
/
