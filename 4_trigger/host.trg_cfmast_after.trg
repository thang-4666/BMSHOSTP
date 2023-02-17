SET DEFINE OFF;
CREATE OR REPLACE TRIGGER TRG_CFMAST_AFTER
 AFTER 
 INSERT OR UPDATE
 ON CFMAST
 REFERENCING OLD AS OLDVAL NEW AS NEWVAL
 FOR EACH ROW
DECLARE
l_expdate DATE ;
l_numexp NUMBER ;
l_nextcftype varchar2(4);
 pkgctx     plog.log_ctx;
begin
    if updating and fopks_api.fn_is_ho_active then
        --Log trigger for buffer if modify advancedline
        IF :newval.STATUS ='A' or :oldval.STATUS = 'P' THEN
             UPDATE emaillog SET status ='A',email=:newval.mobilesms WHERE status ='P' AND afacctno = :newval.custodycd AND templateid ='0303';
             UPDATE emaillog SET status ='A',email=:newval.email WHERE status ='P' AND afacctno = :newval.custodycd AND templateid ='0212';
        END IF;
        --End Log trigger for buffer
        if :newval.mobilesms <> :oldval.mobilesms then
            INSERT INTO emaillog (AUTOID,EMAIL,TEMPLATEID,DATASOURCE,STATUS,CREATETIME,SENTTIME,AFACCTNO,NOTE)
            VALUES(seq_emaillog.nextval,:newval.mobilesms,'0306','select '' SDT: ' || :oldval.mobilesms ||''' oldvalue, '' sang SDT moi: '|| :newval.mobilesms || ''' newvalue, ''' || :newval.custodycd || ''' custodycd  from dual',
            'A',TO_DATE(getcurrdate,'DD/MM/RRRR'),NULL,:oldval.CUSTODYCD,NULL);
            INSERT INTO emaillog (AUTOID,EMAIL,TEMPLATEID,DATASOURCE,STATUS,CREATETIME,SENTTIME,AFACCTNO,NOTE)
            VALUES(seq_emaillog.nextval,:oldval.mobilesms,'0306','select '' SDT: ' || :oldval.mobilesms ||''' oldvalue, '' sang SDT moi: '|| :newval.mobilesms || ''' newvalue, ''' || :newval.custodycd || ''' custodycd  from dual',
            'A',TO_DATE(getcurrdate,'DD/MM/RRRR'),NULL,:oldval.CUSTODYCD,NULL);
        end if;
        if :newval.email <> :oldval.email then
            INSERT INTO emaillog (AUTOID,EMAIL,TEMPLATEID,DATASOURCE,STATUS,CREATETIME,SENTTIME,AFACCTNO,NOTE)
            VALUES(seq_emaillog.nextval,:newval.mobilesms,'0306','select '' Email: ' || :oldval.email ||''' oldvalue, '' sang Email moi: '|| :newval.email || ''' newvalue , ''' || :newval.custodycd || ''' custodycd from dual',
            'A',TO_DATE(getcurrdate,'DD/MM/RRRR'),NULL,:oldval.CUSTODYCD,NULL);
        end if;

    end if;

    if updating and :oldval.pin <> :newval.pin and length(trim(:newval.pin)) <> 0 then
          if substr(:oldval.CUSTODYCD,4,1) <> 'F' then
            INSERT INTO emaillog (AUTOID,EMAIL,TEMPLATEID,DATASOURCE,STATUS,CREATETIME,SENTTIME,AFACCTNO,NOTE)
            VALUES(seq_emaillog.nextval,:newval.mobilesms,'0308','select ''BMSC thong bao: Quy khach co tai khoan so '||:newval.custodycd ||'  da doi Mat khau dat lenh qua dien thoai thanh cong'' detail from dual',
            'A',TO_DATE(getcurrdate,'DD/MM/RRRR'),NULL,:oldval.CUSTODYCD,NULL);
          else
            INSERT INTO emaillog (AUTOID,EMAIL,TEMPLATEID,DATASOURCE,STATUS,CREATETIME,SENTTIME,AFACCTNO,NOTE)
            VALUES(seq_emaillog.nextval,:newval.mobilesms,'0308','select ''Pleased be imformed that Your Telephone Password of the Customer account number '||:newval.custodycd ||'  have been changed sucessfully'' detail from dual',
            'A',TO_DATE(getcurrdate,'DD/MM/RRRR'),NULL,:oldval.CUSTODYCD,NULL);
          end if;

    end if;
        IF :newval.ACTYPE <> NVL(:oldval.ACTYPE,'-')  THEN
        BEGIN
        --ngoc.vu-Jira561
        --SELECT numexp, getduedate (get_t_date(getcurrdate + numexp,1),'B','001',1)  ,nextcftype INTO  l_numexp,l_expdate ,l_nextcftype FROM cftype WHERE actype = :newval.ACTYPE;
        SELECT numexp, getduedate (get_t_date(getcurrdate + numexp,1),'B','000',1)  ,nextcftype INTO  l_numexp,l_expdate ,l_nextcftype FROM cftype WHERE actype = :newval.ACTYPE;
        exception
        when others THEN
        l_numexp:='';
        l_expdate:='';
        l_nextcftype:= '';
        END ;
        UPDATE AccCftypeLog SET STATUS = 'R' WHERE STATUS IN ('A','P')  AND CUSTID =:newval.CUSTID;

        INSERT INTO AccCftypeLog (AUTOID,TXDATE,TYPELOG,CUSTID,CUSTODYCD,FRACTYPE,TOACTYPE,VALDATE,EXPDATE,NUMEXP,nextcftype,STATUS,DELTD)
        VALUES(seq_acccftypelog.NEXTVAL,getcurrdate, CASE WHEN :oldval.ACTYPE IS NULL THEN 'ADD' ELSE 'EDIT' END  ,:newval.CUSTID,:newval.CUSTODYCD,:oldval.ACTYPE,:newval.ACTYPE,getcurrdate,CASE WHEN l_nextcftype IS NOT NULL THEN   l_expdate ELSE NULL END ,l_numexp,l_nextcftype,'A','N');
        END IF;
        IF :newval.STATUS <> NVL(:oldval.STATUS,'-') AND :newval.STATUS IN ('P','E','A')  AND NVL(:oldval.STATUS,'-')<> 'A' THEN
        UPDATE  AccCftypeLog  SET STATUS =:newval.STATUS, DELTD= CASE WHEN :newval.STATUS ='E' THEN  'Y' ELSE 'N' END    WHERE CUSTID =:newval.CUSTID AND VALDATE = getcurrdate AND STATUS <>'R';
        END IF;
    --ADD VuTN: Update careby AFMAST theo CFMAST khac tu doanh
    IF updating and SUBSTR(:newval.CUSTODYCD,4,1) <> 'P' THEN
        Update AFMAST
        SET CAREBY =:newval.CAREBY
        Where CUSTID = :newval.CUSTID;
    END IF;
    --END VuTN
    --Update CFOTHERACC theo CFMAST
    if :NEWVAL.IDCODE <> :OLDVAL.IDCODE or :NEWVAL.IDDATE <> :OLDVAL.IDDATE or :NEWVAL.IDPLACE <> :OLDVAL.IDPLACE   
    then
        UPDATE CFOTHERACC
        SET ACNIDCODE = :NEWVAL.IDCODE, ACNIDPLACE = :NEWVAL.IDPLACE, ACNIDDATE = :NEWVAL.IDDATE
        WHERE CUSTID = NVL(:NEWVAL.CUSTID,'x');
    end if;
    --End CFOTHERACC theo CFMAST
  exception
  when others then
    plog.error(pkgctx, SQLERRM);
    plog.setEndSection(pkgctx, 'trg_cfmast_after');
end;
/
