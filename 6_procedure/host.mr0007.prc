SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "MR0007"
   (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   pv_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2,
   PV_CUSTODYCD   IN       VARCHAR2,
   PV_AFACCTNO    IN       VARCHAR2,
   AUTOID       IN       VARCHAR2 ,
   PV_AFTYPE    IN       VARCHAR2  DEFAULT 'ALL'
   ) IS

   V_STROPT         VARCHAR2(5);
   V_STRBRID        VARCHAR2(100);
   V_INBRID         VARCHAR2(5);

   V_F_DATE         date;
   V_T_DATE         date;

   V_STRCUSTODYCD   VARCHAR2(20);
   V_STRAFACCTNO    VARCHAR2(20);

   V_AUTOID      VARCHAR2(20);
   V_AFTYPE      VARCHAR2(10);

BEGIN

    V_STROPT := upper(OPT);
    V_INBRID := pv_BRID;
    if(V_STROPT = 'A') then
        V_STRBRID := '%';
    else
        if(V_STROPT = 'B') then
            select br.BRID into V_STRBRID from brgrp br where  br.brid = V_INBRID;
        else
            V_STRBRID := pv_BRID;
        end if;
    end if;

    v_F_date := to_date(F_DATE,'dd/mm/rrrr');
    v_T_date := to_date(T_DATE,'dd/mm/rrrr');

  /*  if(upper(PV_CUSTODYCD) = 'ALL' OR LENGTH(PV_CUSTODYCD) < 1 )then
        V_STRCUSTODYCD := '%';
    else
        V_STRCUSTODYCD := UPPER(PV_CUSTODYCD);
    end if;
*/
   V_STRCUSTODYCD := UPPER(PV_CUSTODYCD);

    if(upper(PV_AFACCTNO) = 'ALL' OR LENGTH(PV_AFACCTNO) < 1 )then
        V_STRAFACCTNO := '%';
    else
        V_STRAFACCTNO := UPPER(PV_AFACCTNO);
    end if;

    if(upper(AUTOID) = 'ALL' OR LENGTH(AUTOID) < 1 )then
        V_AUTOID := '%';
    else
        V_AUTOID := UPPER(AUTOID);
    end if;

    IF(PV_AFTYPE IS NULL OR UPPER(PV_AFTYPE) = 'ALL')
    THEN V_AFTYPE := '%%';
      ELSE
        V_AFTYPE := PV_AFTYPE;
        END IF;
     ---GET REPORT DATA:

OPEN PV_REFCURSOR
FOR

     SELECT V_STRCUSTODYCD CUST, V_STRAFACCTNO ACC,V_AUTOID AU,
            CF.FULLNAME, CF.CUSTODYCD,AF.ACCTNO AFACCTNO,TO_CHAR(LNS.LNSCHDID) LNSCHDID,A0.CDCONTENT PRODUCTTYPE,
            CF.ADDRESS, LNS.ACCTNO LNACCTNO,LNS.INTTYPE,LNS.FRDATE,LNS.TODATE,LNS.ICRULE,LNS.IRRATE,
            LNS.INTBAL,LNS.INTAMT,LNS.CFIRRATE,LNS.FEEINTAMT, ROUND(LNS.IRRATE/360,4) RATE
     FROM (SELECT * FROM LNINTTRAN UNION ALL SELECT * FROM LNINTTRANA) LNS,
          VW_LNMAST_ALL LN, AFMAST AF,  AFTYPE AFT,ALLCODE A0,
          cfmast CF
     WHERE LNS.ACCTNO=LN.ACCTNO
            AND LN.TRFACCTNO=AF.ACCTNO
            AND AF.CUSTID=CF.CUSTID
            AND AF.ACTYPE=AFT.ACTYPE
            AND LN.FTYPE<>'DF'
            AND A0.CDTYPE='CF' AND A0.CDNAME='PRODUCTTYPE'
            AND A0.CDVAL=AFT.PRODUCTTYPE
            AND AF.ACCTNO LIKE V_STRAFACCTNO
            AND CF.CUSTODYCD LIKE V_STRCUSTODYCD
            AND LNS.LNSCHDID LIKE V_AUTOID
            AND LNS.FRDATE BETWEEN v_F_date AND v_T_date
            AND AFT.ACTYPE =AF.ACTYPE
            AND AFT.PRODUCTTYPE LIKE V_AFTYPE
     ORDER BY LNS.LNSCHDID,LNS.FRDATE   ;



EXCEPTION
    WHEN OTHERS THEN
        RETURN ;
END; -- Procedure
 
 
 
 
/
