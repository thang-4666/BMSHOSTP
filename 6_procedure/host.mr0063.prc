SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE mr0063 (
                                   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
                                   pv_OPT         IN       VARCHAR2,
                                   pv_BRID        IN       VARCHAR2,
                                   TLGOUPS        IN       VARCHAR2,
                                   TLSCOPE        IN       VARCHAR2,
                                   F_DATE         IN       VARCHAR2,
                                   T_DATE         IN        VARCHAR2,
                                   I_BRID         IN       VARCHAR2,
                                   PV_AFTYPE      IN       VARCHAR2
)
IS
--------------------------
--BAO CAO XU LY CAC TAI KHOAN KHONG DAT TY LE DUY TRI
--NGOCVTT  20/06/2015

-- ---------   ------  -------------------------------------------
   l_STROPTION        VARCHAR2 (5);       -- A: ALL; B: BRANCH; S: SUB-BRANCH
   l_STRBRID          VARCHAR2 (4);

 --  V_IDATE           DATE;
   V_CUDATE        DATE;
   V_INBRID         VARCHAR2(4);
   V_STRBRID        VARCHAR2 (50);
   V_STROPTION      VARCHAR2(10);
   v_BRID        VARCHAR2(20);
   V_INDATE      DATE;

   V_FROMDATE    DATE;
   V_TODATE      DATE;
   V_AFTYPE      VARCHAR2(10);

BEGIN

    V_STROPTION := upper(pv_OPT);
    V_INBRID := pv_BRID;
    --END OF GETTING REPORT'S PARAMETERS   
    -- V_INDATE:=TO_DATE(I_DATE,'DD/MM/RRRR');

    V_FROMDATE:=TO_DATE(F_DATE,'DD/MM/RRRR');
    V_TODATE:=TO_DATE(T_DATE,'DD/MM/RRRR');
    SELECT TO_DATE(VARVALUE,'DD/MM/RRRR') INTO V_CUDATE FROM SYSVAR WHERE VARNAME='CURRDATE';
    -- GET REPORT'S DATA
    IF(PV_AFTYPE IS NULL OR UPPER(PV_AFTYPE) = 'ALL') THEN 
        V_AFTYPE := '%%';
    ELSE 
        V_AFTYPE := PV_AFTYPE;
    END IF;
    
    if(upper(I_BRID) = 'ALL' or I_BRID is null) then
    v_BRID := '%%';
    else
    v_BRID := UPPER(I_BRID);
    end if ;


    OPEN PV_REFCURSOR FOR

     SELECT LN.INDATE,LN.BRID,LN.BRNAME,LN.CUSTID,LN.FULLNAME,LN.CUSTODYCD,LN.ACCTNO,LN.MARGINRATE,LN.MRIRATE,LN.MRMRATE,
        LN.MRLRATE,LN.MRCRATE,LN.MRWRATE,LN.FIRST_CALLDATE,LN.ADD_TO_MRCRATE,LN.SE_TO_MRCRATE,LN.SE_TO_MRCRATEUB,
        LN.SELLTYPE,LN.STATUS,LN.AMT,LN.TOTAL_AMT,NVL(RE.REFULLNAME,'')MG_CHINH,NVL(RE.REFULLNAMEFT,'') MG_PHU
     FROM (
             SELECT MAIN.INDATE,MAIN.BRID, MAIN.BRNAME,MAIN.CUSTID,MAIN.FULLNAME,MAIN.CUSTODYCD,MAIN.ACCTNO,MAIN.MARGINRATE,
             MAIN.MRIRATE,MAIN.MRMRATE,MAIN.MRLRATE,MAIN.MRCRATE,MAIN.MRWRATE,MAIN.FIRST_CALLDATE,MAIN.SELLTYPE,MAIN.STATUS,
             MAIN.ADD_TO_MRCRATE,MAIN.SE_TO_MRCRATE,MAIN.SE_TO_MRCRATEUB, MAIN.AMT,NVL(LAI.AMT,0)  TOTAL_AMT
            FROM (SELECT V_CUDATE INDATE, cf.brid, BR.BRNAME,CF.CUSTID, CF.FULLNAME,CF.CUSTODYCD,AF.ACCTNO,NVL(CI.MARGINRATE,0) MARGINRATE,
                           AF.MRIRATE, AF.MRMRATE,AF.MRLRATE,AF.MRCRATE,AF.MRWRATE,fn_get_prevdate(to_date(V_CUDATE,'dd/mm/rrrr'),AF.CALLDAY) FIRST_CALLDATE,
                           case when aft.mnemonic<>'T3' then
                           round((case when nvl(ci.marginrate,0) * af.mrmrate =0 then - nvl(ci.se_outstanding,0) else greatest( 0,- nvl(ci.se_outstanding,0) - nvl(ci.se_navaccount,0) *100/AF.MRCRATE) end),0)
                           else 0 end ADD_TO_MRCRATE,
                           GREATEST(af.MRCRATE/100 * round(-ci.se_outstanding) - ci.seass,0) SE_TO_MRCRATE,
                           LEAST(  GREATEST(round((-af.mrcrate/100 * ci.se_outstanding - ci.seass) / (af.MRCRATE/100 - 0.5),4),0),GREATEST( ci.se_outstanding*(-1),0)) SE_TO_MRCRATEUB,
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
             FROM CFMAST CF, AFMAST AF, BRGRP BR, BUF_CI_ACCOUNT CI,AFTYPE AFT, CIMAST CIM,
                      ( SELECT CF.CUSTODYCD,
                               sum(CASE WHEN  AF.AUTOADV='N' then
                                greatest(nvl(adv.depoamt,0) + balance - ci.buysecamt - CI.ovamt - CI.dueamt - ci.dfdebtamt - ci.dfintdebtamt - NVL (overamt, 0)
                                - nvl(secureamt,0)+ LEAST(AF.Mrcrlimit,nvl(B.secureamt,0)+ci.trfbuyamt)  - ci.trfbuyamt- CI.ramt-nvl(pd.dealpaidamt,0)
                                - CI.DEPOFEEAMT-CEIL(CI.CIDEPOFEEACR),0) + NVL(ADV.advamt,0)
                                else
                                 greatest(nvl(adv.depoamt,0) + balance - ci.buysecamt - CI.ovamt - CI.dueamt - ci.dfdebtamt - ci.dfintdebtamt - NVL (overamt, 0)
                                  - nvl(secureamt,0)+ LEAST(AF.Mrcrlimit,nvl(B.secureamt,0)+ci.trfbuyamt)  - ci.trfbuyamt- CI.ramt-nvl(pd.dealpaidamt,0)
                                  - CI.DEPOFEEAMT-CEIL(CI.CIDEPOFEEACR),0) end) AMT
                        FROM CIMAST CI, CFMAST CF, AFMAST AF, v_getAccountAvlAdvance ADV, AFTYPE AFT, MRTYPE MR,v_getdealpaidbyaccount pd,v_getbuyorderinfo B
                        WHERE CF.CUSTID=AF.CUSTID
                        AND AF.ACCTNO=CI.ACCTNO
                            AND AF.ACTYPE=AFT.ACTYPE
                            AND AFT.MRTYPE=MR.ACTYPE
                            AND AFT.PRODUCTTYPE LIKE V_AFTYPE
                            AND MR.MRTYPE='N'
                            AND AF.ACCTNO=ADV.AFACCTNO(+)
                            and CI.ACCTNO=pd.afacctno(+)
                            AND CI.ACCTNO=B.AFACCTNO(+)
                        GROUP BY CUSTODYCD , AF.AUTOADV
                         ) MR
            WHERE AF.CUSTID=CF.CUSTID
                    AND AF.ACTYPE =AFT.ACTYPE
                    AND af.PRODUCTTYPE LIKE V_AFTYPE
                      AND CF.BRID=BR.BRID(+)
                      AND CI.AFACCTNO=AF.ACCTNO
                      AND AF.ACCTNO=CIM.ACCTNO(+)
                      AND AF.ACTYPE=AFT.ACTYPE
                      AND AF.ACTYPE<>'0000'
                      AND CF.CUSTODYCD=MR.CUSTODYCD(+)
                     /* AND CI.MARGINRATE < AF.MRMRATE
                      AND (CIM.ODAMT-GREATEST(0,CIM.BALANCE+NVL(CI.AVLADVANCE,0)- CIM.BUYSECAMT))>1*/
                     and ( (aft.mnemonic <>'T3' and
                          ((ci.marginrate<af.mrlrate and af.mrlrate <> 0)
                          OR (ci.marginrate<AF.MRCRATE AND (AF.CALLDAY >= 1/*AF.K1DAYS */ ))
                          OR  (ci.marginrate<AF.MRMRATE )
                          )
                          )
          --   or (CIM.ODAMT-GREATEST(0,CIM.BALANCE+NVL(CI.AVLADVANCE,0)- CIM.BUYSECAMT))>1
                        )

                    ) MAIN
                LEFT JOIN
                    (SELECT AF.ACCTNO, GREATEST(round(sum(LNS.PAID)+sum(LNS.INTPAID)+sum(LNS.FEEPAID)+sum(LNS.FEEPAID2)+
                            sum(LNS.FEEINTPAID)+sum(LNS.FEEINTPREPAID)+sum(LNS.PAIDFEEINT)),0) AMT
                    FROM VW_LNMAST_ALL LN, VW_LNSCHD_ALL LNS,AFMAST AF
                    WHERE AF.ACCTNO=LN.TRFACCTNO
                        AND LN.ACCTNO=LNS.ACCTNO AND LN.FTYPE='AF'
                        AND LNS.RLSDATE IS NOT NULL
                        and ln.rlsamt >0
                    GROUP BY AF.ACCTNO) LAI ON MAIN.ACCTNO=LAI.ACCTNO

                    UNION ALL
                    SELECT fn_get_prevdate(tbl.INDATE,1) INDATE, tbl.BRID, tbl.BRNAME, tbl.CUSTID, tbl.FULLNAME, tbl.CUSTODYCD,
                        tbl.ACCTNO, tbl.MARGINRATE, tbl.MRIRATE, tbl.MRMRATE, tbl.MRLRATE,
                        tbl.MRCRATE, tbl.MRWRATE, tbl.FIRST_CALLDATE, tbl.SELLTYPE, tbl.STATUS, tbl.ADD_TO_MRCRATE, tbl.SE_TO_MRCRATE,
                        tbl.SE_TO_MRCRATEUB, tbl.AMT,TOTAL_AMT
                    FROM TBL_MR0063 tbl, afmast af
                    WHERE tbl.acctno = af.acctno
                        AND af.producttype LIKE V_AFTYPE
                    )LN

           LEFT JOIN
               (SELECT max(case when TYP.REROLE = 'CS' then CFRE.FULLNAME else '' end) REFULLNAME,
                    max(case when TYP.REROLE = 'DG' then CFRE.FULLNAME else '' end) REFULLNAMEFT,
                    LNK.AFACCTNO ACCTNO
                FROM REAFLNK LNK, REMAST RE, RETYPE TYP, CFMAST CFRE
                WHERE LNK.deltd <> 'Y' AND TYP.REROLE in ('CS','DG')
                    AND RE.ACTYPE=TYP.ACTYPE AND RE.CUSTID=CFRE.CUSTID AND RE.ACCTNO=LNK.REACCTNO

                group by LNK.AFACCTNO) RE ON RE.ACCTNO=LN.CUSTID
           WHERE LN.BRID LIKE V_BRID
           AND LN.INDATE BETWEEN V_FROMDATE AND V_TODATE
           ORDER BY LN.INDATE,LN.CUSTODYCD,LN.ACCTNO;

 EXCEPTION
   WHEN OTHERS
   THEN
        RETURN;
END;
 
 
 
 
/
