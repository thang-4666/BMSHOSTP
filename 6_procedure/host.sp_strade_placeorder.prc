SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE sp_strade_placeorder (
  v_afacctno in varchar,
  v_issubacct in varchar,
  v_exectype in varchar,
  v_dfdealid in varchar,  --save to fomast.dfacctno
  v_symbol in varchar,
  v_pricetype in varchar,
  v_quoteprice  in float,
  v_orderqtty  in float,
  v_rqsid in varchar,
  v_retorderid out varchar,
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
  v_splopt varchar(1);
  v_splval float;
  v_direct varchar(1);
  v_subaccount varchar(20);
  v_mainpricetype varchar(3);
  v_dealcodeid varchar2(6);
BEGIN
v_errcode:=0;
  --ki?m tra kh?du?c tr?ng rqsid
  SELECT COUNT(*) INTO v_count FROM BORQSLOG WHERE REQUESTID=v_rqsid AND rqssrc='ONL' AND rqstyp='PLO';
  IF v_count<>0 THEN
    v_errcode:=-3;  --tr?ng y?c?u
  ELSE
    BEGIN

  --ki?m tra Custody Code ho?c Sub-Account c?n t?i kh?
  IF v_issubacct='Y' THEN
    begin
      SELECT ACCTNO INTO v_subaccount FROM AFMAST WHERE ACCTNO=v_afacctno;
    exception
    when others then
      v_errcode:=202;  --kh?t?th?y subaccount
      return;
    end;
  ELSE
    begin
      SELECT AF.ACCTNO INTO v_subaccount FROM AFMAST AF, CFMAST CF WHERE CF.CUSTID=AF.CUSTID AND CF.TRADEONLINE='Y' and AF.STATUS <> 'C' AND CF.CUSTODYCD=v_afacctno;
    exception
    when others then
      v_errcode:=202;  --kh?t?th?y subaccount
      return;
    end;
  END IF;

  --kiem tra m?h?ng kho?
  begin
    SELECT CODEID INTO v_codeid FROM SBSECURITIES WHERE SYMBOL=v_symbol;
  exception
  when others then
    v_errcode:=204;  --sai m?h?ng kho?
    return;
  end;

    if v_exectype = 'MS' then
      begin
        SELECT CODEID INTO v_dealcodeid FROM dfmast WHERE acctno=v_dfdealid;
        if v_dealcodeid <> v_codeid then
            v_errcode:=223;  --khong trung codeid giua deal chon va lenh dat.
            return;
        end if;
      exception
      when others then
        v_errcode:=204;  --sai m?h?ng kho?
        return;
      end;
    end if;

    --nh?n y?c?u x? l?
    v_rqssrc:='ONL';
    v_rqstyp:='PLO';
    v_status:='A';  --do ch? log l?i ? d?d? d?m b?o ch?ng g?i tr?ng l?nh t? STrade.

    --Ghi nh?n y?c?u d?t l?nh v?FOMAST cho ph?n x? l? ti?n tr? t? d?ng c?a l?nh
    v_book:='A';    --l?nh l?ctive lu?n?u cho ph?d?t nh?th?ham s? n?s? ph?i du?c truy?n v?
    v_timetype:='T';  --ch? nh?n l?nh trong ng? n?u d?ng l?nh GTC (=g) th?h?i du?c truy?n v?
    v_matchtype:='N';  --l?nh th?thu?ng
    v_clearcd:='B';  --m?c d?nh l??ch ng?l?vi?c
    --T2-Phuongntn
    --     v_clearday:=3;  --chu k? thanh to?l?
    -- Mac dinh lay chu ky thanh toan tren sysvar
    select TO_NUMBER(VARVALUE) into v_clearday from sysvar where grname like 'SYSTEM' and varname='CLEARDAY' and rownum<=1;
    --End T2-Phuongntn
    v_via:='O';
    v_nork:='N';  --m?c d?nh l??nh thu?ng kh?ph?i l?nh Fill or Kill
    v_confirmedvia:='N';
    v_status := 'P';  --tr?ng th?m?c d?nh c?a FOMAST
    v_price:=v_quoteprice/1000;
    v_triggerprice:=0;
    v_splopt:='N';
    v_splval:=0;
    v_direct:='N';

    v_feedbackmsg:='Order is received and pending to process';

    --x?d?nh codeid
    begin
      SELECT CODEID INTO v_codeid FROM SBSECURITIES WHERE SYMBOL=v_symbol;
    exception
    when others then
      v_errcode:=204;  --sai m?h?ng kho?
      return;
    end;

    IF v_pricetype IS NULL THEN
    --v_errcode:=-4; -- thieu LO
    v_mainpricetype := 'LO';
    ELSE
      v_mainpricetype  := v_pricetype;
    END IF;
    --t?o s? hi?u l?nh
    SELECT RTRIM(VARVALUE) || LTRIM(TO_CHAR(SEQ_FOMAST.NEXTVAL,'0000000000')) INTO v_orderid
    FROM SYSVAR WHERE VARNAME='BUSDATE';
    SELECT VARVALUE INTO v_currdate FROM SYSVAR WHERE VARNAME='CURRDATE';

    --Ghi ra Log request
    SELECT SEQ_BORQSLOG.NEXTVAL INTO v_sequenceid FROM DUAL;
    INSERT INTO BORQSLOG (AUTOID, CREATEDDT, RQSSRC, RQSTYP, REQUESTID, STATUS, TXDATE, TXNUM, ERRNUM, ERRMSG)
    SELECT v_sequenceid, SYSDATE, v_rqssrc, v_rqstyp, v_rqsid, v_status, null, null, 0, null FROM DUAL;
    INSERT INTO BORQSLOGDTL (AUTOID, VARNAME, VARTYPE, CVALUE, NVALUE)
    VALUES (v_sequenceid, 'ORDERID', 'C', v_orderid, 0);

    --Ghi ra FOMAST
    INSERT INTO FOMAST (ACCTNO, ORGACCTNO, ACTYPE, AFACCTNO, STATUS, EXECTYPE, PRICETYPE, TIMETYPE,
    MATCHTYPE, NORK, CLEARCD, CODEID, SYMBOL, CONFIRMEDVIA, BOOK, FEEDBACKMSG, ACTIVATEDT, CREATEDDT,
    CLEARDAY, QUANTITY, PRICE, QUOTEPRICE, TRIGGERPRICE, EXECQTTY, EXECAMT, REMAINQTTY,
    VIA,EFFDATE, EXPDATE, USERNAME, DFACCTNO, SPLOPT, SPLVAL, DIRECT)
    VALUES (v_orderid,v_orderid,v_fotype,v_subaccount,v_status,v_exectype,v_mainpricetype,v_timetype,
    v_matchtype,v_nork,v_clearcd,v_codeid,v_symbol,v_confirmedvia,v_book,v_feedbackmsg,
    TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS'),TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS'),
    v_clearday,v_orderqtty,v_price,v_price,v_triggerprice,0,0,v_orderqtty,
    v_via,TO_DATE(v_currdate,'DD/MM/RRRR'),TO_DATE(v_currdate,'DD/MM/RRRR'),v_rqssrc,v_dfdealid,v_splopt,v_splval,v_direct);

    --tra ve so hieu lenh
    v_retorderid:=v_orderid;
    COMMIT;
    END;
  END IF;
END;

 
 
 
 
/
