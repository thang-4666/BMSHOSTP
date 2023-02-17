SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE MR0070(
                               PV_REFCURSOR             IN OUT   PKG_REPORT.REF_CURSOR,
                               OPT                      IN       VARCHAR2,
                               PV_BRID                  IN       VARCHAR2,
                               TLGOUPS                  IN       VARCHAR2,
                               TLSCOPE                  IN       VARCHAR2,
                               F_DATE                   IN       VARCHAR2,
                               T_DATE                   IN       VARCHAR2
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

    --Tinh tong SL CK margin, gia tri CK margin
    SELECT sum(lg.trade + lg.receiving + lg.buyqtty) sumqtty, sum(lg.seass)
        INTO v_sumqtty, v_sumamt
     FROM tbl_mr3007_log lg, secbasket sec, afmast af, aftype aft, mrtype mrt
    WHERE txdate >= to_date(F_DATE, 'DD/MM/RRRR')
        AND txdate <= to_date(T_DATE, 'DD/MM/RRRR')
        AND upper(sec.basketid) = 'MARGIN'
        AND(sec.mrratiorate > 0 OR sec.mrratioloan > 0)
        AND lg.symbol = sec.symbol
        AND lg.afacctno = af.acctno
        AND af.actype = aft.actype
        AND aft.mrtype = mrt.actype
        AND mrt.mrtype = 'T';

    OPEN PV_REFCURSOR FOR
        SELECT * FROM (
            SELECT qtty, symbol, seass, rate FROM (
                SELECT sum(lg.trade + lg.receiving + lg.buyqtty) qtty, lg.symbol, sum(lg.seass) seass,
                        round(sum(lg.seass)/v_sumamt, 4) rate
                    FROM tbl_mr3007_log lg, secbasket sec, afmast af, aftype aft, mrtype mrt
                    WHERE txdate >= to_date(F_DATE, 'DD/MM/RRRR')
                        AND txdate <= to_date(T_DATE, 'DD/MM/RRRR')
                        AND upper(sec.basketid) = 'MARGIN'
                        AND(sec.mrratiorate > 0 OR sec.mrratioloan > 0)
                        AND lg.symbol = sec.symbol
                        AND lg.afacctno = af.acctno
                        AND af.actype = aft.actype
                        AND aft.mrtype = mrt.actype
                        AND mrt.mrtype = 'T'
                    GROUP BY lg.symbol) 
                ORDER BY seass DESC)
            where ROWNUM <= 10 ;
EXCEPTION
  WHEN OTHERS
   THEN
      Return;
End;
 
 
 
 
/
