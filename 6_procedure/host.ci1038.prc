SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE ci1038 (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   pv_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2,
   I_BRID         IN       VARCHAR2,
   PV_CUSTODYCD   IN       VARCHAR2
     )
IS
--
-- PURPOSE: BRIEFLY EXPLAIN THE FUNCTIONALITY OF THE PROCEDURE
-- TONG HOP KET QUA KHOP LENH
-- MODIFICATION HISTORY
-- PERSON      DATE    COMMENTS
-- NAMNT   21-NOV-06  CREATED
--NGOCVTT   15/05/2015  EDIT
-- ---------   ------  -------------------------------------------
   V_STRSYMBOL          VARCHAR2 (20);

 CUR            PKG_REPORT.REF_CURSOR;
 V_BRID    VARCHAR2 (5);
 V_CUSTODYCD  VARCHAR2 (10);
-- DECLARE PROGRAM VARIABLES AS SHOWN ABOVE
BEGIN

IF  (I_BRID <> 'ALL')
THEN
      V_BRID := upper(I_BRID);
ELSE
   V_BRID := '%';
END IF;


IF  (PV_CUSTODYCD <> 'ALL')
THEN
   V_CUSTODYCD := upper(PV_CUSTODYCD);
ELSE
   V_CUSTODYCD := '%';
END IF;

 -- GET REPORT'S DATA

 OPEN PV_REFCURSOR
   FOR
SELECT * FROM (
SELECT CF.CUSTODYCD, CF.FULLNAME, CF.IDCODE, SUM( CASE WHEN CF.whtax = 'Y' THEN NVL(AMT,0)  ELSE 0 END )  AMT,
      SUM(CASE WHEN CF.whtax = 'Y' THEN NVL(NAMT,0)  ELSE 0 END   ) NAMT,
      (CASE WHEN CF.CUSTTYPE='I' AND CF.COUNTRY='234' THEN 'IN'
      WHEN CF.CUSTTYPE='B' AND CF.COUNTRY='234' THEN 'BN'
      WHEN CF.CUSTTYPE='I' AND CF.COUNTRY<>'234' THEN 'IO'
      WHEN CF.CUSTTYPE='B' AND CF.COUNTRY<>'234' THEN 'BO' ELSE '' END ) TYPE_KH,
      CF.CUSTTYPE,(CASE WHEN TAX.TLTXCD IN ('0066','8894','1137','2266') THEN 'A' ELSE 'B' END) TYPE_CI
FROM (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF,
     (
        SELECT CUSTID,(CASE WHEN TLTXCD='0066' AND TXCD='0011' THEN NAMT
           WHEN  TLTXCD in( '3350','1110') AND TXCD='0011' THEN NAMT
           WHEN  TLTXCD='8894' AND TXCD='0011' THEN NAMT
           WHEN  TLTXCD='1137' AND TXCD='0012' THEN -NAMT
           ELSE 0 END) AMT, TLTXCD,
          (CASE WHEN TLTXCD='0066'  AND TXCD='0011'  THEN NAMT/0.001
           WHEN  TLTXCD='3350' AND TXCD='0012' THEN NAMT
           WHEN  TLTXCD='1110' AND TXCD='0012' AND instr (trdesc,'l')>0  THEN NAMT
           WHEN  TLTXCD='8894' AND TXCD='0029' THEN NAMT
           ELSE 0 END) NAMT
        FROM VW_CITRAN_GEN
        WHERE TLTXCD in ('0066','3350','8894','1137','1110')
              AND TXCD in ('0011','0012','0029')
              AND TXDATE BETWEEN to_date(F_DATE,'DD/MM/YYYY') AND to_date(T_DATE,'DD/MM/YYYY')
      UNION ALL
         SELECT af.custid,  tax  amt, '2266' tltxcd ,tax/0.001 namt  FROM sesendout se,afmast af
         WHERE substr( se.acctno,1,10) = af.acctno
          AND TO_DATE( SUBSTR( id2266,1,10),'DD/MM/YYYY') BETWEEN to_date(F_DATE,'DD/MM/YYYY') AND to_date(T_DATE,'DD/MM/YYYY')
          AND deltd <>'Y'
      ) TAX
WHERE CF.CUSTID=TAX.CUSTID
      AND CF.BRID LIKE V_BRID
      AND CF.CUSTODYCD LIKE V_CUSTODYCD
      GROUP BY CF.CUSTODYCD, CF.FULLNAME, CF.IDCODE,CF.CUSTTYPE,CF.COUNTRY,
      (CASE WHEN TAX.TLTXCD IN ('0066','8894','1137','2266') THEN 'A' ELSE 'B' END)
      ) WHERE AMT<>0
ORDER BY CUSTODYCD, AMT;

/*SELECT  custodycd,fullname,idcode , SUM (amount) amount, SUM (tax)tax
 FROM (
SELECT   cf.custodycd,cf.fullname ,cf.idcode, sum( decode (gl.trans_type,'887801',gl.amount,0)) amount , sum(decode (gl.trans_type,'887802',gl.amount,0))tax
FROM gl_exp_tran gl, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf
WHERE gl.custodycd = cf.custodycd
AND gl.trans_type IN ('887801','887802')
AND gl.txdate >= to_date(F_DATE,'DD/MM/YYYY')
AND gl.txdate<=to_date(T_DATE,'DD/MM/YYYY')
AND GL.BRID LIKE V_BRID
GROUP BY  cf.custodycd,cf.idcode ,cf.fullname
UNION ALL
SELECT   cf.custodycd,cf.fullname ,cf.idcode, sum(od.execamt) amount , sum( gl.amount) tax
FROM gl_exp_tran gl, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf,vw_odmast_all od
WHERE gl.custodycd = cf.custodycd
AND gl.trans_type ='995601'
AND od.orderid = gl.reftran
AND gl.txdate >= to_date(F_DATE,'DD/MM/YYYY')
AND gl.txdate<=to_date(T_DATE,'DD/MM/YYYY')
AND GL.BRID LIKE V_BRID
GROUP BY  cf.custodycd,cf.idcode ,cf.fullname
UNION ALL
SELECT   cf.custodycd,cf.fullname ,cf.idcode, sum( gl.amount*1000) amount , sum(gl.amount)tax
FROM gl_exp_tran gl, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf
WHERE gl.custodycd = cf.custodycd
AND gl.trans_type IN ('1133004','1133023')
AND gl.txdate >= to_date(F_DATE,'DD/MM/YYYY')
AND gl.txdate<=to_date(T_DATE,'DD/MM/YYYY')
AND GL.BRID LIKE V_BRID
GROUP BY  cf.custodycd,cf.idcode ,cf.fullname
)
group BY  custodycd,fullname,idcode    ;*/

EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;                                                              -- PROCEDURE
 
/
