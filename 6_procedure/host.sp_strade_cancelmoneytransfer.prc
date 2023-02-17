SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "SP_STRADE_CANCELMONEYTRANSFER" (
  v_cancelid in varchar,
  v_rqsid in varchar,
  v_errcode out integer) IS
  v_sequenceid integer;
  v_count integer;
  v_rqssrc varchar(3);
  v_rqstyp varchar(3);
  v_status varchar(3);
  v_txdate varchar(20);
  v_txnum varchar(10);
  v_timeallow NUMBER;
  v_tltxcd varchar2(4);
  v_rmstatus varchar2(10);
  v_errmsg varchar2(3000);
BEGIN
  --Kiem tra thoi gian cho phep thuc hien chuyen tien.
  SELECT  CASE
      WHEN to_date(to_char(SYSDATE,'hh24:mi:ss'),'hh24:mi:ss') >= to_date(var1.varvalue,'hh24:mi:ss')
        AND to_date(to_char(SYSDATE,'hh24:mi:ss'),'hh24:mi:ss') <= to_date(var2.varvalue,'hh24:mi:ss') THEN
          1
        ELSE 0
      END INTO v_timeallow FROM sysvar var1, sysvar var2
  WHERE var1.grname = 'STRADE' and var1.varname = 'MT_FRTIME'
  AND var2.grname = 'STRADE' and var2.varname = 'MT_TOTIME';
  if v_timeallow = 0 then
    v_errcode:=-4;  --nam ngoai thoi gian cho phep thuc hien chuyen tien qua strade.
    return;
  end if;
  --Kiem tra khong duoc trung rqsid
  SELECT COUNT(1) INTO v_count FROM BORQSLOG WHERE REQUESTID=v_rqsid AND rqstyp='TRF' AND rqssrc='ONL';
  IF v_count<>0 THEN
    v_errcode:=-1;  --trung yeu cau
  ELSE
    BEGIN
        -- Tu cancelid (REQUESTID) xet cho phep thuc hien revert:
        BEGIN
            SELECT t.tltxcd, t.txnum, t.txdate INTO v_tltxcd, v_txnum, v_txdate FROM tllog t, borqslog b WHERE t.txnum = b.txnum AND t.txdate = b.txdate AND b.requestid = v_cancelid;
        EXCEPTION
        WHEN OTHERS THEN
            v_errcode:= -2; -- Khong tim thay giao dich goc.
            RETURN;
        END;


        IF v_tltxcd = '1101' THEN -- Neu la chuyen tien ra ngoai he thong.
            BEGIN
                SELECT rmstatus INTO v_rmstatus FROM CIREMITTANCE WHERE txdate = to_date(v_txdate,'DD/MM/RRRR') AND txnum = v_txnum;
                IF v_rmstatus = 'C' THEN
                    v_errcode:= -5; -- Giao dich da Completed. Khong the thuc hien revert.
                    RETURN;
                END IF;
            EXCEPTION
            WHEN OTHERS THEN
                v_errcode:= -3; -- Khong tim thay CIREMITTANCE.
                RETURN;
            END;
	ELSIF v_tltxcd = '1120' THEN -- Neu la chuyen tien noi bo
            v_errcode:= -5; -- Giao dich da Completed. Khong the thuc hien revert.
            return;
        END IF;
      --nhan yeu cau xu ly
      v_rqssrc:='ONL';
      v_rqstyp:='TRF';
      v_status:='P';

      --XU LY YEU CAU REVERT CHUYEN TIEN: 1120 OR 1101

        txpks_auto.pr_RevertTransfer(v_tltxcd, v_txdate, v_txnum, v_errcode);

      --XU LY LOI
      IF v_errcode=0 THEN
        v_status:='A';
      ELSE
        BEGIN
            SELECT ERRDESC INTO v_errmsg FROM DEFERROR WHERE ERRNUM=v_errcode;
        EXCEPTION
        WHEN OTHERS THEN
			v_errcode:= -10;
            v_errmsg:='UNDEFINED ERROR';
        END;
        v_status:='E';
      END IF;

      SELECT SEQ_BORQSLOG.NEXTVAL INTO v_sequenceid FROM DUAL;
      INSERT INTO BORQSLOG (AUTOID, CREATEDDT, RQSSRC, RQSTYP, REQUESTID, STATUS, TXDATE, TXNUM, ERRNUM, ERRMSG)
      SELECT v_sequenceid, SYSDATE, v_rqssrc, v_rqstyp, v_rqsid, v_status, TO_DATE(v_txdate,'DD/MM/RRRR'), v_txnum, v_errcode, v_errmsg FROM DUAL;

      INSERT INTO BORQSLOGDTL (AUTOID, VARNAME, VARTYPE, CVALUE, NVALUE)
      VALUES (v_sequenceid, 'TXNUM', 'C', v_txnum, 0);

      INSERT INTO BORQSLOGDTL (AUTOID, VARNAME, VARTYPE, CVALUE, NVALUE)
      VALUES (v_sequenceid, 'TXDATE', 'C', v_txdate, 0);

      COMMIT;
    END;
  END IF;
END;

 
 
 
 
/
