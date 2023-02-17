SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "MR0057" (
                                       PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
                                       pv_OPT         IN       VARCHAR2,
                                       pv_BRID        IN       VARCHAR2,
                                       TLGOUPS        IN       VARCHAR2,
                                       TLSCOPE        IN       VARCHAR2,
                                       I_DATE         IN       VARCHAR2,
                                       I_BRID         IN       VARCHAR2,
                                       PV_AFTYPE      IN       VARCHAR2
)
IS
    ----------------------
    --bao cao cac mon vay den han
    --ngocvtt 14/04/2015
    -- ---------   ------  -------------------------------------------
    l_STROPTION        VARCHAR2 (5);       -- A: ALL; B: BRANCH; S: SUB-BRANCH
    l_STRBRID          VARCHAR2 (4);

    V_INDATE        DATE;
    V_CUDATE        DATE;
    V_INBRID         VARCHAR2(4);
    V_STRBRID        VARCHAR2 (50);
    V_STROPTION      VARCHAR2(10);
    v_BRID        VARCHAR2(20);
    V_AFTYPE      VARCHAR2(10);

BEGIN

    V_STROPTION := upper(pv_OPT);
    V_INBRID := pv_BRID;

    -- END OF GETTING REPORT'S PARAMETERS

    if(upper(I_BRID) = 'ALL' or I_BRID is null) then
        v_BRID := '%%';
    else
        v_BRID := UPPER(I_BRID);
    end if ;
    
    IF(PV_AFTYPE = 'ALL') THEN 
        V_AFTYPE := '%%';
    ELSE 
        V_AFTYPE := PV_AFTYPE;
      END IF;
    
    V_INDATE:=TO_DATE(I_DATE,'DD/MM/RRRR');
    SELECT TO_DATE(VARVALUE,'DD/MM/RRRR') INTO V_CUDATE FROM SYSVAR WHERE VARNAME='CURRDATE';

    ----
    -- GET REPORT'S DATA
    IF V_INDATE = V_CUDATE THEN
        OPEN PV_REFCURSOR FOR
            SELECT V_CUDATE INDATE,LN.AUTOID,LN.ACCTNO,LN.CUSTID,LN.FULLNAME,LN.BRID,LN.BRNAME,LN.CUSTODYCD,LN.TRFACCTNO,RLSDATE,
               LN.OVERDUEDATE,LN.NML,LN.LAI_DUKIEN,LN.ADDRESS,LN.MOBILE,LN.CHI_PHI_KHAC, NVL(RE.REFULLNAME,'') MG_CHINH,
               NVL(RE.REFULLNAMEFT,'') MG_PHU,'' TYPE
            FROM ( SELECT to_date(V_CUDATE,'dd/mm/rrrr') INDATE,LNS.AUTOID,lnm.acctno,cf.custid, cf.fullname,cf.brid, br.brname, cf.custodycd, lnm.trfacctno,LNS.RLSDATE,lns.overduedate,LNS.NML,
               (CASE WHEN LNS.ACRDATE<LNS.DUEDATE THEN
               --TY LE RATE1
               (  sum(lnS.INTNMLACR + ROUND((lnS.NML * lnS.RATE1 / 100 * TO_NUMBER(LNS.DUEDATE -lnS.acrdate)+lnS.NML * lnS.RATE2 / 100 * TO_NUMBER(LNS.OVERDUEDATE  -lnS.DUEDATE))
                                      /(Case When LNM.DRATE= 'D1' then  30
                                                 When LNM.DRATE= 'D2' then  TO_NUMBER(TO_CHAR(LAST_DAY(TO_DATE(LNS.OVERDUEDATE + 1,'dd/mm/rrrr')),'dd'))
                                                 When LNM.DRATE= 'Y1' then  360
                                                 When LNM.DRATE= 'Y2' then
                                                         TO_DATE(CONCAT('31/12/',SUBSTR(LNS.OVERDUEDATE + 1,7)),'dd/mm/rrrr') - TO_DATE(CONCAT('01/01/',SUBSTR(LNS.OVERDUEDATE + 1,7)),'dd/mm/rrrr') + 1
                                                 When LNM.DRATE= 'Y3' then  365
                                             End
                                             )
                                     ,4))+
                 sum(lnS.FEEINTNMLACR + ROUND((lnS.NML * lnS.CFRATE1 / 100 * TO_NUMBER(LNS.DUEDATE -lnS.acrdate)+lnS.NML * lnS.CFRATE2 / 100 * TO_NUMBER(LNS.OVERDUEDATE  -lnS.DUEDATE))
                          / (Case When LNM.DRATE= 'D1' then  30
                                                 When LNM.DRATE= 'D2' then  TO_NUMBER(TO_CHAR(LAST_DAY(TO_DATE(LNS.OVERDUEDATE + 1,'dd/mm/rrrr')),'dd'))
                                                 When LNM.DRATE= 'Y1' then  360
                                                 When LNM.DRATE= 'Y2' then
                                                         TO_DATE(CONCAT('31/12/',SUBSTR(LNS.OVERDUEDATE + 1,7)),'dd/mm/rrrr') - TO_DATE(CONCAT('01/01/',SUBSTR(LNS.OVERDUEDATE + 1,7)),'dd/mm/rrrr') + 1
                                                 When LNM.DRATE= 'Y3' then  365
                                             End
                                             )
                    ,4)))
                    --TY LE RATE2
                ELSE ( sum(lnS.INTNMLACR + ROUND(lnS.NML * lnS.RATE2 / 100 * TO_NUMBER(LNS.OVERDUEDATE  -lnS.acrdate)
                                      /(Case When LNM.DRATE= 'D1' then  30
                                                 When LNM.DRATE= 'D2' then  TO_NUMBER(TO_CHAR(LAST_DAY(TO_DATE(LNS.OVERDUEDATE + 1,'dd/mm/rrrr')),'dd'))
                                                 When LNM.DRATE= 'Y1' then  360
                                                 When LNM.DRATE= 'Y2' then
                                                         TO_DATE(CONCAT('31/12/',SUBSTR(LNS.OVERDUEDATE + 1,7)),'dd/mm/rrrr') - TO_DATE(CONCAT('01/01/',SUBSTR(LNS.OVERDUEDATE + 1,7)),'dd/mm/rrrr') + 1
                                                 When LNM.DRATE= 'Y3' then  365
                                             End
                                             )
                                     ,4))+
                 sum( lnS.FEEINTNMLACR + ROUND(lnS.NML * lnS.CFRATE2 / 100 * TO_NUMBER(LNS.OVERDUEDATE  -lnS.acrdate)
                          / (Case When LNM.DRATE= 'D1' then  30
                                                 When LNM.DRATE= 'D2' then  TO_NUMBER(TO_CHAR(LAST_DAY(TO_DATE(LNS.OVERDUEDATE + 1,'dd/mm/rrrr')),'dd'))
                                                 When LNM.DRATE= 'Y1' then  360
                                                 When LNM.DRATE= 'Y2' then
                                                         TO_DATE(CONCAT('31/12/',SUBSTR(LNS.OVERDUEDATE + 1,7)),'dd/mm/rrrr') - TO_DATE(CONCAT('01/01/',SUBSTR(LNS.OVERDUEDATE + 1,7)),'dd/mm/rrrr') + 1
                                                 When LNM.DRATE= 'Y3' then  365
                                             End
                                             ) ,4))) END)  LAI_DUKIEN,
                  CF.ADDRESS,NVL(CF.MOBILESMS,'') MOBILE,0 CHI_PHI_KHAC,'' mg_chinh,'' mg_phu
             FROM lnmast  lnm, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf,  afmast af, brgrp br, lnschd lns, LNTYPE LNT,AFTYPE AFT
             WHERE  af.custid=cf.custid
                    AND AFT.ACTYPE= AF.ACTYPE
                    AND AFT.PRODUCTTYPE LIKE V_AFTYPE
                    AND LNM.ACCTNO=LNS.ACCTNO
                    AND af.acctno =lnm.trfacctno
                    AND br.brid=cf.brid
                    and lnm.rlsamt >0
                    AND LNM.STATUS<>'Y'
                    AND LNS.NML >0
                    AND LNM.FTYPE='AF'
                    and lns.RLSDATE is not null
                    AND LNT.ACTYPE=LNM.ACTYPE
                    --AND fn_get_prevdate(LNS.OVERDUEDATE,LNT.WARNINGDAYS) <=to_date(V_CUDATE,'dd/mm/rrrr')
                    AND fn_get_prevdate(LNS.OVERDUEDATE,LNT.WARNINGDAYS) =to_date(V_CUDATE,'dd/mm/rrrr')
                    AND LNS.OVERDUEDATE >to_date(V_CUDATE,'dd/mm/rrrr')
              GROUP BY LNS.AUTOID,lnm.acctno,cf.custid, cf.fullname, br.brname, cf.brid,cf.custodycd, lnm.trfacctno,
                    LNS.RLSDATE,lns.overduedate, LNS.NML,CF.ADDRESS,NVL(CF.MOBILESMS,''),LNS.ACRDATE,LNS.DUEDATE
                ) LN
            LEFT JOIN
           (SELECT max(case when TYP.REROLE IN ('CS', 'RM') then CFRE.FULLNAME else '' end) REFULLNAME,
                max(case when TYP.REROLE = 'DG' then CFRE.FULLNAME else '' end) REFULLNAMEFT,
                LNK.AFACCTNO ACCTNO
            FROM REAFLNK LNK, REMAST RE, RETYPE TYP, CFMAST CFRE
            WHERE LNK.deltd <> 'Y' AND TYP.REROLE in ('CS','DG', 'RM')
                AND RE.ACTYPE=TYP.ACTYPE AND RE.CUSTID=CFRE.CUSTID AND RE.ACCTNO=LNK.REACCTNO
                AND LNK.STATUS = 'A'
              --  and lnk.frdate <= V_TDATE
                --and nvl(lnk.clstxdate,lnk.todate) > V_FDATE
            group by LNK.AFACCTNO) RE ON RE.ACCTNO=LN.CUSTID
        WHERE LN.BRID LIKE v_BRID
        ORDER BY LN.INDATE,LN.overduedate ;
    ELSE
        OPEN PV_REFCURSOR FOR
            SELECT V_INDATE INDATE,LN.AUTOID,LN.ACCTNO,LN.CUSTID,LN.FULLNAME,LN.BRID,LN.BRNAME,LN.CUSTODYCD,LN.TRFACCTNO,RLSDATE,
               LN.OVERDUEDATE,LN.NML,LN.LAI_DUKIEN,LN.ADDRESS,LN.MOBILE,LN.CHI_PHI_KHAC, NVL(RE.REFULLNAME,'') MG_CHINH,
               NVL(RE.REFULLNAMEFT,'') MG_PHU,LN.TYPE
            FROM (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF,TBL_MR0057 LN
            LEFT JOIN
               (SELECT max(case when TYP.REROLE = 'CS' then CFRE.FULLNAME else '' end) REFULLNAME,
                    max(case when TYP.REROLE = 'DG' then CFRE.FULLNAME else '' end) REFULLNAMEFT,
                    LNK.AFACCTNO ACCTNO
                FROM REAFLNK LNK, REMAST RE, RETYPE TYP, CFMAST CFRE
                WHERE LNK.deltd <> 'Y' AND TYP.REROLE in ('CS','DG')
                    AND RE.ACTYPE=TYP.ACTYPE AND RE.CUSTID=CFRE.CUSTID AND RE.ACCTNO=LNK.REACCTNO
                    AND LNK.STATUS = 'A'
                    --and lnk.frdate <= V_TDATE
                    --and nvl(lnk.clstxdate,lnk.todate) > V_FDATE
                group by LNK.AFACCTNO) RE 
                ON RE.ACCTNO=LN.CUSTID, AFMAST AF, AFTYPE AFT
            WHERE LN.BRID LIKE v_BRID
                AND LN.CUSTID=CF.CUSTID
                AND LN.INDATE=V_INDATE
                AND af.acctno = ln.trfacctno
                AND CF.CUSTID =AF.CUSTID
                AND AF.ACTYPE= AFT.ACTYPE
                AND AFT.PRODUCTTYPE LIKE V_AFTYPE
          ORDER BY LN.INDATE,LN.overduedate;
          
END IF;

/*SELECT LN.*,NVL(RE.REFULLNAME,'') MG_CHINH,NVL(REFT.REFULLNAME,'') MG_PHU FROM (
 SELECT V_IDATE INDATE,LNS.AUTOID,lnm.acctno,cf.custid, cf.fullname, br.brname, cf.custodycd, lnm.trfacctno,LNS.RLSDATE,lns.overduedate,LNS.NML,
 (CASE WHEN LNS.ACRDATE<LNS.DUEDATE THEN
 --TY LE RATE1
 (  sum(lnS.INTNMLACR + ROUND((lnS.NML * lnS.RATE1 / 100 * TO_NUMBER(LNS.DUEDATE -lnS.acrdate)+lnS.NML * lnS.RATE2 / 100 * TO_NUMBER(LNS.OVERDUEDATE  -lnS.DUEDATE))
                            /(Case When LNM.DRATE= 'D1' then  30
                                       When LNM.DRATE= 'D2' then  TO_NUMBER(TO_CHAR(LAST_DAY(TO_DATE(LNS.OVERDUEDATE + 1,'dd/mm/rrrr')),'dd'))
                                       When LNM.DRATE= 'Y1' then  360
                                       When LNM.DRATE= 'Y2' then
                                               TO_DATE(CONCAT('31/12/',SUBSTR(LNS.OVERDUEDATE + 1,7)),'dd/mm/rrrr') - TO_DATE(CONCAT('01/01/',SUBSTR(LNS.OVERDUEDATE + 1,7)),'dd/mm/rrrr') + 1
                                       When LNM.DRATE= 'Y3' then  365
                                   End
                                   )
                           ,4))+
       sum(lnS.FEEINTNMLACR + ROUND((lnS.NML * lnS.CFRATE1 / 100 * TO_NUMBER(LNS.DUEDATE -lnS.acrdate)+lnS.NML * lnS.CFRATE2 / 100 * TO_NUMBER(LNS.OVERDUEDATE  -lnS.DUEDATE))
                / (Case When LNM.DRATE= 'D1' then  30
                                       When LNM.DRATE= 'D2' then  TO_NUMBER(TO_CHAR(LAST_DAY(TO_DATE(LNS.OVERDUEDATE + 1,'dd/mm/rrrr')),'dd'))
                                       When LNM.DRATE= 'Y1' then  360
                                       When LNM.DRATE= 'Y2' then
                                               TO_DATE(CONCAT('31/12/',SUBSTR(LNS.OVERDUEDATE + 1,7)),'dd/mm/rrrr') - TO_DATE(CONCAT('01/01/',SUBSTR(LNS.OVERDUEDATE + 1,7)),'dd/mm/rrrr') + 1
                                       When LNM.DRATE= 'Y3' then  365
                                   End
                                   )
          ,4)))
 --TY LE RATE2
 ELSE ( sum(lnS.INTNMLACR + ROUND(lnS.NML * lnS.RATE2 / 100 * TO_NUMBER(LNS.OVERDUEDATE  -lnS.acrdate)
                            /(Case When LNM.DRATE= 'D1' then  30
                                       When LNM.DRATE= 'D2' then  TO_NUMBER(TO_CHAR(LAST_DAY(TO_DATE(LNS.OVERDUEDATE + 1,'dd/mm/rrrr')),'dd'))
                                       When LNM.DRATE= 'Y1' then  360
                                       When LNM.DRATE= 'Y2' then
                                               TO_DATE(CONCAT('31/12/',SUBSTR(LNS.OVERDUEDATE + 1,7)),'dd/mm/rrrr') - TO_DATE(CONCAT('01/01/',SUBSTR(LNS.OVERDUEDATE + 1,7)),'dd/mm/rrrr') + 1
                                       When LNM.DRATE= 'Y3' then  365
                                   End
                                   )
                           ,4))+
       sum( lnS.FEEINTNMLACR + ROUND(lnS.NML * lnS.CFRATE2 / 100 * TO_NUMBER(LNS.OVERDUEDATE  -lnS.acrdate)
                / (Case When LNM.DRATE= 'D1' then  30
                                       When LNM.DRATE= 'D2' then  TO_NUMBER(TO_CHAR(LAST_DAY(TO_DATE(LNS.OVERDUEDATE + 1,'dd/mm/rrrr')),'dd'))
                                       When LNM.DRATE= 'Y1' then  360
                                       When LNM.DRATE= 'Y2' then
                                               TO_DATE(CONCAT('31/12/',SUBSTR(LNS.OVERDUEDATE + 1,7)),'dd/mm/rrrr') - TO_DATE(CONCAT('01/01/',SUBSTR(LNS.OVERDUEDATE + 1,7)),'dd/mm/rrrr') + 1
                                       When LNM.DRATE= 'Y3' then  365
                                   End
                                   ) ,4))) END)  LAI_DUKIEN,CF.ADDRESS,NVL(CF.MOBILESMS,'') MOBILE,0 CHI_PHI_KHAC
   FROM vw_lnmast_all  lnm, cfmast cf,  afmast af, brgrp br, vw_lnschd_all lns, LNTYPE LNT
   WHERE  af.custid=cf.custid
        AND LNM.ACCTNO=LNS.ACCTNO
        AND af.acctno =lnm.trfacctno
        AND br.brid=cf.brid
        and lnm.rlsamt >0
\*        AND LNS.REFTYPE='P'
        AND LNS.DUESTS='N'*\
        AND LNM.STATUS<>'Y'
        AND LNS.NML >0
        AND LNM.FTYPE<>'DF'
        and lns.RLSDATE is not null
         AND LNT.ACTYPE=LNM.ACTYPE
        AND fn_get_prevdate(LNS.OVERDUEDATE,LNT.WARNINGDAYS) <=getcurrdate
         AND LNS.OVERDUEDATE >GETCURRDATE
        --AND substr(CF.custid,1,4) LIKE V_INBRID
        AND CF.BRID LIKE v_BRID
        GROUP BY LNS.AUTOID,lnm.acctno,cf.custid, cf.fullname, br.brname, cf.custodycd, lnm.trfacctno,LNS.RLSDATE,lns.overduedate,
      LNS.NML,CF.ADDRESS,NVL(CF.MOBILESMS,''),LNS.ACRDATE,LNS.DUEDATE
        )LN
LEFT JOIN
 (--moi gioi chinh-tu van dau tu vip
SELECT CFRE.CUSTID RECUSTID, CFRE.FULLNAME REFULLNAME, A0.CDCONTENT DESC_REROLE,
CF.CUSTODYCD, CF.FULLNAME CUSTNAME, LNK.AFACCTNO ACCTNO, LNK.FRDATE, LNK.TODATE
FROM REAFLNK LNK, CFMAST CF, REMAST RE, RETYPE TYP, CFMAST CFRE, ALLCODE A0 , RECFLNK RF
WHERE CF.CUSTID=LNK.AFACCTNO AND LNK.STATUS='A' AND TYP.REROLE='CS'
AND RE.ACTYPE=TYP.ACTYPE AND RE.CUSTID=CFRE.CUSTID AND RE.ACCTNO=LNK.REACCTNO
AND A0.CDTYPE='RE' AND A0.CDNAME='REROLE' AND A0.CDVAL=TYP.REROLE
 AND LNK.refrecflnkid=RF.autoid AND (v_BRID ='0001' or  RF.BRID LIKE v_BRID)
 ) RE

ON RE.ACCTNO=LN.CUSTID AND  LN.RLSDATE >=re.frdate AND LN.RLSDATE < re.todate

LEFT JOIN
 (--moi giơi phu-cham soc ho
SELECT CFRE.CUSTID RECUSTID, CFRE.FULLNAME REFULLNAME, A0.CDCONTENT DESC_REROLE,
CF.CUSTODYCD, CF.FULLNAME CUSTNAME, LNK.AFACCTNO ACCTNO, LNK.FRDATE, LNK.TODATE
FROM REAFLNK LNK, CFMAST CF, REMAST RE, RETYPE TYP, CFMAST CFRE, ALLCODE A0 , RECFLNK RF
WHERE CF.CUSTID=LNK.AFACCTNO AND LNK.STATUS='A' AND TYP.REROLE='DG'
AND RE.ACTYPE=TYP.ACTYPE AND RE.CUSTID=CFRE.CUSTID AND RE.ACCTNO=LNK.REACCTNO
AND A0.CDTYPE='RE' AND A0.CDNAME='REROLE' AND A0.CDVAL=TYP.REROLE
 AND LNK.refrecflnkid=RF.autoid AND (v_BRID ='0001' or  RF.BRID LIKE v_BRID)
 ) REFT

ON REFT.ACCTNO=LN.CUSTID AND  LN.RLSDATE >=reft.frdate AND LN.RLSDATE < reft.todate*/


 EXCEPTION
   WHEN OTHERS
   THEN
        RETURN;
END;
 
 
 
 
/
