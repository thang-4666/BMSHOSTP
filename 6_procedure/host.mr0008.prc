SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "MR0008" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   pv_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   I_DATE         IN       VARCHAR2,
   PV_CUSTODYCD   IN       VARCHAR2,
   PV_AFACCTNO    IN       VARCHAR2,
   PV_AFTYPE      IN       VARCHAR2,
   I_BRIDGD       IN       VARCHAR2
 )
IS
--thong bao lenh goi ky quy khi tai khoan bi call
--ngocvtt 20/05/2015

-- ---------   ------  -------------------------------------------
   V_STROPTION     VARCHAR2 (5);            -- A: ALL; B: BRANCH; S: SUB-BRANCH
   V_STRBRID       VARCHAR2 (40);                   -- USED WHEN V_NUMOPTION > 0
   V_INBRID        VARCHAR2 (4);

   V_STRCUSTODYCD   VARCHAR2 (20);
   V_STRAFACCTNO varchar2(20);
   V_I_BRIDGD    VARCHAR2(20);

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
   
     IF (I_BRIDGD <> 'ALL' OR I_BRIDGD <> '')
   THEN
      V_I_BRIDGD :=  I_BRIDGD;
   ELSE
      V_I_BRIDGD := '%%';
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


   IF (PV_AFTYPE IS NULL OR UPPER(PV_AFTYPE) = 'ALL')
   THEN
      V_STRAFTYPE := '%';
   ELSE
      V_STRAFTYPE := PV_AFTYPE;
   END IF;


   V_INDATE:=TO_DATE(I_DATE,'DD/MM/RRRR');

    SELECT TO_DATE(VARVALUE,'DD/MM/RRRR') INTO V_CUDATE FROM SYSVAR WHERE VARNAME='CURRDATE';

   -- GET REPORT'S DATA
IF V_INDATE=V_CUDATE THEN

OPEN  PV_REFCURSOR FOR

SELECT GETDUEDATE(V_INDATE,'B','000','1')NEXTDATE, V_INDATE indate,LN.BRID,LN.BRNAME,LN.CUSTID,LN.FULLNAME,LN.CUSTODYCD,LN.ACCTNO,LN.MARGINRATE,LN.MRIRATE,LN.MRMRATE,
    LN.MRLRATE,LN.MRCRATE,LN.MRWRATE,LN.FIRST_CALLDATE,LN.ADD_TO_MRCRATE,LN.SE_TO_MRCRATE,LN.SE_TO_MRCRATEUB,
    LN.SELLTYPE,LN.STATUS,LN.AMT,LN.TOTAL_AMT,LN.MG_CHINH,LN.MG_PHU ,CF.ADDRESS,CF.MOBILESMS
FROM (
SELECT MAIN.*,NVL(LAI.AMT,0)  TOTAL_AMT,'' MG_CHINH, '' MG_PHU,'' TYPE

FROM(SELECT V_INDATE INDATE, cf.brid, BR.BRNAME,CF.CUSTID, CF.FULLNAME,CF.CUSTODYCD,AF.ACCTNO,NVL(CI.MARGINRATE,0) MARGINRATE,
               AF.MRIRATE, AF.MRMRATE,AF.MRLRATE,AF.MRCRATE,AF.MRWRATE,fn_get_prevdate(to_date(V_INDATE,'dd/mm/rrrr'),AF.CALLDAY) FIRST_CALLDATE,
               case when aft.mnemonic<>'T3' then
               round((case when nvl(ci.marginrate,0) * af.mrmrate =0 then - nvl(ci.se_outstanding,0) else greatest( 0,- nvl(ci.se_outstanding,0) - nvl(ci.se_navaccount,0) *100/AF.MRCRATE) end),0)
               else 0 end ADD_TO_MRCRATE,
               GREATEST(af.MRCRATE/100 * round(-ci.se_outstanding) - ci.seass,0) SE_TO_MRCRATE,
                GREATEST(round((-af.mrcrate/100 * ci.se_outstanding - ci.seass) / (af.MRCRATE/100 - 0.5),4),0) SE_TO_MRCRATEUB,
                (CASE WHEN AF.Callday>=AF.K2DAYS THEN UTF8NUMS.C_CONST_SELLTYPE_MR0063_BH ELSE UTF8NUMS.C_CONST_SELLTYPE_MR0063_BD
                END) SELLTYPE,
               (CASE WHEN (
               (aft.mnemonic <>'T3' and
                         ((CI.marginrate<af.mrlrate and af.mrlrate <> 0)
                         OR (CI.marginrate<AF.MRCRATE AND (AF.CALLDAY >=AF.K1DAYS  ))))
                         or (CIM.OVAMT-GREATEST(0,CIM.BALANCE+NVL(CI.AVLADVANCE,0)- CIM.BUYSECAMT))>1 ) AND AF.Callday>=AF.K2DAYS THEN  UTF8NUMS.C_CONST_SELLTYPE_MR0063_CTYBH
               WHEN ((aft.mnemonic <>'T3' and ((CI.marginrate<af.mrlrate and af.mrlrate <> 0)
               OR (CI.marginrate<AF.MRCRATE AND (AF.CALLDAY >=AF.K1DAYS  ))))
               or (CIM.OVAMT-GREATEST(0,CIM.BALANCE+NVL(CI.AVLADVANCE,0)- CIM.BUYSECAMT))>1 ) AND AF.Callday<AF.K2DAYS THEN UTF8NUMS.C_CONST_SELLTYPE_MR0063_CTYBD
               ELSE UTF8NUMS.C_CONST_SELLTYPE_MR0063_KHBD
               END ) STATUS, NVL(MR.AMT,0) AMT
     FROM (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF, AFMAST AF, BRGRP BR, BUF_CI_ACCOUNT CI,AFTYPE AFT, CIMAST CIM,
              ( SELECT CF.CUSTODYCD,
                       sum(CASE WHEN  AF.AUTOADV='N' then
                        greatest(nvl(adv.depoamt,0) + balance - ci.buysecamt - CI.ovamt - CI.dueamt - ci.dfdebtamt - ci.dfintdebtamt - NVL (overamt, 0)
                        - nvl(secureamt,0)+ LEAST(AF.Mrcrlimit,nvl(B.secureamt,0)+ci.trfbuyamt)  - ci.trfbuyamt- CI.ramt-nvl(pd.dealpaidamt,0)
                        - CI.DEPOFEEAMT-CEIL(CI.CIDEPOFEEACR),0) + NVL(ADV.advamt,0)
                        else
                         greatest(nvl(adv.depoamt,0) + balance - ci.buysecamt - CI.ovamt - CI.dueamt - ci.dfdebtamt - ci.dfintdebtamt - NVL (overamt, 0)
                          - nvl(secureamt,0)+ LEAST(AF.Mrcrlimit,nvl(B.secureamt,0)+ci.trfbuyamt)  - ci.trfbuyamt- CI.ramt-nvl(pd.dealpaidamt,0)
                          - CI.DEPOFEEAMT-CEIL(CI.CIDEPOFEEACR),0) end) AMT
                FROM CIMAST CI, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF, AFMAST AF, v_getAccountAvlAdvance ADV, AFTYPE AFT, MRTYPE MR,v_getdealpaidbyaccount pd,v_getbuyorderinfo B
                WHERE CF.CUSTID=AF.CUSTID
                AND AF.ACCTNO=CI.ACCTNO
                    AND AF.ACTYPE=AFT.ACTYPE
                    AND AFT.MRTYPE=MR.ACTYPE
                    AND MR.MRTYPE='N'
                    AND AF.ACCTNO=ADV.AFACCTNO(+)
                    and CI.ACCTNO=pd.afacctno(+)
                    AND CI.ACCTNO=B.AFACCTNO(+)
                GROUP BY CUSTODYCD , AF.AUTOADV
                 ) MR
    WHERE AF.CUSTID=CF.CUSTID
              AND CF.BRID=BR.BRID(+)
              AND CI.AFACCTNO=AF.ACCTNO
              AND AF.ACCTNO=CIM.ACCTNO(+)
              AND AF.ACTYPE=AFT.ACTYPE
              AND AF.ACTYPE<>'0000'
              AND CF.CUSTODYCD=MR.CUSTODYCD(+)
              AND CI.MARGINRATE < AF.MRMRATE
              AND (CIM.ODAMT-GREATEST(0,CIM.BALANCE+NVL(CI.AVLADVANCE,0)- CIM.BUYSECAMT))>1
            ) MAIN
        LEFT JOIN
            (SELECT AF.ACCTNO, GREATEST(round(sum(LNS.PAID)+sum(LNS.INTPAID)+sum(LNS.FEEPAID)+sum(LNS.FEEPAID2)+
            sum(LNS.FEEINTPAID)+sum(LNS.FEEINTPREPAID)+sum(LNS.PAIDFEEINT)),0) AMT
            FROM VW_LNMAST_ALL LN, VW_LNSCHD_ALL LNS,AFMAST AF
            WHERE AF.ACCTNO=LN.TRFACCTNO
            AND LN.ACCTNO=LNS.ACCTNO AND LN.FTYPE='AF'
            AND LNS.RLSDATE IS NOT NULL
            and ln.rlsamt >0
            GROUP BY AF.ACCTNO) LAI ON MAIN.ACCTNO=LAI.ACCTNO) LN, AFMAST AF, AFTYPE AFT, CFMAST CF
WHERE LN.ACCTNO=AF.ACCTNO
AND AF.ACTYPE=AFT.ACTYPE
AND AF.CUSTID=CF.CUSTID
AND LN.ACCTNO LIKE V_STRAFACCTNO
AND LN.CUSTODYCD LIKE V_STRCUSTODYCD
AND AFT.PRODUCTTYPE LIKE V_STRAFTYPE
AND CF.BRID LIKE V_I_BRIDGD

ORDER BY LN.INDATE,LN.CUSTODYCD,LN.ACCTNO
;

ELSE

OPEN  PV_REFCURSOR FOR

SELECT GETDUEDATE(INDATE-1,'B','000','1')NEXTDATE,V_INDATE indate,LN.BRID,LN.BRNAME,LN.CUSTID,LN.FULLNAME,LN.CUSTODYCD,LN.ACCTNO,LN.MARGINRATE,LN.MRIRATE,LN.MRMRATE,
    LN.MRLRATE,LN.MRCRATE,LN.MRWRATE,LN.FIRST_CALLDATE,LN.ADD_TO_MRCRATE,LN.SE_TO_MRCRATE,LN.SE_TO_MRCRATEUB,
    LN.SELLTYPE,LN.STATUS,LN.AMT,LN.TOTAL_AMT,LN.MG_CHINH,LN.MG_PHU ,CF.ADDRESS,CF.MOBILESMS
FROM TBL_MR0063 LN, AFMAST AF, AFTYPE AFT, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF
WHERE LN.ACCTNO=AF.ACCTNO
AND AF.ACTYPE=AFT.ACTYPE
AND AF.CUSTID=CF.CUSTID
AND LN.INDATE =V_INDATE+1
AND LN.ACCTNO LIKE V_STRAFACCTNO
AND LN.CUSTODYCD LIKE V_STRCUSTODYCD
AND AFT.PRODUCTTYPE LIKE V_STRAFTYPE
AND CF.BRID LIKE V_I_BRIDGD
ORDER BY LN.INDATE,LN.CUSTODYCD,LN.ACCTNO
;

END IF;
EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;

 
 
 
 
/
