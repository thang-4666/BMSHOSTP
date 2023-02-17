SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "CF2006" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   pv_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   PV_CUSTODYCD   IN       VARCHAR2,
   PV_AFACCTNO    IN       VARCHAR2,
   AFTYPE         IN       VARCHAR2,
   LNTYPE         IN       VARCHAR2,
   ODTYPE         IN       VARCHAR2,
   TLID           IN       VARCHAR2,
   RECUSTODYCD    IN       VARCHAR2
)
IS

   V_STROPTION        VARCHAR2 (5);       -- A: ALL; B: BRANCH; S: SUB-BRANCH
   V_STRBRID          VARCHAR2 (4);              -- USED WHEN V_NUMOPTION > 0
   V_CIACCTNO           VARCHAR2 (20);
   v_CustodyCD    varchar2(20);
   v_RECUSTODYCD    varchar2(20);
   v_AFAcctno     varchar2(20);
   v_TLID         varchar2(4);
   V_INBRID     varchar2(5);
   v_AFTYPE         varchar2(4);
   v_LNTYPE         varchar2(4);
   v_ODTYPE         varchar2(4);

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

   IF LNTYPE  = 'ALL' THEN
    v_LNTYPE := '%';
   ELSE
    v_LNTYPE  :=     upper(replace(LNTYPE,'.',''));
   END IF;

   IF ODTYPE  = 'ALL' THEN
    v_ODTYPE := '%';
   ELSE
    v_ODTYPE  :=     upper(replace(ODTYPE,'.',''));
   END IF;

   IF AFTYPE  = 'ALL' THEN
    v_AFTYPE := '%';
   ELSE
    v_AFTYPE  :=     upper(replace(AFTYPE,'.',''));
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
            SELECT CF.CUSTODYCD, CF.FULLNAME, AF.ACCTNO, AFT.ACTYPE, AFT.TYPENAME, NVL(LN.ACTYPE,'') LNTYPE, odt.typename ODTYPE,
                        AF.COREBANK, AF.CAREBY, TLG.GRPNAME, SUBSTR(RE.REACCTNO,1,10) SALECARE
                    FROM (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF,
                     AFMAST AF, AFTYPE AFT, LNMAST LN , AFIDTYPE AFI, TLGROUPS TLG,odtype odt,
                        (select * from reaflnk RE, RETYPE ret WHERE SUBSTR(RE.REACCTNO, 11,4) = RET.ACTYPE AND REROLE = 'RM' and re.status ='A') RE
                    WHERE CF.CUSTID = AF.CUSTID AND AF.ACTYPE = AFT.ACTYPE
                    AND CF.CUSTID = RE.AFACCTNO(+)
                    AND AF.actype = afi.aftype (+)
                    AND AF.ACCTNO = LN.TRFACCTNO (+)
                    AND AF.CAREBY = TLG.GRPID
                    and afi.actype = odt.actype
                    AND CF.CUSTODYCD LIKE v_CustodyCD
                    AND AF.ACCTNO LIKE v_AFAcctno
                    AND AFT.ACTYPE LIKE v_AFTYPE
                    AND NVL(LN.ACTYPE,'XXXX') LIKE v_LNTYPE
                    AND NVL(AFI.ACTYPE,'XXXX') LIKE v_ODTYPE
                    AND NVL(SUBSTR(RE.REACCTNO,1,10),'XXXX') LIKE v_RECUSTODYCD
                    and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid LIKE v_TLID)
                    AND (substr(af.acctno,1,4) LIKE V_STRBRID OR instr(V_STRBRID,substr(af.acctno,1,4))<> 0)
        ) A, CFMAST CF WHERE A.SALECARE = CF.CUSTID (+)


         ;
 EXCEPTION
   WHEN OTHERS
   THEN
    --INSERT INTO TEMP_BUG(TEXT) VALUES('CF0001');COMMIT;
      RETURN;
END;                                                              -- PROCEDURE
 
 
 
 
/
