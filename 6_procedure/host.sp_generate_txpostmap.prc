SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "SP_GENERATE_TXPOSTMAP" (
  pv_txdate in VARCHAR,
  pv_txnum in VARCHAR,
  pv_errmsg out VARCHAR2) IS
  v_ponumber varchar2(100);
  v_dealno varchar2(3000);
  v_camastid varchar2(3000);
  v_dealdate date;
  v_dealdescription varchar2(3000);
  v_code  NUMBER;
  v_errm  VARCHAR2(64);
  v_currdate varchar(50);
  v_hobrid varchar(4);
  v_brid varchar(4);
  v_brid2 varchar(4);
  v_tltxcd varchar(4);
  v_msgacct varchar(50);
  v_withacct varchar(50);
  v_busdate varchar(100);
  v_notes varchar(2500);
  v_entry_acctno varchar(50);
  v_entry_module varchar(50);
  v_acreffld  varchar(50);
  v_acfld varchar(50);
  v_acfld_acname varchar(50);
  v_acfld_actype varchar(4);
  v_acfld_glgrp varchar(4);
  v_acfld_amtexp varchar(250);
  v_acfld_amount number;
  v_acfld_custodycd varchar(10);
  v_acfld_fullname varchar(100);
  v_tradeplace varchar(4);
  v_securities_type varchar(4);
  v_expression varchar(250);
  v_debit_acctno varchar(50);
  v_credit_acctno varchar(50);
  v_evaluator varchar(2);
  v_amount number;
  v_pos_amtexp integer;
  v_ibt integer;
  v_gen_voucher varchar(20);
  v_mapid varchar(4);
  v_isrun varchar(4);
  v_expisrun varchar(50);
  v_brid_msgacct varchar(4);
  v_brid_withacct varchar(4);
  v_custodycd varchar2(20);
  v_txdate date;
  v_orderid varchar2(100);
  v_ordertxnum varchar2(100);
  v_ordertxdate date;
  v_via varchar2(10);
  v_custatcom char(1);
  CURSOR v_cursor_postmap IS SELECT * FROM
  (SELECT EXTPOSTMAP.*, REFFEE.GLACCTNO ACCTNO, REFFEE.FEECD, SUBSTR(EXTPOSTMAP.ACNAME,1,2) NMLMOD, SUBSTR(EXTPOSTMAP.ACNAME,LENGTH(EXTPOSTMAP.ACNAME)-1) CAMOD FROM EXTPOSTMAP, FEEMASTER REFFEE, FEEMAP
  WHERE EXTPOSTMAP.ACNAME='FEEMAST' AND EXTPOSTMAP.TLTXCD=FEEMAP.TLTXCD AND FEEMAP.FEECD=REFFEE.FEECD
  AND EXTPOSTMAP.TLTXCD=v_tltxcd AND EXTPOSTMAP.IBT=v_ibt AND EXTPOSTMAP.FLDTYPE = 'F'
  UNION ALL
  SELECT EXTPOSTMAP.*, REFFEE.ACCTNO, NULL FEECD, SUBSTR(EXTPOSTMAP.ACNAME,1,2) NMLMOD, SUBSTR(EXTPOSTMAP.ACNAME,LENGTH(EXTPOSTMAP.ACNAME)-1) CAMOD FROM EXTPOSTMAP, GLREFCOM REFFEE
  WHERE EXTPOSTMAP.ACNAME = REFFEE.ACNAME AND EXTPOSTMAP.ACNAME<>'FEEMAST'
  AND EXTPOSTMAP.TLTXCD=v_tltxcd AND EXTPOSTMAP.IBT =v_ibt AND EXTPOSTMAP.FLDTYPE = 'F'
  UNION ALL
  SELECT EXTPOSTMAP.*, NULL ACCTNO, NULL FEECD, SUBSTR(EXTPOSTMAP.ACNAME,1,2) NMLMOD, SUBSTR(EXTPOSTMAP.ACNAME,LENGTH(EXTPOSTMAP.ACNAME)-1) CAMOD FROM EXTPOSTMAP
  WHERE EXTPOSTMAP.TLTXCD=v_tltxcd AND EXTPOSTMAP.IBT =v_ibt AND EXTPOSTMAP.FLDTYPE = 'V') REFMAP
  ORDER BY SUBTXNO, DORC DESC; --Th? t? ORDER BY l quan tr?ng kh?ng du?c thay d?i
  v_cpostmap_row v_cursor_postmap%ROWTYPE;
BEGIN
v_withacct:='';  --mac dinh la khong co tai khoan doi ung. Xac dinh IBT bang BRID
v_ibt:=0;    --mac dinh la khong co IBT
v_gen_voucher:='N';

--LAY MA BRANCH HOI SO
SELECT VARVALUE INTO v_hobrid FROM SYSVAR WHERE GRNAME='SYSTEM' AND VARNAME='HOBRID';
SELECT VARVALUE INTO v_currdate FROM SYSVAR WHERE GRNAME='SYSTEM' AND VARNAME='CURRDATE';

--LAY THONG TIN TLLOG
pv_errmsg:='LAY THONG TIN TLLOG CURRDATE=' || v_currdate || ', TXDATE=' || pv_txdate || ', TXNUM=' || pv_txnum;
IF v_currdate=pv_txdate THEN
  SELECT TL.BRID, TL.BRID2, TL.TLTXCD, TL.MSGACCT, TLTX.WITHACCT, TL.BUSDATE,
    CASE WHEN TL.TLTXCD IN ('2641','2642','2643') THEN TL.TXDESC || '/DFACCTNO:' || MSGACCT
        WHEN TL.TLTXCD = '8855' THEN TL.TXDESC || '/TXDATE:' || TL.TXDATE
        ELSE TL.TXDESC END CASE
  INTO v_brid, v_brid2, v_tltxcd, v_msgacct, v_withacct, v_busdate, v_notes
  FROM TLLOG TL, TLTX WHERE TL.TXDATE=TO_DATE(pv_txdate,'DD/MM/RRRR') AND TL.TXNUM=pv_txnum
  AND TL.TLTXCD=TLTX.TLTXCD AND TL.DELTD<>'Y' AND ROWNUM < 2;
ELSE
  SELECT TL.BRID, TL.BRID2, TL.TLTXCD, TL.MSGACCT, TLTX.WITHACCT, TL.BUSDATE,
    CASE WHEN TL.TLTXCD IN ('2641','2642','2643') THEN TL.TXDESC || '/DFACCTNO:' || MSGACCT
        WHEN TL.TLTXCD = '8855' THEN TL.TXDESC || '/TXDATE:' || TL.TXDATE
        ELSE TL.TXDESC END CASE
  INTO v_brid, v_brid2, v_tltxcd, v_msgacct, v_withacct, v_busdate, v_notes
  FROM TLLOGALL TL, TLTX WHERE TL.TXDATE=TO_DATE(pv_txdate,'DD/MM/RRRR') AND TL.TXNUM=pv_txnum
  AND TL.TLTXCD=TLTX.TLTXCD AND TL.DELTD<>'Y' AND ROWNUM < 2;
END IF;
dbms_output.put_line('BRID: ' || v_brid);
v_brid_msgacct:=SUBSTR(v_msgacct,1,4);

--Khong xuat du lieu thu thue TNCN, cat tien T0, ko phi MUA, ko phi BAN cho tai khoan tu doanh
IF v_tltxcd in('0066','8865','8855','8856') THEN
    SELECT  CUSTODYCD, CUSTATCOM
    INTO    v_custodycd,v_custatcom
    FROM    CFMAST CF, AFMAST AF
    WHERE   AF.CUSTID = CF.CUSTID AND AF.ACCTNO = v_msgacct;

    IF SUBSTR(v_custodycd,4, 1) =  'P' AND v_custatcom='Y'  THEN
        RETURN;
    END IF;
END IF;

--Khong hach toan cho giao dich thanh toan bu tru(8865,8866,8827) d/v kh ko luu ky
IF v_tltxcd in ('8865','8866','8827') THEN
    SELECT  CUSTODYCD, CUSTATCOM
    INTO    v_custodycd,v_custatcom
    FROM    CFMAST CF, AFMAST AF
    WHERE   AF.CUSTID = CF.CUSTID AND AF.ACCTNO = v_msgacct;

    IF  v_custatcom <>'Y' THEN
        RETURN;
    END IF;
END IF;

--Chinh lai description cho deal
IF v_tltxcd in ('2641','2642','2643','2670','2678') THEN
    pv_errmsg:='LAY THONG TIN DEAL=' || v_currdate || ', TXDATE=' || pv_txdate || ', TXNUM=' || pv_txnum;
    IF v_tltxcd = '2670' THEN
        SELECT CVALUE INTO v_dealno
        FROM   VW_TLLOGFLD_ALL
        WHERE  TXNUM = pv_txnum AND TXDATE = TO_DATE(pv_txdate,'dd/mm/yyyy') AND FLDCD = '02';
    ELSE
        v_dealno := v_msgacct;
    END IF;

    pv_errmsg:='LAY THONG TIN DEAL DESCRPITION=' || v_dealno || ', TXDATE=' || v_dealdescription || ', TXNUM=' || pv_txnum;
    SELECT TXDATE, DESCRIPTION INTO v_dealdate, v_dealdescription
    FROM   VW_DFMAST_ALL WHERE ACCTNO = v_dealno;

    pv_errmsg:='DA LAY THONG TIN DEAL DESCRPITION1=' || v_dealdescription || ', DEALDATE=' || v_dealdate || ', TXNUM=' || pv_txnum;
    IF v_dealdate < to_date('31-may-2010') THEN
        v_dealno := v_dealdescription;
    END IF;

    IF v_tltxcd IN ('2670','2678') THEN
        v_notes := 'Giai ngan deal: ' || v_dealno;
    ELSE
        v_notes := 'Thanh toan deal: ' || v_dealno;
    END IF;
END IF;

--Lay thong tin quyen dv 3384, 3387
pv_errmsg:='LAY THONG TIN QUYEN TXDATE=' || pv_txdate || ', TXNUM=' || pv_txnum;
IF v_tltxcd in ('3384','3387') THEN
    SELECT CVALUE INTO v_camastid
    FROM   VW_TLLOGFLD_ALL
    WHERE  TXNUM = pv_txnum AND TXDATE = TO_DATE(pv_txdate,'dd/mm/yyyy') AND FLDCD = '02';

    v_notes := v_notes || '/CAMASTID: ' || v_camastid;
END IF;

-- Lay so ban ke cho gd 1104
IF v_tltxcd = '1104' THEN
    SELECT CVALUE INTO v_ponumber
    FROM VW_TLLOGFLD_ALL
    WHERE TXNUM = pv_txnum AND TXDATE = TO_DATE(pv_txdate,'dd/mm/yyyy') AND FLDCD = '99';

    v_notes := v_notes || '/SO BAN KE: ' || v_ponumber;
END IF;

--LAY THONG TIN VE TAI KHOAN DOI UNG
pv_errmsg:='LAY THONG TIN VE TAI KHOAN DOI UNG ACFLDCD=' || v_withacct || ', TXDATE=' || pv_txdate || ', TXNUM=' || pv_txnum;
BEGIN
--dbms_output.put_line('1');
  IF v_currdate=pv_txdate THEN
    SELECT BRID INTO v_withacct FROM POSTMAP WHERE TLTXCD=v_tltxcd AND BRID <> '----' AND ROWNUM < 2;
    SELECT CVALUE INTO v_withacct
    FROM TLLOGFLD TL WHERE TL.TXDATE=TO_DATE(pv_txdate,'DD/MM/RRRR') AND TL.TXNUM=pv_txnum AND FLDCD=v_withacct;
  ELSE
    SELECT BRID INTO v_withacct FROM POSTMAP WHERE TLTXCD=v_tltxcd AND BRID <> '----' AND ROWNUM < 2;
    SELECT CVALUE INTO v_withacct
    FROM TLLOGFLDALL TL WHERE TL.TXDATE=TO_DATE(pv_txdate,'DD/MM/RRRR') AND TL.TXNUM=pv_txnum AND FLDCD=v_withacct;
  END IF;
  v_brid_withacct:=SUBSTR(v_withacct,1,4);
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    v_brid_withacct:=v_brid;
END;
--dbms_output.put_line('2');
--XU LY DOI VOI GD 1143/2643 TRONG BATCH:
IF v_tltxcd IN ('1143','2643') AND v_brid_withacct IS NULL THEN
v_brid_withacct := '0001';
END IF;
--dbms_output.put_line('3');
--dbms_output.put_line(v_brid_withacct);
SELECT MAPID INTO v_mapid FROM BRGRP WHERE BRID=v_brid_withacct;
--dbms_output.put_line('4');
--XAC DINH IBT
IF SUBSTR(v_brid_msgacct,1,2)=SUBSTR(v_brid_withacct,1,2) THEN
  v_ibt:=0;
ELSE
  IF SUBSTR(v_brid_withacct,1,2)=SUBSTR(v_hobrid,1,2) THEN
    --tai khoan doi ung or chi nhanh nhap giao dich la hoi so
    v_ibt:=2;
  ELSE
    --tai khoan doi ung khong phai la cua hoi so
    IF SUBSTR(v_brid_msgacct,1,2)=SUBSTR(v_hobrid,1,2) THEN
      --tai khoan giao dich la cua hoi so
      v_ibt:=1;
    ELSE
      --tai khoan la cua chi nhanh khac
      v_ibt:=3;
    END IF;
  END IF;
END IF;

--X?a b?ng Log cu
pv_errmsg:='Delete on GLLOGHIST';
--DELETE FROM GLLOGHIST WHERE TXDATE=TO_DATE(pv_txdate,'DD/MM/RRRR') AND TXNUM=pv_txnum;
--SELECT SEQ_EBS_VOUCHERNUMBER.NEXTVAL INTO v_gen_voucher FROM DUAL;
--X? l? c?b?t to?trong postmap
OPEN v_cursor_postmap;
LOOP
  pv_errmsg:='Begin';
  FETCH v_cursor_postmap INTO v_cpostmap_row;
  EXIT WHEN v_cursor_postmap%NOTFOUND;
  v_tradeplace:='';
  v_securities_type:='';
  v_acfld_actype:='';
  v_entry_module:='';
  v_acfld:='';
  v_acfld_glgrp:='';
  v_entry_acctno:='';
  v_acfld_custodycd:='';
  v_acfld_fullname:='';

  --X?C ?NH B? TO?N C???C T?O HAY KH?G
  v_isrun:='0';
  v_expisrun:=v_cpostmap_row.ISRUN;
  IF LENGTH(v_expisrun)>0 THEN
     IF SUBSTR(v_expisrun,1,1)='@' THEN     --L?Y TR?C TI?P GI? TR?
        v_isrun:=SUBSTR(v_expisrun,2);
     ELSE
       IF SUBSTR(v_expisrun,1,1)='$' THEN   --L?Y TRU?NG TRONG TLLOGFLD
          IF v_currdate=pv_txdate THEN
            SELECT CVALUE INTO v_isrun
            FROM TLLOGFLD TL WHERE TL.TXDATE=TO_DATE(pv_txdate,'DD/MM/RRRR') AND TL.TXNUM=pv_txnum AND FLDCD=SUBSTR(v_expisrun,2);
          ELSE
            dbms_output.put_line(v_expisrun);
            SELECT CVALUE INTO v_isrun
            FROM TLLOGFLDALL TL WHERE TL.TXDATE=TO_DATE(pv_txdate,'DD/MM/RRRR') AND TL.TXNUM=pv_txnum AND FLDCD=SUBSTR(v_expisrun,2);
          END IF;
       END IF;
     END IF;
  END IF;
  pv_errmsg:='Show is run : ' || v_isrun;

IF v_isrun<>'0' THEN
  --l?y t?v?ru?ng tham chi?u t?kho?n
  v_acfld_acname:=v_cpostmap_row.ACNAME;
  v_entry_module:=v_cpostmap_row.NMLMOD;  --m?h?h?
  pv_errmsg:='Get account field ACFLD: ' || v_cpostmap_row.ACFLD;
  --LAY THONG TIN CUA TRUONG TAI KHOAN KHACH HANG CHI TIET
  dbms_output.put_line('BRID 1: ' || v_brid);
  IF v_currdate=pv_txdate THEN
    SELECT CVALUE INTO v_acfld
    FROM TLLOGFLD TL WHERE TL.TXDATE=TO_DATE(pv_txdate,'DD/MM/RRRR') AND TL.TXNUM=pv_txnum AND FLDCD=v_cpostmap_row.ACFLD;
  ELSE
    SELECT CVALUE INTO v_acfld
    FROM TLLOGFLDALL TL WHERE TL.TXDATE=TO_DATE(pv_txdate,'DD/MM/RRRR') AND TL.TXNUM=pv_txnum AND FLDCD=v_cpostmap_row.ACFLD;
  END IF;

    dbms_output.put_line('fldtype: ' || SUBSTR(v_cpostmap_row.FLDTYPE,1,1));
  IF SUBSTR(v_cpostmap_row.FLDTYPE,1,1)='V' THEN
    --LAY THONG TIN THEO GLREF
    pv_errmsg:='Step check CA';

    IF v_cpostmap_row.CAMOD='CA' THEN
      --V?i ph?h? CA.
      --03 k? t? d?u l?o?i CA: ALLCODE CDTYPE=CA, CDNAME=CATYPE
      --N?u 02 k? t? cu?i l?A th?CNAME s? kh?ng t? 03 k? t? d?u
      --X?d?nh lo?i th?c hi?n quy?n CATYPE
      BEGIN
        IF v_currdate=pv_txdate THEN
          SELECT CATYPE INTO v_acfld_actype FROM TLLOG TL, TLLOGFLD DTL, FLDMASTER FLD, CAMAST
          WHERE TL.TXDATE=TO_DATE(pv_txdate,'DD/MM/RRRR') AND TL.TXNUM=pv_txnum AND TL.TXDATE=DTL.TXDATE AND TL.TXNUM=DTL.TXNUM
          AND TL.TLTXCD=FLD.OBJNAME AND FLD.DEFNAME='CAMASTID' AND DTL.CVALUE=CAMAST.CAMASTID;
        ELSE
          SELECT CATYPE INTO v_acfld_actype FROM TLLOGALL TL, TLLOGFLDALL DTL, FLDMASTER FLD, CAMAST
          WHERE TL.TXDATE=TO_DATE(pv_txdate,'DD/MM/RRRR') AND TL.TXNUM=pv_txnum AND TL.TXDATE=DTL.TXDATE AND TL.TXNUM=DTL.TXNUM
          AND TL.TLTXCD=FLD.OBJNAME AND FLD.DEFNAME='CAMASTID' AND DTL.CVALUE=CAMAST.CAMASTID;
        END IF;
        v_acfld_acname:=substr(v_cpostmap_row.ACNAME,4);
      END;
    ELSE
      v_acfld_actype:='';
    END IF;

    --X?d?nh nh?m GLGRP d? h?ch to?
    IF v_acfld_acname='CINETCLR' OR v_acfld_acname='CICLRTRFSELL' OR v_acfld_acname='CICLRTRFBUY' OR v_acfld_acname='CICLRBUY' OR v_acfld_acname='CICLRSELL' OR v_acfld_acname = 'CIMASTAR-8866' THEN
      IF v_tltxcd='8827' THEN
        --GIAO D?CH 8827 KH?G C?TRU?NG S? TI?U KHO?N CH?NG KHO?N N? PH?I L?Y TH? TRONG ODMAST
        --l?y s? hi?u l?nh
        IF v_currdate=pv_txdate THEN
          SELECT CVALUE INTO v_acreffld
          FROM TLLOGFLD TL WHERE TL.TXDATE=TO_DATE(pv_txdate,'DD/MM/RRRR') AND TL.TXNUM=pv_txnum AND FLDCD=v_cpostmap_row.REFFLD;
        ELSE
          SELECT CVALUE INTO v_acreffld
          FROM TLLOGFLDALL TL WHERE TL.TXDATE=TO_DATE(pv_txdate,'DD/MM/RRRR') AND TL.TXNUM=pv_txnum AND FLDCD=v_cpostmap_row.REFFLD;
        END IF;
        --l?y s? ti?u kho?n ch?ng kho?
        SELECT SEACCT INTO v_acreffld FROM
               (SELECT AFACCTNO || CODEID SEACCT FROM ODMAST WHERE ORDERID=v_acreffld UNION ALL
               SELECT AFACCTNO || CODEID SEACCT FROM ODMASTHIST WHERE ORDERID=v_acreffld );
      ELSE
        --L?y th?ng tin tru?ng tham chi?u (s? ti?u kho?n ch?ng kho?
        IF v_currdate=pv_txdate THEN
          SELECT CVALUE INTO v_acreffld
          FROM TLLOGFLD TL WHERE TL.TXDATE=TO_DATE(pv_txdate,'DD/MM/RRRR') AND TL.TXNUM=pv_txnum AND FLDCD=v_cpostmap_row.REFFLD;
        ELSE
          SELECT CVALUE INTO v_acreffld
          FROM TLLOGFLDALL TL WHERE TL.TXDATE=TO_DATE(pv_txdate,'DD/MM/RRRR') AND TL.TXNUM=pv_txnum AND FLDCD=v_cpostmap_row.REFFLD;
        END IF;
      END IF;

      pv_errmsg:='Get SE information 1: ' || v_acfld_acname || ', ACFLD=' || v_acfld || ', RFFLD=' || v_acreffld;
      --x? l? d?c bi?t cho t?kho?n ti?n thanh to?b? tr?: theo noi giao d?ch v?o?i ch?ng kho?      --v_acfld l??kho?n SE
      --MMM: k? t? thay th? l?h? tru?ng, SSS: k? t? thay th? l??h?ng kho?
      dbms_output.put_line(pv_errmsg);
      SELECT SBSECURITIES.SECTYPE, SBSECURITIES.TRADEPLACE, TYP.GLGRP
      INTO v_securities_type, v_tradeplace, v_acfld_glgrp
      FROM SBSECURITIES, CITYPE TYP, SEMAST MST, CIMAST CI
      WHERE CI.AFACCTNO=MST.AFACCTNO AND MST.CODEID=SBSECURITIES.CODEID AND TYP.ACTYPE = CI.ACTYPE
            AND MST.ACCTNO =v_acreffld AND CI.ACCTNO=v_acfld;
    END IF;

    pv_errmsg:='Get GLGRP: ' || v_acfld_acname || ', ACFLD=' || v_acfld;
    CASE
      WHEN v_entry_module='SE' THEN
        SELECT TYP.GLGRP, CF.CUSTODYCD, CF.FULLNAME INTO v_acfld_glgrp, v_acfld_custodycd, v_acfld_fullname
        FROM SEMAST DTL, SETYPE TYP, AFMAST AF, CFMAST CF
        WHERE CF.CUSTID=AF.CUSTID AND DTL.AFACCTNO=AF.ACCTNO AND DTL.ACTYPE=TYP.ACTYPE AND DTL.ACCTNO=v_acfld;
      WHEN v_entry_module='CI' THEN
        SELECT TYP.GLGRP, CF.CUSTODYCD, CF.FULLNAME INTO v_acfld_glgrp, v_acfld_custodycd, v_acfld_fullname
        FROM CIMAST DTL, CITYPE TYP, AFMAST AF, CFMAST CF
        WHERE CF.CUSTID=AF.CUSTID AND DTL.AFACCTNO=AF.ACCTNO AND DTL.ACTYPE=TYP.ACTYPE AND DTL.ACCTNO=v_acfld;
      WHEN v_entry_module='LN' THEN
        SELECT GLGRP, CUSTODYCD, FULLNAME INTO v_acfld_glgrp, v_acfld_custodycd, v_acfld_fullname
        FROM (SELECT TYP.GLGRP, CF.CUSTODYCD, CF.FULLNAME
        FROM LNMAST DTL, LNTYPE TYP, AFMAST AF, CFMAST CF
        WHERE CF.CUSTID=AF.CUSTID AND DTL.TRFACCTNO=AF.ACCTNO AND DTL.ACTYPE=TYP.ACTYPE AND DTL.ACCTNO=v_acfld
        UNION ALL SELECT TYP.GLGRP, CF.CUSTODYCD, CF.FULLNAME
        FROM LNMASTHIST DTL, LNTYPE TYP, AFMAST AF, CFMAST CF
        WHERE CF.CUSTID=AF.CUSTID AND DTL.TRFACCTNO=AF.ACCTNO AND DTL.ACTYPE=TYP.ACTYPE AND DTL.ACCTNO=v_acfld);
      WHEN v_entry_module='DF' THEN
        BEGIN
          SELECT GLGRP, CUSTODYCD, FULLNAME INTO v_acfld_glgrp, v_acfld_custodycd, v_acfld_fullname
          FROM (SELECT TYP.GLGRP, CF.CUSTODYCD, CF.FULLNAME
          FROM DFMAST DTL, DFTYPE TYP, AFMAST AF, CFMAST CF
          WHERE CF.CUSTID=AF.CUSTID AND DTL.AFACCTNO=AF.ACCTNO AND DTL.ACTYPE=TYP.ACTYPE AND DTL.ACCTNO=v_acfld
          UNION ALL SELECT TYP.GLGRP, CF.CUSTODYCD, CF.FULLNAME
          FROM DFMASTHIST DTL, DFTYPE TYP, AFMAST AF, CFMAST CF
          WHERE CF.CUSTID=AF.CUSTID AND DTL.AFACCTNO=AF.ACCTNO AND DTL.ACTYPE=TYP.ACTYPE AND DTL.ACCTNO=v_acfld);
        EXCEPTION
         WHEN OTHERS THEN
          SELECT TYP.GLGRP, '', '' INTO v_acfld_glgrp, v_acfld_custodycd, v_acfld_fullname
          FROM DFTYPE TYP WHERE TYP.ACTYPE=v_acfld;
        END;
    END CASE;

    --L?y s? t?kho?n k? to? theo GLGRP v?CNAME
    pv_errmsg:='Get GLGRP/ACNAME: ' || v_entry_module || '.' || v_acfld_acname || ', GLGRP=' || v_acfld_glgrp;
    dbms_output.put_line('Step 1 : '||v_entry_module||' - ' ||v_acfld_glgrp||' - '||v_acfld_acname||' - '||v_acfld_actype);
    IF v_cpostmap_row.CAMOD='CA' THEN
      SELECT ACCTNO INTO v_entry_acctno FROM GLREF
      WHERE APPTYPE=v_entry_module AND GLGRP=v_acfld_glgrp AND SUBSTR(ACNAME,4)=v_acfld_acname AND SUBSTR(ACNAME ,1,3)=v_acfld_actype;
    ELSE
      SELECT ACCTNO INTO v_entry_acctno FROM GLREF
      WHERE APPTYPE=v_entry_module AND GLGRP=v_acfld_glgrp AND ACNAME=v_acfld_acname;
    END IF;
  ELSE
    --dbms_output.put_line('2: '||v_entry_acctno);
    pv_errmsg:='Get information: ' || v_acfld_acname || ', ACFLD=' || v_cpostmap_row.ACFLD;
    IF v_acfld_acname='GLMAST' OR v_entry_acctno='GLMAST' THEN
      --N?u ACNAME l?LMAST th??y tr?c ti?p t? giao d?ch
      v_entry_acctno:=v_acfld;
    ELSE
      --N?u kh?ng l?y t? GLREFCOM
      v_entry_acctno:=v_cpostmap_row.ACCTNO;
    END IF;
  END IF;

  --x?d?nh s? t?kho?n h?ch to?  IF v_brid='0000' THEN
    --giao d?ch Batch th??y theo t?kho?n c?a kh? h?
    v_entry_acctno:=replace(v_entry_acctno,'____',SUBSTR(v_acfld,1,2) || '01');
  ELSE
    --giao d?ch manual th??y theo chi nh? t?o giao d?ch ho?c t?kho?n d?i ?ng
    v_entry_acctno:=replace(v_entry_acctno,'____',SUBSTR(v_brid,1,2) || '01');
  END IF;
  v_entry_acctno:=replace(v_entry_acctno,'####',SUBSTR(v_acfld,1,2) || '01');
  v_entry_acctno:=replace(v_entry_acctno,'MMM',v_tradeplace); --ALLCODE CDNAME=TRADEPLACE
  v_entry_acctno:=replace(v_entry_acctno,'SSS',v_securities_type);
  v_entry_acctno:=replace(v_entry_acctno,'AAAA',v_mapid);
dbms_output.put_line(v_acfld_acname);
  --X? L??C BI?T CHO T?I KHO?N TTBT LI? QUAN H?CH TO?N ?N TH? TRU?NG
  IF (v_acfld_acname='CICLRTRFSELL' OR v_acfld_acname='CICLRTRFBUY' OR v_acfld_acname='CICLRBUY' OR v_acfld_acname='CICLRSELL' or v_acfld_acname = 'CIMASTAR-8866') THEN
dbms_output.put_line('IN ' || v_acfld_acname);
dbms_output.put_line(v_tradeplace);
    --X? L?THEO S?N GIAO D?CH
    IF v_tradeplace='001' OR v_tradeplace='002' THEN  --HSX, HNX
    v_entry_acctno:=replace(v_entry_acctno,'E','0');
    END IF;
      IF v_tradeplace='005' THEN  --UPCOM
dbms_output.put_line('in UPCOM');
    v_entry_acctno:=replace(v_entry_acctno,'E','1');
    END IF;
    --X? L?CHO LO?I KH?CH H?NG
    IF length(v_acfld_custodycd)=10 THEN
    IF SUBSTR(v_acfld_custodycd,4,1)='F' THEN  --KH?CH H?NG NU?C NGO?I
      IF (v_acfld_acname = 'CICLRTRFSELL' or v_acfld_acname='CICLRTRFBUY')  AND v_tradeplace = '005' THEN
            v_entry_acctno:=replace(v_entry_acctno,'CCC','326');
      ELSE
      v_entry_acctno:=replace(v_entry_acctno,'CCC','325');
      END IF;
    END IF;
    IF SUBSTR(v_acfld_custodycd,4,1)='C' THEN  --KH?CH H?NG TRONG NU?C
      IF (v_acfld_acname = 'CICLRTRFSELL' or v_acfld_acname='CICLRTRFBUY')  AND v_tradeplace = '005' THEN
            v_entry_acctno:=replace(v_entry_acctno,'CCC','324');
      ELSE
      v_entry_acctno:=replace(v_entry_acctno,'CCC','323');
      END IF;
    END IF;
    IF SUBSTR(v_acfld_custodycd,4,1)='P' THEN  --T? DOANH
      IF (v_acfld_acname = 'CICLRTRFSELL' or v_acfld_acname='CICLRTRFBUY')  AND v_tradeplace = '005' THEN
            v_entry_acctno:=replace(v_entry_acctno,'CCC','002');
      ELSE
      v_entry_acctno:=replace(v_entry_acctno,'CCC','001');
      END IF;
    END IF;
    END IF;
  END IF;

  pv_errmsg:='Generate account number';
  --th?c hi?n t? to?bi?u th?c
  v_acfld_amtexp:=v_cpostmap_row.AMTEXP;
  v_pos_amtexp:=1;
  v_expression:='';
  WHILE v_pos_amtexp<length(v_acfld_amtexp) LOOP
    pv_errmsg:='Generate account number 1';
      v_evaluator:=substr(v_acfld_amtexp,v_pos_amtexp,2);
      v_pos_amtexp:=v_pos_amtexp+2;
      IF (v_evaluator='++' OR  v_evaluator='--' OR  v_evaluator='**' OR  v_evaluator='//' OR  v_evaluator='((' OR v_evaluator='))') THEN
         v_expression:=v_expression || SUBSTR(v_evaluator,1,1);
      ELSE
         BEGIN
            pv_errmsg:='Get data value: ' || v_evaluator;
            IF v_currdate=pv_txdate THEN
                IF v_evaluator = 'FF' THEN
                    BEGIN
                        SELECT NAMT INTO v_amount FROM CITRAN WHERE TXDATE=TO_DATE(pv_txdate,'DD/MM/RRRR') AND TXNUM=pv_txnum AND TXCD = v_cpostmap_row.txcd;
                    EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                            v_amount := 0;
                    END;
                ELSE
                    SELECT NVALUE+TO_NUMBER(NVL(CVALUE,0)) INTO v_amount FROM TLLOGFLD TL
                    WHERE TXDATE=TO_DATE(pv_txdate,'DD/MM/RRRR') AND TXNUM=pv_txnum AND FLDCD=v_evaluator;
                END IF;
            ELSE
                IF v_evaluator = 'FF' THEN
                    SELECT NAMT INTO v_amount FROM CITRANA WHERE TXDATE=TO_DATE(pv_txdate,'DD/MM/RRRR') AND TXNUM=pv_txnum AND TXCD = v_cpostmap_row.txcd;
                ELSE
                    SELECT NVALUE+TO_NUMBER(NVL(CVALUE,0)) INTO v_amount FROM TLLOGFLDALL TL
                    WHERE TXDATE=TO_DATE(pv_txdate,'DD/MM/RRRR') AND TXNUM=pv_txnum AND FLDCD=v_evaluator;
                END IF;
            END IF;
            pv_errmsg:='Got amount: ' || v_amount;
            v_expression:=v_expression || v_amount;
            pv_errmsg:='Expression: ' || v_expression;
         END;
      END IF;
  END LOOP;

  --v_expression:='begin :out_var := ' || v_expression || '; end;';
  --execute immediate v_expression using out v_acfld_amount;
  v_expression:='UPDATE EVAL_EXPRESSTION SET EVAL=' || v_expression;
dbms_output.put_line(v_expression);
  execute immediate v_expression;
  pv_errmsg:='Evaluate: ' || v_expression;
  -- Fix lam tron
  IF v_tltxcd in ('1162','0066','1116','2642','2643','5567','8855') THEN
    SELECT ROUND(EVAL,0) INTO v_acfld_amount FROM EVAL_EXPRESSTION;
  ELSE
    SELECT EVAL INTO v_acfld_amount FROM EVAL_EXPRESSTION;
  END IF;
  pv_errmsg:='Evaluate: ' || v_expression;
dbms_output.put_line(pv_errmsg);
  pv_errmsg:='Booking amount: ' || v_acfld_amount;
dbms_output.put_line(pv_errmsg);
dbms_output.put_line('ACC:' || v_entry_acctno);
  IF v_cpostmap_row.DORC='D' THEN
    BEGIN
      v_debit_acctno:=v_entry_acctno;
      v_credit_acctno:='';
    END;
  ELSE
    BEGIN
      v_debit_acctno:='';
      v_credit_acctno:=v_entry_acctno;
    END;
  END IF;
/*
  -- XU LY RIENG CHO 8865
  IF v_cpostmap_row.TLTXCD = '8865' THEN
    select sbdate INTO v_txdate from (
                    select sbdate from sbcldr where cldrtype = '000' and holiday = 'N' and sbdate > to_date(pv_txdate,'dd/mm/yyyy')
                order by sbdate asc) where rownum=1;
  ELSE
    v_txdate := TO_DATE(pv_txdate,'DD/MM/RRRR');
  END IF;*/
  --ghi nh?n v?Log
  IF v_acfld_amount<>0 THEN
    --b? 06 k? t? d?u trong Back thay b?ng 01 trong EBS

    -- XU LY RIENG CHO CHI NHANH HA NOI
    BEGIN
    SELECT ACCTNO INTO v_debit_acctno FROM GLMAPPING WHERE ORGACCTNO = v_debit_acctno AND BRID = v_brid;
    EXCEPTION WHEN NO_DATA_FOUND THEN
        NULL;
    END;
    BEGIN
    SELECT ACCTNO INTO v_credit_acctno FROM GLMAPPING WHERE ORGACCTNO = v_credit_acctno AND BRID = v_brid;
    EXCEPTION WHEN NO_DATA_FOUND THEN
        NULL;
    END;
    -- END

    -- Xu ly rieng ccho gd 8855/8856

    IF v_tltxcd IN ('8855','8856') THEN
    pv_errmsg:='Get Orderid, TXNUM, VIA:' || pv_txnum;
    SELECT A.ORDERID, A.TXNUM, A.TXDATE, A.VIA INTO v_orderid, v_ordertxnum, v_ordertxdate, v_via
    FROM VW_TLLOGFLD_ALL C, VW_ODMAST_ALL A
    WHERE C.FLDCD = '03' AND c.TXNUM = pv_txnum AND c.TXDATE = TO_DATE(pv_txdate,'DD/MM/RRRR') AND C.CVALUE = A.ORDERID;
    pv_errmsg := pv_errmsg || 'Getting BRID for 8855/8856.ORDERID:' || v_orderid;
    IF v_via = 'O' THEN
        v_brid := '0001';
    ELSIF v_via = 'B' THEN
    BEGIN
        SELECT DISTINCT B.BRID INTO v_brid FROM VW_FOMAST_ALL A, TLPROFILES B WHERE ORGACCTNO = v_orderid AND A.USERNAME = B.TLID;
    EXCEPTION WHEN no_data_found THEN
        SELECT DISTINCT B.BRID INTO v_brid FROM VW_FOMAST_ALL A, TLPROFILES B, VW_ROOTORDERMAP_ALL C WHERE ACCTNO = C.FOACCTNO AND A.USERNAME = B.TLID AND C.ORDERID = v_orderid;
    END;
    ELSE
        SELECT BRID INTO v_brid FROM VW_TLLOG_ALL WHERE TXNUM = v_ordertxnum AND TXDATE = v_ordertxdate;
    END IF;
    END IF;
    pv_errmsg:='Log to GLLOGHIST';

    if length(v_cpostmap_row.trdesc)>0 then
        SP_Generate_gltxdesc(v_cpostmap_row.TLTXCD,pv_txnum, pv_txdate, v_cpostmap_row.trdesc, v_notes);
    end if;

    INSERT INTO GLLOGHIST (AUTOID, TXDATE, TXNUM, BRID, TRANS_TYPE, DESCRIPTION, ACFLDACCTNO, DRACCTNO, CRACCTNO, AMOUNT,
      ACMODULE, GLGRP, CUSTOMER_NUMBER, CUSTOMER_NAME, BUSDATE, SUBTXNO, CREATEDDT, CREATEDTM)
    SELECT SEQ_GLLOGHIST.NEXTVAL, TO_DATE(pv_txdate,'DD/MM/RRRR'), pv_txnum, (SELECT MAPID FROM BRGRP WHERE BRID = v_brid), v_cpostmap_row.TLTXCD, v_notes, v_acfld, v_debit_acctno, v_credit_acctno, v_acfld_amount,
      v_entry_module, v_acfld_glgrp, v_acfld_custodycd, v_acfld_fullname, v_busdate, v_cpostmap_row.SUBTXNO, SYSDATE, SYSTIMESTAMP FROM DUAL;
    END IF;
            dbms_output.put_line('End loop');
END LOOP;
CLOSE v_cursor_postmap;
pv_errmsg:='';
COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    v_code := SQLCODE;
    v_errm := SUBSTR(SQLERRM, 1, 64);
    dbms_output.put_line('ERROR');
    INSERT INTO errors (code, message, logdetail, happened) VALUES (v_code, v_errm, v_tltxcd || '.SP_GENERATE_TXPOSTMAP:' || pv_txdate || '.' || pv_txnum || '-' || pv_errmsg, SYSTIMESTAMP);
END;

 
 
 
 
/
