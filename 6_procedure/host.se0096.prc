SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "SE0096"(PV_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR,
                                     OPT          IN VARCHAR2,
                                     pv_BRID      IN VARCHAR2,
                                     TLGOUPS      IN VARCHAR2,
                                     TLSCOPE      IN VARCHAR2,
                                     F_DATE       IN VARCHAR2,
                                     T_DATE       IN VARCHAR2,
                                     PV_AFTYPE    IN VARCHAR2,
                                     PV_SECTYPE   IN VARCHAR2,
                                     PV_ISSUE IN VARCHAR2) IS
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
  V_PV_ISSUE VARCHAR2(40);
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

   IF (PV_ISSUE <> 'ALL') THEN
    V_PV_ISSUE := PV_ISSUE;
  ELSE
    V_PV_ISSUE := '%%';
  END IF;
  -- GET REPORT'S DATA

  OPEN PV_REFCURSOR FOR
    select cf.idcode, --- so dksh
           cf.fullname, -- ten nha dau tu
           cf.custodycd, -- ngay cap
           aft.rfacctno, -- tai khoan giao dich
           se.sl amt, -- tong sl chung chi quy
           se.amt * nvl(sb.mratio, 0) nav,
           F_DATE F_DATE,
           T_DATE T_DATE,
           sb.fullname tenccq,
           sb.symbol,
           af.acctno
      FROM afmast af,
           (SELECT *
              FROM CFMAST
             WHERE FNC_VALIDATE_SCOPE(BRID,
                                      CAREBY,
                                      TLSCOPE,
                                      pv_BRID,
                                      TLGOUPS) = 0) cf,
           AFEXTACCT aft,
           (select distinct sb.issuerid,
                            sb.sectype,
                            sb.codeid,
                            sb.symbol,
                            sb.mratio,
                            iss.fullname
              from sbsecurities sb, issuers iss
             where sb.sectype = '007'
               and sb.issuerid = iss.issuerid) sb,
           (select se.acctno, sum(se.sl) sl, sum(se.amt) amt
              from (

                    select se.acctno,
                            max(se.trade - nvl(main.amt, 0)) sl,
                            max(se.trade - nvl(main.amt, 0)) *
                            max(case
                                  when se.sbdate >= fromdate and se.sbdate <= todate then
                                   (nav)
                                  else
                                   0
                                end) AMT,
                            se.sbdate
                      FROM (SELECT sbdate, se.acctno, se.trade+se.SECURED trade
                               FROM (SELECT DISTINCT sbdate
                                       FROM sbcldr
                                      WHERE sbdate >=
                                            to_date(f_date, 'dd/MM/rrrr')
                                        AND sbdate <=
                                            to_date(t_date, 'dd/MM/rrrr')
                                        and cldrtype = '000') sbcldr,
                                    semast se,sbsecurities sb
                              where se.codeid = sb.codeid and sb.sectype = '007' and sb.symbol LIKE V_PV_SECTYPE) se,
                            (SELECT cldr.sbdate,
                                    tran.acctno,
                                    sum(CASE
                                          WHEN tran.txtype = 'D' THEN
                                           -tran.namt
                                          ELSE
                                           tran.namt
                                        END) amt
                               FROM vw_setran_gen tran,sbsecurities sb,
                                    (SELECT DISTINCT sbdate
                                       FROM sbcldr
                                      WHERE sbdate <=
                                            to_date(t_date, 'dd/MM/rrrr')
                                        AND sbdate >=
                                            to_date(f_date, 'dd/MM/rrrr')
                                        and cldrtype = '000') cldr
                              WHERE tran.field IN ('TRADE','SECURED')
                                AND tran.txtype IN ('D', 'C')
                                AND tran.namt <> 0
                                and tran.symbol LIKE PV_SECTYPE
                                and tran.symbol = sb.symbol
                                and sb.sectype = '007'
                                AND tran.busdate > cldr.sbdate
                              GROUP BY cldr.sbdate, tran.acctno

                             ) main,
                            (select nav.* from  securities_nav  nav,sbsecurities sb where  nav.codeid = SB.CODEID  and sb.sectype = '007')  senav
                     WHERE se.sbdate = main.sbdate(+)
                       AND se.acctno = main.acctno(+)
                       and substr(se.acctno, 11) = senav.codeid(+)
                     group by se.acctno, se.sbdate) se
             group by acctno) se
     where af.custid = cf.custid
       and aft.afacctno = af.acctno
       and aft.issuerid = sb.issuerid
       and sb.symbol like V_PV_SECTYPE
       and aft.ordertype like V_PV_AFTYPE
       and sb.issuerid like V_PV_ISSUE
       and se.sl >0
       and  af.acctno||sb.codeid = se.acctno;
EXCEPTION
  WHEN OTHERS THEN
    RETURN;
END;

 
 
 
 
/
