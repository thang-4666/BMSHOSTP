SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW V_CA3379
(AUTOID, BALANCE, CAMASTID, AFACCTNO, CATYPE, 
 CODEID, EXCODEID, QTTY, AMT, AQTTY, 
 AAMT, SYMBOL, STATUS, SEACCTNO, EXSEACCTNO, 
 PARVALUE, EXPARVALUE, REPORTDATE, ACTIONDATE, POSTINGDATE, 
 DESCRIPTION, TASKCD, DUTYAMT, FULLNAME, IDCODE, 
 CUSTODYCD, ISINCODE)
BEQUEATH DEFINER
AS 
(SELECT CA.AUTOID, CA.BALANCE, SUBSTR(CA.CAMASTID,1,4) || '.' || SUBSTR(CA.CAMASTID,5,6) || '.' || SUBSTR(CA.CAMASTID,11,6) CAMASTID, CA.AFACCTNO,A0.CDCONTENT CATYPE, CA.CODEID, CA.EXCODEID, CA.QTTY, ROUND(CA.AMT) AMT, ROUND(CA.AQTTY) AQTTY,
       ROUND(CA.AAMT) AAMT, SYM.SYMBOL, A1.CDCONTENT STATUS,CASE WHEN camast.catype = '017' THEN CA.AFACCTNO || CA.EXCODEID ELSE CA.AFACCTNO || CA.CODEID END SEACCTNO,
        CASE WHEN camast.catype = '017' THEN CA.AFACCTNO || CA.CODEID else CA.AFACCTNO || (CASE WHEN CAMAST.EXCODEID IS NULL THEN CAMAST.CODEID ELSE CAMAST.EXCODEID END) end EXSEACCTNO,
       SYM.PARVALUE PARVALUE, EXSYM.PARVALUE EXPARVALUE, CAMAST.REPORTDATE REPORTDATE, CAMAST.ACTIONDATE ,CAMAST.ACTIONDATE  POSTINGDATE,
      (CASE WHEN SUBSTR(CF.custodycd,4,1) = 'F' AND CAMAST.catype ='010'  THEN to_char( 'Cash dividend, '||SYM.SYMBOL ||', exdate on ' || to_char (camast.reportdate,'DD/MM/YYYY')||', yield ' ||camast.DEVIDENTRATE ||'%, '|| cf.fullname )
      WHEN NVL(SUBSTR(CF.custodycd,4,1),'C') in('C','P') AND CAMAST.catype ='010'  THEN to_char( 'Cổ tức bằng tiền, '||SYM.SYMBOL ||', ngày chốt ' || to_char (camast.reportdate,'DD/MM/YYYY')||', tỉ lệ ' ||camast.DEVIDENTRATE ||'%, '|| cf.fullname )
      WHEN SUBSTR(CF.custodycd,4,1) = 'F' AND CAMAST.catype ='011'  THEN to_char( 'Dividend in kind, '||SYM.SYMBOL ||' , exdate on ' || to_char (camast.reportdate,'DD/MM/YYYY')||', ratio ' ||camast.DEVIDENTSHARES ||', '|| cf.fullname )
      WHEN NVL(SUBSTR(CF.custodycd,4,1),'C') in('C','P') AND CAMAST.catype ='011'  THEN to_char( 'Cổ tức bằng cổ phiếu, '||SYM.SYMBOL ||', ngày chốt ' || to_char (camast.reportdate,'DD/MM/YYYY')||', tỉ lệ ' ||camast.DEVIDENTSHARES ||', '|| cf.fullname )
      WHEN SUBSTR(CF.custodycd,4,1) = 'F' AND CAMAST.catype ='014'  THEN  to_char('Secondary offer shares, '||SYM.SYMBOL ||', Exdate on ' || to_char (camast.reportdate,'DD/MM/YYYY')||', ratio ' ||camast.RIGHTOFFRATE ||', '|| cf.fullname  )
      WHEN NVL(SUBSTR(CF.custodycd,4,1),'C')  in('C','P') AND CAMAST.catype ='014'  THEN  to_char('Cổ phiếu mua thêm, '||SYM.SYMBOL ||', ngày chốt ' || to_char (camast.reportdate,'DD/MM/YYYY')||',tỉ lệ ' ||camast.RIGHTOFFRATE ||', '|| cf.fullname  )
      WHEN NVL(SUBSTR(CF.custodycd,4,1),'C')  in('C','P') AND CAMAST.catype ='021'  THEN  to_char('Cổ phiếu thưởng, '||SYM.SYMBOL ||', ngày chốt ' || to_char (camast.reportdate,'DD/MM/YYYY')||', tỉ lệ ' ||camast.DEVIDENTSHARES ||', '|| cf.fullname  )
      WHEN NVL(SUBSTR(CF.custodycd,4,1),'C')  = 'F' AND CAMAST.catype ='021'  THEN  to_char('Bonus share, '||SYM.SYMBOL ||', exdate on ' || to_char (camast.reportdate,'DD/MM/YYYY')||', Rate ' ||camast.DEVIDENTSHARES ||', '|| cf.fullname  )
      WHEN SUBSTR(CF.custodycd,4,1) = 'F' AND CAMAST.catype ='012'  THEN  to_char('Stock split, '||SYM.SYMBOL ||', exdate on ' || to_char (camast.reportdate,'DD/MM/YYYY')||', ratio ' ||camast.SPLITRATE ||', '|| cf.fullname  )
      WHEN SUBSTR(CF.custodycd,4,1) = 'F' AND CAMAST.catype ='013'  THEN  to_char('Stock merge, '||SYM.SYMBOL ||', exdate on ' || to_char (camast.reportdate,'DD/MM/YYYY')||', ratio ' ||camast.SPLITRATE ||', '|| cf.fullname  )
      WHEN NVL(SUBSTR(CF.custodycd,4,1),'C')  in ('C','P') AND CAMAST.catype ='013'  THEN  to_char('Gộp cổ phiếu, '||SYM.SYMBOL ||', ngày chốt ' || to_char (camast.reportdate,'DD/MM/YYYY')||', tỉ lệ ' ||camast.SPLITRATE ||', '|| cf.fullname  )
      else  camast.description END)description, camast.taskcd,
      (CASE WHEN cf.VAT='Y' THEN SYS.VARVALUE*CA.AMT/100 ELSE 0 END) DUTYAMT, CF.FULLNAME, CF.IDCODE, CF.CUSTODYCD, camast.isincode
FROM CASCHD CA, SBSECURITIES SYM, SBSECURITIES EXSYM, ALLCODE A0, ALLCODE A1, CAMAST, AFMAST AF , CFMAST CF , AFTYPE TYP, SYSVAR SYS
WHERE A0.CDTYPE = 'CA' AND A0.CDNAME = 'CATYPE' AND A0.CDVAL = CAMAST.CATYPE
AND A1.CDTYPE = 'CA' AND A1.CDNAME = 'CASTATUS' AND A1.CDVAL = CA.STATUS
AND CA.CAMASTID = CAMAST.CAMASTID AND CAMAST.CODEID = SYM.CODEID
AND CA.AFACCTNO = AF.ACCTNO AND AF.CUSTID = CF.CUSTID
AND CA.DELTD ='N' AND CA.STATUS ='S' and CAMAST.STATUS ='I' AND CA.ISCI ='N' AND CA.ISSE='N'
AND AF.ACTYPE = TYP.ACTYPE AND SYS.GRNAME='SYSTEM' AND SYS.VARNAME='CADUTY'
AND EXSYM.CODEID = (CASE WHEN CAMAST.EXCODEID IS NULL THEN CAMAST.CODEID ELSE CAMAST.EXCODEID END)
)
/
