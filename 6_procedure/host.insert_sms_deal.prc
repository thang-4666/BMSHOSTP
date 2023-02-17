SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "INSERT_SMS_DEAL"
(
       CUSTODYCD IN VARCHAR2,
       DEALACCTNO IN VARCHAR2,
       QTTY IN NUMBER,
       SYMBOL IN VARCHAR2,
       AMT IN NUMBER,
       TXDATE IN VARCHAR2,
       SMSTYPE IN VARCHAR2,
       V_ERRCODE IN OUT NUMBER
)
IS
-- HUNG.LB 29-09-2010 Rel 6.3
-- Duoc goi khi end-user an vao send SMS button tren man hinh theo doi deal
-- Note: So dt lien lac duoc hard-coded trong truong trinh
-- Gia tri hien tai: 08 1234567
	v_phone VARCHAR2(15);
	v_err varchar2(100);
	v_count number(10);
	v_currdate varchar2(10);
	v_afacctno varchar2(10);
BEGIN
	v_count := 0;
	V_ERRCODE := 0;

	BEGIN
		SELECT afacctno INTO v_afacctno FROM dfmast WHERE acctno = DEALACCTNO;
	EXCEPTION
	WHEN no_data_found THEN
		V_ERRCODE:=-100095;
		RETURN;

	END;

	BEGIN
		SELECT SUBSTR (mobilesms,1,15) INTO v_phone FROM afmast af, cfmast cf WHERE cf.custid = af.custid and acctno = v_afacctno AND SUBSTR(mobilesms,1,1) = '0';
	EXCEPTION
	WHEN no_data_found THEN
		V_ERRCODE:=-100095;
		RETURN;
	END;

	BEGIN
  		select sysvar.varvalue into v_currdate from sysvar where varname = 'CURRDATE' and sysvar.grname = 'SYSTEM';
	EXCEPTION
	WHEN no_data_found THEN
		V_ERRCODE:=-100095;
		RETURN;
	END;


	IF SMSTYPE = 'TRIGGER' THEN

		INSERT INTO smslog(autoid,refid,reftype,phonenumber,message,createddt,status,txdate,sendnumber,runmod)
		VALUES (seq_smslog.nextval ,DEALACCTNO,SMSTYPE,v_phone,
		'SBS:TK ' || CUSTODYCD ||' co deal ' || DEALACCTNO ||'.'
		||QTTY||'.'||SYMBOL||' vay '|| AMT || ' cham trigger tu ngay '|| txdate ||
		'.Vui long lien he 0862686868 de duoc tu van',
		SYSTIMESTAMP,'P',to_date(v_currdate,'DD/MM/RRRR'),0,'A');

		select count(1) into v_count from emailsmslog e where e.acctno =  DEALACCTNO and e.reportname = 'DF1003';

		--Update so lan gui sms

		if v_count = 0 then
			INSERT INTO emailsmslog(txdate, txtime, acctno, reportname, smscount)
			VALUES(TO_DATE(v_currdate,'DD/MM/RRRR'), to_char(sysdate,'hh24:mm:ss'),DEALACCTNO, 'DF1003',1);
		else
			Update emailsmslog set smscount = smscount + 1 where acctno = DEALACCTNO and reportname = 'DF1003';
		end if;

	ELSIF SMSTYPE = 'OVERDUE' THEN

		INSERT INTO smslog(autoid,refid,reftype,phonenumber,message,createddt,status,txdate,sendnumber,runmod)
		VALUES (seq_smslog.nextval,DEALACCTNO,SMSTYPE,v_phone,
		'SBS:TK ' || CUSTODYCD ||' co deal ' || DEALACCTNO ||'.'
		||QTTY||'.'||SYMBOL||' vay '|| AMT || ' da qua han tu ngay '|| txdate ||
		'.Vui long lien he 08-12345678 de duoc tu van',
		SYSTIMESTAMP,'P',to_date(v_currdate,'DD/MM/RRRR'),0,'A');

		--Update so lan gui sms
		select count(1) into v_count from emailsmslog e where e.acctno =  DEALACCTNO and e.reportname = 'DF1005';

		if v_count = 0 then
			INSERT INTO emailsmslog(txdate, txtime, acctno, reportname, smscount)
			VALUES(TO_DATE(v_currdate,'DD/MM/RRRR'), to_char(sysdate,'hh24:mm:ss'),DEALACCTNO, 'DF1005',1);
		else
			Update emailsmslog set smscount = smscount + 1 where acctno = DEALACCTNO and reportname = 'DF1005';
		end if;

	ELSIF SMSTYPE = 'DUE' THEN

		INSERT INTO smslog(autoid,refid,reftype,phonenumber,message,createddt,status,txdate,sendnumber,runmod)
		VALUES (seq_smslog.nextval,DEALACCTNO,SMSTYPE,v_phone,
		'SBS:TK ' || CUSTODYCD ||' co deal ' || DEALACCTNO ||'.'
		||QTTY||'.'||SYMBOL||' vay '|| AMT || ' da den han tu ngay '|| txdate ||
		'.Vui long lien he 08-12345678 de duoc tu van',
		SYSTIMESTAMP,'P',to_date(v_currdate,'DD/MM/RRRR'),0,'A');

		select count(1) into v_count from emailsmslog e where e.acctno =  DEALACCTNO and e.reportname = 'DF1004';

		if v_count = 0 then
			INSERT INTO emailsmslog(txdate, txtime, acctno, reportname, smscount)
			VALUES(TO_DATE(v_currdate,'DD/MM/RRRR'), to_char(sysdate,'hh24:mm:ss'),DEALACCTNO, 'DF1004',1);
		else
			Update emailsmslog set smscount = smscount + 1 where acctno = DEALACCTNO and reportname = 'DF1004';
		end if;

	END IF;
EXCEPTION  WHEN OTHERS THEN
  rollback;

      v_err  := SQLERRM;
       INSERT INTO log_err
                  (id,date_log, POSITION, text
                  )
           VALUES ( seq_log_err.NEXTVAL,SYSDATE, 'ERRSMS', v_err
                  );

  commit;
  V_ERRCODE := -100095;
  RETURN;
END ;

 
 
 
 
/
