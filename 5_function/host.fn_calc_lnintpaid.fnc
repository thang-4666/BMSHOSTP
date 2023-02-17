SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_calc_lnintpaid
(
    PV_LNSAUTOID    NUMBER,
    PV_TXDATE       VARCHAR2,
    --PV_TXNUM        VARCHAR2,
    PV_LNSLOGSEQ    NUMBER,
    PV_LOANTYPE     VARCHAR2
) RETURN NUMBER
IS
    ---------------------------------
    -- TINH TIEN LAI PHAI TRA CHO NGAN HANG DOI VOI KHOAN VAY TRA LAI VA PHI KHI
    -- CO TRA GOC
    ----------------------------------------------------------------------------

    V_LASTDATE      date;
    V_LASTTXNUM     VARCHAR2(10);
    V_LASTLOGSEQ    NUMBER;
    V_PAIDINTNMLACR     NUMBER;
    V_LNSLOGSEQ     NUMBER;
BEGIN
    IF PV_LOANTYPE = 'DF' THEN
        -- LAY NGAY GAN NHAT CO TRA GOC CUA KHOAN VAY
        IF PV_LNSLOGSEQ > 0 THEN
            V_LNSLOGSEQ := PV_LNSLOGSEQ;
        ELSE
            SELECT MAX(LNT.autoid) AUTOID
            INTO V_LNSLOGSEQ
            FROM vw_lntran_all lnt, vw_lnschd_all lns
            WHERE lnt.tltxcd IN ('2646','2648','2636','2665')
                AND lnt.txdate = to_date(PV_TXDATE,'DD/MM/YYYY')
                AND lns.acctno = lnt.acctno
                AND LNS.reftype IN ('P','GP')
                AND lns.autoid = PV_LNSAUTOID
            ;
        END IF;

        SELECT MAX(lnT.AUTOID)
        INTO V_LASTLOGSEQ
        FROM
        (
        SELECT MAX(LNT.autoid) AUTOID,
            sum(CASE WHEN lnt.txcd = '0014' THEN lnt.namt ELSE 0 end) ORGPAIDAMT
        FROM vw_lntran_all lnt, vw_lnschd_all lns
        WHERE lnt.tltxcd IN ('2646','2648','2636','2665')
            AND lnt.txdate < to_date(PV_TXDATE,'DD/MM/YYYY')
            and not EXISTS(select txnum from vw_lntran_all lnt2 where lnt2.autoid = V_LNSLOGSEQ and lnt2.txnum = lnt.txnum)
            AND lns.acctno = lnt.acctno
            AND LNS.reftype IN ('P','GP')
            AND lns.autoid = PV_LNSAUTOID
            AND LNT.autoid < V_LNSLOGSEQ
        GROUP BY lnt.txdate, lnt.txnum, lnt.acctno, lnt.acctref
        ) LNT
        WHERE LNT.ORGPAIDAMT > 0;

        /*SELECT MAX(lnT.txdate), max(lnT.txnum)
        INTO V_LASTDATE, V_LASTTXNUM
        FROM
        (
        SELECT lnt.txdate, lnt.txnum, lnt.acctref lnsautoid, MAX(LNT.autoid) AUTOID,
            sum(CASE WHEN lnt.txcd = '0014' THEN lnt.namt ELSE 0 end) ORGPAIDAMT
        FROM vw_lntran_all lnt
        WHERE lnt.tltxcd IN ('2646','2648','2636','2665')
            AND lnt.txdate <= to_date(PV_TXDATE,'DD/MM/YYYY')
            AND LNT.acctref = PV_LNSAUTOID
            AND LNT.autoid < V_LNSLOGSEQ
        GROUP BY lnt.txdate, lnt.txnum, lnt.acctno, lnt.acctref
        ) LNT
        WHERE LNT.ORGPAIDAMT > 0;

        SELECT MAX(lnt.AUTOID)
        INTO V_LASTLOGSEQ
        FROM vw_lntran_all lnt
        WHERE lnT.txdate = V_LASTDATE AND lnT.txnum = V_LASTTXNUM;*/

        -- TINH TONG SO TIEN LAI DA THANH TOAN
        IF V_LASTLOGSEQ IS NULL THEN
        --IF V_LASTDATE IS NULL OR V_LASTDATE = TO_DATE(PV_TXDATE,'DD/MM/YYYY') THEN
            SELECT sum(LNT.INTPAIDAMT) INTPAIDAMT
            INTO V_PAIDINTNMLACR
            FROM
            (
            SELECT lnt.txdate, lnt.txnum, lnt.acctref lnsautoid, MAX(LNT.autoid) AUTOID,
                sum(CASE WHEN lnt.txcd = '0024' THEN lnt.namt ELSE 0 end) INTPAIDAMT
            FROM vw_lntran_all lnt, vw_lnschd_all lns
            WHERE lnt.tltxcd IN ('2646','2648','2636','2665')
                AND lnt.txdate <= to_date(PV_TXDATE,'DD/MM/YYYY')
                AND lns.acctno = lnt.acctno
                AND LNS.reftype IN ('P','GP')
                AND lns.autoid = PV_LNSAUTOID
                AND LNT.autoid <= V_LNSLOGSEQ
            GROUP BY lnt.txdate, lnt.txnum, lnt.acctno, lnt.acctref
            ) LNT;
        ELSE
            SELECT sum(LNT.INTPAIDAMT) INTPAIDAMT
            INTO V_PAIDINTNMLACR
            FROM
            (
            SELECT lnt.txdate, lnt.txnum, lnt.acctref lnsautoid, MAX(LNT.autoid) AUTOID,
                sum(CASE WHEN lnt.txcd = '0024' THEN lnt.namt ELSE 0 end) INTPAIDAMT
            FROM vw_lntran_all lnt, vw_lnschd_all lns
            WHERE lnt.tltxcd IN ('2646','2648','2636','2665')
                AND lnt.txdate <= to_date(PV_TXDATE,'DD/MM/YYYY')
                AND lns.acctno = lnt.acctno
                AND LNS.reftype IN ('P','GP')
                AND lns.autoid = PV_LNSAUTOID
                AND LNT.autoid <= V_LNSLOGSEQ
                AND LNT.autoid > V_LASTLOGSEQ
            GROUP BY lnt.txdate, lnt.txnum, lnt.acctno, lnt.acctref
            ) LNT;

        END IF;
    ELSIF PV_LOANTYPE = 'MR' THEN
        -- LAY NGAY GAN NHAT CO TRA GOC CUA KHOAN VAY
        IF PV_LNSLOGSEQ > 0 THEN
            V_LNSLOGSEQ := PV_LNSLOGSEQ;
        ELSE
            SELECT MAX(LNT.autoid) AUTOID
            INTO V_LNSLOGSEQ
            FROM vw_lntran_all lnt
            WHERE lnt.tltxcd IN ('5540','5567')
                AND lnt.txdate = to_date(PV_TXDATE,'DD/MM/YYYY')
                AND LNT.acctref = PV_LNSAUTOID
            ;
        END IF;

        SELECT MAX(lnT.AUTOID)
        INTO V_LASTLOGSEQ
        FROM
        (
        SELECT MAX(LNT.autoid) AUTOID,
            sum(CASE WHEN lnt.txcd IN ('0014','0065') THEN lnt.namt ELSE 0 end) ORGPAIDAMT
        FROM vw_lntran_all lnt
        WHERE lnt.tltxcd IN ('5540','5567')
            AND lnt.txdate < to_date(PV_TXDATE,'DD/MM/YYYY')
            and not EXISTS(select txnum from vw_lntran_all lnt2 where lnt2.autoid = V_LNSLOGSEQ and lnt2.txnum = lnt.txnum)
            AND LNT.acctref = PV_LNSAUTOID
            AND LNT.autoid < V_LNSLOGSEQ
        GROUP BY lnt.txdate, lnt.txnum, lnt.acctno, lnt.acctref
        ) LNT
        WHERE LNT.ORGPAIDAMT > 0;

        /*SELECT MAX(lnT.txdate), max(lnT.txnum)
        INTO V_LASTDATE, V_LASTTXNUM
        FROM
        (
        SELECT lnt.txdate, lnt.txnum, lnt.acctref lnsautoid, MAX(LNT.autoid) AUTOID,
            sum(CASE WHEN lnt.txcd IN ('0014','0065') THEN lnt.namt ELSE 0 end) ORGPAIDAMT
        FROM vw_lntran_all lnt
        WHERE lnt.tltxcd IN ('5540','5567')
            AND lnt.txdate <= to_date(PV_TXDATE,'DD/MM/YYYY')
            AND LNT.acctref = PV_LNSAUTOID
            AND LNT.autoid < V_LNSLOGSEQ
        GROUP BY lnt.txdate, lnt.txnum, lnt.acctno, lnt.acctref
        ) LNT
        WHERE LNT.ORGPAIDAMT > 0;

        SELECT MAX(lnt.AUTOID)
        INTO V_LASTLOGSEQ
        FROM vw_lntran_all lnt
        WHERE lnT.txdate = V_LASTDATE AND lnT.txnum = V_LASTTXNUM;*/

        -- TINH TONG SO TIEN LAI DA THANH TOAN
        IF V_LASTLOGSEQ IS NULL THEN
        --IF V_LASTDATE IS NULL OR V_LASTDATE = to_date(PV_TXDATE,'DD/MM/YYYY') THEN
            SELECT sum(LNT.INTPAIDAMT) INTPAIDAMT
            INTO V_PAIDINTNMLACR
            FROM
            (
            SELECT lnt.txdate, lnt.txnum, lnt.acctref lnsautoid, MAX(LNT.autoid) AUTOID,
                sum(CASE WHEN lnt.txcd IN ('0024','0075') THEN lnt.namt ELSE 0 end) INTPAIDAMT
            FROM vw_lntran_all lnt
            WHERE lnt.tltxcd IN ('5540','5567')
                AND lnt.txdate <= to_date(PV_TXDATE,'DD/MM/YYYY')
                AND LNT.acctref = PV_LNSAUTOID
                AND LNT.autoid <= V_LNSLOGSEQ
            GROUP BY lnt.txdate, lnt.txnum, lnt.acctno, lnt.acctref
            ) LNT;
        ELSE
            SELECT sum(LNT.INTPAIDAMT) INTPAIDAMT
            INTO V_PAIDINTNMLACR
            FROM
            (
            SELECT lnt.txdate, lnt.txnum, lnt.acctref lnsautoid, MAX(LNT.autoid) AUTOID,
                sum(CASE WHEN lnt.txcd IN ('0024','0075') THEN lnt.namt ELSE 0 end) INTPAIDAMT
            FROM vw_lntran_all lnt
            WHERE lnt.tltxcd IN ('5540','5567')
                AND lnt.txdate <= to_date(PV_TXDATE,'DD/MM/YYYY')
                AND LNT.acctref = PV_LNSAUTOID
                AND LNT.autoid <= V_LNSLOGSEQ
                --AND LNT.TXDATE > V_LASTDATE
                AND LNT.autoid > V_LASTLOGSEQ
            GROUP BY lnt.txdate, lnt.txnum, lnt.acctno, lnt.acctref
            ) LNT;

        END IF;
    END IF;

    if V_PAIDINTNMLACR >0 then
        RETURN V_PAIDINTNMLACR;
    else
        RETURN 0;
    end if;
END;

 
 
 
 
 
 
 
 
 
 
 
 
 
/
