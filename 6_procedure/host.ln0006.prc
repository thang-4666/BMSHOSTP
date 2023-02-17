SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "LN0006" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   pv_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   I_DATE         IN       VARCHAR2,
   PV_CUSTODYCD   IN       VARCHAR2,
   I_BANKNAME     IN        VARCHAR2,
   I_STATUS      IN        VARCHAR2,
   TLID            IN       VARCHAR2
   )
IS
--
-- TONG HOP DU NO THEO KHACH HANG
-- MODIFICATION HISTORY
-- PERSON      DATE    COMMENTS
-- THANHNM   30-MAY-2012  CREATE
-- ---------   ------  -------------------------------------------
-- PV_A            PKG_REPORT.REF_CURSOR;
   V_STROPTION      VARCHAR2 (5);            -- A: ALL; B: BRANCH; S: SUB-BRANCH
   V_STRBRID      VARCHAR2 (40);
   V_INBRID       VARCHAR2 (4);
             -- USED WHEN V_NUMOPTION > 0
   V_STRI_BRID      VARCHAR2 (5);
   V_STRI_TYPE      VARCHAR2 (5);
   V_CURRDATE       DATE;
   V_IDATE       DATE;
   V_STRSTATUS   VARCHAR2(3);
   V_STRCUSTODYCD  VARCHAR2(20);
   V_BANKNAME      VARCHAR2(20);
   V_STATUS        VARCHAR2(3);
   V_STRTLID           VARCHAR2(6);
BEGIN

   V_STROPTION := OPT;
   V_INBRID :=pv_BRID;
   V_STRTLID:= TLID;

   IF (V_STROPTION = 'A') THEN
      V_STRBRID := '%';
   ELSE if(V_STROPTION = 'B') then
          select br.mapid into V_STRBRID from brgrp br where  br.brid = V_INBRID;
        else
            V_STRBRID := V_INBRID;
        end if;
   END IF;

   IF (PV_CUSTODYCD ='ALL') THEN
      V_STRCUSTODYCD :='%';
   ELSE
      V_STRCUSTODYCD := PV_CUSTODYCD;
   END IF;
   IF (I_BANKNAME ='ALL') THEN
      V_BANKNAME :='%';
   ELSE
      V_BANKNAME := I_BANKNAME;
   END IF;
   IF (I_STATUS ='ALL') THEN
      V_STATUS :='%';
   ELSE
      V_STATUS := I_STATUS;
   END IF;

V_IDATE := TO_DATE (I_DATE,'DD/MM/RRRR');

OPEN PV_REFCURSOR
FOR
    SELECT FULLNAME,CUSTODYCD,F_TYPE,
           ROUND(SUM(F_GTGN)) F_GTGN, ROUND(SUM(F_GTTL)) F_GTTL,ROUND(SUM(F_DNHT)) F_DNHT,
           ROUND(SUM(F_LAI)) F_LAI,ROUND(SUM(F_PHI)) F_PHI,  V_IDATE  IDATE
    FROM(
    SELECT   CF.FULLNAME, CF.CUSTODYCD,
               CASE WHEN LN.FTYPE ='DF' THEN 'DF'
                    when LS.REFTYPE in ('P') then 'CL'
               ELSE 'T0' END  F_TYPE,
               LS.NML+LS.OVD+LS.PAID F_GTGN,
               LS.PAID - NVL(LNTR.PRIN_MOVE,0) F_GTTL,
               LS.NML+LS.OVD  -  NVL(LNTR.PRIN_MOVE,0)  F_DNHT,
               LS.INTNMLACR+LS.INTDUE+LS.INTOVD+LS.INTOVDPRIN  - NVL(LNTR.INT_MOVE,0) F_LAI,
               LS.FEEINTNMLACR + LS.FEEINTOVDACR + LS.FEEINTNMLOVD + LS.FEEINTDUE -- +  LS.INTPAID + LS.FEEINTPAID
               - NVL(LNTR.PRFEE_MOVE,0) F_PHI
    FROM (SELECT * FROM LNMAST UNION SELECT * FROM LNMASTHIST) LN,
           (SELECT * FROM LNSCHD UNION SELECT * FROM LNSCHDHIST) LS,
            (   SELECT AUTOID,SUM((CASE WHEN NML > 0 THEN 0 ELSE NML END )  +OVD) PRIN_MOVE,
                SUM(INTNMLACR +INTDUE+INTOVD+INTOVDPRIN) INT_MOVE,
                SUM(FEEINTNMLACR+ FEEINTDUE+FEEINTOVD+FEEINTOVDPRIN) PRFEE_MOVE
                FROM ( SELECT * FROM LNSCHDLOG UNION ALL SELECT * FROM LNSCHDLOGHIST ) LNSLOG
                WHERE NVL(DELTD,'N') <>'Y' AND TXDATE > V_IDATE
                GROUP BY AUTOID) LNTR,
          (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF, AFMAST AF,  CFMAST CFB , LNTYPE LNT
    WHERE LN.ACCTNO = LS.ACCTNO
    AND LS.REFTYPE IN ('P','GP')
    AND LN.ACTYPE = LNT.actype
    AND LN.RLSDATE <= V_IDATE
    AND LS.RLSDATE <=  V_IDATE
    AND LS.AUTOID = LNTR.AUTOID(+)
    AND lN.custbank = cfb.custid(+)
    --LAY THEO NNGUON NGAN HANG
    and case when I_BANKNAME = 'ALL' then 1
                when I_BANKNAME = cspks_system.fn_get_sysvar('SYSTEM','COMPANYSHORTNAME') and LN.rrtype = 'C' then 1
                when cfb.shortname = I_BANKNAME and LN.rrtype = 'B' then 1
            else 0 end = 1

    --LAY THEO LAOI HINH TUAN THU
    AND LNT.CHKSYSCTRL LIKE V_STATUS
    --CHECK TRANG THAI TAT TOAN
    AND LS.NML+LS.OVD - NVL(LNTR.PRIN_MOVE,0) > 0
    AND CF.CUSTID = AF.CUSTID
    AND LN.TRFACCTNO = AF.ACCTNO
    AND CF.CUSTODYCD LIKE V_STRCUSTODYCD
    AND  (AF.BRID LIKE V_STRBRID OR INSTR(V_STRBRID,AF.BRID) <> 0)
        )
    GROUP BY CUSTODYCD,FULLNAME,F_TYPE
;
EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;                                                              -- PROCEDURE

 
 
 
 
/
