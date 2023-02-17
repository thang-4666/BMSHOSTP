SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "SIMPLEOVERDRAFTINTERESTACCURE" (frdate IN VARCHAR2,todate IN VARCHAR2, ERR_CODE out Varchar2)
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
        'S',icdef.ICRATE,mst.odamt,round(mst.odamt*icdef.ICRATE/100/360*V_DAYS,4) intamt
    from cimast mst,citype typ,iccftypedef icdef
    where odamt >0  and mst.actype=typ.actype and mst.status <>'C'
        and typ.actype=icdef.actype and icdef.modcode ='CI' and eventcode='ODINTACR'
        and icdef.ruletype='S' and icdef.deltd='N';

    update cimast set ODINTDT=to_date(V_TODATE,'DD/MM/YYYY'),
        odintacr=odintacr
        + nvl(
        (
            select intamt from
                (select round(mst.odamt*icdef.ICRATE/100/360*V_DAYS,4) intamt, mst.acctno
                from cimast mst,citype typ,iccftypedef icdef
                where odamt >0
                    and mst.actype=typ.actype and mst.status <>'C' and typ.actype=icdef.actype
                    and icdef.modcode ='CI' and eventcode='ODINTACR'
                    and icdef.ruletype='S' and icdef.deltd='N'
                ) A
            where A.acctno=cimast.acctno
        ),0);


   /* update cimast set CRINTDT=to_date(V_TODATE,'DD/MM/YYYY'),
        crintacr=crintacr+ nvl((SELECT INTAMT FROM CIINTTRAN WHERE FRDATE =TO_DATE(V_FRDATE,'DD/MM/YYYY') AND INTTYPE='CR' AND ICRULE='S'
                AND CIINTTRAN.acctno=cimast.acctno),0);*/
	err_code:='0';

EXCEPTION
    WHEN others THEN
    	err_code:='-1';
        return;
END;

 
 
 
 
/
