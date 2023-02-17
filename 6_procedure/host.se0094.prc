SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "SE0094"(PV_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR,
                                     OPT          IN VARCHAR2,
                                     pv_BRID      IN VARCHAR2,
                                     TLGOUPS      IN VARCHAR2,
                                     TLSCOPE      IN VARCHAR2,
                                     F_DATE       IN VARCHAR2,
                                     T_DATE       IN VARCHAR2,
                                     PV_AFTYPE    IN VARCHAR2,
                                     PV_SECTYPE   IN VARCHAR2) IS
  --
  -- PURPOSE: BAO CAO DANH SACH NGUOI SO HUU CHUNG KHOAN LUU KY
  -- MODIFICATION HISTORY
  -- PERSON      DATE      COMMENTS
  -- QUOCTA   15-12-2011   CREATED
  -- ---------   ------  -------------------------------------------
  V_STROPTION  VARCHAR2(5);
  V_STRBRID    VARCHAR2(40);
  V_INBRID     VARCHAR2(4);
  V_PV_AFTYPE  VARCHAR2(40);
  V_PV_SECTYPE VARCHAR2(40);
BEGIN
  V_STROPTION := upper(OPT);
  V_INBRID    := pv_BRID;

  IF (V_STROPTION = 'A') THEN
    V_STRBRID := '%';
  ELSif (V_STROPTION = 'B') then
    select brgrp.mapid
      into V_STRBRID
      from brgrp
     where brgrp.brid = V_INBRID;
  else
    V_STRBRID := V_INBRID;
  END IF;

  IF (PV_AFTYPE <> 'ALL') THEN
    V_PV_AFTYPE := PV_AFTYPE;
  ELSE
    V_PV_AFTYPE := '%%';
  END IF;

  IF (PV_SECTYPE <> 'ALL') THEN
    V_PV_SECTYPE := PV_SECTYPE;
  ELSE
    V_PV_SECTYPE := '%%';
  END IF;
  -- GET REPORT'S DATA

  OPEN PV_REFCURSOR FOR
    SELECT  cf.custid,
       cf.idtype,
       cf.dateofbirth,
       cf.idcode,
       cf.custodycd,
       cf.fullname,
       cf.idplace,
       cf.sex,
       cf.iddate,
       cf.country,
       cf.taxcode,
       cf.mobilesms,
       cf.fax,
       cf.custtype,
       cf.address,
       sb.rfacctno, cfc.address addresscfc,
       cf.email,
       bank.bankacc,bank.bankname,bank.bankacname,bank.citybank,bank.Cityef 
      FROM (SELECT *
              FROM CFMAST
             WHERE FNC_VALIDATE_SCOPE(BRID,
                                      CAREBY,
                                      TLSCOPE,
                                      pv_BRID,
                                      TLGOUPS) = 0) cf,
           afmast af,
           (select distinct aft.afacctno,aft.rfacctno from sbsecurities sb,AFEXTACCT aft
            where sb.sectype = '007' and sb.issuerid = aft.issuerid
            and aft.txdate >= to_date(f_date, 'dd/MM/rrrr')
            and aft.txdate <= to_date(t_date, 'dd/MM/rrrr')
            and aft.ordertype like v_PV_AFTYPE
            and sb.symbol like V_PV_SECTYPE
           ) sb,
          (select distinct cfcustid, bank.bankacc,bank.bankname,bank.bankacname,bank.citybank,bank.Cityef from cfotheracc bank where bank.citybank like '%QMO%') bank,
           cfcontact cfc
     where af.custid = cf.custid
       and af.acctno = sb.afacctno
       and cfc.custid(+) = cf.custid
       and cf.custid = bank.cfcustid(+)
       group by
        cf.custid,
       cf.idtype,
       cf.dateofbirth,
       cf.idcode,
       cf.custodycd,
       cf.fullname,
       cf.idplace,
       cf.sex,
       cf.iddate,
       cf.country,
       cf.taxcode,
       cf.mobilesms,
       cf.fax,
       cf.custtype,cf.address,cf.email
       ,bank.bankacc,bank.bankname,bank.bankacname,bank.citybank, cfc.address,sb.rfacctno,bank.Cityef;

EXCEPTION
  WHEN OTHERS THEN
    RETURN;
END;
 
 
 
 
/
