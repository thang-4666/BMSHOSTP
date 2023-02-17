SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "CF00084" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   PV_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   I_DATE         IN       VARCHAR2,
   PV_CUSTODYCD   IN       VARCHAR2,
   PV_AFACCTNO    IN       VARCHAR2,
   PV_AFTYPE     IN        VARCHAR2
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
   V_STRAFTYPE     VARCHAR2(100);
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


    V_STRPV_CUSTODYCD  := upper(PV_CUSTODYCD);
   IF(PV_AFACCTNO <> 'ALL' AND PV_AFACCTNO IS NOT NULL)
   THEN
        V_STRPV_AFACCTNO := PV_AFACCTNO;
   ELSE
        V_STRPV_AFACCTNO := '%';
   END IF;
    V_IN_DATE       := to_date(I_DATE,'dd/mm/rrrr');
    select to_date(varvalue,'dd/mm/rrrr') into V_CURRDATE from sysvar where varname = 'CURRDATE';

      IF (PV_AFTYPE <> 'ALL' OR PV_AFTYPE <> '')
   THEN
      V_STRAFTYPE :=  PV_AFTYPE;
   ELSE
      V_STRAFTYPE := '%%';
   END IF;


OPEN PV_REFCURSOR
  FOR
    SELECT OD.AFACCTNO, OD.TXDATE, OD.ORDERID,
        io.matchprice, io.matchqtty, io.matchprice * io.matchqtty matchdamt,
       round(case when io.iodfeeacr > 0 then io.iodfeeacr
            else (ROUND(ODT.DEFFEERATE,5)*(io.matchprice * io.matchqtty))/100 end) feeamt,
        round(case when cf.vat = 'Y' then (case when io.iodtaxsellamt > 0
            then io.iodtaxsellamt else ROUND(TO_NUMBER(SYS.VARVALUE)/100,5)*(io.matchprice * io.matchqtty)
            end) else 0 end) vatmat,
        STS.CLEARDATE, io.symbol
    FROM VW_ODMAST_ALL OD, VW_STSCHD_ALL STS, ODTYPE ODT, SYSVAR SYS, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf, afmast af,
        vw_iod_all io,AFTYPE AFT
    WHERE  OD.ORDERID = STS.ORGORDERID AND STS.DUETYPE IN ('RM', 'RS')
      AND STS.DELTD = 'N' AND OD.DELTD = 'N'
      and od.orderid = io.orgorderid
      AND ODT.ACTYPE = OD.ACTYPE and cf.custid = af.custid
      and od.AFACCTNO = af.acctno
      AND SYS.GRNAME = 'SYSTEM' AND SYS.VARNAME = 'ADVSELLDUTY'
      AND INSTR(OD.EXECTYPE,'S') > 0
      AND OD.EXECAMT > 0
      AND AF.ACTYPE=AFT.ACTYPE
      AND AFT.PRODUCTTYPE LIKE V_STRAFTYPE
      AND STS.CLEARDATE > V_IN_DATE AND OD.TXDATE <= V_IN_DATE
      AND AF.ACCTNO LIKE V_STRPV_AFACCTNO
      and cf.custodycd = V_STRPV_CUSTODYCD
;

EXCEPTION
   WHEN OTHERS
   THEN

      RETURN;
End;
 
 
 
 
/
