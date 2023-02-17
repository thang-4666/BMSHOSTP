SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE ttdvtt (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   pv_OPT         IN       VARCHAR2,
   pv_BRID        IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   PV_IDCODE      IN       VARCHAR2
)
IS

----------------------------
--HOP DONG MO TAI KHOAN
--TANPN 28/09/2021

-- ---------   ------  -------------------------------------------
   l_STROPTION        VARCHAR2 (5);       -- A: ALL; B: BRANCH; S: SUB-BRANCH
   l_STRBRID          VARCHAR2 (4);

   V_IDATE           DATE;
   V_CUDATE        DATE;
   V_INBRID         VARCHAR2(4);
   V_STRBRID        VARCHAR2 (50);
   V_STROPTION      VARCHAR2(10);
   v_BRID        VARCHAR2(20);


BEGIN

   V_STROPTION := upper(pv_OPT);
   V_INBRID := pv_BRID;

 -- END OF GETTING REPORT'S PARAMETERS
   ----
-- GET REPORT'S DATA
OPEN PV_REFCURSOR FOR

    select api.custodycd,api.txdate, api.fullname,cft.typename actype, reg.idcode, reg.iddate, reg.idplace, reg.customerbirth,
    reg.address, reg.contactaddress, reg.email, reg.mobile
    from registeronline reg, apiopenaccount api, cfmast cf, cftype cft
    where api.idcode = reg.idcode
        and cf.idcode = reg.idcode
        and cf.actype = cft.actype
        and reg.idcode like PV_IDCODE;

 EXCEPTION
   WHEN OTHERS
   THEN
        RETURN;
END;
 
/
