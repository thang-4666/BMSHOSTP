SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "GENTRANSACTION1159" (pv_afacctno IN VARCHAR2,pv_TOODAMT in number,pv_TOAMT in number)
  IS
    v_tltxcd             VARCHAR2 (30);
    v_txnum              VARCHAR2 (30);
    v_txdate             VARCHAR2 (30);
    v_tlid               VARCHAR2 (30);
    v_brid               VARCHAR2 (30);
    v_ipaddress          VARCHAR2 (30);
    v_wsname             VARCHAR2 (30);
    v_txtime             VARCHAR2 (30);
    v_txdesc             VARCHAR2 (300);

    v_afacctno  VARCHAR2(20);
    v_TOODAMT number(20,0);
    v_TOAMT number(20,0);
    v_dblAmt number(20,0);
BEGIN
    --0 lay cac tham so
    v_brid := '0000';
    v_tlid := '0000';
    v_ipaddress := 'HOST';
    v_wsname := 'HOST';
    v_tltxcd := '1159';

    v_afacctno:=pv_afacctno;
    v_TOODAMT:=pv_TOODAMT;
    v_TOAMT:=pv_TOAMT;
    --Lay TXNUM
    SELECT    '8000'
                  || SUBSTR ('000000' || seq_batchtxnum.NEXTVAL,
                             LENGTH ('000000' || seq_batchtxnum.NEXTVAL) - 5,
                             6
                            )
             INTO v_txnum
             FROM DUAL;
    --Lay TXtime
    SELECT TO_CHAR (SYSDATE, 'HH24:MI:SS')
              INTO v_txtime
              FROM DUAL;
    --lAY TXDATE
    SELECT varvalue
                INTO v_txdate
                FROM sysvar
               WHERE grname = 'SYSTEM' AND varname = 'CURRDATE';
    --txdesc
    v_txdesc:='Tinh toan vay bao lanh va thu hoi han muc';

    --1.TLLOG
    INSERT INTO tllog
            (autoid, txnum,
             txdate, txtime, brid,
             tlid, offid, ovrrqs, chid, chkid, tltxcd, ibt, brid2, tlid2,
             ccyusage, txstatus, msgacct, msgamt, chktime, offtime, off_line,
             deltd, brdate,
             busdate, msgsts, ovrsts, ipaddress, wsname,
             batchname, carebygrp, txdesc
            )
     VALUES (seq_tllog.NEXTVAL, v_txnum,
             TO_DATE (v_txdate, 'dd/MM/yyyy'), v_txtime, v_brid,
             v_tlid, '', '', '', '', v_tltxcd, '', '', '',
             '00', '1', v_afacctno, v_TOODAMT, '', '', 'N',
             'N', TO_DATE (v_txdate, 'dd/MM/yyyy'),
             TO_DATE (v_txdate, 'dd/MM/yyyy'), '0', '0', v_ipaddress, v_wsname,
             'DAY', '', v_txdesc
            );

    --2.TLLOGFLD
    --Hien tai dang off, khong cho gen vao tllogfld nua

    --3.AFTRAN
    --Thuc hien tran ghi giam AF.ADVANCELINE bang v_TOODAMT+v_TOAMT
    INSERT INTO aftran
            (acctno, txnum,txdate, txcd, namt, camt, REF,deltd, autoid)
     VALUES (v_afacctno, v_txnum,TO_DATE (v_txdate, 'dd/MM/yyyy'), '0022', v_TOODAMT+v_TOAMT, '', '','N', seq_aftran.NEXTVAL);
    --Thuc hien tran ghi tang AF.TOAMT bang v_TOAMT
    INSERT INTO aftran
            (acctno, txnum,txdate, txcd, namt, camt, REF,deltd, autoid)
     VALUES (v_afacctno, v_txnum,TO_DATE (v_txdate, 'dd/MM/yyyy'), '0021', v_TOAMT, '', '','N', seq_aftran.NEXTVAL);
    --4.CITRAN
    INSERT INTO citran
            (acctno, txnum,txdate, txcd, namt, camt, REF,deltd, autoid)
     VALUES (v_afacctno, v_txnum,TO_DATE (v_txdate, 'dd/MM/yyyy'), '0061', v_TOODAMT, '', '','N', seq_citran.NEXTVAL);
     --5.Cap nhat lai AFMAST, CIMASt
     UPDATE AFMAST SET ADVANCELINE =ADVANCELINE-v_TOODAMT-v_TOAMT, T0AMT=T0AMT+v_TOAMT WHERE ACCTNO =v_afacctno;
     UPDATE CIMAST SET T0ODAMT=T0ODAMT+v_TOODAMT WHERE ACCTNO =v_afacctno;

     -- 29-07-2010 - TruongLD Comment lai ko tu dong thu hoi BL nua
    /* -- Thu hoi han muc T0 cap trong ngay, cap sau thu hoi truoc
    IF v_TOAMT > 0 THEN
        FOR REC IN
            (SELECT AUTOID, TLID, TYPEALLOCATE, ALLOCATEDLIMIT - RETRIEVEDLIMIT AMT FROM T0LIMITSCHD
               WHERE ACCTNO = v_afacctno AND ALLOCATEDDATE = TO_DATE (v_txdate, 'dd/MM/yyyy') AND ALLOCATEDLIMIT - RETRIEVEDLIMIT > 0
               ORDER BY AUTOID DESC)
        LOOP
            IF v_TOAMT > 0 THEN
                  IF v_TOAMT > REC.AMT THEN
                      v_dblAmt := REC.AMT;
                  ELSE
                      v_dblAmt := v_TOAMT;
                  END IF;
                  v_TOAMT := v_TOAMT - v_dblAmt;
                  UPDATE T0LIMITSCHD SET RETRIEVEDLIMIT = RETRIEVEDLIMIT + v_dblAmt WHERE AUTOID = REC.AUTOID;
                  UPDATE USERAFLIMIT SET ACCLIMIT = ACCLIMIT - v_dblAmt
                  WHERE ACCTNO = v_afacctno AND TLIDUSER = REC.TLID AND TYPERECEIVE = 'T0';
                  INSERT INTO USERAFLIMITLOG (TXNUM,TXDATE,ACCTNO,ACCLIMIT,TLIDUSER,TYPEALLOCATE,TYPERECEIVE)
                  VALUES (v_txnum,TO_DATE (v_txdate, 'dd/MM/yyyy'),v_afacctno,-v_dblAmt,REC.TLID,REC.TYPEALLOCATE,'T0');
            END IF;
        END LOOP;
    END IF;*/

EXCEPTION
    WHEN others THEN
        return;
END;

 
 
 
 
/
