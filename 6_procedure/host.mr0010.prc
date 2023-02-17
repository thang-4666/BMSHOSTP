SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE mr0010 (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   pv_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   I_DATE         IN       VARCHAR2,
   PV_CUSTODYCD   IN       VARCHAR2,
   PV_AFACCTNO    IN       VARCHAR2
 )
IS
--TH�G B�O K?T QU? GIAO D?CH T�I KHO?N MUA K�QU? V� X�C NH?N K�QU?
--ngocvtt 30/06/2015

-- ---------   ------  -------------------------------------------
   V_STROPTION     VARCHAR2 (5);            -- A: ALL; B: BRANCH; S: SUB-BRANCH
   V_STRBRID       VARCHAR2 (40);                   -- USED WHEN V_NUMOPTION > 0
   V_INBRID        VARCHAR2 (4);

   V_STRCUSTODYCD   VARCHAR2 (20);
   V_STRAFACCTNO varchar2(20);


   V_STRAFTYPE        varchar2(20);
   V_INDATE      DATE;
    V_CUDATE        DATE;

BEGIN
   V_STROPTION := upper(OPT);
   V_INBRID := pv_BRID;

   IF (V_STROPTION = 'A')
   THEN
      V_STRBRID := '%';
   ELSE if (V_STROPTION = 'B') then
            select brgrp.BRID into V_STRBRID from brgrp where brgrp.brid = V_INBRID;
        else
            V_STRBRID := V_INBRID;
        end if;
   END IF;

   -- GET REPORT'S PARAMETERS

    if(upper(PV_CUSTODYCD) = 'ALL' or LENGTH(PV_CUSTODYCD) <= 1 ) then
        V_STRCUSTODYCD := '%';
    else
        V_STRCUSTODYCD := PV_CUSTODYCD;
    end if;

    if(UPPER(PV_AFACCTNO) = 'ALL' or LENGTH(PV_AFACCTNO) <= 1 ) THEN
        V_STRAFACCTNO := '%';
    else
        V_STRAFACCTNO := PV_AFACCTNO;
    end if;

     V_INDATE:=TO_DATE(I_DATE,'DD/MM/RRRR');

    SELECT TO_DATE(VARVALUE,'DD/MM/RRRR') INTO V_CUDATE FROM SYSVAR WHERE VARNAME='CURRDATE';

   -- GET REPORT'S DATA
OPEN  PV_REFCURSOR FOR

      SELECT GETDUEDATE(V_INDATE,'B','000','1')NEXTDATE,V_INDATE currdate, LN.*,CF.CUSTID,CF.CAREBY,CF.BRID, CF.CUSTODYCD,CF.FULLNAME, CF.MOBILESMS, CF.ADDRESS,AF.ACCTNO, AF.MRIRATE, OD.TXDATE,
              getduedate(OD.TXDATE,OD.CLEARCD,SB.TRADEPLACE,OD.CLEARDAY) CLEARDT, OD.NORK,
              SB.SYMBOL,OD.ORDERQTTY, OD.QUOTEPRICE,NVL(IO.MATCHPRICE,0) MATCHPRICE,NVL(IO.MATCHQTTY,0) MATCHQTTY,
              NVL(IO.MATCHPRICE,0) * NVL(IO.MATCHQTTY,0) AMT,
              --TruongLD Add 25/09/2019, lay phi theo tung lenh khop
              --nvl(io.iodfeeacr,0) FEEAMT,
              NVL((CASE  WHEN  nvl(io.iodfeeacr,0)>0 THEN  nvl(io.iodfeeacr,0)
                                        WHEN OD.FEEACR=0 AND OD.TXDATE <> V_CUDATE THEN 0
                                        ELSE ROUND(IO.matchqtty * io.matchprice * ODT.deffeerate / 100, 2) END),0) FEEAMT,
                                             --NVL(OD.FEEACR,0) FEEAMT,
             /* (CASE WHEN OD.execamt>0 and OD.feeacr=0  AND OD.TXDATE = V_CUDATE THEN  ODT.deffeerate
                    WHEN OD.execamt>0 and OD.feeacr=0  AND OD.TXDATE <> V_CUDATE THEN 0
               ELSE (CASE WHEN (OD.execamt * OD.feeacr) = 0 THEN 0 ELSE
                         (CASE WHEN OD.txdate = V_CUDATE  THEN round(100 * OD.feeacr/(OD.execamt),2)
                           ELSE ROUND((io.matchqtty * io.matchprice/OD.execamt * OD.feeacr)*100/ (IO.MATCHPRICE*IO.MATCHQTTY),2) END)
                  END) END)*/
              ROUND((io.matchqtty * io.matchprice/OD.execamt * OD.feeacr)*100/ (IO.MATCHPRICE*IO.MATCHQTTY),2)  FEE_RATE,'' type
      FROM VW_ODMAST_ALL OD, VW_IOD_ALL IO, AFMAST AF,
              (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF,
              MRTYPE MR,AFTYPE AFT, SBSECURITIES SB,
              (SELECT LN.TRFACCTNO, LND.RLSDATE,LNT.PRINPERIOD,SUM(LND.NML)+SUM(LND.OVD)+SUM(LND.PAID) NML,
                      (CASE WHEN LND.RLSDATE<LND.DUEDATE AND LND.ACRDATE<LND.DUEDATE THEN LND.RATE1 ELSE LND.RATE2 END) RATE
              FROM LNMAST LN, LNSCHD LND, LNTYPE LNT
              WHERE LN.ACCTNO=LND.ACCTNO
                      AND LN.FTYPE='AF'
                      AND LN.ACTYPE=LNT.ACTYPE
                      AND LND.RLSDATE IS NOT NULL
                      GROUP BY LN.TRFACCTNO, LND.RLSDATE,LNT.PRINPERIOD,
                      (CASE WHEN LND.RLSDATE<LND.DUEDATE AND LND.ACRDATE<LND.DUEDATE THEN LND.RATE1 ELSE LND.RATE2 END))LN
      WHERE OD.AFACCTNO=AF.ACCTNO
              AND AF.CUSTID=CF.CUSTID
              AND OD.ORDERID=IO.ORGORDERID(+)
              AND AF.ACCTNO=LN.TRFACCTNO
              AND OD.TXDATE=LN.RLSDATE
              AND OD.EXECTYPE IN ('NB','BC')
              AND AF.ACTYPE=AFT.ACTYPE
              AND AFT.MRTYPE=MR.ACTYPE
              AND MR.MRTYPE='T'
              AND OD.CODEID=SB.CODEID
              AND OD.TXDATE=V_INDATE
              AND CF.CUSTODYCD LIKE V_STRCUSTODYCD
              AND AF.ACCTNO LIKE V_STRAFACCTNO
              ORDER BY CF.CUSTODYCD,AF.ACCTNO
;


EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;
 
/
