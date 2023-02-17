SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "CF7004" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   pv_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2

 )
IS

   V_STROPTION        VARCHAR2 (5);       -- A: ALL; B: BRANCH; S: SUB-BRANCH

   -- DECLARE PROGRAM VARIABLES AS SHOWN ABOVE
   V_STRPV_CUSTODYCD VARCHAR2(20);
   V_STRPV_AFACCTNO VARCHAR2(20);
   V_INBRID        VARCHAR2(4);
   V_STRBRID      VARCHAR2 (50);


BEGIN



    V_STROPTION := upper(OPT);
    V_INBRID := pv_BRID;
    if(V_STROPTION = 'A') then
        V_STRBRID := '%%';
    else
        if(V_STROPTION = 'B') then
            select br.mapid into V_STRBRID from brgrp br where  br.brid = V_INBRID;
        else
            V_STRBRID := V_INBRID;
        end if;
    end if;


OPEN PV_REFCURSOR
  FOR


Select cf.custodycd,af.acctno,cf.fullname,cf.dateofbirth,cf.idcode,cf.iddate,cf.idplace,cf.address,cf.phone,cf.mobile,cf.email,cf.tradetelephone,
    tradeonline,af.mrcrlimit,cf.vat,
    cf.careby carebyid , tl.grpname carebyname , aft.actype ,aft.typename,
    cf.custatcom, af.corebank, af.bankname, af.bankacctno, af.status,cf.idtype
from (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf ,afmast af , aftype aft,  tlgroups tl
where cf.careby = tl.grpid
and af.custid = cf.custid and af.actype =aft.actype;



EXCEPTION
   WHEN OTHERS
   THEN

      RETURN;
End;

 
 
 
 
/
