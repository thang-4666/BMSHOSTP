SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "CI0004"(PV_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR,
                                     OPT          IN VARCHAR2,
                                     pv_BRID      IN VARCHAR2,
                                     TLGOUPS      IN VARCHAR2,
                                     TLSCOPE      IN VARCHAR2,
                                     F_DATE       IN VARCHAR2,
                                     T_DATE       IN VARCHAR2,
                                     PV_CUSTODYCD IN VARCHAR2,
                                     PV_AFACCTNO  IN VARCHAR2,
                                     MAKER        IN VARCHAR2,
                                     CHECKER      IN VARCHAR2,
                                     I_BRIDGD     IN VARCHAR2,

                                      PV_TLTXCD       IN VARCHAR2,
                                       PV_STATUS       IN VARCHAR2,
                                      TLID         IN VARCHAR2
                                     ) IS

  -- MODIFICATION HISTORY
  -- BAO CAO SO DU PHONG TOA TIEN
  -- PERSON   DATE  COMMENTS
  -- QUOCTA  10-01-2012  CREATED
  -- ---------   ------  -------------------------------------------
  V_STROPTION VARCHAR2(5); -- A: ALL; B: BRANCH; S: SUB-BRANCH
  V_STRBRID   VARCHAR2(40); -- USED WHEN V_NUMOPTION > 0
  V_INBRID    VARCHAR2(4);
  V_FDATE     DATE;
  V_TDATE     DATE;
  V_CUSTODYCD VARCHAR2(100);
  V_AFACCTNO  VARCHAR2(100);

  V_CRRDATE  DATE;
  V_STRTLID  VARCHAR2(6);
  V_BRNAME   VARCHAR2(1000);
  V_I_BRIDGD VARCHAR2(20);

  V_MAKER   VARCHAR2(100);
  V_CHECKER VARCHAR2(100);
  v_status  VARCHAR2(100);
  v_tltxcd  VARCHAR2(100);

BEGIN

  V_STROPTION := OPT;
  V_INBRID    := pv_BRID;
  V_STRTLID   := TLID;
  IF V_STROPTION = 'A' THEN
    V_STRBRID := '%';
  ELSIF V_STROPTION = 'B' then
    select brgrp.mapid
      into V_STRBRID
      from brgrp
     where brgrp.brid = V_INBRID;
  else
    V_STRBRID := V_INBRID;
  END IF;

  -- GET REPORT'S PARAMETERS
  IF (PV_CUSTODYCD <> 'ALL' OR PV_CUSTODYCD <> '') THEN
    V_CUSTODYCD := PV_CUSTODYCD;
  ELSE
    V_CUSTODYCD := '%';
  END IF;

  IF (PV_AFACCTNO <> 'ALL' OR PV_AFACCTNO <> '') THEN
    V_AFACCTNO := PV_AFACCTNO;
  ELSE
    V_AFACCTNO := '%';
  END IF;

  -----------------------
  IF (MAKER <> 'ALL') THEN
    V_MAKER := MAKER;
  ELSE
    V_MAKER := '%';
  END IF;

  IF (CHECKER <> 'ALL') THEN
    V_CHECKER := CHECKER;
  ELSE
    V_CHECKER := '%';
  END IF;
  IF (PV_TLTXCD <> 'ALL') THEN
    V_TLTXCD := PV_TLTXCD;
  ELSE
    V_TLTXCD := '%';
  END IF;
  IF (PV_STATUS <> 'ALL') THEN
    V_STATUS := PV_STATUS;
  ELSE
    V_STATUS := '%';
  END IF;
  -----------------------
  IF (I_BRIDGD <> 'ALL' OR I_BRIDGD <> '') THEN
    V_I_BRIDGD := I_BRIDGD;
  ELSE
    V_I_BRIDGD := '%%';
  END IF;

  IF (I_BRIDGD <> 'ALL' OR I_BRIDGD <> '') THEN
    BEGIN
      SELECT BRNAME INTO V_BRNAME FROM BRGRP WHERE BRID LIKE I_BRIDGD;
    END;
  ELSE
    V_BRNAME := ' To�n c�ng ty ';
  END IF;

  V_FDATE := TO_DATE(F_DATE, SYSTEMNUMS.C_DATE_FORMAT);
  V_TDATE := TO_DATE(T_DATE, SYSTEMNUMS.C_DATE_FORMAT);

  SELECT TO_DATE(SY.VARVALUE, SYSTEMNUMS.C_DATE_FORMAT)
    INTO V_CRRDATE
    FROM SYSVAR SY
   WHERE SY.VARNAME = 'CURRDATE'
     AND SY.GRNAME = 'SYSTEM';

  OPEN PV_REFCURSOR FOR

    SELECT cf.*,tl.BUSDATE,tl.TLTXCD,tl.usermake tlid,tl.userduyet offid
      FROM (SELECT cf.status,
                   CF.CUSTID,
                   CF.BRID,
                   CF.PRODUC,
                   CF.CUSTODYCD,
                   CF.FULLNAME,
                   CF.ACCTNO AFACCTNO,
                   (CIBAL.EMKAMT - NVL(CI_MOVE_FR_CRR.CI_EMKAMT_FR_CRR, 0)) EMKAMT_BEGIN_BAL,
                   NVL(CI_MOVE_FR_TD.CI_EMKAMT_LOCK, 0) CI_EMKAMT_LOCK,
                   NVL(CI_MOVE_FR_TD.CI_EMKAMT_UNLOCK, 0) CI_EMKAMT_UNLOCK,
                   (CIBAL.EMKAMT - NVL(CI_MOVE_FR_CRR.CI_EMKAMT_FR_CRR, 0)) +
                   (NVL(CI_MOVE_FR_TD.CI_EMKAMT_LOCK, 0)) -
                   (NVL(CI_MOVE_FR_TD.CI_EMKAMT_UNLOCK, 0)) EMKAMT_END_BAL--,
                  , nvl(CI_MOVE_FR_CRR.txnum,CI_MOVE_FR_TD.txnum)  txnum
                , nvl(CI_MOVE_FR_CRR.txdate,CI_MOVE_FR_TD.txdate)  txdate 
               

              FROM (SELECT CF.CUSTID,
                           CF.BRID,
                           A0.CDCONTENT PRODUC,
                           CF.CUSTODYCD,
                           AF.ACCTNO,
                           CF.FULLNAME,
                           cf.status
                      FROM (SELECT *
                              FROM CFMAST
                             WHERE FNC_VALIDATE_SCOPE(BRID,
                                                      CAREBY,
                                                      TLSCOPE,
                                                      pv_BRID,
                                                      TLGOUPS) = 0) CF,
                           AFMAST AF,
                           AFTYPE AFT,
                           ALLCODE A0
                     WHERE CF.CUSTID = AF.CUSTID
                       AND CF.CUSTODYCD IS NOT NULL
                       AND AF.ACTYPE = AFT.ACTYPE
                       AND A0.CDTYPE = 'CF'
                       AND A0.CDNAME = 'PRODUCTTYPE'
                       AND A0.CDVAL = AFT.PRODUCTTYPE
                       AND CF.BRID LIKE V_I_BRIDGD
                    --  and (af.brid like V_STRBRID or instr(V_STRBRID,af.brid) <> 0)
                    ) CF
             INNER JOIN (
                        -- TONG SO DU PHONG TOA HIEN TAI (TACH RIENG TUNG TK CUA TUNG KH)
                        SELECT CF.CUSTID,
                                CF.CUSTODYCD,
                                AF.ACCTNO AFACCTNO,
                                NVL(CI.EMKAMT, 0) EMKAMT
                          FROM CFMAST CF, AFMAST AF, CIMAST CI
                         WHERE CF.CUSTID = AF.CUSTID
                           AND AF.ACCTNO = CI.AFACCTNO
                           AND CF.CUSTODYCD LIKE V_CUSTODYCD
                           AND AF.ACCTNO LIKE V_AFACCTNO
                           AND CF.BRID LIKE V_I_BRIDGD) CIBAL
                ON CF.CUSTID = CIBAL.CUSTID
               AND CF.ACCTNO = CIBAL.AFACCTNO

              LEFT JOIN (
                        -- TONG CAC PHAT SINH EMKAMT TU FROM_DATE DEN NGAY HIEN TAI
                        SELECT TR.custid,
                                TR.acctno AFACCTNO,
                                tr.txdate, -- begin binhvt them
                                tr.txnum, --, --
                                
                                SUM(CASE
                                      WHEN TR.txtype = 'D' THEN
                                       -TR.namt
                                      ELSE
                                       TR.namt
                                    END) CI_EMKAMT_FR_CRR
                          FROM VW_CITRAN_GEN TR
                         WHERE TR.busdate BETWEEN V_FDATE AND V_CRRDATE
                           AND TR.custodycd LIKE V_CUSTODYCD
                           AND TR.acctno LIKE V_AFACCTNO
                           AND TR.field = 'EMKAMT'
                           AND TR.deltd <> 'Y'
                           AND NVL(TR.tlid, '0000') LIKE V_MAKER
                           AND NVL(TR.offid, '0000') LIKE V_CHECKER
                           AND nvl (tr.tltxcd,'ALL')  LIKE v_tltxcd
                         GROUP BY TR.custid, TR.acctno,tr.txnum,tr.txdate) CI_MOVE_FR_CRR
                ON CF.CUSTID = CI_MOVE_FR_CRR.CUSTID
               AND CF.ACCTNO = CI_MOVE_FR_CRR.AFACCTNO

              LEFT JOIN (
                        -- TONG CAC PHAT SINH EMKAMT TU FROM_DATE DEN TO_DATE
                        SELECT TR.custid,
                                TR.acctno AFACCTNO,
                                tr.txnum, -- begin binhvt them
                                tr.txdate ,
                                SUM(CASE
                                      WHEN TR.txtype = 'C' THEN
                                       TR.namt
                                      ELSE
                                       0
                                    END) CI_EMKAMT_LOCK,
                                SUM(CASE
                                      WHEN TR.txtype = 'D' THEN
                                       TR.namt
                                      ELSE
                                       0
                                    END) CI_EMKAMT_UNLOCK
                          FROM VW_CITRAN_GEN TR
                         WHERE TR.busdate BETWEEN V_FDATE AND V_TDATE
                           AND TR.custodycd LIKE V_CUSTODYCD
                           AND TR.acctno LIKE V_AFACCTNO
                           AND TR.field = 'EMKAMT'
                           AND TR.deltd <> 'Y'
                           AND NVL(TR.tlid, '0000') LIKE V_MAKER
                           AND NVL(TR.offid, '0000') LIKE V_CHECKER
                            AND nvl (tr.tltxcd,'ALL')  LIKE v_tltxcd
                         GROUP BY TR.custid, TR.acctno,  tr.txnum, -- begin binhvt them
                                tr.txdate ) CI_MOVE_FR_TD
                ON CF.CUSTID = CI_MOVE_FR_TD.CUSTID
               AND CF.ACCTNO = CI_MOVE_FR_TD.AFACCTNO
             WHERE CF.CUSTODYCD LIKE V_CUSTODYCD
               AND CF.ACCTNO LIKE V_AFACCTNO
               AND CF.status LIKE V_STATUS
            ----AND    substr( CF.CUSTID, 1,4) LIKE V_STRBRID
            ) cf, (select tl.*,t1.tlfullname usermake ,t2.tlfullname userduyet from  vw_tllog_all tl,tlprofiles t1, tlprofiles t2 where tl.TLID= t1.tlid and tl.OFFID = t2.tlid) tl 
     WHERE (EMKAMT_BEGIN_BAL <> 0
        OR CI_EMKAMT_LOCK <> 0
        OR CI_EMKAMT_UNLOCK <> 0
        OR EMKAMT_END_BAL <> 0) and tl.TXNUM(+) = cf.txnum and tl.TXDATE(+) = cf.txdate
     ORDER BY CUSTID, AFACCTNO

    ;

EXCEPTION
  WHEN OTHERS THEN
    RETURN;
END;

 
 
 
 
/
