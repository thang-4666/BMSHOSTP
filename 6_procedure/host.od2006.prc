SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "OD2006" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   pv_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2,
   PV_CUSTODYCD   IN       VARCHAR2,
   PV_AFACCTNO    IN       VARCHAR2,
   TLID           IN       VARCHAR2,
   RECUSTODYCD    IN       VARCHAR2
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
    V_INBRID := pv_BRID;

   if(V_STROPTION = 'A') then
        V_STRBRID := '%';
    else
        if(V_STROPTION = 'B') then
            select br.mapid into V_STRBRID from brgrp br where  br.brid = V_INBRID;
        else
            V_STRBRID := pv_BRID;
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

   IF RECUSTODYCD  = 'ALL' THEN
    v_RECUSTODYCD := '%';
   ELSE
    v_RECUSTODYCD  :=     upper(replace(RECUSTODYCD,'.',''));
   END IF;


   -- END OF GETTING REPORT'S PARAMETERS
   -- GET REPORT'S DATA

      OPEN PV_REFCURSOR
       FOR
        SELECT A.*, CF.FULLNAME SALENAME FROM (
            SELECT cf.custodycd, cf.fullname, v.AFACCTNO,aft.actype, aft.typename, v.TXDATE, v.TXTIME, v.TXNUM, sb.CODEID, sb.symbol, v.exectype, a.cdcontent,
            execqtty, execamt, feeacr, tlg.grpid, TLG.GRPNAME,SUBSTR(RE.REACCTNO,1,10) SALECARE

            FROM vw_odmast_all v, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf, afmast af, aftype aft, sbsecurities sb, TLGROUPS TLG,allcode a,
            (select * from reaflnk RE, RETYPE ret WHERE SUBSTR(RE.REACCTNO, 11,4) = RET.ACTYPE AND REROLE = 'RM' and re.status ='A') RE
            WHERE v.EXECQTTY > 0 AND v.DELTD <> 'Y'
            AND CF.CUSTID = RE.AFACCTNO(+)
            and v.afacctno = af.acctno and af.custid = cf.custid
            and af.actype = aft.actype and v.codeid = sb.codeid
            AND AF.CAREBY = TLG.GRPID
            and a.cdname = 'EXECTYPE' and a.cdtype = 'OD' and a.cdval=v.exectype
            AND V.TXDATE BETWEEN TO_DATE(F_DATE,'DD/MM/RRRR') AND TO_DATE(T_DATE,'DD/MM/RRRR')
            AND CF.CUSTODYCD LIKE v_CustodyCD
            AND AF.ACCTNO LIKE v_AFAcctno
            AND (substr(af.acctno,1,4) LIKE V_STRBRID OR instr(V_STRBRID,substr(af.acctno,1,4))<> 0)
            AND NVL(SUBSTR(RE.REACCTNO,1,10),'XXXX') LIKE v_RECUSTODYCD
            and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid LIKE v_TLID)
        ) A, CFMAST CF WHERE A.SALECARE = CF.CUSTID (+)
        order by txdate, txtime
         ;
 EXCEPTION
   WHEN OTHERS
   THEN
    --INSERT INTO TEMP_BUG(TEXT) VALUES('CF0001');COMMIT;
      RETURN;
END;                                                              -- PROCEDURE

 
 
 
 
/
