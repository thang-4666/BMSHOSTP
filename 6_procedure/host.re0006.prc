SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "RE0006" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   pv_BRID        IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE        IN       VARCHAR2,
   T_DATE        IN       VARCHAR2,
   I_BRIDGD         IN       VARCHAR2,
   RECUSTODYCD         IN       VARCHAR2

 )
IS

--BAO CAO PERFORMANCE
--NGOCVTT 22/05/2015
-- ---------   ------  -------------------------------------------
   V_STROPT     VARCHAR2 (50);            -- A: ALL; B: BRANCH; S: SUB-BRANCH
   V_STRBRID       VARCHAR2 (40);            -- USED WHEN V_NUMOPTION > 0
   V_INBRID         VARCHAR2 (50);

    V_CUSTODYCD  VARCHAR2(100);

   V_TODATE         DATE;
   V_FROMDATE          DATE;

   V_I_BRIDGD          VARCHAR2(100);
   V_BRNAME            NVARCHAR2(400);


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

   IF (I_BRIDGD <> 'ALL' OR I_BRIDGD <> '')
   THEN
      BEGIN
            SELECT BRNAME INTO V_BRNAME FROM BRGRP WHERE BRID LIKE I_BRIDGD;
      END;
   ELSE
      V_BRNAME   :=  ' To?c?ty ';
   END IF;

    IF (RECUSTODYCD <> 'ALL' OR RECUSTODYCD <> '') THEN
        V_CUSTODYCD := RECUSTODYCD;
    ELSE
        V_CUSTODYCD := '%%';
    END IF;

   V_FROMDATE:=TO_DATE(F_DATE,'DD/MM/YYYY');
   V_TODATE:=TO_DATE(T_DATE,'DD/MM/YYYY');


   -- GET REPORT'S DATA
    OPEN  PV_REFCURSOR
     FOR
        SELECT * FROM (
        SELECT  CFRE.CUSTID RECUSTID, CFRE.FULLNAME REFULLNAME,lnk.frdate,lnk.todate,LNK.STATUS,
              CF.CUSTODYCD, CF.FULLNAME CUSTNAME, LNK.AFACCTNO CUSTID,
              (CASE WHEN CF.COUNTRY='234' THEN 'IN' ELSE 'OUT' END) COUNTRY,
              SUM(NVL(OD.FEE_B,0)) FEE_B, SUM(NVL(OD.MATCHAMT_B,0)) MATCHAMT_B,SUM(NVL(OD.FEE_S,0)) FEE_S,SUM(NVL(OD.MATCHAMT_S,0)) MATCHAMT_S
        FROM REAFLNK LNK, REMAST RE, RETYPE TYP, CFMAST CFRE, (SELECT * FROM CFMAST WHERE INSTR(TLGOUPS, CAREBY)>0) CF,AFMAST AF,
              (SELECT OD.AFACCTNO,
                    SUM(CASE WHEN OD.EXECTYPE IN ('NB','BC') THEN (CASE WHEN OD.EXECAMT = 0 THEN 0 ELSE
                    (CASE WHEN IO.IODFEEACR = 0 and OD.TXDATE = getcurrdate THEN ROUND(IO.matchqtty * io.matchprice * ODT.deffeerate / 100, 2)
                    ELSE io.iodfeeacr END)END) ELSE 0 END) FEE_B,

                    SUM(CASE WHEN OD.EXECTYPE IN ('NB','BC') THEN NVL(IO.MATCHQTTY*IO.MATCHPRICE,0) ELSE 0 END ) MATCHAMT_B,

                    SUM(CASE WHEN OD.EXECTYPE IN ('NS','SS','MS') THEN (CASE WHEN OD.EXECAMT = 0 THEN 0 ELSE
                    (CASE WHEN IO.IODFEEACR = 0 and OD.TXDATE = getcurrdate THEN ROUND(IO.matchqtty * io.matchprice * ODT.deffeerate / 100, 2)
                    ELSE io.iodfeeacr END) END) ELSE 0 END) FEE_S,

                    SUM(CASE WHEN OD.EXECTYPE IN ('NS','SS','MS') THEN NVL(IO.MATCHQTTY*IO.MATCHPRICE,0) ELSE 0 END ) MATCHAMT_S
              FROM ODTYPE ODT,VW_ODMAST_TRADEPLACE_ALL OD
                   INNER JOIN VW_IOD_ALL IO ON OD.ORDERID = IO.ORGORDERID
              WHERE OD.ACTYPE =ODT.ACTYPE
                    AND OD.DELTD<>'Y'
                    AND OD.TXDATE BETWEEN V_FROMDATE AND V_TODATE
                    AND OD.EXECTYPE IN ('NS','SS','MS','NB','BC')

                    GROUP BY OD.AFACCTNO) OD

        WHERE CF.CUSTID=LNK.AFACCTNO AND LNK.DELTD <> 'Y'/* AND LNK.STATUS='A' */--AND TYP.REROLE='CS'
              AND RE.ACTYPE=TYP.ACTYPE AND RE.CUSTID=CFRE.CUSTID AND RE.ACCTNO=LNK.REACCTNO
              AND CF.CUSTID=AF.CUSTID
              AND AF.ACCTNO=OD.AFACCTNO(+)
              and lnk.frdate <=V_TODATE
              and nvl(lnk.clstxdate,lnk.todate) > V_FROMDATE
              AND CF.BRID LIKE V_I_BRIDGD
              AND CFRE.CUSTID LIKE V_CUSTODYCD
              GROUP BY CFRE.CUSTID , CFRE.FULLNAME ,
              CF.CUSTODYCD, CF.FULLNAME , LNK.AFACCTNO ,
              (CASE WHEN CF.COUNTRY='234' THEN 'IN' ELSE 'OUT' END),lnk.frdate,lnk.todate,LNK.STATUS)
        WHERE MATCHAMT_B+FEE_S+MATCHAMT_S+FEE_B>0

        ORDER BY   RECUSTID, CUSTID    ;


EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;                                                              -- PROCEDURE
 
 
 
 
/
