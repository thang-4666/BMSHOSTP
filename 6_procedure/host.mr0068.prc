SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE MR0068 (
                               PV_REFCURSOR             IN OUT   PKG_REPORT.REF_CURSOR,
                               OPT                      IN       VARCHAR2,
                               PV_BRID                  IN       VARCHAR2,
                               TLGOUPS                  IN       VARCHAR2,
                               TLSCOPE                  IN       VARCHAR2,
                               I_DATE                   IN       VARCHAR2,
                               PV_SYMBOL                IN       varchar2
  )
IS
    CUR            PKG_REPORT.REF_CURSOR;
    V_STROPTION    VARCHAR2 (5);            -- A: ALL; B: BRANCH; S: SUB-BRANCH
    V_STRBRID      VARCHAR2 (4);                   -- USED WHEN V_NUMOPTION > 0
    v_symbol       varchar2(20);
    v_sumqtty       NUMBER;
    v_sumamt        NUMBER;
    v_dueamt        NUMBER;
    v_vcsh          NUMBER;
    v_nextdate      DATE;
    v_indate        DATE;
BEGIN
    V_STROPTION := OPT;

    IF V_STROPTION = 'A' then
        V_STRBRID := '%';
    ELSIF V_STROPTION = 'B' then
        V_STRBRID := substr(PV_BRID,1,2) || '__' ;
    ELSE
        V_STRBRID:=PV_BRID;
    END IF;

    IF PV_SYMBOL = 'ALL' THEN
        v_symbol := '%%';
    ELSE
        v_symbol := PV_SYMBOL;
    END IF;
    V_INDATE:=TO_DATE(I_DATE,'DD/MM/RRRR');
    SELECT getduedate (V_INDATE,'B','001',1  ) INTO v_nextdate  FROM dual ;

    --Tinh tong SL CK margin, gia tri CK margin
    SELECT sum(lg.trade + lg.receiving + lg.buyqtty) sumqtty, sum((lg.trade + lg.receiving + lg.buyqtty) *lg.basicprice)
        INTO v_sumqtty, v_sumamt
     FROM tbl_mr3007_log lg, secbasket sec, afmast af, aftype aft, mrtype mrt
    WHERE txdate = to_date(I_DATE, 'DD/MM/RRRR')
        AND upper(sec.basketid) = 'MARGIN'
        AND(sec.mrratiorate > 0 OR sec.mrratioloan > 0)
        AND lg.symbol = sec.symbol
        AND lg.afacctno = af.acctno
        AND af.actype = aft.actype
        AND aft.mrtype = mrt.actype
        AND mrt.mrtype = 'T';

    --Tinh du no margin
    SELECT sum(lg.phai_tra)
        INTO v_dueamt
    FROM tbl_mr0060 lg, afmast af, aftype aft, mrtype mrt
    WHERE lg.trfacctno = af.acctno
        AND af.actype = aft.actype
        AND aft.mrtype = mrt.actype
        AND mrt.mrtype = 'T'
        AND ngay_in = v_nextdate;

    --Lay 10% von chu so huu
    SELECT TO_NUMBER(varvalue)
        INTO v_vcsh
    FROM sysvar
    WHERE varname = 'MAXDEBTSE';

    --Neu xuat BC o ngay hien tai -> khong ra du lieu
    IF to_date(I_DATE, 'DD/MM/RRRR') = getcurrdate THEN
        OPEN PV_REFCURSOR for
        SELECT '' qtty, '' symbol, '' pricecl, '' amt, '' sumqtty, ''sumamt,
            '' dueamt, '' vcsh, '' average, '' rate,
            '' duedetail FROM dual WHERE 1=0;
    ELSE

    OPEN PV_REFCURSOR FOR
        SELECT sum(lg.trade + lg.receiving + lg.buyqtty) qtty, lg.symbol, max(lg.basicprice) pricecl, (sum(lg.trade + lg.receiving + lg.buyqtty) * max(lg.basicprice)) amt,
            v_sumqtty sumqtty, v_sumamt sumamt,
            v_dueamt dueamt, v_vcsh vcsh, round(v_sumamt/v_sumqtty, 2) average, round(sum(lg.trade + lg.receiving + lg.buyqtty) * max(lg.basicprice)/v_sumamt, 10) rate,
            round(sum(lg.trade + lg.receiving + lg.buyqtty) * max(lg.basicprice)/v_sumamt * v_dueamt, 10) duedetail
        FROM tbl_mr3007_log lg, secbasket sec, afmast af, aftype aft, mrtype mrt
        WHERE txdate = to_date(I_DATE, 'DD/MM/RRRR')
            --AND upper(sec.basketid) = 'MARGIN'
            AND(sec.mrratiorate > 0 OR sec.mrratioloan > 0)
            AND lg.symbol = sec.symbol
            AND lg.afacctno = af.acctno
            AND af.actype = aft.actype
            AND aft.mrtype = mrt.actype
            AND mrt.mrtype = 'T'
            AND lg.symbol like v_symbol
        GROUP BY lg.symbol
        ORDER BY lg.symbol;

    END IF;
EXCEPTION
  WHEN OTHERS
   THEN
      Return;
End;
 
/
