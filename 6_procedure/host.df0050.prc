SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "DF0050" (
   PV_REFCURSOR             IN OUT   PKG_REPORT.REF_CURSOR,
   OPT                      IN       VARCHAR2,
   BBRID                     IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   I_DATE         IN       VARCHAR2,
   PV_AFACCTNO    IN       VARCHAR2,
   GROUPID        IN       VARCHAR2
       )
IS

    V_STROPTION         VARCHAR2  (5);
    V_STRBRID           VARCHAR2  (4);
    v_GROUPID    varchar2(100);
    v_AFAcctno     varchar2(100);
    l_BRID_FILTER        VARCHAR2(50);
    v_ToDate date;

BEGIN
    -- GET REPORT'S PARAMETERS
    V_STROPTION := OPT;

    IF V_STROPTION = 'A' then
        V_STRBRID := '%';
    ELSIF V_STROPTION = 'B' then
        V_STRBRID := substr(BBRID,1,2) || '__' ;
    else
        V_STRBRID:=BBRID;
    END IF;

        IF (V_STROPTION = 'A') THEN
  l_BRID_FILTER := '%';
ELSE if (V_STROPTION = 'B') then
        select brgrp.mapid into l_BRID_FILTER from brgrp where brgrp.brid = BBRID;
    else
        l_BRID_FILTER := BBRID;
    end if;
END IF;

    IF (PV_AFACCTNO <> 'ALL' OR PV_AFACCTNO <> '' OR PV_AFACCTNO <> NULL) THEN
        v_AFAcctno := PV_AFACCTNO;
    ELSE
        v_AFAcctno  := '%';
    END IF;

    IF (GROUPID <> 'ALL' OR GROUPID <> '' OR GROUPID <> NULL) THEN
        v_GROUPID := GROUPID;
    ELSE
        v_GROUPID  := '%';
    END IF;
    v_ToDate:= to_date(I_DATE,'DD/MM/RRRR');

OPEN PV_REFCURSOR FOR
    SELECT A.*, GREATEST (NVL(CFLM.LMAMT,0) , NVL(CFL.LMAMT,0)) LIMITAMT FROM
    (
            SELECT DF.TXDATE,DF.GROUPID, DF.ORGAMT,DFT.ACTYPE,CF.CUSTID, AF.ACCTNO, CF.FULLNAME, CF.IDCODE, CF.IDDATE, CF.IDPLACE, CF.ADDRESS, CF.CUSTODYCD,
            LN.RRTYPE, NVL(LN.CUSTBANK,'') CUSTBANK, NVL(LN.CIACCTNO,'') CIACCTNO, LN.CFRATE2, LN.RATE2, LNM.rlsdate, lnm.overduedate
            FROM AFMAST AF , DFTYPE DFT, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, BBRID, TLGOUPS)=0) CF, LNTYPE LN, DFGROUP DF, LNSCHD LNM
                WHERE CF.CUSTID = AF.CUSTID AND AF.ACCTNO = DF.AFACCTNO AND DF.ACTYPE = DFT.ACTYPE and DFT.LNTYPE=LN.ACTYPE
                    AND DF.LNACCTNO = LNM.ACCTNO AND REFTYPE='P'

    ) A, CFLIMITEXT CFLM, CFLIMIT CFL
    WHERE A.CUSTBANK = CFLM.BANKID (+) AND A.CUSTID = CFLM.CUSTID(+)
    AND A.CUSTBANK = CFL.BANKID (+)
    AND A.TXDATE = v_ToDate AND
    case when V_STROPTION = 'A' then 1 else instr(l_BRID_FILTER,substr(A.ACCTNO,1,4)) end  <> 0
    AND a.groupid like v_GROUPID

    ;


EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;

 
 
 
 
/
