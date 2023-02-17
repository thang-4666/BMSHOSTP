SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "OD1021" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   pv_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   iMONTH         IN       VARCHAR2,
   TRADEPLACE     IN       VARCHAR2
       )
IS
--
-- PURPOSE: BRIEFLY EXPLAIN THE FUNCTIONALITY OF THE PROCEDURE
--
-- MODIFICATION HISTORY
-- PERSON      DATE    COMMENTS
-- ---------   ------  -------------------------------------------
   V_STROPTION        VARCHAR2 (5);       -- A: ALL; B: BRANCH; S: SUB-BRANCH
   V_STRTRADEPLACE              VARCHAR2 (8);
   V_STRI_BRID             VARCHAR2 (8);
   V_FDATE            DATE ;
   V_TDATE            DATE ;
   v_feeacr_cp NUMBER ;
   v_feeacr_Tp NUMBER ;
   v_feeamt_cp NUMBER ;
   v_feeamt_Tp NUMBER ;

   V_INBRID        VARCHAR2(4);
   V_STRBRID      VARCHAR2 (50);

-- DECLARE PROGRAM VARIABLES AS SHOWN ABOVE
BEGIN
-- INSERT INTO TEMP_BUG(TEXT) VALUES('CF0001');COMMIT;
    V_STROPTION := upper(OPT);
 V_INBRID := pv_BRID;
    if(V_STROPTION = 'A') then
        V_STRBRID := '%%';
    else
        if(V_STROPTION = 'B') then
            select br.mapid into V_STRBRID from brgrp br where  br.brid = V_INBRID;
        else
            V_STRBRID := V_INBRID;
        end if;
    end if;

V_FDATE := TO_DATE ('01'||iMONTH ,'DD/MM/YYYY') ;
V_TDATE := LAST_DAY( V_FDATE);

   IF (TRADEPLACE <> 'ALL')
   THEN
      V_STRTRADEPLACE := TRADEPLACE;
   ELSE
      V_STRTRADEPLACE := '%%';
   END IF;
/*
select sum(case when sb.sectype ='001' then feeacr else 0 end ) feeacr_cp
      ,sum(case when sb.sectype <>'001' then feeacr else 0 end )feeacr_tp
       into v_feeacr_cp,v_feeacr_tp
from vw_odmast_all  od , sbsecurities sb
where od.codeid = sb.codeid
and   getduedate(txdate,'B','000',clearday) BETWEEN V_FDATE AND V_TDATE ;

select sum(case when sb.sectype ='001' then feeacr else 0 end ) feeamt_cp
      ,sum(case when sb.sectype <>'001' then feeacr else 0 end )feeamt_tp
       into v_feeacr_cp,v_feeacr_tp
from vw_odmast_all  od , sbsecurities sb
where od.codeid = sb.codeid
and   getduedate(txdate,'B','000',clearday) > V_TDATE
and   txdate <= V_fDATE
 ;*/


select sum(case when sb.sectype ='001' then feeacr else 0 end ) feeacr_cp
      ,sum(case when sb.sectype <>'001' then feeacr else 0 end )feeacr_tp
       into v_feeacr_cp,v_feeacr_tp
from vw_odmast_tradeplace_all  od , sbsecurities sb,vw_stschd_all STS, afmast af, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0)  CF
where od.codeid = sb.codeid
and af.custid = cf.custid
AND OD.orderid = STS.orgorderid
AND STS.duetype IN ('RM','SM')
and od.tradeplace like V_STRTRADEPLACE
and  STS.cleardate BETWEEN V_FDATE AND V_TDATE
AND od.AFACCTNO=af.acctno
AND AF.ACTYPE NOT IN ('0000')
AND (af.brid LIKE V_STRBRID or instr(V_STRBRID,af.brid) <> 0 );


select sum(case when sb.sectype ='001' then feeacr else 0 end ) feeamt_cp
      ,sum(case when sb.sectype <>'001' then feeacr else 0 end )feeamt_tp
       into v_feeamt_cp,v_feeamt_tp
from vw_odmast_tradeplace_all  od , sbsecurities sb,vw_stschd_all STS, afmast af
where od.codeid = sb.codeid
AND OD.orderid = STS.orgorderid
AND STS.duetype IN ('RM','SM')
and od.tradeplace like V_STRTRADEPLACE
and  STS.cleardate > V_TDATE
and   od.txdate <= V_TDATE
AND od.AFACCTNO=af.acctno
AND AF.ACTYPE NOT IN ('0000')
AND (af.brid LIKE V_STRBRID or instr(V_STRBRID,af.brid) <> 0 );

OPEN PV_REFCURSOR
  FOR

SELECT * FROM
(
select v_feeacr_cp feeacr_cp,v_feeacr_tp feeacr_tp,v_feeamt_cp feeamt_cp,v_feeamt_tp feeamt_tp,
-- MUA
--TRONG NUOC
      --CO PHIEU -HOI SO
       SUM( case when iod.BORS='B' AND substr(iod.custodycd,4,1)<>'F' AND SUBSTR(CF.custid,1,2) ='00' AND NORP ='N' AND SB.sectype ='001' THEN iod.matchqtty ELSE 0 END) TT_QTTY_HS_N_CP_TN_B,
       SUM( case when iod.BORS='B' AND substr(iod.custodycd,4,1)<>'F' AND SUBSTR(CF.custid,1,2) ='00' AND NORP ='N' AND SB.sectype ='001' THEN iod.matchprice*iod.matchqtty ELSE 0 END ) TT_AMT_HS_N_CP_TN_B,
       SUM( case when iod.BORS='B' AND substr(iod.custodycd,4,1)<>'F' AND SUBSTR(CF.custid,1,2) ='00' AND NORP ='P' AND SB.sectype ='001' THEN iod.matchqtty ELSE 0 END) TT_QTTY_HS_P_CP_TN_B,
       SUM( case when iod.BORS='B' AND substr(iod.custodycd,4,1)<>'F' AND SUBSTR(CF.custid,1,2) ='00' AND NORP ='P' AND SB.sectype ='001' THEN iod.matchprice*iod.matchqtty ELSE 0 END ) TT_AMT_HS_P_CP_TN_B,
      --CO PHIEU -CHI NHANH
       SUM( case when iod.BORS='B' AND substr(iod.custodycd,4,1)<>'F' AND SUBSTR(CF.custid,1,2) ='01' AND NORP ='N' AND SB.sectype ='001' THEN iod.matchqtty ELSE 0 END) TT_QTTY_CN_N_CP_TN_B,
       SUM( case when iod.BORS='B' AND substr(iod.custodycd,4,1)<>'F' AND SUBSTR(CF.custid,1,2) ='01' AND NORP ='N' AND SB.sectype ='001' THEN iod.matchprice*iod.matchqtty ELSE 0 END ) TT_AMT_CN_N_CP_TN_B,
       SUM( case when iod.BORS='B' AND substr(iod.custodycd,4,1)<>'F' AND SUBSTR(CF.custid,1,2) ='01' AND NORP ='P' AND SB.sectype ='001' THEN iod.matchqtty ELSE 0 END) TT_QTTY_CN_P_CP_TN_B ,
       SUM( case when iod.BORS='B' AND substr(iod.custodycd,4,1)<>'F' AND SUBSTR(CF.custid,1,2) ='01' AND NORP ='P' AND SB.sectype ='001' THEN iod.matchprice*iod.matchqtty ELSE 0 END ) TT_AMT_CN_P_CP_TN_B,
      --TRAI PHIEU- HOI SO
       SUM( case when iod.BORS='B' AND substr(iod.custodycd,4,1)<>'F' AND SUBSTR(CF.custid,1,2) ='00'  AND SB.sectype IN('003','006') THEN iod.matchqtty ELSE 0 END) TT_QTTY_HS_TP_TN_B,
       SUM( case when iod.BORS='B' AND substr(iod.custodycd,4,1)<>'F' AND SUBSTR(CF.custid,1,2) ='00'  AND SB.sectype IN('003','006') THEN iod.matchprice*iod.matchqtty ELSE 0 END ) TT_AMT_HS_TP_TN_B,
      --TRAI PHIEU- HOI SO
       SUM( case when iod.BORS='B' AND substr(iod.custodycd,4,1)<>'F' AND SUBSTR(CF.custid,1,2) ='01'  AND SB.sectype IN('003','006') THEN iod.matchqtty ELSE 0 END) TT_QTTY_CN_TP_TN_B,
       SUM( case when iod.BORS='B' AND substr(iod.custodycd,4,1)<>'F' AND SUBSTR(CF.custid,1,2) ='01'  AND SB.sectype IN('003','006') THEN iod.matchprice*iod.matchqtty ELSE 0 END ) TT_AMT_CN_TP_TN_B,

--NUOC NGOAI
       SUM( case when iod.BORS='B' AND substr(iod.custodycd,4,1)='F' AND SUBSTR(CF.custid,1,2) ='00' AND NORP ='N' AND SB.sectype ='001' THEN iod.matchqtty ELSE 0 END) TT_QTTY_HS_N_CP_NN_B,
       SUM( case when iod.BORS='B' AND substr(iod.custodycd,4,1)='F' AND SUBSTR(CF.custid,1,2) ='00' AND NORP ='N' AND SB.sectype ='001' THEN iod.matchprice*iod.matchqtty ELSE 0 END ) TT_AMT_HS_N_CP_NN_B,
       SUM( case when iod.BORS='B' AND substr(iod.custodycd,4,1)='F' AND SUBSTR(CF.custid,1,2) ='00' AND NORP ='P' AND SB.sectype ='001' THEN iod.matchqtty ELSE 0 END) TT_QTTY_HS_P_CP_NN_B,
       SUM( case when iod.BORS='B' AND substr(iod.custodycd,4,1)='F' AND SUBSTR(CF.custid,1,2) ='00' AND NORP ='P' AND SB.sectype ='001' THEN iod.matchprice*iod.matchqtty ELSE 0 END ) TT_AMT_HS_P_CP_NN_B,
      --CO PHIEU -CHI NHANH
       SUM( case when iod.BORS='B' AND substr(iod.custodycd,4,1)='F' AND SUBSTR(CF.custid,1,2) ='01' AND NORP ='N' AND SB.sectype ='001' THEN iod.matchqtty ELSE 0 END) TT_QTTY_CN_N_CP_NN_B,
       SUM( case when iod.BORS='B' AND substr(iod.custodycd,4,1)='F' AND SUBSTR(CF.custid,1,2) ='01' AND NORP ='N' AND SB.sectype ='001' THEN iod.matchprice*iod.matchqtty ELSE 0 END ) TT_AMT_CN_N_CP_NN_B,
       SUM( case when iod.BORS='B' AND substr(iod.custodycd,4,1)='F' AND SUBSTR(CF.custid,1,2) ='01' AND NORP ='P' AND SB.sectype ='001' THEN iod.matchqtty ELSE 0 END) TT_QTTY_CN_P_CP_NN_B ,
       SUM( case when iod.BORS='B' AND substr(iod.custodycd,4,1)='F' AND SUBSTR(CF.custid,1,2) ='01' AND NORP ='P' AND SB.sectype ='001' THEN iod.matchprice*iod.matchqtty ELSE 0 END ) TT_AMT_CN_P_CP_NN_B,
      --TRAI PHIEU- HOI SO
       SUM( case when iod.BORS='B' AND substr(iod.custodycd,4,1)='F' AND SUBSTR(CF.custid,1,2) ='00'  AND SB.sectype IN('003','006') THEN iod.matchqtty ELSE 0 END) TT_QTTY_HS_TP_NN_B,
       SUM( case when iod.BORS='B' AND substr(iod.custodycd,4,1)='F' AND SUBSTR(CF.custid,1,2) ='00'  AND SB.sectype IN('003','006') THEN iod.matchprice*iod.matchqtty ELSE 0 END ) TT_AMT_HS_TP_NN_B,
      --TRAI PHIEU- HOI SO
       SUM( case when iod.BORS='B' AND substr(iod.custodycd,4,1)='F' AND SUBSTR(CF.custid,1,2) ='01'  AND SB.sectype IN('003','006') THEN iod.matchqtty ELSE 0 END) TT_QTTY_CN_TP_NN_B,
       SUM( case when iod.BORS='B' AND substr(iod.custodycd,4,1)='F' AND SUBSTR(CF.custid,1,2) ='01'  AND SB.sectype IN('003','006') THEN iod.matchprice*iod.matchqtty ELSE 0 END ) TT_AMT_CN_TP_NN_B,

       --BAN
       --

    SUM( case when iod.BORS='S' AND substr(iod.custodycd,4,1)<>'F' AND SUBSTR(CF.custid,1,2) ='00' AND NORP ='N' AND SB.sectype ='001' THEN iod.matchqtty ELSE 0 END) TT_QTTY_HS_N_CP_TN_S,
       SUM( case when iod.BORS='S' AND substr(iod.custodycd,4,1)<>'F' AND SUBSTR(CF.custid,1,2) ='00' AND NORP ='N' AND SB.sectype ='001' THEN iod.matchprice*iod.matchqtty ELSE 0 END ) TT_AMT_HS_N_CP_TN_S,
       SUM( case when iod.BORS='S' AND substr(iod.custodycd,4,1)<>'F' AND SUBSTR(CF.custid,1,2) ='00' AND NORP ='P' AND SB.sectype ='001' THEN iod.matchqtty ELSE 0 END) TT_QTTY_HS_P_CP_TN_S,
       SUM( case when iod.BORS='S' AND substr(iod.custodycd,4,1)<>'F' AND SUBSTR(CF.custid,1,2) ='00' AND NORP ='P' AND SB.sectype ='001' THEN iod.matchprice*iod.matchqtty ELSE 0 END ) TT_AMT_HS_P_CP_TN_S,
      --CO PHIEU -CHI NHANH
       SUM( case when iod.BORS='S' AND substr(iod.custodycd,4,1)<>'F' AND SUBSTR(CF.custid,1,2) ='01' AND NORP ='N' AND SB.sectype ='001' THEN iod.matchqtty ELSE 0 END) TT_QTTY_CN_N_CP_TN_S,
       SUM( case when iod.BORS='S' AND substr(iod.custodycd,4,1)<>'F' AND SUBSTR(CF.custid,1,2) ='01' AND NORP ='N' AND SB.sectype ='001' THEN iod.matchprice*iod.matchqtty ELSE 0 END ) TT_AMT_CN_N_CP_TN_S,
       SUM( case when iod.BORS='S' AND substr(iod.custodycd,4,1)<>'F' AND SUBSTR(CF.custid,1,2) ='01' AND NORP ='P' AND SB.sectype ='001' THEN iod.matchqtty ELSE 0 END) TT_QTTY_CN_P_CP_TN_S,
       SUM( case when iod.BORS='S' AND substr(iod.custodycd,4,1)<>'F' AND SUBSTR(CF.custid,1,2) ='01' AND NORP ='P' AND SB.sectype ='001' THEN iod.matchprice*iod.matchqtty ELSE 0 END ) TT_AMT_CN_P_CP_TN_S,
      --TRAI PHIEU- HOI SO
       SUM( case when iod.BORS='S' AND substr(iod.custodycd,4,1)<>'F' AND SUBSTR(CF.custid,1,2) ='00'  AND SB.sectype IN('003','006') THEN iod.matchqtty ELSE 0 END) TT_QTTY_HS_TP_TN_S,
       SUM( case when iod.BORS='S' AND substr(iod.custodycd,4,1)<>'F' AND SUBSTR(CF.custid,1,2) ='00'  AND SB.sectype IN('003','006') THEN iod.matchprice*iod.matchqtty ELSE 0 END ) TT_AMT_HS_TP_TN_S,
      --TRAI PHIEU- HOI SO
       SUM( case when iod.BORS='S' AND substr(iod.custodycd,4,1)<>'F' AND SUBSTR(CF.custid,1,2) ='01'  AND SB.sectype IN('003','006') THEN iod.matchqtty ELSE 0 END) TT_QTTY_CN_TP_TN_S,
       SUM( case when iod.BORS='S' AND substr(iod.custodycd,4,1)<>'F' AND SUBSTR(CF.custid,1,2) ='01'  AND SB.sectype IN('003','006') THEN iod.matchprice*iod.matchqtty ELSE 0 END ) TT_AMT_CN_TP_TN_S,

--NUOC NGOAI
       SUM( case when iod.BORS='S' AND substr(iod.custodycd,4,1)='F' AND SUBSTR(CF.custid,1,2) ='00' AND NORP ='N' AND SB.sectype ='001' THEN iod.matchqtty ELSE 0 END) TT_QTTY_HS_N_CP_NN_S,
       SUM( case when iod.BORS='S' AND substr(iod.custodycd,4,1)='F' AND SUBSTR(CF.custid,1,2) ='00' AND NORP ='N' AND SB.sectype ='001' THEN iod.matchprice*iod.matchqtty ELSE 0 END ) TT_AMT_HS_N_CP_NN_S,
       SUM( case when iod.BORS='S' AND substr(iod.custodycd,4,1)='F' AND SUBSTR(CF.custid,1,2) ='00' AND NORP ='P' AND SB.sectype ='001' THEN iod.matchqtty ELSE 0 END) TT_QTTY_HS_P_CP_NN_S,
       SUM( case when iod.BORS='S' AND substr(iod.custodycd,4,1)='F' AND SUBSTR(CF.custid,1,2) ='00' AND NORP ='P' AND SB.sectype ='001' THEN iod.matchprice*iod.matchqtty ELSE 0 END ) TT_AMT_HS_P_CP_NN_S,
      --CO PHIEU -CHI NHANH
       SUM( case when iod.BORS='S' AND substr(iod.custodycd,4,1)='F' AND SUBSTR(CF.custid,1,2) ='01' AND NORP ='N' AND SB.sectype ='001' THEN iod.matchqtty ELSE 0 END) TT_QTTY_CN_N_CP_NN_S,
       SUM( case when iod.BORS='S' AND substr(iod.custodycd,4,1)='F' AND SUBSTR(CF.custid,1,2) ='01' AND NORP ='N' AND SB.sectype ='001' THEN iod.matchprice*iod.matchqtty ELSE 0 END ) TT_AMT_CN_N_CP_NN_S,
       SUM( case when iod.BORS='S' AND substr(iod.custodycd,4,1)='F' AND SUBSTR(CF.custid,1,2) ='01' AND NORP ='P' AND SB.sectype ='001' THEN iod.matchqtty ELSE 0 END) TT_QTTY_CN_P_CP_NN_S,
       SUM( case when iod.BORS='S' AND substr(iod.custodycd,4,1)='F' AND SUBSTR(CF.custid,1,2) ='01' AND NORP ='P' AND SB.sectype ='001' THEN iod.matchprice*iod.matchqtty ELSE 0 END ) TT_AMT_CN_P_CP_NN_S,
      --TRAI PHIEU- HOI SO
       SUM( case when iod.BORS='S' AND substr(iod.custodycd,4,1)='F' AND SUBSTR(CF.custid,1,2) ='00'  AND SB.sectype IN('003','006') THEN iod.matchqtty ELSE 0 END) TT_QTTY_HS_TP_NN_S,
       SUM( case when iod.BORS='S' AND substr(iod.custodycd,4,1)='F' AND SUBSTR(CF.custid,1,2) ='00'  AND SB.sectype IN('003','006') THEN iod.matchprice*iod.matchqtty ELSE 0 END ) TT_AMT_HS_TP_NN_S,
      --TRAI PHIEU- HOI SO
       SUM( case when iod.BORS='S' AND substr(iod.custodycd,4,1)='F' AND SUBSTR(CF.custid,1,2) ='01'  AND SB.sectype IN('003','006') THEN iod.matchqtty ELSE 0 END) TT_QTTY_CN_TP_NN_S,
       SUM( case when iod.BORS='S' AND substr(iod.custodycd,4,1)='F' AND SUBSTR(CF.custid,1,2) ='01'  AND SB.sectype IN('003','006') THEN iod.matchprice*iod.matchqtty ELSE 0 END ) TT_AMT_CN_TP_NN_S

from vw_iod_tradeplace_all iod, sbsecurities sb,(SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf
where iod.codeid = sb.codeid and  iod.deltd <>'Y'
and iod.custodycd =cf.custodycd
and iod.tradeplace like V_STRTRADEPLACE
and   iod.txdate BETWEEN V_FDATE AND V_TDATE
AND (cf.brid LIKE V_STRBRID or instr(V_STRBRID,cf.brid) <> 0 )
)TT,
---DAU KY
(select
-- MUA
--TRONG NUOC
      --CO PHIEU -HOI SO
       SUM( case when iod.BORS='B' AND substr(iod.custodycd,4,1)<>'F' AND SUBSTR(CF.custid,1,2) ='00' AND NORP ='N' AND SB.sectype ='001' THEN iod.matchqtty ELSE 0 END) DK_QTTY_HS_N_CP_TN_B,
       SUM( case when iod.BORS='B' AND substr(iod.custodycd,4,1)<>'F' AND SUBSTR(CF.custid,1,2) ='00' AND NORP ='N' AND SB.sectype ='001' THEN iod.matchprice*iod.matchqtty ELSE 0 END ) DK_AMT_HS_N_CP_TN_B,
       SUM( case when iod.BORS='B' AND substr(iod.custodycd,4,1)<>'F' AND SUBSTR(CF.custid,1,2) ='00' AND NORP ='P' AND SB.sectype ='001' THEN iod.matchqtty ELSE 0 END) DK_QTTY_HS_P_CP_TN_B,
       SUM( case when iod.BORS='B' AND substr(iod.custodycd,4,1)<>'F' AND SUBSTR(CF.custid,1,2) ='00' AND NORP ='P' AND SB.sectype ='001' THEN iod.matchprice*iod.matchqtty ELSE 0 END ) DK_AMT_HS_P_CP_TN_B,
      --CO PHIEU -CHI NHANH
       SUM( case when iod.BORS='B' AND substr(iod.custodycd,4,1)<>'F' AND SUBSTR(CF.custid,1,2) ='01' AND NORP ='N' AND SB.sectype ='001' THEN iod.matchqtty ELSE 0 END) DK_QTTY_CN_N_CP_TN_B,
       SUM( case when iod.BORS='B' AND substr(iod.custodycd,4,1)<>'F' AND SUBSTR(CF.custid,1,2) ='01' AND NORP ='N' AND SB.sectype ='001' THEN iod.matchprice*iod.matchqtty ELSE 0 END ) DK_AMT_CN_N_CP_TN_B,
       SUM( case when iod.BORS='B' AND substr(iod.custodycd,4,1)<>'F' AND SUBSTR(CF.custid,1,2) ='01' AND NORP ='P' AND SB.sectype ='001' THEN iod.matchqtty ELSE 0 END) DK_QTTY_CN_P_CP_TN_B ,
       SUM( case when iod.BORS='B' AND substr(iod.custodycd,4,1)<>'F' AND SUBSTR(CF.custid,1,2) ='01' AND NORP ='P' AND SB.sectype ='001' THEN iod.matchprice*iod.matchqtty ELSE 0 END ) DK_AMT_CN_P_CP_TN_B,
      --TRAI PHIEU- HOI SO
       SUM( case when iod.BORS='B' AND substr(iod.custodycd,4,1)<>'F' AND SUBSTR(CF.custid,1,2) ='00'  AND SB.sectype IN('003','006') THEN iod.matchqtty ELSE 0 END) DK_QTTY_HS_TP_TN_B,
       SUM( case when iod.BORS='B' AND substr(iod.custodycd,4,1)<>'F' AND SUBSTR(CF.custid,1,2) ='00'  AND SB.sectype IN('003','006') THEN iod.matchprice*iod.matchqtty ELSE 0 END ) DK_AMT_HS_TP_TN_B,
      --TRAI PHIEU- HOI SO
       SUM( case when iod.BORS='B' AND substr(iod.custodycd,4,1)<>'F' AND SUBSTR(CF.custid,1,2) ='01'  AND SB.sectype IN('003','006') THEN iod.matchqtty ELSE 0 END) DK_QTTY_CN_TP_TN_B,
       SUM( case when iod.BORS='B' AND substr(iod.custodycd,4,1)<>'F' AND SUBSTR(CF.custid,1,2) ='01'  AND SB.sectype IN('003','006') THEN iod.matchprice*iod.matchqtty ELSE 0 END ) DK_AMT_CN_TP_TN_B,

--NUOC NGOAI
       SUM( case when iod.BORS='B' AND substr(iod.custodycd,4,1)='F' AND SUBSTR(CF.custid,1,2) ='00' AND NORP ='N' AND SB.sectype ='001' THEN iod.matchqtty ELSE 0 END) DK_QTTY_HS_N_CP_NN_B,
       SUM( case when iod.BORS='B' AND substr(iod.custodycd,4,1)='F' AND SUBSTR(CF.custid,1,2) ='00' AND NORP ='N' AND SB.sectype ='001' THEN iod.matchprice*iod.matchqtty ELSE 0 END ) DK_AMT_HS_N_CP_NN_B,
       SUM( case when iod.BORS='B' AND substr(iod.custodycd,4,1)='F' AND SUBSTR(CF.custid,1,2) ='00' AND NORP ='P' AND SB.sectype ='001' THEN iod.matchqtty ELSE 0 END) DK_QTTY_HS_P_CP_NN_B,
       SUM( case when iod.BORS='B' AND substr(iod.custodycd,4,1)='F' AND SUBSTR(CF.custid,1,2) ='00' AND NORP ='P' AND SB.sectype ='001' THEN iod.matchprice*iod.matchqtty ELSE 0 END ) DK_AMT_HS_P_CP_NN_B,
      --CO PHIEU -CHI NHANH
       SUM( case when iod.BORS='B' AND substr(iod.custodycd,4,1)='F' AND SUBSTR(CF.custid,1,2) ='01' AND NORP ='N' AND SB.sectype ='001' THEN iod.matchqtty ELSE 0 END) DK_QTTY_CN_N_CP_NN_B,
       SUM( case when iod.BORS='B' AND substr(iod.custodycd,4,1)='F' AND SUBSTR(CF.custid,1,2) ='01' AND NORP ='N' AND SB.sectype ='001' THEN iod.matchprice*iod.matchqtty ELSE 0 END ) DK_AMT_CN_N_CP_NN_B,
       SUM( case when iod.BORS='B' AND substr(iod.custodycd,4,1)='F' AND SUBSTR(CF.custid,1,2) ='01' AND NORP ='P' AND SB.sectype ='001' THEN iod.matchqtty ELSE 0 END) DK_QTTY_CN_P_CP_NN_B ,
       SUM( case when iod.BORS='B' AND substr(iod.custodycd,4,1)='F' AND SUBSTR(CF.custid,1,2) ='01' AND NORP ='P' AND SB.sectype ='001' THEN iod.matchprice*iod.matchqtty ELSE 0 END ) DK_AMT_CN_P_CP_NN_B,
      --TRAI PHIEU- HOI SO
       SUM( case when iod.BORS='B' AND substr(iod.custodycd,4,1)='F' AND SUBSTR(CF.custid,1,2) ='00'  AND SB.sectype IN('003','006') THEN iod.matchqtty ELSE 0 END) DK_QTTY_HS_TP_NN_B,
       SUM( case when iod.BORS='B' AND substr(iod.custodycd,4,1)='F' AND SUBSTR(CF.custid,1,2) ='00'  AND SB.sectype IN('003','006') THEN iod.matchprice*iod.matchqtty ELSE 0 END ) DK_AMT_HS_TP_NN_B,
      --TRAI PHIEU- HOI SO
       SUM( case when iod.BORS='B' AND substr(iod.custodycd,4,1)='F' AND SUBSTR(CF.custid,1,2) ='01'  AND SB.sectype IN('003','006') THEN iod.matchqtty ELSE 0 END) DK_QTTY_CN_TP_NN_B,
       SUM( case when iod.BORS='B' AND substr(iod.custodycd,4,1)='F' AND SUBSTR(CF.custid,1,2) ='01'  AND SB.sectype IN('003','006') THEN iod.matchprice*iod.matchqtty ELSE 0 END ) DK_AMT_CN_TP_NN_B,

       --BAN
       --

    SUM( case when iod.BORS='S' AND substr(iod.custodycd,4,1)<>'F' AND SUBSTR(CF.custid,1,2) ='00' AND NORP ='N' AND SB.sectype ='001' THEN iod.matchqtty ELSE 0 END) DK_QTTY_HS_N_CP_TN_S,
       SUM( case when iod.BORS='S' AND substr(iod.custodycd,4,1)<>'F' AND SUBSTR(CF.custid,1,2) ='00' AND NORP ='N' AND SB.sectype ='001' THEN iod.matchprice*iod.matchqtty ELSE 0 END ) DK_AMT_HS_N_CP_TN_S,
       SUM( case when iod.BORS='S' AND substr(iod.custodycd,4,1)<>'F' AND SUBSTR(CF.custid,1,2) ='00' AND NORP ='P' AND SB.sectype ='001' THEN iod.matchqtty ELSE 0 END) DK_QTTY_HS_P_CP_TN_S,
       SUM( case when iod.BORS='S' AND substr(iod.custodycd,4,1)<>'F' AND SUBSTR(CF.custid,1,2) ='00' AND NORP ='P' AND SB.sectype ='001' THEN iod.matchprice*iod.matchqtty ELSE 0 END ) DK_AMT_HS_P_CP_TN_S,
      --CO PHIEU -CHI NHANH
       SUM( case when iod.BORS='S' AND substr(iod.custodycd,4,1)<>'F' AND SUBSTR(CF.custid,1,2) ='01' AND NORP ='N' AND SB.sectype ='001' THEN iod.matchqtty ELSE 0 END) DK_QTTY_CN_N_CP_TN_S,
       SUM( case when iod.BORS='S' AND substr(iod.custodycd,4,1)<>'F' AND SUBSTR(CF.custid,1,2) ='01' AND NORP ='N' AND SB.sectype ='001' THEN iod.matchprice*iod.matchqtty ELSE 0 END ) DK_AMT_CN_N_CP_TN_S,
       SUM( case when iod.BORS='S' AND substr(iod.custodycd,4,1)<>'F' AND SUBSTR(CF.custid,1,2) ='01' AND NORP ='P' AND SB.sectype ='001' THEN iod.matchqtty ELSE 0 END) DK_QTTY_CN_P_CP_TN_S,
       SUM( case when iod.BORS='S' AND substr(iod.custodycd,4,1)<>'F' AND SUBSTR(CF.custid,1,2) ='01' AND NORP ='P' AND SB.sectype ='001' THEN iod.matchprice*iod.matchqtty ELSE 0 END ) DK_AMT_CN_P_CP_TN_S,
      --TRAI PHIEU- HOI SO
       SUM( case when iod.BORS='S' AND substr(iod.custodycd,4,1)<>'F' AND SUBSTR(CF.custid,1,2) ='00'  AND SB.sectype IN('003','006') THEN iod.matchqtty ELSE 0 END) DK_QTTY_HS_TP_TN_S,
       SUM( case when iod.BORS='S' AND substr(iod.custodycd,4,1)<>'F' AND SUBSTR(CF.custid,1,2) ='00'  AND SB.sectype IN('003','006') THEN iod.matchprice*iod.matchqtty ELSE 0 END ) DK_AMT_HS_TP_TN_S,
      --TRAI PHIEU- HOI SO
       SUM( case when iod.BORS='S' AND substr(iod.custodycd,4,1)<>'F' AND SUBSTR(CF.custid,1,2) ='01'  AND SB.sectype IN('003','006') THEN iod.matchqtty ELSE 0 END) DK_QTTY_CN_TP_TN_S,
       SUM( case when iod.BORS='S' AND substr(iod.custodycd,4,1)<>'F' AND SUBSTR(CF.custid,1,2) ='01'  AND SB.sectype IN('003','006') THEN iod.matchprice*iod.matchqtty ELSE 0 END ) DK_AMT_CN_TP_TN_S,

--NUOC NGOAI
       SUM( case when iod.BORS='S' AND substr(iod.custodycd,4,1)='F' AND SUBSTR(CF.custid,1,2) ='00' AND NORP ='N' AND SB.sectype ='001' THEN iod.matchqtty ELSE 0 END) DK_QTTY_HS_N_CP_NN_S,
       SUM( case when iod.BORS='S' AND substr(iod.custodycd,4,1)='F' AND SUBSTR(CF.custid,1,2) ='00' AND NORP ='N' AND SB.sectype ='001' THEN iod.matchprice*iod.matchqtty ELSE 0 END ) DK_AMT_HS_N_CP_NN_S,
       SUM( case when iod.BORS='S' AND substr(iod.custodycd,4,1)='F' AND SUBSTR(CF.custid,1,2) ='00' AND NORP ='P' AND SB.sectype ='001' THEN iod.matchqtty ELSE 0 END) DK_QTTY_HS_P_CP_NN_S,
       SUM( case when iod.BORS='S' AND substr(iod.custodycd,4,1)='F' AND SUBSTR(CF.custid,1,2) ='00' AND NORP ='P' AND SB.sectype ='001' THEN iod.matchprice*iod.matchqtty ELSE 0 END ) DK_AMT_HS_P_CP_NN_S,
      --CO PHIEU -CHI NHANH
       SUM( case when iod.BORS='S' AND substr(iod.custodycd,4,1)='F' AND SUBSTR(CF.custid,1,2) ='01' AND NORP ='N' AND SB.sectype ='001' THEN iod.matchqtty ELSE 0 END) DK_QTTY_CN_N_CP_NN_S,
       SUM( case when iod.BORS='S' AND substr(iod.custodycd,4,1)='F' AND SUBSTR(CF.custid,1,2) ='01' AND NORP ='N' AND SB.sectype ='001' THEN iod.matchprice*iod.matchqtty ELSE 0 END ) DK_AMT_CN_N_CP_NN_S,
       SUM( case when iod.BORS='S' AND substr(iod.custodycd,4,1)='F' AND SUBSTR(CF.custid,1,2) ='01' AND NORP ='P' AND SB.sectype ='001' THEN iod.matchqtty ELSE 0 END) DK_QTTY_CN_P_CP_NN_S,
       SUM( case when iod.BORS='S' AND substr(iod.custodycd,4,1)='F' AND SUBSTR(CF.custid,1,2) ='01' AND NORP ='P' AND SB.sectype ='001' THEN iod.matchprice*iod.matchqtty ELSE 0 END ) DK_AMT_CN_P_CP_NN_S,
      --TRAI PHIEU- HOI SO
       SUM( case when iod.BORS='S' AND substr(iod.custodycd,4,1)='F' AND SUBSTR(CF.custid,1,2) ='00'  AND SB.sectype IN('003','006') THEN iod.matchqtty ELSE 0 END) DK_QTTY_HS_TP_NN_S,
       SUM( case when iod.BORS='S' AND substr(iod.custodycd,4,1)='F' AND SUBSTR(CF.custid,1,2) ='00'  AND SB.sectype IN('003','006') THEN iod.matchprice*iod.matchqtty ELSE 0 END ) DK_AMT_HS_TP_NN_S,
      --TRAI PHIEU- HOI SO
       SUM( case when iod.BORS='S' AND substr(iod.custodycd,4,1)='F' AND SUBSTR(CF.custid,1,2) ='01'  AND SB.sectype IN('003','006') THEN iod.matchqtty ELSE 0 END) DK_QTTY_CN_TP_NN_S,
       SUM( case when iod.BORS='S' AND substr(iod.custodycd,4,1)='F' AND SUBSTR(CF.custid,1,2) ='01'  AND SB.sectype IN('003','006') THEN iod.matchprice*iod.matchqtty ELSE 0 END ) DK_AMT_CN_TP_NN_S
from vw_iod_tradeplace_all iod, sbsecurities sb,(SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf
where iod.codeid = sb.codeid and  iod.deltd <>'Y'
and iod.tradeplace like V_STRTRADEPLACE
and iod.custodycd =cf.custodycd
and  iod.txdate <  V_FDATE
and   iod.txdate >= TO_DATE ('01/01/'|| substr(IMONTH,4),'DD/MM/YYYY')
AND (cf.brid LIKE V_STRBRID or instr(V_STRBRID,cf.brid) <> 0 )
)DK,
(
select
-- MUA
--TRONG NUOC
      --CO PHIEU -HOI SO
       SUM( case when iod.BORS='B' AND substr(iod.custodycd,4,1)<>'F' AND SUBSTR(CF.custid,1,2) ='00' AND NORP ='N' AND SB.sectype ='001' THEN iod.matchqtty ELSE 0 END) CK_QTTY_HS_N_CP_TN_B,
       SUM( case when iod.BORS='B' AND substr(iod.custodycd,4,1)<>'F' AND SUBSTR(CF.custid,1,2) ='00' AND NORP ='N' AND SB.sectype ='001' THEN iod.matchprice*iod.matchqtty ELSE 0 END ) CK_AMT_HS_N_CP_TN_B,
       SUM( case when iod.BORS='B' AND substr(iod.custodycd,4,1)<>'F' AND SUBSTR(CF.custid,1,2) ='00' AND NORP ='P' AND SB.sectype ='001' THEN iod.matchqtty ELSE 0 END) CK_QTTY_HS_P_CP_TN_B,
       SUM( case when iod.BORS='B' AND substr(iod.custodycd,4,1)<>'F' AND SUBSTR(CF.custid,1,2) ='00' AND NORP ='P' AND SB.sectype ='001' THEN iod.matchprice*iod.matchqtty ELSE 0 END ) CK_AMT_HS_P_CP_TN_B,
      --CO PHIEU -CHI NHANH
       SUM( case when iod.BORS='B' AND substr(iod.custodycd,4,1)<>'F' AND SUBSTR(CF.custid,1,2) ='01' AND NORP ='N' AND SB.sectype ='001' THEN iod.matchqtty ELSE 0 END) CK_QTTY_CN_N_CP_TN_B,
       SUM( case when iod.BORS='B' AND substr(iod.custodycd,4,1)<>'F' AND SUBSTR(CF.custid,1,2) ='01' AND NORP ='N' AND SB.sectype ='001' THEN iod.matchprice*iod.matchqtty ELSE 0 END ) CK_AMT_CN_N_CP_TN_B,
       SUM( case when iod.BORS='B' AND substr(iod.custodycd,4,1)<>'F' AND SUBSTR(CF.custid,1,2) ='01' AND NORP ='P' AND SB.sectype ='001' THEN iod.matchqtty ELSE 0 END) CK_QTTY_CN_P_CP_TN_B ,
       SUM( case when iod.BORS='B' AND substr(iod.custodycd,4,1)<>'F' AND SUBSTR(CF.custid,1,2) ='01' AND NORP ='P' AND SB.sectype ='001' THEN iod.matchprice*iod.matchqtty ELSE 0 END ) CK_AMT_CN_P_CP_TN_B,
      --TRAI PHIEU- HOI SO
       SUM( case when iod.BORS='B' AND substr(iod.custodycd,4,1)<>'F' AND SUBSTR(CF.custid,1,2) ='00'  AND SB.sectype IN('003','006') THEN iod.matchqtty ELSE 0 END) CK_QTTY_HS_TP_TN_B,
       SUM( case when iod.BORS='B' AND substr(iod.custodycd,4,1)<>'F' AND SUBSTR(CF.custid,1,2) ='00'  AND SB.sectype IN('003','006') THEN iod.matchprice*iod.matchqtty ELSE 0 END ) CK_AMT_HS_TP_TN_B,
      --TRAI PHIEU- HOI SO
       SUM( case when iod.BORS='B' AND substr(iod.custodycd,4,1)<>'F' AND SUBSTR(CF.custid,1,2) ='01'  AND SB.sectype IN('003','006') THEN iod.matchqtty ELSE 0 END) CK_QTTY_CN_TP_TN_B,
       SUM( case when iod.BORS='B' AND substr(iod.custodycd,4,1)<>'F' AND SUBSTR(CF.custid,1,2) ='01'  AND SB.sectype IN('003','006') THEN iod.matchprice*iod.matchqtty ELSE 0 END ) CK_AMT_CN_TP_TN_B,

--NUOC NGOAI
       SUM( case when iod.BORS='B' AND substr(iod.custodycd,4,1)='F' AND SUBSTR(CF.custid,1,2) ='00' AND NORP ='N' AND SB.sectype ='001' THEN iod.matchqtty ELSE 0 END) CK_QTTY_HS_N_CP_NN_B,
       SUM( case when iod.BORS='B' AND substr(iod.custodycd,4,1)='F' AND SUBSTR(CF.custid,1,2) ='00' AND NORP ='N' AND SB.sectype ='001' THEN iod.matchprice*iod.matchqtty ELSE 0 END ) CK_AMT_HS_N_CP_NN_B,
       SUM( case when iod.BORS='B' AND substr(iod.custodycd,4,1)='F' AND SUBSTR(CF.custid,1,2) ='00' AND NORP ='P' AND SB.sectype ='001' THEN iod.matchqtty ELSE 0 END) CK_QTTY_HS_P_CP_NN_B,
       SUM( case when iod.BORS='B' AND substr(iod.custodycd,4,1)='F' AND SUBSTR(CF.custid,1,2) ='00' AND NORP ='P' AND SB.sectype ='001' THEN iod.matchprice*iod.matchqtty ELSE 0 END ) CK_AMT_HS_P_CP_NN_B,
      --CO PHIEU -CHI NHANH
       SUM( case when iod.BORS='B' AND substr(iod.custodycd,4,1)='F' AND SUBSTR(CF.custid,1,2) ='01' AND NORP ='N' AND SB.sectype ='001' THEN iod.matchqtty ELSE 0 END) CK_QTTY_CN_N_CP_NN_B,
       SUM( case when iod.BORS='B' AND substr(iod.custodycd,4,1)='F' AND SUBSTR(CF.custid,1,2) ='01' AND NORP ='N' AND SB.sectype ='001' THEN iod.matchprice*iod.matchqtty ELSE 0 END ) CK_AMT_CN_N_CP_NN_B,
       SUM( case when iod.BORS='B' AND substr(iod.custodycd,4,1)='F' AND SUBSTR(CF.custid,1,2) ='01' AND NORP ='P' AND SB.sectype ='001' THEN iod.matchqtty ELSE 0 END) CK_QTTY_CN_P_CP_NN_B ,
       SUM( case when iod.BORS='B' AND substr(iod.custodycd,4,1)='F' AND SUBSTR(CF.custid,1,2) ='01' AND NORP ='P' AND SB.sectype ='001' THEN iod.matchprice*iod.matchqtty ELSE 0 END ) CK_AMT_CN_P_CP_NN_B,
      --TRAI PHIEU- HOI SO
       SUM( case when iod.BORS='B' AND substr(iod.custodycd,4,1)='F' AND SUBSTR(CF.custid,1,2) ='00'  AND SB.sectype IN('003','006') THEN iod.matchqtty ELSE 0 END) CK_QTTY_HS_TP_NN_B,
       SUM( case when iod.BORS='B' AND substr(iod.custodycd,4,1)='F' AND SUBSTR(CF.custid,1,2) ='00'  AND SB.sectype IN('003','006') THEN iod.matchprice*iod.matchqtty ELSE 0 END ) CK_AMT_HS_TP_NN_B,
      --TRAI PHIEU- HOI SO
       SUM( case when iod.BORS='B' AND substr(iod.custodycd,4,1)='F' AND SUBSTR(CF.custid,1,2) ='01'  AND SB.sectype IN('003','006') THEN iod.matchqtty ELSE 0 END) CK_QTTY_CN_TP_NN_B,
       SUM( case when iod.BORS='B' AND substr(iod.custodycd,4,1)='F' AND SUBSTR(CF.custid,1,2) ='01'  AND SB.sectype IN('003','006') THEN iod.matchprice*iod.matchqtty ELSE 0 END ) CK_AMT_CN_TP_NN_B,

       --BAN
       --

    SUM( case when iod.BORS='S' AND substr(iod.custodycd,4,1)<>'F' AND SUBSTR(CF.custid,1,2) ='00' AND NORP ='N' AND SB.sectype ='001' THEN iod.matchqtty ELSE 0 END) CK_QTTY_HS_N_CP_TN_S,
       SUM( case when iod.BORS='S' AND substr(iod.custodycd,4,1)<>'F' AND SUBSTR(CF.custid,1,2) ='00' AND NORP ='N' AND SB.sectype ='001' THEN iod.matchprice*iod.matchqtty ELSE 0 END ) CK_AMT_HS_N_CP_TN_S,
       SUM( case when iod.BORS='S' AND substr(iod.custodycd,4,1)<>'F' AND SUBSTR(CF.custid,1,2) ='00' AND NORP ='P' AND SB.sectype ='001' THEN iod.matchqtty ELSE 0 END) CK_QTTY_HS_P_CP_TN_S,
       SUM( case when iod.BORS='S' AND substr(iod.custodycd,4,1)<>'F' AND SUBSTR(CF.custid,1,2) ='00' AND NORP ='P' AND SB.sectype ='001' THEN iod.matchprice*iod.matchqtty ELSE 0 END ) CK_AMT_HS_P_CP_TN_S,
      --CO PHIEU -CHI NHANH
       SUM( case when iod.BORS='S' AND substr(iod.custodycd,4,1)<>'F' AND SUBSTR(CF.custid,1,2) ='01' AND NORP ='N' AND SB.sectype ='001' THEN iod.matchqtty ELSE 0 END) CK_QTTY_CN_N_CP_TN_S,
       SUM( case when iod.BORS='S' AND substr(iod.custodycd,4,1)<>'F' AND SUBSTR(CF.custid,1,2) ='01' AND NORP ='N' AND SB.sectype ='001' THEN iod.matchprice*iod.matchqtty ELSE 0 END ) CK_AMT_CN_N_CP_TN_S,
       SUM( case when iod.BORS='S' AND substr(iod.custodycd,4,1)<>'F' AND SUBSTR(CF.custid,1,2) ='01' AND NORP ='P' AND SB.sectype ='001' THEN iod.matchqtty ELSE 0 END) CK_QTTY_CN_P_CP_TN_S,
       SUM( case when iod.BORS='S' AND substr(iod.custodycd,4,1)<>'F' AND SUBSTR(CF.custid,1,2) ='01' AND NORP ='P' AND SB.sectype ='001' THEN iod.matchprice*iod.matchqtty ELSE 0 END ) CK_AMT_CN_P_CP_TN_S,
      --TRAI PHIEU- HOI SO
       SUM( case when iod.BORS='S' AND substr(iod.custodycd,4,1)<>'F' AND SUBSTR(CF.custid,1,2) ='00'  AND SB.sectype IN('003','006') THEN iod.matchqtty ELSE 0 END) CK_QTTY_HS_TP_TN_S,
       SUM( case when iod.BORS='S' AND substr(iod.custodycd,4,1)<>'F' AND SUBSTR(CF.custid,1,2) ='00'  AND SB.sectype IN('003','006') THEN iod.matchprice*iod.matchqtty ELSE 0 END ) CK_AMT_HS_TP_TN_S,
      --TRAI PHIEU- HOI SO
       SUM( case when iod.BORS='S' AND substr(iod.custodycd,4,1)<>'F' AND SUBSTR(CF.custid,1,2) ='01'  AND SB.sectype IN('003','006') THEN iod.matchqtty ELSE 0 END) CK_QTTY_CN_TP_TN_S,
       SUM( case when iod.BORS='S' AND substr(iod.custodycd,4,1)<>'F' AND SUBSTR(CF.custid,1,2) ='01'  AND SB.sectype IN('003','006') THEN iod.matchprice*iod.matchqtty ELSE 0 END ) CK_AMT_CN_TP_TN_S,

--NUOC NGOAI
       SUM( case when iod.BORS='S' AND substr(iod.custodycd,4,1)='F' AND SUBSTR(CF.custid,1,2) ='00' AND NORP ='N' AND SB.sectype ='001' THEN iod.matchqtty ELSE 0 END) CK_QTTY_HS_N_CP_NN_S,
       SUM( case when iod.BORS='S' AND substr(iod.custodycd,4,1)='F' AND SUBSTR(CF.custid,1,2) ='00' AND NORP ='N' AND SB.sectype ='001' THEN iod.matchprice*iod.matchqtty ELSE 0 END ) CK_AMT_HS_N_CP_NN_S,
       SUM( case when iod.BORS='S' AND substr(iod.custodycd,4,1)='F' AND SUBSTR(CF.custid,1,2) ='00' AND NORP ='P' AND SB.sectype ='001' THEN iod.matchqtty ELSE 0 END) CK_QTTY_HS_P_CP_NN_S,
       SUM( case when iod.BORS='S' AND substr(iod.custodycd,4,1)='F' AND SUBSTR(CF.custid,1,2) ='00' AND NORP ='P' AND SB.sectype ='001' THEN iod.matchprice*iod.matchqtty ELSE 0 END ) CK_AMT_HS_P_CP_NN_S,
      --CO PHIEU -CHI NHANH
       SUM( case when iod.BORS='S' AND substr(iod.custodycd,4,1)='F' AND SUBSTR(CF.custid,1,2) ='01' AND NORP ='N' AND SB.sectype ='001' THEN iod.matchqtty ELSE 0 END) CK_QTTY_CN_N_CP_NN_S,
       SUM( case when iod.BORS='S' AND substr(iod.custodycd,4,1)='F' AND SUBSTR(CF.custid,1,2) ='01' AND NORP ='N' AND SB.sectype ='001' THEN iod.matchprice*iod.matchqtty ELSE 0 END ) CK_AMT_CN_N_CP_NN_S,
       SUM( case when iod.BORS='S' AND substr(iod.custodycd,4,1)='F' AND SUBSTR(CF.custid,1,2) ='01' AND NORP ='P' AND SB.sectype ='001' THEN iod.matchqtty ELSE 0 END) CK_QTTY_CN_P_CP_NN_S,
       SUM( case when iod.BORS='S' AND substr(iod.custodycd,4,1)='F' AND SUBSTR(CF.custid,1,2) ='01' AND NORP ='P' AND SB.sectype ='001' THEN iod.matchprice*iod.matchqtty ELSE 0 END ) CK_AMT_CN_P_CP_NN_S,
      --TRAI PHIEU- HOI SO
       SUM( case when iod.BORS='S' AND substr(iod.custodycd,4,1)='F' AND SUBSTR(CF.custid,1,2) ='00'  AND SB.sectype IN('003','006') THEN iod.matchqtty ELSE 0 END) CK_QTTY_HS_TP_NN_S,
       SUM( case when iod.BORS='S' AND substr(iod.custodycd,4,1)='F' AND SUBSTR(CF.custid,1,2) ='00'  AND SB.sectype IN('003','006') THEN iod.matchprice*iod.matchqtty ELSE 0 END ) CK_AMT_HS_TP_NN_S,
      --TRAI PHIEU- HOI SO
       SUM( case when iod.BORS='S' AND substr(iod.custodycd,4,1)='F' AND SUBSTR(CF.custid,1,2) ='01'  AND SB.sectype IN('003','006') THEN iod.matchqtty ELSE 0 END) CK_QTTY_CN_TP_NN_S,
       SUM( case when iod.BORS='S' AND substr(iod.custodycd,4,1)='F' AND SUBSTR(CF.custid,1,2) ='01'  AND SB.sectype IN('003','006') THEN iod.matchprice*iod.matchqtty ELSE 0 END ) CK_AMT_CN_TP_NN_S
from vw_iod_tradeplace_all iod, sbsecurities sb,(SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf
where iod.codeid = sb.codeid and  iod.deltd <>'Y'
and iod.custodycd =cf.custodycd
and iod.tradeplace like V_STRTRADEPLACE
and iod.txdate >= TO_DATE ('01/01/'|| substr(IMONTH,4),'DD/MM/YYYY')
and iod.txdate <= V_TDATE
AND (cf.brid LIKE V_STRBRID or instr(V_STRBRID,Cf.brid) <> 0 )
--and   iod.txdate <= TO_DATE ('31/12/'|| substr(IMONTH,4),'DD/MM/YYYY')

)CK;
EXCEPTION
   WHEN OTHERS
   THEN

      RETURN;
End;

 
 
 
 
/
