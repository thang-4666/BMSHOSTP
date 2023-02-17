SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "SP_STRADE_CREDIT_BALANCE"
   ( p_bankacctno IN varchar2,
     p_refnum IN VARCHAR2,
	 p_acctno IN VARCHAR2,
	 p_issubacct IN VARCHAR2,
	 p_desc IN VARCHAR2,
	 p_amt IN NUMBER,
	 p_returnID IN OUT NUMBER,
	 p_errcode IN OUT VARCHAR2,
	 p_errdesc IN OUT VARCHAR2
	 )
   IS
--
-- To modify this template, edit file PROC.TXT in TEMPLATE
-- directory of SQL Navigator
--
-- Purpose: Briefly explain the functionality of the procedure
--
-- MODIFICATION HISTORY
-- Person      Date    Comments
-- ---------   ------  -------------------------------------------
   l_count                 number;
   l_afacctno			varchar2(30);
   l_custodycd			varchar2(30);
   l_txdate 			DATE;
   l_fileid				VARCHAR2(12);
   l_cashdepositid		NUMBER;
   l_bankid				varchar2(50);
   -- Declare program variables as shown above
BEGIN

	p_errcode:=0;
	p_errdesc:='Successfull!';
	SELECT to_date(varvalue,systemnums.c_date_format) INTO l_txdate FROM sysvar WHERE varname = 'CURRDATE' AND grname = 'SYSTEM';
	l_fileid:='000000000000';

	--CHECK p_bankacctno
	BEGIN
		SELECT shortname INTO l_bankid
		FROM banknostro WHERE replace(REPLACE(replace(bankacctno,'.',''),' ',''),'-','') = p_bankacctno;
	EXCEPTION
	WHEN no_data_found THEN
		p_errcode:= 1;
		p_errdesc:= 'ERROR: bankacctno is NOT found!';
		RETURN;
	WHEN OTHERS THEN
		p_errcode:= 1;
		p_errdesc:= 'ERROR: bankacctno is NOT found!';
		RETURN;
	END;

	--CHECK trung so chung tu ngan hang voi cung ngay, cung ngan hang.
	SELECT count(1) INTO l_count FROM
	(
		SELECT * FROM tblcashdeposit WHERE deltd <> 'Y'
		UNION ALL
		SELECT th.* FROM tblcashdeposithist th, sysvar s
		WHERE busdate = l_txdate AND deltd <> 'Y'
		AND s.grname = 'SYSTEM' AND s.varname = 'CURRDATE'
		AND th.txdate = to_date (s.varvalue,systemnums.c_date_format)
	)
	WHERE refnum = p_refnum
	AND bankid = l_bankid
	AND status = 'C';

	IF l_count <> 0 THEN
		p_errcode:= 1;
		p_errdesc:= 'ERROR: REFNUM has been already exists!';
		RETURN;
	END IF;

	--CHECK Acctno + IsSubAcct
	IF p_issubacct = 'Y' THEN
		l_afacctno:= p_acctno;
		BEGIN
		SELECT cf.custodycd INTO l_custodycd FROM afmast af, cfmast cf
		WHERE af.custid = cf.custid
		AND af.status NOT IN ('C','N')
		AND af.acctno = p_acctno;
		EXCEPTION
		WHEN no_data_found THEN
			p_errcode:= 1;
			p_errdesc:= 'ERROR: ACCTNO does not exists OR status is invalid!';
			RETURN;
		END;
	ELSE
		BEGIN
			SELECT acctno INTO l_afacctno
			FROM (
				SELECT af.acctno,cf.fullname FROM afmast af, cfmast cf
				WHERE af.custid = cf.custid
				AND af.status NOT IN ('C','N')
				AND cf.custodycd = p_acctno
				ORDER BY case WHEN af.status = 'A' AND cf.status = 'A' THEN 0
							WHEN af.status = 'A' THEN 0
							ELSE 1 END
			)
			WHERE ROWNUM = 1;
		EXCEPTION
		WHEN no_data_found THEN
			p_errcode:= 1;
			p_errdesc:= 'ERROR: ACCTNO does not exists OR status is invalid!';
			RETURN;
		END;
		l_custodycd:= p_acctno;
	END IF;
			dbms_output.put_line('1');
	--CHECK AMT
	IF p_amt <= 0 THEN
	   p_errcode:= 1;
	   p_errdesc:= 'ERROR: Amount must be greater than zero!';
	   RETURN;
	END IF;

	SELECT seq_tblcashdeposit.NEXTVAL INTO l_cashdepositid FROM dual;

	INSERT INTO tblcashdeposit (AUTOID,FILEID,BANKID,REFNUM,BUSDATE,CUSTODYCD,ACCTNO,AMT,DESCRIPTION,TXDATE,TLTXCD,TXNUM,STATUS,ERRORDESC,DELTD,LAST_CHANGE)
		VALUES
		(	l_cashdepositid,
			to_char(SYSDATE,'RRRRMMDD') || '0000',
			l_bankid,
			p_refnum,
			l_txdate,
			l_custodycd,
			l_afacctno,
			p_amt,
			p_desc,
			l_txdate,
			'1191',
			NULL,
			'P',
			NULL,
			'N',
			SYSTIMESTAMP);
	p_returnID:= l_cashdepositid;
EXCEPTION
    WHEN OTHERS THEN
	   p_errcode:= 2;
	   p_errdesc:= 'ERROR IN PROCESS: ' || SQLERRM;
	   ROLLBACK;
	   RETURN;
END; -- Procedure

 
 
 
 
/
