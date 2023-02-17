SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "CI0036" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   pv_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   INMONTH        IN       VARCHAR2,
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
   V_CFROMDATE       DATE;
   V_CTODATE         DATE;
   V_ADTYPE     VARCHAR2(40);


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

    IF I_ADTYPE = 'ALL' OR I_ADTYPE IS NULL THEN
        V_ADTYPE := '%%';
    ELSE
        V_ADTYPE := I_ADTYPE;
    END IF;

   IF TO_NUMBER(SUBSTR(INMONTH,1,2)) <= 12 THEN
        V_CFROMDATE := TO_DATE('01/' || SUBSTR(INMONTH,1,2) || '/' || SUBSTR(INMONTH,4,4),'DD/MM/RRRR');
    ELSE
        V_CFROMDATE := TO_DATE('31/12/9999','DD/MM/RRRR');
    END IF;

        V_CTODATE := LAST_DAY(V_CFROMDATE);

   -- GET REPORT'S DATA

    OPEN  PV_REFCURSOR FOR

         SELECT V_CFROMDATE THANG,V_CTODATE THANG1, CF.BRID,AD.TXNUM,TL.TXNUM TXNUMPAID,ad.txkey,cf.custodycd,
                  af.acctno,cf.fullname,ad.txdate,adt.amt paidamt,ad.paiddate,AD.ADTYPE,
                  ADT.FEEADVB  bankfee, ADT.RRTYPE,
                  ADT.FEEADVC vatamt, NVL(ADT.CUSTBANK,'') BANK,
                  NVL(ADT.ADVRATE,0)  FEE, NVL(ADT.BANKRATE,0)  BANKFEERATE,
                  ADT.FEEADV FEEAMT, ADT.AMT -ADT.FEEADV AMT,ADT.VAT,     
                  NVL(CF2.SHORTNAME,CF2.MNEMONIC) bankname
        FROM
            (
            SELECT AUTOID,ISMORTAGE,STATUS,DELTD,ACCTNO,TXDATE,TXNUM,REFADNO,CLEARDT,AMT,
                   FEEAMT,VATAMT,BANKFEE,PAIDAMT,RRTYPE,CUSTBANK,CIACCTNO,ODDATE,PAIDDATE, NVL(adtype,'----') ADTYPE,
                   to_char(txdate,'DDMMRRRR') || substr(txnum,5,6) txkey
            FROM adschd where TXDATE >= V_CFROMDATE and TXDATE <= V_CTODATE
            UNION ALL
            SELECT AUTOID,ISMORTAGE,STATUS,DELTD,ACCTNO,TXDATE,TXNUM,REFADNO,CLEARDT,AMT,
                   FEEAMT,VATAMT,BANKFEE,PAIDAMT,RRTYPE,CUSTBANK,CIACCTNO,ODDATE,PAIDDATE, NVL(adtype,'----') ADTYPE,
                   to_char(txdate,'DDMMRRRR') || substr(txnum,5,6) txkey
            FROM adschdhist where TXDATE >= V_CFROMDATE and TXDATE <= V_CTODATE
            ) AD, vw_tllog_all tl2,
            (select fld.nvalue, tl.*
                    From vw_tllog_all tl, vw_tllogfld_all fld
                    where tl.tltxcd in ('8851','8842')
                        and fld.fldcd = '09'
                        and tl.txnum = fld.txnum
                        and tl.txdate = fld.txdate
                        and tl.txdate >= V_CFROMDATE
                        and tl.txdate <= V_CTODATE
            ) TL,
            brgrp BR, AFMAST AF, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf,
           CFMAST cf2,ADTYPE ADTY, VW_ADVSRESLOG_ALL ADT
     WHERE AD.TXDATE=TL2.TXDATE
           AND AD.DELTD <> 'Y' AND ADT.DELTD <> 'Y'
            AND AD.TXNUM=TL2.TXNUM
            and ad.autoid = tl.nvalue
            and ad.acctno=af.acctno
            and af.custid=cf.custid
            AND TL2.BRID=BR.BRID
            AND ad.paidamt > 0
            AND ad.adtype = ADTY.actype 
             AND AD.TXDATE = ADT.TXDATE
            AND AD.TXNUM=ADT.TXNUM
            AND NVL(ADT.custbank,'0000') LIKE V_ADTYPE
            AND cf.BRID LIKE V_STRISBRID
            and ADT.custbank = cf2.custid(+)
        ORDER BY AD.TXDATE, AD.ACCTNO, AD.TXNUM
     ;

EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;                                                              -- PROCEDURE

 
 
 
 
/
