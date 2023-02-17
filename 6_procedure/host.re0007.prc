SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE re0007 (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   pv_BRID        IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2,
   I_BRIDGD       IN       VARCHAR2,
   CFTYPE         IN       VARCHAR2,
   RECUSTODYCD    IN       VARCHAR2

 )
IS

--BAO CAO GIAO D?CH THEO LO?I KH?CH H?NG
--NGOCVTT 22/05/2015
-- ---------   ------  -------------------------------------------
   V_STROPT     VARCHAR2 (50);            -- A: ALL; B: BRANCH; S: SUB-BRANCH
   V_STRBRID       VARCHAR2 (40);            -- USED WHEN V_NUMOPTION > 0
   V_INBRID         VARCHAR2 (50);

    V_CFTYPE  VARCHAR2(100);

   V_TODATE         DATE;
   V_FROMDATE          DATE;

   V_I_BRIDGD          VARCHAR2(100);
   V_BRNAME            NVARCHAR2(400);
   V_RECUSTODYCD       VARCHAR2(400);
   P_DATE DATE ;

BEGIN


    V_STROPT := OPT;

    IF (V_STROPT <> 'A') AND (pv_BRID <> 'ALL')
    THEN
      V_STRBRID := pv_BRID;
    ELSE
      V_STRBRID := '%%';
    END IF;
    -- GET REPORT'S PARAMETERS

       IF (I_BRIDGD <> 'ALL' OR I_BRIDGD <> '')
   THEN
      V_I_BRIDGD :=  I_BRIDGD;
   ELSE
      V_I_BRIDGD := '%%';
   END IF;


    IF CFTYPE = 'ALL' OR CFTYPE IS NULL THEN
        V_CFTYPE := '%%';
    ELSE
        V_CFTYPE := CFTYPE;
    END IF;

        IF RECUSTODYCD = 'ALL' OR RECUSTODYCD IS NULL THEN
        V_RECUSTODYCD := '%%';
    ELSE
        V_RECUSTODYCD := RECUSTODYCD;
    END IF;

   V_FROMDATE:=TO_DATE(F_DATE,'DD/MM/YYYY');
   V_TODATE:=TO_DATE(T_DATE,'DD/MM/YYYY');

    Begin
    select MAX(lastdate) INTO P_DATE from CFREVIEWLOG where lastdate <=V_TODATE;
    EXCEPTION
      WHEN OTHERS THEN
       P_DATE:=V_TODATE;
   End;
   -- GET REPORT'S DATA
    OPEN  PV_REFCURSOR
     FOR


        SELECT CFT.TYPENAME, CF.CUSTID, CF.CUSTODYCD, CF.FULLNAME,BR.BRID,BR.BRNAME, EMAIL,  MOBILESMS,  ADDRESS,
               NVL(RE.FULLNAME,'') REFULLNAME, SUM(NVL(OD.FEE,0)) FEE, SUM(NVL(OD.AMT,0)) AMT, NVL(CFR.NAV,0) NAV,
               NVL(CFRE.NAV_END,0) NAV_END
        FROM  (SELECT * FROM CFMAST WHERE INSTR(TLGOUPS, CAREBY)>0) CF,
              AFMAST AF,CFTYPE CFT,
              (   SELECT OD.AFACCTNO,
                   SUM(NVL(IO.MATCHQTTY*IO.MATCHPRICE,0)) AMT,
                    SUM(CASE WHEN OD.EXECAMT = 0 THEN 0 ELSE
                    (CASE WHEN IO.IODFEEACR = 0 and OD.TXDATE = getcurrdate THEN ROUND(IO.matchqtty * io.matchprice * ODT.deffeerate / 100, 2)
                    ELSE io.iodfeeacr END)END) FEE
                  FROM ODTYPE ODT,VW_ODMAST_ALL OD
                    INNER JOIN VW_IOD_ALL IO ON OD.ORDERID = IO.ORGORDERID
                  WHERE OD.ACTYPE =ODT.ACTYPE
                    AND OD.DELTD<>'Y'
                    AND OD.TXDATE BETWEEN V_FROMDATE AND V_TODATE
                    AND OD.EXECTYPE IN ('NS','SS','MS','NB','BC')
                    GROUP BY OD.AFACCTNO) OD,

              (   SELECT MAX(CFRE.FULLNAME) FULLNAME, LNK.AFACCTNO, MAX(CFRE.CUSTID) CUSTID
                  FROM REAFLNK LNK, REMAST RE, RETYPE TYP, CFMAST CFRE
                  WHERE LNK.deltd <> 'Y' and lnk.status='A' --AND TYP.REROLE in ('CS')
                  and lnk.frdate <=V_TODATE
                  and nvl(lnk.clstxdate,lnk.todate) > V_FROMDATE
                  AND RE.ACTYPE=TYP.ACTYPE AND RE.CUSTID=CFRE.CUSTID AND RE.ACCTNO=LNK.REACCTNO
                  GROUP BY LNK.AFACCTNO
              ) RE,
              ( SELECT CUSTID, ROUND(SUM(NAV)/SUM(LOGDAYS),2) NAV FROM CFREVIEWLOG
                WHERE LASTDATE BETWEEN V_FROMDATE AND V_TODATE
                GROUP BY CUSTID
              ) CFR,
              (  select CUSTID, ROUND(SUM(NAV)/SUM(LOGDAYS),2) nav_END
                 from CFREVIEWLOG
                 where lastdate = p_date
                 GROUP BY CUSTID
              )CFRE ,
               ( SELECT BR.BRID,BR.BRNAME,TL.GRPID CAREBY FROM BRGRP BR, TLGROUPS TL
                   WHERE TL.GRPTYPE='2' AND TL.GRPID NOT IN (SELECT CA.GRPID
                       FROM TRADEPLACE PA, TRADECAREBY CA
                       WHERE  PA.TRAID=CA.TRADEID AND PA.BRID=SUBSTR(BR.BRID,1,4))
                   UNION ALL
                   SELECT BRID||TRAID BRID, TRADENAME BRNAME, CA.GRPID CAREBY
                   FROM TRADEPLACE PA, TRADECAREBY CA WHERE PA.TRAID=CA.TRADEID) BR

        WHERE CF.CUSTID=RE.AFACCTNO(+)
            AND CF.CUSTID=AF.CUSTID
            AND CF.ACTYPE=CFT.ACTYPE
            AND AF.ACCTNO=OD.AFACCTNO(+)
            and cf.custid=cfre.custid(+)
            AND CF.CUSTID=CFR.CUSTID(+)
            AND CF.BRID=SUBSTR(BR.BRID,1,4)
            AND CF.CAREBY=BR.CAREBY
            AND CF.STATUS<>'C'
            AND NVL(RE.CUSTID,'000') LIKE V_RECUSTODYCD
            AND BR.BRID LIKE V_I_BRIDGD
            AND CFT.ACTYPE LIKE V_CFTYPE
            GROUP BY CFT.TYPENAME,CF.CUSTID, CF.CUSTODYCD, CF.FULLNAME,BR.BRID,BR.BRNAME,CF.EMAIL,CF.MOBILESMS,
            CF.ADDRESS,RE.FULLNAME,CFR.NAV,NVL(CFRE.NAV_END,0)


        ORDER BY   CFT.TYPENAME,CF.CUSTID   ;


EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;                                                              -- PROCEDURE
 
 
 
 
/
