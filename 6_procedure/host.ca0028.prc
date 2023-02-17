SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "CA0028" (
PV_REFCURSOR in out PKG_REPORT.REF_CURSOR,
OPT             in varchar2,
pv_BRID            in varchar2,
TLGOUPS        IN       VARCHAR2,
TLSCOPE        IN       VARCHAR2,
F_DATE          in varchar2,
T_DATE          in varchar2,
P_CAMSTID       in varchar2,
P_CUSTODYCD     in varchar2,
P_ACCOUNTTYPE   in varchar2,
P_BRID          in varchar2,
P_CATYPE        in varchar2
) is


  --
  -- PURPOSE: BRIEFLY EXPLAIN THE FUNCTIONALITY OF THE PROCEDURE
  -- BAO CAO TAI KHOAN TIEN TONG HOP CUA NGUOI DAU TU
  -- MODIFICATION HISTORY
  -- PERSON      DATE    COMMENTS
  -- NAMNT   20-DEC-06  CREATED
  -- ---------   ------  -------------------------------------------

  CUR           PKG_REPORT.REF_CURSOR;
  V_STROPTION   varchar2(5); -- A: ALL; B: BRANCH; S: SUB-BRANCH
  V_STRBRID     varchar2(4);

  l_F_date      date;
  l_T_date      date;

  L_CAMASTID    VARCHAR2(20);
  L_CUSTODYCD   VARCHAR2(20);
  L_ACCOUNTTYPE VARCHAR2(10);
  L_CUSTTYPE    VARCHAR2(10);
  L_BRID        VARCHAR2(10);

  L_CATYPE      VARCHAR2(20);

begin

  V_STROPTION := OPT;

  if (V_STROPTION <> 'A') and (pv_BRID <> 'ALL') then
    V_STRBRID := pv_BRID;
  else
    V_STRBRID := '%%';
  end if;

  l_F_DATE := to_date(F_DATE,'dd/mm/rrrr');
  l_T_date := to_date(T_DATE,'dd/mm/rrrr');

  IF(P_CAMSTID IS NULL OR UPPER(P_CAMSTID) = 'ALL')THEN
        L_CAMASTID := '%';
  ELSE
        L_CAMASTID := P_CAMSTID;
  END IF;

  IF(P_CUSTODYCD IS NULL OR UPPER(P_CUSTODYCD) = 'ALL')THEN
        L_CUSTODYCD := '%';
  ELSE
        L_CUSTODYCD := P_CUSTODYCD;
  END IF;

  IF(P_ACCOUNTTYPE IS NULL OR UPPER(P_ACCOUNTTYPE) = 'ALL')THEN
        L_ACCOUNTTYPE := '%';
        L_CUSTTYPE    := '%';
  ELSE
        L_ACCOUNTTYPE := SUBSTR(P_ACCOUNTTYPE,1,1);
        L_CUSTTYPE := SUBSTR(P_ACCOUNTTYPE,2,1);
  END IF;

  IF(P_BRID IS NULL OR UPPER(P_BRID) = 'ALL')THEN
        L_BRID := '%';
  ELSE
        L_BRID := P_BRID;
  END IF;

  IF(P_CATYPE IS NULL OR UPPER(P_CATYPE) = 'ALL')THEN
    L_CATYPE := '%';
  ELSE
    L_CATYPE := P_CATYPE;
  END IF;

  -- GET REPORT'S PARAMETERS

  --Tinh ngay nhan thanh toan bu tru

  open PV_REFCURSOR for
        SELECT af.acctno, cf.custodycd, cf.fullname, cf.MOBILE,
           (case when cf.country = '234' then cf.idcode else cf.tradingcode end) IDCODE,
           cas.balance SLCKSH,
           CASE WHEN CAM.CATYPE = '010' THEN (case when cam.DEVIDENTRATE = '0' and cam.DEVIDENTVALUE > 0 then TO_CHAR(cam.DEVIDENTVALUE)
            else  cam.DEVIDENTRATE || '%' end) ELSE
            (case when cam.DEVIDENTSHARES is null then (case when cam.devidentrate is null then
       (case when cam.rightoffrate is null then NVL(cam.exrate,CAM.INTERESTRATE|| '%') else cam.rightoffrate end)
       else devidentrate end) else cam.DEVIDENTSHARES end) END DEVIDENTRATE,
           A0.cdcontent Catype,
           A1.cdcontent status, cam.camastid,
           (case
             when cf.VAT = 'Y' then
              (cas.AMT - round(cam.pitrate * cas.amt / 100))
             else
              cas.AMT
           end) amt, se.symbol, cam.REPORTDATE, cam.actiondate, af.status status_af,
           (case
             when cf.VAT = 'Y' then
              0 else
              cam.pitrate * cas.amt / 100
           end) thue,CAS.ISEXEC ISEXEC
      from (SELECT * FROM CASCHD UNION SELECT * FROM caschdhist) cas, sbsecurities se, vw_camast_all cam, afmast af, aftype aft,
           (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf, allcode A0, Allcode A1
     where cas.codeid = se.codeid
       and cas.deltd <>'Y'
       and AF.ACTYPE     =  AFT.ACTYPE
       and cam.camastid = cas.camastid
       and cas.afacctno = af.acctno
       and af.custid = cf.custid
       and a0.CDTYPE = 'CA'
       and a0.CDNAME = 'CATYPE'
       and a0.CDVAL = cam.CATYPE
       and A1.CDTYPE = 'CA'
       and A1.CDNAME = 'CASTATUS'
       and A1.CDVAL = cas.STATUS
     --  and cas.STATUS in ('G','J','C')
       AND cas.AMT <> 0
----       and cam.CATYPE = '010'
       and cam.reportdate >= l_F_date
       and cam.reportdate <= l_T_date
       and af.brid like L_BRID
       AND CAM.CATYPE LIKE L_CATYPE
       AND CF.CUSTODYCD LIKE L_CUSTODYCD
       AND CAM.camastid LIKE L_CAMASTID
        AND (CASE WHEN SUBSTR(CF.CUSTODYCD,4,1) = 'P' THEN 'C' ELSE SUBSTR(CF.CUSTODYCD,4,1) END) LIKE  L_CUSTTYPE
        AND CF.CUSTTYPE LIKE L_ACCOUNTTYPE
     order by af.acctno;
  /*plog.setEndSection(pkgctx, 'ca0002');*/

exception
  when others then
    /*plog.error(pkgctx, sqlerrm);
    plog.setEndSection(pkgctx, 'ca0002');*/
    return;
end; -- PROCEDURE
 
 
 
 
/
