SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "GETOTCSECINFO" (PV_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR,AFACCTNO IN VARCHAR2,INDATE IN VARCHAR2)
  IS
  V_SENDINF number(18,5);
  V_AFACCTNO VARCHAR2(10);
  V_INDATE VARCHAR2(20);
BEGIN
    V_SENDINF:=0;
    V_AFACCTNO:=AFACCTNO;
    V_INDATE:=INDATE;
    SELECT SUM(SENDING) INTO V_SENDINF FROM(
    select sum(case when trade>0 then 0 else -trade end) SENDING from
        (select afacctno,sum(trade) trade, codeid,clearday,clearcd from
        (select afacctno,sum(qtty) trade,codeid,clearday-T clearday,clearcd from(
        select afacctno,sum(case when duetype='RS' then qtty else -qtty end) Qtty, codeid,clearday,clearcd,txdate,getclearday(stschd.clearcd, '004',txdate,to_date(V_INDATE,'DD/MM/YYYY')) T
        from stschd where  duetype in ('RS','SS') and status='N'
        and TRIM(AFACCTNO) = V_AFACCTNO
        group by afacctno, codeid,stschd.clearday,clearcd,txdate,stschd.clearcd,getclearday(stschd.clearcd, '004',txdate,to_date(V_INDATE,'DD/MM/YYYY')))
        group by afacctno,codeid,clearday,clearcd,T
        union
        select afacctno,sum(-remainqtty) trade,codeid,clearday,clearcd  from odmast,sysvar where exectype in ('NS')
        and sysvar.grname='SYSTEM' and sysvar.varname='CURRDATE' and odmast.txdate =to_date(sysvar.varvalue,'DD/MM/YYYY')
        and remainqtty>0 and TRIM(AFACCTNO) = V_AFACCTNO
        group by afacctno,codeid,clearday,clearcd)
        group by afacctno,codeid,clearday,clearcd) GROUP BY AFACCTNO
    UNION SELECT 0 SENDING FROM DUAL);
OPEN PV_REFCURSOR FOR
	SELECT to_date(V_INDATE,'DD/MM/YYYY') DUEDATE,B.SYMBOL,B.CODEID,0 CLEARDAY,'B' CLEARCD, A.TRADE-V_SENDINF TRADE, 0 SENDING ,A.MORTAGE, A.COSTPRICE, NVL(C.BASICPRICE, 0) BASICPRICE
      FROM SEMAST A, SBSECURITIES B, SECURITIES_INFO C
      WHERE A.CODEID = B.CODEID AND A.CODEID = C.CODEID (+)
      AND TRIM(A.AFACCTNO) = V_AFACCTNO AND A.TRADE + A.MORTAGE <> 0 AND  B.SECTYPE <>'004' AND  B.tradeplace ='004'
    Union
   SELECT GETDUEDATE(to_date(V_INDATE,'DD/MM/YYYY'),CLEARCD,'004',CLEARDAY) DUEDATE,
   a.clearcd || '-' || B.SYMBOL || to_char(a.clearday) symbol,B.CODEID,A.CLEARDAY,A.CLEARCD,
   (case when trade>0 then trade else 0 end) TRADE,(case when trade>0 then 0 else -trade end) SENDING,
   0 MORTAGE, 0 COSTPRICE, NVL(C.BASICPRICE, 0) BASICPRICE
    from (
        select sum(trade) trade, codeid,clearday,clearcd from
        (select sum(qtty) trade,codeid,clearday-T clearday,clearcd from(
        select sum(case when duetype='RS' then qtty else -qtty end) Qtty, codeid,clearday,clearcd,txdate,getclearday(stschd.clearcd, '004',txdate,to_date(V_INDATE,'DD/MM/YYYY')) T
        from stschd where  duetype in ('RS','SS') and status='N'
        and TRIM(AFACCTNO) = V_AFACCTNO
        group by afacctno, codeid,stschd.clearday,clearcd,txdate,stschd.clearcd,getclearday(stschd.clearcd, '004',txdate,to_date(V_INDATE,'DD/MM/YYYY')))
        group by codeid,clearday,clearcd,T
        union
        select sum(-remainqtty) trade,codeid,clearday,clearcd  from odmast,sysvar where exectype in ('NS')
        and sysvar.grname='SYSTEM' and sysvar.varname='CURRDATE' and odmast.txdate =to_date(sysvar.varvalue,'DD/MM/YYYY')
        and remainqtty>0 and TRIM(AFACCTNO) = V_AFACCTNO
        group by codeid,clearday,clearcd)
        group by codeid,clearday,clearcd
     ) A,SBSECURITIES B, (SECURITIES_INFO )C
   WHERE to_char(A.CODEID) = to_char(B.CODEID) AND A.CODEID = C.CODEID (+)
   AND A.TRADE > 0 AND  B.SECTYPE <>'004' and b.tradeplace ='004';
EXCEPTION
    WHEN others THEN
        return;
END;

 
 
 
 
/
