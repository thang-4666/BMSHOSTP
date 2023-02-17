SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "CI0005" (
   PV_REFCURSOR             IN OUT   PKG_REPORT.REF_CURSOR,
   OPT                      IN       VARCHAR2,
   pv_BRID                     IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2,
   PV_CUSTODYCD   IN       VARCHAR2,
   PV_CISTATUS    IN       VARCHAR2,
   F_ODDATE         IN       VARCHAR2,
   T_ODDATE         IN       VARCHAR2,
   F_CLDATE         IN       VARCHAR2,
   T_CLDATE         IN       VARCHAR2
       )
IS
--
-- BAO CAO: TONG HOP TIEU KHOAN TIEN GUI CUA KHACH HANG
-- MODIFICATION HISTORY
-- PERSON           DATE                    COMMENTS
-- -----------      -----------------       ---------------------------
-- TUNH             15-05-2010              CREATED
-- THENN            14-06-2012              MODIFIED    THAY DOI CACH TINH SDDK
-----------------------------------------------------------------------

    V_STROPTION         VARCHAR2  (5);
    V_STRBRID           VARCHAR2  (16);
    v_brid              VARCHAR2(4);

    v_FDate     date;
    v_TDate     date;

    v_CustodyCD    varchar2(100);
    V_CISTATUS     varchar2(100);

BEGIN
    -- GET REPORT'S PARAMETERS
    V_STROPTION := OPT;
    v_brid := pv_brid;

 IF  V_STROPTION = 'A' and v_brid = '0001' then
    V_STRBRID := '%';
    elsif V_STROPTION = 'B' then
        select br.mapid into V_STRBRID from brgrp br where br.brid = v_brid;
    else V_STROPTION :=pv_brid;

END IF;

    v_FDate := TO_DATE(F_DATE, 'DD/MM/YYYY');
    v_TDate := TO_DATE(T_DATE, 'DD/MM/YYYY');

    IF (UPPER(PV_CUSTODYCD) = 'ALL' OR LENGTH(PV_CUSTODYCD) < 1) THEN
        v_CustodyCD := '%';
    ELSE
        v_CustodyCD := UPPER(PV_CUSTODYCD);
    END IF;

    IF (UPPER(PV_CISTATUS) = 'ALL' OR LENGTH(PV_CISTATUS) < 1) THEN
        V_CISTATUS := '%';
    ELSE
        V_CISTATUS := PV_CISTATUS;
    END IF;

OPEN PV_REFCURSOR
FOR
    SELECT v_FDate INDate, CF.custodycd, CF.fullname, AFT.MNEMONIC, AD.TXDATE, AD.CLEARDT, AD.ODDATE, (AD.AMT) ADAMT,
        (AD.FEEAMT) ADFEEAMT, AD.PAIDAMT,
        (case when DELTD = 'Y' then 'Y' else (CASE WHEN AD.PAIDAMT-(AD.AMT+AD.FEEAMT) >= 0 THEN 'C' ELSE 'P' END)
            end) ADSTATUS, AD.txkey
    FROM (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF, AFMAST AF, AFTYPE AFT,
    (
        SELECT ACCTNO, TXDATE, TXNUM, CLEARDT, AMT, FEEAMT, PAIDAMT, DELTD,CUSTBANK,
            NVL(ADTYPE,'----') ADTYPE, ODDATE, bankfee,
            to_char(txdate,'DDMMRRRR') || substr(txnum,5,6) txkey
        FROM ADSCHD
        WHERE TXDATE >= v_FDate and TXDATE <= v_TDate
            and ODDATE >= to_date(F_ODDATE,'dd/mm/rrrr') and ODDATE <= to_date(T_ODDATE,'dd/mm/rrrr')
            and CLEARDT >= to_date(F_CLDATE,'dd/mm/rrrr') and CLEARDT <= to_date(T_CLDATE,'dd/mm/rrrr')
        UNION ALL
        SELECT ACCTNO, TXDATE, TXNUM, CLEARDT, AMT, FEEAMT, PAIDAMT, DELTD,CUSTBANK,
            NVL(ADTYPE,'----') ADTYPE, ODDATE, bankfee, to_char(txdate,'DDMMRRRR') || substr(txnum,5,6) txkey
        FROM ADSCHDHIST
        WHERE TXDATE >= v_FDate and TXDATE <= v_TDate
            and ODDATE >= to_date(F_ODDATE,'dd/mm/rrrr') and ODDATE <= to_date(T_ODDATE,'dd/mm/rrrr')
            and CLEARDT >= to_date(F_CLDATE,'dd/mm/rrrr') and CLEARDT <= to_date(T_CLDATE,'dd/mm/rrrr')
    ) AD
    WHERE CF.CUSTID = AF.CUSTID
        AND AF.ACTYPE = AFT.ACTYPE
        AND AF.ACCTNO = AD.ACCTNO
        AND CF.CUSTODYCD LIKE v_CustodyCD
        AND (case when AD.DELTD = 'Y' then 'Y' else (CASE WHEN AD.PAIDAMT-(AD.AMT+AD.FEEAMT) >= 0 THEN 'C' ELSE 'P' END)
            end) like V_CISTATUS
;

EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;

 
 
 
 
/
