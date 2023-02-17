SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE cf0084(PV_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR,
                                   OPT          IN VARCHAR2,
                                   PV_BRID      IN VARCHAR2,
                                   TLGOUPS      IN VARCHAR2,
                                   TLSCOPE      IN VARCHAR2,
                                   F_DATE       IN VARCHAR2,
                                   T_DATE       IN VARCHAR2,
                                   PV_CUSTODYCD IN VARCHAR2,
                                   CFTYPE       IN VARCHAR2

                                   ) IS
  --
  -- PURPOSE: BRIEFLY EXPLAIN THE FUNCTIONALITY OF THE PROCEDURE
  --
  -- MODIFICATION HISTORY
  -- PERSON      DATE       COMMENTS
  -- Diennt      28/12/2011 Create
  -- ---------   ------     -------------------------------------------
  V_STROPTION VARCHAR2(5); -- A: ALL; B: BRANCH; S: SUB-BRANCH
  V_STRBRGID  VARCHAR2(10);
  V_branch    varchar2(5);
  V_INBRID    VARCHAR2(4);
  V_STRBRID   VARCHAR2(50);
  V_STRSTATUS VARCHAR2(10);

  V_STRCUSTODYCD VARCHAR2(30);
  V_CFTYPE       VARCHAR2(20);
  v_f_date date;
  v_t_date date;
  -- DECLARE PROGRAM VARIABLES AS SHOWN ABOVE

BEGIN

  IF PV_CUSTODYCD IS NULL OR UPPER(PV_CUSTODYCD) = 'ALL' THEN
    V_STRCUSTODYCD := '%';
  ELSE
    V_STRCUSTODYCD := UPPER(PV_CUSTODYCD);
  END IF;

  IF CFTYPE IS NULL OR UPPER(CFTYPE) = 'ALL' THEN
    V_CFTYPE := '%';
  ELSE
    V_CFTYPE := UPPER(CFTYPE);
  END IF;
  -- lay ngay gan ngay lam viec
   SELECT to_date(MAX(SBDATE), 'dd/MM/rrrr') into v_f_date
   FROM sbcldr
  WHERE CLDRTYPE = '999'
    AND SBDATE <= TO_DATE(F_DATE, 'DD/MM/RRRR')
    and holiday = 'N';

     SELECT to_date(MAX(SBDATE), 'dd/MM/rrrr') into v_T_date
   FROM sbcldr
  WHERE CLDRTYPE = '999'
    AND SBDATE <= TO_DATE(T_DATE, 'DD/MM/RRRR')
    and holiday = 'N';

  --

  -- ngay qua khu
  if V_T_date != to_date(getcurrdate, 'dd/mm/rrrr') then
    open PV_REFCURSOR for
      select t.*, '1' grouptest
        from (
              --- tien
              SELECT (case
                        when cf.sex = '001' then
                         'Ông'
                        when cf.sex = '002' then
                         'Bà'
                        when cf.sex = '000' then
                         ''
                      end) sex,
                      V_F_date txdate,
                      0 orderid,
                      cf.custodycd,
                      cf.fullname,
                      'Số dư tiền' balance,
                      null symbol,
                      NVL(tt.balance,0) ciamt,
                      null seamt,
                      null mramt,
                      t.avladvance -- tien cho ve
                 FROM (SELECT *
                         FROM CFMAST
                        WHERE 0 = 0
                          AND CUSTODYCD LIKE V_STRCUSTODYCD
                          and actype like V_CFTYPE) CF,
                      (select round(NVL(max(cf.rcvamt), 0)) +round(NVL(max(cf.careceiving), 0)) avladvance, cf.custid

                         from CFREVIEWLOG cf
                        where cf.lastdate = v_f_date
                        group by cf.custid) t,
                        (select sum(t.balance) balance,
                              t.custodycd
                         from (select t.afacctno,
                                      t.custodycd,
                                      max(t.balance) balance
                                 from TBL_MR3007_LOG t
                                where t.txdate = v_f_date
                                group by t.afacctno, t.custodycd) t
                        group by t.custodycd) tt
               WHERE cf.custid = t.custid(+)
              and  cf.CUSTODYCD = tt.custodycd(+)
              -- and t.txdate = to_date(F_DATE, 'dd/mm/rrrr')

              union all
              --- du no MR
              SELECT (case
                        when cf.sex = '001' then
                         'Ông'
                        when cf.sex = '002' then
                         'Bà'
                        when cf.sex = '000' then
                         ''
                      end) sex,
                      v_f_date txdate,
                      1 orderid,
                      cf.custodycd,
                      cf.fullname,
                      'Dư nợ gốc' balance,
                      null symbol,
                      t1.mrnml ciamt,
                      null seamt,
                      null mramt,
                      0 avladvance -- tien cho ve
                FROM (SELECT *
                         FROM CFMAST
                        WHERE FNC_VALIDATE_SCOPE(BRID,
                                                 CAREBY,
                                                 TLSCOPE,
                                                 pv_BRID,
                                                 TLGOUPS) = 0
                          AND CUSTODYCD LIKE V_STRCUSTODYCD
                          and actype like V_CFTYPE) CF,
                      (select round(NVL(max(cf.mrnml), 0)) mrnml, cf.custid

                         from CFREVIEWLOG cf
                        where cf.lastdate = v_f_date
                        group by cf.custid) t1
               WHERE cf.custid = t1.custid(+)

              union all
              SELECT (case
                        when cf.sex = '001' then
                         'Ông'
                        when cf.sex = '002' then
                         'Bà'
                        when cf.sex = '000' then
                         ''
                      end) sex,
                      v_f_date txdate,
                      2 orderid,
                      cf.custodycd,
                      cf.fullname,
                      'Lãi vay chưa thanh toán' balance,
                      null symbol,
                      t1.mrfeeamt ciamt,
                      null seamt,
                      null mramt,
                      0 avladvance -- tien cho ve
                FROM (SELECT *
                         FROM CFMAST
                        WHERE FNC_VALIDATE_SCOPE(BRID,
                                                 CAREBY,
                                                 TLSCOPE,
                                                 pv_BRID,
                                                 TLGOUPS) = 0
                          AND CUSTODYCD LIKE V_STRCUSTODYCD
                          and actype like V_CFTYPE) CF,
                      (select round(NVL(max(cf.mrfeeamt), 0)) mrfeeamt,
                              cf.custid

                         from CFREVIEWLOG cf
                        where cf.lastdate = v_f_date
                        group by cf.custid) t1
               where cf.custid = t1.custid(+)
              union all
              --- so du chung khoan.
              SELECT (case
                        when cf.sex = '001' then
                         'Ông'
                        when cf.sex = '002' then
                         'Bà'
                        when cf.sex = '000' then
                         ''
                      end) sex,
                      v_f_date txdate,
                      3 orderid,
                      cf.custodycd,
                      cf.fullname,
                      null balance,
                      t3.symbol,
                      null ciamt,
                      SUM(t3.trade) seamt,
                      SUM(t3.receiving) mramt,
                      null avladvance -- tien cho ve
                FROM (SELECT *
                         FROM CFMAST
                        WHERE FNC_VALIDATE_SCOPE(BRID,
                                                 CAREBY,
                                                 TLSCOPE,
                                                 pv_BRID,
                                                 TLGOUPS) = 0
                          AND CUSTODYCD LIKE V_STRCUSTODYCD
                          and actype like V_CFTYPE) cf,
                      (select t1.symbol,
                              t1.custodycd,
                              sum(t1.trade) trade,
                              sum(t1.careceiving + t1.odreceiving) receiving

                         from tbl_mr3007_log t1, sbsecurities s
                        where t1.txdate = v_f_date
                          and t1.trade > 0
                          and t1.symbol = s.symbol
                          and s.sectype != '004'
                        group by t1.symbol, t1.custodycd) t3

               where cf.custodycd = t3.custodycd(+)
                 and nvl(t3.trade, 0) > 0
               group by cf.sex, cf.custodycd, cf.fullname, t3.symbol
              ----- T_DATE
              union all

              --- tien
              SELECT (case
                        when cf.sex = '001' then
                         'Ông'
                        when cf.sex = '002' then
                         'Bà'
                        when cf.sex = '000' then
                         ''
                      end) sex,
                      v_t_date txdate,
                      4 orderid,
                      cf.custodycd,
                      cf.fullname,
                      'Số dư tiền' balance,
                      null symbol,
                      tt.balance ciamt,
                      null seamt,
                      null mramt,
                      t.avladvance avladvance -- tien cho ve
                FROM (SELECT *
                         FROM CFMAST
                        WHERE 0 = 0
                          AND CUSTODYCD LIKE V_STRCUSTODYCD
                          and actype like V_CFTYPE) CF,
                      (select round(NVL(max(cf.rcvamt), 0)) +round(NVL(max(cf.careceiving), 0)) avladvance, cf.custid

                         from CFREVIEWLOG cf
                        where cf.lastdate = v_t_date
                        group by cf.custid) t,
                        (select sum(t.balance) balance,
                              t.custodycd
                         from (select t.afacctno,
                                      t.custodycd,
                                      max(t.balance) balance
                                 from TBL_MR3007_LOG t
                                where t.txdate = v_t_date
                                group by t.afacctno, t.custodycd) t
                        group by t.custodycd) tt
               WHERE cf.custid = t.custid(+)
              and  cf.CUSTODYCD = tt.custodycd(+)

              union all
              --- du no MR
              SELECT (case
                        when cf.sex = '001' then
                         'Ông'
                        when cf.sex = '002' then
                         'Bà'
                        when cf.sex = '000' then
                         ''
                      end) sex,
                      v_t_date txdate,
                      5 orderid,
                      cf.custodycd,
                      cf.fullname,
                      'Dư nợ gốc' balance,
                      null symbol,
                      t1.mrnml ciamt,
                      null seamt,
                      null mramt,
                      0 avladvance -- tien cho ve
                FROM (SELECT *
                         FROM CFMAST
                        WHERE FNC_VALIDATE_SCOPE(BRID,
                                                 CAREBY,
                                                 TLSCOPE,
                                                 pv_BRID,
                                                 TLGOUPS) = 0
                          AND CUSTODYCD LIKE V_STRCUSTODYCD
                          and actype like V_CFTYPE) CF,
                      (select round(NVL(max(cf.mrnml), 0)) mrnml, cf.custid

                         from CFREVIEWLOG cf
                        where cf.lastdate = v_t_date
                        group by cf.custid) t1
               WHERE cf.custid = t1.custid(+)

              union all
              SELECT (case
                        when cf.sex = '001' then
                         'Ông'
                        when cf.sex = '002' then
                         'Bà'
                        when cf.sex = '000' then
                         ''
                      end) sex,
                      v_t_date txdate,
                      6 orderid,
                      cf.custodycd,
                      cf.fullname,
                      'Lãi vay chưa thanh toán' balance,
                      null symbol,
                      t2.mrfeeamt ciamt,
                      null seamt,
                      null mramt,
                      0 avladvance -- tien cho ve
                FROM (SELECT *
                         FROM CFMAST
                        WHERE FNC_VALIDATE_SCOPE(BRID,
                                                 CAREBY,
                                                 TLSCOPE,
                                                 pv_BRID,
                                                 TLGOUPS) = 0
                          AND CUSTODYCD LIKE V_STRCUSTODYCD
                          and actype like V_CFTYPE) CF,
                      (select round(NVL(max(cf.mrfeeamt), 0)) mrfeeamt,
                              cf.custid

                         from CFREVIEWLOG cf
                        where cf.lastdate = v_t_date
                        group by cf.custid) t2
               WHERE cf.custid = t2.custid(+)

              union all
              --- so du chung khoan.
              SELECT (case
                        when cf.sex = '001' then
                         'Ông'
                        when cf.sex = '002' then
                         'Bà'
                        when cf.sex = '000' then
                         ''
                      end) sex,
                      v_t_date txdate,
                      7 orderid,
                      cf.custodycd,
                      cf.fullname,
                      null balane,
                      t3.symbol,
                      null ciamt,
                      SUM(t3.trade) seamt,
                      SUM(t3.receiving) mramt,
                      null avladvance -- tien cho ve
                FROM (SELECT *
                         FROM CFMAST
                        WHERE FNC_VALIDATE_SCOPE(BRID,
                                                 CAREBY,
                                                 TLSCOPE,
                                                 pv_BRID,
                                                 TLGOUPS) = 0
                          AND CUSTODYCD LIKE V_STRCUSTODYCD
                          and actype like V_CFTYPE) cf,
                      (select t1.symbol,
                              t1.custodycd,
                              sum(t1.trade) trade,
                              sum(t1.careceiving + t1.odreceiving) receiving

                         from tbl_mr3007_log t1, sbsecurities s
                        where t1.txdate = v_t_date
                          and t1.trade > 0
                          and t1.symbol = s.symbol
                          and s.sectype != '004'
                        group by t1.symbol, t1.custodycd) t3

               where cf.custodycd = t3.custodycd(+)
                 and nvl(t3.trade, 0) > 0
               Group by cf.sex, cf.custodycd, cf.fullname, t3.symbol) t
       order by t.orderid, t.symbol;

  end if;
  -- den ngay ngay hien tai
  if v_t_date = to_date(getcurrdate, 'dd/mm/rrrr') then
    open PV_REFCURSOR for
      select t.*, '1' grouptest
        from (
              --- tien
              SELECT (case
                        when cf.sex = '001' then
                         'Ông'
                        when cf.sex = '002' then
                         'Bà'
                        when cf.sex = '000' then
                         ''
                      end) sex,
                      v_f_date txdate,
                      0 orderid,
                      cf.custodycd,
                      cf.fullname,
                      'Số dư tiền' balance,
                      null symbol,
                      nvl(tt.balance,0) ciamt,
                      null seamt,
                      null mramt,
                      t.avladvance -- tien cho ve
                FROM (SELECT *
                         FROM CFMAST
                        WHERE 0 = 0
                          AND CUSTODYCD LIKE V_STRCUSTODYCD
                          and actype like V_CFTYPE) CF,
                      (select round(NVL(max(cf.rcvamt), 0)) +round(NVL(max(cf.careceiving), 0)) avladvance, cf.custid

                         from CFREVIEWLOG cf
                        where cf.lastdate = v_t_date
                        group by cf.custid) t,
                        (select sum(t.balance) balance,
                              t.custodycd
                         from (select t.afacctno,
                                      t.custodycd,
                                      max(t.balance) balance
                                 from TBL_MR3007_LOG t
                                where t.txdate = v_t_date
                                group by t.afacctno, t.custodycd) t
                        group by t.custodycd) tt
               WHERE cf.custid = t.custid(+)
              and  cf.CUSTODYCD = tt.custodycd(+)

              union all
              --- du no MR
              SELECT (case
                        when cf.sex = '001' then
                         'Ông'
                        when cf.sex = '002' then
                         'Bà'
                        when cf.sex = '000' then
                         ''
                      end) sex,
                      v_f_date  txdate,
                      1 orderid,
                      cf.custodycd,
                      cf.fullname,
                      'Dư nợ gốc' balance,
                      null symbol,
                      t1.mrnml ciamt,
                      null seamt,
                      null mramt,
                      0 avladvance -- tien cho ve
                FROM (SELECT *
                         FROM CFMAST
                        WHERE FNC_VALIDATE_SCOPE(BRID,
                                                 CAREBY,
                                                 TLSCOPE,
                                                 pv_BRID,
                                                 TLGOUPS) = 0
                          AND CUSTODYCD LIKE V_STRCUSTODYCD
                          and actype like V_CFTYPE) CF,
                      (select round(NVL(max(cf.mrnml), 0)) mrnml, cf.custid

                         from CFREVIEWLOG cf
                        where cf.lastdate = v_f_date
                        group by cf.custid) t1
               WHERE cf.custid = t1.custid(+)

              union all
              SELECT (case
                        when cf.sex = '001' then
                         'Ông'
                        when cf.sex = '002' then
                         'Bà'
                        when cf.sex = '000' then
                         ''
                      end) sex,
                      v_f_date txdate,
                      2 orderid,
                      cf.custodycd,
                      cf.fullname,
                      'Lãi vay chưa thanh toán' balance,
                      null symbol,
                      t2.mrfeeamt ciamt,
                      null seamt,
                      null mramt,
                      0 avladvance -- tien cho ve
                FROM (SELECT *
                         FROM CFMAST
                        WHERE FNC_VALIDATE_SCOPE(BRID,
                                                 CAREBY,
                                                 TLSCOPE,
                                                 pv_BRID,
                                                 TLGOUPS) = 0
                          AND CUSTODYCD LIKE V_STRCUSTODYCD
                          and actype like V_CFTYPE) CF,
                      (select round(NVL(max(cf.mrfeeamt), 0)) mrfeeamt,
                              cf.custid

                         from CFREVIEWLOG cf
                        where cf.lastdate = v_f_date
                        group by cf.custid) t2
               WHERE cf.custid = t2.custid(+)

              union all
              --- so du chung khoan.
              SELECT (case
                        when cf.sex = '001' then
                         'Ông'
                        when cf.sex = '002' then
                         'Bà'
                        when cf.sex = '000' then
                         ''
                      end) sex,
                      v_f_date txdate,
                      3 orderid,
                      cf.custodycd,
                      cf.fullname,
                      null balance,
                      t3.symbol,
                      null ciamt,
                      SUM(t3.trade) seamt,
                      SUM(t3.receiving) mramt,
                      null avladvance -- tien cho ve
                FROM (SELECT *
                         FROM CFMAST
                        WHERE FNC_VALIDATE_SCOPE(BRID,
                                                 CAREBY,
                                                 TLSCOPE,
                                                 pv_BRID,
                                                 TLGOUPS) = 0
                          AND CUSTODYCD LIKE V_STRCUSTODYCD
                          and actype like V_CFTYPE) cf,
                      (select t1.symbol,
                              t1.custodycd,
                              sum(t1.trade) trade,
                              sum(t1.careceiving + t1.odreceiving) receiving

                         from tbl_mr3007_log t1, sbsecurities s
                        where t1.txdate = v_f_date
                          and t1.trade > 0
                          and t1.symbol = s.symbol
                          and s.sectype != '004'
                        group by t1.symbol, t1.custodycd) t3

               where cf.custodycd = t3.custodycd(+)
                 and nvl(t3.trade, 0) > 0
               group by cf.sex, cf.custodycd, cf.fullname, t3.symbol
              ----- T_DATE
              union all

              --- tien
              SELECT (case
                        when cf.sex = '001' then
                         'Ông'
                        when cf.sex = '002' then
                         'Bà'
                        when cf.sex = '000' then
                         ''
                      end) sex,
                      v_t_date txdate,
                      4 orderid,
                      cf.custodycd,
                      cf.fullname,
                      'Số dư tiền' balance,
                      null symbol,
                      SUM(t.balance) ciamt,
                      null seamt,
                      null mramt,
                      sum(t.receiving) avladvance -- tien cho ve
                FROM (SELECT *
                         FROM CFMAST
                        WHERE FNC_VALIDATE_SCOPE(BRID,
                                                 CAREBY,
                                                 TLSCOPE,
                                                 pv_BRID,
                                                 TLGOUPS) = 0
                          AND CUSTODYCD LIKE V_STRCUSTODYCD
                          and actype like V_CFTYPE) CF,
                      cimast t,
                      afmast af
               WHERE t.afacctno(+) = af.acctno
                 and af.custid = cf.custid
               group by cf.sex, cf.custodycd, cf.fullname
              union all
              --- du no MR
              SELECT (case
                        when cf.sex = '001' then
                         'Ông'
                        when cf.sex = '002' then
                         'Bà'
                        when cf.sex = '000' then
                         ''
                      end) sex,
                      v_t_date txdate,
                      5 orderid,
                      cf.custodycd,
                      cf.fullname,
                      'Dư nợ gốc' balance,
                      null symbol,
                      NVL(ln.mrnml,0) ciamt,
                      null seamt,
                      null mramt,
                      0 avladvance -- tien cho ve
                FROM (SELECT *
                         FROM CFMAST
                        WHERE FNC_VALIDATE_SCOPE(BRID,
                                                 CAREBY,
                                                 TLSCOPE,
                                                 pv_BRID,
                                                 TLGOUPS) = 0
                          AND CUSTODYCD LIKE V_STRCUSTODYCD
                          and actype like V_CFTYPE) CF,
                      (select af.custid, sum(ln.prinnml + ln.prinovd) mrnml
                         from lnmast ln, afmast af
                        where ftype = 'AF'
                          and ln.trfacctno = af.acctno
                          and ln.prinnml + ln.prinovd + ln.intnmlacr +
                              ln.intovdacr + ln.intnmlovd + ln.intdue + ln.fee +
                              ln.feedue + ln.feeovd + ln.feeintnmlacr +
                              ln.feeintovdacr + ln.feeintnmlovd + ln.feeintdue +
                              ln.feefloatamt > 0
                        group by af.custid) ln
               WHERE ln.custid(+) = cf.custid

              union all
              SELECT (case
                        when cf.sex = '001' then
                         'Ông'
                        when cf.sex = '002' then
                         'Bà'
                        when cf.sex = '000' then
                         ''
                      end) sex,
                      v_t_date txdate,
                      6 orderid,
                      cf.custodycd,
                      cf.fullname,
                      'Lãi vay chưa thanh toán' balance,
                      null symbol,
                      NVL(ln.mrfeeamt,0) ciamt,
                      null seamt,
                      null mramt,
                      0 avladvance -- tien cho ve
                FROM (SELECT *
                         FROM CFMAST
                        WHERE FNC_VALIDATE_SCOPE(BRID,
                                                 CAREBY,
                                                 TLSCOPE,
                                                 pv_BRID,
                                                 TLGOUPS) = 0
                          AND CUSTODYCD LIKE V_STRCUSTODYCD
                          and actype like V_CFTYPE) CF,
                      (select af.custid,

                              round(sum(ln.intnmlacr + ln.intovdacr +
                                        ln.intnmlovd + ln.intdue + ln.fee +
                                        ln.feedue + ln.feeovd + ln.feeintnmlacr +
                                        ln.feeintovdacr + ln.feeintnmlovd +
                                        ln.feeintdue + ln.feefloatamt)) mrfeeamt
                         from lnmast ln, afmast af
                        where ftype = 'AF'
                          and ln.trfacctno = af.acctno
                          and ln.prinnml + ln.prinovd + ln.intnmlacr +
                              ln.intovdacr + ln.intnmlovd + ln.intdue + ln.fee +
                              ln.feedue + ln.feeovd + ln.feeintnmlacr +
                              ln.feeintovdacr + ln.feeintnmlovd + ln.feeintdue +
                              ln.feefloatamt > 0
                        group by af.custid) ln
               WHERE cf.custid = ln.custid(+)
              union all
              --- so du chung khoan.
              SELECT (case
                        when cf.sex = '001' then
                         'Ông'
                        when cf.sex = '002' then
                         'Bà'
                        when cf.sex = '000' then
                         ''
                      end) sex,
                      v_t_date txdate,
                      7 orderid,
                      cf.custodycd,
                      cf.fullname,
                      null balane,
                      t3.symbol,
                      null ciamt,
                      SUM(t3.trade) seamt,
                      SUM(t3.receiving) mramt,
                      null avladvance -- tien cho ve
                FROM (SELECT *
                         FROM CFMAST
                        WHERE FNC_VALIDATE_SCOPE(BRID,
                                                 CAREBY,
                                                 TLSCOPE,
                                                 pv_BRID,
                                                 TLGOUPS) = 0
                          AND CUSTODYCD LIKE V_STRCUSTODYCD
                          and actype like V_CFTYPE) cf,
                      (select s.symbol,
                              cf.custodycd,
                              sum(t1.trade) trade,
                              sum(t1.receiving) receiving

                         from semast t1, sbsecurities s, afmast af, cfmast cf
                        where t1.afacctno = af.acctno
                          and af.custid = cf.custid
                          and t1.trade > 0
                          and t1.codeid = s.codeid
                          and s.sectype != '004'

                        group by s.symbol, cf.custodycd) t3

               where cf.custodycd = t3.custodycd(+)
                 and nvl(t3.trade, 0) > 0
               Group by cf.sex, cf.custodycd, cf.fullname, t3.symbol) t
       order by t.orderid, t.symbol;

  end if;

EXCEPTION
  WHEN OTHERS THEN

    RETURN;
End;
 
 
 
 
/
