SET DEFINE OFF;
CREATE OR REPLACE FUNCTION sendordertocompany(indate IN VARCHAR2)
RETURN number
  IS
  V_INDATE VARCHAR2(10);
  --Cac bien
  v_lngErrCode number(20);
  v_blnOK Boolean;
  v_strTLTXCD varchar2(50);
  v_strEXECTYPE varchar2(50);
  v_strORGEXECTYPE varchar2(50);
  v_strOLDEXECTYPE varchar2(50);
  v_strCMDSQL varchar2(50);
  v_strVIA varchar2(50);
  v_strCLEARCD varchar2(50);
  v_strTIMETYPE varchar2(50);
  v_strPRICETYPE varchar2(50);
  v_strMATCHTYPE varchar2(50);
  v_strTRADEPLACE varchar2(50);
  v_strSECTYPE varchar2(50);
  v_strPARVALUE varchar2(50);
  v_strNORK varchar2(50);
  v_strTRADELOT varchar2(50);
  v_strTRADEUNIT varchar2(50);
  v_strAFACCTNO varchar2(50);
  v_strCODEID varchar2(50);
  v_strSYMBOL varchar2(50);
  v_strQUOTEPRICE varchar2(50);
  v_strQUANTITY varchar2(50);
  v_strACTYPE varchar2(50);
  v_strTXTIME varchar2(50);
  v_strCLEARDAY varchar2(50);
  v_strCUSTODYCD varchar2(50);
  v_strFULLNAME varchar2(50);
  mv_dblSecureBratioMin number(20);
  mv_dblSecureBratioMax number(20);
  mv_dblTyp_Bratio number(20);
  mv_dblAF_Bratio number(20);
  mv_dblFeeAmountMin number(20);
  mv_dblFeeRate number(20);
  mv_strACTYPE varchar2(50);
  v_dblSecureRatio number(20);
  v_dblFeeSecureRatioMin number(20);
  v_dblFeeAmout number(20);
  v_strOrderID varchar2(50);
  v_strORGACCTNO varchar2(50);
  v_strREFACCTNO varchar2(50);
  v_strREFQUANTITY varchar2(50);
  v_strREFPRICE varchar2(50);
  v_dblCeilPrice number(20);
  v_dblFloorPrice number(20);
  v_dblAdvanceSecuredAmount number(20);
  v_strTLID varchar2(50);
  v_strATCStartTime varchar2(50);
  v_strSystemTime varchar2(50);
  v_strMarketStatus varchar2(50);
  v_dblCountODtype number(20);
  v_dblCount number(20);
  v_strSendQuantity varchar2(50);
  v_strTXDESC varchar2(250);
  v_strTXDATE varchar2(50);
  v_strHoseBreakingSize varchar2(50);
  v_strSYSVAR varchar2(50);
  v_strTXNUM varchar2(50);
BEGIN
    V_INDATE:=indate;
    v_lngErrCode:=0;
    select VARVALUE into v_strTLID from sysvar where grname='SYSTEM' and varname='FOUSER';
    select VARVALUE into v_strTXDATE from sysvar where grname='SYSTEM' and varname='CURRDATE';
    select VARVALUE into v_strHoseBreakingSize from sysvar where grname='SYSTEM' and varname='HOSEBREAKSIZE';
    select VARVALUE into v_strATCStartTime from sysvar where grname='SYSTEM' and varname='ATCSTARTTIME';
    select VARVALUE into v_strSYSVAR from sysvar where grname='SYSTEM' and varname='HOSTATUS';
    If v_strSYSVAR <> '1' Then
        return -100000-23;
    end if;

    for rec in (
            SELECT MST.*,INF.CEILINGPRICE,INF.FLOORPRICE,SEC.TRADEPLACE,SEC.SECTYPE,SEC.PARVALUE,INF.TRADELOT,
            INF.TRADEUNIT,INF.SECUREDRATIOMIN,INF.SECUREDRATIOMAX
            FROM FOMAST MST,SBSECURITIES SEC,SECURITIES_INFO INF
            WHERE MST.BOOK='A' AND MST.TIMETYPE <> 'G' AND MST.STATUS='P'
            AND MST.CODEID=SEC.CODEID AND MST.CODEID=INF.CODEID
            )
    loop
        v_strVIA := rec.VIA;
        v_strCLEARCD := rec.CLEARCD;
        v_strTIMETYPE := rec.TIMETYPE;
        v_strPRICETYPE := rec.PRICETYPE;
        v_strMATCHTYPE := rec.MATCHTYPE;
        v_strTRADEPLACE := rec.TRADEPLACE;
        v_strSECTYPE := rec.SECTYPE;
        v_strPARVALUE := rec.PARVALUE;
        v_strNORK := rec.NORK;
        v_strTRADELOT := rec.TRADELOT;
        v_strTRADEUNIT := rec.TRADEUNIT;
        v_strAFACCTNO := rec.AFACCTNO;
        v_strCODEID := rec.CODEID;
        v_strSYMBOL := rec.SYMBOL;
        v_strQUOTEPRICE := rec.QUOTEPRICE;
        v_strQUANTITY := rec.QUANTITY;
        v_strEXECTYPE := rec.EXECTYPE;
        mv_dblSecureBratioMin := rec.SECUREDRATIOMIN;
        mv_dblSecureBratioMax := rec.SECUREDRATIOMAX;
        v_strORGACCTNO := rec.ORGACCTNO;
        v_strREFACCTNO := rec.REFACCTNO;
        v_strREFQUANTITY := rec.REFQUANTITY;
        v_strREFPRICE := rec.REFPRICE;
        v_dblCeilPrice := rec.CEILINGPRICE;
        v_dblFloorPrice := rec.FLOORPRICE;
        v_strORGEXECTYPE := v_strEXECTYPE;
        v_strOLDEXECTYPE := v_strEXECTYPE;

        if v_strEXECTYPE='NB' then
        	v_strTLTXCD := '8876';
			v_strEXECTYPE := 'NB';
        elsif v_strEXECTYPE in ('NS', 'MS', 'SS') then
            v_strTLTXCD := '8877';
            v_strEXECTYPE := v_strEXECTYPE;
        elsif v_strEXECTYPE= 'AB' then
            v_strTLTXCD := '8884';
            v_strEXECTYPE := 'NB';
        elsif v_strEXECTYPE= 'AS' then
            v_strTLTXCD := '8885';
        	v_strEXECTYPE := 'NS';
        elsif v_strEXECTYPE= 'CB' then
            v_strTLTXCD := '8882';
            v_strEXECTYPE := 'NB';
        elsif v_strEXECTYPE= 'CS' then
            v_strTLTXCD := '8883';
            v_strEXECTYPE := 'NS';
        end if;

        if length(v_strREFACCTNO)>0 then
        	--Lenh huy sua
        	SELECT EXECTYPE into v_strEXECTYPE  FROM FOMAST WHERE ORGACCTNO=v_strREFACCTNO;
        end if;
        SELECT TO_CHAR(SYSDATE,'HH24MISS') into v_strSystemTime FROM DUAL;
        SELECT SYSVALUE into v_strMarketStatus FROM ORDERSYS WHERE SYSNAME='CONTROLCODE';
        If v_strPRICETYPE <> 'LO' Then
            If v_strPRICETYPE = 'ATO' Then
            	If v_strMarketStatus = 'O' Or v_strMarketStatus = 'A' Then
                    v_lngErrCode := -100000-113;
                    --Cap nhat trang thai tro lai FOMAST
                    UPDATE FOMAST SET STATUS='R',FEEDBACKMSG='[' || v_lngErrCode || '] ' || 'Invalid hose session!' WHERE ACCTNO=rec.ACCTNO;
                    --Log vao messagebus
                    --LogOrderMessage(rec.ACCTNO);
                    v_blnOK := False;
                End If;
            End If;
            If v_strPRICETYPE = 'ATC' Then
                If v_strMarketStatus = 'A' Then
                    v_lngErrCode :=0;
                ElsIf v_strMarketStatus = 'O' And v_strSystemTime >= v_strATCStartTime Then
                    v_lngErrCode :=0;
                Else
                    v_lngErrCode := -100000-113;
                    --Cap nhat trang thai tro lai FOMAST
                    UPDATE FOMAST SET STATUS='R',FEEDBACKMSG='[' || v_lngErrCode || '] ' || 'Invalid hose session!' WHERE ACCTNO=rec.ACCTNO;
                    --Log vao messagebus
                    --LogOrderMessage(rec.ACCTNO);
                    v_blnOK := False;
                End If;
            End If;

            If v_strPRICETYPE = 'MO' Then
                If v_strMarketStatus <> 'O' Then
                    v_lngErrCode := -100000-113;
                    --Cap nhat trang thai tro lai FOMAST
                    UPDATE FOMAST SET STATUS='R',FEEDBACKMSG='[' || v_lngErrCode || '] ' || 'Invalid hose session!' WHERE ACCTNO=rec.ACCTNO;
                    --Log vao messagebus
                    v_blnOK := False;
                End If;
            End If;
        End If;
        --2.Xac dinh cac thong tin lien quan den lenh
        SELECT MST.BRATIO, CF.CUSTODYCD,CF.FULLNAME,MST.ACTYPE
				into mv_dblAF_Bratio,v_strCUSTODYCD,v_strFULLNAME,mv_strACTYPE
		FROM AFMAST MST, CFMAST CF WHERE ACCTNO=v_strAFACCTNO AND MST.CUSTID=CF.CUSTID;
        --3.Xac dinh loai hinh lenh tuong ung
        SELECT count(1) into v_dblCountODtype
		FROM ODTYPE
        WHERE STATUS='Y'
		AND ( VIA=v_strVIA OR VIA = 'A')
        AND CLEARCD=v_strCLEARCD
        AND (EXECTYPE=v_strEXECTYPE  OR EXECTYPE='AA')
        AND (TIMETYPE=v_strTIMETYPE OR TIMETYPE='A' )
        AND (PRICETYPE=v_strPRICETYPE OR PRICETYPE='AA')
        AND (MATCHTYPE=v_strMATCHTYPE OR MATCHTYPE='A')
        AND (TRADEPLACE=v_strTRADEPLACE OR TRADEPLACE='000')
        AND (SECTYPE=v_strSECTYPE OR SECTYPE='000')
        AND (NORK=v_strNORK OR NORK ='A')
        AND ACTYPE IN (SELECT ACTYPE FROM REGTYPE WHERE MODCODE='OD' AND AFTYPE = mv_strACTYPE);

        if v_dblCountODtype>0 then
        	SELECT ACTYPE, CLEARDAY, BRATIO, MINFEEAMT, DEFFEERATE
        			into v_strACTYPE,v_strCLEARDAY,mv_dblTyp_Bratio,mv_dblFeeAmountMin,mv_dblFeeRate
			FROM ODTYPE
	        WHERE STATUS='Y'
			AND ( VIA=v_strVIA OR VIA = 'A')
        	AND CLEARCD=v_strCLEARCD
	        AND (EXECTYPE=v_strEXECTYPE  OR EXECTYPE='AA')
    	    AND (TIMETYPE=v_strTIMETYPE OR TIMETYPE='A' )
	        AND (PRICETYPE=v_strPRICETYPE OR PRICETYPE='AA')
	        AND (MATCHTYPE=v_strMATCHTYPE OR MATCHTYPE='A')
	        AND (TRADEPLACE=v_strTRADEPLACE OR TRADEPLACE='000')
    	    AND (SECTYPE=v_strSECTYPE OR SECTYPE='000')
	        AND (NORK=v_strNORK OR NORK ='A')
	        AND ACTYPE IN (SELECT ACTYPE FROM REGTYPE WHERE MODCODE='OD' AND AFTYPE = mv_strACTYPE);
        elsE
        	v_lngErrCode := -700000-3;
            --Cap nhat trang thai tro lai FOMAST
            UPDATE FOMAST SET STATUS='R',FEEDBACKMSG='[' || v_lngErrCode || '] ' || 'Order type not define!!' WHERE ACCTNO=rec.ACCTNO;
            --Log vao messagebus
            --LogOrderMessage(rec.ACCTNO);
            v_blnOK := False;
        end if;

        v_dblSecureRatio := greatest(least(mv_dblTyp_Bratio + mv_dblAF_Bratio, 100), mv_dblSecureBratioMin);
        if v_dblSecureRatio > mv_dblSecureBratioMax then
        	v_dblSecureRatio:=mv_dblSecureBratioMax;
        end if;
        v_dblFeeSecureRatioMin := mv_dblFeeAmountMin * 100 / (to_number(v_strQUANTITY) * to_number(v_strQUOTEPRICE) * to_number(v_strTRADEUNIT));
        If v_dblFeeSecureRatioMin > mv_dblFeeRate Then
            v_dblSecureRatio := v_dblSecureRatio + v_dblFeeSecureRatioMin;
        Else
            v_dblSecureRatio :=v_dblSecureRatio + mv_dblFeeRate;
        End If;
        --5. Voi lenh sua, xac dinh pham phai ky quy them
        v_dblAdvanceSecuredAmount := 0;
        If TO_NUMBER(v_strQUANTITY) * TO_NUMBER(v_strQUOTEPRICE) * v_dblSecureRatio / 100 - TO_NUMBER(v_strREFPRICE) * TO_NUMBER(v_strREFQUANTITY) * v_dblSecureRatio / 100 > 0 Then
            v_dblAdvanceSecuredAmount := (to_number(v_strQUANTITY) * to_number(v_strQUOTEPRICE) * to_number(v_dblSecureRatio) / 100 - to_number(v_strREFPRICE) * to_number(v_strREFQUANTITY) * v_dblSecureRatio / 100);
    	Else
            v_dblAdvanceSecuredAmount := '0';
        End If;
        If v_blnOK Then
        v_dblCount:= 0;
		While TO_NUMBER(v_strQUANTITY) > 0 LOOP
			v_dblCount := v_dblCount + 1;
			If v_strTRADEPLACE = '001' Then --San HO
                IF TO_NUMBER(v_strQUANTITY) > TO_NUMBER(v_strHoseBreakingSize) THEN
                	v_strSendQuantity := v_strHoseBreakingSize;
                ELSE
                	v_strSendQuantity:=v_strQUANTITY;
                END IF;
            Else --San khac thi khong tach lenh
                v_strSendQuantity := v_strQUANTITY;
            End If;
            SELECT seq_odmast.NEXTVAL INTO v_strOrderID FROM DUAL;
            v_strOrderID := '8000' || SUBSTR(Replace(v_strTXDATE, '/', ''), 1, 4) || SUBSTR(Replace(v_strTXDATE, '/', ''), 7, 2) || substr('000000' || TO_CHAR(v_strOrderID), length('000000' || to_char(v_strOrderID))-5,6);
            SELECT seq_FOTXNUM.NEXTVAL INTO v_strTXNUM FROM DUAL;
            v_strTXNUM := '80' || substr('0000000000' || v_strTXNUM, length('0000000000' || v_strTXNUM) - 7,8);
            v_strTXDESC := 'FO' || substr(v_strOrderID,1, 4) || '.' || substr(v_strOrderID, 5, 6) || '.' || substr(v_strOrderID,11, 6) || '.' || v_strFULLNAME || '.' || v_strMATCHTYPE || v_strEXECTYPE || '.' || v_strSYMBOL || '.' || v_strSendQuantity || '.' || v_strQUOTEPRICE;

     	     IF v_strTLTXCD='8876' THEN
     	     	--cHECK DU LIEU XEM CO THOA MAN KHONG
   	         	--Ghi log giao dich
   	        	--ghi vao tllog
   	 	        INSERT INTO tllog
				(AUTOID,TXNUM,TXDATE,TXTIME,BRID,TLID,OFFID,OVRRQS,CHID,CHKID,TLTXCD,IBT,BRID2,TLID2,CCYUSAGE,OFF_LINE,DELTD,BRDATE,BUSDATE,TXDESC,IPADDRESS,WSNAME,TXSTATUS,MSGSTS,OVRSTS,BATCHNAME,MSGAMT,MSGACCT,CHKTIME,OFFTIME,CAREBYGRP)
				VALUES
				(seq_tllog.NEXTVAL,v_strTXNUM,to_date(v_strTXDATE,'DD/MM/YYYY'),v_strSystemTime,'0000',v_strTLID,NULL,NULL,NULL,NULL,v_strTLTXCD,NULL,NULL,NULL,'00','N','N',to_date(v_strTXDATE,'DD/MM/YYYY'),to_date(v_strTXDATE,'DD/MM/YYYY'),'HOST','HOST','0','0','0','FO        ',v_strTXDESC,v_strSendQuantity*v_strQUOTEPRICE*v_strTRADEUNIT/100,v_strAFACCTNO,NULL,NULL,NULL);
			 	--Ghi vao tllogfld
				INSERT INTO tllogfld
				(AUTOID,TXNUM,TXDATE,FLDCD,NVALUE,CVALUE,TXDESC)
				VALUES
				(seq_tllogfld.NEXTVAL,v_strTXNUM,to_date(v_strTXDATE,'DD/MM/YYYY'),'01',0,v_strCODEID,NULL);
				INSERT INTO tllogfld
				(AUTOID,TXNUM,TXDATE,FLDCD,NVALUE,CVALUE,TXDESC)
				VALUES
				(seq_tllogfld.NEXTVAL,v_strTXNUM,to_date(v_strTXDATE,'DD/MM/YYYY'),'02',0,v_strACTYPE,NULL);
				INSERT INTO tllogfld
				(AUTOID,TXNUM,TXDATE,FLDCD,NVALUE,CVALUE,TXDESC)
				VALUES
				(seq_tllogfld.NEXTVAL,v_strTXNUM,to_date(v_strTXDATE,'DD/MM/YYYY'),'03',0,v_strAFACCTNO,NULL);
				INSERT INTO tllogfld
				(AUTOID,TXNUM,TXDATE,FLDCD,NVALUE,CVALUE,TXDESC)
				VALUES
				(seq_tllogfld.NEXTVAL,v_strTXNUM,to_date(v_strTXDATE,'DD/MM/YYYY'),'04',0,v_strOrderID,NULL);
				INSERT INTO tllogfld
				(AUTOID,TXNUM,TXDATE,FLDCD,NVALUE,CVALUE,TXDESC)
				VALUES
				(seq_tllogfld.NEXTVAL,v_strTXNUM,to_date(v_strTXDATE,'DD/MM/YYYY'),'10',v_strCLEARDAY,NULL,NULL);
				INSERT INTO tllogfld
				(AUTOID,TXNUM,TXDATE,FLDCD,NVALUE,CVALUE,TXDESC)
				VALUES
				(seq_tllogfld.NEXTVAL,v_strTXNUM,to_date(v_strTXDATE,'DD/MM/YYYY'),'11',v_strQUOTEPRICE,NULL,NULL);
				INSERT INTO tllogfld
				(AUTOID,TXNUM,TXDATE,FLDCD,NVALUE,CVALUE,TXDESC)
				VALUES
				(seq_tllogfld.NEXTVAL,v_strTXNUM,to_date(v_strTXDATE,'DD/MM/YYYY'),'12',v_strSendQuantity,NULL,NULL);
				INSERT INTO tllogfld
				(AUTOID,TXNUM,TXDATE,FLDCD,NVALUE,CVALUE,TXDESC)
				VALUES
				(seq_tllogfld.NEXTVAL,v_strTXNUM,to_date(v_strTXDATE,'DD/MM/YYYY'),'13',v_dblSecureRatio,NULL,NULL);
				INSERT INTO tllogfld
				(AUTOID,TXNUM,TXDATE,FLDCD,NVALUE,CVALUE,TXDESC)
				VALUES
				(seq_tllogfld.NEXTVAL,v_strTXNUM,to_date(v_strTXDATE,'DD/MM/YYYY'),'14',REC.PRICE,NULL,NULL);
				INSERT INTO tllogfld
				(AUTOID,TXNUM,TXDATE,FLDCD,NVALUE,CVALUE,TXDESC)
				VALUES
				(seq_tllogfld.NEXTVAL,v_strTXNUM,to_date(v_strTXDATE,'DD/MM/YYYY'),'19',0,'T',NULL);
				INSERT INTO tllogfld
				(AUTOID,TXNUM,TXDATE,FLDCD,NVALUE,CVALUE,TXDESC)
				VALUES
				(seq_tllogfld.NEXTVAL,v_strTXNUM,to_date(v_strTXDATE,'DD/MM/YYYY'),'20',0,v_strTIMETYPE,NULL);
				INSERT INTO tllogfld
				(AUTOID,TXNUM,TXDATE,FLDCD,NVALUE,CVALUE,TXDESC)
				VALUES
				(seq_tllogfld.NEXTVAL,v_strTXNUM,to_date(v_strTXDATE,'DD/MM/YYYY'),'21',0,v_strTXDATE,NULL);
				INSERT INTO tllogfld
				(AUTOID,TXNUM,TXDATE,FLDCD,NVALUE,CVALUE,TXDESC)
				VALUES
				(seq_tllogfld.NEXTVAL,v_strTXNUM,to_date(v_strTXDATE,'DD/MM/YYYY'),'22',0,v_strORGEXECTYPE,NULL);
				INSERT INTO tllogfld
				(AUTOID,TXNUM,TXDATE,FLDCD,NVALUE,CVALUE,TXDESC)
				VALUES
				(seq_tllogfld.NEXTVAL,v_strTXNUM,to_date(v_strTXDATE,'DD/MM/YYYY'),'23',0,v_strNORK,NULL);
				INSERT INTO tllogfld
				(AUTOID,TXNUM,TXDATE,FLDCD,NVALUE,CVALUE,TXDESC)
				VALUES
				(seq_tllogfld.NEXTVAL,v_strTXNUM,to_date(v_strTXDATE,'DD/MM/YYYY'),'24',0,v_strMATCHTYPE,NULL);
				INSERT INTO tllogfld
				(AUTOID,TXNUM,TXDATE,FLDCD,NVALUE,CVALUE,TXDESC)
				VALUES
				(seq_tllogfld.NEXTVAL,v_strTXNUM,to_date(v_strTXDATE,'DD/MM/YYYY'),'25',0,v_strVIA,NULL);
				INSERT INTO tllogfld
				(AUTOID,TXNUM,TXDATE,FLDCD,NVALUE,CVALUE,TXDESC)
				VALUES
				(seq_tllogfld.NEXTVAL,v_strTXNUM,to_date(v_strTXDATE,'DD/MM/YYYY'),'26',0,v_strCLEARCD,NULL);
				INSERT INTO tllogfld
				(AUTOID,TXNUM,TXDATE,FLDCD,NVALUE,CVALUE,TXDESC)
				VALUES
				(seq_tllogfld.NEXTVAL,v_strTXNUM,to_date(v_strTXDATE,'DD/MM/YYYY'),'27',0,v_strPRICETYPE,NULL);
				INSERT INTO tllogfld
				(AUTOID,TXNUM,TXDATE,FLDCD,NVALUE,CVALUE,TXDESC)
				VALUES
				(seq_tllogfld.NEXTVAL,v_strTXNUM,to_date(v_strTXDATE,'DD/MM/YYYY'),'28',0,'p',NULL);
				INSERT INTO tllogfld
				(AUTOID,TXNUM,TXDATE,FLDCD,NVALUE,CVALUE,TXDESC)
				VALUES
				(seq_tllogfld.NEXTVAL,v_strTXNUM,to_date(v_strTXDATE,'DD/MM/YYYY'),'29',0,'N',NULL);
				INSERT INTO tllogfld
				(AUTOID,TXNUM,TXDATE,FLDCD,NVALUE,CVALUE,TXDESC)
				VALUES
				(seq_tllogfld.NEXTVAL,v_strTXNUM,to_date(v_strTXDATE,'DD/MM/YYYY'),'30',0,v_strTXDESC,NULL);
				INSERT INTO tllogfld
				(AUTOID,TXNUM,TXDATE,FLDCD,NVALUE,CVALUE,TXDESC)
				VALUES
				(seq_tllogfld.NEXTVAL,v_strTXNUM,to_date(v_strTXDATE,'DD/MM/YYYY'),'31',0,'A',NULL);
				INSERT INTO tllogfld
				(AUTOID,TXNUM,TXDATE,FLDCD,NVALUE,CVALUE,TXDESC)
				VALUES
				(seq_tllogfld.NEXTVAL,v_strTXNUM,to_date(v_strTXDATE,'DD/MM/YYYY'),'32',0,'A',NULL);
				INSERT INTO tllogfld
				(AUTOID,TXNUM,TXDATE,FLDCD,NVALUE,CVALUE,TXDESC)
				VALUES
				(seq_tllogfld.NEXTVAL,v_strTXNUM,to_date(v_strTXDATE,'DD/MM/YYYY'),'33',0,'A',NULL);
				INSERT INTO tllogfld
				(AUTOID,TXNUM,TXDATE,FLDCD,NVALUE,CVALUE,TXDESC)
				VALUES
				(seq_tllogfld.NEXTVAL,v_strTXNUM,to_date(v_strTXDATE,'DD/MM/YYYY'),'34',0,'NB',NULL);
				INSERT INTO tllogfld
				(AUTOID,TXNUM,TXDATE,FLDCD,NVALUE,CVALUE,TXDESC)
				VALUES
				(seq_tllogfld.NEXTVAL,v_strTXNUM,to_date(v_strTXDATE,'DD/MM/YYYY'),'50',0,NULL,NULL);
				INSERT INTO tllogfld
				(AUTOID,TXNUM,TXDATE,FLDCD,NVALUE,CVALUE,TXDESC)
				VALUES
				(seq_tllogfld.NEXTVAL,v_strTXNUM,to_date(v_strTXDATE,'DD/MM/YYYY'),'96',1,NULL,NULL);
				INSERT INTO tllogfld
				(AUTOID,TXNUM,TXDATE,FLDCD,NVALUE,CVALUE,TXDESC)
				VALUES
				(seq_tllogfld.NEXTVAL,v_strTXNUM,to_date(v_strTXDATE,'DD/MM/YYYY'),'97',0,'A',NULL);
				INSERT INTO tllogfld
				(AUTOID,TXNUM,TXDATE,FLDCD,NVALUE,CVALUE,TXDESC)
				VALUES
				(seq_tllogfld.NEXTVAL,v_strTXNUM,to_date(v_strTXDATE,'DD/MM/YYYY'),'98',v_strTRADEUNIT,NULL,NULL);
				INSERT INTO tllogfld
				(AUTOID,TXNUM,TXDATE,FLDCD,NVALUE,CVALUE,TXDESC)
				VALUES
				(seq_tllogfld.NEXTVAL,v_strTXNUM,to_date(v_strTXDATE,'DD/MM/YYYY'),'99',100,NULL,NULL);
				--kHONG THUC HIEN GHI NHAN VAO APPMAP, POSTMAP

			ELSIF  v_strTLTXCD='8877' THEN
                --cHECK DU LIEU XEM CO THOA MAN KHONG
   	         	--Ghi log giao dich
   	        	--ghi vao tllog
   	 	        INSERT INTO tllog
				(AUTOID,TXNUM,TXDATE,TXTIME,BRID,TLID,OFFID,OVRRQS,CHID,CHKID,TLTXCD,IBT,BRID2,TLID2,CCYUSAGE,OFF_LINE,DELTD,BRDATE,BUSDATE,TXDESC,IPADDRESS,WSNAME,TXSTATUS,MSGSTS,OVRSTS,BATCHNAME,MSGAMT,MSGACCT,CHKTIME,OFFTIME,CAREBYGRP)
				VALUES
				(seq_tllog.NEXTVAL,v_strTXNUM,to_date(v_strTXDATE,'DD/MM/YYYY'),v_strSystemTime,'0000',v_strTLID,NULL,NULL,NULL,NULL,v_strTLTXCD,NULL,NULL,NULL,'00','N','N',to_date(v_strTXDATE,'DD/MM/YYYY'),to_date(v_strTXDATE,'DD/MM/YYYY'),'HOST','HOST','0','0','0','FO        ',v_strTXDESC,v_strSendQuantity,v_strAFACCTNO,NULL,NULL,NULL);
			 	--Ghi vao tllogfld

			END IF;

		END LOOP;
        END IF;
    end loop;

        RETURN 0;
EXCEPTION
    WHEN others THEN
        return 0;
END;
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
/
