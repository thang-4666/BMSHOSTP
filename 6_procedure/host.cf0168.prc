SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "CF0168" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   PV_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2,
   PV_CUSTODYCD   IN       VARCHAR2,
   PV_VIA         IN       VARCHAR2,
   PV_AUTHTYPE    IN       VARCHAR2
 )
IS
--
-- PURPOSE: BRIEFLY EXPLAIN THE FUNCTIONALITY OF THE PROCEDURE
--
-- MODIFICATION HISTORY
-- PERSON      DATE       COMMENTS
-- Diennt      28/12/2011 Create
-- ---------   ------     -------------------------------------------
   V_STROPTION        VARCHAR2 (5);       -- A: ALL; B: BRANCH; S: SUB-BRANCH
   V_STRBRGID           VARCHAR2 (10);
   V_branch  varchar2(5);
   V_INBRID        VARCHAR2(4);
   V_STRBRID      VARCHAR2 (50);
   V_STRSTATUS    VARCHAR2 (10);
   V_CRITERIAS      VARCHAR2 (4000);
   l_fdate            DATE;
   l_tdate            DATE;
   V_CUSTODYCD     VARCHAR2(10);
   l_CUSTODYCD     VARCHAR2(200);
   V_VIA     VARCHAR2(200);
   l_VIA     VARCHAR2(200);
   V_AUTHTYPE VARCHAR2(200);
   l_AUTHTYPE VARCHAR2(200);
-- DECLARE PROGRAM VARIABLES AS SHOWN ABOVE

BEGIN
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
    IF (UPPER(PV_VIA) <> 'ALL')THEN
        Select cdcontent
        into V_VIA
        FROM ALLCODE
        WHERE CDNAME='VIA'
            and cdtype='FO'
            and CDVAL=UPPER(PV_VIA);
    else
        V_VIA:='ALL';
    end if;
    IF (UPPER(PV_AUTHTYPE) <> 'ALL')THEN
        Select cdcontent
        into V_AUTHTYPE
        FROM ALLCODE
        WHERE CDNAME='OTAUTHTYPE'
            and cduser='Y'
            and CDVAL=UPPER(PV_AUTHTYPE);
    else
        V_AUTHTYPE:='ALL';
    end if;
    with tmplabel as (
        Select max(case when  fldname = 'PV_CUSTODYCD' then caption else '' end ) CUSTODYCD
                ,max(case when  fldname = 'PV_VIA' then caption else '' end ) VIA
                ,max(case when  fldname = 'PV_AUTHTYPE' then caption else '' end ) AUTHTYPE
        from rptfields
        where objname ='CF0168'
                and  fldname in ('PV_CUSTODYCD','PV_VIA','PV_AUTHTYPE')
    )
    Select CUSTODYCD ||' : ' || PV_CUSTODYCD
         , VIA||' : ' || V_VIA
         , AUTHTYPE||' : ' || V_AUTHTYPE
    into l_CUSTODYCD
        ,l_VIA
        , l_AUTHTYPE
    from tmplabel;

  V_CRITERIAS:=l_CUSTODYCD||'#'
              || l_VIA||'#'
              || l_AUTHTYPE
              ||'#';

    l_fdate   := TO_DATE(F_DATE, systemnums.C_DATE_FORMAT);
    l_tdate   := TO_DATE(T_DATE, systemnums.C_DATE_FORMAT);
    IF (UPPER(PV_CUSTODYCD) <> 'ALL')THEN
        V_CUSTODYCD:= PV_CUSTODYCD;
    ELSE
        V_CUSTODYCD := '%';
    END IF;
   IF (UPPER(PV_VIA) <> 'ALL')THEN
      V_VIA := UPPER(PV_VIA);
   ELSE
      V_VIA := '%';
   END IF;

   IF (UPPER(PV_AUTHTYPE) <> 'ALL')THEN
      V_AUTHTYPE := UPPER(PV_AUTHTYPE);
   ELSE
      V_AUTHTYPE := '%';
   END IF;

OPEN PV_REFCURSOR
  FOR
    with tmpOTAUTHTYPE as (
        Select cdval authType,cdcontent authType_Content  FROM ALLCODE
        WHERE CDNAME='OTAUTHTYPE'
        and cduser='Y'
    )
    ,tmpVIA as (
        Select CDVAL VIA, cdcontent via_content FROM ALLCODE
        WHERE CDNAME='VIA'
        and cdtype='FO'
      )
    ,tmpOTright as (
    Select cf.custodycd
            , cf.fullname
            , cf.idcode
            , cf.iddate
            , cf.idplace
            , cf.address
            , ot.via
            , ot.authtype
            , ot.valdate
    from otright ot
    left join cfmast cf on ot.cfcustid = cf.custid
    where ot.valdate between l_fdate and l_tdate
     and ot.deltd='N'
     and cf.status!='C'
)
select V_CRITERIAS CRITERIAS
        ,ot.custodycd SoTK
        , ot.fullname HoVaTen
        , ot.idcode CMND
        , ot.iddate NgayCap
        , ot.idplace NoiCap
        , ot.address DiaChi
        , v.via_content Kenh
        , t.authType_Content Kieu
        , ot.valdate NgayHL
from tmpOTright ot
left join tmpVIA v on v.via = ot.via
left join tmpOTAUTHTYPE t on t.authType = ot.authtype
where ot.custodycd like V_CUSTODYCD
and ot.via like V_VIA
and ot.authType like v_authtype;

EXCEPTION
   WHEN OTHERS
   THEN
plog.error('CF0168: '||SQLERRM || dbms_utility.format_error_backtrace);
      RETURN;
End;
 
/
