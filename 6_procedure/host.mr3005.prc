SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "MR3005" (
   PV_REFCURSOR             IN OUT   PKG_REPORT.REF_CURSOR,
   OPT                      IN       VARCHAR2,
   pv_BRID                     IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   PV_CUSTODYCD             IN       VARCHAR2,
   PV_AFACCTNO              IN       VARCHAR2
   )
IS
-- MODIFICATION HISTORY
-- BAO CAO TONG HOP MARGIN CALL THEO NGAY
-- PERSON   DATE  COMMENTS
-- THENN    16-MAR-2012  CREATED
-- ---------   ------  -------------------------------------------
   V_STROPTION         VARCHAR2 (5);            -- A: ALL; B: BRANCH; S: SUB-BRANCH
   V_CUSTODYCD         VARCHAR2(100);
   V_AFACCTNO          VARCHAR2(100);
   V_CURRDATE          VARCHAR2(100);
   V_INBRID        VARCHAR2(4);
   V_STRBRID      VARCHAR2 (50);
  


BEGIN
/*
    V_STROPTION := OPT;

    IF (V_STROPTION <> 'A') AND (BRID <> 'ALL')
    THEN
         V_STRBRID := BRID;
    ELSE
         V_STRBRID := '%%';
    END IF;*/
   V_STROPTION := upper(OPT);
   V_INBRID := pv_BRID;
    if(V_STROPTION = 'A') then
        V_STRBRID := '%%';
    else
        if(V_STROPTION = 'B') then
            select br.brid into V_STRBRID from brgrp br where  br.brid = V_INBRID;
        else
            V_STRBRID := V_INBRID;
        end if;
    end if;

-- GET REPORT'S PARAMETERS

    IF (PV_CUSTODYCD <> 'ALL' OR PV_CUSTODYCD <> '')
    THEN
         V_CUSTODYCD := PV_CUSTODYCD;
    ELSE
         V_CUSTODYCD := '%%';
    END IF;

    IF (PV_AFACCTNO <> 'ALL' OR PV_AFACCTNO <> '')
    THEN
         V_AFACCTNO := PV_AFACCTNO;
    ELSE
         V_AFACCTNO := '%%';
    END IF;

    SELECT TO_CHAR(getcurrdate,'DD/MM/YYYY') INTO V_CURRDATE FROM DUAL;

    OPEN PV_REFCURSOR
    FOR
        SELECT * FROM
        (
            SELECT V_CURRDATE CURRDATE, CF.CUSTODYCD, AF.ACCTNO AFACCTNO, CF.FULLNAME,
                TO_CHAR(LN.RLSDATE,'DD/MM/YYYY') RLSDATE, V.TADF SECAMOUNT, V.DDF LOANAMT, V.RTTDF CURRLNRATE,
                DF.MRATE LNRATE, ROUND(V.ODSELLDF) ADDAMOUNT, 'DF' LOANTYPE
            FROM DFGROUP DF, LNMAST LN, AFMAST AF, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF,
                V_GETGRPDEALFORMULAR V,AFTYPE AFT
            WHERE DF.LNACCTNO= LN.ACCTNO AND DF.AFACCTNO= AF.ACCTNO AND AF.CUSTID= CF.CUSTID
            AND AF.ACTYPE= AFT.ACTYPE
            
                AND DF.GROUPID=V.GROUPID(+)
                AND V.ODDF>0 AND V.RTTDF <= DF.MRATE
                AND AF.ACCTNO = V_AFACCTNO
                AND (af.brid LIKE V_STRBRID or instr(V_STRBRID,af.brid) <> 0 )
            UNION ALL
            SELECT V_CURRDATE CURRDATE, MR.CUSTODYCD, MR.ACCTNO AFACCTNO, CF.FULLNAME, '' RLSDATE,
                ROUND(LEAST(MR.SEASS, MR.MRCRLIMITMAX-dfodamt),0) SECAMOUNT,
                ROUND(case when nvl(MR.OUTSTANDING,0) > 0 then 0 else  abs(nvl(MR.OUTSTANDING,0)) end,0) LOANAMT,
                MR.MARGINRATE CURRLNRATE,
                MR.MRMRATE LNRATE, ROUND(MR.RTNAMT,0) ADDAMOUNT, 'MR' LOANTYPE
            FROM VW_MR0003 MR, CFMAST CF,AFTYPE AFT,
                (SELECT AF.ACCTNO,AF.ACTYPE FROM AFMAST AF WHERE (af.brid LIKE V_STRBRID or instr(V_STRBRID,af.brid) <> 0 )) AF
            WHERE MR.CUSTODYCD = CF.CUSTODYCD AND MR.ACCTNO = AF.ACCTNO
                AND MR.ACCTNO = V_AFACCTNO
                AND AF.ACTYPE=AFT.ACTYPE
               
        ) A
        ORDER BY A.LOANTYPE DESC, A.RLSDATE
    ;
EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;
 
 
 
 
/
