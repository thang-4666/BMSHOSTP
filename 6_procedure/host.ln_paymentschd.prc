SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "LN_PAYMENTSCHD"
   (pv_strTXNUM IN VARCHAR2,
    pv_strTXDATE IN VARCHAR2,
    pv_strACCTNO IN VARCHAR2,
    pv_dblT0PRINOVD IN NUMBER,
    pv_dblT0PRINNML IN NUMBER,
    pv_dblPRINOVD IN NUMBER,
    pv_dblPRINNML IN NUMBER,
    pv_dblFEEOVD IN NUMBER,
    pv_dblFEEDUE IN NUMBER,
    pv_dblFEENML IN NUMBER,
    pv_dblT0INTNMLOVD IN NUMBER,
    pv_dblT0INTOVDACR IN NUMBER,
    pv_dblT0INTDUE IN NUMBER,
    pv_dblT0INTNMLACR IN NUMBER,
    pv_dblINTNMLOVD IN NUMBER,
    pv_dblINTOVDACR IN NUMBER,
    pv_dblINTDUE IN NUMBER,
    pv_dblINTNMLACR IN NUMBER,
    pv_dblADVFEE IN NUMBER,
    pv_blnAUTO IN CHAR)
   IS
    v_dblT0PRINOVD NUMBER(20,4);
    v_dblT0PRINNML NUMBER(20,4);
    v_dblPRINOVD NUMBER(20,4);
    v_dblPRINNML NUMBER(20,4);
    v_dblFEEOVD NUMBER(20,4);
    v_dblFEEDUE NUMBER(20,4);
    v_dblFEENML NUMBER(20,4);
    v_dblT0INTNMLOVD NUMBER(20,4);
    v_dblT0INTOVDACR NUMBER(20,4);
    v_dblT0INTDUE NUMBER(20,4);
    v_dblT0INTNMLACR NUMBER(20,4);
    v_dblINTNMLOVD NUMBER(20,4);
    v_dblINTOVDACR NUMBER(20,4);
    v_dblINTDUE NUMBER(20,4);
    v_dblINTNMLACR NUMBER(20,4);
    v_dblPaidAmt Number(20,4);
    v_dblFeeAmt Number(20,4);
    v_dblSumFee Number(20,4);
    v_dblAmt Number(20,4);
BEGIN
    v_dblT0PRINOVD:= pv_dblT0PRINOVD;
    v_dblT0PRINNML:= pv_dblT0PRINNML;
    v_dblT0INTNMLOVD:= pv_dblT0INTNMLOVD;
    v_dblT0INTOVDACR:= pv_dblT0INTOVDACR;
    v_dblT0INTDUE:= pv_dblT0INTDUE;
    v_dblT0INTNMLACR:= pv_dblT0INTNMLACR;

    v_dblPRINOVD:= pv_dblPRINOVD;
    v_dblPRINNML:= pv_dblPRINNML;
    v_dblINTNMLOVD:= pv_dblINTNMLOVD;
    v_dblINTOVDACR:= pv_dblINTOVDACR;
    v_dblINTDUE:= pv_dblINTDUE;
    v_dblINTNMLACR:= pv_dblINTNMLACR;

    v_dblFEEOVD:= pv_dblFEEOVD;
    v_dblFEEDUE:= pv_dblFEEDUE;
    v_dblFEENML:= pv_dblFEENML;

-- Phan bo goc T0
    -- Phan bo goc T0 qua han
    IF v_dblT0PRINOVD > 0 THEN
        FOR REC1 IN
            (SELECT AUTOID, OVD FROM LNSCHD WHERE ACCTNO = pv_strACCTNO AND REFTYPE = 'GP' AND OVD > 0 ORDER BY OVERDUEDATE)
        LOOP
            IF v_dblT0PRINOVD > 0 THEN
                IF v_dblT0PRINOVD >= REC1.OVD THEN
                    v_dblPaidAmt:= REC1.OVD;
                ELSE
                    v_dblPaidAmt:= v_dblT0PRINOVD;
                END IF;
                v_dblT0PRINOVD:= v_dblT0PRINOVD - v_dblPaidAmt;
                UPDATE LNSCHD SET OVD = OVD - v_dblPaidAmt, PAID = PAID + v_dblPaidAmt, PAIDDATE=TO_DATE(pv_strTXDATE,'DD/MM/RRRR') WHERE AUTOID = REC1.AUTOID;
                INSERT INTO LNSCHDLOG(AUTOID, TXNUM, TXDATE, NML, OVD, PAID, INTNMLACR, FEE)
                VALUES(REC1.AUTOID, pv_strTXNUM, TO_DATE(pv_strTXDATE,'dd/mm/rrrr'), 0, -v_dblPaidAmt, v_dblPaidAmt, 0, 0);
            END IF;
        END LOOP;
    END IF;

    -- Phan bo goc T0 den han va trong han
    IF v_dblT0PRINNML > 0 THEN
        FOR REC2 IN
            (SELECT AUTOID, NML FROM LNSCHD WHERE ACCTNO = pv_strACCTNO AND REFTYPE = 'GP' AND NML > 0 ORDER BY OVERDUEDATE)
        LOOP
            IF v_dblT0PRINNML > 0 THEN
                IF v_dblT0PRINNML >= REC2.NML THEN
                    v_dblPaidAmt:= REC2.NML;
                ELSE
                    v_dblPaidAmt:= v_dblT0PRINNML;
                END IF;
                v_dblT0PRINNML:= v_dblT0PRINNML - v_dblPaidAmt;
                UPDATE LNSCHD SET NML = NML - v_dblPaidAmt, PAID = PAID + v_dblPaidAmt, PAIDDATE=TO_DATE(pv_strTXDATE,'DD/MM/RRRR') WHERE AUTOID = REC2.AUTOID;
                INSERT INTO LNSCHDLOG(AUTOID, TXNUM, TXDATE, NML, OVD, PAID, INTNMLACR, FEE)
                VALUES(REC2.AUTOID, pv_strTXNUM, TO_DATE(pv_strTXDATE,'dd/mm/rrrr'), -v_dblPaidAmt, 0, v_dblPaidAmt, 0, 0);
            END IF;
        END LOOP;
    END IF;

-- Phan bo goc Margin
    -- Phan bo goc Margin qua han
    IF v_dblPRINOVD > 0 THEN
        FOR REC3 IN
            (SELECT AUTOID, OVD FROM LNSCHD WHERE ACCTNO = pv_strACCTNO AND REFTYPE = 'P' AND OVD > 0 ORDER BY OVERDUEDATE)
        LOOP
            IF v_dblPRINOVD > 0 THEN
                IF v_dblPRINOVD >= REC3.OVD THEN
                    v_dblPaidAmt:= REC3.OVD;
                ELSE
                    v_dblPaidAmt:= v_dblPRINOVD;
                END IF;
                v_dblPRINOVD:= v_dblPRINOVD - v_dblPaidAmt;
                UPDATE LNSCHD SET OVD = OVD - v_dblPaidAmt, PAID = PAID + v_dblPaidAmt, PAIDDATE=TO_DATE(pv_strTXDATE,'DD/MM/RRRR') WHERE AUTOID = REC3.AUTOID;
                INSERT INTO LNSCHDLOG(AUTOID, TXNUM, TXDATE, NML, OVD, PAID, INTNMLACR, FEE)
                VALUES(REC3.AUTOID, pv_strTXNUM, TO_DATE(pv_strTXDATE,'dd/mm/rrrr'), 0, -v_dblPaidAmt, v_dblPaidAmt, 0, 0);
            END IF;
        END LOOP;
    END IF;

    -- Phan bo goc Margin den han
    IF v_dblPRINNML > 0 THEN
        FOR REC4_1 IN
            (SELECT AUTOID, NML FROM LNSCHD WHERE ACCTNO = pv_strACCTNO AND REFTYPE = 'P' AND NML > 0 AND OVERDUEDATE = TO_DATE(pv_strTXDATE,'dd/mm/rrrr'))
        LOOP
            IF v_dblPRINNML > 0 THEN
                IF v_dblPRINNML >= REC4_1.NML THEN
                    v_dblPaidAmt:= REC4_1.NML;
                ELSE
                    v_dblPaidAmt:= v_dblPRINNML;
                END IF;
                v_dblPRINNML:= v_dblPRINNML - v_dblPaidAmt;
                UPDATE LNSCHD SET NML = NML - v_dblPaidAmt, PAID = PAID + v_dblPaidAmt, PAIDDATE=TO_DATE(pv_strTXDATE,'DD/MM/RRRR') WHERE AUTOID = REC4_1.AUTOID;
                INSERT INTO LNSCHDLOG(AUTOID, TXNUM, TXDATE, NML, OVD, PAID, INTNMLACR, FEE)
                VALUES(REC4_1.AUTOID, pv_strTXNUM, TO_DATE(pv_strTXDATE,'dd/mm/rrrr'), -v_dblPaidAmt, 0, v_dblPaidAmt, 0, 0);
            END IF;
        END LOOP;

    END IF;

    -- Phan bo goc Margin trong han
    IF v_dblPRINNML > 0 THEN
        v_dblFeeAmt:= 0;
        v_dblSumFee:= 0;
        FOR REC4_2 IN
            (SELECT AUTOID, NML FROM LNSCHD WHERE ACCTNO = pv_strACCTNO AND REFTYPE = 'P' AND NML > 0 AND OVERDUEDATE > TO_DATE(pv_strTXDATE,'dd/mm/rrrr') ORDER BY OVERDUEDATE)
        LOOP
            IF v_dblPRINNML > 0 THEN
                IF v_dblPRINNML >= REC4_2.NML THEN
                    v_dblPaidAmt:= REC4_2.NML;
                ELSE
                    v_dblPaidAmt:= v_dblPRINNML;
                END IF;
                v_dblPRINNML:= v_dblPRINNML - v_dblPaidAmt;
                v_dblFeeAmt:= v_dblPaidAmt*pv_dblAdvFee/100;
                v_dblSumFee:= v_dblSumFee + v_dblFeeAmt;
                If pv_blnAUTO = 'Y' THEN
                    UPDATE LNSCHD SET NML = NML - v_dblPaidAmt, PAID = PAID + v_dblPaidAmt, FEE = FEE + v_dblFeeAmt, PAIDDATE=TO_DATE(pv_strTXDATE,'DD/MM/RRRR') WHERE AUTOID = REC4_2.AUTOID;
                    INSERT INTO LNSCHDLOG(AUTOID, TXNUM, TXDATE, NML, OVD, PAID, INTNMLACR, FEE)
                    VALUES(REC4_2.AUTOID, pv_strTXNUM, TO_DATE(pv_strTXDATE,'dd/mm/rrrr'), -v_dblPaidAmt, 0, v_dblPaidAmt, 0, v_dblFeeAmt);
                ELSE
                    UPDATE LNSCHD SET NML = NML - v_dblPaidAmt, PAID = PAID + v_dblPaidAmt, FEEPAID2 = FEEPAID2 + v_dblFeeAmt, PAIDDATE=TO_DATE(pv_strTXDATE,'DD/MM/RRRR') WHERE AUTOID = REC4_2.AUTOID;
                    INSERT INTO LNSCHDLOG(AUTOID, TXNUM, TXDATE, NML, OVD, PAID, INTNMLACR, FEEPAID2)
                    VALUES(REC4_2.AUTOID, pv_strTXNUM, TO_DATE(pv_strTXDATE,'dd/mm/rrrr'), -v_dblPaidAmt, 0, v_dblPaidAmt, 0, v_dblFeeAmt);
                END IF;
            END IF;
        END LOOP;
        IF pv_blnAUTO = 'Y' THEN
            UPDATE LNMAST SET FEE = FEE + v_dblSumFee WHERE ACCTNO = pv_strACCTNO;
        END IF;

    END IF;

-- Phan bo phi
    -- Phan bo phi qua han
    IF v_dblFEEOVD > 0 THEN
        FOR REC5 IN
            (SELECT AUTOID, OVD FROM LNSCHD WHERE ACCTNO = pv_strACCTNO AND REFTYPE = 'F' AND OVD > 0 ORDER BY OVERDUEDATE)
        LOOP
            IF v_dblFEEOVD > 0 THEN
                IF v_dblFEEOVD >= REC5.OVD THEN
                    v_dblPaidAmt:= REC5.OVD;
                ELSE
                    v_dblPaidAmt:= v_dblFEEOVD;
                END IF;
                v_dblFEEOVD:= v_dblFEEOVD - v_dblPaidAmt;
                UPDATE LNSCHD SET OVD = OVD - v_dblPaidAmt, PAID = PAID + v_dblPaidAmt, PAIDDATE=TO_DATE(pv_strTXDATE,'DD/MM/RRRR') WHERE AUTOID = REC5.AUTOID;
                INSERT INTO LNSCHDLOG(AUTOID, TXNUM, TXDATE, NML, OVD, PAID, INTNMLACR, FEE)
                VALUES(REC5.AUTOID, pv_strTXNUM, TO_DATE(pv_strTXDATE,'dd/mm/rrrr'), 0, -v_dblPaidAmt, v_dblPaidAmt, 0, 0);
                v_dblAmt:= v_dblPaidAmt;
                FOR FEEOVDREC IN
                    (SELECT AUTOID, FEEOVD FROM LNSCHD WHERE ACCTNO = pv_strACCTNO AND REFTYPE = 'P' AND FEEOVD > 0 ORDER BY RLSDATE)
                LOOP
                    If v_dblAmt > 0 THEN
                        If v_dblAmt >= FEEOVDREC.FEEOVD THEN
                            v_dblPaidAmt:= FEEOVDREC.FEEOVD;
                        ELSE
                            v_dblPaidAmt:= v_dblAmt;
                        END IF;
                        v_dblAmt:= v_dblAmt - v_dblPaidAmt;
                        UPDATE LNSCHD SET FEEOVD = FEEOVD - v_dblPaidAmt, FEEPAID = FEEPAID + v_dblPaidAmt WHERE AUTOID = FEEOVDREC.AUTOID;
                        INSERT INTO LNSCHDLOG(AUTOID, TXNUM, TXDATE, NML, OVD, PAID, INTNMLACR, FEE,INTDUE,INTOVD,FEEDUE,FEEOVD,INTPAID,FEEPAID)
                        VALUES(FEEOVDREC.AUTOID, pv_strTXNUM, TO_DATE(pv_strTXDATE,'dd/mm/rrrr'), 0, 0, 0, 0, 0, 0, 0, 0, -v_dblPaidAmt, 0, v_dblPaidAmt);
                    END IF;
                END LOOP;
            END IF;
        END LOOP;
    END IF;

    -- Phan bo phi den han
    IF v_dblFEEDUE > 0 THEN
        FOR REC6 IN
            (SELECT AUTOID, NML FROM LNSCHD WHERE ACCTNO = pv_strACCTNO AND REFTYPE = 'F' AND NML > 0 ORDER BY OVERDUEDATE)
        LOOP
            IF v_dblFEEDUE > 0 THEN
                IF v_dblFEEDUE >= REC6.NML THEN
                    v_dblPaidAmt:= REC6.NML;
                ELSE
                    v_dblPaidAmt:= v_dblFEEDUE;
                END IF;
                v_dblFEEDUE:= v_dblFEEDUE - v_dblPaidAmt;
                UPDATE LNSCHD SET NML = NML - v_dblPaidAmt, PAID = PAID + v_dblPaidAmt, PAIDDATE=TO_DATE(pv_strTXDATE,'DD/MM/RRRR') WHERE AUTOID = REC6.AUTOID;
                INSERT INTO LNSCHDLOG(AUTOID, TXNUM, TXDATE, NML, OVD, PAID, INTNMLACR, FEE)
                VALUES(REC6.AUTOID, pv_strTXNUM, TO_DATE(pv_strTXDATE,'dd/mm/rrrr'), -v_dblPaidAmt, 0, v_dblPaidAmt, 0, 0);
                v_dblAmt:= v_dblPaidAmt;
                FOR FEEDUEREC IN
                    (SELECT AUTOID, FEEDUE FROM LNSCHD WHERE ACCTNO = pv_strACCTNO AND REFTYPE = 'P' AND FEEDUE > 0 ORDER BY RLSDATE)
                LOOP
                    IF v_dblAmt > 0 THEN
                        If v_dblAmt >= FEEDUEREC.FEEDUE THEN
                            v_dblPaidAmt:= FEEDUEREC.FEEDUE;
                        ELSE
                            v_dblPaidAmt:= v_dblAmt;
                        END IF;
                        v_dblAmt:= v_dblAmt - v_dblPaidAmt;
                        UPDATE LNSCHD SET FEEDUE = FEEDUE - v_dblPaidAmt, FEEPAID = FEEPAID + v_dblPaidAmt WHERE AUTOID = FEEDUEREC.AUTOID;
                        INSERT INTO LNSCHDLOG(AUTOID, TXNUM, TXDATE, NML, OVD, PAID, INTNMLACR, FEE,INTDUE,INTOVD,FEEDUE,FEEOVD,INTPAID,FEEPAID)
                        VALUES(FEEDUEREC.AUTOID, pv_strTXNUM, TO_DATE(pv_strTXDATE,'dd/mm/rrrr'), 0, 0, 0, 0, 0, 0, 0, -v_dblPaidAmt, 0, 0, v_dblPaidAmt);
                    END IF;
                END LOOP;
            END IF;
        END LOOP;
    END IF;

    -- Phan bo phi trong han
    IF pv_blnAUTO = 'N' AND v_dblFEENML > 0 THEN
        v_dblFeeAmt:= 0;
        v_dblSumFee:= 0;
        FOR REC7 IN
            (SELECT AUTOID, FEE FROM LNSCHD WHERE ACCTNO = pv_strACCTNO AND REFTYPE IN ('P','GP') AND FEE > 0 ORDER BY OVERDUEDATE)
        LOOP
            IF v_dblFEENML > 0 THEN
                IF v_dblFEENML >= REC7.FEE THEN
                    v_dblPaidAmt:= REC7.FEE;
                ELSE
                    v_dblPaidAmt:= v_dblFEENML;
                END IF;
                v_dblFEENML:= v_dblFEENML - v_dblPaidAmt;
                v_dblFeeAmt:= v_dblPaidAmt*pv_dblAdvFee/100;
                v_dblSumFee:= v_dblSumFee + v_dblFeeAmt;
                UPDATE LNSCHD SET FEE = FEE - v_dblPaidAmt, FEEPAID = FEEPAID + v_dblPaidAmt, FEEPAID2 = FEEPAID2 + v_dblFeeAmt WHERE AUTOID = REC7.AUTOID;
                INSERT INTO LNSCHDLOG(AUTOID, TXNUM, TXDATE, NML, OVD, PAID, INTNMLACR, FEE, FEEPAID, FEEPAID2)
                VALUES(REC7.AUTOID, pv_strTXNUM, TO_DATE(pv_strTXDATE,'dd/mm/rrrr'), 0, 0, 0, 0, -v_dblPaidAmt, v_dblPaidAmt, v_dblFeeAmt);
            END IF;
        END LOOP;
    END IF;

-- Phan bo lai vay T0
    -- Phan bo lai T0 qua han
    IF v_dblT0INTNMLOVD > 0 THEN
        FOR REC8 IN
            (SELECT AUTOID, OVD FROM LNSCHD WHERE ACCTNO = pv_strACCTNO AND REFTYPE = 'GI' AND OVD > 0 ORDER BY OVERDUEDATE)
        LOOP
            IF v_dblT0INTNMLOVD > 0 THEN
                IF v_dblT0INTNMLOVD >= REC8.OVD THEN
                    v_dblPaidAmt:= REC8.OVD;
                ELSE
                    v_dblPaidAmt:= v_dblT0INTNMLOVD;
                END IF;
                v_dblT0INTNMLOVD:= v_dblT0INTNMLOVD - v_dblPaidAmt;
                UPDATE LNSCHD SET OVD = OVD - v_dblPaidAmt, PAID = PAID + v_dblPaidAmt, PAIDDATE=TO_DATE(pv_strTXDATE,'DD/MM/RRRR') WHERE AUTOID = REC8.AUTOID;
                INSERT INTO LNSCHDLOG(AUTOID, TXNUM, TXDATE, NML, OVD, PAID, INTNMLACR, FEE)
                VALUES(REC8.AUTOID, pv_strTXNUM, TO_DATE(pv_strTXDATE,'dd/mm/rrrr'), 0, -v_dblPaidAmt, v_dblPaidAmt, 0, 0);
                v_dblAmt:= v_dblPaidAmt;
                FOR T0INTOVDREC IN
                    (SELECT AUTOID, INTOVD FROM LNSCHD WHERE ACCTNO = pv_strACCTNO AND REFTYPE = 'GP' AND INTOVD > 0 ORDER BY RLSDATE)
                LOOP
                    IF v_dblAmt > 0 THEN
                        If v_dblAmt >= T0INTOVDREC.INTOVD THEN
                            v_dblPaidAmt:= T0INTOVDREC.INTOVD;
                        ELSE
                            v_dblPaidAmt:= v_dblAmt;
                        END IF;
                        v_dblAmt:= v_dblAmt - v_dblPaidAmt;
                        UPDATE LNSCHD SET INTOVD = INTOVD - v_dblPaidAmt, INTPAID = INTPAID + v_dblPaidAmt WHERE AUTOID = T0INTOVDREC.AUTOID;
                        INSERT INTO LNSCHDLOG(AUTOID, TXNUM, TXDATE, NML, OVD, PAID, INTNMLACR, FEE,INTDUE,INTOVD,FEEDUE,FEEOVD,INTPAID,FEEPAID)
                        VALUES(T0INTOVDREC.AUTOID, pv_strTXNUM, TO_DATE(pv_strTXDATE,'dd/mm/rrrr'), 0, 0, 0, 0, 0, 0, -v_dblPaidAmt, 0, 0, v_dblPaidAmt, 0);
                    END IF;
                END LOOP;
            END IF;
        END LOOP;
    END IF;

    -- Phan bo lai tren goc T0 qua han
    IF v_dblT0INTOVDACR > 0 THEN
        FOR REC_OVD IN
            (SELECT AUTOID, INTOVDPRIN FROM LNSCHD WHERE ACCTNO = pv_strACCTNO AND REFTYPE = 'GP' AND INTOVDPRIN > 0 ORDER BY OVERDUEDATE)
        LOOP
            IF v_dblT0INTOVDACR > 0 THEN
                IF v_dblT0INTOVDACR >= REC_OVD.INTOVDPRIN THEN
                    v_dblPaidAmt:= REC_OVD.INTOVDPRIN;
                ELSE
                    v_dblPaidAmt:= v_dblT0INTOVDACR;
                END IF;
                v_dblT0INTOVDACR:= v_dblT0INTOVDACR - v_dblPaidAmt;
                UPDATE LNSCHD SET INTOVDPRIN = INTOVDPRIN - v_dblPaidAmt, INTPAID = INTPAID + v_dblPaidAmt, PAIDDATE=TO_DATE(pv_strTXDATE,'DD/MM/RRRR') WHERE AUTOID = REC_OVD.AUTOID;
                INSERT INTO LNSCHDLOG(AUTOID, TXNUM, TXDATE, NML, OVD, PAID, INTNMLACR, FEE, INTOVDPRIN, INTPAID)
                VALUES(REC_OVD.AUTOID, pv_strTXNUM, TO_DATE(pv_strTXDATE,'dd/mm/rrrr'), 0, 0, 0, 0, 0, -v_dblPaidAmt, v_dblPaidAmt);
            END IF;
        END LOOP;
    END IF;

    -- Phan bo lai T0 den han
    IF v_dblT0INTDUE > 0 THEN
        FOR REC9 IN
            (SELECT AUTOID, NML FROM LNSCHD WHERE ACCTNO = pv_strACCTNO AND REFTYPE = 'GI' AND NML > 0 ORDER BY OVERDUEDATE)
        LOOP
            IF v_dblT0INTDUE > 0 THEN
                IF v_dblT0INTDUE >= REC9.NML THEN
                    v_dblPaidAmt:= REC9.NML;
                ELSE
                    v_dblPaidAmt:= v_dblT0INTDUE;
                END IF;
                v_dblT0INTDUE:= v_dblT0INTDUE - v_dblPaidAmt;
                UPDATE LNSCHD SET NML = NML - v_dblPaidAmt, PAID = PAID + v_dblPaidAmt, PAIDDATE=TO_DATE(pv_strTXDATE,'DD/MM/RRRR') WHERE AUTOID = REC9.AUTOID;
                INSERT INTO LNSCHDLOG(AUTOID, TXNUM, TXDATE, NML, OVD, PAID, INTNMLACR, FEE)
                VALUES(REC9.AUTOID, pv_strTXNUM, TO_DATE(pv_strTXDATE,'dd/mm/rrrr'), -v_dblPaidAmt, 0, v_dblPaidAmt, 0, 0);
                v_dblAmt:= v_dblPaidAmt;
                FOR T0INTDUEREC IN
                    (SELECT AUTOID, INTDUE FROM LNSCHD WHERE ACCTNO = pv_strACCTNO AND REFTYPE = 'GP' AND INTDUE > 0 ORDER BY RLSDATE)
                LOOP
                    IF v_dblAmt > 0 THEN
                        If v_dblAmt >= T0INTDUEREC.INTDUE THEN
                            v_dblPaidAmt:= T0INTDUEREC.INTDUE;
                        ELSE
                            v_dblPaidAmt:= v_dblAmt;
                        END IF;
                        v_dblAmt:= v_dblAmt - v_dblPaidAmt;
                        UPDATE LNSCHD SET INTDUE = INTDUE - v_dblPaidAmt, INTPAID = INTPAID + v_dblPaidAmt WHERE AUTOID = T0INTDUEREC.AUTOID;
                        INSERT INTO LNSCHDLOG(AUTOID, TXNUM, TXDATE, NML, OVD, PAID, INTNMLACR, FEE,INTDUE,INTOVD,FEEDUE,FEEOVD,INTPAID,FEEPAID)
                        VALUES(T0INTDUEREC.AUTOID, pv_strTXNUM, TO_DATE(pv_strTXDATE,'dd/mm/rrrr'), 0, 0, 0, 0, 0, -v_dblPaidAmt, 0, 0, 0, v_dblPaidAmt, 0);
                    END IF;
                END LOOP;
            END IF;
        END LOOP;
    END IF;

    -- Phan bo lai T0 trong han
    IF pv_blnAUTO = 'N' AND v_dblT0INTNMLACR > 0 THEN
        v_dblFeeAmt:= 0;
        v_dblSumFee:= 0;
        FOR REC10 IN
            (SELECT AUTOID, INTNMLACR FROM LNSCHD WHERE ACCTNO = pv_strACCTNO AND REFTYPE = 'GP' AND INTNMLACR > 0 ORDER BY OVERDUEDATE)
        LOOP
            IF v_dblT0INTNMLACR > 0 THEN
                IF v_dblT0INTNMLACR >= REC10.INTNMLACR THEN
                    v_dblPaidAmt:= REC10.INTNMLACR;
                ELSE
                    v_dblPaidAmt:= v_dblT0INTNMLACR;
                END IF;
                v_dblT0INTNMLACR:= v_dblT0INTNMLACR - v_dblPaidAmt;
                v_dblFeeAmt:= v_dblPaidAmt*pv_dblAdvFee/100;
                v_dblSumFee:= v_dblSumFee + v_dblFeeAmt;
                UPDATE LNSCHD SET INTNMLACR = INTNMLACR - v_dblPaidAmt, INTPAID = INTPAID + v_dblPaidAmt, FEEPAID2 = FEEPAID2 + v_dblFeeAmt WHERE AUTOID = REC10.AUTOID;
                INSERT INTO LNSCHDLOG(AUTOID, TXNUM, TXDATE, NML, OVD, PAID, INTNMLACR, FEE, INTPAID, FEEPAID2)
                VALUES(REC10.AUTOID, pv_strTXNUM, TO_DATE(pv_strTXDATE,'dd/mm/rrrr'), 0, 0, 0, -v_dblPaidAmt, 0, v_dblPaidAmt, v_dblFeeAmt);
            END IF;
        END LOOP;
    END IF;

-- Phan bo lai vay Margin
    -- Phan bo lai Margin qua han
    IF v_dblINTNMLOVD > 0 THEN
        FOR REC11 IN
            (SELECT AUTOID, OVD FROM LNSCHD WHERE ACCTNO = pv_strACCTNO AND REFTYPE = 'I' AND OVD > 0 ORDER BY OVERDUEDATE)
        LOOP
            IF v_dblINTNMLOVD > 0 THEN
                IF v_dblINTNMLOVD >= REC11.OVD THEN
                    v_dblPaidAmt:= REC11.OVD;
                ELSE
                    v_dblPaidAmt:= v_dblINTNMLOVD;
                END IF;
                v_dblINTNMLOVD:= v_dblINTNMLOVD - v_dblPaidAmt;
                UPDATE LNSCHD SET OVD = OVD - v_dblPaidAmt, PAID = PAID + v_dblPaidAmt, PAIDDATE=TO_DATE(pv_strTXDATE,'DD/MM/RRRR') WHERE AUTOID = REC11.AUTOID;
                INSERT INTO LNSCHDLOG(AUTOID, TXNUM, TXDATE, NML, OVD, PAID, INTNMLACR, FEE)
                VALUES(REC11.AUTOID, pv_strTXNUM, TO_DATE(pv_strTXDATE,'dd/mm/rrrr'), 0, -v_dblPaidAmt, v_dblPaidAmt, 0, 0);
                v_dblAmt:= v_dblPaidAmt;
                FOR INTOVDREC IN
                    (SELECT AUTOID, INTOVD FROM LNSCHD WHERE ACCTNO = pv_strACCTNO AND REFTYPE = 'P' AND INTOVD > 0 ORDER BY RLSDATE)
                LOOP
                    IF v_dblAmt > 0 THEN
                        If v_dblAmt >= INTOVDREC.INTOVD THEN
                            v_dblPaidAmt:= INTOVDREC.INTOVD;
                        ELSE
                            v_dblPaidAmt:= v_dblAmt;
                        END IF;
                        v_dblAmt:= v_dblAmt - v_dblPaidAmt;
                        UPDATE LNSCHD SET INTOVD = INTOVD - v_dblPaidAmt, INTPAID = INTPAID + v_dblPaidAmt WHERE AUTOID = INTOVDREC.AUTOID;
                        INSERT INTO LNSCHDLOG(AUTOID, TXNUM, TXDATE, NML, OVD, PAID, INTNMLACR, FEE,INTDUE,INTOVD,FEEDUE,FEEOVD,INTPAID,FEEPAID)
                        VALUES(INTOVDREC.AUTOID, pv_strTXNUM, TO_DATE(pv_strTXDATE,'dd/mm/rrrr'), 0, 0, 0, 0, 0, 0, -v_dblPaidAmt, 0, 0, v_dblPaidAmt, 0);
                    END IF;
                END LOOP;
            END IF;
        END LOOP;
    END IF;

    -- Phan bo lai tren goc margin qua han
    IF v_dblINTOVDACR > 0 THEN
        FOR REC_MROVD IN
            (SELECT AUTOID, INTOVDPRIN FROM LNSCHD WHERE ACCTNO = pv_strACCTNO AND REFTYPE = 'P' AND INTOVDPRIN > 0 ORDER BY OVERDUEDATE)
        LOOP
            IF v_dblINTOVDACR > 0 THEN
                IF v_dblINTOVDACR >= REC_MROVD.INTOVDPRIN THEN
                    v_dblPaidAmt:= REC_MROVD.INTOVDPRIN;
                ELSE
                    v_dblPaidAmt:= v_dblINTOVDACR;
                END IF;
                v_dblINTOVDACR:= v_dblINTOVDACR - v_dblPaidAmt;
                UPDATE LNSCHD SET INTOVDPRIN = INTOVDPRIN - v_dblPaidAmt, INTPAID = INTPAID + v_dblPaidAmt, PAIDDATE=TO_DATE(pv_strTXDATE,'DD/MM/RRRR') WHERE AUTOID = REC_MROVD.AUTOID;
                INSERT INTO LNSCHDLOG(AUTOID, TXNUM, TXDATE, NML, OVD, PAID, INTNMLACR, FEE, INTOVDPRIN, INTPAID)
                VALUES(REC_MROVD.AUTOID, pv_strTXNUM, TO_DATE(pv_strTXDATE,'dd/mm/rrrr'), 0, 0, 0, 0, 0, -v_dblPaidAmt, v_dblPaidAmt);
            END IF;
        END LOOP;
    END IF;

    -- Phan bo lai Margin den han
    IF v_dblINTDUE > 0 THEN
        FOR REC12 IN
            (SELECT AUTOID, NML FROM LNSCHD WHERE ACCTNO = pv_strACCTNO AND REFTYPE = 'I' AND NML > 0 ORDER BY OVERDUEDATE)
        LOOP
            IF v_dblINTDUE > 0 THEN
                IF v_dblINTDUE >= REC12.NML THEN
                    v_dblPaidAmt:= REC12.NML;
                ELSE
                    v_dblPaidAmt:= v_dblINTDUE;
                END IF;
                v_dblINTDUE:= v_dblINTDUE - v_dblPaidAmt;
                UPDATE LNSCHD SET NML = NML - v_dblPaidAmt, PAID = PAID + v_dblPaidAmt, PAIDDATE=TO_DATE(pv_strTXDATE,'DD/MM/RRRR') WHERE AUTOID = REC12.AUTOID;
                INSERT INTO LNSCHDLOG(AUTOID, TXNUM, TXDATE, NML, OVD, PAID, INTNMLACR, FEE)
                VALUES(REC12.AUTOID, pv_strTXNUM, TO_DATE(pv_strTXDATE,'dd/mm/rrrr'), -v_dblPaidAmt, 0, v_dblPaidAmt, 0, 0);
                v_dblAmt:= v_dblPaidAmt;
                FOR INTDUEREC IN
                    (SELECT AUTOID, INTDUE FROM LNSCHD WHERE ACCTNO = pv_strACCTNO AND REFTYPE = 'P' AND INTDUE > 0 ORDER BY RLSDATE)
                LOOP
                    IF v_dblAmt > 0 THEN
                        If v_dblAmt >= INTDUEREC.INTDUE THEN
                            v_dblPaidAmt:= INTDUEREC.INTDUE;
                        ELSE
                            v_dblPaidAmt:= v_dblAmt;
                        END IF;
                        v_dblAmt:= v_dblAmt - v_dblPaidAmt;
                        UPDATE LNSCHD SET INTDUE = INTDUE - v_dblPaidAmt, INTPAID = INTPAID + v_dblPaidAmt WHERE AUTOID = INTDUEREC.AUTOID;
                        INSERT INTO LNSCHDLOG(AUTOID, TXNUM, TXDATE, NML, OVD, PAID, INTNMLACR, FEE,INTDUE,INTOVD,FEEDUE,FEEOVD,INTPAID,FEEPAID)
                        VALUES(INTDUEREC.AUTOID, pv_strTXNUM, TO_DATE(pv_strTXDATE,'dd/mm/rrrr'), 0, 0, 0, 0, 0, -v_dblPaidAmt, 0, 0, 0, v_dblPaidAmt, 0);
                    END IF;
                END LOOP;
            END IF;
        END LOOP;
    END IF;

    -- Phan bo lai Margin trong han
    IF pv_blnAUTO = 'N' AND v_dblINTNMLACR > 0 THEN
        FOR REC13 IN
            (SELECT AUTOID, INTNMLACR FROM LNSCHD WHERE ACCTNO = pv_strACCTNO AND REFTYPE = 'P' AND INTNMLACR > 0 ORDER BY OVERDUEDATE)
        LOOP
            IF v_dblINTNMLACR > 0 THEN
                IF v_dblINTNMLACR >= REC13.INTNMLACR THEN
                    v_dblPaidAmt:= REC13.INTNMLACR;
                ELSE
                    v_dblPaidAmt:= v_dblINTNMLACR;
                END IF;
                v_dblINTNMLACR:= v_dblINTNMLACR - v_dblPaidAmt;
                v_dblFeeAmt:= v_dblPaidAmt*pv_dblAdvFee/100;
                v_dblSumFee:= v_dblSumFee + v_dblFeeAmt;
                UPDATE LNSCHD SET INTNMLACR = INTNMLACR - v_dblPaidAmt, INTPAID = INTPAID + v_dblPaidAmt, FEEPAID2 = FEEPAID2 + v_dblFeeAmt WHERE AUTOID = REC13.AUTOID;
                INSERT INTO LNSCHDLOG(AUTOID, TXNUM, TXDATE, NML, OVD, PAID, INTNMLACR, FEE, INTPAID, FEEPAID2)
                VALUES(REC13.AUTOID, pv_strTXNUM, TO_DATE(pv_strTXDATE,'dd/mm/rrrr'), 0, 0, 0, -v_dblPaidAmt, 0, v_dblPaidAmt, v_dblFeeAmt);
            END IF;
        END LOOP;
    END IF;
EXCEPTION
     WHEN others THEN
        return;
END; -- Procedure

 
 
 
 
/
