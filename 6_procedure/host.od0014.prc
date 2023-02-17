SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE od0014 (
   PV_REFCURSOR             IN OUT   PKG_REPORT.REF_CURSOR,
   OPT                      IN       VARCHAR2,
   pv_BRID                  IN       VARCHAR2,
   TLGOUPS                  IN       VARCHAR2,
   TLSCOPE                  IN       VARCHAR2,
   F_DATE                   IN       VARCHAR2,
   T_DATE                    IN       VARCHAR2,
   PV_CUSTODYCD                      IN       VARCHAR2
   )
IS
-- MODIFICATION HISTORY
-- KHOP L?NH
-- PERSON      DATE    COMMENTS
-- NGOCVTT   15-JUN-15  CREATED
-- ---------   ------  -------------------------------------------
   V_STROPTION      VARCHAR2 (5);            -- A: ALL; B: BRANCH; S: SUB-BRANCH
   V_STRBRID        VARCHAR2 (4);            -- USED WHEN V_NUMOPTION > 0

   V_CUR_DATE       DATE ;
   V_STRCUSTODYCD   VARCHAR2 (200);
   v_taxrate        NUMBER;
   v_whtax              NUMBER;
-- DECLARE PROGRAM VARIABLES AS SHOWN ABOVE
BEGIN
   V_STROPTION := OPT;


   IF (V_STROPTION <> 'A') AND (pv_BRID <> 'ALL')
   THEN
      V_STRBRID := pv_BRID;
   ELSE
      V_STRBRID := '%%';
   END IF;

    -- GET REPORT'S PARAMETERS
   --
   IF (PV_CUSTODYCD <> 'ALL')
   THEN
      V_STRCUSTODYCD := PV_CUSTODYCD;
   ELSE
      V_STRCUSTODYCD := '%%';
   END IF;

       select to_number(varvalue) into v_taxrate  from sysvar where varname = 'ADVSELLDUTY';
        select to_number(varvalue) into v_whtax  from sysvar where varname = 'WHTAX';
   SELECT TO_DATE(VARVALUE ,'DD/MM/YYYY') INTO V_CUR_DATE FROM SYSVAR WHERE VARNAME ='CURRDATE';


   -- GET REPORT'S DATA
    OPEN PV_REFCURSOR
     FOR

SELECT IO.ORGORDERID,IO.CUSTODYCD,IO.SYMBOL,IO.BORS,IO.NORP,IO.MATCHQTTY,IO.MATCHPRICE,
      IO.TXTIME,IO.TXDATE,IO.TXDATE DATE_OD, IO.MATCHQTTY*IO.MATCHPRICE AMT,
      (CASE WHEN OD.execamt = 0 THEN 0 ELSE
           (CASE WHEN io.iodfeeacr = 0 and IO.Txdate = V_CUR_DATE  THEN ROUND(IO.matchqtty * io.matchprice * ODT.deffeerate / 100)
                 ELSE io.iodfeeacr END)
       END)
      FEE_AMT_DETAIL,
      (case when OD.execamt>0 and OD.feeacr=0  AND OD.TXDATE = V_CUR_DATE THEN  ODT.deffeerate
             when OD.execamt>0 and OD.feeacr=0  AND OD.TXDATE <> V_CUR_DATE THEN 0
           else
             (CASE WHEN (OD.execamt * OD.feeacr) = 0 THEN 0 ELSE
                 (CASE WHEN OD.TXDATE = V_CUR_DATE THEN round(100 * OD.feeacr/(OD.execamt),2)
                       ELSE ROUND((io.matchqtty * io.matchprice/OD.execamt * OD.feeacr)*100/ (IO.MATCHPRICE*IO.MATCHQTTY),2) END)
             END)
           end)  FEE_RATE,
      (CASE WHEN OD.EXECTYPE IN('NS','SS','MS') AND( CF.VAT = 'Y' OR cf.WHTAX='Y')  THEN
          (CASE WHEN IO.iodtaxsellamt<> 0 THEN IO.iodtaxsellamt
           ELSE (ROUND((IO.MATCHQTTY * IO.MATCHPRICE * (decode (CF.VAT,'Y',v_taxrate,'N',0) + decode (CF.WHTAX,'Y',v_whtax,'N',0))) /100) + NVL(sts.ARIGHT, 0)) END)
       else 0 end) taxsellamt
      FROM VW_IOD_ALL IO,VW_ODMAST_ALL OD, ODTYPE ODT, VW_STSCHD_ALL STS, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF
      WHERE IO.DELTD='N'
     -- AND SUBSTR(IO.CUSTODYCD,4,1)<>'P'
      AND OD.ORDERID=IO.ORGORDERID
      AND OD.ACTYPE=ODT.ACTYPE AND CF.CUSTODYCD=IO.CUSTODYCD
      AND STS.ORGORDERID=IO.ORGORDERID
      AND STS.DUETYPE IN ('SM','RM')
      AND IO.TXDATE BETWEEN TO_DATE(F_DATE,'DD/MM/YYYY') AND TO_DATE(T_DATE,'DD/MM/YYYY')
      AND IO.CUSTODYCD LIKE V_STRCUSTODYCD
      ORDER BY IO.TXDATE,IO.TXTIME,IO.CUSTODYCD,IO.SYMBOL,IO.ORGORDERID
;


EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;
-- PROCEDURE
 
 
 
 
/
