SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW VW_CASCHD_ALL
(AUTOID, CAMASTID, BALANCE, QTTY, AMT, 
 AQTTY, AAMT, STATUS, AFACCTNO, CODEID, 
 EXCODEID, DELTD, PSTATUS, REFCAMASTID, RETAILSHARE, 
 DEPOSIT, REQTTY, REAQTTY, RETAILBAL, PBALANCE, 
 PQTTY, PAAMT, COREBANK, ISCISE, DFQTTY, 
 ISCI, ISSE, ISRO, TQTTY, TRADE, 
 INBALANCE, OUTBALANCE)
BEQUEATH DEFINER
AS 
select "AUTOID","CAMASTID","BALANCE","QTTY","AMT","AQTTY","AAMT","STATUS","AFACCTNO","CODEID","EXCODEID","DELTD","PSTATUS","REFCAMASTID","RETAILSHARE","DEPOSIT","REQTTY","REAQTTY","RETAILBAL","PBALANCE","PQTTY","PAAMT","COREBANK","ISCISE","DFQTTY","ISCI","ISSE","ISRO","TQTTY","TRADE","INBALANCE","OUTBALANCE"
    from caschd
    union all
     select "AUTOID","CAMASTID","BALANCE","QTTY","AMT","AQTTY","AAMT","STATUS","AFACCTNO","CODEID","EXCODEID","DELTD","PSTATUS","REFCAMASTID","RETAILSHARE","DEPOSIT","REQTTY","REAQTTY","RETAILBAL","PBALANCE","PQTTY","PAAMT","COREBANK","ISCISE","DFQTTY","ISCI","ISSE","ISRO","TQTTY","TRADE","INBALANCE","OUTBALANCE"
    from caschdhist
/
