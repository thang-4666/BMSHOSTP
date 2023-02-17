SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "CA0002" (PV_REFCURSOR in out PKG_REPORT.REF_CURSOR,
                                   OPT          in varchar2,
                                   pv_BRID        in varchar2,
                                   TLGOUPS        IN       VARCHAR2,
                                   TLSCOPE        IN       VARCHAR2,
                                   CACODE       in varchar2,
                                   AFACCTNO     in varchar2) is
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
  V_STRCACODE   varchar2(20);
  V_STRAFACCTNO varchar2(20);

  /*pkgctx plog.log_ctx;
  logrow tlogdebug%rowtype;*/
begin

  /*-- Initialization log
  for i in (select * from tlogdebug)
  loop
    logrow.loglevel  := i.loglevel;
    logrow.log4table := i.log4table;
    logrow.log4alert := i.log4alert;
    logrow.log4trace := i.log4trace;
  end loop;

  pkgctx := plog.init('ca0002',
                      plevel    => nvl(logrow.loglevel, 30),
                      plogtable => (nvl(logrow.log4table, 'N') = 'Y'),
                      palert    => (nvl(logrow.log4alert, 'N') = 'Y'),
                      ptrace    => (nvl(logrow.log4trace, 'N') = 'Y'));

  plog.setBeginSection(pkgctx, 'ca0002');*/

  V_STROPTION := OPT;

  if (V_STROPTION <> 'A') and (pv_BRID <> 'ALL') then
    V_STRBRID := pv_BRID;
  else
    V_STRBRID := '%%';
  end if;

  if (CACODE <> 'ALL') then
    V_STRCACODE := CACODE;
  else
    V_STRCACODE := '%%';
  end if;
  if (AFACCTNO <> 'ALL') then
    V_STRAFACCTNO := AFACCTNO;
  else
    V_STRAFACCTNO := '%%';
  end if;

  /*plog.error(pkgctx,
             'CACODE:' || V_STRCACODE || '::AFACCTNO' || V_STRAFACCTNO);*/
  -- GET REPORT'S PARAMETERS

  --Tinh ngay nhan thanh toan bu tru

  open PV_REFCURSOR for
    select af.acctno, cf.custodycd, cf.fullname, cf.MOBILE,
           (case when cf.country = '234' then cf.idcode else cf.tradingcode end) IDCODE,
           cas.balance SLCKSH,
           (case when cam.DEVIDENTRATE = '0' and cam.DEVIDENTVALUE > 0 then TO_CHAR(cam.DEVIDENTVALUE)
            else  cam.DEVIDENTRATE || '%' end) DEVIDENTRATE,
           A0.cdcontent Catype,
           A1.cdcontent status, cam.camastid,
           (case
             when cf.VAT = 'Y' then
              (cas.AMT - round(cam.pitrate * cas.amt / 100))
             else
              cas.AMT
           end) amt, se.symbol, cam.REPORTDATE, af.status status_af,
           (case
             when cf.VAT = 'Y' then
              0
             else
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
       and cam.CATYPE = '010'
       and cam.camastid like V_STRCACODE
       and cas.afacctno like V_STRAFACCTNO
     order by af.acctno;
  /*plog.setEndSection(pkgctx, 'ca0002');*/

exception
  when others then
    /*plog.error(pkgctx, sqlerrm);
    plog.setEndSection(pkgctx, 'ca0002');*/
    return;
end; -- PROCEDURE

 
 
 
 
/
