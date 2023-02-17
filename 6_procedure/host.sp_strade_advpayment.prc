SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "SP_STRADE_ADVPAYMENT" (
  v_afacctno in varchar,
  v_issubacct in varchar,
  v_duedate in varchar,
  v_amt  in float,
  v_feeamt  in float,
  v_rqsid in varchar,
  v_errcode out integer) IS
  v_sequenceid integer;
  v_count integer;
  v_rqssrc varchar(3);
  v_rqstyp varchar(3);
  v_status varchar(3);
  v_subaccount varchar(20);
BEGIN
  --kiem tra khong duoc trung rqsid
  SELECT COUNT(*) INTO v_count FROM BORQSLOG WHERE REQUESTID=v_rqsid AND RQSTYP = 'ADV' and rqssrc='ONL';
  IF v_count<>0 THEN
    v_errcode:=-1;  --trung yeu cau
  ELSE
    BEGIN
    --kiem tra Custody Code hoac Sub-Account co ton tai khong
    IF v_issubacct='Y' THEN
      begin
        SELECT ACCTNO INTO v_subaccount FROM AFMAST WHERE ACCTNO=v_afacctno;
      exception
      when others then
        v_errcode:=-3;  --khong thay subaccount
        return;
      end;
    ELSE
      begin
        SELECT AF.ACCTNO INTO v_subaccount FROM AFMAST AF, CFMAST CF WHERE CF.CUSTID=AF.CUSTID AND CF.TRADEONLINE='Y' AND CF.CUSTODYCD=v_afacctno;
      exception
      when others then
        v_errcode:=-3;  --khong thay subaccount
        return;
      end;
    END IF;

    --nhan yeu cau xu ly
    v_rqssrc:='ONL';
    v_rqstyp:='ADV';
    v_status:='P';
    SELECT SEQ_BORQSLOG.NEXTVAL INTO v_sequenceid FROM DUAL;
    INSERT INTO BORQSLOG (AUTOID, CREATEDDT, RQSSRC, RQSTYP, REQUESTID, STATUS, TXDATE, TXNUM, ERRNUM, ERRMSG)
    SELECT v_sequenceid, SYSDATE, v_rqssrc, v_rqstyp, v_rqsid, v_status, null, null, 0, null FROM DUAL;

    INSERT INTO BORQSLOGDTL (AUTOID, VARNAME, VARTYPE, CVALUE, NVALUE)
    VALUES (v_sequenceid, 'AFACCTNO', 'C', v_subaccount, 0);

    INSERT INTO BORQSLOGDTL (AUTOID, VARNAME, VARTYPE, CVALUE, NVALUE)
    VALUES (v_sequenceid, 'DUEDATE', 'D', v_duedate, 0);

    INSERT INTO BORQSLOGDTL (AUTOID, VARNAME, VARTYPE, CVALUE, NVALUE)
    VALUES (v_sequenceid, 'AMT', 'N', NULL, v_amt);

    INSERT INTO BORQSLOGDTL (AUTOID, VARNAME, VARTYPE, CVALUE, NVALUE)
    VALUES (v_sequenceid, 'FEEAMT', 'N', NULL, v_feeamt);

    v_errcode:=0;

    COMMIT;
    END;
  END IF;
END;

 
 
 
 
/
