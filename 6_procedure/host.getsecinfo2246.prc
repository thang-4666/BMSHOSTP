SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE GETSECINFO2246 (PV_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR,GROUPID IN VARCHAR2, sumamt IN number ,amt IN number)
  IS

  v_groupid VARCHAR2(20);
  l_sumamt number;
  l_amt number;

BEGIN

    v_groupid:=to_char(GROUPID);
    l_sumamt:=to_number(sumamt);
    if l_sumamt= 0 then
        l_amt:=10000000000000000;
    else
        l_amt:=to_number(amt);
    end if;


OPEN PV_REFCURSOR FOR
select CASE WHEN l_amt=0 THEN VReleaseDF ELSE a.MINAMTRLS END MINAMTRLS, A.SEACCTNO, A.ACCTNO, A.INTPAIDMETHOD, A.LOT, A.TA0DF, A.CURAMT, A.IRATE, A.TADF, A.DDF, A.VRELEASEDF, A.DFRATE, A.DFREFPRICE, A.DEALTYPE, A.SYMBOL,
A.CONTENT, A.QTTY, A.INITQTTY, A.ADDQTTY, A.SECUREQTTY, A.ISINITASSET, A.ISADDASSET,
least(round(CASE WHEN 0=0 THEN decode(abs(VReleaseDF) + VReleaseDF,0,0,VReleaseDF) ELSE a.MINAMTRLS END / ( DFREFPRICE * DFRATE/100)),A.QTTY)  MAXRELEASE ,
0 ADDQTTYRELEASE, 0 initqttyrelease, A.amtreleaseall,
0 QTTYRELEASE  from (
    SELECT floor(LEAST (TADF- (DDF - l_amt ) *(IRATE/100), l_amt * (TA0DF / case when (CASE WHEN intpaidmethod = 'L' THEN CURAMT ELSE l_sumamt END ) =0 then 1 else (CASE WHEN intpaidmethod = 'L' THEN CURAMT ELSE l_sumamt END ) end ) )) MINAMTRLS, A.*,
    FLOOR(GREATEST(floor(least (floor(LEAST (TADF- (DDF - l_amt ) *(IRATE/100), l_amt * (TA0DF / case when (CASE WHEN intpaidmethod = 'L' THEN CURAMT ELSE l_sumamt END ) =0 then 1 else (CASE WHEN intpaidmethod = 'L' THEN CURAMT ELSE l_sumamt END ) end ) )) / ( DFREFPRICE * DFRATE/100), QTTY )),0) / LOT) * LOT MAXRELEASE ,
--    least(ROUND(decode(abs(VReleaseDF) + VReleaseDF,0,0,VReleaseDF)/(DFREFPRICE*IRATE/100)),qtty - secureqtty ) QTTYToIRate,
    QTTY * (DFREFPRICE * DFRATE/100) AMTRELEASEALL   FROM (

        select DF.AFACCTNO||DF.CODEID SEACCTNO, DF.ACCTNO,  LN.intpaidmethod,
        CASE WHEN DF.DEALTYPE='T' THEN 1 ELSE df.TRADELOT END LOT, V.TA0DF , V.CURAMT, V.IRATE, V.TADF, V.DDF, V.TADF - (V.IRATE*(DDF- 0 )/100 ) VReleaseDF, df.DFRATE,
         CASE WHEN DEALTYPE='T' THEN 1 ELSE SEC.DFREFPRICE END dfrefprice, DF.DEALTYPE, sec.symbol,A1.CDCONTENT CONTENT,
         CASE WHEN DF.DEALTYPE IN('N') THEN DF.DFQTTY - NVL(V1.SECUREAMT,0)ELSE  CASE WHEN DF.DEALTYPE='B' THEN DF.BLOCKQTTY
         ELSE CASE WHEN DF.DEALTYPE='R' THEN DF.RCVQTTY  ELSE CASE WHEN DF.DEALTYPE='T' THEN DF.CACASHQTTY
         ELSE DF.CARCVQTTY END END END END QTTY, DF.INITASSETQTTY INITQTTY, DF.ADDASSETQTTY ADDQTTY,nvl(v1.SECUREAMT,0) SECUREQTTY,
         ISINITASSET, ISADDASSET
         from v_getdealinfo DF, v_getgrpdealformular v, v_getdealsellorderinfo v1, securities_info sec , ALLCODE A1 , LNMAST LN  , dftype dft
         where DF.GROUPID= v_groupid and DF.groupid=v.groupid AND df.codeid=sec.codeid  AND DF.DEALTYPE=A1.CDVAL AND A1.CDNAME='DEALTYPE'
         and df.actype = dft.actype
         AND V.LNACCTNO = LN.ACCTNO and  DF.ACCTNO=V1.DFACCTNO(+)

     ) A
 ) a
 ;-- where QTTY > 0;


EXCEPTION
    WHEN others THEN
        return;
END;

 
 
 
 
/
