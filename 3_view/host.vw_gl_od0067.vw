SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW VW_GL_OD0067
(SETTDATE, TRADATE, P_BAMT, P_SAMT, C_BAMT, 
 C_SAMT, F_BAMT, F_SAMT, TRADEPLACE, SYMBOL, 
 BRID, TXBRID)
BEQUEATH DEFINER
AS 
SELECT   settdate settdate, tradate tradate,
             SUM (P_bamt) P_bamt, SUM (P_samt) P_samt, SUM (C_bamt) C_bamt,
             SUM (C_samt) C_samt, SUM (F_bamt) F_bamt, SUM (F_samt) F_samt,
            tradeplace, symbol,brid,txbrid
        FROM (
              SELECT af.brid, cleardate settdate, CASE when SUBSTR(orgorderid,1,4) <>'0101' THEN '0001' ELSE SUBSTR(orgorderid,1,4) END txbrid  ,
                       chd.txdate tradate, cf.custodycd, cf.fullname,to_char(sb.TRADEPLACE) TRADEPLACE, sb.symbol,
                   SUM (case when SUBSTR (cf.custodycd, 4, 1) = 'P' then  DECODE (chd.duetype, 'RS', chd.amt , 0) else 0 end) P_bamt,
                   SUM (case when SUBSTR (cf.custodycd, 4, 1) = 'P' then  DECODE (chd.duetype, 'RM', chd.amt , 0) else 0 end) P_samt,
                   SUM (case when SUBSTR (cf.custodycd, 4, 1) = 'C' then  DECODE (chd.duetype, 'RS', chd.amt , 0) else 0 end) C_bamt,
                   SUM (case when SUBSTR (cf.custodycd, 4, 1) = 'C' then  DECODE (chd.duetype, 'RM', chd.amt , 0) else 0 end) C_samt,
                   SUM (case when SUBSTR (cf.custodycd, 4, 1) = 'F' then  DECODE (chd.duetype, 'RS', chd.amt , 0) else 0 end) F_bamt,
                   SUM (case when SUBSTR (cf.custodycd, 4, 1) = 'F' then  DECODE (chd.duetype, 'RM', chd.amt , 0) else 0 end) F_samt
                  FROM (SELECT * FROM vw_stschd_tradeplace_all  ) chd,
                       afmast af,
                       cfmast cf,
                       (SELECT *
                          FROM sbsecurities
                         --WHERE   SECTYPE IN ('001','006','008')
                         ) sb
                 WHERE chd.deltd <> 'Y'
                   --AND SUBSTR (chd.acctno, 1, 10) = af.acctno
                   AND chd.afacctno= af.acctno
                   AND af.custid = cf.custid
                   AND chd.duetype IN ('RS', 'RM')
                 --  and chd.clearday =  3
--                   AND chd.txdate = TO_DATE (i_date, 'DD/MM/YYYY')
                  -- AND chd.acctno LIKE v_strafacctno
                   AND cf.custodycd LIKE '%'
                   AND CHD.TXDATE >='01-JAN-2014'
                   AND sb.codeid = chd.codeid
                   and cf.custatcom = 'Y'
              GROUP BY chd.cleardate,
                       cf.custodycd,
                       cf.fullname,
                       chd.txdate,
                       sb.TRADEPLACE,
                       sb.symbol,
                       af.brid,
                       SUBSTR(orgorderid,1,4)
                       )
      GROUP BY settdate,  tradate, tradeplace, symbol ,brid,txbrid
/
