SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "AUTOGENPOSTMAP" (v_txdate IN varchar2,
                      v_txnum IN VARCHAR2)
   IS
   CUR             PKG_REPORT.REF_CURSOR;
   EntrySUBTXNO varchar2(30);
   EntryDORC    varchar2(30);
   EntryACCTNO varchar2(30);
   EntryCCYCD varchar2(30);
   EntryDEC varchar2(30);
   EntryFEECD varchar2(30);
   EntryGLGRP varchar2(30);
   EntryBRID varchar2(30);
   EntryAMOUNT varchar2(30);

   EntryCUSTID  varchar2(30);
   EntryCUSTNAME varchar2(250);
   EntryTASKCD  varchar2(50);
   EntryDEPTCD  varchar2(50);
   EntryMICD  varchar2(50);

   v_tradeplace  varchar2(3);
   v_sectype     varchar2(3);
   v_tltxcd      varchar2(4);
   v_acctfldcd   varchar2(30);
   v_strIBT        varchar(2);

   v_strACCTVALUE varchar2(30);
   v_strBRID varchar2(4);
   v_strHOBRID varchar2(4);
   v_strACNAME	varchar2(30);
   v_strNEGATIVECD varchar2(30);
   v_strFLDCCY	varchar2(30);
   v_strACFLD	varchar2(30);
   v_strFLDTYPE	varchar2(30);
   v_strAMTEXP	varchar2(30);

   v_strGLGRP varchar2(4);
   v_strTRADEPLACE varchar2(3);
   v_strSECTYPE varchar2(5);

   v_strAPP varchar2(2);
   v_strAPPREF varchar2(2);
   v_strCATYPE varchar2(10);
   v_strcamastid varchar2(40);
   v_strACCTNO varchar2(40);
   v_strSQL varchar2(200);
   v_strTxdesc varchar2(250);
   v_dtBKDATE  date;
BEGIN
   v_strHOBRID:='0001'	;
   select tltxcd ,BRID,TXDESC,BUSDATE into v_tltxcd ,v_strBRID,v_strTxdesc,v_dtBKDATE from tllog where txnum=v_txnum and txdate =to_date(v_txdate,'DD/MM/YYYY');
   SELECT MSG_ACCT, IBT into v_acctfldcd ,v_strIBT FROM TLTX WHERE TLTXCD = v_tltxcd;
   EntryCCYCD:='00';
   --Xac dinh IBT
   If v_strBRID = '0000' Then
        v_strIBT := '0';
   elsif length(v_acctfldcd)>0 then
        	select cvalue into v_strACCTVALUE from tllogfld where txnum=v_txnum and txdate =to_date(v_txdate,'DD/MM/YYYY') and fldcd=v_acctfldcd;
        	If length(v_strACCTVALUE) < 4 Then
        		v_strIBT:=0;
        	elsif v_strBRID=substr(v_strACCTVALUE,1,4) then
        			v_strIBT:='0';
       		elsIf v_strBRID = v_strHOBRID Then
        			 v_strIBT := '2';
        	elsIf substr(v_strACCTVALUE,1,4) = v_strHOBRID Then
        			 v_strIBT := '1';
        	else
					 v_strIBT := '3';
			end if;
   end if;--Ket thuc xac dinh IBT


   for rec in
        (SELECT * FROM
           (SELECT POSTMAP.*, REF.GLACCTNO ACCTNO, REF.FEECD FROM POSTMAP, FEEMASTER REF, FEEMAP WHERE POSTMAP.ACNAME='FEEMAST'
             AND POSTMAP.TLTXCD=FEEMAP.TLTXCD AND FEEMAP.FEECD=REF.FEECD
             AND POSTMAP.TLTXCD = v_tltxcd AND POSTMAP.IBT = v_strIBT AND POSTMAP.FLDTYPE = 'F'
             UNION ALL
             SELECT POSTMAP.*, REF.ACCTNO, NULL FEECD FROM POSTMAP, GLREFCOM REF WHERE POSTMAP.ACNAME = REF.ACNAME AND POSTMAP.ACNAME<>'FEEMAST'
             AND POSTMAP.TLTXCD = v_tltxcd AND POSTMAP.IBT = v_strIBT AND POSTMAP.FLDTYPE = 'F'
             UNION ALL
             SELECT POSTMAP.*, NULL ACCTNO, NULL FEECD FROM POSTMAP WHERE 0=0
             AND POSTMAP.TLTXCD = v_tltxcd AND POSTMAP.IBT = v_strIBT AND POSTMAP.FLDTYPE = 'V') MAP
             ORDER BY SUBTXNO, DORC DESC
         )
   loop
        --Xu ly cho tung but toan D/C
        v_strACNAME := rec.ACNAME;
        v_strNEGATIVECD := rec.NEGATIVECD;
        v_strFLDCCY := rec.FLDCCY;
        v_strACFLD := rec.ACFLD;
        v_strFLDTYPE := rec.FLDTYPE;
        v_strAMTEXP := rec.AMTEXP;
        EntryFEECD := rec.FEECD;
        EntrySUBTXNO := rec.SUBTXNO;
        EntryDORC := rec.DORC;

        v_strAMTEXP := BuildAMTEXP(v_strAMTEXP,v_txnum,v_txdate);
        v_strSQL := 'select ' || v_strAMTEXP || ' from dual';
        OPEN CUR FOR v_strSQL;
        --EntryAMOUNT:=to_number(v_strAMTEXP);
        LOOP
        FETCH CUR INTO EntryAMOUNT ;
        EXIT WHEN CUR%NOTFOUND;
        END LOOP;
        CLOSE CUR;

        select cvalue into v_strACCTNO	from tllogfld where txnum=v_txnum and txdate =to_date(v_txdate,'DD/MM/YYYY') and fldcd=v_strACFLD ;
        If length(v_strACCTNO) > 4 Then
			EntryBRID := substr(v_strACCTNO,1,4);
		else
            EntryBRID:=v_strACCTNO;
		end if;
		EntryCUSTID:=rec.FLDCUSTID;
		if length(EntryCUSTID)>0 then
		  select cvalue into EntryCUSTID	from tllogfld where txnum=v_txnum and txdate =to_date(v_txdate,'DD/MM/YYYY') and fldcd=EntryCUSTID ;
		end if;

		EntryCUSTNAME:=rec.FLDCUSTNAME;
		if length(EntryCUSTNAME)>0 then
		  select cvalue into EntryCUSTNAME	from tllogfld where txnum=v_txnum and txdate =to_date(v_txdate,'DD/MM/YYYY') and fldcd=EntryCUSTNAME ;
        end if;
		EntryTASKCD:=rec.FLDTASKCD;
		if length(EntryTASKCD)>0 then
    		select cvalue into EntryTASKCD	from tllogfld where txnum=v_txnum and txdate =to_date(v_txdate,'DD/MM/YYYY') and fldcd=EntryTASKCD ;
		end if;
		EntryDEPTCD:=rec.FLDDEPTCD;
		if length(EntryDEPTCD)>0 then
		  select cvalue into EntryDEPTCD	from tllogfld where txnum=v_txnum and txdate =to_date(v_txdate,'DD/MM/YYYY') and fldcd=EntryDEPTCD ;
        end if;
		EntryMICD:=rec.FLDMICD;
		if length(EntryMICD)>0 then
    		select cvalue into EntryMICD	from tllogfld where txnum=v_txnum and txdate =to_date(v_txdate,'DD/MM/YYYY') and fldcd=EntryMICD ;
		end if;


        EntryACCTNO:=rec.ACCTNO;
        If Length(EntryACCTNO) = 0 or EntryACCTNO is null Then
                v_strAPP :=substr(v_strACNAME,1, 2);
                v_strAPPREF := substr(v_strACNAME,length(v_strACNAME)-1, 2);
                If v_strAPPREF = 'CA' Then
                    v_strcamastid:=v_strACCTNO;
                    SELECT CATYPE into v_strCATYPE from camast where camastid = v_strcamastid;
                end if;
                If v_strACNAME = 'CINETMARKET' Or v_strACNAME = 'CINETMARKETRM'
                    Or v_strACNAME = 'CINETCLR' Or v_strACNAME = 'CINETCLRRM'
                    Or v_strACNAME = 'CIINVEST' Or v_strACNAME = 'CIINVESTRM'
                    Or v_strACNAME = 'CIINVESTRE' Or v_strACNAME = 'SEINVEBOCA' Then
                SELECT SBSECURITIES.SECTYPE, SBSECURITIES.TRADEPLACE, TYP.GLGRP
                        into v_strSECTYPE,v_strTRADEPLACE,v_strGLGRP
                    FROM SBSECURITIES, SETYPE TYP, SEMAST MST
                    WHERE MST.CODEID=SBSECURITIES.CODEID AND TYP.ACTYPE = MST.ACTYPE AND MST.ACCTNO = v_strACCTNO;
                if to_number(v_strTRADEPLACE)>3 then
                    v_strTRADEPLACE:=3;
                else
                    v_strTRADEPLACE:=to_char(to_number(v_strTRADEPLACE));
                end if;
                if v_strSECTYPE in ('001','002') then
                    v_strSECTYPE := '1';
                elsif v_strSECTYPE in ('003','006') then
                    v_strSECTYPE := '2';
                Else
                    v_strSECTYPE := '3';
                end if;
            else
                If v_strAPP = 'SE' Then
                    SELECT SBSECURITIES.SECTYPE, SBSECURITIES.TRADEPLACE, TYP.GLGRP
                                into v_strSECTYPE,v_strTRADEPLACE,v_strGLGRP
                                FROM SBSECURITIES, SETYPE TYP, SEMAST MST
                                WHERE MST.CODEID=SBSECURITIES.CODEID AND TYP.ACTYPE = MST.ACTYPE AND MST.ACCTNO = v_strACCTNO;
                    if to_number(v_strTRADEPLACE)>3 then
                        v_strTRADEPLACE:=3;
                    else
                        v_strTRADEPLACE:=to_char(to_number(v_strTRADEPLACE));
                    end if;
                    if v_strSECTYPE in ('001','002') then
                        v_strSECTYPE := '1';
                    elsif v_strSECTYPE in ('003','006') then
                        v_strSECTYPE := '2';
                    Else
                        v_strSECTYPE := '3';
                    end if;
                else
                    SELECT TYP.GLGRP into v_strGLGRP FROM CITYPE TYP, CIMAST MST
                            WHERE TYP.ACTYPE = MST.ACTYPE AND MST.ACCTNO =v_strACCTNO;
                end if;
            end if;
            EntryGLGRP := v_strGLGRP;
            EntryACCTNO := v_strAPP || v_strGLGRP || v_strACNAME;
            If length(EntryACCTNO) > 0 Then
                If v_strAPPREF = 'CA' Then
                    SELECT ACCTNO into EntryACCTNO FROM GLREF WHERE APPTYPE=v_strAPP AND GLGRP=v_strGLGRP AND SUBSTR(ACNAME,4) = v_strACNAME AND SUBSTR(ACNAME ,1,3) = v_strCATYPE;
                Else
                    SELECT ACCTNO into EntryACCTNO FROM GLREF WHERE APPTYPE=v_strAPP AND GLGRP=v_strGLGRP AND ACNAME=v_strACNAME;
                End If;
            end if;
        end if;

        If v_strBRID <> '0000' Then
            EntryACCTNO := Replace(EntryACCTNO, '____', v_strBRID);   --BRID Lay theo chi nhanh
        else
            EntryACCTNO := Replace(EntryACCTNO, '____', EntryBRID);   --BRID Lay theo tai khoan
        end if;
        EntryACCTNO := Replace(EntryACCTNO, '####', EntryBRID);   --BRID Lay theo tai khoan
        EntryACCTNO := Replace(EntryACCTNO, '**', EntryCCYCD);
        EntryACCTNO := Replace(EntryACCTNO, '^^', EntryCCYCD);
        EntryACCTNO := Replace(EntryACCTNO, '@', v_strTRADEPLACE);
        EntryACCTNO := Replace(EntryACCTNO, '$', v_strSECTYPE);
        If v_strACNAME = 'GLMAST' Then
            select cvalue into EntryACCTNO from tllogfld where txnum=v_txnum and txdate =to_date(v_txdate,'DD/MM/YYYY') and fldcd=v_strACFLD ;
        end if;
        If v_strACNAME = 'CASH' Then
            If EntryCCYCD = '00' Then
            --'Based currency
                EntryACCTNO := Replace(EntryACCTNO, '$', '1');
            Else
            --'Foreign currency
                EntryACCTNO := Replace(EntryACCTNO, '$', '3');
            End If;
            If substr(EntryACCTNO,length(EntryACCTNO)-3, 4) = '0000' Then
            --'For HeadOffice
                EntryACCTNO := Replace(EntryACCTNO, '~', '1');
            Else
            --'For branch
                EntryACCTNO := Replace(EntryACCTNO, '~', '2');
            End If;
        end if;
        If to_number(EntryAMOUNT) < 0 Then
            if v_strNEGATIVECD='Z' then    --'Reset ve 0
                EntryAMOUNT := '0';
            elsif v_strNEGATIVECD='R' then    --'Revert
                If EntryDORC = 'D' Then
                    EntryDORC := 'C';
                end if;
                If EntryDORC = 'C' Then
                    EntryDORC := 'D';
                end if;
                EntryAMOUNT := to_char(-to_number(EntryAMOUNT));
            elsif v_strNEGATIVECD='A' then--'GIU NGUYEN
                EntryAMOUNT:=EntryAMOUNT;
            end if;

        End If;

        --Tao Mitran
        If EntryAMOUNT <> 0 And EntryACCTNO > 0 And Length(EntryCUSTID) > 0
                    Or Length(EntryCUSTNAME) > 0 Or Length(EntryTASKCD) > 0 Or Length(EntryDEPTCD) > 0 Or Length(EntryMICD) > 0 Then
             INSERT INTO MITRAN
                (AUTOID,TXDATE,TXNUM,SUBTXNO,DORC,ACCTNO,
                 CUSTID,CUSTNAME,TASKCD,DEPTCD,MICD,DESCRIPTION,DELTD)
             VALUES
                (SEQ_MITRAN.NEXTVAL,TO_DATE(v_txdate, 'DD/MM/YYYY'),v_txnum,EntrySUBTXNO,EntryDORC,EntryACCTNO,EntryCUSTID,EntryCUSTNAME,EntryTASKCD,EntryDEPTCD,EntryMICD,v_strTxdesc,'N');
        end if;
        if length(EntryACCTNO)>0 and EntryAMOUNT<>0 then
            --Tao GLTRAN
            INSERT INTO GLTRAN (AUTOID,ACCTNO, TXDATE, TXNUM, BKDATE, CCYCD, DORC, SUBTXNO, AMT, DELTD)
            VALUES
                (SEQ_GLTRAN.NEXTVAL,EntryACCTNO,TO_DATE(v_txdate, 'DD/MM/YYYY'),v_txnum ,v_dtBKDATE,EntryCCYCD,EntryDORC,EntrySUBTXNO,EntryAMOUNT,'N');
            --Cap nhat GLMAST
            If EntryDORC = 'D' Then
                    UPDATE GLMAST SET LSTDATE=TO_DATE(v_txdate, 'DD/MM/YYYY'), BALANCE=NVL(BALANCE,0)-(EntryAMOUNT),DDR=NVL(DDR,0)+(EntryAMOUNT),MDR=NVL(MDR,0)+(EntryAMOUNT),YDR=NVL(YDR,0)+(EntryAMOUNT) WHERE ACCTNO=EntryACCTNO;
            ElsIf EntryDORC = 'C' Then
                    UPDATE GLMAST SET LSTDATE=TO_DATE(v_txdate, 'DD/MM/YYYY'), BALANCE=NVL(BALANCE,0)+(EntryAMOUNT),DCR=NVL(DCR,0)+(EntryAMOUNT),MCR=NVL(MCR,0)+(EntryAMOUNT),YCR=NVL(YCR,0)+(EntryAMOUNT) WHERE ACCTNO=EntryACCTNO;
            End If;
            If v_dtBKDATE <> TO_DATE(v_txdate, 'DD/MM/YYYY') Then
                INSERT INTO GLHIST (AUTOID,PERIOD,TXDATE,ACCTNO,BALANCE,AVGBAL,YEARBAL,DDR,DCR,MDR,MCR,YDR,YCR)
                SELECT SEQ_GLHIST.NEXTVAL,'EOD',TO_DATE(v_txdate, 'DD/MM/YYYY') + ID.Id,ACCTNO,0,0,0,0,0,0,0,0,0 FROM GLMAST,
                    (select rownum Id from glhist where txdate >=TO_DATE(v_txdate, 'DD/MM/YYYY') and txdate < (select min (txdate) from glhist where acctno=EntryACCTNO)) ID
                WHERE ACCTNO=EntryACCTNO;

                If EntryDORC = 'D' Then
                    UPDATE GLHIST SET BALANCE=NVL(BALANCE,0)-(EntryAMOUNT),DDR=NVL(DDR,0)+(EntryAMOUNT),MDR=NVL(MDR,0)+(EntryAMOUNT),YDR=NVL(YDR,0)+(EntryAMOUNT) WHERE ACCTNO=EntryACCTNO AND TXDATE >= v_dtBKDATE;
                ElsIf EntryDORC = 'C' Then
                    UPDATE GLHIST SET BALANCE=NVL(BALANCE,0)+(EntryAMOUNT),DCR=NVL(DCR,0)+(EntryAMOUNT),MCR=NVL(MCR,0)+(EntryAMOUNT),YCR=NVL(YCR,0)+(EntryAMOUNT) WHERE ACCTNO=EntryACCTNO AND TXDATE >= v_dtBKDATE;
                End If;
            end if;
        end if;

    end loop;
EXCEPTION
   WHEN OTHERS THEN
    RETURN ;

END;

 
 
 
 
/
