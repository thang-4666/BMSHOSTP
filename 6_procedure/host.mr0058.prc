SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "MR0058" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   pv_OPT         IN       VARCHAR2,
   pv_BRID        IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2,
   I_BRID         IN       VARCHAR2,
   PV_AFTYPE      IN       VARCHAR2
)
IS

--BAO CAO XU LY CAC TAI KHOAN CO MON VAY DEN HAN QUA HAN
--NGOCVTT 24/04/2015

-- ---------   ------  -------------------------------------------
   l_STROPTION          VARCHAR2 (5);       -- A: ALL; B: BRANCH; S: SUB-BRANCH
   l_STRBRID            VARCHAR2 (4);
   V_INDATE             DATE;
   V_FROMDATE           DATE;
   V_TODATE             DATE;
   V_CUDATE             DATE;
   V_INBRID             VARCHAR2(4);
   V_STRBRID            VARCHAR2 (50);
   V_STROPTION          VARCHAR2(10);
   v_BRID               VARCHAR2(20);
   V_AFTYPE             VARCHAR2(10);

BEGIN

   V_STROPTION := upper(pv_OPT);
   V_INBRID := pv_BRID;

 -- END OF GETTING REPORT'S PARAMETERS

    if(upper(I_BRID) = 'ALL' or I_BRID is null) then
        v_BRID := '%%';
    else
        v_BRID := UPPER(I_BRID);
    end if ;
    
    IF(PV_AFTYPE  ='ALL')
        THEN V_AFTYPE := '%%';
    ELSE 
        V_AFTYPE:= PV_AFTYPE;
    END IF;

  --  V_INDATE:=TO_DATE(I_DATE,'DD/MM/RRRR');
     V_FROMDATE:=TO_DATE(F_DATE,'DD/MM/RRRR');
     V_TODATE:=TO_DATE(T_DATE,'DD/MM/RRRR');
    SELECT TO_DATE(VARVALUE,'DD/MM/RRRR') INTO V_CUDATE FROM SYSVAR WHERE VARNAME='CURRDATE';

-- GET REPORT'S DATA
 OPEN PV_REFCURSOR FOR


 SELECT INDATE INDATE,LN.AUTOID,LN.ACCTNO,LN.CUSTID,LN.FULLNAME,LN.BRNAME,LN.CUSTODYCD,LN.TRFACCTNO,LN.RLSDATE,LN.OVERDUEDATE,
       LN.NML,LN.PAID,LN.TOTAL_AMT,LN.LAI_DUKIEN,LN.ADDRESS,LN.BRID,
       NVL(LN.MOBILE,'') MOBILE, LN.CHI_PHI_KHAC,NVL(RE.REFULLNAME,'')MG_CHINH,NVL(RE.REFULLNAMEFT,'') MG_PHU

FROM  (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0)CF,
       (       SELECT  V_CUDATE INDATE, cf.brid, LNS.AUTOID,lnm.acctno,CF.CUSTID, cf.fullname, br.brname,
            cf.custodycd, lnm.trfacctno,LNS.RLSDATE,lns.overduedate,round(LNS.NML+LNS.OVD) NML,
            round(LNS.PAID+LNS.INTPAID+LNS.FEEPAID+LNS.FEEPAID2+LNS.FEEINTPAID+LNS.FEEINTPREPAID+LNS.PAIDFEEINT) PAID ,
            MR.AMT TOTAL_AMT,round(LNS.INTNMLACR+LNS.INTOVD+LNS.INTOVDPRIN+LNS.FEEINTNMLACR+LNS.FEEDUE+LNS.INTDUE +LNS.FEEOVD+LNS.FEEINTOVDACR
            +LNS.FEEINTNMLOVD+LNS.FEEINTDUE+LNS.OVDFEEINT+LNS.FEEINTNML+LNS.FEEINTOVD) LAI_DUKIEN,
            CF.ADDRESS,NVL(CF.MOBILESMS,'') MOBILE,0 CHI_PHI_KHAC
        FROM lnmast  lnm, CFMAST cf,  afmast af, brgrp br, lnschd lns,
            (/*
                SELECT CF.CUSTODYCD,
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
                    AND MR.MRTYPE='N'
                    AND AF.ACCTNO=ADV.AFACCTNO(+)
                    and CI.ACCTNO=pd.afacctno(+)
                    AND CI.ACCTNO=B.AFACCTNO(+)
                GROUP BY CUSTODYCD , AF.AUTOADV
            */
                SELECT BUF.CUSTODYCD,  sum(CASE WHEN  AF.AUTOADV='N' then NVL(BUF.BALDEFOVD,0) + NVL(BUF.avladvance,0)
                       ELSE NVL(BUF.BALDEFOVD,0) END) AMT
                FROM AFMAST AF,AFTYPE AFT, MRTYPE MR, buf_ci_account buf
                WHERE  AF.ACTYPE=AFT.ACTYPE
                    AND AFT.MRTYPE=MR.ACTYPE
                    AND MR.MRTYPE='N'
                    AND AF.ACCTNO=BUF.AFACCTNO
                 GROUP BY BUF.CUSTODYCD
            ) MR
        WHERE  af.custid=cf.custid
            AND LNM.ACCTNO=LNS.ACCTNO
            AND af.acctno =lnm.trfacctno
            AND af.PRODUCTTYPE LIKE V_AFTYPE
            AND br.brid=cf.brid
            and lnm.rlsamt >0
            AND LNM.FTYPE='AF'
            and lns.RLSDATE is not null
            AND LNM.STATUS<>'Y'
            AND CF.CUSTODYCD=MR.CUSTODYCD(+)
            AND LNS.OVERDUEDATE <= V_CUDATE
            and round(LNS.NML+LNS.OVD)+
            round(LNS.INTNMLACR+LNS.INTOVD+LNS.INTOVDPRIN+LNS.FEEINTNMLACR+LNS.FEEDUE+LNS.INTDUE +LNS.FEEOVD+LNS.FEEINTOVDACR
            +LNS.FEEINTNMLOVD+LNS.FEEINTDUE+LNS.OVDFEEINT+LNS.FEEINTNML+LNS.FEEINTOVD) > 0

          UNION ALL

          SELECT fn_get_prevdate(tbl.INDATE,1) INDATE, tbl.BRID, tbl.AUTOID, tbl.ACCTNO, tbl.CUSTID, tbl.FULLNAME, tbl.BRNAME,
                tbl.CUSTODYCD, tbl.TRFACCTNO, tbl.RLSDATE, tbl.OVERDUEDATE,
                tbl.NML, tbl.PAID, tbl.TOTAL_AMT, tbl.LAI_DUKIEN, tbl.ADDRESS, tbl.MOBILE, tbl.CHI_PHI_KHAC
          FROM TBL_MR0058 tbl, afmast af
          WHERE tbl.trfacctno = af.acctno
            AND af.producttype LIKE V_AFTYPE
            )LN

        LEFT JOIN
               (SELECT max(case when TYP.REROLE IN ('CS', 'RM') then CFRE.FULLNAME else '' end) REFULLNAME,
                    max(case when TYP.REROLE = 'DG' then CFRE.FULLNAME else '' end) REFULLNAMEFT,
                    LNK.AFACCTNO ACCTNO
                FROM REAFLNK LNK, REMAST RE, RETYPE TYP, CFMAST CFRE
                WHERE LNK.deltd <> 'Y' AND TYP.REROLE in ('CS','DG', 'RM')
                    AND RE.ACTYPE=TYP.ACTYPE AND RE.CUSTID=CFRE.CUSTID AND RE.ACCTNO=LNK.REACCTNO
                    AND LNK.STATUS = 'A'
                 --   and lnk.frdate <= V_TODATE
                 --   and nvl(lnk.clstxdate,lnk.todate) > V_FROMDATE
                group by LNK.AFACCTNO) RE ON RE.ACCTNO=LN.CUSTID
   WHERE  ROUND(NML+LAI_DUKIEN) >0
   AND CF.CUSTID=LN.CUSTID
   AND LN.BRID LIKE V_BRID
   AND LN.INDATE BETWEEN V_FROMDATE AND V_TODATE
   ORDER BY LN.INDATE,LN.overduedate;


 EXCEPTION
   WHEN OTHERS
   THEN
        RETURN;
END;
 
 
 
 
/
