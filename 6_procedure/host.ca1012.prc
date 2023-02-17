SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE ca1012 (
                                    PV_REFCURSOR in out PKG_REPORT.REF_CURSOR,
                                   OPT              in      varchar2,
                                   BRID             in      varchar2,
                                   TLGOUPS        IN       VARCHAR2,
                                   TLSCOPE        IN       VARCHAR2,
                                   F_DATE           IN       VARCHAR2,
                                   T_DATE           IN       VARCHAR2,
                                   PV_CACODE        IN       VARCHAR2,
                                   PV_SYMBOL        IN       VARCHAR2,
                                   PV_CUSTODYCD     IN       VARCHAR2,
                                   TLID             IN        VARCHAR2
  )
IS
--
-- PURPOSE: DANH SACH KH HUONG LOI TUC CW
-- BAO CAO QUYEN MUA
-- MODIFICATION HISTORY
-- PERSON      DATE    COMMENTS
-- DIEUNNDA      25/09/2019
-- ---------   ------  -------------------------------------------

    CUR             PKG_REPORT.REF_CURSOR;
    V_STROPT    VARCHAR2 (5);            -- A: ALL; B: BRANCH; S: SUB-BRANCH
    V_STRBRID      VARCHAR2 (2000);
    V_INBRID       VARCHAR2 (5);
    V_STRTLID       VARCHAR2(10);
    V_FRDATE        DATE;
    V_TODATE        DATE;
    V_CUSTODYCD     VARCHAR2 (60);
    V_SYMBOL        VARCHAR2 (60);
    V_CACODE        VARCHAR2 (60);

BEGIN
   V_STRTLID:= TLID;
    V_STROPT := upper(OPT);
    V_INBRID := BRID;
    if(V_STROPT = 'A') then
        V_STRBRID := '%';
    else
        if(V_STROPT = 'B') then
            select br.mapid into V_STRBRID from brgrp br where  br.brid = V_INBRID;
        else
            V_STRBRID := BRID;
        end if;
    end if;

   IF (UPPER(PV_CUSTODYCD) <> 'ALL')
   THEN
      V_CUSTODYCD := UPPER(replace(PV_CUSTODYCD,'.',''));
   ELSE
      V_CUSTODYCD := '%%';
   END IF;

   IF (UPPER(PV_SYMBOL) <> 'ALL')
   THEN
      V_SYMBOL :=  upper(REPLACE (PV_SYMBOL,' ','_'));
   ELSE
      V_SYMBOL := '%%';
   END IF;

   IF (UPPER(PV_CACODE) <> 'ALL')
   THEN
      V_CACODE :=  upper(REPLACE (PV_CACODE,'.',''));
   ELSE
      V_CACODE := '%%';
   END IF;

   V_FRDATE := TO_DATE(F_DATE,'DD/MM/RRRR');
   V_TODATE := TO_DATE(T_DATE,'DD/MM/RRRR');


OPEN PV_REFCURSOR
   FOR
    SELECT  V_FRDATE FRDATE, V_TODATE TODATE,
            AF.ACCTNO, CF.CUSTODYCD,  AFT.MNEMONIC, AFT.TYPENAME, CF.FULLNAME, NVL(CF.MOBILESMS,CF.MOBILE) MOBILESMS,
            CASE WHEN CF.IDTYPE='009' THEN CF.TRADINGCODE ELSE CF.IDCODE END IDCODE, SC.BALANCE QTTY,
            CASE WHEN CA.TYPERATE='R' THEN TO_NUMBER(CA.DEVIDENTRATE) ELSE (CA.DEVIDENTVALUE) END CARATE,
            ca.DEVIDENTRATE, ca.DEVIDENTVALUE,
            CA.EXPRICE, CA.ACTIONDATE,
            /*SC.AMT,*/
            sc.AMT AMT,
           NVL((CASE WHEN  ca.PITRATEMETHOD ='NO' OR sc.PITRATEMETHOD= 'NO' THEN 0 ELSE 1 END),0)*(case when CF.VAT='N' then 0
            else
               round(LEAST(sc.AMT,
                        sc.balance*ca.EXPRICE*ca.pitrate/100
                        /(to_number(SUBSTR(SB.EXERCISERATIO,0,INSTR(SB.EXERCISERATIO,'/') - 1))/to_number(SUBSTR(SB.EXERCISERATIO,INSTR(SB.EXERCISERATIO,'/')+1,LENGTH(SB.EXERCISERATIO)) ))
                        )
                    )
            end) DUTYAMT,
            NVL((CASE WHEN  ca.PITRATEMETHOD ='NO' OR sc.PITRATEMETHOD= 'NO' THEN 0 ELSE 1 END),0)*(case when CF.VAT='N' then 0
            else
               round(
                        sc.balance*ca.EXPRICE*ca.pitrate/100
                        /(to_number(SUBSTR(SB.EXERCISERATIO,0,INSTR(SB.EXERCISERATIO,'/') - 1))/to_number(SUBSTR(SB.EXERCISERATIO,INSTR(SB.EXERCISERATIO,'/')+1,LENGTH(SB.EXERCISERATIO)) ))
                    )
            end) DUTYAMT_max,
            sc.AMT - NVL((CASE WHEN  ca.PITRATEMETHOD ='NO' OR sc.PITRATEMETHOD= 'NO' THEN 0 ELSE 1 END),0)*(case when CF.VAT='N' then 0
            else
               round(LEAST(sc.AMT,
                        sc.balance*ca.EXPRICE*ca.pitrate/100
                        /(to_number(SUBSTR(SB.EXERCISERATIO,0,INSTR(SB.EXERCISERATIO,'/') - 1))/to_number(SUBSTR(SB.EXERCISERATIO,INSTR(SB.EXERCISERATIO,'/')+1,LENGTH(SB.EXERCISERATIO)) ))
                        )
                    )
            end) REMAINAMT,SB.EXERCISERATIO,
             A1.CDCONTENT CASTATUS, A2.CDCONTENT AFSTATUS,
            A3.CDCONTENT SCHDVAT, CA.REPORTDATE, SB.SYMBOL,
            CA.CAMASTID, CA.ISINCODE, CA.DESCRIPTION
    FROM CAMAST CA, CASCHD SC, CFMAST CF, AFMAST AF, AFTYPE AFT, SBSECURITIES SB,
        (SELECT * FROM ALLCODE WHERE CDNAME='CASTATUS' AND CDTYPE='CA') A1,
        (SELECT * FROM ALLCODE WHERE CDNAME='STATUS' AND CDTYPE='CF') A2,
        (SELECT * FROM ALLCODE WHERE CDNAME='PITRATEMETHOD' AND CDTYPE='CA') A3
    WHERE CA.CAMASTID=SC.CAMASTID
    AND CF.CUSTID=AF.CUSTID
    AND SC.AFACCTNO=AF.ACCTNO
    AND AF.ACTYPE=AFT.ACTYPE
    AND CA.STATUS=A1.CDVAL
    AND AF.STATUS=A2.CDVAL
    AND SC.CODEID=SB.CODEID
    AND CASE WHEN SC.PITRATEMETHOD='##' OR  SC.PITRATEMETHOD IS NULL THEN CA.PITRATEMETHOD ELSE SC.PITRATEMETHOD END=A3.CDVAL
    AND CA.CATYPE='028'
    AND SC.DELTD <> 'Y'
    AND CA.ACTIONDATE BETWEEN  V_FRDATE AND V_TODATE
    AND SB.SYMBOL LIKE V_SYMBOL
    AND CF.CUSTODYCD LIKE  V_CUSTODYCD
    and CA.CAMASTID like V_CACODE;


EXCEPTION
   WHEN OTHERS
   THEN
        --plog.error ('CA1012.Error: ' || SQLERRM || dbms_utility.format_error_backtrace);
      RETURN;
END;  -- PROCEDURE
 
/
