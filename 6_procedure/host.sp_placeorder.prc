SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE sp_placeorder (
  v_afacctno in varchar,
  v_exectype in varchar,
  v_dfdealid in varchar,  --save to fomast.dfacctno
  v_symbol in varchar,
  v_pricetype in varchar,
  v_quoteprice  in float,
  v_orderqtty  in float,
  v_rqsid in varchar,
  v_errcode out integer) IS
  v_sequenceid integer;
  v_count integer;
  v_rqssrc varchar(3);
  v_rqstyp varchar(3);
  v_status varchar(3);
  v_book varchar(1);
  v_timetype varchar(1);
  v_clearcd varchar(1);
  v_clearday integer;
  v_nork varchar(1);
  v_codeid varchar(10);
  v_confirmedvia varchar(1);
  v_matchtype varchar(1);
  v_feedbackmsg varchar(250);
  v_price  float;
  v_triggerprice  float;
  v_fotype varchar(10);
  v_orderid varchar(50);
  v_currdate varchar(10);
  v_via varchar(1);
BEGIN
  --ki?m tra khong d??c trung rqsid
  SELECT COUNT(*) INTO v_count FROM BORQSLOG WHERE REQUESTID=v_rqsid;
  IF v_count<>0 THEN
    v_errcode:=-1;  --trung yeu c?u
  ELSE
    BEGIN
      --nh?n yeu c?u x? ly
      v_rqssrc:='ONL';
      v_rqstyp:='PLO';
      v_status:='A';  --do ch? log l?i ? day d? d?m b?o ch?ng g?i trung l?nh t? STrade.
      SELECT SEQ_BORQSLOG.NEXTVAL INTO v_sequenceid FROM DUAL;
      INSERT INTO BORQSLOG (AUTOID, CREATEDDT, RQSSRC, RQSTYP, REQUESTID, STATUS, TXDATE, TXNUM, ERRNUM, ERRMSG)
      SELECT v_sequenceid, SYSDATE, v_rqssrc, v_rqstyp, v_rqsid, v_status, null, null, 0, null FROM DUAL;

    --Ghi nh?n yeu c?u d?t l?nh vao FOMAST cho ph?n x? ly ti?n trinh t? d?ng c?a l?nh
    v_book:='A';    --l?nh la active luon (n?u cho phep d?t nhap thi tham s? nay s? ph?i d??c truy?n vao)
    v_timetype:='T';  --ch? nh?n l?nh trong ngay, n?u dung l?nh GTC (=g) thi ph?i d??c truy?n vao
    v_matchtype:='N';  --l?nh thong th??ng
    v_clearcd:='B';  --m?c d?nh la l?ch ngay lam vi?c
      --T2-Phuongntn
    --     v_clearday:=3;  --chu k? thanh toan la 3
    -- Mac dinh lay chu ky thanh toan tren sysvar
    select TO_NUMBER(VARVALUE) into v_clearday from sysvar where grname like 'SYSTEM' and varname='CLEARDAY' and rownum<=1;
    --End T2-Phuongntn

    v_via:='O';
    v_nork:='N';  --m?c d?nh la l?nh th??ng khong ph?i l?nh Fill or Kill
    v_confirmedvia:='N';
    v_status := 'P';  --tr?ng thai m?c d?nh c?a FOMAST
    v_price:=v_quoteprice;
    v_triggerprice:=0;
    v_feedbackmsg:='Order is received and pending to process';

    --xac d?nh codeid
    SELECT CODEID INTO v_codeid FROM SBSECURITIES WHERE SYMBOL=v_symbol;
    IF SQL%NOTFOUND THEN
    v_errcode:=-2;  --sai m? ch?ng khoan
    END IF;

    --ki?m tra tai kho?n co d??c phep s? d?ng d?t l?nh khong
    Begin
        SELECT ACTYPE INTO v_fotype FROM FOTYPE
        WHERE STATUS='A' AND NORK=v_nork AND (EXECTYPE= v_exectype OR EXECTYPE='AA')
            AND (PRICETYPE=v_pricetype OR PRICETYPE='AA') AND (MATCHTYPE=v_matchtype OR MATCHTYPE='A')
        AND ACTYPE IN (SELECT REGTYPE.ACTYPE FROM AFMAST AF, REGTYPE WHERE MODCODE='FO' AND AF.ACTYPE=REGTYPE.AFTYPE AND AF.ACCTNO=v_afacctno);
    exception when others then
        v_fotype:='';
    end;
    IF SQL%NOTFOUND THEN
    v_errcode:=-3;  --tai kho?n c?a khach hang ch?a d??c cai d?t s? d?ng d?ch v?
    END IF;

    --t?o s? hi?u l?nh
    SELECT RTRIM(VARVALUE) || LTRIM(TO_CHAR(SEQ_FOMAST.NEXTVAL,'0000000000')) INTO v_orderid
    FROM SYSVAR WHERE VARNAME='BUSDATE';
    SELECT VARVALUE INTO v_currdate FROM SYSVAR WHERE VARNAME='BUSDATE';

    --Ghi ra FOMAST
    INSERT INTO FOMAST (ACCTNO, ORGACCTNO, ACTYPE, AFACCTNO, STATUS, EXECTYPE, PRICETYPE, TIMETYPE,
    MATCHTYPE, NORK, CLEARCD, CODEID, SYMBOL, CONFIRMEDVIA, BOOK, FEEDBACKMSG, ACTIVATEDT, CREATEDDT,
    CLEARDAY, QUANTITY, PRICE, QUOTEPRICE, TRIGGERPRICE, EXECQTTY, EXECAMT, REMAINQTTY,
    VIA,EFFDATE, EXPDATE, USERNAME, DFACCTNO)
    VALUES (v_orderid,v_orderid,v_fotype,v_afacctno,v_status,v_exectype,v_pricetype,v_timetype,
    v_matchtype,v_nork,v_clearcd,v_codeid,v_symbol,v_confirmedvia,v_book,v_feedbackmsg,
    TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS'),TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS'),
    v_clearday,v_orderqtty,v_price,v_quoteprice,v_triggerprice,0,0,0,
    v_via,TO_DATE(v_currdate,'DD/MM/RRRR'),TO_DATE(v_currdate,'DD/MM/RRRR'),v_rqssrc,v_dfdealid);

      COMMIT;
    END;
  END IF;
END;

 
 
 
 
/
