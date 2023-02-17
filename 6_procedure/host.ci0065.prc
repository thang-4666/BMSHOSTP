SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "CI0065" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   pv_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   P_CUSTODYCD         IN       VARCHAR2,
   P_AFACCTNO         IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2,
   F_CDATE        IN       VARCHAR2,
   T_CDATE        IN       VARCHAR2,
   I_BRID         IN       VARCHAR2,

   VIA          IN       VARCHAR2,
   PV_CLEARDT     IN       VARCHAR2,
   I_ADTYPE       IN       VARCHAR2,
   CASHPLACE      IN       VARCHAR2
 )
IS
--
-- PURPOSE: BRIEFLY EXPLAIN THE FUNCTIONALITY OF THE PROCEDURE
-- BANG KE UONG TRUOC TIEN BAN
-- MODIFICATION HISTORY
-- PERSON      DATE    COMMENTS
-- DUNGNH   21-MAY-10  CREATED
-- HUNG.LB  06-SE-10    UPDATED
-- DUONG.TT 16-SEP-2010 UPDATED CHANGE 28
-- DIENNT   27/08/2011  UPDATE
--  THENN   19-MAR-2012 MODIFIED    THEM THAM SO NGUON UNG TRUOC
-- HOANGND  23-APRIL-2012 UPDATE    THEM THAM SO SO NGAY UNG TRUOC
-- ---------   ------  -------------------------------------------
   V_STROPT     VARCHAR2 (50);            -- A: ALL; B: BRANCH; S: SUB-BRANCH
   V_STRBRID    VARCHAR2 (40);                   -- USED WHEN V_NUMOPTION > 0
   V_INBRID     VARCHAR2 (50);


   V_STRAFACCTNO   VARCHAR2 (20);
   V_STRCUSTODYCD  VARCHAR2 (20);

   V_STRISBRID      VARCHAR2 (50);
   V_FROMDATE       DATE;
   V_TODATE         DATE;
   V_CFROMDATE       DATE;
   V_CTODATE         DATE;
   V_ADVFEERATE NUMBER(20,6);

    -- ADDED BY TRUONG FOR LOGGING
   V_TRADELOG CHAR(20);
   V_AUTOID NUMBER;
   V_INSTANCE VARCHAR2 (10);
   V_ADTYPE     VARCHAR2(40);
   V_STRVIA     VARCHAR2(60);
   V_PV_CLEARDT   NUMBER;
   V_STRCASHPLACE      VARCHAR2(1000);

BEGIN

    V_STROPT := UPPER(OPT);
    V_INBRID := pv_BRID;

    IF(V_STROPT = 'A') THEN
        V_STRBRID := '%';
    ELSE
        IF(V_STROPT = 'B') THEN
            SELECT BR.brid INTO V_STRBRID FROM BRGRP BR WHERE  BR.BRID = V_INBRID;
        ELSE
            V_STRBRID := pv_BRID;
        END IF;
    END IF;

    -- GET REPORT'S PARAMETERS
    IF  (CASHPLACE <> 'ALL')
    THEN
      V_STRCASHPLACE := CASHPLACE;
    ELSE
      V_STRCASHPLACE := '%';
    END IF;

    IF (UPPER(I_BRID) = 'ALL' OR I_BRID IS NULL)
    THEN
      V_STRISBRID := '%%';
    ELSE
      V_STRISBRID := I_BRID;
    END IF;

    IF I_ADTYPE = 'ALL' OR I_ADTYPE IS NULL THEN
        V_ADTYPE := '%%';
    ELSE
        V_ADTYPE := I_ADTYPE;
    END IF;

    IF UPPER(VIA) = 'ALL' OR VIA IS NULL THEN
        V_STRVIA := '%';
    ELSE
        V_STRVIA := VIA;
    END IF;

    IF(UPPER(PV_CLEARDT) = 'ALL')OR PV_CLEARDT IS NULL THEN
        V_PV_CLEARDT := 0;
    ELSE
        V_PV_CLEARDT := PV_CLEARDT;
    END IF;

   V_FROMDATE := TO_DATE(F_DATE,'DD/MM/YYYY');
   V_TODATE   := TO_DATE(T_DATE,'DD/MM/YYYY');
   V_CFROMDATE := TO_DATE(F_CDATE,'DD/MM/YYYY');
   V_CTODATE   := TO_DATE(T_CDATE,'DD/MM/YYYY');
    SELECT TO_NUMBER(VARVALUE)/360 INTO V_ADVFEERATE
    FROM SYSVAR WHERE VARNAME = 'AINTRATE' AND GRNAME = 'SYSTEM';
   -- END OF GETTING REPORT'S PARAMETERS

   -- GET REPORT'S DATA

    OPEN  PV_REFCURSOR FOR
        SELECT TO_CHAR(AD.ODDATE,'DD/MM/RRRR') ODDATE, BR.BRNAME BRNAME,PF.TLNAME CAREBY,NVL(PF1.TLNAME,'') USERDUYET,
            TO_CHAR(AD.TXDATE,'DD/MM/RRRR') TXDATE, TO_CHAR(AD.TXNUM) TXNUM , CF.CUSTODYCD CUSTODYCD, AF.ACCTNO ACCTNO, CF.FULLNAME FULLNAME,
            TO_CHAR(AD.CLEARDT,'DD/MM/RRRR') CLEARDT, adty.amt NAMT,
            NVL(round((TO_NUMBER(AD.CLEARDT-AD.TXDATE))*(adty.BANKRATE*( round( ADTY.AMT/(1+((TO_NUMBER(AD.CLEARDT-AD.TXDATE))*ADT.ADVRATE/100/360)),4)))/(100*360),4),0) BANKFEE,
           round( NVL((AD.FEEAMT - round((TO_NUMBER(AD.CLEARDT-AD.TXDATE))*(adty.BANKRATE*( round( ADTY.AMT/(1+((TO_NUMBER(AD.CLEARDT-AD.TXDATE))*ADT.ADVRATE/100/360)),4)))/(100*360),4)),0)) VATAMT,
            ROUND((NVL(ADT.ADVRATE,0)/360),4) FEE,
            ROUND((NVL(ADTY.BANKRATE,0)/360),4) BANKFEERATE,
        --            ROUND((AD.FEEAMT*100/(AD.AMT+AD.FEEAMT))/TO_NUMBER(AD.CLEARDT-AD.TXDATE),4) FEE,
          --  AD.FEEAMT FEEAMT, AD.AMT AMT,
           ROUND(ADTY.amt-round( ADTY.AMT/(1+((TO_NUMBER(AD.CLEARDT-AD.TXDATE))*ADT.ADVRATE/100/360)),4),4) FEEAMT,
            round( ADTY.AMT/(1+((TO_NUMBER(AD.CLEARDT-AD.TXDATE))*ADT.ADVRATE/100/360)),4) AMT,
              nvl(cf2.shortname,cspks_system.fn_get_sysvar('SYSTEM','COMPANYSHORTNAME')) bankname,
           -- (CASE WHEN AD.ADTYPE = '0001' THEN cspks_system.fn_get_sysvar('SYSTEM','COMPANYSHORTNAME') ELSE NVL(CF2.SHORTNAME,'') END) CUSTBANK,
            ---- NVL(CF2.SHORTNAME,'BVSC') CUSTBANK,
            TO_NUMBER(AD.CLEARDT-AD.TXDATE) NGAYUT,
            DECODE(V_ADTYPE,'%%','ALL',NVL(CF2.FULLNAME,'')) ADVBANK, AD.ADTYPE,
            DECODE(V_STRISBRID,'%%','ALL',NVL(BR.BRNAME,'')) BRANCH,
            (CASE WHEN SUBSTR(AD.TXNUM,1,2) = '68' THEN '68'
                WHEN SUBSTR(AD.TXNUM,1,2) = '99' THEN '99' ELSE '00' END) KENH,  CASE WHEN SUBSTR(AF.ACCTNO,1,2)= SUBSTR(AD.TXNUM,1,2) OR substr(AD.TXNUM,1,2) IN ('99','68')   THEN '1'  ELSE '2' END TYPEBRID
        FROM (SELECT * FROM
                (
                    SELECT ACCTNO, TXDATE, TXNUM, CLEARDT, AMT, FEEAMT, PAIDAMT, DELTD,CUSTBANK, NVL(ADTYPE,'----') ADTYPE, ODDATE, bankfee, vatamt FROM ADSCHD
                    UNION ALL
                    SELECT ACCTNO, TXDATE, TXNUM, CLEARDT, AMT, FEEAMT, PAIDAMT, DELTD,CUSTBANK, NVL(ADTYPE,'----') ADTYPE, ODDATE, bankfee, vatamt FROM ADSCHDHIST
                )
             ) AD, (select * from afmast where (case when CASHPLACE = 'ALL' then 'ALL'
                                                        when CASHPLACE = '000' or CASHPLACE = '---' then corebank
                                                        when CASHPLACE = '111' then corebank
                                                        else corebank || bankname end)
                                                   = case when CASHPLACE = 'ALL' then 'ALL'
                                                        when CASHPLACE = '000'  or CASHPLACE = '---' then 'N'
                                                        when CASHPLACE = '111'  then 'Y'
                                                        else 'Y' || V_STRCASHPLACE  end ) AF, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF, BRGRP BR , VW_TLLOG_ALL TL,TLPROFILES PF,TLPROFILES PF1,
             (SELECT ADT.ACTYPE, ADT.TYPENAME, ADT.ADVRATE, adt.advbankrate FROM ADTYPE ADT UNION ALL SELECT '----' ACTYPE, '----' TYPENAME, 0 ADVRATE, 0 advbankrate FROM DUAL) ADT,
             (SELECT * FROM CFMAST WHERE ISBANKING = 'Y') CF2,
             (SELECT * FROM ADVRESLOG UNION ALL SELECT * FROM ADVRESLOGHIST) ADTY
        WHERE AD.DELTD <> 'Y'
            AND AF.ACCTNO = AD.ACCTNO and af.acctno = P_AFACCTNO
            AND AF.CUSTID = CF.CUSTID
            AND AD.TXNUM = TL.TXNUM
            AND AD.TXDATE = TL.TXDATE
            AND CF.CUSTATCOM='Y'
            AND TL.BRID = BR.BRID
            AND AD.TXDATE >= V_FROMDATE
            AND AD.TXDATE <= V_TODATE
            AND AD.CLEARDT >= V_CFROMDATE
            AND AD.CLEARDT <= V_CTODATE
            AND (TL.BRID LIKE V_STRBRID OR INSTR(V_STRBRID,TL.BRID) <> 0)
            AND ADTY.CUSTBANK = CF2.CUSTID(+)
            AND CF.TLID = PF.TLID(+)--UPDATED BY DUONG.TT
            AND  TL.OFFID  = PF1.TLID(+)
            AND AD.ADTYPE = ADT.ACTYPE (+)
             AND AD.TXDATE = ADTY.TXDATE(+)
            AND AD.TXNUM=ADTY.TXNUM(+)
            AND AD.ACCTNO=ADTY.AFACCTNO(+)
            AND NVL(ADTY.CUSTBANK,'0000') LIKE V_ADTYPE
            AND AF.BRID LIKE V_STRISBRID
            AND (CASE WHEN V_PV_CLEARDT = 0 THEN V_PV_CLEARDT ELSE TO_NUMBER(AD.CLEARDT-AD.TXDATE)END) LIKE V_PV_CLEARDT   --HOANGND
            AND ((CASE WHEN SUBSTR(AD.TXNUM,1,2) = '68' THEN 'O' ELSE 'FA' END) LIKE V_STRVIA
            OR (CASE WHEN SUBSTR(AD.TXNUM,1,2) = '68' THEN 'O'
                WHEN SUBSTR(AD.TXNUM,1,2) = '99' THEN 'A' ELSE 'F' END) LIKE V_STRVIA)      ----HOANGND
        ORDER BY AD.TXDATE, AD.ACCTNO, AD.TXNUM;

EXCEPTION
   WHEN OTHERS
   THEN
   pr_error('CI0015',SQLERRM || '. At row: '|| dbms_utility.format_error_backtrace);
      RETURN;
END;                                                              -- PROCEDURE

 
 
 
 
/
