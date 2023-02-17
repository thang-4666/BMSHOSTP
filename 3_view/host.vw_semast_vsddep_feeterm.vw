SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW VW_SEMAST_VSDDEP_FEETERM
(AFACCTNO, ACCTNO, TBALDT, AUTOID, FORP, 
 FEEAMT, LOTDAY, LOTVAL, ROUNDTYP, SEBAL, 
 ODRNUM, TYPE, AMT_TEMP, SECTYPE)
BEQUEATH DEFINER
AS 
SELECT SE.AFACCTNO, SE.ACCTNO, SE.TBALDT, RF.ACTYPE AUTOID, RF.FORP,
(CASE WHEN sb.issedepofee='Y' THEN  RF.FEEAMT ELSE 0 END) FEEAMT, RF.LOTDAY, RF.LOTVAL, RF.ROUNDTYP,
(se.trade + se.margin + se.mortage + se.blocked + se.secured + se.repo + se.netting + se.dtoclose + se.withdraw+se.emkqtty+ se.blockdtoclose + se.blockwithdraw) SEBAL, 0 ODRNUM,
'E' TYPE,
CASE WHEN sb.issedepofee='Y' THEN
ROUND((se.trade + se.margin + se.mortage + se.blocked + se.secured + se.repo + se.netting + se.dtoclose + se.withdraw+se.emkqtty+ se.blockdtoclose + se.blockwithdraw)*
(DECODE(RF.FORP,'P',RF.FEEAMT/100,RF.FEEAMT)/(RF.LOTDAY*RF.LOTVAL)),8)
ELSE 0 END
 AMT_TEMP, SB.SECTYPE
FROM SEMAST SE, CIMAST MST,(select  * from cifeedef_ext where  getcurrdate between valdate   and expdate) RF,AFMAST AF, CFMAST CF, sbsecurities sb,CIFEEDEF_EXTLNK LNK
WHERE RF.STATUS='A'
AND (se.trade + se.margin + se.mortage + se.blocked + se.secured + se.repo + se.netting + se.dtoclose + se.withdraw+se.emkqtty+ se.blockdtoclose + se.blockwithdraw )>0
AND MST.AFACCTNO=SE.AFACCTNO AND nvl( RF.CODEID,SE.CODEID)=SE.CODEID
AND SE.AFACCTNO=AF.ACCTNO AND AF.STATUS IN ('A','P','G','B') --Ngay 12/01/2017 NamTv them trang thai tieu khoan phong toa
AND CF.CUSTID=AF.CUSTID AND CF.CUSTATCOM='Y'
AND (SB.SECTYPE= decode(RF.SECTYPE,'000',sb.SECTYPE, rf.sectype) OR DECODE(SB.SECTYPE,'001','111','002','111','007','111','008','111','003','222','006','222','')=RF.SECTYPE)
AND se.codeid=SB.CODEID
AND RF.ACTYPE=LNK.ACTYPE AND LNK.Afacctno=AF.ACCTNO AND LNK.STATUS='A'
AND SB.SECTYPE <> '004'
UNION ALL
--THEO TRADEPLACE
SELECT SE.AFACCTNO, SE.ACCTNO, SE.TBALDT, RF.ACTYPE AUTOID, RF.FORP,
(CASE WHEN sb.issedepofee='Y' THEN  RF.FEEAMT ELSE 0 END) FEEAMT, RF.LOTDAY, RF.LOTVAL, RF.ROUNDTYP,
(se.trade + se.margin + se.mortage + se.blocked + se.secured + se.repo + se.netting + se.dtoclose + se.withdraw+se.emkqtty+ se.blockdtoclose + se.blockwithdraw) SEBAL, 0 ODRNUM,
'E' TYPE,
CASE WHEN sb.issedepofee='Y' THEN
ROUND((se.trade + se.margin + se.mortage + se.blocked + se.secured + se.repo + se.netting + se.dtoclose + se.withdraw+se.emkqtty+ se.blockdtoclose + se.blockwithdraw)*
(DECODE(RF.FORP,'P',RF.FEEAMT/100,RF.FEEAMT)/(RF.LOTDAY*RF.LOTVAL)),8)
ELSE 0 END AMT_TEMP, SB.SECTYPE
FROM SBSECURITIES SB, SEMAST SE, CIMAST MST, (select  * from cifeedef_ext where  getcurrdate between valdate   and expdate) RF,AFMAST AF,CFMAST CF,CIFEEDEF_EXTLNK LNK
WHERE  RF.STATUS='A'
AND (se.trade + se.margin + se.mortage + se.blocked + se.secured + se.repo + se.netting + se.dtoclose + se.withdraw+se.emkqtty+ se.blockdtoclose + se.blockwithdraw)>0
AND MST.AFACCTNO=SE.AFACCTNO AND SB.CODEID=SE.CODEID AND SB.TRADEPLACE=RF.TRADEPLACE AND RF.CODEID IS NULL
AND (SB.SECTYPE= decode(RF.SECTYPE,'000',sb.SECTYPE, rf.sectype) OR DECODE(SB.SECTYPE,'001','111','002','111','007','111','008','111','003','222','006','222','')=RF.SECTYPE)
AND SE.AFACCTNO=AF.ACCTNO AND AF.STATUS IN ('A','P','G','B') --Ngay 12/01/2017 NamTv them trang thai tieu khoan phong toa
AND CF.CUSTID=AF.CUSTID AND CF.CUSTATCOM='Y'
AND RF.ACTYPE=LNK.ACTYPE AND LNK.Afacctno=AF.ACCTNO AND LNK.STATUS='A'
AND SB.SECTYPE <> '004'
UNION ALL
--DEFAULT THEO SECTYPE
SELECT SE.AFACCTNO, SE.ACCTNO, SE.TBALDT, RF.ACTYPE AUTOID, RF.FORP,
(CASE WHEN sb.issedepofee='Y' THEN  RF.FEEAMT ELSE 0 END) FEEAMT, RF.LOTDAY, RF.LOTVAL, RF.ROUNDTYP,
(se.trade + se.margin + se.mortage + se.blocked + se.secured + se.repo + se.netting + se.dtoclose + se.withdraw+se.emkqtty+ se.blockdtoclose + se.blockwithdraw) SEBAL, 0 ODRNUM,
'E' TYPE,
CASE WHEN sb.issedepofee='Y' THEN
ROUND((se.trade + se.margin + se.mortage + se.blocked + se.secured + se.repo + se.netting + se.dtoclose + se.withdraw+se.emkqtty+ se.blockdtoclose + se.blockwithdraw)*
(DECODE(RF.FORP,'P',RF.FEEAMT/100,RF.FEEAMT)/(RF.LOTDAY*RF.LOTVAL)),8)
ELSE 0 END
 AMT_TEMP, SB.SECTYPE
FROM SBSECURITIES SB, SEMAST SE, CIMAST MST, (select  * from cifeedef_ext where  getcurrdate between valdate   and expdate) RF,AFMAST AF,CFMAST CF,CIFEEDEF_EXTLNK LNK
WHERE  RF.STATUS='A'
AND (se.trade + se.margin + se.mortage + se.blocked + se.secured + se.repo + se.netting + se.dtoclose + se.withdraw+se.emkqtty+ se.blockdtoclose + se.blockwithdraw)>0
AND MST.AFACCTNO=SE.AFACCTNO AND SB.CODEID=SE.CODEID AND RF.TRADEPLACE='000' AND RF.CODEID IS NULL
AND (SB.SECTYPE= decode(RF.SECTYPE,'000',sb.SECTYPE, rf.sectype) OR DECODE(SB.SECTYPE,'001','111','002','111','007','111','008','111','003','222','006','222','')=RF.SECTYPE)
AND SE.AFACCTNO=AF.ACCTNO AND AF.STATUS IN ('A','P','G','B') --Ngay 12/01/2017 NamTv them trang thai tieu khoan phong toa
AND CF.CUSTID=AF.CUSTID AND CF.CUSTATCOM='Y'
AND RF.ACTYPE=LNK.ACTYPE AND LNK.Afacctno=AF.ACCTNO AND LNK.STATUS='A'
AND SB.SECTYPE <> '004'
--end of PhuongHT edit
UNION ALL -- cac bieu phi thuong
SELECT SE.AFACCTNO, SE.ACCTNO, SE.TBALDT, TO_CHAR(RF.AUTOID) AUTOID, RF.FORP,
(CASE WHEN sb.issedepofee='Y' THEN  RF.FEEAMT ELSE 0 END) FEEAMT, RF.LOTDAY, RF.LOTVAL, RF.ROUNDTYP,
(se.trade + se.margin + se.mortage + se.blocked + se.secured + se.repo + se.netting + se.dtoclose + se.withdraw+se.emkqtty+ se.blockdtoclose + se.blockwithdraw) SEBAL, 1 ODRNUM,
'N' TYPE,
CASE WHEN sb.issedepofee='Y' THEN
ROUND((se.trade + se.margin + se.mortage + se.blocked + se.secured + se.repo + se.netting + se.dtoclose + se.withdraw+se.emkqtty+ se.blockdtoclose + se.blockwithdraw)*
(DECODE(RF.FORP,'P',RF.FEEAMT/100,RF.FEEAMT)/(RF.LOTDAY*RF.LOTVAL)),8)
ELSE 0 END
 AMT_TEMP, SB.SECTYPE
FROM SEMAST SE, CIMAST MST, CITYPE TYP, CIFEEDEF RF,AFMAST AF, CFMAST CF, sbsecurities sb
WHERE TYP.ACTYPE=MST.ACTYPE AND TYP.ACTYPE=RF.ACTYPE AND RF.FEETYPE='VSDDEP' AND RF.STATUS='A'
AND (se.trade + se.margin + se.mortage + se.blocked + se.secured + se.repo + se.netting + se.dtoclose + se.withdraw+se.emkqtty+ se.blockdtoclose + se.blockwithdraw)>0
AND MST.AFACCTNO=SE.AFACCTNO AND RF.CODEID=SE.CODEID
AND SE.AFACCTNO=AF.ACCTNO AND AF.STATUS IN ('A','P','G','B') --Ngay 12/01/2017 NamTv them trang thai tieu khoan phong toa
AND CF.CUSTID=AF.CUSTID AND CF.CUSTATCOM='Y'
AND se.codeid=sb.codeid
AND SB.SECTYPE <> '004'
UNION ALL
--THEO TRADEPLACE
SELECT SE.AFACCTNO, SE.ACCTNO, SE.TBALDT, TO_CHAR(RF.AUTOID) AUTOID, RF.FORP,
(CASE WHEN sb.issedepofee='Y' THEN  RF.FEEAMT ELSE 0 END) FEEAMT, RF.LOTDAY, RF.LOTVAL, RF.ROUNDTYP,
(se.trade + se.margin + se.mortage + se.blocked + se.secured + se.repo + se.netting + se.dtoclose + se.withdraw+se.emkqtty+ se.blockdtoclose + se.blockwithdraw) SEBAL, 1 ODRNUM,
'N' TYPE,
CASE WHEN sb.issedepofee='Y' THEN
ROUND((se.trade + se.margin + se.mortage + se.blocked + se.secured + se.repo + se.netting + se.dtoclose + se.withdraw+se.emkqtty+ se.blockdtoclose + se.blockwithdraw)*
(DECODE(RF.FORP,'P',RF.FEEAMT/100,RF.FEEAMT)/(RF.LOTDAY*RF.LOTVAL)),8)
ELSE 0 END
 AMT_TEMP, SB.SECTYPE
FROM SBSECURITIES SB, SEMAST SE, CIMAST MST, CITYPE TYP, CIFEEDEF RF,AFMAST AF,CFMAST CF
WHERE TYP.ACTYPE=MST.ACTYPE AND TYP.ACTYPE=RF.ACTYPE AND RF.FEETYPE='VSDDEP' AND RF.STATUS='A'
AND (se.trade + se.margin + se.mortage + se.blocked + se.secured + se.repo + se.netting + se.dtoclose + se.withdraw+se.emkqtty+ se.blockdtoclose + se.blockwithdraw)>0
AND MST.AFACCTNO=SE.AFACCTNO AND SB.CODEID=SE.CODEID AND SB.TRADEPLACE=RF.TRADEPLACE AND RF.CODEID IS NULL
AND (SB.SECTYPE= decode(RF.SECTYPE,'000',sb.SECTYPE, rf.sectype) OR DECODE(SB.SECTYPE,'001','111','002','111','007','111','008','111','003','222','006','222','')=RF.SECTYPE)
AND SE.AFACCTNO=AF.ACCTNO AND AF.STATUS IN ('A','P','G','B') --Ngay 12/01/2017 NamTv them trang thai tieu khoan phong toa
AND CF.CUSTID=AF.CUSTID AND CF.CUSTATCOM='Y'
AND SB.SECTYPE <> '004'
UNION ALL
--DEFAULT THEO SECTYPE
SELECT SE.AFACCTNO, SE.ACCTNO, SE.TBALDT,  TO_CHAR(RF.AUTOID) AUTOID, RF.FORP,
(CASE WHEN sb.issedepofee='Y' THEN  RF.FEEAMT ELSE 0 END) FEEAMT, RF.LOTDAY, RF.LOTVAL, RF.ROUNDTYP,
(se.trade + se.margin + se.mortage + se.blocked + se.secured + se.repo + se.netting + se.dtoclose + se.withdraw+se.emkqtty+ se.blockdtoclose + se.blockwithdraw) SEBAL, 1 ODRNUM,
'N' TYPE,
CASE WHEN sb.issedepofee='Y' THEN
ROUND((se.trade + se.margin + se.mortage + se.blocked + se.secured + se.repo + se.netting + se.dtoclose + se.withdraw+se.emkqtty+ se.blockdtoclose + se.blockwithdraw)*
(DECODE(RF.FORP,'P',RF.FEEAMT/100,RF.FEEAMT)/(RF.LOTDAY*RF.LOTVAL)),8)
ELSE 0 END
AMT_TEMP, SB.SECTYPE
FROM SBSECURITIES SB, SEMAST SE, CIMAST MST, CITYPE TYP, CIFEEDEF RF,AFMAST AF,CFMAST CF
WHERE TYP.ACTYPE=MST.ACTYPE AND TYP.ACTYPE=RF.ACTYPE AND RF.FEETYPE='VSDDEP' AND RF.STATUS='A'
AND (se.trade + se.margin + se.mortage + se.blocked + se.secured + se.repo + se.netting + se.dtoclose + se.withdraw+se.emkqtty+ se.blockdtoclose + se.blockwithdraw)>0
AND MST.AFACCTNO=SE.AFACCTNO AND SB.CODEID=SE.CODEID AND RF.TRADEPLACE='000' AND RF.CODEID IS NULL
AND (SB.SECTYPE= decode(RF.SECTYPE,'000',sb.SECTYPE, rf.sectype) OR DECODE(SB.SECTYPE,'001','111','002','111','007','111','008','111','003','222','006','222','')=RF.SECTYPE)
AND SE.AFACCTNO=AF.ACCTNO AND AF.STATUS IN ('A','P','G','B') --Ngay 12/01/2017 NamTv them trang thai tieu khoan phong toa
AND CF.CUSTID=AF.CUSTID AND CF.CUSTATCOM='Y'
AND SB.SECTYPE <> '004'
/
