SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE cf2005_1(PV_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR,
                                     OPT          IN VARCHAR2,
                                     pv_BRID      IN VARCHAR2,
                                     TLGOUPS      IN VARCHAR2,
                                     TLSCOPE      IN VARCHAR2,
                                     F_DATE       IN VARCHAR2,
                                     T_DATE       IN VARCHAR2,
                                     PV_CUSTATCOM IN VARCHAR2) IS
  --

  V_STROPTION VARCHAR2(5); -- A: ALL; B: BRANCH; S: SUB-BRANCH
  V_STRBRID   VARCHAR2(40); -- USED WHEN V_NUMOPTION > 0
  V_INBRID    VARCHAR2(5); -- USED WHEN V_NUMOPTION > 0

  V_TODATE   DATE;
  V_FROMDATE DATE;

  v_DK_CN_NN        NUMBER;
  v_DK_TC_NN        NUMBER;
  v_DK_CN_TN        NUMBER;
  v_DK_TC_TN        NUMBER;
  v_TK_CN_NN_Credit NUMBER;
  v_TK_TC_NN_Credit NUMBER;
  v_TK_CN_TN_Credit NUMBER;
  v_TK_TC_TN_Credit NUMBER;
  v_TK_CN_NN_Debit  NUMBER;
  v_TK_TC_NN_Debit  NUMBER;
  v_TK_CN_TN_Debit  NUMBER;
  v_TK_TC_TN_Debit  NUMBER;
  v_CK_CN_NN        NUMBER;
  v_CK_TC_NN        NUMBER;
  v_CK_CN_TN        NUMBER;
  v_CK_TC_TN        NUMBER;

  v_strcustatcom varchar2(10);

  V_TK_CN_NN_Trade NUMBER;
  V_TK_TC_NN_Trade NUMBER;
  V_TK_CN_TN_Trade NUMBER;
  V_TK_TC_TN_Trade NUMBER;

  -- DECLARE PROGRAM VARIABLES AS SHOWN ABOVE

BEGIN
  -- INSERT INTO TEMP_BUG(TEXT) VALUES('CF0001');COMMIT;
  V_STROPTION := upper(OPT);
  V_INBRID    := pv_BRID;

  if (V_STROPTION = 'A') then
    V_STRBRID := '%';
  else
    if (V_STROPTION = 'B') then
      select br.BRID into V_STRBRID from brgrp br where br.brid = V_INBRID;
    else
      V_STRBRID := pv_BRID;
    end if;
  end if;

  V_FROMDATE := to_date(F_DATE, 'DD/MM/RRRR');
  V_TODATE   := to_date(T_DATE, 'DD/MM/RRRR');

  if PV_CUSTATCOM = 'Y' then
    V_strcustatcom := '%';
  else
    V_strcustatcom := 'Y';
  end if;
  OPEN PV_REFCURSOR FOR
    SELECT cf.fullname, cf.custodycd, cf.idcode, cf.iddate, cf.idplace
    
      FROM (select distinct cf.custid
              from vw_odmast_all od,
                   afmast af,
                   (SELECT *
                      FROM CFMAST
                     WHERE FNC_VALIDATE_SCOPE(BRID,
                                              CAREBY,
                                              TLSCOPE,
                                              pv_BRID,
                                              TLGOUPS) = 0
                       AND activests = 'Y') cf
             where od.txdate BETWEEN V_FROMDATE AND V_TODATE
               and od.execqtty <> 0
               and od.afacctno = af.acctno
               and af.custid = cf.custid
               AND cf.custatcom like V_strcustatcom) od,
           (SELECT *
              FROM CFMAST
             WHERE FNC_VALIDATE_SCOPE(BRID,
                                      CAREBY,
                                      TLSCOPE,
                                      pv_BRID,
                                      TLGOUPS) = 0
               AND activests = 'Y') cf
     WHERE od.custid = cf.custid
       AND CF.CLASS <> '000'
       AND cf.custatcom like V_strcustatcom;

EXCEPTION
  WHEN OTHERS THEN
  
    RETURN;
End;
 
 
 
 
/
