SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE sp_process_cifeeschd_common
IS
  v_CURRDATE  DATE;
  v_NEXTDATE  DATE;
  v_BOMDATE  DATE;
  v_EOMDATE  DATE;
  v_TODATE  DATE;
  v_Result    number(20);
  V_VSDDEPOFEE_111 NUMBER;
  V_VSDDEPOFEE_222 NUMBER;
  V_VSDDEPOFEE_011 NUMBER;  --Ngay 28/03/2017 CW NamTv them tham so tinh phi luu k? chung quyen
BEGIN
  --PROCESS FEE FOR EXCHANGE FEETYPE=EXCBRK
  --****************************************************************************************
  --CALCULATE THE AMOUNT OF FEE FOR EXCHANGE
  UPDATE ODMAST T1
  SET EXCFEEAMT = nvl((
    SELECT DECODE(T2.FORP,'P',FEEAMT/100,FEEAMT)*T1.EXECAMT/(T2.LOTDAY*T2.LOTVAL)
    FROM (SELECT A2.*
    FROM (SELECT T.ORDERID, MIN(T.ODRNUM) RFNUM FROM VW_ODMAST_EXC_FEETERM T GROUP BY T.ORDERID) A1,
    VW_ODMAST_EXC_FEETERM A2 WHERE A1.ORDERID=A2.ORDERID AND A1.RFNUM=A2.ODRNUM) T2
    WHERE T1.ORDERID = T2.ORDERID),0);
  --MAP TO CIFEEDEF.AUTOID
  UPDATE ODMAST T1
  SET EXCFEEREFID = nvl((
    SELECT T2.AUTOID
    FROM (SELECT A2.*
    FROM (SELECT T.ORDERID, MIN(T.ODRNUM) RFNUM FROM VW_ODMAST_EXC_FEETERM T GROUP BY T.ORDERID) A1,
    VW_ODMAST_EXC_FEETERM A2 WHERE A1.ORDERID=A2.ORDERID AND A1.RFNUM=A2.ODRNUM) T2
    WHERE T1.ORDERID = T2.ORDERID),0);


  --PROCESS THE DEPOSITORY FEE
  --****************************************************************************************
  SELECT TO_DATE (varvalue, systemnums.c_date_format) INTO v_CURRDATE
  FROM sysvar WHERE grname = 'SYSTEM' AND varname = 'CURRDATE';
  SELECT TO_DATE (varvalue, systemnums.c_date_format) INTO v_NEXTDATE
  FROM sysvar WHERE grname = 'SYSTEM' AND varname = 'NEXTDATE';
  SELECT TO_NUMBER (VARVALUE) INTO V_VSDDEPOFEE_111
  FROM sysvar WHERE grname = 'SYSTEM' AND varname = 'VSDDEPOFEE_111';
  SELECT TO_NUMBER (VARVALUE) INTO V_VSDDEPOFEE_222
  FROM sysvar WHERE grname = 'SYSTEM' AND varname = 'VSDDEPOFEE_222';

  --Ngay 28/03/2017 CW NamTv them tham so tinh phi luu k? chung quyen
  SELECT TO_NUMBER (VARVALUE) INTO V_VSDDEPOFEE_011
  FROM sysvar WHERE grname = 'SYSTEM' AND varname = 'VSDDEPOFEE_011';
  --NamTv End

  --CHECK EOM PROCESSING
  --SELECT DECODE(extract(MONTH FROM v_NEXTDATE)-extract(MONTH FROM v_CURRDATE),0,'N','Y') into v_EOM FROM DUAL;
  SELECT ADD_MONTHS(TRUNC(v_CURRDATE, 'MM'), 1) -1 INTO v_EOMDATE FROM DUAL;
  IF v_EOMDATE>=v_NEXTDATE THEN
    --DURING THIS MONTH: CALCULATE THE ACCRUE DEPOSITPORY FEE ONLY (BUSDATE-NEXTDATE)
    BEGIN
           --INCREASE CIDEPOFEEACR IN CIMAST
/*      UPDATE CIMAST T1
      SET CIDEPOFEEACR = CIDEPOFEEACR + nvl((
        SELECT FEEACR
        FROM (
        SELECT A2.AFACCTNO,
          SUM(DECODE(A2.FORP,'P',A2.FEEAMT/100,A2.FEEAMT)*A2.SEBAL*(v_NEXTDATE-nvl (A2.TBALDT,v_CURRDATE))/(A2.LOTDAY*A2.LOTVAL)) FEEACR
        FROM (SELECT T.ACCTNO, MIN(T.ODRNUM) RFNUM FROM VW_SEMAST_VSDDEP_FEETERM T GROUP BY T.ACCTNO) A1,
        VW_SEMAST_VSDDEP_FEETERM A2 WHERE A1.ACCTNO=A2.ACCTNO AND A1.RFNUM=A2.ODRNUM GROUP BY A2.AFACCTNO) T2
        WHERE T1.AFACCTNO = T2.AFACCTNO),0);*/
      for rec in
      (
        SELECT A2.AFACCTNO,a2.ACCTNO,
        /*round((DECODE(A2.FORP,'P',A2.FEEAMT/100,A2.FEEAMT)*A2.SEBAL*(v_NEXTDATE-nvl (A2.TBALDT,v_CURRDATE))/(A2.LOTDAY*A2.LOTVAL)),4) FEEACR,*/
        round(((v_NEXTDATE-nvl (A2.TBALDT,v_CURRDATE))*A2.AMT_TEMP),4) FEEACR,
        A2.AUTOID Ref, A2.TYPE,
        A2.FEEAMT,A2.LOTDAY,A2.LOTVAL,A2.FORP,
        (CASE WHEN A2.ODR=A3.ODR THEN 'Y' ELSE 'N' END ) USED,
        A2.SECTYPE
        FROM /*(SELECT T.ACCTNO, MIN(T.ODRNUM) RFNUM FROM VW_SEMAST_VSDDEP_FEETERM T GROUP BY T.ACCTNO) A1,*/
            (SELECT T.*,ROWNUM ODR
            FROM   (SELECT * FROM VW_SEMAST_VSDDEP_FEETERM T ORDER BY T.ACCTNO,T.ODRNUM, T.AMT_TEMP) T
            ) A2,
            (
            SELECT ACCTNO,MIN(ODR) ODR
            FROM
            (SELECT T.*,ROWNUM ODR
            FROM   (SELECT * FROM VW_SEMAST_VSDDEP_FEETERM T ORDER BY T.ACCTNO,T.ODRNUM, T.AMT_TEMP) T
            )
            GROUP BY ACCTNO
            )A3
         WHERE A2.ACCTNO=A3.ACCTNO
      )
      LOOP
      --PhuongHT edit: chi update vao CIMAST khi bieu phi duoc su dung
      IF REC.USED='Y' THEN
        UPDATE CIMAST T1
            SET CIDEPOFEEACR = CIDEPOFEEACR + nvl(REC.FEEACR,0)
        where acctno = rec.afacctno;
      END IF;
      -- end of PhuongHT edit
         --LOG INTO SEDEPOBAL
      INSERT INTO SEDEPOBAL (AUTOID, ACCTNO, TXDATE, DAYS, QTTY, DELTD,AMT,Type,Ref,FEEAMT,LOTDAY,LOTVAL,FORP,ID,USED,VSDFEEAMT, REACCTNO, REACCTNORD)
      SELECT SEQ_SEDEPOBAL.NEXTVAL, SE.ACCTNO, nvl (SE.TBALDT,v_CURRDATE), v_NEXTDATE-nvl (SE.TBALDT,v_CURRDATE),
        (se.trade + se.margin + se.mortage + se.blocked + se.secured + se.repo + se.netting + se.dtoclose + se.withdraw+se.emkqtty+se.blockwithdraw+se.blockdtoclose), 'N',
        nvl(REC.FEEACR,0),REC.TYPE,REC.Ref,REC.FEEAMT,REC.LOTDAY,REC.LOTVAL,REC.FORP,'BATCH',REC.USED,
      (CASE WHEN REC.SECTYPE IN ('001','002','007','008') THEN V_VSDDEPOFEE_111
      --Ngay 22/03/2017 CW NamTv them sectype chung quyen
            WHEN REC.SECTYPE IN ('011') THEN V_VSDDEPOFEE_011
      --NamTv End
            WHEN REC.SECTYPE IN ('003','006') THEN V_VSDDEPOFEE_222 ELSE 0 END ), nvl(re.reacctno,'') reacctno, nvl(re.reacctnord,'') reacctnord
      FROM SEMAST SE, afmast af, (SELECT rl.afacctno, CASE WHEN ret.rerole = 'RD' THEN rl.reacctno ELSE ' ' END reacctnord,
                        CASE WHEN ret.rerole IN ('RM', 'CS') THEN rl.reacctno ELSE ' ' END reacctno, rl.frdate, nvl(rl.clstxdate, rl.todate) todate FROM
                        reaflnk rl, remast re, retype ret
                     WHERE rl.reacctno = re.acctno
                        AND re.actype = ret.actype  and rl.status = 'A'
                        AND ret.rerole IN ('RM' ,'CS' ,'RD')) re
        WHERE se.afacctno = af.acctno
            AND af.custid = re.afacctno(+)
            AND nvl(re.frdate,v_CURRDATE) <= v_CURRDATE
            AND nvl(re.todate,v_currdate) >= v_currdate
            AND se.acctno=rec.ACCTNO
            AND nvl (SE.TBALDT,v_CURRDATE) <v_NEXTDATE;
      end loop;
      --MARK TO SEMAST
      UPDATE SEMAST SET TBALDT=v_NEXTDATE;
    END;
  ELSE
    --NEED PROCESS END OF MONTH: CALCULATE THE ACCRUE DEPOSITPORY FEE 1 THE MATURITY DEPOSITORY FEE
    BEGIN
      --1.1: TINH CONG DON DEN NGAY CUOI THANG
          --INCREASE CIDEPOFEEACR IN CIMAST
/*      UPDATE CIMAST T1
      SET CIDEPOFEEACR = CIDEPOFEEACR + nvl((
        SELECT FEEACR
        FROM (
        SELECT A2.AFACCTNO,
          SUM(DECODE(A2.FORP,'P',A2.FEEAMT/100,A2.FEEAMT)*A2.SEBAL*(v_EOMDATE-nvl(A2.TBALDT,v_CURRDATE)+1)/(A2.LOTDAY*A2.LOTVAL)) FEEACR
        FROM (SELECT T.ACCTNO, MIN(T.ODRNUM) RFNUM FROM VW_SEMAST_VSDDEP_FEETERM T GROUP BY T.ACCTNO) A1,
        VW_SEMAST_VSDDEP_FEETERM A2 WHERE A1.ACCTNO=A2.ACCTNO AND A1.RFNUM=A2.ODRNUM GROUP BY A2.AFACCTNO) T2
        WHERE T1.AFACCTNO = T2.AFACCTNO),0);*/
      for rec in
      (
        SELECT A2.AFACCTNO,a2.ACCTNO,
          round((v_EOMDATE-nvl(A2.TBALDT,v_CURRDATE)+1)*A2.AMT_TEMP,4) FEEACR,
          A2.AUTOID Ref, A2.TYPE,
          A2.FEEAMT,A2.LOTDAY,A2.LOTVAL,A2.FORP,
          (CASE WHEN A2.ODR=A3.ODR THEN 'Y' ELSE 'N' END ) USED,A2.SECTYPE

        FROM /*(SELECT T.ACCTNO, MIN(T.ODRNUM) RFNUM FROM VW_SEMAST_VSDDEP_FEETERM T GROUP BY T.ACCTNO) A1,*/
            (SELECT T.*,ROWNUM ODR
            FROM   (SELECT * FROM VW_SEMAST_VSDDEP_FEETERM T ORDER BY T.ACCTNO,T.ODRNUM, T.AMT_TEMP) T
            ) A2,
            (
            SELECT ACCTNO,MIN(ODR) ODR
            FROM
            (SELECT T.*,ROWNUM ODR
            FROM   (SELECT * FROM VW_SEMAST_VSDDEP_FEETERM T ORDER BY T.ACCTNO,T.ODRNUM, T.AMT_TEMP) T
            )
            GROUP BY ACCTNO
            )A3
         WHERE A2.ACCTNO=A3.ACCTNO
      )
      LOOP
        IF REC.USED='Y' THEN
            UPDATE CIMAST T1
                SET CIDEPOFEEACR = CIDEPOFEEACR + nvl(REC.FEEACR,0)
            where acctno = rec.afacctno;
        END IF;
         --LOG INTO SEDEPOBAL: UPTO END OF MONTH
      INSERT INTO SEDEPOBAL (AUTOID, ACCTNO, TXDATE, DAYS, QTTY, DELTD,AMT,Type,Ref,FEEAMT,LOTDAY,LOTVAL,FORP,ID,USED,VSDFEEAMT, REACCTNO, REACCTNORD)
      SELECT SEQ_SEDEPOBAL.NEXTVAL, SE.ACCTNO, SE.TBALDT, v_EOMDATE- nvl (SE.TBALDT,v_CURRDATE)+1,
        (se.trade + se.margin + se.mortage + se.blocked + se.secured + se.repo + se.netting + se.dtoclose + se.withdraw+se.emkqtty+se.blockwithdraw+se.blockdtoclose), 'N',
         nvl(REC.FEEACR,0),
         REC.TYPE,REC.Ref,REC.FEEAMT,REC.LOTDAY,REC.LOTVAL,REC.FORP,'BATCH',REC.USED,
         (CASE WHEN REC.SECTYPE IN ('001','002','007','008') THEN V_VSDDEPOFEE_111
      --Ngay 22/03/2017 CW NamTv them sectype chung quyen
            WHEN REC.SECTYPE IN ('011') THEN V_VSDDEPOFEE_011
      --NamTv End
         WHEN REC.SECTYPE IN ('003','006') THEN V_VSDDEPOFEE_222 ELSE 0 END ), nvl(re.reacctno,'') reacctno, nvl(re.reacctnord,'') reacctnord
      FROM SEMAST SE, afmast af, (SELECT rl.afacctno, CASE WHEN ret.rerole = 'RD' THEN rl.reacctno ELSE ' ' END reacctnord,
                        CASE WHEN ret.rerole IN ('RM', 'CS') THEN rl.reacctno ELSE ' ' END reacctno, rl.frdate, nvl(rl.clstxdate, rl.todate) todate FROM
                        reaflnk rl, remast re, retype ret
                     WHERE rl.reacctno = re.acctno
                        AND re.actype = ret.actype  and rl.status = 'A'
                        AND ret.rerole IN ('RM' ,'CS' ,'RD')) re
         WHERE se.acctno=rec.acctno
         AND  nvl(SE.TBALDT,v_CURRDATE)<=v_EOMDATE
         AND se.afacctno = af.acctno
        AND af.custid = re.afacctno(+)
        AND nvl(re.frdate,v_CURRDATE) <= v_CURRDATE
        AND nvl(re.todate,v_currdate) >= v_currdate;

      end loop;
      --MARK TO SEMAST
      UPDATE SEMAST SET TBALDT=v_EOMDATE+1;

      --1.2: CHUYEN PHI LUU KY DEN HAN
      SELECT TRUNC(v_CURRDATE, 'MM') INTO v_BOMDATE FROM DUAL;
      INSERT INTO CIFEESCHD (AUTOID, AFACCTNO, FEETYPE, TXDATE, TXNUM, NMLAMT, PAIDAMT, FLOATAMT, FRDATE, TODATE, REFACCTNO, DELTD)
      SELECT SEQ_CIFEESCHD.NEXTVAL, AFACCTNO, 'VSDDEP', v_EOMDATE, 'VSDDEP_DUE', round(CIDEPOFEEACR), 0, 0, v_BOMDATE, v_EOMDATE, NULL, 'N'
      FROM CIMAST WHERE CIDEPOFEEACR>0 AND nvl(DEPOLASTDT,v_CURRDATE)<v_EOMDATE;
/*      UPDATE CIMAST SET DEPOFEEAMT=DEPOFEEAMT+round(CIDEPOFEEACR), CIDEPOFEEACR=0, DEPOLASTDT=v_EOMDATE WHERE CIDEPOFEEACR>0 AND nvl(DEPOLASTDT,v_CURRDATE)<v_EOMDATE;*/
        UPDATE CIMAST SET DEPOFEEAMT=DEPOFEEAMT+round(CIDEPOFEEACR), CIDEPOFEEACR=0, DEPOLASTDT=v_EOMDATE ;

      --1.3: TINH CONG DON TU DAU THANG DEN NGAY HIEN TAI
        --INCREASE CIDEPOFEEACR IN CIMAST
/*      UPDATE CIMAST T1
      SET CIDEPOFEEACR = CIDEPOFEEACR + nvl((
        SELECT FEEACR
        FROM (
        SELECT A2.AFACCTNO,
          SUM(DECODE(A2.FORP,'P',A2.FEEAMT/100,A2.FEEAMT)*A2.SEBAL*(v_NEXTDATE-nvl (A2.TBALDT,v_CURRDATE))/(A2.LOTDAY*A2.LOTVAL)) FEEACR
        FROM (SELECT T.ACCTNO, MIN(T.ODRNUM) RFNUM FROM VW_SEMAST_VSDDEP_FEETERM T GROUP BY T.ACCTNO) A1,
        VW_SEMAST_VSDDEP_FEETERM A2 WHERE A1.ACCTNO=A2.ACCTNO AND A1.RFNUM=A2.ODRNUM GROUP BY A2.AFACCTNO) T2
        WHERE T1.AFACCTNO = T2.AFACCTNO),0);*/
      for rec in
      (
        SELECT A2.AFACCTNO,a2.acctno,
               round((v_NEXTDATE-nvl (A2.TBALDT,v_CURRDATE))*A2.AMT_TEMP,4) FEEACR,
               A2.AUTOID Ref, A2.TYPE,
               A2.FEEAMT,A2.LOTDAY,A2.LOTVAL,A2.FORP,
               (CASE WHEN A2.ODR=A3.ODR THEN 'Y' ELSE 'N' END ) USED,A2.SECTYPE
        FROM /*(SELECT T.ACCTNO, MIN(T.ODRNUM) RFNUM FROM VW_SEMAST_VSDDEP_FEETERM T GROUP BY T.ACCTNO) A1,*/
            (SELECT T.*,ROWNUM ODR
            FROM   (SELECT * FROM VW_SEMAST_VSDDEP_FEETERM T ORDER BY T.ACCTNO,T.ODRNUM, T.AMT_TEMP) T
            ) A2,
            (
            SELECT ACCTNO,MIN(ODR) ODR
            FROM
            (SELECT T.*,ROWNUM ODR
            FROM   (SELECT * FROM VW_SEMAST_VSDDEP_FEETERM T ORDER BY T.ACCTNO,T.ODRNUM, T.AMT_TEMP) T
            )
            GROUP BY ACCTNO
            )A3
         WHERE A2.ACCTNO=A3.ACCTNO
      )
      LOOP
        IF REC.USED='Y' THEN
           UPDATE CIMAST T1
                SET CIDEPOFEEACR = CIDEPOFEEACR + nvl(REC.FEEACR,0)
            where acctno = rec.afacctno;
        END IF;
         --LOG INTO SEDEPOBAL: UPTO NEXTDATE
      INSERT INTO SEDEPOBAL (AUTOID, ACCTNO, TXDATE, DAYS, QTTY, DELTD,amt,Type,Ref,FEEAMT,LOTDAY,LOTVAL,FORP,ID,USED,VSDFEEAMT, REACCTNO, REACCTNORD)
      SELECT SEQ_SEDEPOBAL.NEXTVAL, SE.ACCTNO, SE.TBALDT, v_NEXTDATE-nvl (SE.TBALDT,v_CURRDATE),
        (se.trade + se.margin + se.mortage + se.blocked + se.secured + se.repo + se.netting + se.dtoclose + se.withdraw+se.emkqtty+se.blockwithdraw+se.blockdtoclose), 'N',
         nvl(REC.FEEACR,0),
         REC.TYPE,REC.Ref,REC.FEEAMT,REC.LOTDAY,REC.LOTVAL,REC.FORP,'BATCH',REC.USED,
         (CASE WHEN REC.SECTYPE IN ('001','002','007','008') THEN V_VSDDEPOFEE_111
      --Ngay 22/03/2017 CW NamTv them sectype chung quyen
            WHEN REC.SECTYPE IN ('011') THEN V_VSDDEPOFEE_011
      --NamTv End
         WHEN REC.SECTYPE IN ('003','006') THEN V_VSDDEPOFEE_222 ELSE 0 END ), nvl(re.reacctno,'') reacctno, nvl(re.reacctnord,'') reacctnord
      FROM SEMAST SE, afmast af, (SELECT rl.afacctno, CASE WHEN ret.rerole = 'RD' THEN rl.reacctno ELSE ' ' END reacctnord,
                        CASE WHEN ret.rerole IN ('RM', 'CS') THEN rl.reacctno ELSE ' ' END reacctno, rl.frdate, nvl(rl.clstxdate, rl.todate) todate FROM
                        reaflnk rl, remast re, retype ret
                     WHERE rl.reacctno = re.acctno
                        AND re.actype = ret.actype and rl.status = 'A'
                        AND ret.rerole IN ('RM' ,'CS' ,'RD')) re
        WHERE se.acctno=rec.acctno
        AND  nvl (TBALDT,v_currdate)<v_NEXTDATE
         AND se.afacctno = af.acctno
        AND af.custid = re.afacctno(+)
        AND nvl(re.frdate,v_CURRDATE) <= v_CURRDATE
        AND nvl(re.todate,v_currdate) >= v_currdate;
      end loop;
      --MARK TO SEMAST
      UPDATE SEMAST SET TBALDT=v_NEXTDATE;
    END;
  END IF;

  --?A C?C BI?U THAM S? ?N NG?Y HI?U L?C V?O HO?T ?NG (BI?U PH?TUONG T? S? H?T H?N-FEETYPE/CODEID/EXCHANGE/SECTYPE)
  --?A C?C BI?U THAM S? ?N NG?Y HI?U L?C V?O HO?T ?NG (BI?U PH?TUONG T? S? H?T H?N-FEETYPE/CODEID/EXCHANGE/SECTYPE)
  -- update cac bieu phi co ngay hieu luc la nextdate

      FOR REC IN (
      SELECT * FROM CIFEEDEF WHERE VALDATE= v_NEXTDATE AND STATUS='P'
      )
      LOOP
        UPDATE CIFEEDEF SET STATUS='C' WHERE FEETYPE=REC.FEETYPE  AND ACTYPE=REC.ACTYPE
         AND NVL(CODEID,'A')=NVL(REC.CODEID,'A') AND TRADEPLACE=REC.TRADEPLACE
         AND SECTYPE=REC.SECTYPE AND STATUS='A' ;
        UPDATE CIFEEDEF SET STATUS='A' WHERE AUTOID=REC.AUTOID;

      END LOOP;
      -- update cac dong het han trong cifeedef_ext_lnk
      FOR REC IN (
                 Select dtl.*
                 From CIFEEDEF_EXTLNK dtl, CIFEEDEF_EXT hdr
                 Where dtl.actype=hdr.actype
                 and hdr.VALDATE= v_NEXTDATE AND dtl.STATUS='P'
      )
      LOOP
        UPDATE CIFEEDEF_EXTLNK SET STATUS='C' WHERE ACTYPE=REC.ACTYPE
           AND AFACCTNO=REC.AFACCTNO AND STATUS='A' ;
        UPDATE CIFEEDEF_EXTLNK SET STATUS='A' WHERE ACTYPE=REC.AUTOID;
      END LOOP;
       -- update cac dong het han trong cifeedef_ext_lnk
      FOR REC IN (
                 Select dtl.*
                 From CIFEEDEF_EXTLNK dtl, CIFEEDEF_EXT hdr
                 Where dtl.actype=hdr.actype
                 and hdr.EXPDATE < v_NEXTDATE AND dtl.STATUS='A'
      )
      LOOP
        UPDATE CIFEEDEF_EXTLNK SET STATUS='C' WHERE ACTYPE=REC.ACTYPE
           AND AFACCTNO=REC.AFACCTNO AND STATUS='A' ;
      END LOOP;
  -- backup nhung dong used='N' trong SEDEPOBAL sang bang Hist
  INSERT INTO SEDEPOBAL_HIST SELECT * FROM SEDEPOBAL WHERE USED='N';
  DELETE FROM SEDEPOBAL WHERE USED='N';
  COMMIT;
EXCEPTION
   WHEN OTHERS THEN
        BEGIN
            raise;
            return;
        END;
END;
 
/
