SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE mr0069(
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
    v_paid          NUMBER;
    v_laidukien     NUMBER;
    v_davay         NUMBER;
    v_intamt        NUMBER;
    V_NTDATE        DATE ;
BEGIN
    V_STROPTION := OPT;
    V_NTDATE := getduedate (to_date(T_DATE, 'DD/MM/RRRR'),'B','000',1);

    IF V_STROPTION = 'A' then
        V_STRBRID := '%';
    ELSIF V_STROPTION = 'B' then
        V_STRBRID := substr(PV_BRID,1,2) || '__' ;
    ELSE
        V_STRBRID:=PV_BRID;
    END IF;

    --Tinh tong du no
    begin
        SELECT sum(nvl(phai_tra, 0))
            INTO v_paid
         FROM tbl_mr0060
         WHERE ngay_in =  V_NTDATE;
    exception when no_data_found then
        v_paid := 0;
    end;

    --Tinh lai du kien
    begin
        SELECT sum(nvl(lai_dukien, 0))
            INTO v_laidukien
        FROM tbl_mr0060 WHERE ngay_in =  V_NTDATE;
    EXCEPTION when no_data_found then
        v_laidukien := 0;
    end;

    --Tinh tong so tien vay trong ky
    begin
        SELECT sum(nvl(gen.namt, 0))
            INTO v_davay
        FROM
            ( SELECT txdate, namt FROM vw_citran_gen WHERE tltxcd = '5566' AND field = 'ODAMT') gen
        WHERE gen.txdate >= to_date(F_DATE, 'DD/MM/RRRR')
        AND gen.txdate <= to_date(T_DATE, 'DD/MM/RRRR');
    exception when no_data_found then
        v_davay := 0;
    end;

    --Tinh goc, lai da tra
    begin
        SELECT sum(CASE WHEN upper(trdesc) like '%LÃI%' THEN nvl(namt, 0) ELSE 0 end), SUM(CASE WHEN upper(trdesc) like '%GỐC%' THEN nvl(namt, 0) ELSE 0 end)
            INTO v_intamt, v_dueamt
        FROM
            (
            SELECT txdate, namt, trdesc FROM vw_citran_gen WHERE tltxcd IN ('5567', '5540') AND field = 'BALANCE') gen
        WHERE gen.txdate >= to_date(F_DATE, 'DD/MM/RRRR')
        AND gen.txdate <= to_date(T_DATE, 'DD/MM/RRRR');
    exception when no_data_found then
        v_intamt := 0;
        v_dueamt := 0;
    end;


    OPEN PV_REFCURSOR FOR
    SELECT (ma.custodycd)trfacctno, ma.fullname, ma.paid, ma.lai_dukien, nvl(gena.vay, 0) vay, nvl(gena.laidatra, 0) laidatra, nvl(gena.gocdatra, 0) gocdatra,
        v_laidukien laidukientong, v_davay davaytong, v_intamt laidatratong, v_dueamt gocdatratong, v_paid dunotong
         FROM
        (SELECT * FROM
         (SELECT * FROM
            (SELECT custodycd, fullname, sum(phai_tra) paid, sum(lai_dukien) lai_dukien
                FROM tbl_mr0060
                where ngay_in = V_NTDATE
                GROUP BY custodycd, fullname)
        ORDER BY paid DESC)
      WHERE ROWNUM <=10)ma,
        (SELECT sum(CASE WHEN tltxcd = '5566' THEN namt ELSE 0 end) vay,
                sum(CASE WHEN tltxcd IN('5540', '5567') AND upper(trdesc) like '%LÃI%' THEN namt ELSE 0 END) laidatra,
                sum(CASE WHEN tltxcd IN('5540', '5567') AND upper(trdesc) like '%GỐC%' THEN namt ELSE 0 END) gocdatra,
                custodycd

           FROM (
        SELECT txdate, namt, field, tltxcd, trdesc, custodycd FROM vw_citran_gen WHERE  field = 'BALANCE') gen
        WHERE gen.tltxcd in ('5566', '5567', '5540')
            AND gen.field = 'BALANCE'
            AND gen.txdate >= to_date(F_DATE, 'DD/MM/RRRR')
            AND gen.txdate <= to_date(T_DATE, 'DD/MM/RRRR')
        GROUP BY custodycd)gena
        WHERE ma.custodycd = gena.custodycd(+)
        order by ma.paid desc;
EXCEPTION
  WHEN OTHERS
   THEN
      Return;
End;
 
 
 
 
/
