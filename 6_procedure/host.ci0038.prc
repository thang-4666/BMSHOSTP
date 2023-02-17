SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "CI0038" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   pv_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   I_DATE        IN       VARCHAR2,
   I_BRID         IN       VARCHAR2,
   I_ADTYPE       IN       VARCHAR2

 )
IS

--
-- ---------   ------  -------------------------------------------
   V_STROPT     VARCHAR2 (50);            -- A: ALL; B: BRANCH; S: SUB-BRANCH
   V_STRBRID       VARCHAR2 (40);            -- USED WHEN V_NUMOPTION > 0
   V_INBRID         VARCHAR2 (50);

   V_STRISBRID      VARCHAR2 (50);
   V_FROMDATE       DATE;
   V_TODATE         DATE;
   V_IDATE       DATE;
   V_CURR_DATE   DATE;
   V_ADTYPE     VARCHAR2(40);
   V_BRNAME   VARCHAR2(100);
V_SYSCLEARDAY NUMBER;
BEGIN


    V_STROPT := OPT;

    IF (V_STROPT <> 'A') AND (pv_BRID <> 'ALL')
    THEN
      V_STRBRID := pv_BRID;
    ELSE
      V_STRBRID := '%%';
    END IF;
    -- GET REPORT'S PARAMETERS

    IF (UPPER(I_BRID) = 'ALL' OR I_BRID IS NULL)
    THEN
      V_STRISBRID := '%%';
    ELSE
      V_STRISBRID := I_BRID;
    END IF;
       IF (I_BRID <> 'ALL' OR I_BRID <> '')
   THEN
      BEGIN
            SELECT BRNAME INTO V_BRNAME FROM BRGRP WHERE BRID LIKE I_BRID;
      END;
   ELSE
      V_BRNAME   :=  ' Toàn công ty ';
   END IF;


    IF I_ADTYPE = 'ALL' OR I_ADTYPE IS NULL THEN
        V_ADTYPE := '%%';
    ELSE
        V_ADTYPE := I_ADTYPE;
    END IF;

        SELECT to_date(varvalue,'DD/MM/RRRR') INTO V_CURR_DATE FROM sysvar WHERE varname = 'CURRDATE';
        V_IDATE := TO_DATE(I_DATE,'DD/MM/RRRR');
   --T2- NAMNT
    SELECT fn_getSYSCLEARDAY(I_DATE) INTO V_SYSCLEARDAY FROM dual;

    --End T2-NAMNT
   -- GET REPORT'S DATA

    OPEN  PV_REFCURSOR FOR

     SELECT V_IDATE IDATE,V_CURR_DATE CURRENTDATE,V_BRNAME TEN_CN, CF.BRID BRNAME,AD.TXNUM,
          nvl(TL.TXNUM,'') TXNUMPAID,ad.txkey,cf.custodycd,af.acctno,cf.fullname,
            ad.txdate,adT.AMT paidamt,nvl(ad.paiddate,AD.CLEARDT) paiddate,
            ADT.AMT -ADT.FEEADV AMT, AD.ADTYPE,
             (CASE WHEN AD.TXDATE = V_IDATE THEN 0
          --   WHEN AD.CLEARDT=V_IDATE  THEN 0
               ELSE ADT.AMT END
               ) T1,
             (CASE WHEN AD.TXDATE=V_IDATE THEN ADT.AMT ELSE 0 END) T2,
             (CASE WHEN AD.CLEARDT=V_IDATE THEN ADT.AMT ELSE 00 END ) T3,
            NVL(CF2.SHORTNAME,CF2.MNEMONIC) bankname,
           ADT.FEEADV FEEAMT, ADT.FEEADVB BANKFEE,ADT.FEEADVC VATAMT,NVL(ADT.RRTYPE,'') RRTYPE
        FROM
            (
            SELECT AUTOID,ISMORTAGE,STATUS,DELTD,ACCTNO,TXDATE,TXNUM,REFADNO,CLEARDT,AMT,
                   FEEAMT,VATAMT,BANKFEE,PAIDAMT,RRTYPE,CUSTBANK,CIACCTNO,ODDATE,PAIDDATE, NVL(adtype,'----') ADTYPE,
                   to_char(txdate,'DDMMRRRR') || substr(txnum,5,6) txkey
            FROM adschd where  TXDATE <= getduedate(V_IDATE,'B','000',V_SYSCLEARDAY) AND TXDATE >=fn_get_prevdate(V_IDATE,3)
            UNION ALL
            SELECT AUTOID,ISMORTAGE,STATUS,DELTD,ACCTNO,TXDATE,TXNUM,REFADNO,CLEARDT,AMT,
                   FEEAMT,VATAMT,BANKFEE,PAIDAMT,RRTYPE,CUSTBANK,CIACCTNO,ODDATE,PAIDDATE, NVL(adtype,'----') ADTYPE,
                   to_char(txdate,'DDMMRRRR') || substr(txnum,5,6) txkey
            FROM adschdhist where  TXDATE <= getduedate(V_IDATE,'B','000',V_SYSCLEARDAY) AND TXDATE >=fn_get_prevdate(V_IDATE,3)
            ) AD, vw_tllog_all tl2,
            (select fld.nvalue, tl.*
                    From vw_tllog_all tl, vw_tllogfld_all fld
                    where tl.tltxcd in ('8851','8842')
                        and fld.fldcd = '09'
                        and tl.txnum = fld.txnum
                        and tl.txdate = fld.txdate
                        and tl.txdate <= getcurrdate
            ) TL,
            brgrp BR, AFMAST AF, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf,
            CFMAST cf2, VW_ADVSRESLOG_ALL ADT, VW_TLLOGFLD_ALL FLD
     WHERE AD.TXDATE=TL2.TXDATE
            AND AD.TXNUM=TL2.TXNUM
            AND TL2.TXDATE=FLD.TXDATE
            AND TL2.TXNUM=FLD.TXNUM
            AND FLD.FLDCD='12'
            and ad.autoid = tl.nvalue(+)
            and ad.acctno=af.acctno
            and af.custid=cf.custid
            AND TL2.BRID=BR.BRID
             AND AD.TXDATE = ADT.TXDATE
            AND AD.TXNUM=ADT.TXNUM
            AND AD.CLEARDT>=V_IDATE
           AND NVL(ADT.custbank,'0000') LIKE V_ADTYPE
           AND CF.BRID LIKE V_STRISBRID
            and ADT.custbank = cf2.custid(+)
        ORDER BY AD.TXDATE, AD.ACCTNO, AD.TXNUM
     ;

EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;                                                              -- PROCEDURE

 
 
 
 
/
