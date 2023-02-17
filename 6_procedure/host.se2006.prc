SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "SE2006" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   PV_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2,
   PV_CUSTODYCD   IN       VARCHAR2,
   PV_AFACCTNO    IN       VARCHAR2,
   TLID           IN       VARCHAR2
)
IS

   V_STROPTION        VARCHAR2 (5);       -- A: ALL; B: BRANCH; S: SUB-BRANCH
   V_STRBRID          VARCHAR2 (4);              -- USED WHEN V_NUMOPTION > 0
   V_CIACCTNO           VARCHAR2 (20);
   v_CustodyCD    varchar2(20);
   v_RECUSTODYCD  varchar2(20);
    V_INBRID     varchar2(5);
   v_AFAcctno     varchar2(20);
   v_TLID         varchar2(4);


-- DECLARE PROGRAM VARIABLES AS SHOWN ABOVE
BEGIN


   V_STROPTION := OPT;

    V_INBRID := PV_BRID;

   if(V_STROPTION = 'A') then
        V_STRBRID := '%';
    else
        if(V_STROPTION = 'B') then
            select br.mapid into V_STRBRID from brgrp br where  br.brid = V_INBRID;
        else
            V_STRBRID := PV_BRID;
        end if;
    end if;

   IF PV_CUSTODYCD  = 'ALL' THEN
    v_CustodyCD:= '%';
   ELSE
    v_CustodyCD :=     upper(replace(pv_custodycd,'.',''));
   END IF;

    IF PV_AFACCTNO  = 'ALL' THEN
    v_AFAcctno := '%';
   ELSE
    v_AFAcctno  :=     upper(replace(PV_AFACCTNO,'.',''));
   END IF;

    IF TLID  = 'ALL' THEN
    v_TLID := '%';
   ELSE
    v_TLID  :=     upper(replace(TLID,'.',''));
   END IF;


   -- END OF GETTING REPORT'S PARAMETERS
   -- GET REPORT'S DATA

      OPEN PV_REFCURSOR
       FOR
          select v.txdate, v.custodycd, v.afacctno, cf.fullname, af.actype, aft.typename,
              V.SYMBOL, V.TRADE, V.receiving, V.RATECL, V.PRICECL, V.SEASS
          from tbl_mr3007_log v, afmast af, (SELECT * FROM CFMAST WHERE INSTR(TLGOUPS, CAREBY)>0)  cf, aftype aft, TLGROUPS TLG
          --,(select * from reaflnk RE, RETYPE ret WHERE SUBSTR(RE.REACCTNO, 11,4) = RET.ACTYPE AND REROLE = 'RM') RE
          where cf.custid = af.custid and cf.custodycd = v.custodycd
          AND V.AFACCTNO = AF.ACCTNO
          and aft.actype = af.actype
          --and v.mramt + v.intmramt > 0
          AND NVL(AF.CAREBY,'XXX') = TLG.GRPID(+)
          --AND V.ACCTNO = RE.AFACCTNO(+)
          AND V.TXDATE BETWEEN TO_DATE(F_DATE,'DD/MM/RRRR') AND TO_DATE(T_DATE,'DD/MM/RRRR')
          AND CF.CUSTODYCD LIKE v_CustodyCD
          AND AF.ACCTNO LIKE v_AFAcctno
          AND AFT.PRODUCTTYPE IN ('NM','QM')
          --AND AFT.MNEMONIC in('Margin','T3')
          and nvl(v.symbol,'xxx') not like 'xxx'
          AND (substr(af.acctno,1,4) LIKE V_STRBRID OR instr(V_STRBRID,substr(af.acctno,1,4))<> 0)
          --and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid LIKE v_TLID)
          order by v.txdate, v.afacctno, v.symbol
         ;
 EXCEPTION
   WHEN OTHERS
   THEN

      RETURN;
END;                                                              -- PROCEDURE
 
 
 
 
/
