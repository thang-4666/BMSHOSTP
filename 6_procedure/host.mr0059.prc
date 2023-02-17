SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE mr0059 (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   pv_OPT         IN       VARCHAR2,
   pv_BRID        IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
 /*  F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2,*/
   I_DATE         IN       VARCHAR2,
   I_BRID         IN       VARCHAR2,
   PV_AFTYPE      IN       VARCHAR2
)
IS

---------------------------------
--BAO CAO DANH SACH MUC DEN NGUONG CANH CAO
--NGOCVTT 19/04/2015

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

    IF(PV_AFTYPE IS NULL OR UPPER(PV_AFTYPE) = 'ALL')
    THEN V_AFTYPE := '%%';
      ELSE V_AFTYPE := PV_AFTYPE;
      END IF;

    V_INDATE:=TO_DATE(I_DATE,'DD/MM/RRRR');

    SELECT TO_DATE(VARVALUE,'DD/MM/RRRR') INTO V_CUDATE FROM SYSVAR WHERE VARNAME='CURRDATE';

   ----
-- GET REPORT'S DATA
IF V_INDATE=V_CUDATE THEN
OPEN PV_REFCURSOR FOR

SELECT V_INDATE INDATE,LN.BRID,LN.BRNAME,LN.CUSTID,LN.FULLNAME,LN.CUSTODYCD,LN.ACCTNO,LN.MARGINRATE,LN.MRIRATE, LN.MRMRATE,LN.MRLRATE,
       LN.MRCRATE,LN.MRWRATE,LN.ADD_TO_MRIRATE,LN.SE_TO_MRIRATE,LN.SE_TO_MRIRATEUB,NVL(RE.REFULLNAME,'')MG_CHINH,NVL(RE.REFULLNAMEFT,'') MG_PHU ,'' TYPE

FROM(SELECT to_date(V_CUDATE,'dd/mm/rrrr') INDATE,CF.BRID,BR.BRNAME,CF.CUSTID, CF.FULLNAME,CF.CUSTODYCD,AF.ACCTNO,NVL(CI.MARGINRATE,0) MARGINRATE,
           AF.MRIRATE, AF.MRMRATE,AF.MRLRATE,AF.MRCRATE,AF.MRWRATE,
           (case when aft.mnemonic<>'T3' then
           round((case when nvl(ci.marginrate,0) * af.mrmrate =0 then - nvl(ci.se_outstanding,0) else greatest( 0,- nvl(ci.se_outstanding,0) - nvl(ci.se_navaccount,0) *100/AF.MRIRATE) end),0)
           else 0  end) ADD_TO_MRIRATE, --So tien can bo sung ve Rat
          GREATEST(af.mrirate/100 * round(-ci.se_outstanding) - ci.seass,0) SE_TO_MRIRATE, -- se can bo sung dat Rat
            GREATEST(round((-af.mrirate/100 * ci.se_outstanding - ci.seass) / (af.mrirate/100 - 0.5),4),0) SE_TO_MRIRATEUB,
            '' MG_CHINH, '' MG_PHU

      FROM (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF,
       AFMAST AF, BRGRP BR, BUF_CI_ACCOUNT CI,AFTYPE AFT
      WHERE AF.CUSTID=CF.CUSTID
            AND CF.BRID=BR.BRID(+)
            AND CI.AFACCTNO=AF.ACCTNO
            AND AF.ACTYPE=AFT.ACTYPE
            AND AFT.PRODUCTTYPE LIKE V_AFTYPE
           /* AND AF.ACTYPE<>'0000'
            AND CI.MARGINRATE<= AF.MRWRATE
            AND CI.MARGINRATE>=AF.MRMRATE*/
            AND  (
              (AFT.MNEMONIC <>'T3') and
                  ((ci.marginrate<AF.MRwRATE and ci.marginrate>=AF.MRCRATE)-- chi pham ti le canh bao
                  OR (ci.MARGINRATE<AF.MRCRATE AND ci.MARGINRATE>=AF.MRMRATE AND AF.Callday=0)))
       )LN

LEFT JOIN
             (SELECT max(case when TYP.REROLE = 'CS' then CFRE.FULLNAME else '' end) REFULLNAME,
                  max(case when TYP.REROLE = 'DG' then CFRE.FULLNAME else '' end) REFULLNAMEFT,
                  LNK.AFACCTNO ACCTNO
              FROM REAFLNK LNK, REMAST RE, RETYPE TYP, CFMAST CFRE
              WHERE LNK.deltd <> 'Y' AND TYP.REROLE in ('CS','DG')
                  AND RE.ACTYPE=TYP.ACTYPE AND RE.CUSTID=CFRE.CUSTID AND RE.ACCTNO=LNK.REACCTNO
                    AND LNK.STATUS = 'A'
                 -- and lnk.frdate <= V_TDATE
                --  and nvl(lnk.clstxdate,lnk.todate) > V_FDATE
              group by LNK.AFACCTNO) RE ON RE.ACCTNO=LN.CUSTID

WHERE LN.BRID LIKE V_BRID
ORDER BY LN.INDATE,LN.CUSTODYCD,LN.ACCTNO;

ELSE
OPEN PV_REFCURSOR FOR

   SELECT V_INDATE INDATE,LN.BRID,LN.BRNAME,LN.CUSTID,LN.FULLNAME,LN.CUSTODYCD,LN.ACCTNO,LN.MARGINRATE,LN.MRIRATE, LN.MRMRATE,LN.MRLRATE,
       LN.MRCRATE,LN.MRWRATE,LN.ADD_TO_MRIRATE,LN.SE_TO_MRIRATE,LN.SE_TO_MRIRATEUB,NVL(RE.REFULLNAME,'')MG_CHINH,NVL(RE.REFULLNAMEFT,'') MG_PHU ,LN.TYPE

FROM (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF , TBL_MR0059 LN
   LEFT JOIN
       (SELECT max(case when TYP.REROLE = 'CS' then CFRE.FULLNAME else '' end) REFULLNAME,
            max(case when TYP.REROLE = 'DG' then CFRE.FULLNAME else '' end) REFULLNAMEFT,
            LNK.AFACCTNO ACCTNO
        FROM REAFLNK LNK, REMAST RE, RETYPE TYP, CFMAST CFRE
        WHERE LNK.deltd <> 'Y' AND TYP.REROLE in ('CS','DG')
            AND RE.ACTYPE=TYP.ACTYPE AND RE.CUSTID=CFRE.CUSTID AND RE.ACCTNO=LNK.REACCTNO
           -- and lnk.frdate <= V_TDATE
          --  and nvl(lnk.clstxdate,lnk.todate) > V_FDATE
        group by LNK.AFACCTNO) RE ON RE.ACCTNO=LN.CUSTID, AFMAST AF, AFTYPE AFT
   WHERE LN.BRID LIKE V_BRID
   AND CF.CUSTID=LN.CUSTID
   AND AF.CUSTID =CF.CUSTID
   AND AFT.ACTYPE = AF.ACTYPE
   AND AFT.PRODUCTTYPE LIKE V_AFTYPE
   AND fn_get_prevdate(LN.INDATE,1)=V_INDATE
   ORDER BY LN.INDATE,LN.CUSTODYCD,LN.ACCTNO;
END IF;
/*SELECT LN.*,NVL(RE.REFULLNAME,'') MG_CHINH, NVL(REFT.REFULLNAME,'') MG_PHU FROM (
 SELECT V_CUDATE INDATE,BR.BRNAME,CF.CUSTID, CF.FULLNAME,CF.CUSTODYCD,AF.ACCTNO,NVL(CI.MARGINRATE,0) MARGINRATE,
       AF.MRIRATE, AF.MRMRATE,AF.MRLRATE,AF.MRCRATE,AF.MRWRATE,
       (case when aft.mnemonic<>'T3' then
       round((case when nvl(ci.marginrate,0) * af.mrmrate =0 then - nvl(ci.se_outstanding,0) else greatest( 0,- nvl(ci.se_outstanding,0) - nvl(ci.se_navaccount,0) *100/AF.MRIRATE) end),0)
       else 0  end) ADD_TO_MRIRATE, --So tien can bo sung ve Rat
      GREATEST(af.mrirate/100 * round(-ci.se_outstanding) - ci.seass,0) SE_TO_MRIRATE, -- se can bo sung dat Rat
        GREATEST(round((-af.mrirate/100 * ci.se_outstanding - ci.seass) / (af.mrirate/100 - 0.5),4),0) SE_TO_MRIRATEUB
FROM CFMAST CF, AFMAST AF, BRGRP BR, BUF_CI_ACCOUNT CI,AFTYPE AFT
WHERE AF.CUSTID=CF.CUSTID
      AND CF.BRID=BR.BRID(+)
      AND CI.AFACCTNO=AF.ACCTNO
      AND AF.ACTYPE=AFT.ACTYPE
      AND AF.ACTYPE<>'0000'
      AND CI.MARGINRATE<= AF.MRWRATE
      AND CI.MARGINRATE>=AF.MRMRATE
      AND SUBSTR(CF.CUSTID,1,4) LIKE V_INBRID
      AND CF.BRID LIKE v_BRID
        )LN
LEFT JOIN
 (--moi gioi chinh-tu van dau tu vip
SELECT CFRE.CUSTID RECUSTID, CFRE.FULLNAME REFULLNAME, A0.CDCONTENT DESC_REROLE,
CF.CUSTODYCD, CF.FULLNAME CUSTNAME, LNK.AFACCTNO ACCTNO, LNK.FRDATE, LNK.TODATE
FROM REAFLNK LNK, CFMAST CF, REMAST RE, RETYPE TYP, CFMAST CFRE, ALLCODE A0 , RECFLNK RF
WHERE CF.CUSTID=LNK.AFACCTNO AND LNK.STATUS='A' AND TYP.REROLE='CS'
AND RE.ACTYPE=TYP.ACTYPE AND RE.CUSTID=CFRE.CUSTID AND RE.ACCTNO=LNK.REACCTNO
AND A0.CDTYPE='RE' AND A0.CDNAME='REROLE' AND A0.CDVAL=TYP.REROLE
 AND LNK.refrecflnkid=RF.autoid AND (V_INBRID ='0001' or  RF.BRID LIKE V_INBRID)
 ) RE

ON RE.ACCTNO=LN.CUSTID-- AND  LN.RLSDATE >=re.frdate AND LN.RLSDATE < re.todate

LEFT JOIN
 (--moi gioi phu-cham soc ho
SELECT CFRE.CUSTID RECUSTID, CFRE.FULLNAME REFULLNAME, A0.CDCONTENT DESC_REROLE,
CF.CUSTODYCD, CF.FULLNAME CUSTNAME, LNK.AFACCTNO ACCTNO, LNK.FRDATE, LNK.TODATE
FROM REAFLNK LNK, CFMAST CF, REMAST RE, RETYPE TYP, CFMAST CFRE, ALLCODE A0 , RECFLNK RF
WHERE CF.CUSTID=LNK.AFACCTNO AND LNK.STATUS='A' AND TYP.REROLE='DG'
AND RE.ACTYPE=TYP.ACTYPE AND RE.CUSTID=CFRE.CUSTID AND RE.ACCTNO=LNK.REACCTNO
AND A0.CDTYPE='RE' AND A0.CDNAME='REROLE' AND A0.CDVAL=TYP.REROLE
 AND LNK.refrecflnkid=RF.autoid AND (V_INBRID ='0001' or  RF.BRID LIKE V_INBRID)
 ) REFT

ON REFT.ACCTNO=LN.CUSTID-- AND  LN.RLSDATE >=reft.frdate AND LN.RLSDATE < reft.todate
ORDER BY ln.CUSTODYCD,ln.ACCTNO
    ;*/

 EXCEPTION
   WHEN OTHERS
   THEN
        RETURN;
END;
 
 
 
 
/
