SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "CF00082" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   PV_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   I_DATE         IN       VARCHAR2,
   PV_CUSTODYCD   IN       VARCHAR2,
   PV_AFACCTNO    IN       VARCHAR2,
   PV_AFTYPE      IN       VARCHAR2
 )
IS
--
-- PURPOSE: BRIEFLY EXPLAIN THE FUNCTIONALITY OF THE PROCEDURE
--
-- MODIFICATION HISTORY
-- PERSON      DATE       COMMENTS
-- Diennt      30/09/2011 Create
-- ---------   ------     -------------------------------------------
   V_STROPTION        VARCHAR2 (5);       -- A: ALL; B: BRANCH; S: SUB-BRANCH

   -- DECLARE PROGRAM VARIABLES AS SHOWN ABOVE
   V_STRPV_CUSTODYCD VARCHAR2(20);
   V_STRPV_AFACCTNO VARCHAR2(20);
   V_INBRID        VARCHAR2(4);
   V_STRBRID      VARCHAR2 (50);
   V_STRTLID           VARCHAR2(6);
   V_BALANCE        number;
   V_BALDEFOVD      number;
   V_IN_DATE        date;
   V_CURRDATE       date;
   V_STRAFTYPE       VARCHAR2(100);
BEGIN
/*
   V_STROPTION := OPT;

   IF (V_STROPTION <> 'A') AND (BRID <> 'ALL')
   THEN
      V_STRBRID := BRID;
   ELSE
      V_STRBRID := '%%';
   END IF;*/

--   V_STRTLID:=TLID;
   /*IF(TLID <> 'ALL' AND TLID IS NOT NULL)
   THEN
        V_STRTLID := TLID;
   ELSE
        V_STRTLID := 'ZZZZZZZZZ';
   END IF;
*/
    V_STROPTION := upper(OPT);
    V_INBRID := PV_BRID;
    if(V_STROPTION = 'A') then
        V_STRBRID := '%%';
    else
        if(V_STROPTION = 'B') then
            select br.BRID into V_STRBRID from brgrp br where  br.brid = V_INBRID;
        else
            V_STRBRID := V_INBRID;
        end if;
    end if;

      IF (PV_AFTYPE <> 'ALL' OR PV_AFTYPE <> '')
   THEN
      V_STRAFTYPE :=  PV_AFTYPE;
   ELSE
      V_STRAFTYPE := '%%';
   END IF;

    V_STRPV_CUSTODYCD  := upper(PV_CUSTODYCD);
    IF(PV_AFACCTNO <> 'ALL' AND PV_AFACCTNO IS NOT NULL)
   THEN
        V_STRPV_AFACCTNO := PV_AFACCTNO;
   ELSE
        V_STRPV_AFACCTNO := '%';
   END IF;
    V_IN_DATE       := to_date(I_DATE,'dd/mm/rrrr');
    select to_date(varvalue,'dd/mm/rrrr') into V_CURRDATE from sysvar where varname = 'CURRDATE';


OPEN PV_REFCURSOR
  FOR
    select cf.fullname, cf.custodycd, main.txdate, main.cleardt,
        sum(main.exeamt) exeamt,
        sum((main.exeamt) - ((main.amt) + (main.feeamt) + (main.aamt))) adamt
    from (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf, afmast af,AFTYPE AFT,
    (
        select od.afacctno acctno, od.txdate, od.cleardate cleardt, od.txdate oddate, max(nvl(ad.amt,0)) amt, max(nvl(ad.feeamt,0)) feeamt,
        sum(od.exeamt) exeamt, nvl(max(ad.cleardt - ad.txdate),0) ndate, sum(nvl(adt.aamt,0)) aamt
        from
        (
            /*SELECT OD.AFACCTNO, OD.TXDATE, OD.ORDERID,
                round(OD.EXECAMT- (case when od.feeacr > 0 then od.feeacr else (ROUND(ODT.DEFFEERATE,5)*od.EXECAMT)/100 end )
                -((od.EXECAMT*(case when od.taxrate > 0 then od.taxrate else (case when cf.vat = 'Y' then ROUND(TO_NUMBER(SYS.VARVALUE),5) else 0 end) end))/100)) exeamt,
                STS.CLEARDATE
            FROM VW_ODMAST_ALL OD, VW_STSCHD_ALL STS, ODTYPE ODT, SYSVAR SYS, cfmast cf, afmast af
            WHERE  OD.ORDERID = STS.ORGORDERID AND STS.DUETYPE IN ('RM', 'RS')
                AND STS.DELTD = 'N' AND OD.DELTD = 'N'
                AND ODT.ACTYPE = OD.ACTYPE and cf.custid = af.custid
                and od.AFACCTNO = af.acctno
                AND SYS.GRNAME = 'SYSTEM' AND SYS.VARNAME = 'ADVSELLDUTY'
                AND INSTR(OD.EXECTYPE,'S') > 0
                AND OD.EXECAMT > 0
                AND STS.CLEARDATE > V_IN_DATE AND OD.TXDATE <= V_IN_DATE*/
            SELECT OD.AFACCTNO, OD.TXDATE, OD.ORDERID,
                round(OD.EXECAMT- (case when od.feeacr > 0 then od.feeacr else (ROUND(ODT.DEFFEERATE,5)*od.EXECAMT)/100 end )
                -((od.EXECAMT*(case when od.taxrate > 0 then od.taxrate else (case when cf.vat = 'Y' then ROUND(TO_NUMBER(SYS.VARVALUE),5) else 0 end) end))/100)) exeamt,
                STS.CLEARDATE
            FROM ODMAST OD, STSCHD STS, ODTYPE ODT, SYSVAR SYS, cfmast cf, afmast af
            WHERE  OD.ORDERID = STS.ORGORDERID AND STS.DUETYPE IN ('RM', 'RS')
                AND STS.DELTD = 'N' AND OD.DELTD = 'N'
                AND ODT.ACTYPE = OD.ACTYPE and cf.custid = af.custid
                and od.AFACCTNO = af.acctno
                AND SYS.GRNAME = 'SYSTEM' AND SYS.VARNAME = 'ADVSELLDUTY'
                AND INSTR(OD.EXECTYPE,'S') > 0
                AND OD.EXECAMT > 0
                AND STS.CLEARDATE > V_IN_DATE AND OD.TXDATE <= V_IN_DATE
            union
            SELECT OD.AFACCTNO, OD.TXDATE, OD.ORDERID,
                round(OD.EXECAMT- (case when od.feeacr > 0 then od.feeacr else (ROUND(ODT.DEFFEERATE,5)*od.EXECAMT)/100 end )
                -((od.EXECAMT*(case when od.taxrate > 0 then od.taxrate else (case when cf.vat = 'Y' then ROUND(TO_NUMBER(SYS.VARVALUE),5) else 0 end) end))/100)) exeamt,
                STS.CLEARDATE
            FROM ODMASTHIST  OD, STSCHDHIST STS, ODTYPE ODT, SYSVAR SYS, cfmast cf, afmast af
            WHERE  OD.ORDERID = STS.ORGORDERID AND STS.DUETYPE IN ('RM', 'RS')
                AND STS.DELTD = 'N' AND OD.DELTD = 'N'
                AND ODT.ACTYPE = OD.ACTYPE and cf.custid = af.custid
                and od.AFACCTNO = af.acctno
                AND SYS.GRNAME = 'SYSTEM' AND SYS.VARNAME = 'ADVSELLDUTY'
                AND INSTR(OD.EXECTYPE,'S') > 0
                AND OD.EXECAMT > 0
                AND STS.CLEARDATE > V_IN_DATE AND OD.TXDATE <= V_IN_DATE
        ) OD
        left join
        (
            select a.acctno, a.txdate, a.cleardt, a.oddate, adt.orderid,
                max(a.amt) amt, max(a.feeamt) feeamt
            from adschd a , adschddtl adt
            WHERE a.TXDATE =  V_IN_DATE and a.deltd <> 'Y'
                and a.txnum = adt.txnum
                and a.txdate = adt.txdate
            group by a.acctno, a.txdate, a.cleardt, a.oddate, adt.orderid
            union all
            select a.acctno, a.txdate, a.cleardt, a.oddate, adt.orderid,
                max(a.amt) amt, max(a.feeamt) feeamt
            from adschdhist a, adschddtl adt
            WHERE a.TXDATE = V_IN_DATE and a.deltd <> 'Y'
                and a.txnum = adt.txnum
                and a.txdate = adt.txdate
            group by a.acctno, a.txdate, a.cleardt, a.oddate, adt.orderid
        ) ad
        on ad.orderid = od.orderid
        left join (select orderid, sum(aamt) aamt from adschddtl where deltd = 'N'
            and txdate < V_IN_DATE
            group by orderid) adt
            on od.orderid = adt.orderid
        group by od.afacctno, od.txdate, od.cleardate, od.txdate
    ) main
    where cf.custid = af.custid
        and main.acctno = af.acctno
        AND AF.ACTYPE=AFT.ACTYPE
        AND AFT.PRODUCTTYPE LIKE V_STRAFTYPE
        AND af.acctno LIKE V_STRPV_AFACCTNO
        and cf.custodycd = V_STRPV_CUSTODYCD
    group by cf.fullname, cf.custodycd,
        main.txdate, main.cleardt
;

EXCEPTION
   WHEN OTHERS
   THEN

      RETURN;
End;
 
 
 
 
/
