SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "CI0006" (
   PV_REFCURSOR             IN OUT   PKG_REPORT.REF_CURSOR,
   OPT                      IN       VARCHAR2,
   pv_BRID                     IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2,
   PV_CUSTODYCD   IN       VARCHAR2,
   SF_DATE        IN       VARCHAR2,
   ST_DATE        IN       VARCHAR2,
   CF_DATE        IN       VARCHAR2,
   CT_DATE        IN       VARCHAR2,
   I_BRID         IN       VARCHAR2,
   I_ADTYPE       IN       VARCHAR2,
   VIA          IN       VARCHAR2,
   PV_CLEARDT     IN       VARCHAR2,
   CASHPLACE      IN       VARCHAR2
       )
IS

-- BAO CAO: TONG HOP TIEU KHOAN TIEN GUI CUA KHACH HANG
-- MODIFICATION HISTORY
-- PERSON           DATE                    COMMENTS
 ---      -       -
-- TUNH             15-05-2010              CREATED
-- THENN            14-06-2012              MODIFIED    THAY DOI CACH TINH SDDK
--

    V_STROPTION         VARCHAR2  (5);
    V_STRBRID           VARCHAR2  (16);
    v_brid              VARCHAR2(10);

     V_STRISBRID      VARCHAR2 (10);
   V_FROMDATE       DATE;
   V_TODATE         DATE;

   V_SFROMDATE       DATE;
   V_STODATE         DATE;
   V_CFROMDATE       DATE;
   V_CTODATE         DATE;

   V_ADVFEERATE NUMBER(20,6);

 --    ADDED BY TRUONG FOR LOGGING
   V_TRADELOG CHAR(20);
   V_AUTOID NUMBER;
   V_INSTANCE VARCHAR2 (10);
   V_ADTYPE     VARCHAR2(20);
   V_STRVIA     VARCHAR2(10);
   V_PV_CLEARDT   NUMBER;
   V_STRCASHPLACE      VARCHAR2(1000);

    v_CustodyCD    varchar2(100);

BEGIN
  --   GET REPORT'S PARAMETERS
    V_STROPTION := OPT;
    v_brid := pv_brid;

 IF  V_STROPTION = 'A' and v_brid = '0001' then
    V_STRBRID := '%';
    elsif V_STROPTION = 'B' then
        select br.mapid into V_STRBRID from brgrp br where br.brid = v_brid;
    else V_STROPTION := v_brid;

END IF;

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

   V_FROMDATE   := TO_DATE(F_DATE,'DD/MM/YYYY');
   V_TODATE     := TO_DATE(T_DATE,'DD/MM/YYYY');

   V_SFROMDATE   := TO_DATE(SF_DATE,'DD/MM/YYYY');
   V_STODATE     := TO_DATE(ST_DATE,'DD/MM/YYYY');
   V_CFROMDATE   := TO_DATE(CF_DATE,'DD/MM/YYYY');
   V_CTODATE     := TO_DATE(CT_DATE,'DD/MM/YYYY');

    IF (UPPER(PV_CUSTODYCD) = 'ALL' OR LENGTH(PV_CUSTODYCD) < 1) THEN
        v_CustodyCD := '%';
    ELSE
        v_CustodyCD := UPPER(PV_CUSTODYCD);
    END IF;

OPEN PV_REFCURSOR
FOR
    select cf.fullname, cf.custodycd, af.acctno, MAIN.MNEMONIC, (case when af.corebank = 'Y' then af.bankacctno else cf.custodycd end) bankacct,
        (main.exeamt) exeamt, (main.aamt) aamt, (main.amt) amt, main.oddate, main.cleardt, (main.ndate) ndate,
        (main.feeamt) feeamt, main.txkey, main.odkey
    from (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf, afmast af,
    (
        select od.afacctno acctno, OD.MNEMONIC, od.txdate, od.cleardate cleardt, od.txdate oddate, sum(nvl(ad.amt,0)) amt, MAX(nvl(ad.feeamt,0)) feeamt,
            max(od.exeamt) exeamt, nvl(max(ad.cleardt - ad.txdate),0) ndate, sum(nvl(adt.aamt,0)) aamt,
            ad.txkey, od.odkey
        from
        (
            SELECT OD.AFACCTNO, OD.TXDATE, AFT.MNEMONIC,
                sum(round(OD.EXECAMT- (case when od.feeacr > 0 then od.feeacr else (ROUND(ODT.DEFFEERATE,5)*od.EXECAMT)/100 end )
                -((od.EXECAMT*(case when od.taxrate > 0 then od.taxrate else (case when cf.vat = 'Y' then ROUND(TO_NUMBER(SYS.VARVALUE),5) else 0 end) end))/100))) exeamt,
                STS.CLEARDATE, OD.AFACCTNO || TO_CHAR(OD.TXDATE,'DDMMRRRR') || TO_CHAR(STS.CLEARDATE,'DDMMRRRR') ODKEY
            FROM VW_ODMAST_ALL OD, VW_STSCHD_ALL STS, ODTYPE ODT, SYSVAR SYS, cfmast cf, afmast af, AFTYPE AFT
            WHERE  OD.ORDERID = STS.ORGORDERID AND STS.DUETYPE IN ('RM', 'RS')
                AND STS.DELTD = 'N' AND OD.DELTD = 'N'
                AND ODT.ACTYPE = OD.ACTYPE and cf.custid = af.custid
                and od.AFACCTNO = af.acctno
                AND AF.ACTYPE=AFT.ACTYPE
                AND SYS.GRNAME = 'SYSTEM' AND SYS.VARNAME = 'ADVSELLDUTY'
                AND INSTR(OD.EXECTYPE,'S') > 0 AND OD.EXECAMT > 0
                AND OD.TXDATE >= V_SFROMDATE AND OD.TXDATE <= V_STODATE
                AND STS.CLEARDATE >= V_CFROMDATE AND STS.CLEARDATE <= V_CTODATE
            group by OD.AFACCTNO, OD.TXDATE,AFT.MNEMONIC,
                STS.CLEARDATE, OD.AFACCTNO || TO_CHAR(OD.TXDATE,'DDMMRRRR') || TO_CHAR(STS.CLEARDATE,'DDMMRRRR')
        ) OD
        INNER join
        (
            select a.acctno, a.txdate, a.cleardt, a.oddate, adt.orderid,
                sum(adt.aamt) amt, max(a.feeamt) feeamt, adt.txnum, to_char(a.txdate,'DDMMRRRR') || substr(a.txnum,5,6) txkey,
                 a.ACCTNO || TO_CHAR(a.oddate,'DDMMRRRR') || TO_CHAR(a.cleardt,'DDMMRRRR') odkey
            from adschd a , adschddtl adt, ADVRESLOG ADV
            WHERE
            a.TXDATE >= V_FROMDATE and a.txdate <= V_TODATE and a.deltd <> 'Y'  and
             a.txnum = adt.txnum
                and a.txdate = adt.txdate
                AND ((CASE WHEN SUBSTR(A.TXNUM,1,2) = '68' THEN 'O' ELSE 'FA' END) LIKE V_STRVIA
                    OR (CASE WHEN SUBSTR(A.TXNUM,1,2) = '68' THEN 'O'
                WHEN SUBSTR(A.TXNUM,1,2) = '99' THEN 'A' ELSE 'F' END) LIKE V_STRVIA)
                  AND A.TXDATE=ADV.TXDATE(+)
                AND A.TXNUM=ADV.TXNUM(+)
                AND A.ACCTNO=ADV.AFACCTNO(+)
                AND NVL(ADV.CUSTBANK,'0000') LIKE V_ADTYPE
            group by a.acctno, a.txdate, a.cleardt, a.oddate, adt.orderid, adt.txnum, to_char(a.txdate,'DDMMRRRR') || substr(a.txnum,5,6),
                a.ACCTNO || TO_CHAR(a.oddate,'DDMMRRRR') || TO_CHAR(a.cleardt,'DDMMRRRR')
            union all
            select a.acctno, a.txdate, a.cleardt, a.oddate, adt.orderid,
                sum(adt.aamt) amt, max(a.feeamt) feeamt, adt.txnum, to_char(a.txdate,'DDMMRRRR') || substr(a.txnum,5,6) txkey,
                a.ACCTNO || TO_CHAR(a.oddate,'DDMMRRRR') || TO_CHAR(a.cleardt,'DDMMRRRR') odkey
            from adschdhist a, adschddtl adt, ADVRESLOGHIST ADV
            WHERE
            a.TXDATE >= V_FROMDATE and a.txdate <= V_TODATE and a.deltd <> 'Y'         and
              a.txnum = adt.txnum
                and a.txdate = adt.txdate
                AND ((CASE WHEN SUBSTR(A.TXNUM,1,2) = '68' THEN 'O' ELSE 'FA' END) LIKE V_STRVIA
                    OR (CASE WHEN SUBSTR(A.TXNUM,1,2) = '68' THEN 'O'
                WHEN SUBSTR(A.TXNUM,1,2) = '99' THEN 'A' ELSE 'F' END) LIKE V_STRVIA)
                  AND A.TXDATE=ADV.TXDATE(+)
                AND A.TXNUM=ADV.TXNUM(+)
                AND A.ACCTNO=ADV.AFACCTNO(+)
               AND NVL(ADV.CUSTBANK,'0000') LIKE V_ADTYPE
            group by a.acctno, a.txdate, a.cleardt, a.oddate, adt.orderid, adt.txnum, to_char(a.txdate,'DDMMRRRR') || substr(a.txnum,5,6),
                a.ACCTNO || TO_CHAR(a.oddate,'DDMMRRRR') || TO_CHAR(a.cleardt,'DDMMRRRR')
        ) ad
        on ad.odkey = od.odkey and ad.acctno = od.afacctno
        left join
            (
                select ad.acctno, ad.acctno || TO_CHAR(ad.oddate,'DDMMRRRR') || TO_CHAR(ad.cleardt,'DDMMRRRR') odkey, sum(aamt) aamt
                from adschddtl adt, adschd ad
                where adt.deltd = 'N' and adt.txnum = ad.txnum and adt.txdate = ad.txdate
                and adt.txdate < V_FROMDATE
                group by  ad.acctno || TO_CHAR(ad.oddate,'DDMMRRRR') || TO_CHAR(ad.cleardt,'DDMMRRRR'), ad.acctno
            ) adt
            on adt.odkey = od.odkey and adt.acctno = od.afacctno
        group by od.afacctno, od.txdate, od.cleardate, od.txdate, ad.txkey, od.odkey, OD.MNEMONIC
    ) main
    where cf.custid = af.custid
        and main.acctno = af.acctno
        and (main.aamt <> 0 or main.amt <> 0)
        AND (CASE WHEN V_PV_CLEARDT = 0 THEN V_PV_CLEARDT ELSE (main.ndate)  END) LIKE V_PV_CLEARDT
        AND CF.BRID LIKE V_STRISBRID
        AND CF.CUSTODYCD LIKE v_CustodyCD
;

EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;
 
 
 
/
