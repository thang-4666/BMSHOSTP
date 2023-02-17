SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE sp_sbs_batch_adhoc_bod IS
  v_code  NUMBER;
  v_errm  VARCHAR2(64);
  pv_errmsg varchar(250);
  v_ref_account_no varchar(50);
  v_ref_prinamt NUMBER;
  v_ref_intnmlday NUMBER;
  v_ref_intday NUMBER;
  v_ref_intovday NUMBER;
  v_ref_intovdayprin NUMBER;
  v_currdate date;
  v_indueratio NUMBER;
  v_overdueratio NUMBER;
  CURSOR pv_refcursor_custodian IS
    SELECT ACCTNO FROM CFMAST CF, AFMAST AF, AFTYPE TYP
        WHERE /*substr(cf.custodycd ,1,3) <> (select varvalue from sysvar where grname ='SYSTEM' and varname ='COMPANYCD')*/cf.custatcom <> 'Y' AND CF.CUSTID=AF.CUSTID AND AF.ACTYPE=TYP.ACTYPE;
  CURSOR pv_refcursor_sbs_lnint_accr IS
    select mst.acctno, mst.prinnml+mst.prinovd prinamt,
      SP_SBS_CAL_INTDUE(mst.PRINTFRQ1, mst.rate1, mst.PRINTFRQ2, mst.rate2, mst.PRINTFRQ3, mst.rate3, mst.rlsdate, dt.currdate) INTDAY,
      SP_SBS_CAL_INTOVDDUE(mst.PRINTFRQ3, mst.rate3, mst.rlsdate, dt.currdate) INTOVDDAY
    from lnmast mst, lntype typ, (select TO_DATE(VARVALUE,'DD/MM/RRRR') currdate from sysvar where varname='CURRDATE') dt
    where typ.actype=mst.actype and typ.NINTCD='001' and mst.rlsdate<dt.currdate; --lai bac thang tung thoi ky

BEGIN
  select TO_DATE(VARVALUE,'DD/MM/RRRR') into v_currdate from sysvar where varname='CURRDATE';
  --Cap nhat trang call cho cac deal bi call
  INSERT INTO dfmastlog (autoid, acctno, flagtrigger, callprice, triggerprice,basicprice,nextflagtrigger, datelog)
    SELECT seq_dfmastlog.NEXTVAL autoid, DF.ACCTNO, df.flagtrigger , df.mrate/100*df.refprice callprice, df.triggerprice, sb.basicprice, 'C' nextflagtrigger, SYSTIMESTAMP datelog
    FROM LNMAST LN, DFMAST DF, SECURITIES_INFO SB
    WHERE df.flagtrigger <> 'T' AND DF.CODEID=SB.CODEID AND DF.LNACCTNO=LN.ACCTNO  AND (SB.BASICPRICE<=DF.mrate/100*DF.refprice OR
    (DF.CALLTYPE<>'P' AND (case when df.CALLTYPE='P' then 0 else
                         (case when (DF.DFAMT + greatest(df.INTAMTACR+df.feeamt,df.FEEMIN-df.RLSFEEAMT) +
              ln.PRINNML+ln.PRINOVD+ln.INTNMLACR+ln.INTOVDACR+ln.INTNMLOVD+ln.INTDUE+
                          ln.OPRINNML+ln.OPRINOVD+ln.OINTNMLACR+ln.OINTOVDACR+ln.OINTNMLOVD+
                          ln.OINTDUE+ln.FEE+ln.FEEDUE+ln.FEEOVD) =0
                         then 1000000
                         else
                          round((df.dfqtty + df.rcvqtty + df.carcvqtty + df.blockqtty + df.bqtty) * SB.BASICPRICE * DF.DFRATE
                  / (DF.DFAMT + greatest(df.INTAMTACR+df.feeamt,df.FEEMIN-df.RLSFEEAMT) +
                      ln.PRINNML+ln.PRINOVD+ln.INTNMLACR+ln.INTOVDACR+ln.INTNMLOVD+ln.INTDUE+
                          ln.OPRINNML+ln.OPRINOVD+ln.OINTNMLACR+ln.OINTOVDACR+ln.OINTNMLOVD+
                          ln.OINTDUE+ln.FEE+ln.FEEDUE+ln.FEEOVD),4)
                    end)
        end) <= DF.mrate));

  UPDATE DFMAST SET FLAGTRIGGER='C' WHERE FLAGTRIGGER<>'T' AND ACCTNO IN
 ( SELECT DF.ACCTNO FROM LNMAST LN, DFMAST DF, SECURITIES_INFO SB
  WHERE DF.CODEID=SB.CODEID AND DF.LNACCTNO=LN.ACCTNO  AND (SB.BASICPRICE<=DF.mrate/100*DF.refprice OR
    (DF.CALLTYPE<>'P' AND (case when df.CALLTYPE='P' then 0 else
                         (case when (DF.DFAMT + greatest(df.INTAMTACR+df.feeamt,df.FEEMIN-df.RLSFEEAMT) +
              ln.PRINNML+ln.PRINOVD+ln.INTNMLACR+ln.INTOVDACR+ln.INTNMLOVD+ln.INTDUE+
                          ln.OPRINNML+ln.OPRINOVD+ln.OINTNMLACR+ln.OINTOVDACR+ln.OINTNMLOVD+
                          ln.OINTDUE+ln.FEE+ln.FEEDUE+ln.FEEOVD) =0
                         then 1000000
                         else
                          round((df.dfqtty + df.rcvqtty + df.carcvqtty + df.blockqtty + df.bqtty) * SB.BASICPRICE * DF.DFRATE
                  / (DF.DFAMT + greatest(df.INTAMTACR+df.feeamt,df.FEEMIN-df.RLSFEEAMT) +
                      ln.PRINNML+ln.PRINOVD+ln.INTNMLACR+ln.INTOVDACR+ln.INTNMLOVD+ln.INTDUE+
                          ln.OPRINNML+ln.OPRINOVD+ln.OINTNMLACR+ln.OINTOVDACR+ln.OINTNMLOVD+
                          ln.OINTDUE+ln.FEE+ln.FEEDUE+ln.FEEOVD),4)
                    end)
        end) <= DF.mrate)));

  --cap nhat trang thai TRIGGER CHO DEAL
    INSERT INTO dfmastlog (autoid, acctno, flagtrigger, callprice, triggerprice,basicprice,nextflagtrigger, datelog)
    SELECT seq_dfmastlog.NEXTVAL autoid, DF.ACCTNO, df.flagtrigger , df.mrate/100*df.refprice callprice, df.triggerprice, sb.basicprice, 'T' nextflagtrigger, SYSTIMESTAMP datelog
        FROM LNMAST LN, DFMAST DF, SECURITIES_INFO SB
    WHERE FLAGTRIGGER<>'T' AND DF.CODEID=SB.CODEID AND DF.LNACCTNO=LN.ACCTNO  AND (sb.basicprice<=df.triggerprice OR
    (DF.CALLTYPE<>'P' AND (case when df.CALLTYPE='P' then 0 else
                         (case when (DF.DFAMT + greatest(df.INTAMTACR+df.feeamt,df.FEEMIN-df.RLSFEEAMT) +
              ln.PRINNML+ln.PRINOVD+ln.INTNMLACR+ln.INTOVDACR+ln.INTNMLOVD+ln.INTDUE+
                          ln.OPRINNML+ln.OPRINOVD+ln.OINTNMLACR+ln.OINTOVDACR+ln.OINTNMLOVD+
                          ln.OINTDUE+ln.FEE+ln.FEEDUE+ln.FEEOVD) =0
                         then 1000000
                         else
                          round((df.dfqtty + df.rcvqtty + df.carcvqtty + df.blockqtty + df.bqtty) * SB.BASICPRICE * DF.DFRATE
                  / (DF.DFAMT + greatest(df.INTAMTACR+df.feeamt,df.FEEMIN-df.RLSFEEAMT) +
                      ln.PRINNML+ln.PRINOVD+ln.INTNMLACR+ln.INTOVDACR+ln.INTNMLOVD+ln.INTDUE+
                          ln.OPRINNML+ln.OPRINOVD+ln.OINTNMLACR+ln.OINTOVDACR+ln.OINTNMLOVD+
                          ln.OINTDUE+ln.FEE+ln.FEEDUE+ln.FEEOVD),4)
                    end)
        end) < DF.Lrate));

  UPDATE DFMAST SET FLAGTRIGGER='T' WHERE FLAGTRIGGER<>'T' AND ACCTNO IN
  (SELECT DF.ACCTNO FROM LNMAST LN, DFMAST DF, SECURITIES_INFO SB
  WHERE DF.CODEID=SB.CODEID AND DF.LNACCTNO=LN.ACCTNO  AND (sb.basicprice<=df.triggerprice OR
    (DF.CALLTYPE<>'P' AND (case when df.CALLTYPE='P' then 0 else
                         (case when (DF.DFAMT + greatest(df.INTAMTACR+df.feeamt,df.FEEMIN-df.RLSFEEAMT) +
              ln.PRINNML+ln.PRINOVD+ln.INTNMLACR+ln.INTOVDACR+ln.INTNMLOVD+ln.INTDUE+
                          ln.OPRINNML+ln.OPRINOVD+ln.OINTNMLACR+ln.OINTOVDACR+ln.OINTNMLOVD+
                          ln.OINTDUE+ln.FEE+ln.FEEDUE+ln.FEEOVD) =0
                         then 1000000
                         else
                          round((df.dfqtty + df.rcvqtty + df.carcvqtty + df.blockqtty + df.bqtty) * SB.BASICPRICE * DF.DFRATE
                  / (DF.DFAMT + greatest(df.INTAMTACR+df.feeamt,df.FEEMIN-df.RLSFEEAMT) +
                      ln.PRINNML+ln.PRINOVD+ln.INTNMLACR+ln.INTOVDACR+ln.INTNMLOVD+ln.INTDUE+
                          ln.OPRINNML+ln.OPRINOVD+ln.OINTNMLACR+ln.OINTOVDACR+ln.OINTNMLOVD+
                          ln.OINTDUE+ln.FEE+ln.FEEDUE+ln.FEEOVD),4)
                    end)
        end) < DF.Lrate)));

--cap nhat trang thai trigger cho deal tong
UPDATE DFGROUP SET FLAGTRIGGER='T' WHERE  GROUPID IN
(
SELECT DFG.GROUPID FROM LNMAST LN, dfgroup DFG,
(SELECT SUM ( (df.dfqtty + df.rcvqtty + df.carcvqtty + df.blockqtty + df.bqtty) * SB.BASICPRICE * DF.DFRATE  ) AMT, DF.GROUPID,LNACCTNO
FROM DFMAST DF, SECURITIES_INFO SB
WHERE DF.CODEID = SB.CODEID
AND DF.GROUPID IS NOT NULL
GROUP BY GROUPID,LNACCTNO) df
WHERE LN.ACCTNO = DFG.LNACCTNO
AND DFG.GROUPID = DF.GROUPID
AND ROUND((DF.AMT+DFG.DFAMT)/ greatest(dfg.INTAMTACR+dfg.feeamt,dfg.FEEMIN-dfg.RLSFEEAMT) +
ln.PRINNML+ln.PRINOVD+ln.INTNMLACR+ln.INTOVDACR+ln.INTNMLOVD+ln.INTDUE+
ln.OPRINNML+ln.OPRINOVD+ln.OINTNMLACR+ln.OINTOVDACR+ln.OINTNMLOVD+
ln.OINTDUE+ln.FEE+ln.FEEDUE+ln.FEEOVD,4)< DFG.LRATE
                          )                    ;
  --RESET S? DU KH?CH H?NG LUU K?? NOI KH?C
  OPEN pv_refcursor_custodian;
  LOOP
    FETCH pv_refcursor_custodian INTO v_ref_account_no;
    EXIT WHEN pv_refcursor_custodian%NOTFOUND;
    UPDATE AFMAST SET ADVANCELINE=0 WHERE ACCTNO=v_ref_account_no;
    UPDATE SEMAST SET TRADE=0,RECEIVING=0,NETTING=0 WHERE AFACCTNO=v_ref_account_no;
    UPDATE CIMAST SET RECEIVING=0,NETTING=0 WHERE AFACCTNO=v_ref_account_no;
  END LOOP;
  CLOSE pv_refcursor_custodian;


  --Tinh lai dau ngay cho cac mon vay tra lai bac thang khi tra
/*  OPEN pv_refcursor_sbs_lnint_accr;
  LOOP
      FETCH pv_refcursor_sbs_lnint_accr INTO v_ref_account_no, v_ref_prinamt, v_ref_intday, v_ref_intovday;
    EXIT WHEN pv_refcursor_sbs_lnint_accr%NOTFOUND;
    UPDATE LNMAST SET INTNMLACR=v_ref_prinamt*v_ref_intday, INTOVDACR=v_ref_prinamt*v_ref_intovday WHERE ACCTNO=v_ref_account_no;
  END LOOP;
  CLOSE pv_refcursor_sbs_lnint_accr;*/
  --Re set lai lai truoc khi tinh
  for rec in
  (
    select chd.autoid,mst.acctno
    from lnmast mst, lntype typ, lnschd chd
    where typ.actype=mst.actype and typ.NINTCD='001'
    and mst.acctno = chd.acctno and chd.reftype <> 'I'
    and mst.ftype='DF'
    and chd.rlsdate<v_currdate --lai bac thang tung thoi ky
  )
  loop
      update lnschd set intnmlacr=0,intdue=0,intovd=0,intovdprin=0 where autoid= rec.autoid;
      update lnmast set intnmlacr=0,intovdacr=0,intdue=0,intnmlovd=0 where acctno = rec.acctno;
  end loop;
  --Cat nhat lai lai sau khi tinh
  for rec in
  (
    select chd.autoid,mst.acctno,mst.actype, mst.prinnml+mst.prinovd prinamt,
      mst.PRINTFRQ1, mst.rate1, mst.PRINTFRQ2, mst.rate2, mst.PRINTFRQ3, mst.rate3, chd.rlsdate,
      getnextdt(getduedate (chd.rlsdate,typ.lncldr,'000',mst.PRINTFRQ1)) frqdate1,
      getnextdt(getduedate (chd.rlsdate,typ.lncldr,'000',mst.PRINTFRQ2)) frqdate2,
      greatest(getnextdt(getduedate (chd.rlsdate,typ.lncldr,'000',mst.PRINTFRQ3)),chd.overduedate) frqdate3
    from lnmast mst, lntype typ, lnschd chd
    where typ.actype=mst.actype and typ.NINTCD='001'
    and mst.ftype='DF'
    and mst.acctno = chd.acctno and chd.reftype <> 'I'
    and chd.rlsdate<v_currdate --lai bac thang tung thoi ky
  )
  loop
        v_ref_intovdayprin:=0;
        v_ref_intnmlday:=0;
        v_ref_intday :=0;
        v_ref_intovday:=0;
        v_indueratio:=0;
        v_overdueratio:=0;
        if v_currdate>rec.frqdate3 then
            --Muc lai qua han
             v_ref_intnmlday:=0;
             v_ref_intday :=0;
             if rec.frqdate3 =rec.frqdate2 THEN
                v_ref_intovday:=rec.prinamt * (rec.frqdate3-rec.rlsdate) * rec.rate2 /100/360 ;
                v_indueratio:=(rec.frqdate3-rec.rlsdate) * rec.rate2 /100/360 ;
             elsif rec.frqdate3 =rec.frqdate1 THEN
                v_ref_intovday:=rec.prinamt * (rec.frqdate3-rec.rlsdate) * rec.rate1 /100/360 ;
                v_indueratio:=(rec.frqdate3-rec.rlsdate) * rec.rate1 /100/360 ;
             else
                v_ref_intovday:=rec.prinamt * (rec.frqdate3-rec.rlsdate) * rec.rate3 /100/360 ;
                v_indueratio:=(rec.frqdate3-rec.rlsdate) * rec.rate3 /100/360 ;
             end if;

             v_ref_intovdayprin:=rec.prinamt * (v_currdate-rec.frqdate3) * 1.5 * rec.rate3 /100/360;
             v_overdueratio:=(v_currdate-rec.frqdate3) * 1.5 * rec.rate3 /100/360;
        elsif v_currdate=rec.frqdate3 then
            --Muc lai den han
            if rec.frqdate3 =rec.frqdate2 THEN
                 v_ref_intnmlday:=0;
                 v_ref_intday :=rec.prinamt * (rec.frqdate3-rec.rlsdate) * rec.rate2 /100/360 ;
                 v_ref_intovday:=0;
                 v_ref_intovdayprin:=0;
                 v_indueratio:=(rec.frqdate3-rec.rlsdate) * rec.rate2 /100/360 ;
            elsif rec.frqdate3 =rec.frqdate1 THEN
                 v_ref_intnmlday:=0;
                 v_ref_intday :=rec.prinamt * (rec.frqdate3-rec.rlsdate) * rec.rate1 /100/360 ;
                 v_ref_intovday:=0;
                 v_ref_intovdayprin:=0;
                 v_indueratio:=(rec.frqdate3-rec.rlsdate) * rec.rate1 /100/360 ;
            else
                 v_ref_intnmlday:=0;
                 v_ref_intday :=rec.prinamt * (rec.frqdate3-rec.rlsdate) * rec.rate3 /100/360 ;
                 v_ref_intovday:=0;
                 v_ref_intovdayprin:=0;
                 v_indueratio:=(rec.frqdate3-rec.rlsdate) * rec.rate3 /100/360 ;
            end if;

        else
            --Muc lai trong han
            if v_currdate<=rec.frqdate1 then
                --Trong han rate1
                v_ref_intnmlday:=rec.prinamt * (v_currdate-rec.rlsdate) * rec.rate1 /100/360 ;
                v_ref_intday :=0;
                v_ref_intovday:=0;
                v_ref_intovdayprin:=0;
                v_indueratio:= (v_currdate-rec.rlsdate) * rec.rate1 /100/360 ;
            elsif v_currdate<=rec.frqdate2 and v_currdate>rec.frqdate1 then
                --Trong han rate2
                v_ref_intnmlday:=rec.prinamt * (v_currdate-rec.rlsdate) * rec.rate2 /100/360 ;
                v_ref_intday :=0;
                v_ref_intovday:=0;
                v_ref_intovdayprin:=0;
                v_indueratio:=(v_currdate-rec.rlsdate) * rec.rate2 /100/360 ;
            elsif v_currdate<=rec.frqdate3 and v_currdate>rec.frqdate2 then
                --Trong han rate3
                v_ref_intnmlday:=rec.prinamt * (v_currdate-rec.rlsdate) * rec.rate3 /100/360 ;
                v_ref_intday :=0;
                v_ref_intovday:=0;
                v_ref_intovdayprin:=0;
                v_indueratio:=(v_currdate-rec.rlsdate) * rec.rate3 /100/360 ;
            end if;
        end if;
        update lnschd set intnmlacr=round(v_ref_intnmlday,0),
                          intdue=round(v_ref_intday,0),
                          intovd=round(v_ref_intovday,0),
                          intovdprin=round(v_ref_intovdayprin,0)
               where autoid= rec.autoid;
        update lnmast set intnmlacr=round(v_ref_intnmlday,0),
                          intdue=round(v_ref_intday,0),
                          intnmlovd =round(v_ref_intovdayprin,0),
                          intovdacr=round(v_ref_intovday,0),
                          indueratio=v_indueratio,
                          overdueratio=v_overdueratio
               where acctno = rec.acctno;
  end loop;
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    v_code := SQLCODE;
    v_errm := SUBSTR(SQLERRM, 1, 64);
    INSERT INTO errors (code, message, logdetail, happened) VALUES (v_code, v_errm, 'sp_sbs_batch_adhoc_bod', SYSTIMESTAMP);
END; 
 
 
 
 
/
