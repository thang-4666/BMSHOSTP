SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "DF0057" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   BBRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   I_DATE         IN       VARCHAR2,
   P_RRTYPE       IN       VARCHAR2,
   PV_CUSTODYCD   IN       VARCHAR2,
   PV_AFACCTNO    IN       VARCHAR2,
   PV_NUM      IN          VARCHAR2
   )
IS
   V_STROPTION      VARCHAR2 (5);            -- A: ALL; B: BRANCH; S: SUB-BRANCH
   V_STRI_TYPE      VARCHAR2 (5);
   l_BANKNAME   varchar2(100);
   V_I_DATE       DATE;
   v_CUSTODYCD    varchar2(100);
   v_AFAcctno     varchar2(100);
   V_STRNUM       VARCHAR2(20);
   v_RRTYPE    varchar2(4);
   l_BRID_FILTER        VARCHAR2(50);

   BEGIN

   V_STROPTION := OPT;
      l_BANKNAME:=P_RRTYPE; -- ALL, BVSC, CF.SHORTNAME

    IF (V_STROPTION = 'A') THEN
      l_BRID_FILTER := '%';
    ELSif (V_STROPTION = 'B') then
        select brgrp.mapid into l_BRID_FILTER from brgrp where brgrp.brid = BBRID;
    else
        l_BRID_FILTER := BBRID;
    END IF;


    IF (PV_CUSTODYCD <> 'ALL' OR PV_CUSTODYCD <> '' OR PV_CUSTODYCD <> NULL) THEN
        v_CUSTODYCD := PV_CUSTODYCD;
    ELSE
        v_CUSTODYCD  := '%';
    END IF;

    IF (PV_AFACCTNO <> 'ALL' OR PV_AFACCTNO <> '' OR PV_AFACCTNO <> NULL) THEN
        v_AFAcctno := PV_AFACCTNO;
    ELSE
        v_AFAcctno  := '%';
    END IF;

   IF (PV_NUM ='ALL') THEN
      V_STRNUM :='%';
   ELSE
      V_STRNUM := PV_NUM;
   END IF;

 IF (P_RRTYPE <> 'ALL' OR P_RRTYPE <> '' OR P_RRTYPE <> NULL) THEN
        v_RRTYPE := P_RRTYPE;
    ELSE
        v_RRTYPE  := '%';
    END IF;


V_I_DATE := TO_DATE (I_DATE,'DD/MM/RRRR');


OPEN PV_REFCURSOR
FOR

SELECT case when a.rrtype = 'C' then cspks_system.fn_get_sysvar('SYSTEM','COMPANYSHORTNAME') else cf.shortname end RRNAME, a.*, BBRID v_strbrid,
       case WHEN P_RRTYPE = 'ALL' THEN 'ALL'
            when a.rrtype = 'C' then cspks_system.fn_get_sysvar('SYSTEM','COMPANYSHORTNAME') else cf.fullname end RRFULLNAME
FROM (

 SELECT df.txdate opndate,LNM.RRTYPE,LNM.CUSTBANK,CF.CUSTODYCD, AF.ACCTNO AFACCTNO,df.acctno, LNM.ACCTNO LNACCTNO, SB.SYMBOL
    , parvalue ,SE.NAMT TRADE,
     CASE WHEN sb.markettype = '001' AND sb.sectype IN ('003','006','222','333','444') THEN utf8nums.c_const_df_marketname
    WHEN  nvl(sb.tradeplace,'') = '001' THEN ' HOSE'
    WHEN  nvl(sb.tradeplace,'') = '002' THEN ' HNX'
    WHEN  nvl(sb.tradeplace,'') = '005' THEN ' UPCOM'  END tradeplace,
        cf.fullname, cf.idcode, cf.idplace, cf.iddate, cf.address, cf.phone, cf.fax

    FROM DFTYPE DFT, AFMAST AF, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, BBRID, TLGOUPS)=0) CF, vw_lnmast_all LNM, SBSECURITIES SB,   vw_dfmast_all DF, CFMAST CFB,
    ( SELECT max(txdate) txdate, max(txnum) txnum , max(acctno) acctno , max(namt) namt
        FROM vw_dftran_all v, apptx a WHERE v.txcd = a.txcd and a.apptype ='DF' and tltxcd = '2610'
        and field = 'SENDVSDQTTY' and deltd <> 'Y'
        group by acctno) SE
    WHERE DF.ACTYPE=DFT.ACTYPE AND DF.AFACCTNO = AF.ACCTNO AND AF.CUSTID = CF.CUSTID
   AND SE.acctno=DF.acctno
    AND DF.LNACCTNO = LNM.ACCTNO AND DF.CODEID = SB.CODEID
    AND DFT.ISVSD='Y'
    AND df.txdate >= V_I_DATE AND df.txdate <= V_I_DATE
    AND LNM.CUSTBANK = CFB.CUSTID(+)
    AND CF.CUSTODYCD LIKE v_CUSTODYCD
    AND AF.ACCTNO LIKE v_AFAcctno
    AND df.groupid LIKE V_STRNUM
    and case when l_BANKNAME = 'ALL' then 1
                when l_BANKNAME = cspks_system.fn_get_sysvar('SYSTEM','COMPANYSHORTNAME') and LNM.rrtype = 'C' then 1
                when cfB.shortname = l_BANKNAME and LNM.rrtype = 'B' then 1
            else 0 end = 1
    AND case when V_STROPTION = 'A' then 1 else instr(l_BRID_FILTER,substr(AF.ACCTNO,1,4)) end  <> 0
    union all

    select se.txdate opndate, NULL RRTYPE, NULL CUSTBANK, CF.CUSTODYCD, AF.ACCTNO AFACCTNO, NULL acctno, NULL LNACCTNO,
        SB.SYMBOL, parvalue, SE.NAMT TRADE,
     CASE WHEN sb.markettype = '001' AND sb.sectype IN ('003','006','222','333','444') THEN utf8nums.c_const_df_marketname
    WHEN  nvl(sb.tradeplace,'') = '001' THEN ' HOSE'
    WHEN  nvl(sb.tradeplace,'') = '002' THEN ' HNX'
    WHEN  nvl(sb.tradeplace,'') = '005' THEN ' UPCOM'  END tradeplace,
        cf.fullname, cf.idcode, cf.idplace, cf.iddate, cf.address, cf.phone, cf.fax

    FROM AFMAST AF, CFMAST CF, SBSECURITIES SB,
    (
        select txdate, acctno, namt, codeid, symbol, afacctno
        from vw_setran_gen
        where tltxcd = '2232' and deltd <> 'Y' and field in ('TRADE')
        AND txdate >= V_I_DATE AND txdate <= V_I_DATE
    ) SE
    WHERE AF.CUSTID = CF.CUSTID
    AND SE.afacctno = af.acctno AND SE.codeid = SB.CODEID
    AND CF.CUSTODYCD LIKE v_CUSTODYCD
    AND AF.ACCTNO LIKE v_AFAcctno
) a, cfmast cf
where
a.custbank = cf.custid(+)
order by tradeplace, RRNAME, a.custodycd, a.afacctno, a.lnacctno

;

EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;                                                              -- PROCEDURE

 
 
 
 
/
