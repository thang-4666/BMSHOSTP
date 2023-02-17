SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "SP_STRADE_MONEYTRANSFER" (
  v_afacctno in varchar,
  v_issubacct in varchar,
  v_amt  in float,
  v_refid  in integer,
  v_trfdesc in varchar,
  v_rqsid in varchar,
  v_errcode out integer) IS
  v_sequenceid integer;
  v_count integer;
  v_rqssrc varchar(3);
  v_rqstyp varchar(3);
  v_status varchar(3);
  v_custodycd varchar(20);
  v_subaccount varchar(20);
  v_tociacctno varchar(50);
  v_tocustid varchar(50);
  v_destination varchar(50);
  v_feecd varchar(50);
  v_errmsg varchar(250);
  v_txdate varchar(20);
  v_txnum varchar(10);
  v_timeallow NUMBER;
  p_benefbank varchar(250);
  p_benefacct varchar(250);
  p_benefcustname varchar(250);
  p_beneflicense varchar(250);
  p_trf_iore varchar(1);
  p_fee_forp varchar(1);
  p_fee_vat float;
  p_fee_rate    float;
  p_fee_amt     float;
  p_fee_min     float;
  p_fee_max     float;
  p_feeamt  float;
  p_vatamt  float;
  p_trfamt  float;
BEGIN
v_errcode:=0;
  --Kiem tra thoi gian cho phep thuc hien chuyen tien.
    SELECT CASE WHEN max(case WHEN grname = 'SYSTEM' AND varname = 'HOSTATUS' THEN varvalue END) = 1
        AND to_date(to_char(SYSDATE,'hh24:mi:ss'),'hh24:mi:ss') >= to_date(max(case WHEN grname = 'STRADE' AND varname = 'MT_FRTIME' THEN varvalue END),'hh24:mi:ss')
        AND to_date(to_char(SYSDATE,'hh24:mi:ss'),'hh24:mi:ss') <= to_date(max(case WHEN grname = 'STRADE' AND varname = 'MT_TOTIME' THEN varvalue END),'hh24:mi:ss')
        THEN 1 ELSE 0 end
        INTO v_timeallow
    FROM sysvar;
  if v_timeallow = 0 then
    v_errcode:=306;  --nam ngoai thoi gian cho phep thuc hien chuyen tien qua strade.
    return;
  end if;
  --Kiem tra khong duoc trung rqsid
  SELECT COUNT(*) INTO v_count FROM BORQSLOG WHERE REQUESTID=v_rqsid AND rqssrc='ONL' and rqstyp='TRF';
  IF v_count<>0 THEN
    v_errcode:=-3;  --trung yeu cau
  ELSE
    BEGIN
  --kiem tra Custody Code hoac Sub-Account co ton tai khong
  IF v_issubacct='Y' THEN
    begin
    SELECT AFMAST.ACCTNO, CFMAST.CUSTODYCD INTO v_subaccount, v_custodycd FROM AFMAST, CFMAST WHERE AFMAST.CUSTID=CFMAST.CUSTID and AFMAST.STATUS <> 'C' AND AFMAST.ACCTNO=v_afacctno;
    exception
    when others then
         v_errcode:=307;  --khong thay subaccount
         return;
    end;
  ELSE
    v_custodycd:=v_afacctno;
    SELECT count(1) INTO v_count FROM AFMAST AF, CFMAST CF WHERE CF.CUSTID=AF.CUSTID and AF.STATUS <> 'C' AND CF.TRADEONLINE='Y' AND CF.CUSTODYCD=v_afacctno;
    if v_count > 1 then
      v_errcode:=308;  --Khai bao nhieu tai khoan dang ki online tren cung 1 ma luu ky chung khoan
      return;
    end if;
    BEGIN
    SELECT AF.ACCTNO INTO v_subaccount FROM AFMAST AF, CFMAST CF WHERE CF.CUSTID=AF.CUSTID and AF.STATUS <> 'C' AND CF.TRADEONLINE='Y' AND CF.CUSTODYCD=v_afacctno;
    EXCEPTION
    WHEN no_data_found THEN
      v_errcode:=307;  --khong thay subaccount
      RETURN;
    END;
  END IF;
      --nhan yeu cau xu ly
      v_rqssrc:='ONL';
      v_rqstyp:='TRF';
      v_status:='P';

      p_feeamt:=0;
      p_vatamt:=0;
      --XU LY YEU CAU CHUYEN TIEN: 1120 OR 1101
      SELECT CIACCOUNT, CUSTID, FEECD,bankname,bankacc,bankacname INTO v_tociacctno, v_tocustid, v_feecd, p_benefbank,p_benefacct,p_benefcustname    FROM CFOTHERACC WHERE AUTOID=v_refid;
      IF length(v_tociacctno)<>0 THEN
        p_trf_iore :='I';
        v_destination:=v_tociacctno;
      ELSE
        BEGIN
            p_trf_iore :='E';
            --tinh toan phi cho giao dich chuyen tien ra ben ngoai
            IF length(v_feecd)<>0 THEN
                SELECT FORP, FEEAMT, FEERATE, MINVAL, MAXVAL, VATRATE INTO p_fee_forp, p_fee_amt, p_fee_rate, p_fee_min, p_fee_max, p_fee_vat  FROM FEEMASTER WHERE FEECD=v_feecd;
                IF p_fee_forp='F' THEN
                    p_feeamt:=p_fee_amt;
                ELSE
                    p_feeamt:=v_amt*p_fee_rate/100;
                    IF p_feeamt < p_fee_min THEN
                        p_feeamt:=p_fee_min;
                    END IF;
                    IF p_feeamt > p_fee_max THEN
                        p_feeamt:=p_fee_max;
                    END IF;
                END IF;
                p_vatamt:=p_feeamt*p_fee_vat/100;
            END IF;
            --1101
            p_trfamt:=v_amt+p_feeamt+p_vatamt; --chuyen tien ra ben ngoai la thu phi ngoai
            v_destination:=v_tocustid;
        END;
      END IF;



      SELECT SEQ_BORQSLOG.NEXTVAL INTO v_sequenceid FROM DUAL;
      INSERT INTO BORQSLOG (AUTOID, CREATEDDT, RQSSRC, RQSTYP, REQUESTID, STATUS, TXDATE, TXNUM, ERRNUM, ERRMSG)
      SELECT v_sequenceid, SYSDATE, v_rqssrc, v_rqstyp, v_rqsid, v_status, TO_DATE(v_txdate,'DD/MM/RRRR'), v_txnum, v_errcode, v_errmsg FROM DUAL;

      INSERT INTO BORQSLOGDTL (AUTOID, VARNAME, VARTYPE, CVALUE, NVALUE)
      VALUES (v_sequenceid, 'AFACCTNO', 'C', v_subaccount, 0);

      INSERT INTO BORQSLOGDTL (AUTOID, VARNAME, VARTYPE, CVALUE, NVALUE)
      VALUES (v_sequenceid, 'CUSTODYCD', 'C', v_custodycd, 0);

      INSERT INTO BORQSLOGDTL (AUTOID, VARNAME, VARTYPE, CVALUE, NVALUE)
      VALUES (v_sequenceid, 'AMT', 'N', NULL, v_amt);

      INSERT INTO BORQSLOGDTL (AUTOID, VARNAME, VARTYPE, CVALUE, NVALUE)
      VALUES (v_sequenceid, 'FEEAMT', 'N', NULL, p_feeamt);

      INSERT INTO BORQSLOGDTL (AUTOID, VARNAME, VARTYPE, CVALUE, NVALUE)
      VALUES (v_sequenceid, 'REFID', 'N', 0, v_refid);

      INSERT INTO BORQSLOGDTL (AUTOID, VARNAME, VARTYPE, CVALUE, NVALUE)
      VALUES (v_sequenceid, 'TRFDESC', 'C', v_trfdesc, 0);

      INSERT INTO BORQSLOGDTL (AUTOID, VARNAME, VARTYPE, CVALUE, NVALUE)
      VALUES (v_sequenceid, 'TRFIORC', 'C', p_trf_iore, 0);

      INSERT INTO BORQSLOGDTL (AUTOID, VARNAME, VARTYPE, CVALUE, NVALUE)
      VALUES (v_sequenceid, 'TRFREFACCT', 'C', v_destination, 0);

    INSERT INTO BORQSLOGDTL (AUTOID, VARNAME, VARTYPE, CVALUE, NVALUE)
      VALUES (v_sequenceid, 'REFACCTNO', 'C', v_afacctno, 0);

    INSERT INTO BORQSLOGDTL (AUTOID, VARNAME, VARTYPE, CVALUE, NVALUE)
      VALUES (v_sequenceid, 'ISSUBACCT', 'C', v_issubacct, 0);

      COMMIT;
    END;
  END IF;
END;

 
 
 
 
/
