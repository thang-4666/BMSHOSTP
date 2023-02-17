SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "SP_CANCELORDER" (
  v_cancelorderid in varchar,
  v_rqsid in varchar,
  v_errcode out integer) IS
  v_sequenceid integer;
  v_count integer;
  v_rqssrc varchar(3);
  v_rqstyp varchar(3);
  v_status varchar(3);
  v_feedbackmsg varchar(250);
  v_currdate varchar(10);
  v_process integer;
  v_orderid varchar(50);
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

    --h?y l?nh inactive
    DELETE FROM FOMAST WHERE BOOK='I' AND ACCTNO=v_cancelorderid;

    --n?u l?nh la active nh?ng v?n dang pending thi ch? d?i tr?ng thai FOMAST
    v_process:=0;
    v_feedbackmsg:='Order is cancelled when processing';
  SELECT count(*) INTO v_count FROM FOMAST WHERE BOOK='A' AND ORGACCTNO=v_cancelorderid AND EXECTYPE IN ('NB','NS');

    --X? ly h?y l?nh
    IF v_count=0 THEN
        --l?nh nh?p tr?c ti?p vao ODMAST trong h? th?ng: Ph?i t?o l?nh h?y
        v_process:=1;
    ELSE
    BEGIN
      SELECT STATUS INTO v_status FROM FOMAST WHERE BOOK='A' AND ORGACCTNO=v_cancelorderid AND EXECTYPE IN ('NB','NS');
      IF v_status='P' THEN
        UPDATE FOMAST SET STATUS='R',FEEDBACKMSG=v_feedbackmsg WHERE BOOK='A' AND ACCTNO=v_cancelorderid AND STATUS='P';
      ELSE
        --Ph?i t?o l?nh h?y
        v_process:=1;
      END IF;
    END;
    END IF;

    IF v_process=1 THEN
    BEGIN
        --t?o s? hi?u l?nh
        SELECT RTRIM(VARVALUE) || LTRIM(TO_CHAR(SEQ_FOMAST.NEXTVAL,'0000000000')) INTO v_orderid
        FROM SYSVAR WHERE VARNAME='BUSDATE';
        SELECT VARVALUE INTO v_currdate FROM SYSVAR WHERE VARNAME='BUSDATE';
      --t?o l?nh h?y
      INSERT INTO FOMAST (ACCTNO, ORGACCTNO, ACTYPE, AFACCTNO, STATUS, EXECTYPE, PRICETYPE,
          TIMETYPE, MATCHTYPE, NORK, CLEARCD, CODEID, SYMBOL, CONFIRMEDVIA, BOOK, FEEDBACKMSG,
          ACTIVATEDT, CREATEDDT, CLEARDAY, QUANTITY, PRICE, QUOTEPRICE, TRIGGERPRICE, EXECQTTY,
          EXECAMT, REMAINQTTY, REFACCTNO,  REFQUANTITY, REFPRICE, REFQUOTEPRICE,VIA,EFFDATE, EXPDATE,USERNAME)
      SELECT v_orderid, od.orderid ORGACCTNO, od.ACTYPE, od.AFACCTNO, 'P',
        (CASE WHEN od.EXECTYPE='NB' OR od.EXECTYPE='CB' OR od.EXECTYPE='AB' THEN 'CB' ELSE 'CS' END) CANCEL_EXECTYPE,
        od.PRICETYPE, od.TIMETYPE, od.MATCHTYPE, od.NORK, od.CLEARCD, od.CODEID, sb.SYMBOL,
        'O' CONFIRMEDVIA, 'A' BOOK, v_feedbackmsg, TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS'), TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS'),
        od.CLEARDAY,od.exqtty QUANTITY, (od.exprice/1000) PRICE, (od.QUOTEPRICE/1000) QUOTEPRICE, 0 TRIGGERPRICE, od.EXECQTTY, od.EXECAMT,
        od.REMAINQTTY, od.orderid REFACCTNO, 0 REFQUANTITY, 0 REFPRICE, (od.QUOTEPRICE/1000) REFQUOTEPRICE,'O' VIA,
        TO_DATE(v_currdate,'DD/MM/RRRR') EFFDATE,TO_DATE(v_currdate,'DD/MM/RRRR') EXPDATE, v_rqssrc USERNAME
      FROM ODMAST od, sbsecurities sb
        WHERE orstatus IN ('1','2','4','8') AND orderid=v_cancelorderid and sb.codeid = od.codeid
        and orderid not in (select REFACCTNO from fomast WHERE EXECTYPE IN ('CB','CS') AND STATUS <>'R');
    END;
    END IF;
      COMMIT;
    END;
  END IF;
END;

 
 
 
 
/
