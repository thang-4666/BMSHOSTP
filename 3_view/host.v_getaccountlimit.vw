SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW V_GETACCOUNTLIMIT
(ACCTNO, FULLNAME, ACTYPE, TYPENAME, ADVANCELINE, 
 ODAMT, BALDEFOVD, NAVCI, SEMARGIN, AFNAV, 
 MARGINLIMIT)
BEQUEATH DEFINER
AS 
(select CI.ACCTNO,cf.fullname,af.actype, typ.typename, af.ADVANCELINE, ci.ODAMT,ci.BALDEFOVD,CI.CASH NAVCI,NVL(se.SEMARGIN,0) SEMARGIN,NVL(afnav.afnav,0) afnav,
    (case when af.actype ='0016' then round(least(CI.CASH+NVL(se.SEMARGIN,0),500000000),-6)
    	  when af.actype ='0020' then round(least(CI.CASH+NVL(se.SEMARGIN,0),1000000000),-6)
          when af.actype ='0023' then round(least(CI.CASH+NVL(se.SEMARGIN,0),2000000000),-6)
          when af.actype ='0024' then round(least(CI.CASH+NVL(se.SEMARGIN,0),3000000000),-6)
          when af.actype ='0025' then round(least(CI.CASH+NVL(se.SEMARGIN,0),4000000000),-6)
          when af.actype ='0026' then round(least(CI.CASH+NVL(se.SEMARGIN,0),5000000000),-6)
          when af.actype ='0027' then round(least(CI.CASH+NVL(se.SEMARGIN,0),10000000000),-6)		  		            
          when af.actype ='0031' then round(least(CI.CASH+NVL(se.SEMARGIN,0),5000000000),-6)
         
          else 0 end
    ) MARGINLIMIT
from
(SELECT CI.ACCTNO,CI.ODAMT,BALANCE-NVL(B.SECUREAMT,0)-ODAMT-NVL(B.ADVAMT,0)-RAMT+NVL(C.AAMT,0) BALDEFOVD,
         BALANCE-ODAMT-RAMT+NVL(C.AAMT,0) CASH
    FROM CIMAST CI,
    	 v_getbuyorderinfo b,
         (SELECT AFACCTNO ACCTNO, SUM(AMT-AAMT-FAMT+PAIDAMT+PAIDFEEAMT) AAMT
                 FROM STSCHD WHERE DUETYPE = 'RM' AND STATUS='N' AND DELTD <> 'Y'
                 GROUP BY AFACCTNO
         ) C
    WHERE ci.acctno =b.afacctno (+) AND CI.ACCTNO=C.ACCTNO(+)
) CI,
(select afacctno, sum((se.trade-nvl(vs.execamt,0)+nvl(sests.receiving,0))*(case when af.actype='0016' then mg.mass else mg.vip end)*  Decode(sbs.tradeplace,'001',sb.currprice*0.95,'002',sb.currprice*0.93,sb.currprice)) SEMARGIN
    from semast se,securities_info sb, sbsecurities sbs ,afmast af, SEMARGINRATE mg,
	(
		SELECT  seacctno,  SUM (case when od.exectype IN ('NS', 'SS') then remainqtty + execqtty else 0 end)  secureamt,
						SUM (case when od.exectype IN ('NS', 'SS') then execqtty else 0 end)  execamt,	
	             	SUM (case when od.exectype ='MS' then remainqtty + execqtty else 0 end)  securemtg
		              FROM odmast od
		             WHERE od.txdate =(select to_date(VARVALUE,'DD/MM/YYYY') from sysvar where grname='SYSTEM' and varname='CURRDATE')
		               AND deltd <> 'Y'
		               AND od.exectype IN ('NS', 'SS','MS')
		            group by seacctno
	) vs,
	(SELECT AFACCTNO || CODEID ACCTNO, SUM(QTTY) RECEIVING
                 FROM STSCHD WHERE DUETYPE = 'RS' AND STATUS='N' AND DELTD <> 'Y'
                 GROUP BY AFACCTNO,CODEID
     ) sests
    where se.codeid=sb.codeid and sb.symbol=mg.symbol and se.afacctno =af.acctno and af.actype in ('0016','0020','0023','0024','0025','0026','0027','0019','0028','0029','0030','0031')
    and se.acctno=vs.seacctno(+) and sb.codeid =sbs.codeid and se.acctno = sests.acctno(+)
    group by afacctno
) SE
,
(SELECT afacctno, round(sum(CIBALANCE)/sum(COUNTAF),0) + round(sum(SEBALANCE)/sum(COUNTAF),0) AFNAV 
    FROM ((SELECT MAX(AFACCTNO) AFACCTNO,SUM(CIBALANCE) CIBALANCE,
                    SUM(SEBALANCE) SEBALANCE, count(AFACCTNO) COUNTAF 
                FROM (SELECT AFACCTNO,TXDATE,CIBALANCE,SEBALANCE,AVRBAL FROM AVRBAL) DT1  
                GROUP BY AFACCTNO
           )
           union all
           (SELECT AFACCTNO,sum(CIBALANCE*25) CIBALANCE,sum(SEBALANCE*25) SEBALANCE,count(AFACCTNO)*25 COUNTAF 
                FROM AVRBALALL ,SYSVAR SYS
                where SYS.VARNAME='CURRDATE' AND SYS.GRNAME='SYSTEM' and add_months(TXDATE,1)>=to_date(SYS.VARVALUE,'DD\MM\YYYY')
                group by AFACCTNO)
            ) 
    group by afacctno
) AFNAV,
afmast af, cfmast cf, aftype typ
where ci.acctno=se.afacctno(+) and ci.acctno = afnav.afacctno(+) and ci.acctno =af.acctno and af.custid=cf.custid
and af.actype=typ.actype AND TYP.ACTYPE IN ('0016','0020','0023','0024','0025','0026','0027','0019','0028','0029','0030','0031')
)
/
