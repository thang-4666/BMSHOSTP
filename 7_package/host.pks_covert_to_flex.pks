SET DEFINE OFF;
CREATE OR REPLACE PACKAGE pks_covert_to_flex is

  -- Author  : TruongLD
  -- Created : 15/11/2016
  -- Purpose : convert data
  procedure Truncate_table ;
  procedure InsertConvertLog(p_typecv  varchar2, p_description varchar2   );
  procedure ResetSeq;
  procedure Cleandata;
  procedure Cfmastcv;
  procedure Cfauthcv;
  PROCEDURE ImpTableConvert ;
  procedure Cimastcv;
  procedure Semastcv;
  procedure odmastcv;
  procedure lnmastcv;
  procedure adschdcv;
  procedure cfotheracccv;
  procedure setupconvert;
  procedure userlogincv;
  procedure endconvert;
  procedure tllogcv;

  C_CONST_CFTYPE_C_I CONSTANT VARCHAR2(20):= '0001';
  C_CONST_CFTYPE_C_B CONSTANT VARCHAR2(20):= '0002';
  C_CONST_CFTYPE_P CONSTANT VARCHAR2(20):= '0000';

  C_CONST_ADTYPE CONSTANT VARCHAR2(20):= '0001';

  C_CONST_AFTYPE_NN CONSTANT VARCHAR2(20):= '0001'; -- Thuong
  C_CONST_AFTYPE_NM CONSTANT VARCHAR2(20):= '0002'; -- Margin

  C_CONST_LNTYPE_T0 CONSTANT VARCHAR2(20):= '0001'; -- Vay BL
  C_CONST_LNTYPE_MR CONSTANT VARCHAR2(20):= '0003'; -- Vay MR

  C_CONST_USERCV CONSTANT VARCHAR2(20):= '0001';

  C_CONST_DEPOLASTDT CONSTANT DATE:= TO_DATE('01/12/2016','DD/MM/RRRR');

  PROCEDURE OTC_CFMASTCV;

  PROCEDURE OTC_CIMASTCV;

  PROCEDURE OTC_SEMASTCV  ;

  PROCEDURE OTC_PREV_Convert;

  function fn_todate(p_date in varchar2)
  return date;

  function fn_tonumber(p_number in varchar2)
  return number;

  function fn_convert_linkauth(p_linkauth in varchar2)
  return varchar2;

end pks_covert_to_flex;
 
 
/


CREATE OR REPLACE PACKAGE BODY pks_covert_to_flex is

  pkgctx plog.log_ctx;
  logrow tlogdebug%rowtype;

 procedure InsertConvertLog(p_typecv       varchar2,
                              p_description VARCHAR2 ) is

  BEGIN
    INSERT INTO CONVERT_LOG(id,typecv,description)
    VALUES ( seq_convert_log.NEXTVAL,p_typecv ,p_description);
    COMMIT;

  Exception
    when others then
      plog.error(pkgctx, sqlerrm);
      plog.setEndSection(pkgctx, 'InsertConvertLog');
END;

PROCEDURE setupconvert
IS
    v_currdate varchar2(50);
    v_prevdate varchar2(50);
    v_nextdate varchar2(50);
BEGIN
    InsertConvertLog('I','Begin setupconvert');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE convert_log' );

    select VARVALUE into v_prevdate from sysvar where VARNAME ='PREVDATE';
    select VARVALUE into v_currdate from sysvar where VARNAME ='CURRDATE';
    select VARVALUE into v_nextdate from sysvar where VARNAME ='NEXTDATE';

    Delete  from sysvar where VARNAME in ('CURRDATE','PREVDATE','BUSDATE','NEXTDATE');

    INSERT INTO sysvar
    (GRNAME,VARNAME,VARVALUE,VARDESC,EN_VARDESC)
    VALUES
    ('SYSTEM','CURRDATE',v_currdate,'Current working date',NULL);

    INSERT INTO sysvar
    (GRNAME,VARNAME,VARVALUE,VARDESC,EN_VARDESC)
    VALUES
    ('SYSTEM','PREVDATE',v_prevdate,'Previous working date',NULL);

    INSERT INTO sysvar
    (GRNAME,VARNAME,VARVALUE,VARDESC,EN_VARDESC)
    VALUES
    ('SYSTEM','BUSDATE',v_currdate,'Current business date',NULL);

    INSERT INTO sysvar
    (GRNAME,VARNAME,VARVALUE,VARDESC,EN_VARDESC)
    VALUES
    ('SYSTEM','NEXTDATE',v_nextdate,'Next working date',NULL);

    COMMIT;

    EXECUTE IMMEDIATE('drop sequence seq_CONVERT');
    EXECUTE IMMEDIATE('create sequence seq_CONVERT NOCACHE ');


    EXECUTE IMMEDIATE('drop sequence seq_tlprofilecv');
    EXECUTE IMMEDIATE('create sequence seq_tlprofilecv NOCACHE ');

    EXECUTE IMMEDIATE('drop sequence seq_Cv_orderid');
    EXECUTE IMMEDIATE('create sequence seq_Cv_orderid NOCACHE ');

    EXECUTE IMMEDIATE('drop sequence seq_lnmast');
    EXECUTE IMMEDIATE('create sequence seq_lnmast NOCACHE ');

    reset_sequence('seq_cvtxnum',1);


    pr_gen_sbcurrdate();

    InsertConvertLog('I','End setupconvert');
    Commit;
EXCEPTION
    WHEN OTHERS THEN
         InsertConvertLog('E','Setupconvert, '
                               ||sqlerrm || '.At:' || dbms_utility.format_error_backtrace);

END;

PROCEDURE ImpTableConvert
IS
BEGIN
    setupconvert();
    CFMASTCV();
    CFOTHERACCCV();
    ODMASTCV();
    CIMASTCV();
    SEMASTCV();
    LNMASTCV();
    ADSCHDCV();
    TLLOGCV();
    USERLOGINCV();

    OTC_PREV_Convert();
    OTC_CFMASTCV();
    OTC_CIMASTCV();
    OTC_SEMASTCV();


    ENDCONVERT();
EXCEPTION
    WHEN OTHERS THEN
    plog.error(pkgctx, sqlerrm);
    InsertConvertLog('E',sqlerrm) ;
END;

PROCEDURE OTC_PREV_Convert
IS

BEGIN
    InsertConvertLog('I','Begin OTC_PREV_Convert...');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CFMASTCV');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CIMASTCV');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE SEMASTCV');
    -- Thong tin KH Nam A
    INSERT into cfmastcv(brid, custodycd, cftype, fullname, dateofbirth, sex,
        idcode, idtype, iddate, idplace, phone, mobilecall,
        mobilesms, mnemonic, tradingcodedt, fax, email,
        address, province, country, class, custtype, isdepo,
        maker, checker, careby, pin, tradingcode, vat,
        vcbs_oldcode, workplace, opndate, isonline, istele,
        isfatca, description, deltd, errmsg, autoid)
    Select a.brid, a.custodycd, '0001' cftype, a.fullname, fn_todate(a.dateofbirth),
        (case when upper(a.sex) ='NAM' then '001'
             when upper(a.sex) ='NU' then '002' else '000' end) sex, a.idcode,
        nvl(a.idtype,'001') idtype,
        fn_todate(a.iddate),
        nvl(a.idplace,''), a.phone,
        (case when mobile like '09%' then SUBSTR(REPLACE(REPLACE(mobile,' ',''),'.',''),0,10)
          when mobile like '01%' then SUBSTR(REPLACE(REPLACE(mobile,' ',''),'.',''),0,11)
          when mobile like '08%' then SUBSTR(REPLACE(REPLACE(mobile,' ',''),'.',''),0,10)
          else '' end) mobilecall,
        (case when mobile like '09%' then SUBSTR(REPLACE(REPLACE(mobile,' ',''),'.',''),0,10)
          when mobile like '01%' then SUBSTR(REPLACE(REPLACE(mobile,' ',''),'.',''),0,11)
          when mobile like '08%' then SUBSTR(REPLACE(REPLACE(mobile,' ',''),'.',''),0,10)
          else '' end)  mobilesms,
        '' mnemonic, a.tradingcodedt, '' fax, a.email,
        a.address, a.province, a.country, '' class,
        (case when a.ctmtype ='002' then 'B' else 'I' end) custtype, '' isdepo,
        a.maker, a.checker, a.careby, '' pin, a.tradingcode, 'Y' vat,
        '' vcbs_oldcode, '' workplace, getcurrdate opndate, 'N' isonline, 'N' istele,
        'N' isfatca, 'NAM A' description, 'N' deltd, '' errmsg, '' autoid
    FROM t_cfmast_nama a  where custodycd is not null;

    INSERT into cfmastcv(brid, custodycd, cftype, fullname, dateofbirth, sex,
        idcode, idtype, iddate, idplace, phone, mobilecall,
        mobilesms, mnemonic, tradingcodedt, fax, email,
        address, province, country, class, custtype, isdepo,
        maker, checker, careby, pin, tradingcode, vat,
        vcbs_oldcode, workplace, opndate, isonline, istele,
        isfatca, description, deltd, errmsg, autoid)
     Select a.brid, a.custodycd, '0001' cftype, a.fullname,
        fn_todate(a.dateofbirth),
        (case when upper(a.sex) ='NAM' then '001'
             when upper(a.sex) ='NU' then '002' else '000' end) sex, a.idcode,
        nvl(a.idtype,'001') idtype,
        fn_todate(a.iddate),
        nvl(a.idplace,''), a.phone,
        (case when mobile like '09%' then SUBSTR(REPLACE(REPLACE(mobile,' ',''),'.',''),0,10)
          when mobile like '01%' then SUBSTR(REPLACE(REPLACE(mobile,' ',''),'.',''),0,11)
          when mobile like '08%' then SUBSTR(REPLACE(REPLACE(mobile,' ',''),'.',''),0,10)
          else '' end) mobilecall,
        (case when mobile like '09%' then SUBSTR(REPLACE(REPLACE(mobile,' ',''),'.',''),0,10)
          when mobile like '01%' then SUBSTR(REPLACE(REPLACE(mobile,' ',''),'.',''),0,11)
          when mobile like '08%' then SUBSTR(REPLACE(REPLACE(mobile,' ',''),'.',''),0,10)
          else '' end)  mobilesms,
        '' mnemonic, a.tradingcodedt, '' fax, a.email,
        a.address, a.province, a.country, '' class,
        (case when a.ctmtype ='002' then 'B' else 'I' end) custtype, '' isdepo,
        a.maker, a.checker, a.careby, '' pin, a.tradingcode, 'Y' vat,
        '' vcbs_oldcode, '' workplace, getcurrdate opndate, 'N' isonline, 'N' istele,
        'N' isfatca, 'BMSC' description, 'N' deltd, '' errmsg, '' autoid
    FROM t_cfmast_bmsc a where custodycd is not null;


    Update cfmastcv set idtype ='001' where idtype='CMND';
    Update cfmastcv set idtype ='005' where idtype='GPKD';

    Update cfmastcv set cftype ='0003', dateofbirth = fn_todate(dateofbirth) where custtype='I';
    Update cfmastcv set cftype ='0004', dateofbirth = fn_todate(dateofbirth) where custtype='B';

    COMMIT;


    INSERT into cimastcv (custodycd, accounttype, balance, description, EMKAMT)
    select DISTINCT mst.custodycd, 'C', nvl(balance,0), nvl(mst.description,'Convert data to FLEX'), 0
    from t_cimastcv_bmsc mst, cfmastcv cf
    where mst.custodycd = cf.custodycd and nvl(balance,0) > 0;


    INSERT into  semastcv (custodycd, accounttype, symbol, trade, shareholdersid)
    select DISTINCT mst.custodycd, 'C', symbol, nvl(trade,0), mst.shareholdersid
    from t_semastcv_bmsc mst, cfmastcv cf
    where mst.custodycd = cf.custodycd and nvl(trade,0) > 0;

    INSERT into  semastcv (custodycd, accounttype, symbol, trade, shareholdersid)
    select DISTINCT mst.custodycd, 'C', symbol, nvl(trade,0), mst.shareholdersid
    from t_semastcv_nama mst, cfmastcv cf
    where mst.custodycd = cf.custodycd and nvl(trade,0) > 0;

    COMMIT;

    InsertConvertLog('I','End OTC_PREV_Convert...');
EXCEPTION
    WHEN OTHERS THEN
    plog.error(pkgctx, sqlerrm);
    InsertConvertLog('E',sqlerrm) ;
END;

PROCEDURE OTC_SEMASTCV  IS
    v_currdate date;
    v_prevdate date;
    v_nextdate date;
    v_t_1_date date;
    v_t_2_date date;
    v_t_3_date date;
    V_TXNUM VARCHAR2(20);
    v_max_autoid number;
BEGIN

select to_date(varvalue,'DD/MM/RRRR') into v_currdate from sysvar where grname ='SYSTEM' and varname ='CURRDATE';
select to_date(varvalue,'DD/MM/RRRR') into v_prevdate from sysvar where grname ='SYSTEM' and varname ='PREVDATE';
select to_date(varvalue,'DD/MM/RRRR') into v_nextdate from sysvar where grname ='SYSTEM' and varname ='NEXTDATE';

InsertConvertLog('I','BEGIN OTC_SEMASTCV...');

Delete from semast se
    where EXISTS (Select * from cfmast cf where cf.custid = se.custid and cf.custodycd like 'OTCC%');

DELETE FROM TLLOGALL MST
    WHERE EXISTS (SELECT * FROM SETRAN_GEN SE
                    WHERE MST.TXNUM = SE.TXNUM AND MST.TXDATE = SE.TXDATE
                          AND SE.CUSTODYCD LIKE 'OTCC%');

DELETE FROM SETRAN MST
    WHERE EXISTS (SELECT * FROM SETRAN_GEN SE
                    WHERE MST.TXNUM = SE.TXNUM AND MST.TXDATE = SE.TXDATE
                          AND SE.CUSTODYCD LIKE 'OTCC%');

DELETE FROM SETRAN_GEN WHERE CUSTODYCD LIKE 'OTCC%';

DELETE FROM SEOTCTRANLOG;

RESET_SEQUENCE(SEQ_NAME => 'seq_seotctranlog', STARTVALUE => 1);
select max(autoid) + 1 into v_max_autoid from vw_setran_all;
RESET_SEQUENCE(SEQ_NAME => 'seq_setran', STARTVALUE => v_max_autoid);


for rec in
(
    SELECT cf.CUSTODYCD, AF.ACCTNO,SB.CODEID ,sb.symbol, AF.ACCTNO||SB.CODEID SEACCTNO,AF.CUSTID, SE.TRADE, se.SHAREHOLDERSID
    FROM CFMAST CF, AFMAST AF,  SBSECURITIES SB,
    (
        SELECT CUSTODYCD ,SYMBOL SYMBOL , TO_NUMBER(NVL(TRADE,0)) TRADE,
               CUSTODYCD|| ACCOUNTTYPE DESCRIPTION, SHAREHOLDERSID
        FROM SEMASTCV
    )SE
    WHERE CF.CUSTID = AF.CUSTID
          AND SB.SYMBOL = SE.SYMBOL
          AND SE.CUSTODYCD = CF.CUSTODYCD
          and SE.TRADE > 0
)
loop
    insert into semast (ACTYPE, ACCTNO, CODEID, AFACCTNO, OPNDATE, CLSDATE, LASTDATE, STATUS, PSTATUS, IRTIED, IRCD, COSTPRICE, TRADE, MORTAGE, MARGIN, NETTING, STANDING, WITHDRAW, DEPOSIT, LOAN, BLOCKED, RECEIVING, TRANSFER, PREVQTTY, DCRQTTY, DCRAMT, DEPOFEEACR, REPO, PENDING, TBALDEPO, CUSTID, COSTDT, SECURED, ICCFCD, ICCFTIED, TBALDT, SENDDEPOSIT, SENDPENDING, DDROUTQTTY, DDROUTAMT, DTOCLOSE, SDTOCLOSE, QTTY_TRANSFER, LAST_CHANGE,     DEALINTPAID, WTRADE)
    values ('0000', rec.seacctno, rec.codeid, rec.ACCTNO,v_prevdate, null, v_prevdate, 'A', '', 'Y', '001', 0.00, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, rec.custid, v_prevdate, 0, '', 'Y',v_prevdate, 0, 0, 0, 0, 0, 0, 0, '18-OCT-11 03.30.05.344506 PM',    0.0000, 0);

    update semast set TRADE = TRADE + REC.TRADE, TBALDT = getcurrdate() WHERE ACCTNO = REC.SEACCTNO;

    V_TXNUM := '9990'|| LPAD(seq_CVtxnum.NEXTVAL,6,'0');
    INSERT INTO tllogall
    (AUTOID,TXNUM,TXDATE,TXTIME,BRID,TLID,OFFID,OVRRQS,CHID,CHKID,TLTXCD,IBT,BRID2,TLID2,CCYUSAGE,OFF_LINE,DELTD,BRDATE,BUSDATE,TXDESC,IPADDRESS,WSNAME,TXSTATUS,MSGSTS,OVRSTS,BATCHNAME,MSGAMT,MSGACCT,CHKTIME,OFFTIME,CAREBYGRP)
    VALUES
    (seq_tllog.NEXTVAL ,V_TXNUM,v_prevdate,'13:50:24','0001','0001','0001','@00',NULL,NULL,'9902',NULL,NULL,NULL,'00','N','N',v_prevdate,v_prevdate,'Inward SE Transfer','10.26.0.125','Admin','1','0','0','DAY',REC.TRADE ,REC.SEACCTNO,NULL,'01:51:39',NULL);

    if rec.trade>0 then
        INSERT INTO setrana(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,REF,DELTD,AUTOID)
        VALUES (V_TXNUM,v_prevdate,rec.seacctno,'0045',rec.trade,NULL,'','N',seq_setran.nextval);
    end if;

    -- Cap nhat thong tin lien quan den so co dong

    If rec.symbol ='NAMABANK' then

        INSERT into seotctranlog(autoid, txnum, txdate, tltxcd, seacctno, typepon, shareholdersid, status, amount, trade, deltd)
        SELECT seq_seotctranlog.nextval autoid, V_TXNUM txnum, v_prevdate txdate, '9902' tltxcd, rec.seacctno,
               'NE' typepon, LPAD(REC.SHAREHOLDERSID,5,'0'), 'A' status, rec.TRADE amount, rec.TRADE trade, 'N' deltd
        FROM dual a;

        update semast set  shareholdersid = LPAD(REC.SHAREHOLDERSID,5,'0') where acctno = rec.seacctno;
    Else
        INSERT into seotctranlog(autoid, txnum, txdate, tltxcd, seacctno, typepon, shareholdersid, status, amount, trade, deltd)
        SELECT seq_seotctranlog.nextval autoid, V_TXNUM txnum, v_prevdate txdate, '9902' tltxcd, rec.seacctno,
               'NE' typepon, LPAD(REC.SHAREHOLDERSID,4,'0'), 'A' status, rec.TRADE amount, rec.TRADE trade, 'N' deltd
        FROM dual a;

        update semast set  shareholdersid = LPAD(REC.SHAREHOLDERSID,4,'0') where acctno = rec.seacctno;
    End If;
end loop;
    --End

COMMIT;


INSERT INTO setran_gen (AUTOID,CUSTODYCD,CUSTID,TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,REF,DELTD,ACCTREF,TLTXCD,BUSDATE,TXDESC,TXTIME,BRID,TLID,OFFID,CHID,AFACCTNO,SYMBOL,SECTYPE,TRADEPLACE,TXTYPE,FIELD,CODEID,TLLOG_AUTOID,TRDESC)
select tr.autoid, cf.custodycd, cf.custid, tr.txnum, tr.txdate, tr.acctno, tr.txcd, tr.namt, tr.camt, tr.ref, tr.deltd, tr.acctref,
    tl.tltxcd, tl.busdate,
    case when tl.tlid ='6868' then trim(tl.txdesc) || ' (Online)' else tl.txdesc end txdesc,
    tl.txtime, tl.brid, tl.tlid, tl.offid, tl.chid,
    se.afacctno, sb.symbol, sb.sectype, sb.tradeplace, ap.txtype, ap.field, sb.codeid ,tl.autoid,
    case when tr.trdesc is not null
        then (case when tl.tlid ='6868' then trim(tr.trdesc) || ' (Online)' else tr.trdesc end)
        else tr.trdesc end trdesc
from setrana tr, tllogall tl, sbsecurities sb, semast se, cfmast cf, apptx ap
where tr.txdate = tl.txdate and tr.txnum = tl.txnum
    and tr.acctno = se.acctno
    and sb.codeid = se.codeid
    and se.custid = cf.custid
    and tr.txcd = ap.txcd and ap.apptype = 'SE' and ap.txtype in ('D','C')
    and tr.deltd <> 'Y' and tr.namt <> 0
    and cf.custodycd like 'OTCC%'
    and tr.txdate = v_prevdate;

COMMIT;

InsertConvertLog('I','END OTC_SEMASTCV...');
EXCEPTION
    WHEN OTHERS THEN
        plog.error(pkgctx, sqlerrm);
        InsertConvertLog('E','OTC_SEMASTCV ' || sqlerrm) ;
END;


PROCEDURE Cleandata is
BEGIN
    Truncate_table();
    ResetSeq();
   plog.setEndSection(pkgctx, 'Cleandata');
 exception
    when others then
      plog.error(pkgctx, sqlerrm);
      plog.setEndSection(pkgctx, 'Cleandata');
END;

Procedure Truncate_table  IS
  str  nvarchar2(3200);
  BEGIN

    dbms_utility.exec_ddl_statement('TRUNCATE TABLE convert_log' );
    InsertConvertLog('I','Begin truncate table....');

    dbms_utility.exec_ddl_statement('TRUNCATE TABLE ACCCFTYPELOG');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE ACCUPDATE');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE ACTYPEMAP');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE ADJUSTMENU');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE ADJUSTORDERPTACK');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE ADJUSTORDERPTACK_HIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE ADMAST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE ADMINMSG');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE ADMINMSGHIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE ADPRMFEECF');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE ADPRMFEECFIMP');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE ADPRMFEECFIMP_HIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE ADPRMFEEMST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE ADPRMFEEMSTMEMO');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE ADSCHD');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE ADSCHDCV');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE ADSCHDDTL');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE ADSCHDHIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE ADSCHDTEMP');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE ADTYPEMEMO');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE ADVRESLNK');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE ADVRESLNKCV');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE ADVRESLNKMEMO');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE ADVRESLOG');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE ADVRESLOGHIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE ADVRESLOG_BK');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE AFBRKFEEGRP');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE AFBRKFEEGRPLOG');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE AFDEFSCHD');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE AFDFBASKETHIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE AFDFBASKETMEMO');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE AFDSOGRP');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE AFEXTACCT');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE AFGROUPDETAIL');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE AFGROUPHEADER');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE AFIBDEALSFEE');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE AFIDTYPEMEMO');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE AFLN_INFO_LOG');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE AFMARGININFO');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE AFMAST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE AFMASTCV');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE AFMASTCV1');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE AFMASTMEMO');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE AFMASTTEMP');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE AFMAST_LOG');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE AFMRLIMITGRP');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE AFPOLICYDTL');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE AFPOLICYMAP');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE AFPOLICYMST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE AFPRALLOC');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE AFPRALLOCATION');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE AFPRALLOCHIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE AFPRINUSEDLOG');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE AFSEBASKETHIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE AFSEINFO');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE AFSEINFO_LOG');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE AFSELIMIT');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE AFSELIMITGRP');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE AFSELIMITGRPLOG');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE AFSELIMITGRPMEMO');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE AFSERISK74HIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE AFSERISKHIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE AFSE_INFO_LOG');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE AFTEMPLATESMEMO');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE AFTRANA');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE AFTXMAPHIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE AFTYPEMEMO');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE AFTYPE_LOG');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE AFTYPE_TEMP');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE AFUSERLNK');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE AFUSERTRDLNK');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE AFUSERTRDLNKMEMO');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE AIBANKACCT');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE AIQUEUETRANSFER');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE AISYSVAR');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE AITRANLOG');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE ALLCODEMEMO');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE ALL_DAYPRICE');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE ALL_DAYPRICE_HIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE APPMSGLOG');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE APPMSGLOGHIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE APPMSGMAP');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE APPMSGTX');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE APPRVEXEC');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE AQ$_FSS_QO_PROCESS_TABLE_G');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE AQ$_FSS_QO_PROCESS_TABLE_H');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE AQ$_FSS_QO_PROCESS_TABLE_I');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE AQ$_FSS_QO_PROCESS_TABLE_L');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE AQ$_FSS_QO_PROCESS_TABLE_S');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE AQ$_FSS_QO_PROCESS_TABLE_T');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE AQ$_FSS_QT_PROCESS_TABLE_G');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE AQ$_FSS_QT_PROCESS_TABLE_H');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE AQ$_FSS_QT_PROCESS_TABLE_I');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE AQ$_FSS_QT_PROCESS_TABLE_L');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE AQ$_FSS_QT_PROCESS_TABLE_S');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE AQ$_FSS_QT_PROCESS_TABLE_T');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE AUTH_LOOKUP');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE AVRBAL');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE AVRBALALL');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE BANKACCTINFO');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE BANKACC_RECEIPT');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE BANKCODE');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE BANKINFO');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE BANKNOSTROMEMO');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE BASKETMEMO');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE BATCHLOG');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE BATCHLOGMEMO');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE BIDVTRANLOG');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE BIDVWARNINGHOLDLOG');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE BL_EVENT');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE BL_EVENTHIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE BL_EXEC_RPT');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE BL_EXEC_RPTHIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE BL_LOG');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE BL_MAPORDER');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE BL_MSGSEQNUM_MAP');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE BL_ODMAST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE BL_ODMASTDTL');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE BL_ODMASTDTLHIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE BL_ODMASTHIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE BL_ORDERCANCELREJECT');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE BL_REGISTER');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE BL_REJECT');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE BL_TRADEREF');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE BONDCUST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE BONDDEAL');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE BONDIPO');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE BONDREPO');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE BONDTRANSACTPT');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE BORQSLOG');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE BORQSLOGDTL');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE BORQSLOGDTLHIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE BORQSLOGHIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE BRGRPMEMO');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE BRGRPPARAM_BK');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE BRIDTYPEMEMO');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE BRKFEEGRP');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE BRKFEEGRPLOG');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE BROKERLIST_FULLINFOCV');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE BRRGDETAIL');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE BRRGMASTER');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE BUF_AF_ACCOUNT');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE BUF_CI_ACCOUNT');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE BUF_CI_ACCOUNT_NAM');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE BUF_CI_ACCOUNT_NAMNT');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE BUF_OD_ACCOUNT');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE BUF_SE_ACCOUNT');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE BUF_SE_POLICY_ACC');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE BUSMAPTX');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE BUSTXLOG');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE BUSTXLOGHIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CADTLIMP');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CAEXEC_TEMP');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CAMAST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CAMASTHIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CAMASTMEMO');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CANCELORDERPTACK');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CANCELORDERPTACK_HIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CAREBYCHK');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CASCHD');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CASCHDHIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CASCHDTEMP');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CASCHDTEMP1');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CASCHDTEMPGRP');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CASCHD_TEMP');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CASEND_TEMP');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CATEMP');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CATRAN');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CATRANA');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CATRANSFER');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CATRFLOG');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CF0014_LOG');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CF0080_LOG');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CF0081_LOG');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CFAF');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CFAFCUSTODYCD');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CFAFGROUP');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CFAFPLANLNK');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CFAFTRDALERT');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CFAFTRDALERTLOG');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CFAFTRDLNK');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CFAFTRDPLAN');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CFAFTYPE');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CFAFTYPEMEMO');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CFAUTH');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CFAUTHCV');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CFAUTHMEMO');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CFBANKLIMIT');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CFBANKSTATUS');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CFCHANGEBRIDIMP');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CFCHANGEBRIDIMP_HIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CFCONTACT');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CFCONTACTMEMO');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CFCUSTODYCD');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CFEXTACCT');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CFLIMIT');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CFLIMITEXT');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CFLIMITMAP');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CFLIMITMEMO');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CFLIMITUSER');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CFLINK');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CFMAST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CFMASTCV');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CFMASTMEMO');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CFMASTTEMP');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CFMASTTEMPCV');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CFMASTTEMP_HIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CFMAST_BK');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CFMAST_TEMP');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CFMRIDCODE');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CFOLCHGLOG');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CFOTHERACC');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CFOTHERACCCV');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CFOTHERACCMEMO');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CFRELATION');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CFRELATIONMEMO');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CFREVIEW');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CFREVIEWDAILYLOG');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CFREVIEWDTL');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CFREVIEWLOG');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CFREVIEWLOGHIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CFREVIEWRESULT');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CFTRDALERT');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CFTRDPOLICY');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CFTYPE');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CFTYPELOG');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CFTYPEMEMO');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CFVIP');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CFVSDLOG');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CFVSDLOGTMP');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CHANGECFSTSLOG');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CHANGECFTYPE_LOG');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CHAUNH_LOG');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CHECK_TRADING_RESULT_HIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CHMAST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CHTRAN');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CHTRANA');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CI2000_GL_DAUKY');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CI2001DTL');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CI2001_GL_DAUKY');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CICUSTWITHDRAW');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CIDEPOFEETRAN');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CIFEEDEF');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CIFEEDEF_EXT');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CIFEEDEF_EXTLNK');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CIFEEDEF_EXTLNKCV');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CIFEEDEF_EXTLNKIMP');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CIFEEDEF_EXTLNKIMP_HIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CIFEEDEF_EXTLNKMEMO');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CIFEEDEF_EXTMEMO');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CIFEESCHD');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CIFEESCHDHIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CIINTTRAN');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CIINTTRANA');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CIMAST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CIMASTCV');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CIMAST_13072015');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CIMAST_BG1112');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CIMAST_BK');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CIMAST_BKDEPOFEE');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CIMAST_TEMP');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CIREMITTANCE');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CISCHD');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CISCHDHIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CITEMP');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CITRAN');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CITRAN1120');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CITRANA');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CITRAN_BK');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CITRAN_GEN');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CITRFEOD');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CITRFEOD_BK');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CITYPEMEMO');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CLDEALLOG');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CLDRAWNDOWNRPTLOG');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CLLINK');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CLMAST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CLTRAN');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CLTRANA');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CMDAUTH_BK_1805');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CONFIRMODRSTS');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CONTENTTMP');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CONVERT_COUNT');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CONVERT_LOG');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CRBBANKCODEMAP');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CRBBANKREQUEST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CRBBANKREQUESTHIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CRBBANKTRFLIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CRBCHANGELOG');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CRBHOLDLIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CRBREQUESTRECONCIDE');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CRBTRFACCTSRC');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CRBTRFLOG');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CRBTRFLOGDTL');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CRBTRFLOGDTLHIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CRBTRFLOGHIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CRBTRFREFLOG');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CRBTRFSEQINFO');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CRBTXREQ');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CRBTXREQDTL');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CRBTXREQDTLHIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CRBTXREQHIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CRBTXREQLOG');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CRBTXREQLOGHIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CRINTACRCV');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CRINTACRCV18052015');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CRINTACR_TEMP');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CSIDXINFOR');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CSTB_ENTCRYPTED_LIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CSTB_USER_SOURCES');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CTCI_REJECT');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CURR_SEC_INFO');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CURR_TRADING_RESULT');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CUSTODIANACCT');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CUSTODIANACCTHIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CUSTODYCD_MAP_EXTERNAL');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE DEFGLRULES');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE DEFGLRULESMEMO');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE DEPOFEEAMTCV');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE DEPOFEEAMTCV18052015');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE DEPOINTACRCV');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE DEPOINTACRCV18052015');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE DEPOSIT_MEMBERMEMO');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE DFBASKETHIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE DFBASKETTEMP');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE DFGROUPHIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE DFGRPDTLLOG');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE DFGRPLOG');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE DFMAST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE DFMASTHIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE DFMASTLOG');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE DFSENDVSDDTL');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE DFTEMP');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE DFTRAN');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE DFTRANA');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE DFTYPE');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE DFTYPEMEMO');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE DL_ALERTTEMP');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE DL_SECURITYTEMP');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE DL_TRADERTEMP');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE DSOGRP');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE DTOCLOSEDTL');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE EMAILLOG');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE EMAILLOGHIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE EMAILLOG_BACKUP23');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE EMAILSMSLOG');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE EMPLOYEESLISTCV');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE EOD_DAYPRICE');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE ERRODCV');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE ERRORS');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE EVAL_EXPRESSTION');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE EVENTSLOG');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE EVENTSYS');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE EVENTSYSLOG');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE EXAFMAST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE EXAFMASTHIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE EXAFSCHD');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE EXEC_8');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE EXEC_8_HIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE EXEC_8_QUEUE');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE EXEC_UPCOM_8');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE EXEC_UPCOM_8_HIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE EXPORT_TABLE');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE EXTPOSTMAP');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE EXTREFDEF');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE EXTREFVAL');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE F2E_2I');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE F2E_2I_HIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE FATCA');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE FATCAMEMO');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE FEEMAPMEMO');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE FEEMASTERMEMO');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE FEEMASTERSCHM');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE FEEMASTERSCHMMEMO');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE FEETAX_TEMP');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE FEETRAN');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE FEETRANA');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE FEE_TRANS');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE FILE_1C');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE FILE_1C_HIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE FILE_1D');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE FILE_1D_HIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE FILE_1F');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE FILE_1F_HIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE FILE_1G');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE FILE_1G_HIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE FILE_1I');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE FILE_1I_HIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE FILE_2C');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE FILE_2C_HIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE FILE_2D');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE FILE_2D_HIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE FILE_2E');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE FILE_2E_HIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE FILE_2I');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE FILE_2I_HIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE FILE_2L');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE FILE_2L_HIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE FILE_3B');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE FILE_3B_HIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE FILE_3C');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE FILE_3C_HIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE FILE_3D');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE FILE_3D_HIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE FILE_ASTDL');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE FILE_ASTPT');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE FILE_FROOM');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE FILE_FROOM_HIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE FILE_LE');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE FILE_LE_HIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE FILE_MARKET_STAT');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE FILE_MARKET_STAT_HIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE FILE_PUTAD');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE FILE_PUTAD_HIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE FILE_PUTEXEC');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE FILE_PUTEXEC_HIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE FILE_SECURITY');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE FILE_SECURITY_HIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE FIX1');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE FIXTEMP');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE FLDDEFDESC');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE FLEX2ESBLOG');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE FNMAST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE FNTRAN');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE FNTRANA');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE FOCASCHD');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE FOMAST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE FOMASTHIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE FOMASTLOG');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE FOMASTLOGALL');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE FOMASTMEMO');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE FOMASTMEMOHIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE FOQUEUE');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE FOQUEUEALL');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE FOTRAN');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE FOTRANA');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE FO_AUDIT_LOGS');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE FO_BO2FO_QUEUE');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE FO_BO2FO_QUEUE_LOG');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE FO_FO2BO_QUEUE');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE FSSADSCHDCV');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE FSSADVRESLNKCV');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE FSSAFMASTCV');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE FSSCFAUTHCV');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE FSSCFMASTCV');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE FSSCFMASTTEMPCV');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE FSSCFOTHERACCCV');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE FSSCIFEEDEF_EXTLNKCV');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE FSSCIMASTCV');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE FSSCRINTACRCV');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE FSSDEPOFEEAMTCV');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE FSSDEPOINTACRCV');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE FSSLNMASTCV');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE FSSMG_ACCOUNTBROKERCV');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE FSSMG_DSBROKERCV');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE FSSMG_DSLOAIHINHCV');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE FSSMG_DSNHOMCAREBYCV');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE FSSMG_DSNHOMHOAHONGCV');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE FSSMG_SUDUNGLOAIHINHCV');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE FSSMG_THUOCNHOMCAREBYCV');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE FSSMG_THUOCNHOMCV');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE FSSODPROBRKAFCV');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE FSSPAR_ADVANCE');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE FSSPAR_EXTRANSFER');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE FSSPAR_INTTRANSFER');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE FSSPAR_IODBOOKCV');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE FSSPAR_LNPAIDALLOC');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE FSSPAR_ORDERBOOKCV');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE FSSPAR_SECURITYTRANSFER');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE FSSSBSECURITIESCV');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE FSSSEMASTCV');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE FSSSTSCHDCV');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE FSSSUBACCMASTCV');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE FSSUSERLOGINCV');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE GA');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE GETSECMARGINDETAIL_TEMP');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE GETSECMARGININFO_TEMP');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE GIANH_TEMP');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE GLBANK');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE GLCOA');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE GLDEALPAY');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE GLHIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE GLJOURNAL');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE GLJOURNAL_BK');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE GLLOGHIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE GLLOGHISTALL');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE GLLOGVOUCHER');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE GLLOGVOUCHERALL');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE GLMAP');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE GLMAPPING');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE GLMAST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE GLREF');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE GLREFCOM');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE GLRULES');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE GLRULESMEMO');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE GLRULES_BK');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE GLTEMP');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE GLTRAN');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE GLTRANA');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE GLTRANADTL');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE GLTRANDTL');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE GL_EXP_TRAN');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE GRINTTRAN');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE GRINTTRANA');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE GRMAST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE GROUPBROKERLISTCV');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE GRPGLMAP');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE GRPGLMAPMEMO');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE GRTRAN');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE GRTRANA');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE GRTYPE');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE GWBATCHLOG');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE GWBATCHSEQINFO');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE GWHOLDUNHOLDLOG');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE GWLOG');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE GWLOGHIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE GWTRAN');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE GWTRANSFERLOG');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE GWTRANSFERLOG_11052011');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE GW_PUTBATCHTRANS');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE GW_PUTBATCHTRANS_HIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE GW_TRANSCHKFILE');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE GW_UPDATETRANS');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE HAPTCANCELLED');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE HAPTCANCELLED_HIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE HAPUT_AD');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE HAPUT_ADHIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE HAPUT_AD_DELT');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE HAPUT_AD_DELT_HIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE HASECURITY_REQ');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE HASECURITY_REQ_HIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE HASTATUSREQ');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE HASTATUSREQ_HIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE HA_7');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE HA_7_HIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE HA_B');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE HA_BRD');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE HA_B_HIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE HA_D');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE HA_D_HIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE HA_F');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE HA_F_HIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE HA_G');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE HA_G_HIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE HA_MARKET_INFO');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE HA_ORDERS');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE HA_S');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE HA_STOCK_INFO');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE HA_S_HIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE HA_T');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE HA_TOP_PRICE');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE HA_T_HIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE HA_U');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE HA_U_HIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE HNXTRADINGRESULT');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE HOMSGQUEUE');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE HO_1C');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE HO_1C_HIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE HO_1D');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE HO_1D_HIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE HO_1E');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE HO_1E_HIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE HO_1F');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE HO_1F_HIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE HO_1G');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE HO_1G_HIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE HO_1I');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE HO_1I_HIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE HO_3B');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE HO_3B_HIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE HO_3C');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE HO_3C_HIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE HO_3D');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE HO_3D_HIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE HO_SEC_INFO');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE IBDEALS');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE ICCFMAP');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE ICCFTIER');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE ICCFTIERHIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE ICCFTIER_HIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE ICCFTYPEDEFHIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE ICCFTYPEDEFSCHD');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE ICCFTYPEDEF_HIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE ICCFTYPEHIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE ICCFTYPESCHD');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE ICCFTYPESCHDHIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE ICCFTYPESCHDMAP');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE ICCFTYPESCHDMAPHIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE IDXINFOR');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE INTOPAR_INTSECTRANSFER_HIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE INVESTORS');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE IOD');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE IODCOMPARE');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE IODHIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE IODQUEUE');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE IODSMSLOG');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE IODSMSLOGHIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE IRRATEHIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE IRRATESCHD');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE IRRATESCHM');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE IRRATESCHMHIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE ISSFEEMASTER');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE ISSFEEMASTERMEMO');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE ISSUERSMEMO');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE ISSUERS_BK');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE ISSUER_MEMBERMEMO');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE ITLOG');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE LINKACCOUNTBROKERCV');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE LMLINK');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE LMMAST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE LMTRAN');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE LMTRANA');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE LN1000_AFMARGIN');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE LNAPPL');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE LNDD');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE LNFLOATING');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE LNFLOATINGHIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE LNINTTRAN');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE LNINTTRANA');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE LNMAST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE LNMASTCV');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE LNMASTHIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE LNPAIDALLOC');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE LNPAIDALLOCHIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE LNPAIDALLOCODR');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE LNPAIDALLOC_DTL');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE LNPAIDALLOC_TMP');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE LNPRMINMAST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE LNPRMINMASTMEMO');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE LNPRMINTCF');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE LNPRMINTCFIMP');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE LNPRMINTCFIMP_HIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE LNSCHD');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE LNSCHDEXTLOG');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE LNSCHDHIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE LNSCHDLOG');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE LNSCHDLOGHIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE LNSEBASKET');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE LNSEBASKETHIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE LNTRAN');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE LNTRANA');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE LNTYPEMEMO');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE LOAD_ACCOUNT');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE LOGCSC');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE LOGINFAIL_LOG');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE LOGINHIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE LOGIN_INFO_BO');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE LOGIN_INFO_BOMEMO');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE LOGIN_INFO_BO_HIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE LOGRPORDER');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE LOGRPORDERHIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE LOG_CI_ACCOUNT');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE LOG_ERR');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE LOG_MR0056');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE LOG_MR0064');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE LOG_NOTIFY_EVENT');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE LOG_NOTIFY_EVENT_HIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE LOG_OD_ACCOUNT');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE LOG_SE_ACCOUNT');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE LOG_TRF_TRANSACT');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE MAINTAIN_LOG');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE MARGINRATE_LOG');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE MARKETINFOR');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE MATCHRESULT');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE MESSAGELOG');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE MESSAGELOGHIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE MG_ACCOUNTBROKERCV');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE MG_DSBROKERCV');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE MG_DSLOAIHINHCV');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE MG_DSNHOMCAREBYCV');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE MG_DSNHOMHOAHONGCV');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE MG_SUDUNGLOAIHINHCV');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE MG_THUOCNHOMCAREBYCV');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE MG_THUOCNHOMCV');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE MIMAST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE MISSING_STC');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE MIS_ITEM_GROUPS');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE MIS_ITEM_RESULTS');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE MITRAN');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE MITRANA');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE MITRANADTL');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE MITRANDTL');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE MR0002_LOG');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE MR3008_LOG');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE MR3009_LOG');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE MR3009_LOGALL');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE MR9000_LOG');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE MR9000_LOGHIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE MRLIMITGRP');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE MRPRMLIMITCF');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE MRPRMLIMITCFIMP');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE MRPRMLIMITCFIMP_HIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE MRPRMLIMITMST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE MRPRMLIMITMSTMEMO');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE MRTYPEMEMO');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE MSGQUEUE');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE MSGRECEIVETEMP');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE MSGRECEIVETEMP_HA');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE MSGRECEIVETEMP_HA_E');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE MSGRECEIVETEMP_HA_EHIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE MSGRECEIVETEMP_HA_HIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE MSGRECEIVETEMP_HIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE MSGRECEIVETEMP_UPCOM');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE MSGRECEIVETEMP_UPCOM_E');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE MSGRECEIVETEMP_UPCOM_EHIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE MSGRECEIVETEMP_UPCOM_HIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE MSGSENDTEMP');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE MSGSENDTEMP_HA');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE MSGSENDTEMP_HA_HIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE MSGSENDTEMP_HIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE MSGSENDTEMP_UPCOM');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE MSGSENDTEMP_UPCOM_HIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE MSG_2G_MAP');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE MSG_2G_MAST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE MSG_3D');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE MSG_3D_HIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE NETTING_TRANS');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE ODBRKFEE');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE ODBRKFEEHIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE ODCANCEL');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE ODCANCELALL');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE ODCHANGING');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE ODCHANGING_TRIGGER_LOG');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE ODERS');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE ODFEEODTYPETRAN');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE ODFIXRQS');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE ODMAPEXT');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE ODMAPEXTHIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE ODMAST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE ODMASTHIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE ODMAST_ERR');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE ODPROBRKAF');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE ODPROBRKAFCV');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE ODPROBRKAFIMP');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE ODPROBRKAFIMP_HIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE ODPROBRKAFMEMO');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE ODPROBRKMST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE ODPROBRKMSTLOG');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE ODPROBRKMSTMEMO');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE ODPROBRKSCHM');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE ODPROBRKSCHM2');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE ODQUEUE');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE ODQUEUEALL');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE ODQUEUEBACK');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE ODQUEUELOG');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE ODTRAN');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE ODTRANA');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE ODTYPEMEMO');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE OOD');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE OODHIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE ORDERDEAL');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE ORDERMAP');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE ORDERMAPHIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE ORDERMAP_HA');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE ORDERMAP_HA_HIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE ORDERMAP_HIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE ORDERMAP_UPCOM');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE ORDERMAP_UPCOM_HIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE ORDERPTACK');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE ORDERPTACKHIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE ORDERPTACK_DELT');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE ORDERPTACK_DELT_HIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE ORDERPTACK_HIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE ORDERPTADMEND');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE ORDERPTADV');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE ORDERPTADVHIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE ORDERPTADV_HIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE ORDERPTDEAL_DELT');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE ORDERPTDEAL_DELT_HIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE ORDERS');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE ORDERSMISSING');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE ORDERS_HISTORY');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE ORDER_CHANGE');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE ORDER_CHANGE_HIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE OTHERCIACCTNO_TEMP');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE OTHERSEACCTNO_TEMP');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE OTRIGHTDTL');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE OTRIGHTDTLMEMO');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE OTRIGHTMEMO');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE PAR_ADVANCE');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE PAR_ADVANCE_HIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE PAR_CIINT');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE PAR_DEPO');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE PAR_EXTRANSFER');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE PAR_EXTRANSFER_HIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE PAR_FROMBANK');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE PAR_INTSECTRANSFER');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE PAR_INTSECTRANSFER_HIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE PAR_INTTRANSFER');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE PAR_INTTRANSFER_HIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE PAR_IODBOOKCV');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE PAR_IODBOOKCV_HIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE PAR_LNPAIDALLOC');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE PAR_LNPAIDALLOC_HIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE PAR_ORDERBOOKCV');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE PAR_ORDERBOOKCV_HIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE PAR_RIGHTOFF');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE PAR_RIGHTOFF_HIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE PAR_SECURITYTRANSFER');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE PAR_THANHTOANT3');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE PAR_THANHTOANT3_HIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE PASS_CUSTOMER_LOG');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE PB_SECURITIES');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE PB_SECURITIES_HIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE PLSQL_PROFILER_DATA');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE PLSQL_PROFILER_RUNS');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE PLSQL_PROFILER_UNITS');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE PMRECONCIDE');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE PMTXMAP');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE PMTXMSG');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE PODETAILS');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE PODETAILSHIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE POGROUP');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE POMAST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE POSTMAP');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE PRACTYPEMAP');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE PRAFMAP');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE PRAFMAPMEMO');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE PRINUSEDLOG');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE PRINUSEDLOG_EX');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE PRLOG');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE PRLOGMSG');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE PRMASTER');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE PRMASTERMEMO');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE PRMASTER_TEMP');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE PRTRAN');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE PRTRANA');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE PRTXLOG');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE PRTYPEMAPMEMO');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE PTMATCH');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE PUTTHROUGHINFO');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE QUEST_SL_TEMP_EXPLAIN1');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE QUEST_TEMP_EXPLAIN');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE REAFLNK');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE REAFLNK_TMP');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE REAF_LOG');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE RECFDEF');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE RECFLNK');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE RECOMM');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE RECOMMDTL');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE RECOMMISION');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE RECONCILE');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE REFEEDTL');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE REFPRICE_LOG');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE REGISTERONLINE');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE REGRP');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE REGRPBM_TMP');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE REGRPDEF');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE REGRPHIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE REGRPLEADERS');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE REGRPLNK');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE REGRPLNK_TMP');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE REGRPVC');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE REGTYPE');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE REINTTRAN');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE REINTTRANA');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE REINTTRANTEMP');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE REMAST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE REPORTLOG');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE REPORT_RSKMNGT_LOG');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE REREVDG');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE REREVLOG');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE RERFEE');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE RESALARY');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE RESEND_GTWRES');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE RESULT');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE RETAX');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE RETEMP');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE RETRAN');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE RETRANA');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE RETRIEVEDT0LOG');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE RETYPE');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE RETYPEMEMO');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE REUSERLNK');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE RE_CUSTOMERCHANGE_LOG');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE RIGHTASSIGN_LOG');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE RIGHTASSIGN_LOG_BK');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE RIGHTOFFEVENT');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE RIGHTOFFEVENTMEMO');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE RLSRPTLOG_EOD');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE RMLOG');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE ROOTORDERMAP');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE ROOTORDERMAPHIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE RPTAFMAST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE RPTGRPDTL');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE RPTGRPMST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE RPT_CHANGE_TERM_4_MARGIN');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE SALARY');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE SBBATCHSTS');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE SBCURRDATE');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE SBCURRDATE4NEW');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE SBFXRT');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE SBFXRTMNT');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE SBSECURITIESCV');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE SBSECURITIES_BK');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE SB_TEMP');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE SE2244_CATRFLOG');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE SE2244_LOG');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE SE2255_LOG');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE SEARCHLOG');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE SEBLOCKED');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE SECBASKETHIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE SECBASKETMEMO');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE SECBASKETTEMP');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE SECMAST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE SECMAST_GENERATE_LOG');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE SECNET');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE SECOSTPRICE');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE SECOSTPRICEDTL');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE SECURITIES_INFO_0206AM');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE SECURITIES_INFO_0206PM');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE SECURITIES_INFO_0306AM');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE SECURITIES_INFO_0306PM');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE SECURITIES_INFO_0406AM');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE SECURITIES_INFO_0406PM');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE SECURITIES_INFO_0506AM');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE SECURITIES_INFO_0506PM');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE SECURITIES_INFO_0710');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE SECURITIES_INFO_0806PM');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE SECURITIES_INFO_08_06');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE SECURITIES_INFO_0906AM');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE SECURITIES_INFO_0906PM');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE SECURITIES_INFO_1407AM');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE SECURITIES_INFO_1407PM');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE SECURITIES_INFO_140AM');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE SECURITIES_INFO_1507AM');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE SECURITIES_INFO_1507PM');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE SECURITIES_INFO_1607AM');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE SECURITIES_INFO_1607PM');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE SECURITIES_INFO_1707AM');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE SECURITIES_INFO_1707PM');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE SECURITIES_INFO_2007AM');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE SECURITIES_INFO_2007PM');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE SECURITIES_INFO_2107AM');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE SECURITIES_INFO_2107PM');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE SECURITIES_INFO_2207AM');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE SECURITIES_INFO_2207PM');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE SECURITIES_INFO_2307AM');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE SECURITIES_INFO_2307PM');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE SECURITIES_INFO_2407AM');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE SECURITIES_INFO_2407PM');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE SECURITIES_INFO_2707AM');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE SECURITIES_INFO_2707PM');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE SECURITIES_INFO_BSC');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE SECURITIES_INFO_ECC');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE SECURITIES_INFO_HIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE SECURITIES_INFO_IMPORT');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE SECURITIES_INFO_LOG');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE SECURITIES_MR_LOG');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE SECURITIES_RISKHIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE SECURITIES_RISKTEMP');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE SECURITIES_TICKSIZE_BK');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE SEDEPOBAL');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE SEDEPOBAL_HIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE SEDEPOFEELOG');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE SEDEPOSIT');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE SEDEPOWFTLOG');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE SELIMITGRP');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE SELIMITGRPMEMO');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE SELLSTOCKCALOG');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE SEMARGININFO');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE SEMARGINRATE');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE SEMAST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE SEMASTCV');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE SEMASTDTLHIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE SEMAST_PREVQTTY');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE SEMAST_TEMP_FLEX');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE SEMORTAGE');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE SEMORTAGEDTL');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE SENDMSGLOG');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE SENDSETOCLOSE');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE SENDTEMP');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE SENDUSER');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE SEODDLOT');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE SEOTCTRANLOG');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE SEPITALLOCATE');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE SEPITLOG');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE SERETAIL');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE SESENDOUT');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE SETRADEPLACE');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE SETRAN');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE SETRANA');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE SETRAN_GEN');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE SEVSD');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE SEWITHDRAWDTL');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE SE_TOTAL_FLEX');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE SHAUSERLOGIN');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE SIGNATURE');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE SIGNATURE_TEMP');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE SMSLOG');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE SMSLOGHIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE SMSMARGINCALL');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE SMSMARGINCALLHIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE SMSMARGINPROCESSED');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE SMSMATCHED');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE SMSMATCHEDHIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE SMSMOBILE');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE SMSSERVICETEMPLATES');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE SMSSERVICEUSER');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE SQLN_EXPLAIN_PLAN');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE SQLN_PROF_ANB');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE SQLN_PROF_PROFILES');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE SQLN_PROF_RUNS');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE SQLN_PROF_SESS');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE SQLN_PROF_UNITS');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE SQLN_PROF_UNIT_HASH');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE SS_PHATVAYMARGIN');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE SS_PHATVAYMARGIN_HIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE SS_PHATVAYT3');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE SS_PHATVAYT3_HIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE STCCANCELORDERBOOK');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE STCCANCELORDERBOOKBUFFER');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE STCCANCELORDERBOOKEXP');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE STCCANCELORDERBOOKEXPHIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE STCCANCELORDERBOOKHIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE STCCANCELORDERBOOKTEMP');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE STCORDERBOOK');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE STCORDERBOOKBUFFER');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE STCORDERBOOKEXP');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE STCORDERBOOKEXPHIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE STCORDERBOOKHIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE STCORDERBOOKTEMP');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE STCSE');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE STCTICKSIZE');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE STCTRADEALLOCATION');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE STCTRADEALLOCATIONHIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE STCTRADEBOOK');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE STCTRADEBOOKBUFFER');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE STCTRADEBOOKEXP');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE STCTRADEBOOKEXPHIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE STCTRADEBOOKHIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE STCTRADEBOOKTEMP');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE STDFMAP');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE STDFMAPHIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE STOCKINFOR');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE STOCKINFOR_HIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE STOCKS');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE STSCHD');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE STSCHDCV');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE STSCHDHIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE STS_MARKET_INFO');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE STS_ORDERS');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE STS_ORDERS_HNX');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE STS_ORDERS_HNX_0206');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE STS_ORDERS_HNX_0306');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE STS_ORDERS_HNX_0406');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE STS_ORDERS_HNX_0506');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE STS_ORDERS_HNX_0806');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE STS_ORDERS_HNX_0906');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE STS_ORDERS_HNX_1205');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE STS_ORDERS_HNX_1305');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE STS_ORDERS_HNX_1307');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE STS_ORDERS_HNX_1405');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE STS_ORDERS_HNX_1407');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE STS_ORDERS_HNX_1507');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE STS_ORDERS_HNX_1607');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE STS_ORDERS_HNX_1707');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE STS_ORDERS_HNX_1905');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE STS_ORDERS_HNX_2005');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE STS_ORDERS_HNX_2007');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE STS_ORDERS_HNX_2105');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE STS_ORDERS_HNX_2107');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE STS_ORDERS_HNX_2207');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE STS_ORDERS_HNX_2307');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE STS_ORDERS_HNX_2407');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE STS_ORDERS_HNX_2707');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE STS_ORDERS_UPCOM');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE STS_ORDERS_UPCOM_0206');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE STS_ORDERS_UPCOM_0306');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE STS_ORDERS_UPCOM_0406');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE STS_ORDERS_UPCOM_0506');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE STS_ORDERS_UPCOM_0806');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE STS_ORDERS_UPCOM_0906');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE STS_ORDERS_UPCOM_1205');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE STS_ORDERS_UPCOM_1305');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE STS_ORDERS_UPCOM_1307');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE STS_ORDERS_UPCOM_1405');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE STS_ORDERS_UPCOM_1407');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE STS_ORDERS_UPCOM_1507');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE STS_ORDERS_UPCOM_1607');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE STS_ORDERS_UPCOM_1707');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE STS_ORDERS_UPCOM_1905');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE STS_ORDERS_UPCOM_2005');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE STS_ORDERS_UPCOM_2007');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE STS_ORDERS_UPCOM_2105');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE STS_ORDERS_UPCOM_2107');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE STS_ORDERS_UPCOM_2207');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE STS_ORDERS_UPCOM_2307');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE STS_ORDERS_UPCOM_2407');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE STS_ORDERS_UPCOM_2707');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE STS_STOCKS_INFO');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE SUBACCMASTCV');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE SWAPODMASTLOG');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE SYNCODE');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE SYSVARMEMO');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE SYSVAR_CURRDATE');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE SYS_FLEX_TABLES');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE SYS_FLEX_TMPCMDSQL');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE SYS_IOT_OVER_1272594');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE SYS_IOT_OVER_1272603');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE T0AFLIMIT_IMPORT');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE T0LIMITSCHD');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE T0LIMITSCHDHIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE T0LIMIT_IMPORT');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE T3SETTLEMENT');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TABLEMONITOR');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TABLEMONITOR_LOG');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TABLE_COUNT');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TABLE_COUNT_FIX');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TABLINK');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TAXSI_TRANS');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TBLBOOKORDERVCBSHIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TBLCA3343');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TBLCAI039');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TBLCASHDEPOSIT');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TBLCASHDEPOSITHIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TBLCF0037');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TBLCFAF');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TBLCFAFHIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TBLCFSE');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TBLCFSEHIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TBLCHANGEAFTYPE');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TBLCHANGEAFTYPE_HIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TBLCHANGECAREBY');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TBLCHANGECAREBY_HIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TBLCHANGECFTYPE');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TBLCHANGECFTYPE_HIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TBLCI1101');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TBLCI1101HIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TBLCI1135');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TBLCI1137');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TBLCI1137HIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TBLCI1138');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TBLCI1138HIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TBLCI1141');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TBLCI1141HIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TBLCI1180');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TBLCI1187');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TBLCI1187HIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TBLGUAR');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TBLGUARHIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TBLQUYENMUA');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TBLRE0380');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TBLRE0380HIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TBLRE0384');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TBLSE2202');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TBLSE2203');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TBLSE2203HIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TBLSE2240');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TBLSE2240HIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TBLSE2244');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TBLSE2245');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TBLSE2245HIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TBLSE2287');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TBLSE2287HIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TBLSSTATEMENTVCBSHIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TBLSTATEMENTVCBSHIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TBLTEMP_GEN_JOB');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TBLTRFSTOCK');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TBLTRFSTOCKHIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TBL_2D');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TBL_CFOTHERACC');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TBL_CFOTHERACCHIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TBL_COUNTRY_TEMP');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TBL_GENMULTIPKG');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TBL_GL_MR0013');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TBL_GL_MR0013_NEW');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TBL_GL_MR0013_TEMP');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TBL_GL_MR2013_TEMP');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TBL_GL_OD0006');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TBL_GL_OD0067');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TBL_GL_SE0008');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TBL_MO');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TBL_MR0057');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TBL_MR0058');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TBL_MR0059');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TBL_MR0060');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TBL_MR0063');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TBL_MR3007_LOG');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TBL_ODREPO');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TBL_POSTMAP');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TBL_PROVINCE_TEMP');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TBL_STRADE_SUBACCOUNT_CI');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TBL_TXPKS');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TBL_VMR0001');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TCDTCRBTXREQLOG');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TCDTCRBTXREQLOGHIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TCDTMESSAGELOG');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TDLINK');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TDLINKHIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TDMAST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TDMASTHIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TDMSTSCHM');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TDMSTSCHMHIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TDTRAN');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TDTRANA');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TDTYPSCHMHIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TEMP');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TEMPAF');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TEMPLATES_BACKUP');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TEMPLATES_BACKUP23');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TEMPLATES_SCHEDULER');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TEMPLATES_SCHEDULER_LOG');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TEMPLATES_STATUS');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TEMP_CF2000');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TEMP_MAIL');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TEST_MAIL');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TLAUTH_BK_1805');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TLGROUPCV');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TLGROUPPROFILECV');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TLGROUPSMAPCAREBY');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TLGRPUSERS_TEMP');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TLIDTYPE');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TLLOG');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TLLOG4DR');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TLLOG4DRALL');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TLLOGALL');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TLLOGDEL');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TLLOGDESC');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TLLOGEXT');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TLLOGEXTHIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TLLOGFLD');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TLLOGFLD4DR');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TLLOGFLD4DRALL');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TLLOGFLDALL');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TLLOGFLDDEL');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TLPROFILESCV');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TLTXEXTBR');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TMPSEMASTVSD');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TMPTOTALSEVSD');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TRADECAREBY');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TRADEPLACE');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TRADEPLACEMEMO');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TRADINGCODE_TEMP');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TRADINGRESULTEXP');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TRADING_RESULT');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TRADING_RESULT_HIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TRADING_TRANS');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TRANSLOG');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TRFDTOCLOSE');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TRFGL');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TR_BOOKITEM');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TR_BOOKITEM_PZT');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TR_BOOKITEM_PZT_THUEPHI');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TR_BOOKITEM_TLJ');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TR_BOOKITEM_TLJ_TOTAL');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TUNING_LOG');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TX1195_UPLOAD');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TX1195_UPLOADDTL');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TX1195_UPLOADDTLHIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TXAQS_FLEX2FO_QUEUE');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TXAQS_FLEX2VSD_TABLE');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TXAUTO');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TXDEFDESC');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TXDESC');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TXMAPDESC');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TXMAPGLRULESMEMO');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TYPELINE');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TYPELINELOG');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE T_SEOD');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE UNREAFLNK');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE UNREAFLNKMEMO');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE UPCOMPTCANCELLED');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE UPCOMPTCANCELLED_HIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE UPCOMSECURITY_REQ');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE UPCOMSECURITY_REQ_HIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE UPCOMSTATUSREQ');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE UPCOMSTATUSREQ_HIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE UPCOM_7');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE UPCOM_7_HIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE UPCOM_D');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE UPCOM_D_HIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE UPCOM_F');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE UPCOM_F_HIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE UPCOM_G');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE UPCOM_G_HIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE UPCOM_S');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE UPCOM_S_HIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE UPCOM_T');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE UPCOM_T_HIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE UPCOM_U');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE UPCOM_U_HIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE USERAFLIMIT');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE USERAFLIMITLOG');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE USERLIMIT');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE USERLIMITLOG');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE USERLOGIN');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE USERLOGINCV');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE USERLOGINMEMO');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE USERLOGIN_CHANGE');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE USERMKTWATCH');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE VATTRAN');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE VATTRANA');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE VCBSEQMAP');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE VOUCHERLOG');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE VOUCHERLOGHIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE VOUCHERODFEE');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE VSDMSGFROMFLEX');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE VSDMSGLOG');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE VSDMSGLOGHIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE VSDTRFLOG');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE VSDTRFLOGDTL');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE VSDTRFLOGDTLHIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE VSDTRFLOGHIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE VSDTXREQ');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE VSDTXREQDTL');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE VSDTXREQDTLHIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE VSDTXREQHIST');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE VSD_MT598_INF');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE VSD_PROCESS_LOG');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE VSD_SE');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE WATCHLIST');


    InsertConvertLog('I','Complete truncate table !') ;

Exception
    when others then
      plog.error(pkgctx, sqlerrm);
      InsertConvertLog('E',sqlerrm) ;
 End;

Procedure ResetSeq
IS
Begin

    InsertConvertLog('I','Begin reset sequence....');
    -- drop cac sequence

    for rec in (SELECT   object_name
    from user_objects where object_type='SEQUENCE' AND object_name NOT IN ('SEQ_CRBHOLDLIST') )
    loop
        RESET_SEQUENCE(SEQ_NAME => rec.object_name, STARTVALUE => 1);
    end loop;

    InsertConvertLog('I','Complete reset sequence !') ;

Exception
    when others then
      plog.error(pkgctx, sqlerrm);
      InsertConvertLog('E',sqlerrm) ;
End;

PROCEDURE CFMASTCV
IS
    v_currdate date;
    v_prevdate date;
    v_nextdate date;
    err varchar2(100);
BEGIN

    EXECUTE IMMEDIATE('TRUNCATE TABLE AFMAST DROP STORAGE');
    EXECUTE IMMEDIATE('TRUNCATE TABLE CIMAST DROP STORAGE');
    EXECUTE IMMEDIATE('TRUNCATE TABLE CFMAST DROP STORAGE');
    EXECUTE IMMEDIATE('TRUNCATE TABLE USERAFLIMIT DROP STORAGE');


    InsertConvertLog('I','Begin CFMAST');

    select to_date(varvalue,'DD/MM/RRRR') into v_currdate from sysvar where grname ='SYSTEM' and varname ='CURRDATE';
    select to_date(varvalue,'DD/MM/RRRR') into v_prevdate from sysvar where grname ='SYSTEM' and varname ='PREVDATE';
    select to_date(varvalue,'DD/MM/RRRR') into v_nextdate from sysvar where grname ='SYSTEM' and varname ='NEXTDATE';


    -- Khach hang
    INSERT INTO cfmast (custid, shortname, fullname, mnemonic, dateofbirth,
       idtype, idcode, iddate, idplace, idexpired, address,
       phone, mobile, fax, email, country, province,
       postcode, resident, class, grinvestor, investrange,
       timetojoin, custodycd, staff, companyid, position,
       sex, sector, businesstype, investtype, experiencetype,
       incomerange, assetrange, focustype, brid, careby,
       approveid, lastdate, auditorid, auditdate, language,
       bankacctno, bankcode, valudadded, issuerid,
       description, married, taxcode, internation, occupation,
       education, custtype, status, pstatus,
       investmentexperience, pcustodycd, experiencecd, orginf,
       tlid, isbanking, pin, username, mrloanlimit,
       risklevel, tradingcode, tradingcodedt, last_change,
       opndate, cfclsdate, marginallow, custatcom,
       t0loanlimit, dmsts, activedate, afstatus, mobilesms,
       openvia, olautoid, vat, refname, tradefloor,
       tradetelephone, tradeonline, commrate, consultant,
       activests, last_mkid, last_ofid, onlinelimit,
       ischkonlimit, managetype, actype, isuseoadvres,
       workplace, vcbs_oldcode, callsts, whtax, nsdstatus)
    SELECT cf.custid, cf.shortname, cf.fullname, fn_CutOffUTF8(upper(cf.fullname)) mnemonic, cf.dateofbirth,
       cf.idtype, cf.idcode, cf.iddate, cf.idplace, cf.idexpired, cf.address,
       cf.phone, cf.mobile, cf.fax, cf.email, cf.country, cf.province,
       cf.postcode, cf.resident, cf.class, cf.grinvestor, cf.investrange,
       cf.timetojoin, cf.custodycd, cf.staff, cf.companyid, cf.position,
       cf.sex, cf.sector, cf.businesstype, cf.investtype, cf.experiencetype,
       cf.incomerange, cf.assetrange, cf.focustype, cf.brid, cf.careby,
       cf.approveid, cf.lastdate, cf.auditorid, cf.auditdate, cf.language,
       cf.bankacctno, cf.bankcode, cf.valudadded, cf.issuerid,
       cf.description, cf.married, cf.taxcode, cf.internation, cf.occupation,
       cf.education, trim(cf.custtype), cf.status, cf.pstatus,
       cf.investmentexperience, cf.pcustodycd, cf.experiencecd, cf.orginf,
       cf.tlid, cf.isbanking, cf.pin, cf.username, cf.mrloanlimit,
       cf.risklevel, cf.tradingcode, cf.tradingcodedt, cf.last_change,
       cf.opndate, clsdate cfclsdate, cf.marginallow, DECODE(SUBSTR(cf.custodycd,1,3),'086','Y', 'N') custatcom,
       1000000000 t0loanlimit,
       'N' dmsts,
       cf.opndate activedate, 'N' afstatus, NVL(CF.MOBILE, CF.PHONE) mobilesms,
       'F' openvia, '' olautoid,
       DECODE(CF.custtype, 'I', 'Y','N') vat,
       '' refname, 'Y' tradefloor,
       'Y' tradetelephone, 'Y' tradeonline, 100 commrate, 'Y' consultant,
       DECODE(CF.STATUS,'A','Y','N') activests, cf.tlid last_mkid, cf.tlid last_ofid, '0' onlinelimit,
       'Y' ischkonlimit, 'A' managetype,
       (case when cf.custodycd like '086P%' then pks_covert_to_flex.C_CONST_CFTYPE_P
                            Else case when trim(cf.CUSTTYPE) <> 'I' then pks_covert_to_flex.C_CONST_CFTYPE_C_B
                                 Else pks_covert_to_flex.C_CONST_CFTYPE_C_I end
                            End) actype,
       'N' isuseoadvres,
       '' workplace, '' vcbs_oldcode, 'N' callsts, 'N' whtax, 'C' nsdstatus
    FROM cfmast cf;

    -- Xy ly dac biet cho nhom no xau Quang --0007    NO XAU QUANG
    Update cfmast set actype ='0007' where custodycd in ('086C893389','086C895589','086C688889','086C894668');
    -- Xy ly dac biet cho nhom C47 0008    KH_C47_VIP1
    Update cfmast set actype ='0008' where custodycd in ('086C892165');

    Update cfmast cf
       set careby ='0001',
           tlid ='0001',
           last_ofid ='0001',
           brid ='0001',
           cf.approveid='0001',
           whtax = 'N', -- Thue nha thau
           vat = DECODE(trim(CUSTTYPE), 'I', 'Y','N'), -- Thue nha thau
           cf.SEX = case when trim(SEX) not in ('001','002') then '000' else SEX end,
           cf.CUSTTYPE = trim(CUSTTYPE),
           cf.actype = (case when cf.custodycd like '086P%' then pks_covert_to_flex.C_CONST_CFTYPE_P
                            Else case when trim(cf.CUSTTYPE) <> 'I' then pks_covert_to_flex.C_CONST_CFTYPE_C_B
                                 Else pks_covert_to_flex.C_CONST_CFTYPE_C_I end
                            End);

    Update cfmast set IDTYPE ='010' where IDTYPE ='004';

    InsertConvertLog('I','End CFMAST');
    Commit;

    -- Tieu khoan thuong
    INSERT into afmast(actype, custid, acctno, aftype, bankacctno, bankname,
       swiftcode, lastdate, status, pstatus, advanceline,
       depositline, bratio, termofuse, description, isotc,
       pisotc, opndate, corebank, via, mrirate, mrmrate,
       mrlrate, mrcrlimit, mrcrlimitmax, groupleader, t0amt,
       brid, last_change, clsdate, careby, autoadv, tlid,
       mriratio, mrmratio, mrlratio, depolastdt, brkfeetype,
       triggerdate, alternateacct, callday, limitdaily,
       isfixaccount, autotrf, chgactype, mrcrate, mrwrate,
       k1days, k2days, mrexrate, producttype, iscieod, ispm,
       isdebtt0, tradeline, tradebl, chstatus, clamtlimit)
    SELECT pks_covert_to_flex.C_CONST_AFTYPE_NN actype, af.custid, af.acctno, af.aftype, af.bankacctno, af.bankname,
       af.swiftcode, af.lastdate, af.status, 'P' pstatus, af.advanceline,
       af.depositline, af.bratio, af.termofuse, af.description, af.isotc,
       af.pisotc, af.opndate, af.corebank, af.via, af.mrirate, af.mrmrate,
       af.mrlrate, af.mrcrlimit, af.mrcrlimitmax, af.groupleader, af.t0amt,
       af.brid, af.last_change, af.clsdate, af.careby, af.autoadv, af.tlid,
       af.mriratio, af.mrmratio, af.mrlratio, NULL depolastdt, 'CF' brkfeetype,
       NULL triggerdate, 'N' alternateacct, 0 callday, 0 limitdaily,
       'N' isfixaccount, 'N' autotrf, 'N' chgactype, 0 mrcrate, 0 mrwrate,
       0 k1days, 0 k2days, 0 mrexrate, 'NN' producttype, 'N' iscieod, 'N' ispm,
       'N' isdebtt0, '' tradeline, 'N' tradebl, '' chstatus, 0 clamtlimit
    FROM cfmast cf, host.afmast af, host.aftype aft, host.mrtype mrt
    where cf.custid = af.custid
          and af.actype = aft.actype
          and aft.mrtype = mrt.actype
          and mrt.mrtype <> 'T';

    InsertConvertLog('I','End Afmast Thuong');
    COMMIT;

    -- Tieu khoan Margin
    INSERT into afmast(actype, custid, acctno, aftype, bankacctno, bankname,
       swiftcode, lastdate, status, pstatus, advanceline,
       depositline, bratio, termofuse, description, isotc,
       pisotc, opndate, corebank, via, mrirate, mrmrate,
       mrlrate, mrcrlimit, mrcrlimitmax, groupleader, t0amt,
       brid, last_change, clsdate, careby, autoadv, tlid,
       mriratio, mrmratio, mrlratio, depolastdt, brkfeetype,
       triggerdate, alternateacct, callday, limitdaily,
       isfixaccount, autotrf, chgactype, mrcrate, mrwrate,
       k1days, k2days, mrexrate, producttype, iscieod, ispm,
       isdebtt0, tradeline, tradebl, chstatus, clamtlimit)
    SELECT pks_covert_to_flex.C_CONST_AFTYPE_NM actype, af.custid, af.acctno, af.aftype, af.bankacctno, af.bankname,
       af.swiftcode, af.lastdate, af.status, 'P'  pstatus, af.advanceline,
       af.depositline, af.bratio, af.termofuse, af.description, af.isotc,
       af.pisotc, af.opndate, af.corebank, af.via, af.mrirate, af.mrmrate,
       af.mrlrate, af.mrcrlimit, af.mrcrlimitmax, af.groupleader, af.t0amt,
       af.brid, af.last_change, af.clsdate, af.careby, af.autoadv, af.tlid,
       af.mriratio, af.mrmratio, af.mrlratio, NULL depolastdt, 'CF' brkfeetype,
       NULL triggerdate, 'N' alternateacct, 0 callday, 0 limitdaily,
       'N' isfixaccount, 'N' autotrf, 'N' chgactype, 80 mrcrate, 80 mrwrate,
       2 k1days, 2 k2days, 20 mrexrate, 'NM' producttype, 'N' iscieod, 'N' ispm,
       'N' isdebtt0, '' tradeline, 'N' tradebl, '' chstatus, 0 clamtlimit
    FROM cfmast cf, host.afmast af, host.aftype aft, host.mrtype mrt
    where cf.custid = af.custid and af.actype = aft.actype and aft.mrtype = mrt.actype
          and mrt.mrtype = 'T';

    InsertConvertLog('I','End Afmast Margin');
    Update afmast set brid = nvl(brid,'0001') where brid is null;
    -- 0006    NX QUANG
    Update afmast
        set actype = '0006'
        where acctno in ('0001987777','0101688889','0001893389','0001894668','0001895589');
    -- 0007    KH_C47
    Update afmast
        set actype = '0004', producttype='NN'
        where acctno in ('0001000029');

    Update afmast
        set actype = '0007', producttype='NM', autoadv='Y'
        where acctno in ('0001892165');

    Commit;

    INSERT into cimast(actype, acctno, ccycd, afacctno, custid, opndate,
       clsdate, lastdate, dormdate, status, pstatus,
       balance, cramt, dramt, crintacr, crintdt, odintacr,
       odintdt, avrbal, mdebit, mcredit, aamt, ramt, bamt,
       emkamt, mmarginbal, marginbal, iccfcd, iccftied,
       odlimit, adintacr, adintdt, facrtrade, facrdepository,
       facrmisc, minbal, odamt, namt, floatamt, holdbalance,
       pendinghold, pendingunhold, corebank, receiving,
       netting, mblock, ovamt, dueamt, t0odamt, mbalance,
       mcrintdt, trfamt, last_change, dfodamt, dfdebtamt,
       dfintdebtamt, cidepofeeacr, trfbuyamt, intfloatamt,
       feefloatamt, depolastdt, depofeeamt, holdmnlamt,
       t0ovdamt, bankbalance, bankavlbal, bankinqirydt,
       intbuyamt, intcaamt, buysecamt)
    SELECT aft.citype, ci.acctno, ci.ccycd, ci.afacctno, ci.custid, ci.opndate,
       ci.clsdate, ci.lastdate, ci.dormdate, ci.status, 'P' pstatus,
       ci.balance, 0 cramt, 0 dramt, ci.crintacr, ci.crintdt, ci.odintacr,
       ci.odintdt, 0 avrbal, 0 mdebit, 0 mcredit, 0 aamt, 0 ramt, 0 bamt,
       ci.emkamt, 0 mmarginbal, 0 marginbal, ci.iccfcd, ci.iccftied,
       0 odlimit, 0 adintacr, ci.adintdt, ci.facrtrade, ci.facrdepository,
       ci.facrmisc, 0 minbal,  0 odamt, 0 namt, 0 floatamt, 0 holdbalance,
       0 pendinghold, 0 pendingunhold, ci.corebank, 0 receiving,
       ci.netting, 0 mblock, 0 ovamt, 0 dueamt, 0 t0odamt, 0 mbalance,
       ci.mcrintdt, ci.trfamt, ci.last_change, 0 dfodamt, 0 dfdebtamt,
       0  dfintdebtamt, 0 cidepofeeacr, 0 trfbuyamt, 0 intfloatamt,
       0 feefloatamt, null depolastdt, 0 depofeeamt, 0 holdmnlamt,
       0 t0ovdamt, 0 bankbalance, 0 bankavlbal, NULL bankinqirydt,
       0 intbuyamt, 0 intcaamt, 0 buysecamt
    FROM host.cimast ci, afmast af, aftype aft
    where ci.afacctno = af.acctno and af.actype = aft.actype;

    InsertConvertLog('I','End cimast');
    INSERT into useraflimit(acctno, acclimit,  tliduser, typeallocate, typereceive)
    SELECT a.acctno, a.acclimit, pks_covert_to_flex.C_CONST_USERCV tliduser, 'Flex' typeallocate, a.typereceive
    FROM host.useraflimit a, afmast af
    where a.acctno = af.acctno and af.producttype='NM' and a.acclimit <> 0;

    InsertConvertLog('I','End useraflimit ....');
    COMMIT;

    EXECUTE IMMEDIATE('ANALYZE TABLE CFMAST COMPUTE STATISTICS');
    EXECUTE IMMEDIATE('ANALYZE TABLE AFMAST COMPUTE STATISTICS');
    EXECUTE IMMEDIATE('ANALYZE TABLE CIMAST COMPUTE STATISTICS');
    EXECUTE IMMEDIATE('ANALYZE TABLE USERAFLIMIT COMPUTE STATISTICS');


    Update afmast set careby ='0001';
    UPDATE CFMAST SET MANAGETYPE ='N' WHERE CUSTATCOM='N';
    UPDATE CIMAST
        SET DEPOLASTDT = pks_covert_to_flex.C_CONST_DEPOLASTDT;

    UPDATE afmast SET autoadv ='Y'  WHERE  producttype ='NM';
    Commit;

    InsertConvertLog('I','Begin fn_ApplyTypeToMast CFMASTCV....');
    if cspks_cfproc.fn_ApplyTypeToMast (err) then
        err:='';
    end if;

    InsertConvertLog('I','End fn_ApplyTypeToMast CFMASTCV....');
    COMMIT;

    InsertConvertLog('I','End convert cfmast....');

EXCEPTION
    WHEN OTHERS THEN
        InsertConvertLog('E',' CFMASTCV.'
                               ||sqlerrm || '.At:' || dbms_utility.format_error_backtrace);
END;

PROCEDURE cimastcv  IS
v_currdate date;
v_prevdate date;
v_nextdate date;
v_t_1_date date;
v_t_2_date date;
v_t_3_date date;
v_max_autoid number;
BEGIN

    InsertConvertLog('I','Begin cimastcv');
    EXECUTE IMMEDIATE('TRUNCATE TABLE citran DROP STORAGE');
    EXECUTE IMMEDIATE('TRUNCATE TABLE citrana DROP STORAGE');
    EXECUTE IMMEDIATE('TRUNCATE TABLE citran_gen DROP STORAGE');
    EXECUTE IMMEDIATE('TRUNCATE TABLE ciinttran DROP STORAGE');
    EXECUTE IMMEDIATE('TRUNCATE TABLE ciinttrana DROP STORAGE');

    select to_date(varvalue,'DD/MM/RRRR') into v_currdate from sysvar where grname ='SYSTEM' and varname ='CURRDATE';
    select to_date(varvalue,'DD/MM/RRRR') into v_prevdate from sysvar where grname ='SYSTEM' and varname ='PREVDATE';
    select to_date(varvalue,'DD/MM/RRRR') into v_nextdate from sysvar where grname ='SYSTEM' and varname ='NEXTDATE';
    v_t_1_date:=get_t_date(v_currdate,1);
    v_t_2_date:=get_t_date(v_currdate,2);
    v_t_3_date:=get_t_date(v_currdate,3);

    -- Tien cho ve
    Update cimast set RECEIVING=0;
    Begin
        For rec in (
            SELECT AFACCTNO, SUM(AMT) RECEIVING
            FROM STSCHD
            WHERE DUETYPE='RM'
                  and v_currdate <= cleardate and txdate <> v_currdate
            GROUP BY  AFACCTNO
        )Loop
            Update cimast set RECEIVING = rec.RECEIVING where afacctno = rec.AFACCTNO;
        End Loop;
    End;

    /*-- Tien cho giao
    Begin
        For rec in (
            SELECT AFACCTNO, SUM(AMT) NETTING
            FROM STSCHD WHERE DUETYPE='SM' and v_currdate <= cleardate and txdate <> v_currdate
            GROUP BY  AFACCTNO
        )Loop
            Update cimast set NETTING = rec.NETTING where afacctno = rec.AFACCTNO;
        End Loop;
    End;
    COMMIT;*/


    InsertConvertLog('I','Begin citran');
    INSERT into citran(txnum, txdate, acctno, txcd, namt, camt, ref,
       deltd, acctref, autoid, tltxcd, bkdate, trdesc, corebank)
    SELECT a.txnum, a.txdate, a.acctno, a.txcd, a.namt, a.camt, a.ref,
       a.deltd, a.acctref, a.autoid, a.tltxcd, a.bkdate, a.trdesc, 'N' corebank
    FROM host.citran a where a.namt <> 0 and a.deltd <> 'Y';

    InsertConvertLog('I','Begin citrana');
    INSERT into citrana(txnum, txdate, acctno, txcd, namt, camt, ref,
       deltd, acctref, autoid, tltxcd, bkdate, trdesc, corebank)
    SELECT a.txnum, a.txdate, a.acctno, a.txcd, a.namt, a.camt, a.ref,
       a.deltd, a.acctref, a.autoid, a.tltxcd, a.bkdate, a.trdesc, 'N' corebank
    FROM host.citrana a where a.namt <> 0 and a.deltd <> 'Y';

    InsertConvertLog('I','Begin citran_gen');
    INSERT INTO citran_gen(autoid, custodycd, custid, txnum, txdate, acctno,
       txcd, namt, camt, ref, deltd, acctref, tltxcd,
       busdate, txdesc, txtime, brid, tlid, offid, chid,
       dfacctno, old_dfacctno, txtype, field, tllog_autoid,
       trdesc, corebank)
    SELECT a.autoid, a.custodycd, a.custid, a.txnum, a.txdate, a.acctno,
       a.txcd, a.namt, a.camt, a.ref, a.deltd, a.acctref, a.tltxcd,
       a.busdate, a.txdesc, a.txtime, a.brid, a.tlid, a.offid, a.chid,
       a.dfacctno, a.old_dfacctno, a.txtype, a.field, a.tllog_autoid,
       a.trdesc, 'N' corebank
    FROM host.citran_gen a where a.namt <> 0 and a.deltd <> 'Y';

    InsertConvertLog('I','End citran_gen');

    SELECT max(autoid) + 1 into v_max_autoid from vw_citran_all;
    RESET_SEQUENCE(SEQ_NAME => 'seq_citran', STARTVALUE => v_max_autoid);

    InsertConvertLog('I','Begin ciinttran');
    INSERT into ciinttran(autoid, acctno, inttype, frdate, todate, icrule,
       irrate, intbal, intamt, balance, emkamt, intbuyamt, intcaamt)
    SELECT a.autoid, a.acctno, a.inttype, a.frdate, a.todate, a.icrule,
       a.irrate, a.intbal, a.intamt, a.intbal balance, 0 emkamt, 0 intbuyamt, 0 intcaamt
    FROM host.ciinttran a where a.intamt <> 0;

    InsertConvertLog('I','Begin ciinttrana');
    INSERT into ciinttrana(autoid, acctno, inttype, frdate, todate, icrule,
       irrate, intbal, intamt, balance, emkamt, intbuyamt, intcaamt)
    SELECT a.autoid, a.acctno, a.inttype, a.frdate, a.todate, a.icrule,
       a.irrate, a.intbal, a.intamt, a.intbal balance, 0 emkamt, 0 intbuyamt, 0 intcaamt
    FROM host.ciinttrana a where a.intamt <> 0;

    SELECT max(autoid) + 1 into v_max_autoid
    from (
            select * from  ciinttran
            UNION all
            select * from  ciinttrana
          );
    RESET_SEQUENCE(SEQ_NAME => 'seq_ciinttran', STARTVALUE => v_max_autoid);

    EXECUTE IMMEDIATE('ANALYZE TABLE CITRAN COMPUTE STATISTICS');
    EXECUTE IMMEDIATE('ANALYZE TABLE CITRANA COMPUTE STATISTICS');
    EXECUTE IMMEDIATE('ANALYZE TABLE CITRAN_GEN COMPUTE STATISTICS');
    EXECUTE IMMEDIATE('ANALYZE TABLE CIINTTRAN COMPUTE STATISTICS');
    EXECUTE IMMEDIATE('ANALYZE TABLE CIINTTRANA COMPUTE STATISTICS');

    InsertConvertLog('I','End cimast');

EXCEPTION
WHEN OTHERS THEN
     InsertConvertLog('E','cimastcv, '
                               ||sqlerrm || '.At:' || dbms_utility.format_error_backtrace);

END;

PROCEDURE cfotheracccv  IS
v_currdate date;
v_prevdate date;
v_nextdate date;
v_t_1_date date;
v_t_2_date date;
v_t_3_date date;
v_linkauth VARCHAR2(20);
BEGIN
    InsertConvertLog('I','BEGIN CFOTHERACC');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CFOTHERACC' );
    RESET_SEQUENCE(SEQ_NAME => 'seq_cfotheracc', STARTVALUE => 1);

    INSERT INTO CFOTHERACC(AUTOID, CFCUSTID, CIACCOUNT, CINAME, CUSTID, BANKACC,
           BANKACNAME, BANKNAME, TYPE, ACNIDCODE, ACNIDDATE,
           ACNIDPLACE, FEECD, CITYEF, CITYBANK, BANKCODE, CHSTATUS)
    SELECT seq_cfotheracc.nextval,  MST.CFCUSTID, MST.CIACCOUNT, MST.CINAME, MST.CUSTID, MST.BANKACC,
           MST.BANKACNAME, MST.BANKNAME, MST.TYPE, MST.ACNIDCODE, MST.ACNIDDATE,
           MST.ACNIDPLACE, MST.FEECD, MST.CITYEF, MST.CITYBANK, MST.BANKCODE, MST.CHSTATUS
    FROM
    (
        SELECT MAX(AUTOID)AUTOID,  AF.CUSTID CFCUSTID, CFO.CIACCOUNT, CFO.CINAME, CFO.CUSTID, CFO.BANKACC,
               MAX(CFO.BANKACNAME) BANKACNAME, MAX(CFO.BANKNAME) BANKNAME, CFO.TYPE, CFO.ACNIDCODE, CFO.ACNIDDATE,
               CFO.ACNIDPLACE, FEECD, '' CITYEF, '' CITYBANK, '' BANKCODE, null CHSTATUS
        FROM host.CFOTHERACC CFO, host.AFMAST AF
        WHERE CFO.AFACCTNO = AF.ACCTNO AND type=1
        GROUP BY AF.CUSTID, CFO.CIACCOUNT, CFO.CINAME, CFO.CUSTID, CFO.BANKACC,
               CFO.TYPE, CFO.ACNIDCODE, CFO.ACNIDDATE, CFO.ACNIDPLACE, CFO.FEECD
    )MST;

    UPdate CFOTHERACC set FEECD = '0005' where nvl(feecd,'') not in ('00042','00043','0019', '0020', '0041', '0044');
    UPdate CFOTHERACC set FEECD = '0003' where nvl(feecd,'') in ('00042','00043');
    UPdate CFOTHERACC set FEECD = '0005' where nvl(feecd,'') in ('0019', '0020', '0041', '0044');

    EXECUTE IMMEDIATE('ANALYZE TABLE CFOTHERACC COMPUTE STATISTICS');
    InsertConvertLog('I','END CFOTHERACC');

EXCEPTION
    WHEN OTHERS THEN
        InsertConvertLog('E','cfotheracccv, '
                               ||sqlerrm || '.At:' || dbms_utility.format_error_backtrace);
END;

PROCEDURE cfauthcv  IS
    v_max_autoid number(20);
BEGIN

    InsertConvertLog('I','Begin cfauth');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE CFAUTH' );
    RESET_SEQUENCE(SEQ_NAME => 'seq_cfauth', STARTVALUE => 1);

    --BMSC chot ko convert UQ --> Comment lai
    /*
    INSERT INTO cfauth(autoid, cfcustid, custid, fullname, address,
           telephone, licenseno, valdate, expdate, deltd,
           linkauth, signature, accountname, bankaccount,
           bankname, lnplace, lniddate, chstatus)
    SELECT cfu.autoid, AF.custid cfcustid, cfu.custid, cfu.fullname, cfu.address,
           cfu.telephone, cfu.licenseno, cfu.valdate, cfu.expdate, cfu.deltd,
           fn_convert_linkauth(cfu.linkauth) linkauth, TO_CLOB(cfu.signature), cfu.accountname, cfu.bankaccount,
           cfu.bankname, cfu.lnplace, cfu.lniddate, 'C' chstatus
    from host.cfauth cfu, host.afmast af
    where cfu.acctno = af.acctno and expdate >= getcurrdate;

    Update cfauth set autoid = seq_cfauth.nextval;
    EXECUTE IMMEDIATE('ANALYZE TABLE cfauth COMPUTE STATISTICS');
    */
    InsertConvertLog('I','End cfauth');
    Commit;

EXCEPTION
    WHEN OTHERS THEN
        InsertConvertLog('E','cfauthcv, '
                               ||sqlerrm || '.At:' || dbms_utility.format_error_backtrace);
END;

PROCEDURE tllogcv  IS
    v_max_autoid number(20);
BEGIN

    InsertConvertLog('I','Begin tllog');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TLLOG' );
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE TLLOGALL' );

    InsertConvertLog('I','Begin tllog');
    insert into tllog(autoid, txnum, txdate, txtime, brid, tlid, offid,
       ovrrqs, chid, chkid, tltxcd, ibt, brid2, tlid2,
       ccyusage, off_line, deltd, brdate, busdate, txdesc,
       ipaddress, wsname, txstatus, msgsts, ovrsts,
       batchname, msgamt, msgacct, chktime, offtime,
       carebygrp, reftxnum, namenv, cfcustodycd, createdt,
       cffullname, ptxstatus)
    SELECT a.autoid, a.txnum, a.txdate, a.txtime, a.brid, a.tlid, a.offid,
           a.ovrrqs, a.chid, a.chkid, a.tltxcd, a.ibt, a.brid2, a.tlid2,
           a.ccyusage, a.off_line, a.deltd, a.brdate, a.busdate, a.txdesc,
           a.ipaddress, a.wsname, a.txstatus, a.msgsts, a.ovrsts,
           a.batchname, a.msgamt, a.msgacct, a.chktime, a.offtime,
           a.carebygrp, '' reftxnum, '' namenv, '' cfcustodycd, txdate createdt,
           '' cffullname, '' ptxstatus
      FROM host.tllog a
      where EXISTS (
          select * from
            (
                select txnum, txdate from citran
                UNION all
                select txnum, txdate from setran
                UNION all
                select txnum, txdate from lntran
            ) tr
       where tr.txnum = a.txnum and tr.txdate = a.txdate);

    insert into tllogall(autoid, txnum, txdate, txtime, brid, tlid, offid,
       ovrrqs, chid, chkid, tltxcd, ibt, brid2, tlid2,
       ccyusage, off_line, deltd, brdate, busdate, txdesc,
       ipaddress, wsname, txstatus, msgsts, ovrsts,
       batchname, msgamt, msgacct, chktime, offtime,
       carebygrp, reftxnum, namenv, cfcustodycd, createdt,
       cffullname, ptxstatus)
    SELECT a.autoid, a.txnum, a.txdate, a.txtime, a.brid, a.tlid, a.offid,
           a.ovrrqs, a.chid, a.chkid, a.tltxcd, a.ibt, a.brid2, a.tlid2,
           a.ccyusage, a.off_line, a.deltd, a.brdate, a.busdate, a.txdesc,
           a.ipaddress, a.wsname, a.txstatus, a.msgsts, a.ovrsts,
           a.batchname, a.msgamt, a.msgacct, a.chktime, a.offtime,
           a.carebygrp, '' reftxnum, '' namenv, '' cfcustodycd, txdate createdt,
           '' cffullname, '' ptxstatus
    FROM host.tllogall a
      where EXISTS (
          select * from
            (
                select txnum, txdate from citrana
                UNION all
                select txnum, txdate from setrana
                UNION all
                select txnum, txdate from lntrana
            ) tr
    where tr.txnum = a.txnum and tr.txdate = a.txdate);

    select max(autoid) + 1 into v_max_autoid from vw_tllog_all;
    RESET_SEQUENCE(SEQ_NAME => 'seq_tllog', STARTVALUE => v_max_autoid);

    EXECUTE IMMEDIATE('ANALYZE TABLE TLLOG COMPUTE STATISTICS');
    EXECUTE IMMEDIATE('ANALYZE TABLE TLLOGALL COMPUTE STATISTICS');

    InsertConvertLog('I','End tllog');

EXCEPTION
    WHEN OTHERS THEN
         InsertConvertLog('E','tllogcv, '
                       ||sqlerrm || '.At:' || dbms_utility.format_error_backtrace);

END;

PROCEDURE semastcv
IS
    v_currdate date;
    v_prevdate date;
    v_nextdate date;
    v_t_1_date date;
    v_t_2_date date;
    v_t_3_date date;
    v_max_autoid number(20);
    V_TXNUM VARCHAR2(20);
BEGIN
    v_currdate := getcurrdate;
    v_prevdate := getprevdate(getcurrdate,1);
    InsertConvertLog('I','Begin semast');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE semast' );
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE seblocked' );
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE semortage' );
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE setran' );
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE setrana' );
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE setran_gen' );

    INSERT into semast(actype, acctno, codeid, afacctno, opndate, clsdate,
       lastdate, status, pstatus, irtied, ircd, costprice,
       trade, mortage, margin, netting, standing, withdraw,
       deposit, loan, blocked, receiving, transfer,
       prevqtty, dcrqtty, dcramt, depofeeacr, repo, pending,
       tbaldepo, custid, costdt, secured, iccfcd, iccftied,
       tbaldt, senddeposit, sendpending, ddroutqtty,
       ddroutamt, dtoclose, sdtoclose, qtty_transfer,
       last_change, dealintpaid, wtrade, grpordamt, emkqtty,
       blockwithdraw, blockdtoclose, roomchk, roomlimit,
       costprice_adj_date, shareholdersid, oldshareholdersid, oldcodeid, oldacctno)
    SELECT '0000' actype,
       se.afacctno || sb_new.codeid acctno,--se.acctno,
       sb_new.codeid, -- se.codeid,
       se.afacctno, se.opndate, se.clsdate,
       se.lastdate, se.status, 'P' pstatus, se.irtied, se.ircd,
       sb_new.avgprice costprice,
       se.trade, se.mortage, se.margin, 0 netting, se.standing, se.withdraw,
       se.deposit, se.loan, se.blocked, 0 receiving, se.transfer,
       se.prevqtty, se.dcrqtty, se.dcramt, 0 depofeeacr, 0 repo, se.pending,
       se.tbaldepo, se.custid,  se.costdt, se.secured, se.iccfcd, se.iccftied, v_currdate tbaldt,
       se.senddeposit, se.sendpending, se.ddroutqtty, se.ddroutamt, se.dtoclose, se.sdtoclose, se.qtty_transfer,
       sysdate last_change, 0 dealintpaid, 0 wtrade, 0 grpordamt, 0 emkqtty,
       0 blockwithdraw, 0 blockdtoclose, 'Y' roomchk, 0 roomlimit,
       '' costprice_adj_date, '' shareholdersid, '' oldshareholdersid, sb_old.codeid, se.acctno
    FROM host.semast se, host.sbsecurities sb_old, securities_info sb_new
    where /*se.trade + se.mortage + se.margin + se.netting + se.standing + se.withdraw
        + se.deposit + se.loan + se.blocked + se.receiving + se.transfer + se.secured + se.pending >0
        and*/ se.codeid = sb_old.codeid
        and sb_old.symbol = sb_new.symbol
        and nvl(se.trade,0) >=0
        and INSTR(sb_old.symbol, '-') + INSTR(sb_old.symbol, '.') + INSTR(sb_old.symbol, '_') =0;

    -- Cho giao
    Update semast set netting=0, receiving=0;
    Begin
        For rec in
        (
            select acctno, sum(qtty) netting
            from stschd
            where duetype ='SS'  and v_currdate <= cleardate and txdate <> v_currdate
            group by acctno
        )Loop
            Update semast set netting = rec.netting where acctno = rec.acctno;
        End Loop;
    End;

    -- Cho ve
    Begin
        For rec in
        (
            select acctno, sum(qtty) receiving
            from stschd where duetype ='RS' and v_currdate <= cleardate and txdate <> v_currdate
            group by acctno
        )Loop
            Update semast set receiving = rec.receiving where acctno = rec.acctno;
        End Loop;
    End;

    InsertConvertLog('I','End semast');
    COMMIT;
    EXECUTE IMMEDIATE('ANALYZE TABLE SEMAST COMPUTE STATISTICS');

    INSERT into setran(txnum, txdate, acctno, txcd, namt, camt, ref, deltd, autoid, acctref, tltxcd, bkdate, trdesc)
    SELECT a.txnum, a.txdate, se.acctno,
           a.txcd, a.namt, a.camt, a.ref, a.deltd, a.autoid, a.acctno acctref, a.tltxcd, a.bkdate, a.trdesc
    FROM host.setran a, semast se
    where a.acctno = se.oldacctno and a.namt <> 0;

    InsertConvertLog('I','End setran');
    COMMIT;

    INSERT into setrana(txnum, txdate, acctno, txcd, namt, camt, ref, deltd, autoid, acctref, tltxcd, bkdate, trdesc)
    SELECT a.txnum, a.txdate, se.acctno,
           a.txcd, a.namt, a.camt, a.ref, a.deltd, a.autoid, a.acctno acctref, a.tltxcd, a.bkdate, a.trdesc
    FROM host.setrana a, semast se
    where a.acctno = se.oldacctno and a.namt <> 0;

    InsertConvertLog('I','End setrana');
    COMMIT;

    INSERT into setran_gen(autoid, custodycd, custid, txnum, txdate, acctno,
       txcd, namt, camt, ref, deltd, acctref, tltxcd,
       busdate, txdesc, txtime, brid, tlid, offid, chid,
       afacctno, symbol, sectype, tradeplace, txtype, field,
       codeid, tllog_autoid, trdesc)
    SELECT a.autoid, a.custodycd, a.custid, a.txnum, a.txdate, mst.acctno,
           a.txcd, a.namt, a.camt, a.ref, a.deltd, a.acctref, a.tltxcd,
           a.busdate, a.txdesc, a.txtime, a.brid, a.tlid, a.offid, a.chid,
           a.afacctno, a.symbol, a.sectype, a.tradeplace, a.txtype, a.field,
           mst.codeid, a.tllog_autoid, a.trdesc
    FROM host.setran_gen a, semast mst
    where a.acctno = mst.oldacctno and a.namt <> 0;


    -- Log chung khoan phong toa de co the thuc hien duoc 2203
    INSERT into seblocked(afacctno, codeid, blocked, emkqtty, blocktype, deltd,
       txnum, txdate, rlsblocked, rlsemkqtty, rlstxnum, rlstxdate, txdesc)
    SELECT se.afacctno, se.codeid, 0 blocked, se.blocked emkqtty, 'O' blocktype, 'N' deltd,
           nvl(tr.txnum,''), nvl(tr.txdate,''), 0 rlsblocked, 0 rlsemkqtty, '' rlstxnum,
           null rlstxdate, '' txdesc
    FROM cfmast cf, sbsecurities sb, semast se
    LEFT JOIN
        (
            Select acctno, max(txnum) txnum, max(txdate) txdate,  sum(namt) namt
            from vw_setran_gen
            where field ='BLOCKED' and deltd <> 'Y'
            group by acctno
        )tr on tr.acctno = se.acctno
    where cf.custid = se.custid and sb.codeid = se.codeid
          and se.blocked > 0
          and not EXISTS (select * from t_bmsc_hccn_vsd t where cf.custodycd = t.custodycd and sb.symbol = t.symbol);


    select max(autoid) + 1 into v_max_autoid from vw_setran_all;
    RESET_SEQUENCE(SEQ_NAME => 'seq_setran', STARTVALUE => v_max_autoid);

    For rec in
    (
        select mst.afacctno || mst.codeid seacctno, mst.* from seblocked mst
    )Loop

        Update semast
            set emkqtty = emkqtty + rec.emkqtty, blocked=blocked-rec.emkqtty
        where acctno = rec.seacctno;

        V_TXNUM := '9990'|| LPAD(seq_CVtxnum.NEXTVAL,6,'0');
        INSERT INTO tllogall
        (AUTOID,TXNUM,TXDATE,TXTIME,BRID,TLID,OFFID,OVRRQS,CHID,CHKID,TLTXCD,IBT,BRID2,TLID2,CCYUSAGE,OFF_LINE,DELTD,BRDATE,BUSDATE,TXDESC,IPADDRESS,WSNAME,TXSTATUS,MSGSTS,OVRSTS,BATCHNAME,MSGAMT,MSGACCT,CHKTIME,OFFTIME,CAREBYGRP)
        VALUES
        (seq_tllog.NEXTVAL ,V_TXNUM,v_prevdate,'13:50:24','0001','0001','0001','@00',NULL,NULL,'9902',NULL,NULL,NULL,'00','N','N',v_prevdate,v_prevdate,
        'Convert data, move blocked to emkqtty','10.26.0.125','Admin','1','0','0','DAY',REC.emkqtty ,REC.SEACCTNO,NULL,'01:51:39',NULL);

        -- -0044 BLOCKED
        INSERT INTO setrana(TLTXCD,TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,REF,DELTD,AUTOID)
        VALUES ('9902', V_TXNUM,v_prevdate,rec.seacctno,'0044',rec.emkqtty,NULL,'','N',seq_setran.nextval);

        -- + 0087 EMKQTTY
        INSERT INTO setrana(TLTXCD,TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,REF,DELTD,AUTOID)
        VALUES ('9902',V_TXNUM,v_prevdate,rec.seacctno,'0087',rec.emkqtty,NULL,'','N',seq_setran.nextval);

        INSERT INTO setran_gen (AUTOID,CUSTODYCD,CUSTID,TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,REF,DELTD,ACCTREF,TLTXCD,BUSDATE,TXDESC,TXTIME,BRID,TLID,OFFID,CHID,AFACCTNO,SYMBOL,SECTYPE,TRADEPLACE,TXTYPE,FIELD,CODEID,TLLOG_AUTOID,TRDESC)
        select tr.autoid, cf.custodycd, cf.custid, tr.txnum, tr.txdate, tr.acctno, tr.txcd, tr.namt, tr.camt, tr.ref, tr.deltd, tr.acctref,
            tl.tltxcd, tl.busdate,
            case when tl.tlid ='6868' then trim(tl.txdesc) || ' (Online)' else tl.txdesc end txdesc,
            tl.txtime, tl.brid, tl.tlid, tl.offid, tl.chid,
            se.afacctno, sb.symbol, sb.sectype, sb.tradeplace, ap.txtype, ap.field, sb.codeid ,tl.autoid,
            case when tr.trdesc is not null
                then (case when tl.tlid ='6868' then trim(tr.trdesc) || ' (Online)' else tr.trdesc end)
                else tr.trdesc end trdesc
        from setrana tr, tllogall tl, sbsecurities sb, semast se, cfmast cf, apptx ap
        where tr.txdate = tl.txdate and tr.txnum = tl.txnum
            and tr.acctno = se.acctno
            and sb.codeid = se.codeid
            and se.custid = cf.custid
            and tr.txcd = ap.txcd and ap.apptype = 'SE' and ap.txtype in ('D','C')
            and tr.deltd <> 'Y' and tr.namt <> 0
            and tr.ACCTNO like rec.seacctno
            and tr.txnum = V_TXNUM
            and tr.txdate = v_prevdate;
    End Loop;


    InsertConvertLog('I','End setran_gen');
    COMMIT;



    EXECUTE IMMEDIATE('ANALYZE TABLE SETRAN COMPUTE STATISTICS');
    EXECUTE IMMEDIATE('ANALYZE TABLE SETRANA COMPUTE STATISTICS');
    EXECUTE IMMEDIATE('ANALYZE TABLE SETRAN_GEN COMPUTE STATISTICS');

    COMMIT;

EXCEPTION
    WHEN OTHERS THEN

InsertConvertLog('E',sqlerrm) ;
END;

PROCEDURE odmastcv  IS
v_currdate date;
v_prevdate date;
v_nextdate date;
v_t_1_date date;
v_t_2_date date;
v_t_3_date date;
v_max_autoid number(20);
BEGIN


    dbms_utility.exec_ddl_statement('TRUNCATE TABLE ODMAST' );
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE ODMASTHIST' );
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE STSCHD' );
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE STSCHDHIST' );
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE IOD' );
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE IODHIST' );
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE OOD' );
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE OODHIST' );

    InsertConvertLog('I','Begin odmasthist....');

    INSERT INTO odmasthist(actype, orderid, codeid, afacctno, seacctno,
         ciacctno, txnum, txdate, txtime, expdate, bratio,
         timetype, exectype, nork, matchtype, via, clearday,
         clearcd, orstatus, pricetype, quoteprice, stopprice,
         limitprice, orderqtty, remainqtty, execqtty, standqtty,
         cancelqtty, adjustqtty, rejectqtty, rejectcd, custid,
         exprice, exqtty, iccfcd, iccftied, execamt, examt,
         feeamt, consultant, voucher, odtype, feeacr,
         porstatus, rlssecured, securedamt, matchamt, deltd,
         reforderid, banktrfamt, banktrffee, edstatus,
         correctionnumber, contrafirm, traderid, clientid,
         confirm_no, foacctno, hosesession, contraorderid,
         puttype, contrafrm, dfacctno, last_change, dfqtty,
         stsstatus, feebratio, tlid, ssafacctno, advidref,
         noe, grporder, grpamt, excfeeamt, excfeerefid,
         isdisposal, taxrate, taxsellamt, errod, errsts,
         errreason, ferrod, fixerrtype, errodref, quoteqtty,
         confirmed, exstatus, ptdeal, cancelstatus, feedbackmsg,
         blorderid, isblorder)
    SELECT '0001' actype, a.orderid, se.codeid, a.afacctno, se.acctno,
           a.ciacctno, a.txnum, a.txdate, a.txtime, a.expdate, a.bratio,
           a.timetype, a.exectype, a.nork, a.matchtype, a.via, a.clearday,
           a.clearcd, a.orstatus, a.pricetype, a.quoteprice, a.stopprice,
           a.limitprice, a.orderqtty, a.remainqtty, a.execqtty, a.standqtty,
           a.cancelqtty, a.adjustqtty, a.rejectqtty, a.rejectcd, a.custid,
           a.exprice, a.exqtty, a.iccfcd, a.iccftied, a.execamt, a.examt,
           a.feeamt, a.consultant, a.voucher, a.odtype, a.feeacr,
           a.porstatus, a.rlssecured, a.securedamt, a.matchamt, a.deltd,
           a.reforderid, a.banktrfamt, a.banktrffee, a.edstatus,
           a.correctionnumber, a.contrafirm, a.traderid, a.clientid,
           a.confirm_no, a.foacctno, a.hosesession, a.contraorderid,
           a.puttype, a.contrafrm, a.dfacctno, a.last_change, a.dfqtty,
           a.stsstatus, a.feebratio, a.tlid, '' ssafacctno, 0 advidref,
           'N' noe, 'N' grporder, 0 grpamt, 0 excfeeamt, 0 excfeerefid,
           'N' isdisposal, 0 taxrate, 0 taxsellamt, 'N' errod, ''errsts,
           '' errreason, 'N' ferrod, '' fixerrtype, '' errodref, a.quoteqtty,
           a.confirmed, a.exstatus, a.ptdeal, 'N' cancelstatus, '' feedbackmsg,
           '' blorderid, '' isblorder
      FROM host.odmasthist a, semast se
      WHERE a.afacctno = se.afacctno
            and a.seacctno = se.oldacctno;

      InsertConvertLog('I','Begin odmast....');
      INSERT INTO odmast(actype, orderid, codeid, afacctno, seacctno,
         ciacctno, txnum, txdate, txtime, expdate, bratio,
         timetype, exectype, nork, matchtype, via, clearday,
         clearcd, orstatus, pricetype, quoteprice, stopprice,
         limitprice, orderqtty, remainqtty, execqtty, standqtty,
         cancelqtty, adjustqtty, rejectqtty, rejectcd, custid,
         exprice, exqtty, iccfcd, iccftied, execamt, examt,
         feeamt, consultant, voucher, odtype, feeacr,
         porstatus, rlssecured, securedamt, matchamt, deltd,
         reforderid, banktrfamt, banktrffee, edstatus,
         correctionnumber, contrafirm, traderid, clientid,
         confirm_no, foacctno, hosesession, contraorderid,
         puttype, contrafrm, dfacctno, last_change, dfqtty,
         stsstatus, feebratio, tlid, ssafacctno, advidref,
         noe, grporder, grpamt, excfeeamt, excfeerefid,
         isdisposal, taxrate, taxsellamt, errod, errsts,
         errreason, ferrod, fixerrtype, errodref, quoteqtty,
         confirmed, exstatus, ptdeal, cancelstatus, feedbackmsg,
         blorderid, isblorder)
    SELECT '0001' actype, a.orderid, se.codeid, a.afacctno, se.acctno,
           a.ciacctno, a.txnum, a.txdate, a.txtime, a.expdate, a.bratio,
           a.timetype, a.exectype, a.nork, a.matchtype, a.via, a.clearday,
           a.clearcd, a.orstatus, a.pricetype, a.quoteprice, a.stopprice,
           a.limitprice, a.orderqtty, a.remainqtty, a.execqtty, a.standqtty,
           a.cancelqtty, a.adjustqtty, a.rejectqtty, a.rejectcd, a.custid,
           a.exprice, a.exqtty, a.iccfcd, a.iccftied, a.execamt, a.examt,
           a.feeamt, a.consultant, a.voucher, a.odtype, a.feeacr,
           a.porstatus, a.rlssecured, a.securedamt, a.matchamt, a.deltd,
           a.reforderid, a.banktrfamt, a.banktrffee, a.edstatus,
           a.correctionnumber, a.contrafirm, a.traderid, a.clientid,
           a.confirm_no, a.foacctno, a.hosesession, a.contraorderid,
           a.puttype, a.contrafrm, a.dfacctno, a.last_change, a.dfqtty,
           a.stsstatus, a.feebratio, a.tlid, '' ssafacctno, 0 advidref,
           'N' noe, 'N' grporder, 0 grpamt, 0 excfeeamt, 0 excfeerefid,
           'N' isdisposal, 0 taxrate, 0 taxsellamt, 'N' errod, ''errsts,
           '' errreason, 'N' ferrod, '' fixerrtype, '' errodref, a.quoteqtty,
           a.confirmed, a.exstatus, a.ptdeal, 'N' cancelstatus, '' feedbackmsg,
           '' blorderid, '' isblorder
      FROM host.odmast a, semast se
      WHERE a.afacctno = se.afacctno
            and a.seacctno = se.oldacctno;

      COMMIT;
      EXECUTE IMMEDIATE('ANALYZE TABLE ODMAST COMPUTE STATISTICS');
      EXECUTE IMMEDIATE('ANALYZE TABLE ODMASTHIST COMPUTE STATISTICS');

      Update odmast set VIA ='F' where VIA ='B';
      Update odmasthist set VIA ='F' where VIA ='B';

      Update odmast set tlid='0001' where VIA <> 'O';
      Update odmasthist set tlid='0001' where VIA <> 'O';

      Update odmast set tlid='6868' where VIA ='O';
      Update odmasthist set tlid='6868' where VIA='O';

      InsertConvertLog('I','Begin oodhist....');
      INSERT INTO oodhist(orgorderid, codeid, symbol, custodycd, bors, norp,
       aorn, price, qtty, oodstatus, txnum, txdate, deltd,
       securedratio, txtime, brid, tlid, tlidsent,
       ipaddress, reforderid, refqtty, refprice, execqtty,
       sendqtty, confirmid, quoteqtty, limitprice, sendnum, senttime)
      SELECT a.orgorderid, sb.codeid, a.symbol, a.custodycd, a.bors, a.norp,
           a.aorn, a.price, a.qtty, a.oodstatus, a.txnum, a.txdate, a.deltd,
           a.securedratio, a.txtime, a.brid, a.tlid, a.tlidsent,
           a.ipaddress, a.reforderid, a.refqtty, a.refprice, a.execqtty,
           a.sendqtty, a.confirmid, a.quoteqtty, a.limitprice, '' sendnum,
           '' senttime
      FROM host.oodhist a, sbsecurities sb
      WHERE a.symbol = sb.symbol;-- and EXISTS (SELECT * FROM VW_ODMAST_ALL OD WHERE OD.ORDERID = ORGORDERID);

      InsertConvertLog('I','Begin ood....');
      INSERT INTO ood(orgorderid, codeid, symbol, custodycd, bors, norp,
       aorn, price, qtty, oodstatus, txnum, txdate, deltd,
       securedratio, txtime, brid, tlid, tlidsent,
       ipaddress, reforderid, refqtty, refprice, execqtty,
       sendqtty, confirmid, quoteqtty, limitprice, sendnum, senttime)
      SELECT a.orgorderid, a.codeid, a.symbol, a.custodycd, a.bors, a.norp,
           a.aorn, a.price, a.qtty, a.oodstatus, a.txnum, a.txdate, a.deltd,
           a.securedratio, a.txtime, a.brid, a.tlid, a.tlidsent,
           a.ipaddress, a.reforderid, a.refqtty, a.refprice, a.execqtty,
           a.sendqtty, a.confirmid, a.quoteqtty, a.limitprice, '' sendnum,
           '' senttime
      FROM host.ood a, sbsecurities sb
      WHERE a.symbol = sb.symbol;-- and EXISTS (SELECT * FROM vw_odmast_all OD WHERE OD.ORDERID = ORGORDERID);


      InsertConvertLog('I','Begin iodhist....');
      INSERT INTO iodhist(orgorderid, exorderid, codeid, symbol, custodycd,
           bors, norp, aorn, price, qtty, refcustcd,
           matchprice, matchqtty, txnum, txdate, deltd,
           confirm_no, txtime, iodfeeacr, iodtaxsellamt)
      SELECT a.orgorderid, a.exorderid, a.codeid, a.symbol, a.custodycd,
           a.bors, a.norp, a.aorn, a.price, a.qtty, a.refcustcd,
           a.matchprice, a.matchqtty, a.txnum, a.txdate, a.deltd,
           a.confirm_no, a.txtime, 0 iodfeeacr, 0 iodtaxsellamt
      FROM host.iodhist a, sbsecurities sb
      WHERE a.symbol = sb.symbol;-- and EXISTS (SELECT * FROM VW_ODMAST_ALL OD WHERE OD.ORDERID = ORGORDERID);

      InsertConvertLog('I','Begin iod....');
      INSERT INTO iod(orgorderid, exorderid, codeid, symbol, custodycd,
           bors, norp, aorn, price, qtty, refcustcd,
           matchprice, matchqtty, txnum, txdate, deltd,
           confirm_no, txtime, iodfeeacr, iodtaxsellamt)
      SELECT a.orgorderid, a.exorderid, a.codeid, a.symbol, a.custodycd,
           a.bors, a.norp, a.aorn, a.price, a.qtty, a.refcustcd,
           a.matchprice, a.matchqtty, a.txnum, a.txdate, a.deltd,
           a.confirm_no, a.txtime, 0 iodfeeacr, 0 iodtaxsellamt
      FROM host.iod a, sbsecurities sb
      WHERE a.symbol = sb.symbol;-- and  EXISTS (SELECT * FROM VW_ODMAST_ALL OD WHERE OD.ORDERID = ORGORDERID);


      InsertConvertLog('I','Begin stschdhist S....');
      -- Nhan CK
      INSERT INTO stschdhist(autoid, duetype, acctno, reforderid, txdate,
           clearday, clearcd, amt, aamt, qtty, aqtty, famt,
           afacctno, status, deltd, txnum, orgorderid, codeid,
           paidamt, paidfeeamt, costprice, cleardate, rightqtty, aright, dfamt)
      select a.autoid, a.duetype, od.seacctno,
       a.reforderid, a.txdate, a.clearday, a.clearcd, a.amt, a.aamt, a.qtty, a.aqtty, a.famt,
       a.afacctno, a.status, a.deltd, a.txnum, a.orgorderid, od.codeid, a.paidamt, a.paidfeeamt,
       a.costprice, a.cleardate, 0 rightqtty, 0 aright, 0 dfamt
      from host.stschdhist a, vw_odmast_all od
      WHERE A.orgorderid = od.orderid
            AND duetype IN ('RS','SS');

      -- Nhan Tien
      InsertConvertLog('I','Begin stschdhist M....');
      INSERT INTO stschdhist(autoid, duetype, acctno, reforderid, txdate,
           clearday, clearcd, amt, aamt, qtty, aqtty, famt,
           afacctno, status, deltd, txnum, orgorderid, codeid,
           paidamt, paidfeeamt, costprice, cleardate, rightqtty, aright, dfamt)
      select a.autoid, a.duetype, od.afacctno,
       a.reforderid, a.txdate, a.clearday, a.clearcd, a.amt, a.aamt, a.qtty, a.aqtty, a.famt,
       a.afacctno, a.status, a.deltd, a.txnum, a.orgorderid, od.codeid, a.paidamt, a.paidfeeamt,
       a.costprice, a.cleardate, 0 rightqtty, 0 aright, 0 dfamt
      from host.stschdhist a, vw_odmast_all od
      WHERE A.orgorderid = od.orderid
            AND a.duetype IN ('RM','SM');


      -- Nhan CK
      InsertConvertLog('I','Begin stschd S....');
      INSERT INTO stschd(autoid, duetype, acctno, reforderid, txdate,
           clearday, clearcd, amt, aamt, qtty, aqtty, famt,
           afacctno, status, deltd, txnum, orgorderid, codeid,
           paidamt, paidfeeamt, costprice, cleardate, rightqtty, aright, dfamt)
      select a.autoid, a.duetype,
             od.seacctno,
       a.reforderid, a.txdate, a.clearday, a.clearcd, a.amt, a.aamt, a.qtty, a.aqtty, a.famt,
       a.afacctno, a.status, a.deltd, a.txnum, a.orgorderid, od.codeid, a.paidamt, a.paidfeeamt,
       a.costprice, a.cleardate, 0 rightqtty, 0 aright, 0 dfamt
      from host.stschd a, vw_odmast_all od
      WHERE A.orgorderid = od.orderid
            AND duetype IN ('RS','SS');

      -- Nhan Tien
      InsertConvertLog('I','Begin stschd M....');
      INSERT INTO stschd(autoid, duetype, acctno, reforderid, txdate,
           clearday, clearcd, amt, aamt, qtty, aqtty, famt,
           afacctno, status, deltd, txnum, orgorderid, codeid,
           paidamt, paidfeeamt, costprice, cleardate, rightqtty, aright, dfamt)
      select a.autoid, a.duetype, a.afacctno,
       a.reforderid, a.txdate, a.clearday, a.clearcd, a.amt, a.aamt, a.qtty, a.aqtty, a.famt,
       a.afacctno, a.status, a.deltd, a.txnum, a.orgorderid, od.codeid, a.paidamt, a.paidfeeamt,
       a.costprice, a.cleardate, 0 rightqtty, 0 aright, 0 dfamt
      from host.stschd a, vw_odmast_all od
      WHERE A.orgorderid = od.orderid
            AND a.duetype IN ('RM','SM');


       -- Cap nhat lai thue ban CK
      InsertConvertLog('I','odmastcv, begin tinh lai thue ban....');
      Begin
        For rec in
        (
            Select * from stschd where DUETYPE='RM'
        )Loop
            update odmast set taxrate=0.1, taxsellamt=0.1/100*rec.AMT where orderid = rec.orgorderid;
        End Loop;
      End;

      Begin
        For rec in
        (
            Select * from stschdhist where DUETYPE='RM'
        )Loop
            update odmasthist set taxrate=0.1, taxsellamt=0.1/100*rec.AMT where orderid = rec.orgorderid;
        End Loop;
      End;
      InsertConvertLog('I','odmastcv, End tinh lai thue ban....');


      InsertConvertLog('I','End stschd....');
      COMMIT;

      select max(autoid) + 1 into v_max_autoid from vw_stschd_all;
      RESET_SEQUENCE(SEQ_NAME => 'seq_stschd', STARTVALUE => v_max_autoid);

      EXECUTE IMMEDIATE('ANALYZE TABLE IOD COMPUTE STATISTICS');
      EXECUTE IMMEDIATE('ANALYZE TABLE IODHIST COMPUTE STATISTICS');
      EXECUTE IMMEDIATE('ANALYZE TABLE OOD COMPUTE STATISTICS');
      EXECUTE IMMEDIATE('ANALYZE TABLE OODHIST COMPUTE STATISTICS');
      EXECUTE IMMEDIATE('ANALYZE TABLE STSCHD COMPUTE STATISTICS');
      EXECUTE IMMEDIATE('ANALYZE TABLE STSCHDHIST COMPUTE STATISTICS');

      InsertConvertLog('I','Begin pr_allocate_IODHIST....');
      FOR REC IN (SELECT * FROM VW_ODMAST_ALL)
        LOOP
            pr_allocate_IODHIST_fee(REC.ORDERID);
            pr_allocate_IODHIST_tax(REC.ORDERID);
      END LOOP;
      InsertConvertLog('I','End pr_allocate_IODHIST....');

      COMMIT;

      InsertConvertLog('I','End Odmastcv !') ;

EXCEPTION
    WHEN OTHERS THEN
         InsertConvertLog('E','Odmastcv, '
                       ||sqlerrm || '.At:' || dbms_utility.format_error_backtrace);


END;

PROCEDURE adschdcv  IS
    v_currdate date;
    v_prevdate date;
    v_nextdate date;
    v_t_1_date date;
    v_t_2_date date;
    v_t_3_date date;
    v_dblamt number(20,4);
    v_acctno varchar2(50);
    v_max_autoid number(20);
BEGIN
    InsertConvertLog('I','Begin adschd....');
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE adschd' );
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE adschdhist' );
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE advreslog' );
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE advresloghist' );
    RESET_SEQUENCE(SEQ_NAME => 'seq_advreslog', STARTVALUE => 1);

    select to_date(varvalue,'DD/MM/RRRR') into v_currdate from sysvar where grname ='SYSTEM' and varname ='CURRDATE';
    select to_date(varvalue,'DD/MM/RRRR') into v_prevdate from sysvar where grname ='SYSTEM' and varname ='PREVDATE';
    select to_date(varvalue,'DD/MM/RRRR') into v_nextdate from sysvar where grname ='SYSTEM' and varname ='NEXTDATE';
    v_t_1_date:=get_t_date(v_currdate,1);
    v_t_2_date:=get_t_date(v_currdate,2);
    v_t_3_date:=get_t_date(v_currdate,3);

    InsertConvertLog('I','Begin adschdhist....');
    INSERT into adschdhist(autoid, ismortage, status, deltd, acctno, txdate,
       txnum, refadno, cleardt, amt, feeamt, vatamt,
       bankfee, paidamt, oddate, rrtype, custbank, ciacctno,
       paiddate, adtype, paidfee)
    SELECT a.autoid, a.ismortage, a.status, a.deltd, a.acctno, a.txdate,
       a.txnum, a.refadno, a.cleardt, a.amt, a.feeamt, a.vatamt,
       a.bankfee, a.paidamt, '' oddate, '' rrtype, '' custbank, '' ciacctno,
       null paiddate, '0001' adtype, 0 paidfee
    FROM host.adschdhist a;

    InsertConvertLog('I','Begin adschd....');
    INSERT into adschd(autoid, ismortage, status, deltd, acctno, txdate,
       txnum, refadno, cleardt, amt, feeamt, vatamt,
       bankfee, paidamt, oddate, rrtype, custbank, ciacctno,
       paiddate, adtype, paidfee)
    SELECT a.autoid, a.ismortage, a.status, a.deltd, a.acctno, a.txdate,
       a.txnum, a.refadno, a.cleardt, a.amt, a.feeamt, a.vatamt,
       a.bankfee, a.paidamt, '' oddate, '' rrtype, '' custbank, '' ciacctno,
       null paiddate, '0001' adtype, 0 paidfee
    FROM host.adschd a where a.cleardt <= v_nextdate;

    Delete from advresloghist;
    for rec in (select  * from  adschdhist)
    loop
        INSERT INTO advresloghist (AUTOID,TXDATE,TXNUM,RRTYPE,CUSTBANK,AFACCTNO,AMT,RESREMAIN,BANKRATE,DELTD)
        VALUES(seq_advreslog.nextval  ,rec.txdate,rec.txnum,'C','',rec.acctno,rec.amt,0,0,'N');
    end loop;


    InsertConvertLog('I','Begin adschd....');
    INSERT into adschd(autoid, ismortage, status, deltd, acctno, txdate,
       txnum, refadno, cleardt, amt, feeamt, vatamt,
       bankfee, paidamt, oddate, rrtype, custbank, ciacctno,
       paiddate, adtype, paidfee)
    SELECT a.autoid, a.ismortage, a.status, a.deltd, a.acctno, a.txdate,
       a.txnum, a.refadno, a.cleardt, a.amt, a.feeamt, a.vatamt,
       a.bankfee, a.paidamt, '' oddate, '' rrtype, '' custbank, '' ciacctno,
       null paiddate, '0001' adtype, 0 paidfee
    FROM host.adschd a where a.cleardt > v_nextdate;

    Delete from advreslog;
    for rec in (select  * from  adschd)
    loop
        INSERT INTO advreslog (AUTOID,TXDATE,TXNUM,RRTYPE,CUSTBANK,AFACCTNO,AMT,RESREMAIN,BANKRATE,DELTD)
        VALUES(seq_advreslog.nextval  ,rec.txdate,rec.txnum,'C','',rec.acctno,rec.amt,0,0,'N');
    end loop;

    SELECT max(autoid) + 1 into v_max_autoid from vw_adschd_all;
    RESET_SEQUENCE(SEQ_NAME => 'seq_adschd', STARTVALUE => v_max_autoid);

    InsertConvertLog('I','End adschd....');

EXCEPTION
    WHEN OTHERS THEN
         InsertConvertLog('E','adschdcv, '
                               ||sqlerrm || '.At:' || dbms_utility.format_error_backtrace);
END;

PROCEDURE lnmastcv  IS

v_currdate date;
v_prevdate date;
l_prevdate date;
v_nextdate date;
v_t_1_date date;
v_t_2_date date;
v_t_3_date date;
v_max_autoid NUMBER;
l_lnschdid number;
l_sumval number;
l_overduedate date;
BEGIN
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE LNMAST DROP STORAGE' );
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE LNMASTHIST DROP STORAGE' );
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE LNSCHD DROP STORAGE' );
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE LNSCHDHIST DROP STORAGE' );
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE LNSCHDLOG DROP STORAGE' );
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE LNSCHDLOGHIST DROP STORAGE' );
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE LNSCHDEXTLOG DROP STORAGE' );
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE RLSRPTLOG_EOD DROP STORAGE' );
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE LNTRAN DROP STORAGE' );
    dbms_utility.exec_ddl_statement('TRUNCATE TABLE LNTRANA DROP STORAGE' );

    select to_date(varvalue,'DD/MM/RRRR') into v_currdate from sysvar where grname ='SYSTEM' and varname ='CURRDATE';
    select to_date(varvalue,'DD/MM/RRRR') into v_prevdate from sysvar where grname ='SYSTEM' and varname ='PREVDATE';
    select to_date(varvalue,'DD/MM/RRRR') into v_nextdate from sysvar where grname ='SYSTEM' and varname ='NEXTDATE';
    l_prevdate := v_prevdate;

    InsertConvertLog('I','Begin lnmast MR...');
    -- Vay Margin
    INSERT into lnmast(actype, acctno, ccycd, bankid, applid, opndate,
       expdate, extdate, clsdate, rlsdate, lastdate,
       acrdate, oacrdate, status, pstatus, trfacctno,
       prinaft, intaft, lntype, lncldr, prinfrq, prinperiod,
       intfrgcd, intday, intperiod, nintcd, ointcd, rate1,
       rate2, rate3, oprinfrq, oprinperiod, ointfrqcd,
       ointday, orate1, orate2, orate3, drate, aprlimit,
       rlsamt, prinpaid, prinnml, prinovd, intnmlacr,
       intovdacr, intnmlpbl, intnmlovd, intdue, intpaid,
       intprepaid, notes, lnclass, advpay, advpayfee,
       orlsamt, oprinpaid, oprinnml, oprinovd, ointnmlacr,
       ointnmlovd, ointovdacr, ointdue, ointpaid, ointprepaid,
       fee, feepaid, feedue, feeovd, feepaid2, ftype,
       last_change, printfrq1, printfrq2, printfrq3,
       indueratio, overdueratio, rrtype, custbank, ciacctno,
       autoadvpay, cfrate1, cfrate2, cfrate3, minterm,
       prepaid, intpaidmethod, autoapply, feeintnmlacr,
       feeintovdacr, feeintnmlovd, feeintdue, feeintprepaid,
       feeintpaid, intfloatamt, feefloatamt, intovdcd, bankpaidmethod)
    SELECT '0003' actype, a.acctno, a.ccycd, a.bankid, a.applid, a.opndate,
       a.expdate, a.extdate, a.clsdate, a.rlsdate, a.lastdate,
       a.acrdate, a.oacrdate, a.status, a.pstatus, a.trfacctno,
       a.prinaft, a.intaft, a.lntype, a.lncldr, a.prinfrq, a.prinperiod,
       a.intfrgcd, a.intday, a.intperiod, a.nintcd, a.ointcd, a.rate1,
       a.rate2, a.rate3, a.oprinfrq, a.oprinperiod, a.ointfrqcd,
       a.ointday, a.orate1, a.orate2, a.orate3, a.drate, a.aprlimit,
       a.rlsamt, a.prinpaid, a.prinnml, a.prinovd, a.intnmlacr,
       a.intovdacr, a.intnmlpbl, a.intnmlovd, a.intdue, a.intpaid,
       a.intprepaid, a.notes, a.lnclass, a.advpay, a.advpayfee,
       a.orlsamt, a.oprinpaid, a.oprinnml, a.oprinovd, a.ointnmlacr,
       a.ointnmlovd, a.ointovdacr, a.ointdue, a.ointpaid, a.ointprepaid,
       a.fee, a.feepaid, a.feedue, a.feeovd, a.feepaid2, a.ftype,
       a.last_change, 0 printfrq1, 0 printfrq2, 0 printfrq3,
       0 indueratio, 0 overdueratio, 'C' rrtype, null custbank, null ciacctno,
       a.autoadvpay, 0 cfrate1, 0 cfrate2, 0 cfrate3, 0 minterm,
       'N' prepaid, 'I' intpaidmethod, 'L' autoapply, 0 feeintnmlacr,
       0 feeintovdacr, 0 feeintnmlovd, 0 feeintdue, 0 feeintprepaid,
       0 feeintpaid, 0 intfloatamt, 0 feefloatamt, 'N' intovdcd,
       'I' bankpaidmethod
     FROM host.lnmast a
     WHERE abs( a.prinnml + a.prinovd + a.intnmlacr +
           a.intovdacr + a.intnmlpbl + a.intnmlovd + a.intdue) >= 2;

    InsertConvertLog('I','Begin lnschd MR...');
    INSERT INTO lnschd(autoid, acctno, dueno, rlsdate, duedate, overduedate,
       acrdate, ovdacrdate, paiddate, reftype, nml, ovd,
       paid, duests, pduests, intnmlacr, fee, due,
       intovdduedate, intdue, intovd, intovdprin, intpaid,
       feedue, feeovd, feepaid, feepaid2, rate1, rate2,
       rate3, cfrate1, cfrate2, cfrate3, feeintnmlacr,
       feeintovdacr, feeintnmlovd, feeintdue, feeintprepaid,
       feeintpaid, nmlfeeint, ovdfeeint, paidfeeint,
       feeintnml, feeintovd, refautoid, extimes, exdays, accrualsamt)
    SELECT a.autoid, a.acctno, a.dueno, a.rlsdate, a.duedate, a.overduedate,
       a.acrdate, a.ovdacrdate, a.paiddate, a.reftype, a.nml, a.ovd,
       a.paid, a.duests, a.pduests, a.intnmlacr, a.fee, a.due,
       a.intovdduedate, a.intdue, a.intovd, a.intovdprin, a.intpaid,
       a.feedue, a.feeovd, a.feepaid, a.feepaid2, ln.rate1, ln.rate2,
       ln.rate3, 0 cfrate1, 0 cfrate2, 0 cfrate3, 0 feeintnmlacr,
       0 feeintovdacr, 0 feeintnmlovd, 0 feeintdue, 0 feeintprepaid,
       0 feeintpaid, 0 nmlfeeint, 0 ovdfeeint, 0 paidfeeint,
       0 feeintnml, 0 feeintovd, null refautoid, 0 extimes, 0 exdays,
       (a.intnmlacr + a.intdue + a.intovd + a.intovdprin) accrualsamt
    FROM host.lnschd a, host.lnmast ln
       where a.acctno = ln.acctno
             and ln.prinnml + ln.prinovd + ln.intnmlacr +
             ln.intovdacr + ln.intnmlpbl + ln.intnmlovd + ln.intdue <> 0;


    INSERT INTO lnschdloghist (autoid, txnum, txdate, nml, ovd, paid, intnmlacr,
       fee, intdue, intovd, intovdprin, feedue, feeovd,
       intpaid, feepaid, feepaid2, feeintnmlacr, feeintdue,
       feeintovd, feeintovdprin, feeintpaid, nmlfeeint,
       ovdfeeint, paidfeeint, deltd, refautoid, lastpaid,
       accrualsamt)
    SELECT a.autoid, '' txnum, getcurrdate txdate, a.nml, a.ovd, a.paid, a.intnmlacr,
        a.fee, a.intdue, a.intovd, a.intovdprin, a.feedue, a.feeovd,
        a.intpaid, a.feepaid, a.feepaid2, a.feeintnmlacr, a.feeintdue,
        a.feeintovd, 0 feeintovdprin, a.feeintpaid, a.nmlfeeint,
        a.ovdfeeint, a.paidfeeint, 'Y' deltd, a.refautoid, '' lastpaid,
        a.accrualsamt
   FROM lnschd a;


    -- Vay Bao Lanh
    InsertConvertLog('I','Begin lnmast T0...');
    INSERT into lnmast(actype, acctno, ccycd, bankid, applid, opndate,
       expdate, extdate, clsdate, rlsdate, lastdate,
       acrdate, oacrdate, status, pstatus, trfacctno,
       prinaft, intaft, lntype, lncldr, prinfrq, prinperiod,
       intfrgcd, intday, intperiod, nintcd, ointcd, rate1,
       rate2, rate3, oprinfrq, oprinperiod, ointfrqcd,
       ointday, orate1, orate2, orate3, drate, aprlimit,
       rlsamt, prinpaid, prinnml, prinovd, intnmlacr,
       intovdacr, intnmlpbl, intnmlovd, intdue, intpaid,
       intprepaid, notes, lnclass, advpay, advpayfee,
       orlsamt, oprinpaid, oprinnml, oprinovd, ointnmlacr,
       ointnmlovd, ointovdacr, ointdue, ointpaid, ointprepaid,
       fee, feepaid, feedue, feeovd, feepaid2, ftype,
       last_change, printfrq1, printfrq2, printfrq3,
       indueratio, overdueratio, rrtype, custbank, ciacctno,
       autoadvpay, cfrate1, cfrate2, cfrate3, minterm,
       prepaid, intpaidmethod, autoapply, feeintnmlacr,
       feeintovdacr, feeintnmlovd, feeintdue, feeintprepaid,
       feeintpaid, intfloatamt, feefloatamt, intovdcd, bankpaidmethod)
    SELECT (case when to_date(rlsdate,systemnums.C_DATE_FORMAT) >= pks_covert_to_flex.C_CONST_DEPOLASTDT then '0002' else '0001' end) actype, a.acctno, a.ccycd, a.bankid, a.applid, a.opndate,
       a.expdate, a.extdate, a.clsdate, a.rlsdate, a.lastdate,
       a.acrdate, a.oacrdate, a.status, a.pstatus, a.trfacctno,
       a.prinaft, a.intaft, a.lntype, a.lncldr, a.prinfrq, a.prinperiod,
       a.intfrgcd, a.intday, a.intperiod, a.nintcd, a.ointcd, a.rate1,
       a.rate2, a.rate3, a.oprinfrq, a.oprinperiod, a.ointfrqcd,
       a.ointday, a.orate1, a.orate2, a.orate3, a.drate, a.aprlimit,
       a.rlsamt, a.prinpaid, a.prinnml, a.prinovd, a.intnmlacr,
       a.intovdacr, a.intnmlpbl, a.intnmlovd, a.intdue, a.intpaid,
       a.intprepaid, a.notes, a.lnclass, a.advpay, a.advpayfee,
       a.orlsamt, a.oprinpaid, a.oprinnml, a.oprinovd, a.ointnmlacr,
       a.ointnmlovd, a.ointovdacr, a.ointdue, a.ointpaid, a.ointprepaid,
       a.fee, a.feepaid, a.feedue, a.feeovd, a.feepaid2, a.ftype,
       a.last_change, 0 printfrq1, 0 printfrq2, 0 printfrq3,
       0 indueratio, 0 overdueratio, 'C' rrtype, null custbank, null ciacctno,
       a.autoadvpay, 0 cfrate1, 0 cfrate2, 0 cfrate3, 0 minterm,
       'N' prepaid, 'I' intpaidmethod, 'L' autoapply, 0 feeintnmlacr,
       0 feeintovdacr, 0 feeintnmlovd, 0 feeintdue, 0 feeintprepaid,
       0 feeintpaid, 0 intfloatamt, 0 feefloatamt, 'N' intovdcd,
       'I' bankpaidmethod
     FROM host.lnmast a
     WHERE a.oprinnml + a.oprinovd + a.ointnmlacr +
           a.ointnmlovd + a.ointovdacr + a.ointdue <> 0;

    InsertConvertLog('I','Begin lnschd T0...');
    INSERT INTO lnschd(autoid, acctno, dueno, rlsdate, duedate, overduedate,
       acrdate, ovdacrdate, paiddate, reftype, nml, ovd,
       paid, duests, pduests, intnmlacr, fee, due,
       intovdduedate, intdue, intovd, intovdprin, intpaid,
       feedue, feeovd, feepaid, feepaid2, rate1, rate2,
       rate3, cfrate1, cfrate2, cfrate3, feeintnmlacr,
       feeintovdacr, feeintnmlovd, feeintdue, feeintprepaid,
       feeintpaid, nmlfeeint, ovdfeeint, paidfeeint,
       feeintnml, feeintovd, refautoid, extimes, exdays, accrualsamt)
    SELECT seq_lnschd.nextval, a.acctno, a.dueno, a.rlsdate, a.duedate, a.overduedate,
       a.acrdate, a.ovdacrdate, a.paiddate, a.reftype, a.nml, a.ovd,
       a.paid, a.duests, a.pduests, a.intnmlacr, a.fee, a.due,
       a.intovdduedate, a.intdue, a.intovd, a.intovdprin, a.intpaid,
       a.feedue, a.feeovd, a.feepaid, a.feepaid2, ln.orate1, ln.orate2,
       ln.orate3, 0 cfrate1, 0 cfrate2, 0 cfrate3, 0 feeintnmlacr,
       0 feeintovdacr, 0 feeintnmlovd, 0 feeintdue, 0 feeintprepaid,
       0 feeintpaid, 0 nmlfeeint, 0 ovdfeeint, 0 paidfeeint,
       0 feeintnml, 0 feeintovd, null refautoid, 0 extimes, 0 exdays,
       (a.intnmlacr + a.intdue + a.intovd + a.intovdprin) accrualsamt
    FROM host.lnschd a, host.lnmast ln
       where a.acctno = ln.acctno
             and ln.oprinnml + ln.oprinovd + ln.ointnmlacr +
                 ln.ointnmlovd + ln.ointovdacr + ln.ointdue <> 0;


    -- Xu ly dac biet LNMAST
    update LNMAST
        set actype='0003',
            prinperiod =90,
            rate1 = 13,
            rate2 = 13,
            rate3 = 19.5,
            rlsamt = orlsamt,
            orlsamt =0 ,
            prinnml = oprinnml+oprinovd,
            oprinnml =0,
            oprinovd =0,
            intnmlacr = round((getcurrdate - rlsdate) * (oprinnml+oprinovd) * 13/100/360,0)
    where acctno ='0001261216000001';
    -- Xu ly dac biet LNMAST
    Update lnschd
        set reftype ='P',
            nml = ovd,
            ovd= 0,
            duests='N',
            exdays = 90,
            overduedate = '26/03/2017',
            intnmlacr = round((getcurrdate - rlsdate) * ovd * 13/100/360,0),
            accrualsamt = round((getcurrdate - rlsdate) * ovd * 13/100/360,0),
            rate1=13,
            rate2=13,
            rate3=19.5
    where acctno ='0001261216000001';

    Delete from lninttran where acctno='0001261216000001';
    INSERT into lninttran(autoid, txnum, txdate, acctno, inttype, frdate,
       todate, icrule, irrate, intbal, intamt, cfirrate,
       feeintamt, deltd, lnschdid, accrualsamt)
    SELECT seq_lninttran.nextval autoid, '' txnum, '' txdate, a.acctno, 'P' inttype, a.rlsdate frdate,
           getcurrdate todate, 'S' icrule, a.rate1 irrate, a.nml intbal, a.intnmlacr intamt, 0 cfirrate,
           0 feeintamt, 'N' deltd, a.autoid lnschdid, a.intnmlacr accrualsamt
    FROM lnschd a
    where acctno ='0001261216000001';

    -- End
    INSERT INTO lnschdloghist (autoid, txnum, txdate, nml, ovd, paid, intnmlacr,
       fee, intdue, intovd, intovdprin, feedue, feeovd,
       intpaid, feepaid, feepaid2, feeintnmlacr, feeintdue,
       feeintovd, feeintovdprin, feeintpaid, nmlfeeint,
       ovdfeeint, paidfeeint, deltd, refautoid, lastpaid,
       accrualsamt)
    SELECT a.autoid, '' txnum, getcurrdate txdate, a.nml, a.ovd, a.paid, a.intnmlacr,
        a.fee, a.intdue, a.intovd, a.intovdprin, a.feedue, a.feeovd,
        a.intpaid, a.feepaid, a.feepaid2, a.feeintnmlacr, a.feeintdue,
        a.feeintovd, 0 feeintovdprin, a.feeintpaid, a.nmlfeeint,
        a.ovdfeeint, a.paidfeeint, 'Y' deltd, a.refautoid, '' lastpaid,
        a.accrualsamt
   FROM lnschd A WHERE not EXISTS (SELECT * FROM lnschdloghist LOG WHERE A.AUTOID = LOG.AUTOID);


    EXECUTE IMMEDIATE('ANALYZE TABLE LNMAST COMPUTE STATISTICS');
    EXECUTE IMMEDIATE('ANALYZE TABLE LNMASTHIST COMPUTE STATISTICS');
    EXECUTE IMMEDIATE('ANALYZE TABLE LNSCHD COMPUTE STATISTICS');
    EXECUTE IMMEDIATE('ANALYZE TABLE LNSCHDHIST COMPUTE STATISTICS');

    For rec in
    (
      select mst.*, '9990' || lpad(seq_CVtxnum.nextval,6,'0') txnum
      from (select ls.acctno, ln.trfacctno,
                  sum(case when ls.reftype = 'P' then ls.nml else 0 end) prinnml,
                  sum(case when ls.reftype = 'P' then ls.ovd else 0 end) prinovd,
                  sum(case when ls.reftype = 'P' then ls.intnmlacr else 0 end) intnmlacr,
                  sum(case when ls.reftype = 'P' then ls.intdue else 0 end) intdue,
                  sum(case when ls.reftype = 'P' then ls.intovdprin else 0 end) intovdacr,
                  sum(case when ls.reftype = 'P' then ls.intovd else 0 end) intnmlovd,
                  sum(case when ls.reftype = 'P' then ls.paid else 0 end) paidamt,

                  sum(case when ls.reftype = 'GP' then ls.nml else 0 end) oprinnml,
                  sum(case when ls.reftype = 'GP' then ls.ovd else 0 end) oprinovd,
                  sum(case when ls.reftype = 'GP' then ls.intnmlacr else 0 end) ointnmlacr,
                  sum(case when ls.reftype = 'GP' then ls.intdue else 0 end) ointdue,
                  sum(case when ls.reftype = 'GP' then ls.intovdprin else 0 end) ointovdacr,
                  sum(case when ls.reftype = 'GP' then ls.intovd else 0 end) ointnmlovd,
                  sum(case when ls.reftype = 'GP' then ls.paid else 0 end) opaidamt
              from lnschd ls, lnmast ln
              where ls.reftype in ('P','GP') and ln.acctno = ls.acctno and ln.ftype = 'AF'
              group by ls.acctno, ln.trfacctno
              having sum(ls.nml) + sum(ls.ovd) + sum(ls.paid)
                    + sum(ls.intnmlacr) +  sum(ls.intdue)
                    + sum(ls.intovdprin) + sum(ls.intovd) >0
            ) mst
    )
    Loop
      update lnmast
          set rlsamt = rlsamt + rec.paidamt + rec.prinnml + rec.prinovd,
          orlsamt = orlsamt + rec.opaidamt + rec.oprinnml + rec.oprinovd,
          prinpaid = prinpaid + rec.paidamt,
          prinnml = rec.prinnml,
          prinovd = rec.prinovd,
          intnmlacr= rec.intnmlacr,
          intdue = rec.intdue,
          intovdacr = rec.intovdacr,
          intnmlovd = rec.intnmlovd,
          oprinpaid = oprinpaid + rec.opaidamt,
          oprinnml = rec.oprinnml,
          oprinovd = rec.oprinovd,
          ointnmlacr= rec.ointnmlacr,
          ointdue = rec.ointdue,
          ointovdacr = rec.ointovdacr,
          ointnmlovd = rec.ointnmlovd
      where acctno = rec.acctno;
        -- PRINNML
        if rec.prinnml > 0 then
          INSERT INTO lntrana (AUTOID,TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,REF,DELTD,ACCTREF,TLTXCD,BKDATE,TRDESC)
          VALUES(seq_lntran.nextval,rec.txnum,l_prevdate,rec.acctno,'0016',rec.prinnml,NULL,rec.trfacctno,'N',rec.trfacctno,null,l_prevdate,NULL);
        end if;
        -- OPRINNML
        if rec.OPRINNML > 0 then
          INSERT INTO lntrana (AUTOID,TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,REF,DELTD,ACCTREF,TLTXCD,BKDATE,TRDESC)
          VALUES(seq_lntran.nextval,rec.txnum,l_prevdate,rec.acctno,'0053',rec.OPRINNML,NULL,rec.trfacctno,'N',rec.trfacctno,null,l_prevdate,NULL);
        end if;
        -- PRINOVD
        if rec.prinovd > 0 then
          INSERT INTO lntrana (AUTOID,TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,REF,DELTD,ACCTREF,TLTXCD,BKDATE,TRDESC)
          VALUES(seq_lntran.nextval,rec.txnum,l_prevdate,rec.acctno,'0018',rec.prinovd,NULL,rec.trfacctno,'N',rec.trfacctno,null,l_prevdate,NULL);
        end if;
        -- OPRINOVD
        if rec.OPRINOVD > 0 then
          INSERT INTO lntrana (AUTOID,TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,REF,DELTD,ACCTREF,TLTXCD,BKDATE,TRDESC)
          VALUES(seq_lntran.nextval,rec.txnum,l_prevdate,rec.acctno,'0061',rec.OPRINOVD,NULL,rec.trfacctno,'N',rec.trfacctno,null,l_prevdate,NULL);
        end if;
        -- INTNMLACR
        if rec.intnmlacr > 0 then
          INSERT INTO lntrana (AUTOID,TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,REF,DELTD,ACCTREF,TLTXCD,BKDATE,TRDESC)
          VALUES(seq_lntran.nextval,rec.txnum,l_prevdate,rec.acctno,'0042',rec.intnmlacr,NULL,rec.trfacctno,'N',rec.trfacctno,null,l_prevdate,NULL);
        end if;
        -- OINTNMLACR
        if rec.OINTNMLACR > 0 then
          INSERT INTO lntrana (AUTOID,TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,REF,DELTD,ACCTREF,TLTXCD,BKDATE,TRDESC)
          VALUES(seq_lntran.nextval,rec.txnum,l_prevdate,rec.acctno,'0055',rec.OINTNMLACR,NULL,rec.trfacctno,'N',rec.trfacctno,null,l_prevdate,NULL);
        end if;
        -- INTDUE
        if rec.intdue > 0 then
          INSERT INTO lntrana (AUTOID,TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,REF,DELTD,ACCTREF,TLTXCD,BKDATE,TRDESC)
          VALUES(seq_lntran.nextval,rec.txnum,l_prevdate,rec.acctno,'0026',rec.intdue,NULL,rec.trfacctno,'N',rec.trfacctno,null,l_prevdate,NULL);
        end if;
        -- OINTDUE
        if rec.OINTDUE > 0 then
          INSERT INTO lntrana (AUTOID,TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,REF,DELTD,ACCTREF,TLTXCD,BKDATE,TRDESC)
          VALUES(seq_lntran.nextval,rec.txnum,l_prevdate,rec.acctno,'0057',rec.OINTDUE,NULL,rec.trfacctno,'N',rec.trfacctno,null,l_prevdate,NULL);
        end if;
        -- INTNMLOVD
        if rec.intnmlovd > 0 then
          INSERT INTO lntrana (AUTOID,TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,REF,DELTD,ACCTREF,TLTXCD,BKDATE,TRDESC)
          VALUES(seq_lntran.nextval,rec.txnum,l_prevdate,rec.acctno,'0028',rec.intnmlovd,NULL,rec.trfacctno,'N',rec.trfacctno,null,l_prevdate,NULL);
        end if;
        -- OINTNMLOVD
        if rec.OINTNMLOVD > 0 then
          INSERT INTO lntrana (AUTOID,TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,REF,DELTD,ACCTREF,TLTXCD,BKDATE,TRDESC)
          VALUES(seq_lntran.nextval,rec.txnum,l_prevdate,rec.acctno,'0059',rec.OINTNMLOVD,NULL,rec.trfacctno,'N',rec.trfacctno,null,l_prevdate,NULL);
        end if;
        -- INTOVDACR
        if rec.intovdacr > 0 then
          INSERT INTO lntrana (AUTOID,TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,REF,DELTD,ACCTREF,TLTXCD,BKDATE,TRDESC)
          VALUES(seq_lntran.nextval,rec.txnum,l_prevdate,rec.acctno,'0044',rec.intovdacr,NULL,rec.trfacctno,'N',rec.trfacctno,null,l_prevdate,NULL);
        end if;
        -- OINTOVDACR
        if rec.OINTOVDACR > 0 then
          INSERT INTO lntrana (AUTOID,TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,REF,DELTD,ACCTREF,TLTXCD,BKDATE,TRDESC)
          VALUES(seq_lntran.nextval,rec.txnum,l_prevdate,rec.acctno,'0063',rec.OINTOVDACR,NULL,rec.trfacctno,'N',rec.trfacctno,null,l_prevdate,NULL);
        end if;

        -- PRINPAID
        if rec.paidamt > 0 then
          INSERT INTO lntrana (AUTOID,TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,REF,DELTD,ACCTREF,TLTXCD,BKDATE,TRDESC)
          VALUES(seq_lntran.nextval,rec.txnum,l_prevdate,rec.acctno,'0014',rec.paidamt,NULL,rec.trfacctno,'N',rec.trfacctno,null,l_prevdate,NULL);
        end if;
        -- OPRINPAID
        if rec.opaidamt > 0 then
          INSERT INTO lntrana (AUTOID,TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,REF,DELTD,ACCTREF,TLTXCD,BKDATE,TRDESC)
          VALUES(seq_lntran.nextval,rec.txnum,l_prevdate,rec.acctno,'0065',rec.opaidamt,NULL,rec.trfacctno,'N',rec.trfacctno,null,l_prevdate,NULL);
        end if;

    end loop;



    InsertConvertLog('I','End lntran');
    SELECT MAX(AUTOID) + 1 INTO v_max_autoid FROM vw_lnschd_all;
    RESET_SEQUENCE(SEQ_NAME => 'seq_lnschd', STARTVALUE => v_max_autoid);
    SELECT MAX(AUTOID) + 1 INTO v_max_autoid FROM vw_lntran_all;
    RESET_SEQUENCE(SEQ_NAME => 'seq_tran', STARTVALUE => v_max_autoid);
    SELECT MAX(AUTOID) + 1 INTO v_max_autoid FROM lninttran;
    RESET_SEQUENCE(SEQ_NAME => 'seq_lninttran', STARTVALUE => v_max_autoid);


    EXECUTE IMMEDIATE('ANALYZE TABLE LNTRANA COMPUTE STATISTICS');
    EXECUTE IMMEDIATE('ANALYZE TABLE LNTRAN COMPUTE STATISTICS');

    UPDATE CIMAST SET ODAMT=0,ovamt=0,dueamt=0 ;

    -- QUA HAN
    FOR REC IN (
        SELECT SUM(intnmlovd) intnmlovd,
               SUM(prinovd) prinovd ,
               SUM(NVL(intovdacr,0)) intovdacr,
               SUM( NVL(prinnml,0) + NVL(prinovd,0)+ NVL(intnmlacr,0)+ NVL(intovdacr,0)+ NVL(intnmlovd,0)+ NVL(intdue,0) ) AMT ,
               sum(nvl(oprinnml,0)) oprinnml,
               sum(nvl(oprinovd,0)) oprinovd,
               TRFACCTNO
        FROM LNMAST
        WHERE  NVL(prinnml,0) + NVL(prinovd,0) + NVL(intnmlacr,0) + NVL(intovdacr,0)
               + NVL(intnmlovd,0) + NVL(intdue,0) + nvl(oprinnml,0) + nvl(oprinovd,0) + NVL(intovdacr,0)  >0
        GROUP BY TRFACCTNO
    )
    LOOP

        UPDATE CIMAST
            SET ODAMT = ODAMT + ROUND(REC.AMT) + round(rec.oprinnml),
                ovamt = ovamt + round(rec.oprinnml) + round(rec.oprinovd)
                              + ROUND (REC.prinovd) + ROUND(REC.intnmlovd)+ ROUND(REC.intovdacr)

        WHERE ACCTNO = REC.TRFACCTNO ;
    END LOOP;

    -- DEN HAN
    FOR rec IN (
        SELECT ln.trfacctno, sum (lns.nml) nml
        FROM LNSCHD lns, lnmast ln
        WHERE   lns.overduedate   = v_currdate and lns.acctno =ln.acctno  group by trfacctno
    )
    LOOP
        UPDATE CIMAST SET dueamt = dueamt + rec.nml
        WHERE ACCTNO = REC.TRFACCTNO;
    END loop;


    /*FOR REC IN (
        SELECT LN.ACCTNO, AFTYPE.LNTYPE , aftype.t0lntype
        FROM LNMAST LN , AFMAST AF, AFTYPE
        WHERE LN.TRFACCTNO = AF.ACCTNO AND
        AF.ACTYPE = AFTYPE.ACTYPE
    )
    LOOP
        UPDATE LNMAST SET ACTYPE = REC.LNTYPE WHERE ACCTNO = REC.ACCTNO;
    END LOOP;*/

    UPDATE lnschd SET  INTOVDDUEDATE = v_currdate  where overduedate = v_currdate AND reftype ='P';

    For i in (select * from lntype)
        Loop
               UPDATE lnmast
               SET LNTYPE = i.LNTYPE,
                   LNCLDR = i.LNCLDR,
                   PRINFRQ = i.PRINFRQ,
                   PRINPERIOD = i.PRINPERIOD,
                   INTFRGCD = i.INTFRQCD,
                   INTDAY = i.INTDAY,
                   INTPERIOD = i.INTPERIOD,
                   NINTCD = i.NINTCD,
                   OINTCD = i.OINTCD,
                   RATE1 = i.RATE1,
                   RATE2 = i.RATE2,
                   RATE3 = i.RATE3,
                   OPRINFRQ = i.OPRINFRQ,
                   OPRINPERIOD = i.OPRINPERIOD,
                   OINTFRQCD = i.OINTFRQCD,
                   OINTDAY = i.OINTDAY,
                   ORATE1 = i.ORATE1,
                   ORATE2 = i.ORATE2,
                   ORATE3 = i.ORATE3,
                   DRATE = i.DRATE,
                   ADVPAY = i.ADVPAY,
                   AUTOAPPLY = i.AUTOAPPLY,
                   PREPAID = i.PREPAID,
                   ADVPAYFEE = i.ADVPAYFEE,
                   MINTERM= i.MINTERM,
                   CFRATE1=i.CFRATE1,
                   CFRATE2=i.CFRATE2,
                   CFRATE3=i.CFRATE3,
                   INTOVDCD = i.INTOVDCD,
                   BANKPAIDMETHOD=i.bankpaidmethod
                WHERE lnmast.actype = i.actype ; -- cap nhat cac hop dong autoappy in  ('A','N')
                Commit;
        End loop;

    InsertConvertLog('I','End lnmastcv....');

EXCEPTION
    WHEN OTHERS THEN
        InsertConvertLog('E','cfauthcv, '
                               ||sqlerrm || '.At:' || dbms_utility.format_error_backtrace);

END;

PROCEDURE userlogincv  IS

v_currdate varchar2(50);
v_prevdate varchar2(50);
v_nextdate varchar2(50);
L_USERPASS      VARCHAR2(50);
L_NEWPIN      VARCHAR2(50);
L_TEMPLATEID    VARCHAR2(50);
L_DATASOURCESQL VARCHAR2(1000);
L_EMAIL         VARCHAR2(250);
L_MOBILESMS     VARCHAR2(250);
L_DATASOURCESMS VARCHAR2(1000);
BEGIN

InsertConvertLog('I','Begin convert userlogin....');

DELETE OTRIGHT;
DELETE OTRIGHTDTL;
DELETE FROM USERLOGIN;
DELETE FROM EMAILLOG;

COMMIT;

RESET_SEQUENCE(SEQ_NAME => 'SEQ_EMAILLOG', STARTVALUE => 1);
RESET_SEQUENCE(SEQ_NAME => 'seq_otright', STARTVALUE => 1);
RESET_SEQUENCE(SEQ_NAME => 'seq_otrightdtl', STARTVALUE => 1);
v_currdate := getcurrdate;

BEGIN

    Update CFMAST set TRADEONLINE='N', USERNAME ='';

    FOR REC IN (
        SELECT CF.CUSTID, CF.FULLNAME, CF.CUSTODYCD, CF.CUSTODYCD USERNAME, CF.TRADEONLINE ISONLINE, CF.EMAIL
        FROM CFMAST CF, t_user_online mst
        WHERE cf.CUSTODYCD= mst.username AND CF.CUSTODYCD IS NOT NULL
    )
    LOOP

        L_EMAIL := rec.email;
        L_TEMPLATEID := '213B';
        L_USERPASS := cspks_system.fn_passwordgenerator('8');
        L_NEWPIN := cspks_system.fn_passwordgenerator('8');
        L_DATASOURCESQL := 'select ''' || rec.custodycd || ''' custodycd, ''' ||
                                                 rec.FULLNAME || ''' fullname, '''
                                                 || rec.USERNAME ||''' username, '''
                                                 || L_USERPASS ||''' loginpwd, ''' || L_NEWPIN ||
                                                 ''' tradingpwd from dual';

        Update CFMAST set TRADEONLINE='Y', USERNAME = REC.USERNAME where CUSTID = REC.CUSTID;



            INSERT INTO OTRIGHT (AUTOID,CFCUSTID,AUTHCUSTID,AUTHTYPE,VALDATE,EXPDATE,DELTD,LASTDATE,LASTCHANGE,SERIALTOKEN)
            VALUES(seq_otright.NEXTVAL,REC.CUSTID,REC.CUSTID,'1',v_currdate ,getcurrdate + 36000,'N',sysdate,sysdate,NULL);


            INSERT INTO otrightDTL (AUTOID,CFCUSTID,AUTHCUSTID,OTMNCODE,OTRIGHT,DELTD)
            VALUES(seq_otrightdtl.NEXTVAL,REC.CUSTID,REC.CUSTID,'STOCKTRANS','YYYYYNY','N');
            INSERT INTO otrightDTL (AUTOID,CFCUSTID,AUTHCUSTID,OTMNCODE,OTRIGHT,DELTD)
            VALUES(seq_otrightdtl.NEXTVAL,REC.CUSTID,REC.CUSTID,'GROUP_ORDER','YYYYYNY','N');
            INSERT INTO otrightDTL (AUTOID,CFCUSTID,AUTHCUSTID,OTMNCODE,OTRIGHT,DELTD)
            VALUES(seq_otrightdtl.NEXTVAL,REC.CUSTID,REC.CUSTID,'ADWINPUT','YYYYYNY','N');
            INSERT INTO otrightDTL (AUTOID,CFCUSTID,AUTHCUSTID,OTMNCODE,OTRIGHT,DELTD)
            VALUES(seq_otrightdtl.NEXTVAL,REC.CUSTID,REC.CUSTID,'RESETPASS','YYYYYNY','N');
            INSERT INTO otrightDTL (AUTOID,CFCUSTID,AUTHCUSTID,OTMNCODE,OTRIGHT,DELTD)
            VALUES(seq_otrightdtl.NEXTVAL,REC.CUSTID,REC.CUSTID,'ISSUEINPUT','YYYYYNY','N');
            INSERT INTO otrightDTL (AUTOID,CFCUSTID,AUTHCUSTID,OTMNCODE,OTRIGHT,DELTD)
            VALUES(seq_otrightdtl.NEXTVAL,REC.CUSTID,REC.CUSTID,'COND_ORDER','YYYYYNY','N');
            INSERT INTO otrightDTL (AUTOID,CFCUSTID,AUTHCUSTID,OTMNCODE,OTRIGHT,DELTD)
            VALUES(seq_otrightdtl.NEXTVAL,REC.CUSTID,REC.CUSTID,'ORDINPUT','YYYYYNY','N');
            INSERT INTO otrightDTL (AUTOID,CFCUSTID,AUTHCUSTID,OTMNCODE,OTRIGHT,DELTD)
            VALUES(seq_otrightdtl.NEXTVAL,REC.CUSTID,REC.CUSTID,'DEPOSIT','YYYYYNY','N');
            INSERT INTO otrightDTL (AUTOID,CFCUSTID,AUTHCUSTID,OTMNCODE,OTRIGHT,DELTD)
            VALUES(seq_otrightdtl.NEXTVAL,REC.CUSTID,REC.CUSTID,'CASHTRANSENDDATE','YYYYYNY','N');
            INSERT INTO otrightDTL (AUTOID,CFCUSTID,AUTHCUSTID,OTMNCODE,OTRIGHT,DELTD)
            VALUES(seq_otrightdtl.NEXTVAL,REC.CUSTID,REC.CUSTID,'CASHTRANS','YYYYNYY','N');

            insert into USERLOGIN (USERNAME, AUTHTYPE, STATUS, LOGINSTATUS, LASTCHANGED, NUMBEROFDAY,  LASTLOGIN, ISRESET, ISMASTER)
            values (REC.USERNAME,  '1', 'A', 'O', v_currdate, 360, v_currdate, 'Y', 'N');

            UPDATE USERLOGIN
                   SET ISRESET     = 'Y',
                                 ISMASTER    = 'N',
                                 NUMBEROFDAY = 360,
                                 LOGINPWD    = GENENCRYPTPASSWORD(UPPER(L_USERPASS)),
                                 AUTHTYPE    = '1',
                                 TRADINGPWD  = GENENCRYPTPASSWORD(UPPER(L_NEWPIN))
                     WHERE UPPER(USERNAME) = rec.USERNAME;

        BEGIN
            SELECT MOBILESMS
                INTO L_MOBILESMS
                FROM VW_CFMAST_SMS
             WHERE CUSTID = REC.CUSTID;
        EXCEPTION
            WHEN OTHERS THEN
                L_MOBILESMS := '';
        END;

        if nmpks_ems.CheckEmail(l_email) then
            INSERT INTO EMAILLOG (AUTOID, EMAIL, TEMPLATEID, DATASOURCE, STATUS, CREATETIME)
            VALUES (SEQ_EMAILLOG.NEXTVAL, L_EMAIL, L_TEMPLATEID, L_DATASOURCESQL, 'A', SYSDATE);
        End if;

        IF length(TRIM(l_mobilesms)) > 0 THEN
            L_DATASOURCESMS := 'select ''' || rec.USERNAME || ''' username, ''' ||
                                                 L_USERPASS || ''' loginpwd, ''' || L_NEWPIN ||
                                                 ''' tradingpwd from dual';
            INSERT INTO EMAILLOG (AUTOID, EMAIL, TEMPLATEID, DATASOURCE, STATUS, CREATETIME)
            VALUES (SEQ_EMAILLOG.NEXTVAL, L_MOBILESMS, '304A', L_DATASOURCESMS, 'A', SYSDATE);
        END IF;

    END LOOP;
END ;


InsertConvertLog('I','End convert userlogin....');

EXCEPTION
    WHEN OTHERS THEN
     InsertConvertLog('E','userlogincv, '
                               ||sqlerrm || '.At:' || dbms_utility.format_error_backtrace);

END;

PROCEDURE endconvert  IS

v_currdate date;
v_prevdate date;
v_nextdate date;
v_t_1_date date;
v_t_2_date date;
v_t_3_date date;

BEGIN

    select to_date(varvalue,'DD/MM/RRRR') into v_currdate from sysvar where grname ='SYSTEM' and varname ='CURRDATE';
    select to_date(varvalue,'DD/MM/RRRR') into v_prevdate from sysvar where grname ='SYSTEM' and varname ='PREVDATE';
    select to_date(varvalue,'DD/MM/RRRR') into v_nextdate from sysvar where grname ='SYSTEM' and varname ='NEXTDATE';
    v_t_1_date:=get_t_date(v_currdate,1);
    v_t_2_date:=get_t_date(v_currdate,2);
    v_t_3_date:=get_t_date(v_currdate,3);

    InsertConvertLog('I','Begin endconvert...');
    update  AFDFBASKET set autoid = seq_AFDFBASKET.nextval ;
    update  AFIDTYPE set autoid = seq_AFIDTYPE.nextval ;
    update  BRGRPPARAM set autoid = seq_BRGRPPARAM.nextval ;
    update  BRIDTYPE set autoid = seq_BRIDTYPE.nextval ;
    update  BUSTXLOG set autoid = seq_BUSTXLOG.nextval ;
    update  CRBDEFACCT set autoid = seq_CRBDEFACCT.nextval ;
    update  CRBDEFBANK set autoid = seq_CRBDEFBANK.nextval ;
    update  DFBASKET set autoid = seq_DFBASKET.nextval ;
    update  EMAILLOG set autoid = seq_EMAILLOG.nextval ;
    update  FEEMAP set autoid = seq_FEEMAP.nextval ;
    update  GLMAP set autoid = seq_GLMAP.nextval ;
    update  ICCFTIER set autoid = seq_ICCFTIER.nextval ;
    update  ICCFTYPEDEF set autoid = seq_ICCFTYPEDEF.nextval ;
    update  ISSUER_MEMBER set autoid = seq_ISSUER_MEMBER.nextval ;
    update  LNDD set autoid = seq_LNDD.nextval ;
    update  OTRIGHT set autoid = seq_OTRIGHT.nextval ;
    update  OTRIGHTDTL set autoid = seq_OTRIGHTDTL.nextval ;
    update  PRTYPEMAP set autoid = seq_PRTYPEMAP.nextval ;
    update  RECONCILE set autoid = seq_RECONCILE.nextval ;
    update  REGTYPE set autoid = seq_REGTYPE.nextval ;
    update  SBCLDR set autoid = seq_SBCLDR.nextval ;
    update  SBFXRT set autoid = seq_SBFXRT.nextval ;
    update  SECBASKET set autoid = seq_SECBASKET.nextval ;
    update  SECURITIES_INFO set autoid = seq_SECURITIES_INFO.nextval ;
    update  SECURITIES_RATE set autoid = seq_SECURITIES_RATE.nextval ;
    update  SECURITIES_TICKSIZE set autoid = seq_SECURITIES_TICKSIZE.nextval ;
    update  SECURITIES_RATE set autoid = seq_SECURITIES_RATE.nextval ;
    update  SMSMATCHED set autoid = seq_SMSMATCHED.nextval ;
    update  STCSE set autoid = seq_STCSE.nextval ;
    update  TLAUTH set autoid = seq_TLAUTH.nextval ;
    update  TLGRPAFTYPE set autoid = seq_TLGRPAFTYPE.nextval ;
    update  TLGRPUSERS set autoid = seq_TLGRPUSERS.nextval ;
    update  TXDESC set autoid = seq_TXDESC.nextval ;
    update  TYPEIDMAP set autoid = seq_TYPEIDMAP.nextval ;
    update  lnsebasket set autoid = seq_lnsebasket.nextval ;
    UPDATE ODPROBRKAF SET AUTOID = SEQ_ODPROBRKAF.NEXTVAL ;
    UPDATE cifeedef_extlnk SET AUTOID = SEQ_cifeedef_extlnk.NEXTVAL ;
    UPDATE ODPROBRKAF SET AUTOID = SEQ_ODPROBRKAF.NEXTVAL ;
    update  cmdauth set autoid = seq_TLAUTH.nextval ;
    update glrules set autoid = seq_glrules.nextval ;
    update txmapglrules set autoid =seq_txmapglrules.nextval ;

    UPDATE securities_info
        SET margincallprice = basicprice,
            dfrefprice = basicprice,
            dfrlsprice = basicprice,
            marginprice = basicprice,
            marginrefprice = basicprice,marginrefcallprice = basicprice;

    COMMIT;


    Update cfmast cf
       set careby ='9999',
           tlid ='0001',
           last_ofid ='0001',
           brid ='0001',
           cf.approveid='0001',
           cf.NSDSTATUS ='C',
           cf.pstatus ='P',
           cf.country = nvl(cf.country,'234'),
           cf.last_change = sysdate,
           cf.lastdate = nvl(cf.lastdate, v_prevdate),
           cf.SEX = case when trim(SEX) not in ('001','002') then '000' else SEX end,
           cf.CUSTTYPE = trim(CUSTTYPE);

    Update cfmast set IDTYPE ='010' where IDTYPE ='004';
    Update afmast set careby ='9999';
    update cfmast set pin ='1234' where cfmast.tradetelephone='Y';


    FOR REC IN (SELECT ACCTNO,STATUS FROM AFMAST)
    LOOP
        update cimast set status= rec.status where acctno = rec.acctno;
        update semast set status= rec.status where afacctno = rec.acctno;
    end loop;

    COMMIT;

    DBMS_UTILITY.EXEC_DDL_STATEMENT('TRUNCATE TABLE SECMAST');
    FOR REC IN
     (
        SELECT MST.AFACCTNO,SEIF.CODEID ,
         (MST.TRADE + MST.MARGIN + MST.BLOCKWITHDRAW + MST.EMKQTTY + MST.BLOCKDTOCLOSE + MST.WTRADE
             + MST.MORTAGE + MST.BLOCKED + MST.SECURED + MST.REPO + MST.NETTING+ MST.DTOCLOSE
             + MST.WITHDRAW+ MST.RECEIVING+MST.DEPOSIT+MST.SENDDEPOSIT ) QTTY, SEIF.BASICPRICE
        FROM semast MST,  securities_info SEIF
        WHERE MST.CODEID = SEIF.CODEID
              AND (MST.TRADE + MST.MARGIN + MST.BLOCKWITHDRAW + MST.EMKQTTY + MST.BLOCKDTOCLOSE + MST.WTRADE
                     + MST.MORTAGE + MST.BLOCKED + MST.SECURED + MST.REPO
                     + MST.NETTING+ MST.DTOCLOSE+MST.WITHDRAW+
                     MST.RECEIVING+MST.deposit+MST.senddeposit )>0
      )
    LOOP
        secmast_CV(to_char(getcurrdate,'DD/MM/RRRR'),rec.afacctno,REC.CODEID,REC.QTTY,REC.basicprice);
    END LOOP;

    COMMIT;

    -- Sinh nhom 1
    Delete from tlgroups where GRPID='9999';
    insert into tlgroups (GRPID, GRPNAME, GRPTYPE, GRPRIGHT, ACTIVE, DESCRIPTION, PRGRPID, SHORTNAME, BRID, BRIDGL)
    values ('9999', 'Care by All System', '2', 'NNNNN', 'Y', null, 'P000', null, '0001', '0001');


    Delete from TLGRPUSERS where GRPID='9999';

    insert into TLGRPUSERS (AUTOID, GRPID, BRID, TLID, DESCRIPTION)
    select seq_tlgrpusers.nextval, '9999', brid, tlid, ''
    from tlprofiles where brid ='0001';


update PRMASTER SET PRINUSED=0;
COMMIT;

DECLARE
  p_acctno VARCHAR2(10);
  L_BRID   VARCHAR2(10);
  L_ACTYPE VARCHAR2(10);

BEGIN
  FOR REC_CI IN (
    SELECT SUM(NML+OVD) AMT,TRFACCTNO AFACCTNO
    FROM LNSCHD SCHD, LNMAST MST
    WHERE SCHD.ACCTNO=MST.ACCTNO AND SCHD.REFTYPE='P' AND MST.FTYPE ='AF'
    GROUP BY MST.TRFACCTNO
  )
  LOOP
         P_ACCTNO:=REC_CI.AFACCTNO;

         SELECT CF.BRID, AF.ACTYPE
            INTO L_BRID, L_ACTYPE
         FROM CFMAST CF, AFMAST AF
         WHERE CF.CUSTID=AF.CUSTID AND AF.ACCTNO=P_ACCTNO;

         -- pool
         FOR REC_PR IN (
            SELECT * FROM
            -- Pool dac biet cho tieu khoan
            (
                SELECT DISTINCT PM.PRCODE,PM.PRNAME,PM.PRTYP,PM.CODEID,PM.PRLIMIT,PM.PRINUSED+0 prinused,
                       PM.EXPIREDDT,PM.PRSTATUS, 1 ODR
                FROM PRMASTER PM
                WHERE PM.POOLTYPE='AF' AND PM.AFACCTNO=p_acctno
                      AND PM.PRSTATUS='A' AND PM.PRTYP='P'
                UNION ALL-- Pool dac biet cho danh sach khach hang
                SELECT DISTINCT PM.PRCODE,PM.PRNAME,PM.PRTYP,PM.CODEID,PM.PRLIMIT,PM.PRINUSED+ 0 prinused,
                       PM.EXPIREDDT,PM.PRSTATUS, 2 ODR
                FROM PRMASTER PM,PRAFMAP PRM
                WHERE PM.POOLTYPE='GR' AND PM.PRCODE=PRM.PRCODE AND PRM.AFACCTNO=p_acctno
                      AND PM.PRSTATUS='A' AND PM.PRTYP='P'
                UNION ALL-- Pool cho nhom loai hinh khach hang
                SELECT DISTINCT PM.PRCODE,PM.PRNAME,PM.PRTYP,PM.CODEID,PM.PRLIMIT,PM.PRINUSED+ 0 prinused,
                       PM.EXPIREDDT,PM.PRSTATUS, 3 ODR
                FROM PRMASTER PM, PRTYPEMAP PRTM, BRIDMAP BRM
                WHERE PM.PRCODE=BRM.PRCODE
                      AND PM.PRCODE = PRTM.PRCODE
                      AND PM.PRSTATUS = 'A'
                      AND PRTM.PRTYPE=DECODE(PRTM.PRTYPE,'ALL',PRTM.PRTYPE,L_ACTYPE)
                      AND BRM.BRID = DECODE(BRM.BRID,'ALL',BRM.BRID,L_BRID)
                      AND PM.PRTYP='P'
                      AND PM.POOLTYPE='TY'
                UNION ALL
                --PooL he thong
                SELECT DISTINCT PM.PRCODE,PM.PRNAME,PM.PRTYP,PM.CODEID,PM.PRLIMIT,PM.PRINUSED+ 0 prinused,
                       PM. EXPIREDDT,PM.PRSTATUS, 3 ODR
                FROM PRMASTER PM
                WHERE  PM.POOLTYPE='SY' AND PM.PRSTATUS='A' AND PM.PRTYP='P'
              )
            WHERE odr=
            ( SELECT  min(odr)
                FROM
                        -- Pool dac biet cho tieu khoan
                        (
                            SELECT DISTINCT PM.PRCODE,PM.PRNAME,PM.PRTYP,PM.CODEID,PM.PRLIMIT,PM.PRINUSED+ 0 prinused,
                                  PM.EXPIREDDT,PM.PRSTATUS, 1 ODR
                            FROM PRMASTER PM
                            WHERE PM.POOLTYPE='AF' AND PM.AFACCTNO=p_acctno
                                  AND PM.prstatus='A' and PM.prtyp='P'
                            UNION ALL-- Pool dac biet cho danh sach khach hang
                            SELECT DISTINCT PM.PRCODE,PM.PRNAME,PM.PRTYP,PM.CODEID,PM.PRLIMIT,PM.PRINUSED+ 0 prinused,
                                   PM.EXPIREDDT,PM.PRSTATUS, 2 ODR
                            FROM PRMASTER PM,PRAFMAP PRM
                            WHERE PM.POOLTYPE='GR'
                                  AND PM.PRCODE=PRM.PRCODE AND PRM.AFACCTNO=p_acctno
                                  AND PM.PRSTATUS='A' AND PM.PRTYP='P'
                            UNION ALL-- Pool cho nhom loai hinh khach hang
                            SELECT DISTINCT PM.PRCODE,PM.PRNAME,PM.PRTYP,PM.CODEID,PM.PRLIMIT,PM.PRINUSED+ 0 prinused,
                                PM.EXPIREDDT,PM.PRSTATUS, 3 ODR
                            FROM PRMASTER PM,/*PRTYPE PRT,*/ PRTYPEMAP PRTM,/*TYPEIDMAP TMP, */BRIDMAP BRM
                            WHERE PM.PRCODE=BRM.PRCODE
                                AND pm.prcode = prtm.prcode
                                AND pm.prstatus = 'A'
                                AND PRTM.PRTYPE=DECODE(PRTM.PRTYPE,'ALL',PRTM.PRTYPE,l_actype)
                                AND brm.brid = decode(brm.brid,'ALL',brm.brid,l_brid)
                                and PM.prtyp='P'
                                AND pm.pooltype='TY'
                            UNION ALL
                              --PooL he thong
                            SELECT DISTINCT PM.PRCODE,PM.PRNAME,PM.PRTYP,PM.CODEID,PM.PRLIMIT,PM.PRINUSED+ 0 prinused,
                                PM. EXPIREDDT,PM.PRSTATUS, 3 ODR
                            FROM PRMASTER PM
                            WHERE  PM.POOLTYPE='SY' AND PM.PRSTATUS='A' AND PM.PRTYP='P'
                            )
                )
         )
         LOOP
             UPDATE PRMASTER SET PRINUSED=PRINUSED+REC_CI.AMT WHERE PRCODE=REC_PR.PRCODE;

             INSERT INTO PRTRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
             select '9990' || LPAD(seq_CVtxnum.NEXTVAL,6,'0') txnum, v_prevdate, REC_PR.PRCODE, '0004', REC_CI.AMT,
                    NULL,'N' deltd,'' REF,seq_PRTRAN.NEXTVAL,'',v_prevdate,' CONVERT DATA' FROM DUAL;
         END LOOP;
  END LOOP;
END;
COMMIT;



    InsertConvertLog('I','Begin Gen SE....');
    JBPKS_AUTO.PR_GEN_BUF_SE_ACCOUNT;

    InsertConvertLog('I','Begin Gen OD....');
    JBPKS_AUTO.PR_GEN_BUF_OD_ACCOUNT;

    InsertConvertLog('I','Begin Gen CI....');
    PR_GENCIBUFALL;
    COMMIT;


    InsertConvertLog('I','End convert data....');
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
                InsertConvertLog('E','EndConvert, '
                               ||sqlerrm || '.At:' || dbms_utility.format_error_backtrace);

END;

PROCEDURE pr_AutoOpenNormalAccount(p_CUSTID in varchar2,p_FirstTime in varchar2,p_err_code in out varchar2)
IS
    v_currdate date;
    v_count number;
    l_corebank  char(1);
    l_autoadv   char(1);

    l_aftype varchar2(10);
    l_custid varchar2(20);
    l_afacctno varchar2(20);
    v_busdate   varchar2(20);
    p_tlid varchar2(20);
    p_apptlid varchar2(20);
    l_citype  varchar2(20);

    l_balance number;
    l_isPM varchar2(1);
BEGIN
    p_err_code:= '0';

    v_currdate := getcurrdate;
    v_busdate  := v_currdate;

    --Neu chua co tieu khoan thi mo moi
    for rec in (
         select aft.actype, aft.AFTYPE,aft.corebank,aft.autoadv,aft.citype,aft.k1days,aft.k2days,
                aft.producttype, substr(cf.custodycd,4,1) custype,
                cf.brid,cf.careby,cf.tlid,
                mrt.MRIRATE,mrt.MRMRATE,mrt.MRLRATE,mrt.MRCRLIMIT,
                mrt.MRLMMAX,mrt.mriratio,mrt.mrmratio,mrt.mrlratio,mrt.mrcrate,mrt.mrwrate,mrt.mrexrate,
                nvl(cf.last_ofid,nvl(cf.approveid,cf.tlid)) appid
         from cfmast cf, cfaftype cfaf , aftype aft, mrtype mrt
         where cf.actype = cfaf.cftype and cfaf.aftype = aft.actype
             and aft.mrtype = mrt.actype and mrt.mrtype ='N'
             and cf.custid = p_CUSTID

    )
    loop
        ---- Kiem tra truong hop da co CFMAST nhung chua co AFMAST thi moi sinh
         select count(1) into v_count from afmast where custid = p_CUSTID and actype = rec.actype;

         if v_count =0 then
             l_aftype   :=  rec.AFTYPE;
             l_corebank :=  'N';
             l_autoadv  :=  'N';
             l_custid   :=  p_CUSTID;
             p_tlid     :=  rec.tlid;
             p_apptlid  :=  rec.appid;

             l_balance:=0;
             l_isPM:='N';
             ---- SINH SO AFMAST
             Begin
                SELECT SUBSTR(INVACCT,1,4) || TRIM(TO_CHAR(MAX(ODR)+1,'000000')) into l_afacctno
                FROM
                (
                    SELECT ROWNUM ODR, INVACCT
                    FROM (SELECT ACCTNO INVACCT
                            FROM AFMAST WHERE SUBSTR(ACCTNO,1,4)= trim(rec.brid)
                            ORDER BY ACCTNO
                         ) DAT
                    WHERE TO_NUMBER(SUBSTR(INVACCT,5,6))= ROWNUM
                ) INVTAB
                GROUP BY SUBSTR(INVACCT,1,4);
             Exception when others then
                l_afacctno :=trim(rec.brid) || '000001';
             End;
            --- SINH TAI KHOAN AFMAST
            INSERT INTO AFMAST (ACTYPE,CUSTID,ACCTNO,AFTYPE,
            BANKACCTNO,BANKNAME,STATUS,lastdate,bratio,k1days,k2days,
            ADVANCELINE,DESCRIPTION,ISOTC,PISOTC,OPNDATE,VIA,producttype,
            MRIRATE,MRMRATE,MRLRATE,MRCRLIMIT,MRCRLIMITMAX,
            mriratio,mrmratio,mrlratio,mrcrate,mrwrate,mrexrate,
            T0AMT,BRID,CAREBY,corebank,AUTOADV,TLID,TERMOFUSE,isdebtt0,isPM)
            VALUES(rec.actype,l_custid,l_afacctno,l_aftype, '' ,'---', 'A',TO_DATE( v_busdate ,'DD/MM/RRRR'),100,rec.k1days,rec.k2days,
            0,'','Y','N',TO_DATE( v_busdate ,'DD/MM/RRRR'),'F',rec.producttype,
            rec.MRIRATE,rec.MRMRATE,rec.MRLRATE,rec.MRCRLIMIT,rec.MRLMMAX,
            rec.mriratio,rec.mrmratio,rec.mrlratio,rec.mrcrate,rec.mrwrate,rec.mrexrate,
            0,rec.brid, rec.careby,l_corebank,l_AUTOADV, rec.tlid,'001','N',l_isPM);

            l_citype:= rec.citype;

           -- Sinh tai khoan CI
           /*INSERT INTO CIMAST (ACTYPE,ACCTNO,CCYCD,AFACCTNO,CUSTID,OPNDATE,CLSDATE,LASTDATE,DORMDATE,STATUS,PSTATUS,BALANCE,CRAMT,DRAMT,CRINTACR,CRINTDT,ODINTACR,ODINTDT,AVRBAL,MDEBIT,MCREDIT,AAMT,RAMT,BAMT,EMKAMT,MMARGINBAL,MARGINBAL,ICCFCD,ICCFTIED,ODLIMIT,ADINTACR,ADINTDT,FACRTRADE,FACRDEPOSITORY,FACRMISC,MINBAL,ODAMT,NAMT,FLOATAMT,HOLDBALANCE,PENDINGHOLD,PENDINGUNHOLD,COREBANK,RECEIVING,NETTING,MBLOCK,OVAMT,DUEAMT,T0ODAMT,MBALANCE,MCRINTDT,TRFAMT,LAST_CHANGE,DFODAMT,DFDEBTAMT,DFINTDEBTAMT,CIDEPOFEEACR,DEPOLASTDT)
           VALUES(l_citype,l_afacctno,'00',l_afacctno,l_custid,TO_DATE(v_busdate,'DD/MM/RRRR'),NULL,TO_DATE(v_busdate,'DD/MM/RRRR'),NULL,'A',NULL,l_balance,0,0,0,TO_DATE(v_busdate,'DD/MM/RRRR'),0,TO_DATE(v_busdate,'DD/MM/RRRR'),0,0,0,0,0,0,0,0,0,NULL,'Y',0,0,NULL,0,0,0,0,0,0,0,0,0,0,l_corebank,0,0,0,0,0,0,0,TO_DATE(v_busdate,'DD/MM/RRRR'),0,TO_DATE(v_busdate,'DD/MM/RRRR'),0,0,0,0,( select last_day(trunc(to_date(v_busdate,'DD/MM/RRRR'),'MM')-1)  from dual ));*/
           INSERT INTO cimast (ACTYPE,ACCTNO,CCYCD,AFACCTNO,CUSTID,OPNDATE,CLSDATE,LASTDATE,DORMDATE,STATUS,PSTATUS,BALANCE,CRAMT,DRAMT,CRINTACR,CRINTDT,ODINTACR,ODINTDT,AVRBAL,MDEBIT,MCREDIT,AAMT,RAMT,BAMT,EMKAMT,MMARGINBAL,MARGINBAL,ICCFCD,ICCFTIED,ODLIMIT,ADINTACR,ADINTDT,FACRTRADE,FACRDEPOSITORY,FACRMISC,MINBAL,ODAMT,NAMT,FLOATAMT,HOLDBALANCE,PENDINGHOLD,PENDINGUNHOLD,COREBANK,RECEIVING,NETTING,MBLOCK,OVAMT,DUEAMT,T0ODAMT,MBALANCE,MCRINTDT,TRFAMT,LAST_CHANGE,DFODAMT,DFDEBTAMT,DFINTDEBTAMT,CIDEPOFEEACR,TRFBUYAMT,INTFLOATAMT,FEEFLOATAMT,DEPOLASTDT,DEPOFEEAMT,HOLDMNLAMT,T0OVDAMT,BANKBALANCE,BANKAVLBAL,BANKINQIRYDT,INTBUYAMT,INTCAAMT,BUYSECAMT)
           VALUES(l_citype, l_afacctno,'00',l_afacctno,l_custid,v_currdate,
                    NULL,v_currdate,NULL,'A','AN',0,0,0,0,v_currdate,0,v_currdate,0,0,0,0,0,0,0,0,0,
                    NULL,'Y',0,0,NULL,0,0,0,0,0,0,0,0,0,0,'N',0,0,0,0,0,0,0,
                    TO_DATE('01/12/2016','DD/MM/RRRR'),0,'',0,0,0,0,0,0,0,
                    TO_DATE('31/12/2016','DD/MM/RRRR'),0,0,0,0,0,NULL,0,0,0);


         end if; ---- Kiem tra truong hop da co CFMAST nhung chua co AFMAST thi moi sinh
    end loop;
    p_err_code:='0';
EXCEPTION
   WHEN others THEN
    InsertConvertLog('E','End OTC_CFMASTCV...l_afacctno:=' || l_afacctno || ' ' || SQLERRM || dbms_utility.format_error_backtrace);
      p_err_code:='-1';
   return;
END;

PROCEDURE OTC_CFMASTCV
IS
  -- Enter the procedure variables here. As shown below
 v_busdate DATE;
 v_count NUMBER;
 l_err_code varchar2(30);
 l_err_param varchar2(30);
 p_err_param varchar2(30);
 l_custodycd varchar(10);
 l_tmpcustodycd varchar(10);
 l_custid varchar(10);
 l_afacctno varchar(10);
 l_aftype varchar(3);
 l_citype varchar(4);
 l_corebank varchar(1);
 l_autoadv varchar(1);
 L_STRPASS VARCHAR2(20);
 L_STRPASS2 VARCHAR2(20);
 L_STRidcode VARCHAR2(20);
 l_STRtradingcode VARCHAR2(20);
 v_strCFOTHERACCid number(20);
 p_tlid VARCHAR2(10);
BEGIN

    l_err_code:= systemnums.C_SUCCESS;
    l_err_param:= 'SYSTEM_SUCCESS';
    p_err_param:='SYSTEM_SUCCESS';
    p_tlid := '0001';

    InsertConvertLog('I','Begin OTC_CFMASTCV...');

    DELETE FROM CIMAST MST
        WHERE EXISTS (SELECT * FROM CFMAST CF WHERE CUSTODYCD LIKE 'OTCC%' AND MST.CUSTID = CF.CUSTID);

    DELETE FROM AFMAST MST
        WHERE EXISTS (SELECT * FROM CFMAST CF WHERE CUSTODYCD LIKE 'OTCC%' AND MST.CUSTID = CF.CUSTID);

    DELETE FROM SEMAST MST
        WHERE EXISTS (SELECT * FROM CFMAST CF WHERE CUSTODYCD LIKE 'OTCC%' AND MST.CUSTID = CF.CUSTID);

    DELETE FROM CFMAST CF WHERE CUSTODYCD LIKE 'OTCC%';

    COMMIT;

    -- get CURRDATE
    v_busdate := getcurrdate;

    RESET_SEQUENCE(SEQ_NAME => 'seq_cfmastcv', STARTVALUE => 1);
    Commit;

    UPDATE cfmastcv
        SET autoid = seq_cfmastcv.NEXTVAL;
    COMMIT;

    InsertConvertLog('I','Begin OTC_CFMASTCV...BAT DAU UPDATE THONG BAO LOI');
     -- kiem tra cac truong mandatory va CHECK gia tri so chung khoan.
     UPDATE cfmastcv
     SET deltd = 'Y', errmsg = 'data missing: ' ||
        CASE
            WHEN fullname IS NULL OR fullname = '' THEN ' [FULLNAME] IS NULL '
            WHEN idcode IS NULL OR idcode = '' THEN ' [IDCODE] IS NULL '
            WHEN iddate IS NULL OR iddate = '' THEN ' [IDDATE] IS NULL '
            WHEN IDPLACE IS NULL OR IDPLACE = '' THEN ' [IDPLACE] IS NULL '
            WHEN IDTYPE IS NULL OR IDTYPE = '' THEN ' [IDTYPE] IS NULL '
            WHEN COUNTRY IS NULL OR COUNTRY = '' THEN ' [COUNTRY] IS NULL '
            WHEN ADDRESS IS NULL OR ADDRESS = '' THEN ' [ADDRESS] IS NULL '
            WHEN CFTYPE IS NULL OR CFTYPE = '' THEN ' [CFTYPE] IS NULL '
            WHEN brid IS NULL OR brid = '' THEN ' [brid] IS NULL '
            WHEN CAREBY IS NULL OR CAREBY = '' THEN ' [CAREBY] IS NULL '
            WHEN TRIM(brid) NOT IN (SELECT TRIM(BRID) FROM BRGRP ) THEN ' [brid] IS INVALID '
            WHEN TRIM(CUSTODYCD) IN (SELECT CUSTODYCD FROM CFMAST WHERE CUSTODYCD IS NOT NULL) THEN ' [CUSTODYCD] IS EXIST '

             WHEN mobilesms IS NULL OR brid = '' THEN ' [mobilesms] IS NULL '
             WHEN OPNDATE IS NULL OR brid = '' THEN ' [OPNDATE] IS NULL '
             WHEN CUSTTYPE IS NULL OR brid = '' THEN ' [CUSTTYPE] IS NULL '
            ELSE 'UNKNOWN!'
        END
     WHERE DELTD <> 'Y' AND
     (IDTYPE IS NULL OR IDTYPE = ''
     OR FULLNAME IS NULL OR FULLNAME = ''
     OR IDCODE IS NULL OR IDCODE = ''
     OR IDDATE IS NULL OR IDDATE = '')
     ;

    InsertConvertLog('I','Begin OTC_CFMASTCV...CHECK [CUSTODYCD] IS DUPLICATE');
    for rec in (select * from cfmastcv where DELTD<>'Y' )
    loop
        Begin
            select count(1) into v_count
            from cfmast cfaf where rec.custodycd = cfaf.custodycd;
        EXCEPTION
            WHEN others THEN
                v_count := 0;
        End;
        if v_count > 0 then
            UPDATE cfmastcv SET deltd = 'Y', errmsg = ' [CUSTODYCD] IS DUPLICATE ' where CUSTODYCD=rec.CUSTODYCD;
        end if;
    end loop;

     -- xu ly tuan tu
     InsertConvertLog('I','Begin OTC_CFMASTCV...Convert');
     FOR rec  IN
     (
         SELECT cf.*, 'N' TRADETELEPHONE, 'N' marginallow,
                '0001' tlid, '' taxcode,
                nvl(cf.mobilesms,cf.mobilecall) mobile
         FROM cfmastcv cf WHERE cf.DELTD<>'Y'
     )
     LOOP

            l_custodycd := rec.custodycd;

            BEGIN
                SELECT SUBSTR(INVACCT,1,4) || TRIM(TO_CHAR(MAX(ODR)+1,'000000'))
                    into l_custid
                FROM (
                        SELECT ROWNUM ODR, INVACCT
                        FROM (
                                SELECT TO_CHAR(CUSTID) INVACCT
                                FROM CFMAST
                                WHERE SUBSTR(CFMAST.CUSTID,1,4)= trim(rec.brid)
                                ORDER BY CUSTID
                             ) DAT
                        WHERE TO_NUMBER(SUBSTR(INVACCT,5,6))= ROWNUM
                     ) INVTAB
                GROUP BY SUBSTR(INVACCT,1,4);
            EXCEPTION
                WHEN others THEN -- caution handles all exceptions
                     l_custid := trim(rec.brid)  || '000001';
            END;

            IF rec.country <> '234' THEN
                L_STRidcode := '';
                l_STRtradingcode := rec.idcode;
            ELSE
                L_STRidcode :=  rec.idcode;
                l_STRtradingcode := '';
            END IF;

            --- MO TAI KHOAN
            INSERT INTO CFMAST (CUSTID, CUSTODYCD, FULLNAME, IDCODE, IDDATE, IDPLACE,IDEXPIRED, IDTYPE, COUNTRY, ADDRESS, mobilesms, EMAIL, DESCRIPTION, TAXCODE, OPNDATE,
            CAREBY, BRID, STATUS, PROVINCE, CLASS, GRINVESTOR, INVESTRANGE, POSITION, TIMETOJOIN, STAFF, SEX, SECTOR, FOCUSTYPE ,BUSINESSTYPE,
            INVESTTYPE, EXPERIENCETYPE, INCOMERANGE, ASSETRANGE, LANGUAGE, BANKCODE, MARRIED, ISBANKING, DATEOFBIRTH,CUSTTYPE,CUSTATCOM,
            mnemonic,valudadded,occupation,education,experiencecd,tlid,risklevel,marginallow,t0loanlimit,commrate,mrloanlimit, ACTYPE, tradingcode,USERNAME, LAST_OFID,APPROVEID, TRADEONLINE,tradingcodedt,OPENVIA, TRADETELEPHONE,PIN)
                    VALUES (l_custid, l_custodycd, rec.fullname, L_STRidcode, rec.iddate, rec.idplace, ADD_MONTHS(rec.iddate,180), rec.idtype, rec.country, rec.address,
                    rec.mobile, rec.email, rec.description, rec.taxcode, v_busdate, rec.careby,rec.brid,'A','HN','001','000','000','000','000','000',rec.sex
                    ,'000','000','009','000','000','000','000','001','000','004','N',rec.dateofbirth,rec.CUSTTYPE,'Y',
                    nmpks_ems.fn_convert_to_vn(rec.fullname),'000','001','000','00000',rec.tlid,'M',REC.marginallow,10000000000000,100,10000000000000,REC.CFTYPE,l_STRtradingcode,'',p_tlid,p_tlid,REC.isonline,rec.iddate,'I',rec.tradetelephone,rec.pin);


             select count(1) into v_count from afmast where custid = l_custid;

             if v_count =0 then
               pr_AutoOpenNormalAccount(l_custid,'Y',l_err_code);
             END IF;

    END LOOP;
    COMMIT;

    InsertConvertLog('I','End OTC_CFMASTCV...');

EXCEPTION
   WHEN OTHERS THEN
   InsertConvertLog('E','End OTC_CFMASTCV...' || l_custodycd || ' ' || SQLERRM || dbms_utility.format_error_backtrace);
   plog.setendsection(pkgctx, 'OTC_CFMASTCV');
END OTC_CFMASTCV;

PROCEDURE OTC_CIMASTCV
IS
l_currdate date;
l_prevdate date;
l_nextdate date;
l_maxtxnum number;
BEGIN

InsertConvertLog('I','BEGIN OTC_CIMASTCV...');
select to_date(varvalue,'DD/MM/RRRR') into l_prevdate from sysvar where varname = 'PREVDATE';
select to_date(varvalue,'DD/MM/RRRR') into l_currdate from sysvar where varname = 'CURRDATE';
select to_date(varvalue,'DD/MM/RRRR') into l_nextdate from sysvar where varname = 'NEXTDATE';

-- Revert so da import --> nhung tai khoan da co tai PHS
For rec in
(
    select tr.acctno afacctno, tr.txdate, tr.txnum,
           sum(decode(tr.txcd,'0012' , tr.namt, 0)) balance
    from citran_gen tr
    where custodycd like 'OTCC%'
    group by tr.acctno, tr.txdate, tr.txnum

 )Loop
    Delete tllogall where txnum = rec.txnum and txdate = rec.txdate and msgacct=rec.afacctno;
    Delete citrana  where txnum = rec.txnum and txdate = rec.txdate and acctno=rec.afacctno;
    Delete citran_gen  where txnum = rec.txnum and txdate = rec.txdate and acctno=rec.afacctno;

    /*Update cimast
        set balance = balance - rec.balance
    where acctno = rec.afacctno;*/
End Loop;

Begin
    SELECT TO_NUMBER(MAX(SUBSTR(TXNUM,5,6))) into L_MAXTXNUM FROM TLLOGALL WHERE TXDATE = l_prevdate;
EXCEPTION
  WHEN OTHERS THEN
    L_MAXTXNUM := 1;
END;

for rec in
(
    select cf.custodycd, cf.custid, af.acctno afacctno, af.brid,
           round(to_number(nvl(cv.balance,0)),0) balance,
           '9990' || LPAD(seq_CVtxnum.NEXTVAL,6,'0') TXNUM, nvl(cv.description,'CASH_DEPOSIT') desc_ci
    from cfmast cf, afmast af, cimast ci, cimastcv cv
    where cf.custid = af.custid
            and af.acctno = ci.afacctno
            and cf.custodycd = cv.custodycd
            and round(to_number(nvl(cv.balance,0)),0) > 0
)
loop

INSERT INTO TLLOGALL
(autoid, txnum, txdate, txtime, brid, tlid, offid,
       ovrrqs, chid, chkid, tltxcd, ibt, brid2, tlid2,
       ccyusage, off_line, deltd, brdate, busdate, txdesc,
       ipaddress, wsname, txstatus, msgsts, ovrsts,
       batchname, msgamt, msgacct, chktime)
VALUES
(SEQ_TLLOG.NEXTVAL ,REC.TXNUM,l_prevdate,TO_CHAR(SYSDATE,systemnums.C_TIME_FORMAT),REC.BRID,'0001','0001','@00','0001',NULL,'9104',NULL,NULL,NULL,'00','N','N',l_prevdate,l_prevdate,rec.desc_ci,'127.0.0.1','BMSC-CONV','1','0','0','DAY',REC.BALANCE,REC.AFACCTNO,NULL);

INSERT INTO CITRANA
(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,REF,DELTD,ACCTREF,AUTOID, TLTXCD)
VALUES
(REC.TXNUM,l_prevdate,REC.AFACCTNO,'0012',REC.BALANCE,NULL,NULL,'N',NULL,SEQ_CITRAN.NEXTVAL, '9104');

INSERT INTO CITRANA
(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,REF,DELTD,ACCTREF,AUTOID, TLTXCD)
VALUES
(REC.TXNUM,l_prevdate,REC.AFACCTNO,'0014',REC.BALANCE,NULL,NULL,'N',NULL,SEQ_CITRAN.NEXTVAL, '9104');

update cimast
    set balance = balance + REC.BALANCE, CRAMT = CRAMT + REC.BALANCE
where acctno = REC.AFACCTNO;

end loop;

Delete from citran_gen tr where CUSTODYCD like 'OTCC%';
INSERT INTO citran_gen (AUTOID,CUSTODYCD,CUSTID,TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,REF,DELTD,ACCTREF,TLTXCD,BUSDATE,TXDESC,TXTIME,BRID,TLID,OFFID,CHID,DFACCTNO,OLD_DFACCTNO,TXTYPE,FIELD,TLLOG_AUTOID,TRDESC)
    select ci.autoid, cf.custodycd, cf.custid,
        ci.txnum, ci.txdate, ci.acctno, ci.txcd, ci.namt,
        ci.camt, ci.ref, nvl(ci.deltd,'N') deltd, ci.acctref,
        tl.tltxcd, tl.busdate,
        case when tl.tlid ='6868' then trim(tl.txdesc) || ' (Online)' else tl.txdesc end txdesc,
        tl.txtime, tl.brid, tl.tlid, tl.offid, tl.chid,
        '' dfacctno,''  old_dfacctno, app.txtype, app.field ,tl.autoid,
        case when ci.trdesc is not null
            then (case when tl.tlid ='6868' then trim(ci.trdesc) || ' (Online)' else ci.trdesc end)
            else ci.trdesc end trdesc
    from citrana ci, tllogall tl, cfmast cf, afmast af, apptx app
    where ci.txdate = tl.txdate and ci.txnum = tl.txnum
        and cf.custid = af.custid
        and ci.acctno = af.acctno
        and ci.txcd = app.txcd and app.apptype = 'CI' and app.txtype in ('D','C')
        and tl.deltd <> 'Y'
        and cf.custodycd like 'OTCC%'
        and ci.txdate = l_prevdate
        and ci.namt <> 0;

InsertConvertLog('I','END OTC_CIMASTCV...');

EXCEPTION
  WHEN others THEN
    InsertConvertLog('E','END OTC_CIMAST...' || SQLERRM|| '.At:' || dbms_utility.format_error_backtrace);
    rollback;
    RAISE errnums.E_SYSTEM_ERROR;
END;

function fn_todate(p_date in varchar2)
return date is
begin
return to_date(nvl(p_date,'01/01/1900'),'DD/MM/RRRR');
exception when others then
return to_date('01/01/1900','DD/MM/RRRR');
end;

function fn_tonumber(p_number in varchar2)
return number is
l_number varchar2(1000);
l_num number;
begin
l_number:= trim(replace(replace(p_number,',',''),'?',''));

select to_number(decode(l_number,null,'0','-','0',l_number)) into l_num from dual;
return l_num;

exception when others then
return null;
end;

function fn_convert_linkauth(p_linkauth in varchar2)
return varchar2 is
    v_linkauth varchar2(100);
begin

/*
        v_1Xem VARCHAR2(1);
        v_2Baocao VARCHAR2(1);
        v_3Tien VARCHAR2(1);
        v_4MUA VARCHAR2(1);
        v_5BAN VARCHAR2(1);
        v_7CKCK VARCHAR2(1);
        v_8DKQM VARCHAR2(1);
        v_9ChungKhoan VARCHAR2(1);
        v_10UTTB VARCHAR2(1);
        v_11CamCo VARCHAR2(1);
        v_12Margin VARCHAR2(1);
*/
    v_linkauth := '';
    If nvl(SUBSTR(p_linkauth,10,1),'N') ='Y' then
        v_linkauth := 'YYYYYYYYYYYY';
    Else
        -- Xem
        If SUBSTR(p_linkauth,1,1) = 'Y' then
            v_linkauth := v_linkauth || 'YY';
        Else
            v_linkauth := v_linkauth || 'NN';
        End If;

        -- Tien
        v_linkauth := v_linkauth || SUBSTR(p_linkauth,2,1);

        -- Dat lenh
        If SUBSTR(p_linkauth,4,1) = 'Y' then
            v_linkauth := v_linkauth || 'YYN';
        Else
            v_linkauth := v_linkauth || 'NNN';
        End If;

        -- Chung khoan
        If SUBSTR(p_linkauth,3,1) = 'Y' then
            v_linkauth := v_linkauth || 'YNY';
        Else
            v_linkauth := v_linkauth || 'NNN';
        End If;

        -- UTTB
        If SUBSTR(p_linkauth,5,1) = 'Y' then
            v_linkauth := v_linkauth || 'Y';
        Else
            v_linkauth := v_linkauth || 'N';
        End If;

        -- Cam co
        If SUBSTR(p_linkauth,6,1) = 'Y' then
            v_linkauth := v_linkauth || 'YN';
        Else
            v_linkauth := v_linkauth || 'NN';
        End If;

    End if;

    RETURN v_linkauth;

exception when others then
    return 'NNNNNNNNNNNN';
end;

PROCEDURE pr_Do_PRMASTER
IS
v_nextdate varchar2(20);
v_currdate varchar2(20);
v_prevdate varchar2(20);
l_prevdate date;
l_err_code varchar2(1000);
l_maxdebtqttyrate number;
l_maxdebtse number;
l_iratio number;
v_prinused number;
l_value number;
BEGIN
v_nextdate:=cspks_system.fn_get_sysvar ('SYSTEM', 'NEXTDATE');
v_currdate:=cspks_system.fn_get_sysvar ('SYSTEM', 'CURRDATE');
v_prevdate:=cspks_system.fn_get_sysvar ('SYSTEM', 'PREVDATE');
l_prevdate:= to_date(v_prevdate,'DD/MM/RRRR');


-- Cap nhat lai SECURITIES_INFO.ROOMLIMIT
select to_number(varvalue)/100 into l_maxdebtqttyrate from sysvar where grname = 'MARGIN' and varname = 'MAXDEBTQTTYRATE';
select to_number(varvalue) into l_maxdebtse from sysvar where grname = 'MARGIN' and varname = 'MAXDEBTSE';
select 1 - to_number(varvalue)/100 into l_iratio from sysvar where grname = 'MARGIN' and varname = 'IRATIO';

update securities_info
set roomlimit = least(listingqtty*l_maxdebtqttyrate, l_maxdebtse/marginrefprice/l_iratio)
where marginrefprice <> 0 and l_iratio <> 0;



UPDATE PRMASTER SET PRINUSED = 0;
delete PRTRAN;
for rec in
(
    SELECT pm.prcode, pm.prname, pm.prtyp, pm.codeid, pm.prlimit,
                    pm.prinused, pm.expireddt, pm.prstatus, prt.type
    FROM prmaster pm, prtype prt, prtypemap prtm, typeidmap tpm, bridmap brm
    WHERE pm.prcode = brm.prcode
        AND pm.prcode = prtm.prcode
        AND prt.actype = prtm.prtype
        AND prt.actype = tpm.prtype
        and pm.prtyp = 'P'
)
loop

    if rec.type = 'SYSTEM' then
        select round(nvl(sum(ls.nml + ls.ovd),0),0) into l_value
        from lntype lnt, vw_lnmast_all ln, vw_lnschd_all ls
        where lnt.actype = ln.actype and ln.acctno = ls.acctno
        and ls.reftype in ('P','GP')
        and ln.ftype <> 'DF'
        and lnt.chksysctrl = 'Y';

    else
        select round(nvl(sum(ls.nml + ls.ovd),0),0) into l_value
        from vw_lnmast_all ln, vw_lnschd_all ls
        where ln.acctno = ls.acctno
        and ln.ftype <> 'DF'
        and ls.reftype in ('P','GP');
    end if;

    UPDATE PRMASTER SET PRINUSED=NVL(PRINUSED,0)+ l_value WHERE PRCODE= rec.prcode;
    INSERT INTO PRTRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
    VALUES ('9990' || LPAD(seq_CVtxnum.NEXTVAL,6,'0'), l_prevdate,rec.prcode,'0004',l_value,NULL,'N','',seq_PRTRAN.NEXTVAL,'0101',l_prevdate,'Data Conversion');

end loop;

EXCEPTION
  WHEN others THEN
    plog.error('CONVERT:' || SQLERRM || '.At:' || dbms_utility.format_error_backtrace);
    rollback;
    RAISE errnums.E_SYSTEM_ERROR;
END;


PROCEDURE pr_Gen_AfterConvert
IS
v_nextdate varchar2(20);
v_currdate varchar2(20);
v_prevdate varchar2(20);
l_MAXDEBTSE number;
l_err_code varchar2(1000);
v_prinused number;
BEGIN
v_nextdate:=cspks_system.fn_get_sysvar ('SYSTEM', 'NEXTDATE');
v_currdate:=cspks_system.fn_get_sysvar ('SYSTEM', 'CURRDATE');
v_prevdate:=cspks_system.fn_get_sysvar ('SYSTEM', 'PREVDATE');

reset_sequence('seq_secbasket',1);
InsertConvertLog('I','Begin pr_Gen_AfterConvert...');
select to_number(varvalue) into l_MAXDEBTSE from sysvar where grname = 'MARGIN' and varname = 'MAXDEBTSE';



Delete secbasket;
insert into secbasket
(autoid,basketid, symbol, mrratiorate, mrratioloan,
   mrpricerate, mrpriceloan, description,importdt)
select seq_secbasket.nextval,basketid, symbol, mrratiorate, mrratioloan,
   mrpricerate, mrpriceloan, description, to_char(sysdate,'DD/MM/YYYY:HH:MI:SS') importdt
from secbaskettemp;

update LNSEBASKET
set EFFDATE = getcurrdate;


InsertConvertLog('I','Begin cspks_saproc.fn_ApplySystemParam...');
if cspks_saproc.fn_ApplySystemParam(l_err_code) <> 0 then
   RAISE errnums.E_SYSTEM_ERROR;
end if;

if l_err_code <> 0 then
   RAISE errnums.E_SYSTEM_ERROR;
end if;

InsertConvertLog('I','CONVERT:' || 'UPDATE CIMAST SET ODAMT = 0;');
UPDATE CIMAST SET ODAMT = 0;
for rec_af in
(
    select trfacctno, round(sum(PRINNML + PRINOVD + INTNMLACR + INTOVDACR + INTNMLOVD + INTDUE + INTPREPAID +
                            OPRINNML + OPRINOVD + OINTNMLACR + OINTOVDACR + OINTNMLOVD + OINTDUE + OINTPREPAID +
                            FEE + FEEDUE + FEEOVD + FEEINTNMLACR + FEEINTOVDACR + FEEINTNMLOVD + FEEINTDUE + FEEINTPREPAID)) ODAMT
           from lnmast
           where ftype = 'AF'
           group by trfacctno
           order by trfacctno
)
loop -- rec_af
    UPDATE CIMAST SET ODAMT = rec_af.ODAMT
    WHERE ACCTNO = rec_af.TRFACCTNO;
end loop; -- rec_af

UPDATE CIMAST SET DUEAMT = 0;
FOR REC IN
(
    select m.trfacctno, sum(nml + INTDUE + FEEINTDUE) nml
    from
    (SELECT ACCTNO, SUM(NML) NML
        FROM LNSCHD
        WHERE OVERDUEDATE = TO_DATE(cspks_system.fn_get_sysvar('SYSTEM','CURRDATE'),'DD/MM/YYYY') AND nml + INTDUE + FEEINTDUE > 0 AND REFTYPE IN ('P') group by acctno) S,
        LNMAST M
    where S.ACCTNO = M.ACCTNO AND M.STATUS NOT IN ('P','R','C') and M.FTYPE<>'DF'
    GROUP BY M.TRFACCTNO
    order by trfacctno
)
LOOP
    UPDATE CIMAST SET DUEAMT = round(DUEAMT + REC.NML,0) WHERE ACCTNO = REC.TRFACCTNO;
END LOOP;

-- update cimast set ovamt
--Reset CIMAST.OVAMT = 0;
UPDATE CIMAST SET OVAMT = 0;
for rec_af in
(
    select trfacctno, round(sum(PRINOVD + INTOVDACR + INTNMLOVD + INTPREPAID +
                            OPRINNML + OPRINOVD + OINTNMLACR + OINTOVDACR + OINTNMLOVD + OINTDUE + OINTPREPAID +
                            FEE + FEEDUE + FEEOVD + FEEINTOVDACR + FEEINTNMLOVD + FEEINTPREPAID)) OVAMT
    from lnmast
    where ftype = 'AF'
    group by trfacctno
    order by trfacctno
)
loop -- rec_af
    UPDATE CIMAST SET OVAMT = rec_af.OVAMT
    WHERE ACCTNO = rec_af.TRFACCTNO;
end loop; -- rec_af

--Update lai room toan he thong va room margin theo rm thiet lap lai cuoi ngay
for rec in (
    select * from securities_info where syroomlimit_set+roomlimitmax_set+roomlimitmax+syroomlimit>0
)
loop
    --Cap nhat room he thong
    begin
        select nvl(afpr.prinused,0) into v_prinused
            from securities_info sb,
                   (select codeid, sum(prinused) prinused from vw_afpralloc_all where restype = 'S' group by codeid) afpr
            where sb.codeid = afpr.codeid(+)
            and sb.codeid = rec.codeid;
    exception when others then
        v_prinused:=0;
    end;

    update securities_info
    set syroomlimit = greatest(syroomlimit_set,v_prinused),
        syroomused = v_prinused
    where codeid = rec.codeid;
    --Cap nhat room margin
    begin
        select nvl(sum(prinused),0) into v_prinused from vw_afpralloc_all
        where restype = 'M'
        and codeid = rec.codeid;
    exception when others then
        v_prinused:=0;
    end;
    update securities_info
    set roomlimitmax = GREATEST(roomlimitmax_set,v_prinused),
        roomused = v_prinused
    where codeid = rec.codeid;
end loop;

jbpks_auto.pr_gen_buf_ci_account('ALL');
jbpks_auto.pr_gen_buf_se_account('ALL');
jbpks_auto.pr_gen_buf_od_account('ALL');

begin
        for rec in
        (
        select * from user_objects where object_type = 'TRIGGER'
        )
        loop
                     execute immediate 'ALTER TRIGGER ' || rec.object_name || ' ENABLE';
        end loop;
end;
plog.error('CONVERT:' || 'End....');

EXCEPTION
  WHEN others THEN
    plog.error('CONVERT:' || SQLERRM || '.At:' || dbms_utility.format_error_backtrace);
    rollback;
    RAISE errnums.E_SYSTEM_ERROR;
END;

Begin
  -- Initialization
  -- <Statement>;
  for i in (select * from tlogdebug) loop
    logrow.loglevel  := i.loglevel;
    logrow.log4table := i.log4table;
    logrow.log4alert := i.log4alert;
    logrow.log4trace := i.log4trace;
  end loop;

  pkgctx := plog.init('pks_covert_flex',
                      plevel     => nvl(logrow.loglevel, 30),
                      plogtable  => (nvl(logrow.log4table, 'N') = 'Y'),
                      palert     => (nvl(logrow.log4alert, 'N') = 'Y'),
                      ptrace     => (nvl(logrow.log4trace, 'N') = 'Y'));
end pks_covert_to_flex;
/
