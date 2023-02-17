SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "GETORDERBOOKONHAND" (PV_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR,pv_AFACCTNO IN VARCHAR2)
  IS

BEGIN

  OPEN PV_REFCURSOR FOR
      SELECT * FROM (
                      SELECT MST.TXDATE, MST.REFORDERID, MST.AFACCTNO, MST.orderid ACCTNO, '' ORGACCTNO, MST.EXECTYPE,MST.REFORDERID REFACCTNO,
                      MST.PRICETYPE, CD2.cdcontent DESC_EXECTYPE, TO_CHAR(sb.SYMBOL) SYMBOL, MST.exqtty QUANTITY, MST.exprice PRICE,   TO_CHAR(CD0.cdcontent) feedbackmsg,
                      MST.QUOTEPRICE, 'Active' DESC_BOOK, MST.orstatus status, CD1.cdcontent DESC_STATUS, CD4.cdcontent DESC_TIMETYPE,
                      CD5.cdcontent DESC_MATCHTYPE, CD6.cdcontent DESC_NORK, CD7.cdcontent DESC_PRICETYPE,
                      MST.EXECQTTY, MST.EXECAMT, (CASE WHEN MST.EXECQTTY>0 THEN ROUND(MST.EXECAMT/1000/MST.EXECQTTY,2) ELSE 0 END) AVEXECPRICE, MST.REMAINQTTY, mst.txtime, mst.CANCELQTTY, mst.ADJUSTQTTY,'A' BOOK,CD8.cdcontent VIA,mst.VIA VIACD,
                      (CASE WHEN MST.CANCELQTTY>0 THEN 'Cancelled'  WHEN MST.EDITSTATUS='C' THEN 'Cancelling' ELSE '----' END) CANCELSTATUS,(CASE WHEN MST.ADJUSTQTTY>0 THEN 'Amended'  WHEN MST.EDITSTATUS='A' THEN 'Amending' ELSE '----' END) AMENDSTATUS,
                      SYS.SYSVALUE CURRSECSSION,MST.HOSESESSION ODSECSSION, nvl(f.username,nvl(mk.tlname,'Auto')) maker
                      FROM AFMAST CF,(SELECT OD1.*,OD2.EDSTATUS EDITSTATUS from odmast OD1,(SELECT * FROM ODMAST WHERE EDSTATUS IN ('C','A')) OD2   WHERE OD1.ORDERID=OD2.REFORDERID(+)) MST,TLLOG TL, sbsecurities sb,
                      ALLCODE CD0,ALLCODE CD1, ALLCODE CD2, ALLCODE CD4, ALLCODE CD5, ALLCODE CD6, ALLCODE CD7, ALLCODE CD8,ORDERSYS SYS,tlprofiles mk,fomast f
                      WHERE MST.ORSTATUS <> '7' AND CF.ACCTNO=MST.AFACCTNO AND CF.ACCTNO =pv_AFACCTNO
                      AND MST.TXNUM=TL.TXNUM AND MST.TXDATE=TL.TXDATE AND TL.TXSTATUS='1'
                      and sb.codeid = mst.codeid
                      AND CD0.CDNAME = 'ORSTATUS' AND CD0.CDTYPE ='OD' AND CD0.CDVAL=MST.ORSTATUS
                      AND CD1.cdtype ='OD' AND CD1.CDNAME='ORSTATUS' AND CD1.CDVAL=MST.orstatus
                      AND SYS.SYSNAME='CONTROLCODE'
                      AND CD2.cdtype ='OD' AND CD2.CDNAME='EXECTYPE' AND CD2.CDVAL=MST.EXECTYPE
                      AND CD4.cdtype ='OD' AND CD4.CDNAME='TIMETYPE' AND CD4.CDVAL=MST.TIMETYPE
                      AND CD5.cdtype ='OD' AND CD5.CDNAME='MATCHTYPE' AND CD5.CDVAL=MST.MATCHTYPE
                      AND CD6.cdtype ='OD' AND CD6.CDNAME='NORK' AND CD6.CDVAL=MST.NORK
                      AND CD8.cdtype ='OD' AND CD8.CDNAME='VIA' AND CD8.CDVAL=MST.VIA
                      AND MST.TXDATE=(SELECT TO_DATE(VARVALUE,'DD/MM/YYYY') FROM SYSVAR WHERE GRNAME ='SYSTEM' AND VARNAME='CURRDATE')
                      AND CD7.cdtype ='OD' AND CD7.CDNAME='PRICETYPE' AND CD7.CDVAL=MST.PRICETYPE and tl.tlid =mk.tlid (+) and mst.orderid = f.orgacctno(+) and mst.exectype = f.exectype(+)

      UNION ALL

                      SELECT TO_DATE(substr(MST.ACTIVATEDT,0,10),'DD/MM/YYYY') TXDATE, '' REFORDERID, MST.AFACCTNO, MST.ACCTNO, MST.ORGACCTNO, MST.EXECTYPE,MST.REFACCTNO REFACCTNO, MST.PRICETYPE,
                      CD2.cdcontent DESC_EXECTYPE, MST.SYMBOL, MST.QUANTITY, (MST.PRICE * 1000) PRICE, MST.feedbackmsg,
                      MST.QUOTEPRICE, TO_CHAR(CD3.cdcontent) DESC_BOOK, MST.STATUS, CD1.cdcontent DESC_STATUS, CD4.cdcontent DESC_TIMETYPE,
                      CD5.cdcontent DESC_MATCHTYPE, CD6.cdcontent DESC_NORK, CD7.cdcontent DESC_PRICETYPE,
                      REFOD.EXECQTTY, REFOD.EXECAMT,(CASE WHEN REFOD.EXECQTTY>0 THEN ROUND(REFOD.EXECAMT/1000/REFOD.EXECQTTY,2) ELSE 0 END) AVEXECPRICE, REFOD.REMAINQTTY, SUBSTR(MST.activatedt,12,9) txtime, REFOD.CANCELQTTY, REFOD.ADJUSTQTTY ,MST.BOOK BOOK,CD8.cdcontent VIA,REFOD.VIA VIACD,
                      (CASE WHEN REFOD.CANCELQTTY>0 THEN 'Cancelled'  WHEN REFOD.EDITSTATUS='C' THEN 'Cancelling' ELSE '----' END) CANCELSTATUS,(CASE WHEN REFOD.ADJUSTQTTY>0 THEN 'Amended' WHEN REFOD.EDITSTATUS='A' THEN 'Amending' ELSE '----' END) AMENDSTATUS,
                      SYS.SYSVALUE CURRSECSSION,REFOD.HOSESESSION ODSECSSION,MST.Username maker
                      FROM AFMAST CF, FOMAST MST, (select OD1.*,OD2.EDSTATUS EDITSTATUS from odmast OD1,(SELECT * FROM ODMAST WHERE EDSTATUS IN ('C','A')) OD2   WHERE OD1.ORDERID=OD2.REFORDERID(+)) REFOD,
                      ALLCODE CD1, ALLCODE CD2, ALLCODE CD3, ALLCODE CD4, ALLCODE CD5, ALLCODE CD6, ALLCODE CD7, ALLCODE CD8 ,ORDERSYS SYS
                      WHERE  REFOD.ORSTATUS <> '7' AND CF.ACCTNO=MST.AFACCTNO AND MST.STATUS = 'A' AND MST.acctno = mst.orgacctno AND CF.ACCTNO=pv_AFACCTNO
                      AND CD1.cdtype ='FO' AND CD1.CDNAME='STATUS' AND CD1.CDVAL=MST.status
                      AND SYS.SYSNAME='CONTROLCODE'
                      AND CD2.cdtype ='FO' AND CD2.CDNAME='EXECTYPE' AND CD2.CDVAL=MST.EXECTYPE
                      AND CD3.cdtype ='FO' AND CD3.CDNAME='BOOK' AND CD3.CDVAL=MST.BOOK
                      AND CD4.cdtype ='FO' AND CD4.CDNAME='TIMETYPE' AND CD4.CDVAL=MST.TIMETYPE
                      AND CD5.cdtype ='FO' AND CD5.CDNAME='MATCHTYPE' AND CD5.CDVAL=MST.MATCHTYPE
                      AND CD6.cdtype ='FO' AND CD6.CDNAME='NORK' AND CD6.CDVAL=MST.NORK
                      AND CD8.cdtype ='OD' AND CD8.CDNAME='VIA' AND CD8.CDVAL=REFOD.VIA
                      AND CD7.cdtype ='FO' AND CD7.CDNAME='PRICETYPE' AND CD7.CDVAL=MST.PRICETYPE
                      AND REFOD.TXDATE=(SELECT TO_DATE(VARVALUE,'DD/MM/YYYY') FROM SYSVAR WHERE GRNAME ='SYSTEM' AND VARNAME='CURRDATE')
                      AND MST.ORGACCTNO=REFOD.ORDERID


      UNION ALL
                      SELECT TO_DATE(substr(MST.ACTIVATEDT,0,10),'DD/MM/YYYY') TXDATE,'' REFORDERID, MST.AFACCTNO, MST.ACCTNO, MST.ORGACCTNO, MST.EXECTYPE,(CASE WHEN MST.STATUS='R' THEN '' ELSE MST.REFACCTNO END) REFACCTNO, MST.PRICETYPE,
                      CD2.cdcontent DESC_EXECTYPE, MST.SYMBOL, MST.QUANTITY-NVL(ROOT.ORDERQTTY,0) QUANTITY,(MST.PRICE * 1000) PRICE, MST.feedbackmsg,
                      MST.QUOTEPRICE, TO_CHAR(CD3.cdcontent) DESC_BOOK, MST.STATUS, CD1.cdcontent DESC_STATUS, CD4.cdcontent DESC_TIMETYPE,
                      CD5.cdcontent DESC_MATCHTYPE, CD6.cdcontent DESC_NORK, CD7.cdcontent DESC_PRICETYPE,
                      MST.EXECQTTY, MST.EXECAMT,(CASE WHEN MST.EXECQTTY>0 THEN ROUND(MST.EXECAMT/1000/MST.EXECQTTY,2) ELSE 0 END) AVEXECPRICE, MST.REMAINQTTY-NVL(ROOT.ORDERQTTY,0) REMAINQTTY, SUBSTR(MST.activatedt,12,9) txtime, mst.CANCELQTTY , mst.AMENDQTTY ADJUSTQTTY,MST.BOOK BOOK,CD8.cdcontent VIA,'T' VIACD,('----') CANCELSTATUS,('----') AMENDSTATUS,
                      SYS.SYSVALUE CURRSECSSION,'N' ODSECSSION,MST.Username maker
                      FROM AFMAST CF, FOMAST MST,
                      ALLCODE CD1, ALLCODE CD2, ALLCODE CD3, ALLCODE CD4, ALLCODE CD5, ALLCODE CD6, ALLCODE CD7, ALLCODE CD8 ,ORDERSYS SYS,
                      (SELECT A.FOACCTNO, SUM (B.ORDERQTTY) ORDERQTTY FROM ROOTORDERMAP A, ODMAST B WHERE A.ORDERID=B.ORDERID AND STATUS='A' GROUP BY A.FOACCTNO) ROOT
                      WHERE MST.ACCTNO=ROOT.FOACCTNO(+) AND MST.STATUS<>'A' AND CF.ACCTNO=MST.AFACCTNO AND CF.ACCTNO=pv_AFACCTNO
                      AND CD1.cdtype ='FO' AND CD1.CDNAME='STATUS' AND CD1.CDVAL=MST.status
                      AND SYS.SYSNAME='CONTROLCODE'
                      AND CD2.cdtype ='FO' AND CD2.CDNAME='EXECTYPE' AND CD2.CDVAL=MST.EXECTYPE
                      AND CD3.cdtype ='FO' AND CD3.CDNAME='BOOK' AND CD3.CDVAL=MST.BOOK
                      AND CD4.cdtype ='FO' AND CD4.CDNAME='TIMETYPE' AND CD4.CDVAL=MST.TIMETYPE
                      AND CD5.cdtype ='FO' AND CD5.CDNAME='MATCHTYPE' AND CD5.CDVAL=MST.MATCHTYPE
                      AND CD6.cdtype ='FO' AND CD6.CDNAME='NORK' AND CD6.CDVAL=MST.NORK
                      AND CD8.cdtype ='OD' AND CD8.CDNAME='VIA' AND CD8.CDVAL='T'
                      AND CD7.cdtype ='FO' AND CD7.CDNAME='PRICETYPE' AND CD7.CDVAL=MST.PRICETYPE
      ) DTL
      ORDER BY TXDATE DESC, TXTIME DESC, REFORDERID, ACCTNO;


EXCEPTION
    WHEN others THEN
        return;
END;

 
 
 
 
/
