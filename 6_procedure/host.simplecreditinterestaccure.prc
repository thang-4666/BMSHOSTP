SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "SIMPLECREDITINTERESTACCURE" (frdate IN VARCHAR2,todate IN VARCHAR2, ERR_CODE out Varchar2)
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
    select seq_ciinttran.NEXTVAL, mst.acctno,'CR',to_date(V_FRDATE,'DD/MM/YYYY'),to_date(V_TODATE,'DD/MM/YYYY'),
        'S',icdef.ICRATE,(mst.balance+mst.trfamt),round((mst.balance+mst.trfamt)*icdef.ICRATE/100/360*V_DAYS,4) intamt
    from cimast mst,citype typ,iccftypedef icdef
    where (mst.balance+mst.trfamt) >0  and mst.actype=typ.actype and mst.status <>'C' and mst.status <>'N'
        and typ.actype=icdef.actype and icdef.modcode ='CI' and eventcode='CRINTACR'
        and icdef.ruletype='S' and icdef.deltd='N';

    update cimast set CRINTDT=to_date(V_TODATE,'DD/MM/YYYY'),
        crintacr=crintacr
        + nvl(
        (
            select intamt from
                (select round((mst.balance+mst.trfamt)*icdef.ICRATE/100/360*V_DAYS,4) intamt, mst.acctno
                from cimast mst,citype typ,iccftypedef icdef
                where (mst.balance+mst.trfamt) >0
                    and mst.actype=typ.actype and mst.status <>'C' and mst.status <>'N'
                    and typ.actype=icdef.actype
                    and icdef.modcode ='CI' and eventcode='CRINTACR'
                    and icdef.ruletype='S' and icdef.deltd='N'
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
