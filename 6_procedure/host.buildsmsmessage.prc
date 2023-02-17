SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "BUILDSMSMESSAGE"
IS
       v_err    VARCHAR2(100);
BEGIN

insert into smslog ( autoid ,refid,reftype, phonenumber,message,createddt,txdate,status,sentdt,runmod,errcode,errmsg,sendnumber)
select seq_smslog.NEXTVAL , refid , reftype, phone, message, SYSTIMESTAMP, txdate,status, sentdt,  runmod, errcode,  errmsg, sendnumber from
(
    select refid, temp.acctno acctno , 'CIBALANCE' reftype, SUBSTR(cf.mobilesms,1,15) phone,
    '[' || to_char(temp.txdate, 'DD/MM/RRRR')|| '].TK: ' || cf.custodycd || ' : ' ||
    (case
        when temp.amt > 0 then ' Tang : '
        when temp.amt < 0 then ' Giam : '
     end
     ) || abs(temp.amt) || ' dong.'  message, temp.txdate,'P' status, NULL sentdt, 'A' runmod, NULL errcode, NULL errmsg, 0 sendnumber, ROWNUM rown
    from
    (
        select tr.autoid refid ,tr.acctno, tr.txdate,
        sum (case when apptx.txtype = 'D' then -tr.namt else tr.namt
            end)  amt
        from citran tr, tllog tl, apptx
        where tr.txnum = tl.txnum and tl.txdate = tr.txdate
        and tr.txcd = apptx.txcd and apptx.apptype = 'CI' and field = 'BALANCE'
        and tr.deltd <> 'Y'
        and tl.batchname = 'DAY'
        and not exists (select autoid,txdate from smslog where tr.autoid = smslog.refid and smslog.txdate = tr.txdate)
        group by tr.autoid ,tr.acctno, tr.txdate
    ) temp, cfmast cf, afmast af
    where temp.acctno = af.acctno and cf.custid = af.custid
    and SUBSTR(cf.mobilesms,1,1) = '0'
    and temp.amt <> 0
) A where A.rown <= 50;

commit;
EXCEPTION
    WHEN others THEN
    ROLLBACK;
      v_err := 'ERR :' || SQLERRM;
      INSERT INTO log_err (id,date_log, POSITION, text)
             VALUES (seq_log_err.NEXTVAL, SYSDATE, 'BUILDSMS', v_err);
    commit;
    return;
end;

 
 
 
 
/
