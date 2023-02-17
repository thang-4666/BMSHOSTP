SET DEFINE OFF;
CREATE OR REPLACE TRIGGER TRG_TBL_MO_AFTER 
 AFTER
  INSERT OR UPDATE
 ON tbl_mo
REFERENCING NEW AS NEWVAL OLD AS OLDVAL
 FOR EACH ROW
declare
    v_msgbody varchar2(100);
    v_msgbodyBSC varchar2(100);
    v_msgbodySLK varchar2(100);
    --v_msgbodyWrong varchar2(100);
    v_msgbodyINDEX varchar2(100);
    v_msgbodyCK varchar2(100);
    v_MCK varchar2(100);
    v_MaSan varchar2(100);

    v_mobile  varchar2(100);
    l_mobilesms  varchar2(100);
    l_details varchar2(1000);
    l_data_source varchar2(2000);
    --v_afacctno varchar2(20);
    --v_errmsg varchar2(10000);
    l_TC varchar2(100);
    l_Tran varchar2(100);
    l_San varchar2(100);
    checknull boolean;
begin
    if inserting then

       v_msgbody := UPPER(substr(replace ( :newval.msgbody,' ',''),14));
       v_msgbodyBSC := UPPER(substr(replace ( :newval.msgbody,' ',''),1,3));
       v_msgbodySLK := UPPER(substr(replace ( :newval.msgbody,' ',''),4,10));
       v_msgbodyINDEX := UPPER(substr(replace ( :newval.msgbody,' ',''),4,5));
       v_msgbodyCK := UPPER(substr(replace ( :newval.msgbody,' ',''),4,2));

    checknull := true;
    ------cu phap kiem tra thong tin tien
    if v_msgbody='TIEN' and v_msgbodyBSC='BSC' then

       v_mobile := '0'||ltrim(substr(:newval.SRC,1),'+84');
       begin
         select mobilesms into l_mobilesms from VW_CFMAST_SMS where custodycd= v_msgbodySLK;
       exception
         when others then
                l_mobilesms := '';
         end ;

       if v_mobile= l_mobilesms then
         BEGIN
          select listagg('TK '||ci.acctno||': '||ltrim(to_char(ci.balance,'9,999,999,999,999')||'d'),', ') within group (order by ci.acctno)
         into l_details
         from cimast ci, VW_CFMAST_SMS cf
         where ci.custid= cf.custid
         and cf.custodycd=v_msgbodySLK;
         exception
         when others then
                l_details := '';
                checknull := false;
         end ;

         l_data_source := 'select ''' || v_msgbodySLK ||
           ''' custodycd,''' || l_details ||
           ''' details from dual;';

         --NMPKS_EMS.InsertEmailLog(v_mobile, '0332', l_data_source , '');

         insert into emaillog
          (autoid, email, templateid, datasource, status, createtime, note)
         values
          (seq_emaillog.nextval,
           v_mobile,
           '0332',
           l_data_source,
           'A',
           sysdate,
           '---');

       --cu phap sai so dien thoai
       else
         l_details:='Tai khoan hoac so dien thoai cua ban chua dang ky dich vu, hay lien he toi so 04.39264660, 08.38218889 de biet them thong tin chi tiet..';

         l_data_source := 'select ''' || v_msgbodySLK ||
           ''' custodycd,''' || l_details ||
           ''' details from dual;';

         --NMPKS_EMS.InsertEmailLog(v_mobile, '0340', l_data_source , '');

         insert into emaillog
          (autoid, email, templateid, datasource, status, createtime, note)
         values
          (seq_emaillog.nextval,
           v_mobile,
           '0340',
           l_data_source,
           'A',
           sysdate,
           '---');
       end if;
       ---------so du chung khoan
    else if v_msgbody='SDCK' and v_msgbodyBSC='BSC' then

       v_mobile := '0'||ltrim(substr(:newval.SRC,1),'+84');
       begin
         select mobilesms into l_mobilesms from VW_CFMAST_SMS where custodycd= v_msgbodySLK;
       exception
         when others then
                l_mobilesms := '';
       end ;
       if v_mobile= l_mobilesms then
           begin
             select listagg(s.symbol||'-'||s.trade,', ')
             within group (order by s.symbol) as detals
             into l_details
             from (select sec.symbol, nvl((sum(se.trade)-sum(vg.EXECQTTY)),sum(se.trade)) trade
             from semast se, cfmast cf, securities_info sec , v_getsellorderinfo vg
             where se.custid = cf.custid
             and se.acctno = vg.SEACCTNO (+)
             and cf.custodycd= v_msgbodySLK
             and se.codeid = sec.codeid
             and se.trade <> '0'
             and sec.tradebuysell ='Y'
             group by sec.symbol, vg.EXECQTTY) s;
           exception
           when others then
                l_details := '';
           end ;
           if l_details is not null then
             l_data_source := 'select ''' || v_msgbodySLK ||
             ''' custodycd,''' || l_details ||
             ''' details from dual;';


           else if l_details is null then
             l_details := 'quy khach khong co chung khoan';
             l_data_source := 'select ''' || v_msgbodySLK ||
             ''' custodycd,''' || l_details ||
             ''' details from dual;';


           end if;
           end if;
           --NMPKS_EMS.InsertEmailLog(v_mobile, '0333', l_data_source , '');
           insert into emaillog
          (autoid, email, templateid, datasource, status, createtime, note)
         values
          (seq_emaillog.nextval,
           v_mobile,
           '0333',
           l_data_source,
           'A',
           sysdate,
           '---');
       --cu phap sai so dien thoai
       else
         l_details:='Tai khoan hoac so dien thoai cua ban chua dang ky dich vu, hay lien he toi so 04.39264660, 08.38218889 de biet them thong tin chi tiet.';

         l_data_source := 'select ''' || v_msgbodySLK ||
           ''' custodycd,''' || l_details ||
           ''' details from dual;';

         --NMPKS_EMS.InsertEmailLog(v_mobile, '0340', l_data_source , '');
         insert into emaillog
          (autoid, email, templateid, datasource, status, createtime, note)
         values
          (seq_emaillog.nextval,
           v_mobile,
           '0340',
           l_data_source,
           'A',
           sysdate,
           '---');
       end if;
       ----------trang thai lenh
    else if v_msgbody='TTL' and v_msgbodyBSC='BSC' then

       v_mobile := '0'||ltrim(substr(:newval.SRC,1),'+84');
       begin
         select mobilesms into l_mobilesms from VW_CFMAST_SMS where custodycd= v_msgbodySLK;
       exception
         when others then
                l_mobilesms := '';
         end ;
       if l_mobilesms = v_mobile then
          begin
                select listagg(detail, ', ') within group(order by detail)  as detail
                into l_details
       from (
            select max(autoid) autoid, custodycd, orderid, txdate,
            (MAX(ORDERQTTY) - max(TOTALQTTY)) as KLCL ,
            lower(substr(header,1,3)) || ' ' || MAX(ORDERQTTY) || ' ' ||  ltrim(substr(header,4))  || 'gia ' || price || ' da khop ' ||
            listagg(detail, ', ') within group(order by detail)  as detail
            from (select a.*, rownum top
                 from (select max(autoid) autoid, txdate, custodycd, orderid, header,max(TOTALQTTY) TOTALQTTY,ORDERQTTY,price,
                   sum(matchqtty) || ' gia ' || matchprice as detail
                   from smsmatched
                   where custodycd = v_msgbodySLK
                   group by txdate, custodycd, orderid, header, matchprice ,ORDERQTTY,price
                   order by autoid) a)
                   group by custodycd, orderid, txdate, header ,price
                   order by autoid)
            group by custodycd, txdate;
           exception
           when others then
                l_details := '';
                checknull := false;
           end ;
           --CHECK KHI KHONG CO LENH KHOP
           if l_details is not null then
                l_data_source := 'select ''' || v_msgbodySLK ||
           ''' custodycd,''' || l_details ||
           ''' details from dual;';

           ELSE IF l_details is null THEN
               l_details := 'quy khach khong co lenh khop.';
                l_data_source := 'select ''' || v_msgbodySLK ||
           ''' custodycd,''' || l_details ||
           ''' details from dual;';


           end if;
           END IF;
           --NMPKS_EMS.InsertEmailLog(v_mobile, '0334', l_data_source , '');
           insert into emaillog
          (autoid, email, templateid, datasource, status, createtime, note)
         values
          (seq_emaillog.nextval,
           v_mobile,
           '0334',
           l_data_source,
           'A',
           sysdate,
           '---');
       --cu phap sai so dien thoai
       else
         l_details:='Tai khoan hoac so dien thoai cua ban chua dang ky dich vu, hay lien he toi so  04.39264660, 08.38218889 de biet them thong tin chi tiet.';

         l_data_source := 'select ''' || v_msgbodySLK ||
           ''' custodycd,''' || l_details ||
           ''' details from dual;';

         --NMPKS_EMS.InsertEmailLog(v_mobile, '0340', l_data_source , '');
         insert into emaillog
          (autoid, email, templateid, datasource, status, createtime, note)
         values
          (seq_emaillog.nextval,
           v_mobile,
           '0340',
           l_data_source,
           'A',
           sysdate,
           '---');
       end if;
    end if;
    end if;
    end if;
    ------------------------------
    --check thong tin san

    if v_msgbodyINDEX = 'INDEX' and v_msgbodyBSC ='BSC' then
       v_MaSan := UPPER(substr(replace ( :newval.msgbody,' ',''),9));
    end if;
    --check thong tin chung khoan

    v_MCK := UPPER(substr(replace ( :newval.msgbody,' ',''),6));
    if v_msgbodyCK ='CK' and v_msgbodyBSC ='BSC' then

       v_mobile := '0'||ltrim(substr(:newval.SRC,1),'+84');

       begin
       select se.basicprice as TC,
         se.ceilingprice as Tran,
         se.floorprice as San
         into l_TC, l_Tran, l_San
         from securities_info se where symbol = v_MCK;
       exception
       when others then
            l_TC := '';
            l_Tran := '';
            l_San := '';
            checknull := false;
       end ;
       if checknull = true then
         l_details := 'TC: ' || round(l_TC) || ', TRAN: ' || round(l_Tran) || ', SAN: ' || round(l_San) ;
         l_data_source := 'select ''' ||
             v_MCK || ''' mck,''' ||
             l_details || ''' details from dual;';

       --check ma~ ck
       else if checknull = false then
         l_details := 'ma CK khong dung.';

         l_data_source := 'select ''' ||
             v_MCK || ''' mck,''' ||
             l_details || ''' details from dual;';

       end if;
       end if;
       --NMPKS_EMS.InsertEmailLog(v_mobile, '0336', l_data_source, '');
       insert into emaillog
          (autoid, email, templateid, datasource, status, createtime, note)
         values
          (seq_emaillog.nextval,
           v_mobile,
           '0336',
           l_data_source,
           'A',
           sysdate,
           '---');
    end if;
    ------------------------------
    --cu phap khi tin nhan sai dinh dang
    if v_msgbody not in ('TIEN','TTL','SDCK') and v_msgbodyCK <> 'CK' and v_msgbodyINDEX <> 'INDEX' or v_msgbodyBSC <> 'BSC' then

       v_mobile := '0'||ltrim(substr(:newval.SRC,1),'+84');

       l_details:='Tin nhan cua ban khong dung dinh dang, de nghi lien he BSC de biet them thong tin chi tiet.';

       l_data_source := 'select ''' || l_details ||
           ''' details from dual;';

         --NMPKS_EMS.InsertEmailLog(v_mobile, '0340', l_data_source , '');
         insert into emaillog
          (autoid, email, templateid, datasource, status, createtime, note)
         values
          (seq_emaillog.nextval,
           v_mobile,
           '0340',
           l_data_source,
           'A',
           sysdate,
           '---');
    end if;
    --CHECK TIN NHAN SAI CU PHAP 2
    IF LENGTH(UPPER(replace(:newval.MSGBODY,' ',''))) < 14  and v_msgbodyCK <> 'CK' and v_msgbodyINDEX <> 'INDEX' THEN
      v_mobile := '0'||ltrim(substr(:newval.SRC,1),'+84');

       l_details:='Tin nhan cua ban khong dung dinh dang, de nghi lien he BSC de biet them thong tin chi tiet.';

       l_data_source := 'select ''' || l_details ||
           ''' details from dual;';

         --NMPKS_EMS.InsertEmailLog(v_mobile, '0340', l_data_source , '');
         insert into emaillog
          (autoid, email, templateid, datasource, status, createtime, note)
         values
          (seq_emaillog.nextval,
           v_mobile,
           '0340',
           l_data_source,
           'A',
           sysdate,
           '---');
    end if;
    -----------------------------------
    end if;
end;
/
