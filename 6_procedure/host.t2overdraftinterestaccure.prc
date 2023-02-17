SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "T2OVERDRAFTINTERESTACCURE" (frdate IN VARCHAR2,todate IN VARCHAR2, ERR_CODE out Varchar2)
  IS

  V_FRDATE VARCHAR2(10);
  V_TODATE VARCHAR2(10);
  V_DAYS NUMBER(20,0);
BEGIN

    V_FRDATE:=frdate;
    V_TODATE:=todate;
    V_DAYS:=to_date(V_TODATE,'DD/MM/YYYY')-to_date(V_FRDATE,'DD/MM/YYYY');

    INSERT INTO ciinttran
    (AUTOID,ACCTNO,INTTYPE,FRDATE,TODATE,ICRULE,IRRATE,INTBAL,INTAMT)
    select seq_ciinttran.NEXTVAL, mst.acctno,'OD',to_date(V_FRDATE,'DD/MM/YYYY'),to_date(V_TODATE,'DD/MM/YYYY'),
        ICDEF.RULETYPE,icdef.ICRATE,mst.T2ODAMT odamt,round(T2ODAMT*icdef.ICRATE/100/360*V_DAYS,4) intamt
    from (SELECT A.ACCTNO,A.ACTYPE,A.STATUS,A.ODAMT-NVL(STS.T2AMT,0) T2ODAMT FROM CIMAST A,
                (SELECT AFACCTNO, SUM(AMT+ FEEAMT) T2AMT FROM
                    (SELECT S.AFACCTNO, SUM(S.AMT) AMT , MAX(OD.FEEAMT) FEEAMT FROM STSCHD S,ODMAST OD
                    WHERE S.ORGORDERID=OD.ORDERID
                    AND DUETYPE ='RS' AND STATUS <> 'C'
                    --ngoc.vu-Jira561
                    AND /*GETDUEDATE(S.TXDATE,'B','000',2)*/s.CLEARDATE >=
                    (SELECT TO_DATE(VARVALUE,'DD/MM/YYYY') FROM SYSVAR WHERE GRNAME ='SYSTEM' AND VARNAME='CURRDATE')
                    GROUP BY ORGORDERID,S.AFACCTNO)
                    GROUP BY AFACCTNO
                ) STS
                WHERE A.AFACCTNO = STS.AFACCTNO (+)
         ) mst,
        citype typ,iccftypedef icdef
    where MST.T2ODAMT >0  and mst.actype=typ.actype and mst.status <>'C'
        and typ.actype=icdef.actype and icdef.modcode ='CI' and eventcode='ODT2INTACR'
        and icdef.ruletype IN ('S','F') and icdef.deltd='N';

    update cimast set ODINTDT=to_date(V_TODATE,'DD/MM/YYYY'),
        odintacr=odintacr
        + nvl(
        (
            select intamt from
                (select round(MST.T2ODAMT*icdef.ICRATE/100/360*V_DAYS,4) intamt, mst.acctno
                from (SELECT A.ACCTNO,A.ACTYPE,A.STATUS,A.ODAMT-NVL(STS.T2AMT,0) T2ODAMT FROM CIMAST A,
                        (SELECT AFACCTNO, SUM(AMT+ FEEAMT) T2AMT FROM
                            (SELECT S.AFACCTNO, SUM(S.AMT) AMT , MAX(OD.FEEAMT) FEEAMT FROM STSCHD S,ODMAST OD
                            WHERE S.ORGORDERID=OD.ORDERID
                            AND DUETYPE ='RS' AND STATUS <> 'C'
                            --ngoc.vu-Jira561
                            AND /*GETDUEDATE(S.TXDATE,'B','000',2)*/s.CLEARDATE >=
                            (SELECT TO_DATE(VARVALUE,'DD/MM/YYYY') FROM SYSVAR WHERE GRNAME ='SYSTEM' AND VARNAME='CURRDATE')
                            GROUP BY ORGORDERID,S.AFACCTNO)
                            GROUP BY AFACCTNO
                        ) STS
                        WHERE A.AFACCTNO = STS.AFACCTNO (+)
                    ) mst,citype typ,iccftypedef icdef
                where MST.T2ODAMT >0
                    and mst.actype=typ.actype and mst.status <>'C' and typ.actype=icdef.actype
                    and icdef.modcode ='CI' and eventcode='ODT2INTACR'
                    and icdef.ruletype IN ('S','F') and icdef.deltd='N'
                ) A
            where A.acctno=cimast.acctno
        ),0);
    err_code:='0';
EXCEPTION
    WHEN others THEN
        err_code:='-1';
        return;
END;
 
 
 
 
/
