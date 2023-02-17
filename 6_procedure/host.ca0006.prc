SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "CA0006" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   pv_BRID        IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   V_CACODE       IN       VARCHAR2
   )
IS
--
-- PURPOSE: BRIEFLY EXPLAIN THE FUNCTIONALITY OF THE PROCEDURE
-- BAO CAO TAI KHOAN TIEN TONG HOP CUA NGUOI DAU TU
-- MODIFICATION HISTORY
-- PERSON      DATE    COMMENTS
-- NAMNT   20-DEC-06  CREATED
-- ---------   ------  -------------------------------------------

    CUR             PKG_REPORT.REF_CURSOR;
    V_STROPTION    VARCHAR2 (5);            -- A: ALL; B: BRANCH; S: SUB-BRANCH
    V_STRBRID      VARCHAR2 (4);
    V_STRCACODE    VARCHAR2 (20);

BEGIN

  /* V_STROPTION := OPT;

   IF (V_STROPTION <> 'A') AND (BRID <> 'ALL')
   THEN
      V_STRBRID := BRID;
   ELSE
      V_STRBRID := '%%';
   END IF;
*/
   IF (V_CACODE <> 'ALL' OR V_CACODE <> '')
   THEN
      V_STRCACODE := replace(V_CACODE,'.','');
   ELSE
      V_STRCACODE := '%%';
   END IF;


OPEN PV_REFCURSOR
FOR


     SELECT SB.SYMBOL, ISS.FULLNAME ISS_NAME, CF.CUSTID, CF.FULLNAME, (case when cf.country = '234' then cf.idcode else cf.tradingcode end) IDCODE,
        decode (cf.idtype, 001, 1, 002, 2, 003, 3, 005, 5, 4 ) idcode_type , al.cdcontent country,
        sum(ca.BALANCE + ca.PBALANCE) BALANCE, cf.address,
        (case when substr(cf.custodycd, 4, 1) = 'C' and af.aftype = 001 then 3
              when substr(cf.custodycd, 4, 1) = 'F' and af.aftype = 001 then 4
              when (substr(cf.custodycd,4,1)  = 'C' and af.aftype <> 001 ) or substr(cf.custodycd,4,1) = 'P' then 5
              when substr(cf.custodycd,4,1)   ='F' and af.aftype <> 001 then 6  end) aftype,camast.reportdate ,
              camast.description,
     decode (substr(cf.custodycd ,4,1),'P',2,1) tpye_acc, sb.parvalue, camast.reportdate reportdate1
    FROM vw_CASCHD_all CA, AFMAST AF, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF, ALLCODE AL, SBSECURITIES SB, ISSUERS ISS, vw_CAMAST_all camast
    where ca.afacctno  = af.acctno
    and af.custid = cf.custid
    and cf.country = al.cdval
    and al.cdname ='COUNTRY'
    and ca.codeid = sb.codeid
    AND CA.STATUS<>'O'
    and sb.issuerid  = iss.issuerid
    and ca.deltd  <>'Y'
    and (ca.BALANCE + ca.pbalance) > 0
    and ca.camastid =camast.camastid
    and  ca.camastid like V_STRCACODE
    GROUP BY SB.SYMBOL, ISS.FULLNAME , CF.CUSTID, CF.FULLNAME,
    (case when cf.country = '234' then cf.idcode else cf.tradingcode end) ,
        decode (cf.idtype, 001, 1, 002, 2, 003, 3, 005, 5, 4 )  , al.cdcontent ,
        cf.address,
        (case when substr(cf.custodycd, 4, 1) = 'C' and af.aftype = 001 then 3
              when substr(cf.custodycd, 4, 1) = 'F' and af.aftype = 001 then 4
              when (substr(cf.custodycd,4,1)  = 'C' and af.aftype <> 001 ) or substr(cf.custodycd,4,1) = 'P' then 5
              when substr(cf.custodycd,4,1)   ='F' and af.aftype <> 001 then 6  end),camast.reportdate ,
              camast.description,
     decode (substr(cf.custodycd ,4,1),'P',2,1) , sb.parvalue, camast.reportdate

    ;


EXCEPTION
   WHEN OTHERS
   then
        --plog.error('Report:'||'CA0006:'||SQLERRM|| ':'||dbms_utility.format_error_backtrace);
      RETURN;
END;                                                              -- PROCEDURE

 
 
 
 
/
