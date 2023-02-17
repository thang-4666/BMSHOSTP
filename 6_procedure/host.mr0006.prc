SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "MR0006" (
   PV_REFCURSOR             IN OUT   PKG_REPORT.REF_CURSOR,
   OPT                      IN       VARCHAR2,
   pv_BRID                  IN       VARCHAR2,
   TLGOUPS                  IN       VARCHAR2,
   TLSCOPE                  IN       VARCHAR2,
     I_DATE                 IN     VARCHAR2,
   PV_CUSTODYCD             IN       VARCHAR2,
   PV_AFACCTNO              IN       VARCHAR2,
   PV_AFTYPE                IN       VARCHAR2
   )
IS



-- MODIFICATION HISTORY
-- PERSON   DATE  COMMENTS
-- ---------   ------  -------------------------------------------
   V_STROPTION         VARCHAR2 (10);            -- A: ALL; B: BRANCH; S: SUB-BRANCH
   V_CUSTODYCD         VARCHAR2(100);
   V_AFACCTNO          VARCHAR2(100);
   V_CURRDATE          VARCHAR2(100);
   V_INBRID        VARCHAR2(10);
   V_STRBRID      VARCHAR2 (50);
     V_DATE DATE;
     V_AFTYPE  VARCHAR2(50);


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

        IF (PV_AFTYPE IS NULL OR UPPER(PV_AFTYPE) = 'ALL')
   THEN
      V_AFTYPE := '%%';
   ELSE
      V_AFTYPE := PV_AFTYPE;
      END IF;

    SELECT TO_CHAR(getcurrdate,'DD/MM/YYYY') INTO V_CURRDATE FROM DUAL;
        V_DATE:= to_date(I_DATE,'DD/MM/YYYY');

    OPEN PV_REFCURSOR
    FOR

SELECT  CF.CUSTODYCD, CF.FULLNAME, CF.ADDRESS, NVL(CF.MOBILESMS,'') MOBILE,LNT.WARNINGDAYS,
        LN.TRFACCTNO, LND.ACCTNO, SUM(LND.NML) AMT,
        LND.OVERDUEDATE,
                 fn_get_prevdate(LND.OVERDUEDATE,LNT.Warningdays) reportdate,
       /* sum(lnd.INTNMLACR + ROUND(lnd.NML * lnd.RATE1 / 100 * TO_NUMBER(LND.OVERDUEDATE + 1 -lnd.acrdate)
                            /(Case When LN.DRATE= 'D1' then  30
                                       When LN.DRATE= 'D2' then  TO_NUMBER(TO_CHAR(LAST_DAY(TO_DATE(LND.OVERDUEDATE + 1,'dd/mm/rrrr')),'dd'))
                                       When LN.DRATE= 'Y1' then  360
                                       When LN.DRATE= 'Y2' then
                                               TO_DATE(CONCAT('31/12/',SUBSTR(LND.OVERDUEDATE + 1,7)),'dd/mm/rrrr') - TO_DATE(CONCAT('01/01/',SUBSTR(LND.OVERDUEDATE + 1,7)),'dd/mm/rrrr') + 1
                                       When LN.DRATE= 'Y3' then  365
                                   End
                                   )
                           ,4)) INT,
       sum( lnd.FEEINTNMLACR + ROUND(lnd.NML * lnd.CFRATE1 / 100 * TO_NUMBER(LND.OVERDUEDATE + 1 -lnd.acrdate)
                / (Case When LN.DRATE= 'D1' then  30
                                       When LN.DRATE= 'D2' then  TO_NUMBER(TO_CHAR(LAST_DAY(TO_DATE(LND.OVERDUEDATE + 1,'dd/mm/rrrr')),'dd'))
                                       When LN.DRATE= 'Y1' then  360
                                       When LN.DRATE= 'Y2' then
                                               TO_DATE(CONCAT('31/12/',SUBSTR(LND.OVERDUEDATE + 1,7)),'dd/mm/rrrr') - TO_DATE(CONCAT('01/01/',SUBSTR(LND.OVERDUEDATE + 1,7)),'dd/mm/rrrr') + 1
                                       When LN.DRATE= 'Y3' then  365
                                   End
                                   )
          ,4)) FEE*/
     (CASE WHEN LND.ACRDATE<LND.DUEDATE THEN
 --TY LE RATE1
 (  sum(LND.INTNMLACR + ROUND((LND.NML * LND.RATE1 / 100 * TO_NUMBER(LND.DUEDATE -lnD.acrdate)+LND.NML * LND.RATE2 / 100 * TO_NUMBER(LND.OVERDUEDATE  -LND.DUEDATE))
                            /(Case When LN.DRATE= 'D1' then  30
                                       When LN.DRATE= 'D2' then  TO_NUMBER(TO_CHAR(LAST_DAY(TO_DATE(LND.OVERDUEDATE + 1,'dd/mm/rrrr')),'dd'))
                                       When LN.DRATE= 'Y1' then  360
                                       When LN.DRATE= 'Y2' then
                                               TO_DATE(CONCAT('31/12/',SUBSTR(LND.OVERDUEDATE + 1,7)),'dd/mm/rrrr') - TO_DATE(CONCAT('01/01/',SUBSTR(LND.OVERDUEDATE + 1,7)),'dd/mm/rrrr') + 1
                                       When LN.DRATE= 'Y3' then  365
                                   End
                                   )
                           ,4))+
       sum(lnD.FEEINTNMLACR + ROUND((lnD.NML * lnD.CFRATE1 / 100 * TO_NUMBER(LND.DUEDATE -lnD.acrdate)+lnD.NML * lnD.CFRATE2 / 100 * TO_NUMBER(LND.OVERDUEDATE  -lnD.DUEDATE))
                / (Case When LN.DRATE= 'D1' then  30
                                       When LN.DRATE= 'D2' then  TO_NUMBER(TO_CHAR(LAST_DAY(TO_DATE(LND.OVERDUEDATE + 1,'dd/mm/rrrr')),'dd'))
                                       When LN.DRATE= 'Y1' then  360
                                       When LN.DRATE= 'Y2' then
                                               TO_DATE(CONCAT('31/12/',SUBSTR(LND.OVERDUEDATE + 1,7)),'dd/mm/rrrr') - TO_DATE(CONCAT('01/01/',SUBSTR(LND.OVERDUEDATE + 1,7)),'dd/mm/rrrr') + 1
                                       When LN.DRATE= 'Y3' then  365
                                   End
                                   )
          ,4)))
 --TY LE RATE2
 ELSE ( sum(lnD.INTNMLACR + ROUND(lnD.NML * lnD.RATE2 / 100 * TO_NUMBER(LND.OVERDUEDATE  -lnD.acrdate)
                            /(Case When LN.DRATE= 'D1' then  30
                                       When LN.DRATE= 'D2' then  TO_NUMBER(TO_CHAR(LAST_DAY(TO_DATE(LND.OVERDUEDATE + 1,'dd/mm/rrrr')),'dd'))
                                       When LN.DRATE= 'Y1' then  360
                                       When LN.DRATE= 'Y2' then
                                               TO_DATE(CONCAT('31/12/',SUBSTR(LND.OVERDUEDATE + 1,7)),'dd/mm/rrrr') - TO_DATE(CONCAT('01/01/',SUBSTR(LND.OVERDUEDATE + 1,7)),'dd/mm/rrrr') + 1
                                       When LN.DRATE= 'Y3' then  365
                                   End
                                   )
                           ,4))+
       sum( lnD.FEEINTNMLACR + ROUND(lnD.NML * lnD.CFRATE2 / 100 * TO_NUMBER(LND.OVERDUEDATE  -lnD.acrdate)
                / (Case When LN.DRATE= 'D1' then  30
                                       When LN.DRATE= 'D2' then  TO_NUMBER(TO_CHAR(LAST_DAY(TO_DATE(LND.OVERDUEDATE + 1,'dd/mm/rrrr')),'dd'))
                                       When LN.DRATE= 'Y1' then  360
                                       When LN.DRATE= 'Y2' then
                                               TO_DATE(CONCAT('31/12/',SUBSTR(LND.OVERDUEDATE + 1,7)),'dd/mm/rrrr') - TO_DATE(CONCAT('01/01/',SUBSTR(LND.OVERDUEDATE + 1,7)),'dd/mm/rrrr') + 1
                                       When LN.DRATE= 'Y3' then  365
                                   End
                                   ) ,4))) END) FEE
FROM VW_LNSCHD_ALL LND, VW_LNMAST_ALL LN, LNTYPE LNT, AFMAST AF, AFTYPE AFT,
 (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF
WHERE LN.ACTYPE=LNT.ACTYPE
      AND LND.ACCTNO=LN.ACCTNO
      AND GETCURRDATE< LND.OVERDUEDATE
      --AND fn_get_prevdate(LND.OVERDUEDATE,LNT.Warningdays)<=GETCURRDATE
      AND LND.NML>0
      and lnd.RLSDATE is not null
      AND AF.ACCTNO=LN.TRFACCTNO
      AND AF.CUSTID=CF.CUSTID
      AND LN.FTYPE<>'DF'
            AND fn_get_prevdate(LND.OVERDUEDATE,LNT.Warningdays) = V_DATE
      AND CF.CUSTODYCD LIKE V_CUSTODYCD
      AND AF.ACCTNO LIKE V_AFACCTNO
      AND CF.BRID LIKE V_STRBRID
      AND AFT.ACTYPE = AF.ACTYPE
      AND AFT.PRODUCTTYPE LIKE V_AFTYPE
GROUP BY LN.TRFACCTNO, LND.ACCTNO,LND.OVERDUEDATE, CF.CUSTODYCD, CF.FULLNAME, CF.ADDRESS, NVL(CF.MOBILESMS,''),
LNT.WARNINGDAYS,LND.INTNMLACR,LND.NML,LND.RATE1,LND.CFRATE1,LND.INTNMLACR, LND.ACRDATE,LND.DUEDATE

ORDER BY CF.CUSTODYCD, LND.ACCTNO
    ;

EXCEPTION

   WHEN OTHERS
   THEN
      RETURN;
END;

 
 
 
 
/
