SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE cf0020 (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   PV_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2,
   I_BRIDGD       IN       VARCHAR2,
   PV_STATUSVSD       IN       VARCHAR2,
   BRANCH           IN       VARCHAR2,
   PV_CLASS        IN        VARCHAR2,
   PV_CUSTATCOM    IN        VARCHAR2,
   PV_OPENVIA    IN        VARCHAR2
 )
IS
--
-- PURPOSE: BAO CAO DSKH MO TK (GUI HNX)
-- MODIFICATION HISTORY
-- PERSON      DATE      COMMENTS
-- QUOCTA   23-12-2011   CREATED
-- ---------   ------  -------------------------------------------

   V_STROPTION         VARCHAR2  (10);

   V_INBRID        VARCHAR2(10);
   V_STRBRID      VARCHAR2 (50);

   V_F_DATE            DATE;
   V_T_DATE            DATE;

   V_I_BRIDGD          VARCHAR2(100);
   V_BRNAME            NVARCHAR2(400);
    v_STRSTATUSVSD        VARCHAR2(100);

    V_STRCLASS           VARCHAR2(100);
    V_STRCUSTATCOM       VARCHAR2(10);
    v_STROPENVIA        varchar2(10);
    v_strcust            varchar2(10);
BEGIN
  /* V_STROPTION := OPT;

   IF (V_STROPTION <> 'A') AND (BRID <> 'ALL')
   THEN
      V_STRBRID := BRID;
   ELSE
      V_STRBRID := '%%';
   END IF;
*/
    V_STROPTION := upper(OPT);
 V_INBRID := PV_BRID;
    if(V_STROPTION = 'A') then
        V_STRBRID := '%%';
    else
        if(V_STROPTION = 'B') then
            select br.brid into V_STRBRID from brgrp br where  br.brid = V_INBRID;
        else
            V_STRBRID := V_INBRID;
        end if;
    end if;
    if PV_OPENVIA = 'A' then
        v_STROPENVIA := '%';
    else
        v_STROPENVIA := PV_OPENVIA;
    end if;
   -- GET REPORT'S PARAMETERS
   V_F_DATE        := TO_DATE(F_DATE, SYSTEMNUMS.C_DATE_FORMAT);
   V_T_DATE        := TO_DATE(T_DATE, SYSTEMNUMS.C_DATE_FORMAT);

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
      V_BRNAME   :=  ' Toan cong ty ';
   END IF;

   IF (PV_STATUSVSD IS NULL OR UPPER(PV_STATUSVSD) = 'ALL')
   THEN
      v_STRSTATUSVSD := '%';
   ELSE
      v_STRSTATUSVSD := PV_STATUSVSD;
   END IF;

          IF (PV_CLASS IS NULL OR UPPER(PV_CLASS) = 'ALL')
   THEN
      V_STRCLASS := '%';
   ELSE
      V_STRCLASS := PV_CLASS;
   END IF;

   IF PV_CUSTATCOM = 'Y' THEN
     V_STRCUSTATCOM := '%';
     v_strcust:='%';
     ELSE
       V_STRCUSTATCOM := 'Y';
       v_strcust:=systemnums.C_COMPANYCD||'%';
       END IF;

   -- GET REPORT'S DATA
      OPEN PV_REFCURSOR
      FOR

      SELECT CF.FULLNAME,case when cf.custatcom = 'Y' then '005' else 'N/A' end  TVCODE, CF.CUSTODYCD,'' ACCTNO, CF.IDCODE, CF.ADDRESS, CF.IDDATE, CF.IDPLACE,
          (CASE WHEN substr(cf.custodycd,4,1) = 'F' THEN 'NN' ELSE 'TN' END) || '-' ||
          (CASE WHEN CF.CUSTTYPE = 'I' THEN 'CN' WHEN CF.CUSTTYPE = 'B' THEN 'TC' END) CUSTTYPE_NAME,
          CF.OPNDATE, AL.CDCONTENT COUNTRY_NAME,
          al2.cdcontent, CR.grpname, to_date(T_DATE,'dd/mm/yyyy') todate, PV_BRID pv_brid,BRANCH BRANCH ,
          (CASE WHEN CF.CUSTTYPE='I' THEN '' ELSE A2.CDCONTENT END) BUSINESSTYPE,
          (CASE WHEN CF.CUSTTYPE='I' THEN '' ELSE '0' END) BANK,cf.mobilesms,
           CF.OPENVIA
      FROM  (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF,
             ALLCODE AL, allcode al2,(select * from tlgroups where GRPTYPE = '2' and Active ='Y') CR, ALLCODE A2
      WHERE CF.COUNTRY = AL.CDVAL
          AND AL.CDNAME  = 'COUNTRY'
          AND AL.CDTYPE  = 'CF'
          AND CF.CUSTODYCD like v_strcust
          AND CF.ACTIVESTS LIKE v_STRSTATUSVSD
          AND(CF.STATUS='A' OR (CF.STATUS <>'C' AND INSTR(CF.pstatus,'A') <> 0))
          AND A2.CDTYPE='CF' AND A2.CDNAME='BUSINESSTYPE' AND A2.CDVAL=CF.BUSINESSTYPE
          and al2.cdtype = 'CF' and al2.cdname = 'COUNTRY'
          AND CF.COUNTRY = AL2.CDVAL
          and cf.CUSTODYCD is not null
          AND CF.CUSTATCOM LIKE 'Y'
          AND      (CASE WHEN CF.CLASS='000' THEN 'Y' ELSE 'N' END) LIKE V_STRCLASS
          AND CF.OPNDATE >= V_F_DATE AND cf.opndate <= V_T_DATE
          AND CF.BRID LIKE V_I_BRIDGD
          AND cf.careby = cr.grpid(+)
          and cf.openvia like v_STROPENVIA
      ---    ORDER BY CF.CUSTODYCD
      union all
      SELECT CF.FULLNAME,case when cf.custatcom = 'Y' then '005' else 'N/A' end  TVCODE, CF.CUSTODYCD,'' ACCTNO, CF.IDCODE, CF.ADDRESS, CF.IDDATE, CF.IDPLACE,
          (CASE WHEN substr(cf.custodycd,4,1) = 'F' THEN 'NN' ELSE 'TN' END) || '-' ||
          (CASE WHEN CF.CUSTTYPE = 'I' THEN 'CN' WHEN CF.CUSTTYPE = 'B' THEN 'TC' END) CUSTTYPE_NAME,
          CF.OPNDATE, AL.CDCONTENT COUNTRY_NAME,
          al.cdcontent, CR.grpname, to_date(T_DATE,'dd/mm/yyyy') todate, PV_BRID pv_brid,BRANCH BRANCH,
          (CASE WHEN CF.CUSTTYPE='I' THEN '' ELSE A2.CDCONTENT END) BUSINESSTYPE,
          (CASE WHEN CF.CUSTTYPE='I' THEN '' ELSE '0' END) BANK,cf.mobilesms,
           CF.OPENVIA
      FROM vw_tllog_all, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf,
            ALLCODE AL,(select * from tlgroups where GRPTYPE = '2' and Active ='Y') CR,  ALLCODE A2,
          (SELECT * FROM VW_TLLOGFLD_ALL WHERE FLDCD='08') FLD
          WHERE tltxcd = '0067'  AND vw_tllog_all.TXDATE=FLD.TXDATE AND vw_tllog_all.TXNUM=FLD.TXNUM AND FLD.CVALUE='Y'
              AND busdate <= to_date(T_DATE,'dd/mm/rrrr')
              AND busdate >= to_date(F_DATE,'dd/mm/rrrr') AND deltd <> 'Y'
              AND cf.custid = vw_tllog_all.msgacct
              AND CF.CUSTATCOM LIKE 'Y'
              and CF.COUNTRY = AL.CDVAL
              AND AL.CDNAME  = 'COUNTRY'
              AND vw_tllog_all.TXSTATUS IN ('1','7')
              AND AL.CDTYPE  = 'CF'
               AND CF.CUSTODYCD like v_strcust
              AND CF.ACTIVESTS LIKE v_STRSTATUSVSD
               AND(CF.STATUS='A' OR (CF.STATUS <>'C' AND INSTR(CF.pstatus,'A') <> 0))
               AND A2.CDTYPE='CF' AND A2.CDNAME='BUSINESSTYPE' AND A2.CDVAL=CF.BUSINESSTYPE
              AND      (CASE WHEN CF.CLASS='000' THEN 'Y' ELSE 'N' END) LIKE V_STRCLASS
              AND CF.BRID LIKE V_I_BRIDGD
              AND cf.careby = cr.grpid(+)
              and cf.openvia like v_STROPENVIA
      ;

EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;


-- End of DDL Script for Procedure HOST.CF0017
 
 
 
 
/
