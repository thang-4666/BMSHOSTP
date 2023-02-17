SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE sp_generate_appmapbravo (
       pv_txdate in VARCHAR,
       pv_txnum in VARCHAR,
       pv_errmsg out VARCHAR ) IS
       v_currdate                varchar2(20);
       v_busdate                varchar2(20);
       V_TXDATE                  varchar2(20);
       v_custid                 varchar2(10);
       v_custodycd              varchar2(10);
       v_custodycd_debit        varchar2(10);
       v_custodycd_credit      varchar2(10);
       v_bankid                varchar2(100);
       v_trans_type            varchar2(10);
       v_amount                varchar2(100);
       v_symbol                varchar2(20);
       v_symbol_qtty           number DEFAULT 0;
       --v_symbol_price          number DEFAULT 0;
       v_costprice            number DEFAULT 0;
       v_txbrid               varchar2(10);
       v_brid                 varchar2(10);
       v_tradeplace           varchar2(10);
       v_iscorebank           varchar2(10);
       v_status               varchar2(10);
       v_custatcom            varchar2(10);
       v_custtype             varchar2(10);
       v_country             varchar2(10);
       v_sectype             varchar2(10);
       v_note                varchar2(2000);
       v_tltxcd              varchar2(10);
       v_acfld               varchar2(10);
       v_acsefld               varchar2(16);
       v_amtexp              varchar2(100);
       v_codeid              varchar2(100);
       v_qttyexp             varchar2(100);
       v_price               varchar2(100);
       v_pos_amtexp          NUMBER DEFAULT 0;
       v_expression          varchar2(100);
       v_evaluator           varchar2(100);
       v_bankname             varchar2(1000);
       --v_orgorderid           varchar2(1000);
       v_bors                           varchar2(10);
       v_fullname              varchar2(1000);
       v_acname              varchar2(100);
       v_dorc                varchar2(10);
       v_reftran          varchar2(100);
       V_QTTYTYPE               varchar2(10);
       v_apptype                varchar2(2);
       v_actype                 varchar2(4);
       --v_type                    varchar2(3);
       --v_magiaodich              varchar2(100);
       --v_cmnd                    varchar2(100);
       --v_namecmnd                varchar2(100);
       v_realdate               varchar2(50);
       v_NB                     varchar2(50);
       v_orderID                varchar2(100);
       v_symcode                varchar2(100);
       v_errcode                varchar2(100);
       v_actype_debit           varchar2(4);
       v_actype_credit           varchar2(4);
       v_acctno_debit           varchar2(20);
       v_acctno_credit           varchar2(20);
       v_subtx           varchar2(20);
       v_strTLID            varchar2(20);
       v_strDEPID            varchar2(20);
       V_STRT3  VARCHAR (20);
       V_STRISVAT     VARCHAR (20);
       v_strtrfcode    VARCHAR (20);
       v_strbankname    VARCHAR (20);
       v_str_trfbuyext VARCHAR (20);
       v_strismagin VARCHAR (200);
       v_alternateacct VARCHAR (20);
       v_typetrf  VARCHAR (20);

       v_amount1                varchar2(100);
       v_amount2                varchar2(100);
       v_amount3                varchar2(100);
       v_debit_iscorebank       varchar2(100);
       v_credit_iscorebank       varchar2(100);
       v_tobrid   varchar2(100);
       v_typegr                    varchar2(20);
       v_catype     varchar2(20);
       v_iofee  varchar2(3);
       pkgctx   plog.log_ctx;
       logrow   tlogdebug%ROWTYPE;

 CURSOR v_cursor_appmapbravo(v_tltxcd VARCHAR2 ) is SELECT * FROM APPMAPBRAVO where tltxcd = v_tltxcd  ;
 v_appmapbravo_row v_cursor_appmapbravo%ROWTYPE;
BEGIN
plog.error (pkgctx, '<<BEGIN OF SP_GENERATE_APPMAPBRAVO' || SYSDATE);
    V_TXDATE:= pv_txdate;
   select varvalue into v_currdate
       from sysvar where varname = 'CURRDATE';
--THONG TIN GIAO DICH
        SELECT tltxcd, to_char(busdate,'DD/MM/RRRR'), txdesc,DECODE ( SUBSTR(TXNUM,1,4),'0101',SUBSTR(TXNUM,1,4),'0001')
                 INTO v_tltxcd, v_busdate, v_note,v_txbrid
         FROM TMP_TBL_TLLOG TL WHERE TL.TXDATE=TO_DATE(pv_txdate,'DD/MM/RRRR') AND TL.TXNUM=pv_txnum;

         OPEN v_cursor_appmapbravo(v_tltxcd);
      LOOP
        pv_errmsg:='Begin';

--        dbms_output.put_line(pv_errmsg);
        FETCH v_cursor_appmapbravo INTO v_appmapbravo_row;
        EXIT WHEN v_cursor_appmapbravo%NOTFOUND;
        v_trans_type := v_tltxcd || v_appmapbravo_row.Subtx;

          v_acname:=v_appmapbravo_row.acname;
          v_dorc:=v_appmapbravo_row.dorc;
          v_apptype:=v_appmapbravo_row.apptype;
--LAY KHOA
          v_acfld:=v_appmapbravo_row.acfld;
          v_strtrfcode :=v_appmapbravo_row.trfcode;
        begin
            SELECT CVALUE INTO v_acfld
            FROM tmp_tbl_tllogfld TL WHERE TL.TXDATE=TO_DATE(PV_TXDATE,'DD/MM/RRRR') AND TL.TXNUM=PV_TXNUM AND FLDCD=V_APPMAPBRAVO_ROW.ACFLD;
        EXCEPTION
            when OTHERS then
            v_acfld := '';
        end;


        SELECT max(decode(fldcd, v_appmapbravo_row.acfld , CVALUE, '')),
               max(decode(fldcd, v_appmapbravo_row.bankid , CVALUE, '')),
               max(decode(fldcd, v_appmapbravo_row.codeid , CVALUE, '')),
               max(decode(fldcd, v_appmapbravo_row.price , NVALUE, 0)),
               max(decode(fldcd, v_appmapbravo_row.acsefld , CVALUE, '')),
               max(decode(fldcd, v_appmapbravo_row.symbol , CVALUE, '')),
               max(decode(fldcd, v_appmapbravo_row.reftran , CVALUE, '')),
               max(decode(fldcd, v_appmapbravo_row.debit_cd , CVALUE, '')),
               max(decode(fldcd, v_appmapbravo_row.credit_cd , CVALUE, '')),
               max(decode(fldcd, v_appmapbravo_row.debit_acctno , CVALUE, '')),
               max(decode(fldcd, v_appmapbravo_row.credit_acctno , CVALUE, '')),
               max(decode(fldcd, v_appmapbravo_row.subtx , CVALUE, ''))
        INTO v_acfld,v_bankid,v_codeid,v_price,v_acsefld,v_symbol,v_reftran , v_custodycd_debit, v_custodycd_credit , v_acctno_debit, v_acctno_credit , v_subtx
        FROM tmp_tbl_tllogfld TL WHERE TL.TXDATE=TO_DATE(pv_txdate,'DD/MM/RRRR') AND TL.TXNUM=pv_txnum;

if v_tltxcd in ('1120','1130')  then

  v_tobrid:= substr(v_acctno_credit,1,4);

END IF;

IF LENGTH(v_bankid)  = 2 then
select  bankacctno into v_bankid  from banknostro where shortname =v_bankid;
End if;

IF v_tltxcd IN ('1112') THEN
select af.acctno, cf.custodycd
    into v_acfld, v_custodycd
    from TMP_TBL_TLLOG tl, cfmast cf, afmast af
    where cf.custid=af.custid
    and tl.msgacct=af.acctno
    and tl.tltxcd like '1112'
    and txnum=pv_txnum and txdate=pv_txdate;
END IF;

-- LAY CAC TRUONG LIEN QUAN DEN TIEU KHOAN
SELECT cf.custid,cf.custodycd , AF.brid,CF.custatcom,CF.CUSTTYPE,DECODE (CF.country,'234','001','002'),
--Ngay 07/03/2017 NamTv chinh lai cho tai khoan chinh phu af.corebank corebank
case when af.corebank='Y' then 'Y' when af.corebank='N' and af.alternateacct='Y' then 'Y' else 'N' end corebank
,cf.fullname,af.actype,
--af.bankname,aftype.trfbuyext, decode(mrtype.mrtype,'T','Y','N'),alternateacct
af.bankname,aftype.trfbuyext,upper(aftype.mnemonic),alternateacct
INTO v_custid,v_custodycd, v_brid,v_custatcom,v_custtype,v_country ,v_iscorebank,v_fullname,v_actype,v_strbankname, v_str_trfbuyext,v_strismagin,v_alternateacct
FROM AFMAST AF, CFMAST CF,aftype,mrtype
WHERE AF.CUSTID =CF.CUSTID AND af.actype=aftype.actype AND aftype.mrtype=mrtype.actype AND AF.ACCTNO = v_acfld;


begin
select max(typegr) into v_typegr  from vw_gl_regr
where custodycd = v_custodycd
and TO_DATE(pv_txdate,'DD/MM/RRRR') >=re_frdate
and TO_DATE(pv_txdate,'DD/MM/RRRR') <= re_todate
and TO_DATE(pv_txdate,'DD/MM/RRRR') >=regl_frdate
and TO_DATE(pv_txdate,'DD/MM/RRRR') <= regl_todate;
EXCEPTION
  WHEN OTHERS THEN
  v_typegr:= '' ;
end ;


/*
begin
select  NVL( max(corebank),v_iscorebank) into v_iscorebank FROM vw_citran_gen WHERE TXDATE=TO_DATE(pv_txdate,'DD/MM/RRRR') AND TXNUM=pv_txnum;
EXCEPTION
  WHEN OTHERS THEN
  v_iscorebank:= 'N' ;
end ;*/

/*BEGIN
IF v_iscorebank ='Y' and v_tltxcd <> '1104' THEN


IF v_tltxcd ='1153' THEN
BEGIN
SELECT  trfcode INTO v_strtrfcode FROM crbtxreq
WHERE txdate =TO_DATE(pv_txdate,'DD/MM/RRRR') AND objkey = pv_txnum AND via='RPT'
AND trfcode = decode (v_appmapbravo_row.Subtx,'01','TRFADVAMT','02','TRFADVAMTFEE') ;
EXCEPTION
  WHEN OTHERS THEN
  v_strtrfcode:= trim(v_strtrfcode) ;
END ;
END IF ;

/*IF v_tltxcd IN ('1120','1130') THEN
SELECT  nvl(max(refacctno),v_bankid) INTO  v_bankid FROM CRBDEFACCT where trfcode= v_strtrfcode and refbank= (CASE WHEN v_tobrid ='0001' THEN 'BIDVHCM' ELSE  'BIDVHCM' END );
ELSE
SELECT  nvl(max(refacctno),v_bankid) INTO  v_bankid FROM CRBDEFACCT where trfcode= v_strtrfcode and refbank= 'BIDVHCM';--(CASE WHEN v_brid ='0001' THEN 'BIDVHN' ELSE  'BIDVHCM' END );
END IF;

--Ngay 28/02/2017 NamTv chinh lay theo BIDVHCM khong case theo BRID
--SELECT  nvl(max(refacctno),v_bankid) INTO  v_bankid FROM CRBDEFACCT where trfcode= v_strtrfcode and refbank= 'BIDVHCM';

END IF ;
EXCEPTION
  WHEN OTHERS THEN
  v_bankid:= trim(v_bankid) ;
END ;
*/




BEGIN
SELECT  'TCDT' INTO v_strtrfcode  FROM crbtxreq WHERE SUBSTR(bankcode,1,4)='TCDT'  AND txdate = to_date( pv_txdate,'DD/MM/YYYY') AND objkey =pv_txnum;

SELECT max(refacctno) INTO  v_bankid FROM CRBDEFACCT where trfcode= v_strtrfcode and refbank = (CASE WHEN v_brid ='0001' THEN 'BIDVHN' ELSE  'BIDVHCM' END );

EXCEPTION
  WHEN OTHERS THEN
  v_bankid:= trim(v_bankid) ;
END ;

--LAY THONG TIN LIEN QUAN DEN MOI GIOI
BEGIN

SELECT  recflnk.custid, regrp.autoid INTO v_strTLID,v_strDEPID
FROM reaflnk , regrplnk  , recflnk ,regrp,retype
WHERE substr( reaflnk.reacctno,1,10)= recflnk.custid
and recflnk.autoid= regrplnk.autoid
and regrplnk.refrecflnkid= regrp.autoid
AND reaflnk.afacctno = v_acfld
and substr( reaflnk.reacctno,11)= retype.actype
and retype.retype='D'
and retype.rerole='RM'
;

EXCEPTION
  WHEN OTHERS THEN
 v_strTLID:='';
 v_strDEPID:='';
END ;


-- LAY CAC TRUONG LIEN QUAN DEN THONG TIN CHUNG KHOAN
if  LENGTH(v_acsefld)  >0 then
for rec in
(select nvl( sb.symbol,'') symbol , decode ( v_price,0, sb.parvalue, v_price) price,nvl(se.COSTPRICE,0) COSTPRICE
,nvl( sb1.TRADEPLACE,sb.tradeplace) TRADEPLACE , nvl(sb.SECTYPE,'') SECTYPE
from sbsecurities sb,semast se,sbsecurities sb1
where  se.codeid =  sb.codeid  and  se.acctno = v_acsefld
and  sb.refcodeid = sb1.codeid(+)
)
loop
 v_symbol:=replace(rec.symbol,'_WFT','') ;
 v_price:= rec.price;
 v_costprice:= rec.costprice;
 v_tradeplace := rec.tradeplace;
 v_sectype := rec.sectype;

end loop ;

else


for rec in
(select nvl( sb.symbol,'') symbol , decode ( v_price,0, sb.parvalue, v_price) price,nvl(se.COSTPRICE,0) COSTPRICE
,nvl( sb1.TRADEPLACE,sb1.tradeplace) TRADEPLACE , nvl(sb.SECTYPE,'') SECTYPE
from sbsecurities sb,semast se,sbsecurities sb1
where  se.codeid = nvl(sb.refcodeid, sb.codeid) and  se.afacctno = v_acfld and sb.symbol =v_symbol
and  sb.refcodeid = sb1.codeid(+)
)
loop
 v_symbol:=replace(rec.symbol,'_WFT','') ;
 v_price:= rec.price;
 v_costprice:= rec.costprice;
 v_tradeplace := rec.tradeplace;
 v_sectype := rec.sectype;

end loop ;

end if ;

v_symbol_qtty:=0;
v_amount:=0;
-- TINH AMOUNT
 pv_errmsg:='Generate account number';
                --Thuc hien tinh bieu thuc
if v_appmapbravo_row.AMTEXP is not null then
                v_amtexp:=v_appmapbravo_row.AMTEXP;
                v_pos_amtexp:=1;
                v_expression:='';
--                dbms_output.put_line(pv_errmsg);
                WHILE v_pos_amtexp<length(v_amtexp) LOOP
                    v_evaluator:=substr(v_amtexp,v_pos_amtexp,2);
                    v_pos_amtexp:=v_pos_amtexp+2;
                    IF (v_evaluator='++' OR  v_evaluator='--' OR  v_evaluator='**' OR  v_evaluator='//' OR  v_evaluator='((' OR v_evaluator='))') THEN
                       v_expression:=v_expression || SUBSTR(v_evaluator,1,1);
                    ELSE
                       BEGIN
                            SELECT NVALUE+TO_NUMBER(NVL(CVALUE,0)) INTO v_amount FROM  tmp_tbl_tllogfld TL
                            WHERE TXDATE=TO_DATE(pv_txdate,'DD/MM/RRRR') AND TXNUM=pv_txnum AND FLDCD=v_evaluator;
                            v_expression:=v_expression || v_amount;
                       END;
                    END IF;
                END LOOP;

          v_expression:='UPDATE EVAL_EXPRESSTION SET EVAL=' || v_expression;
          execute immediate v_expression;
          pv_errmsg:='Evaluate: ' || v_expression;
          SELECT EVAL INTO v_amount FROM EVAL_EXPRESSTION;
UPDATE EVAL_EXPRESSTION SET EVAL =0;

end if;
-- TINH v_symbol_qtty
if v_appmapbravo_row.QTTYEXP is not null then
                --Thuc hien tinh bieu thuc
                v_qttyexp:=v_appmapbravo_row.QTTYEXP;
                v_pos_amtexp:=1;
                v_expression:='';
--                dbms_output.put_line(pv_errmsg);
                WHILE v_pos_amtexp<length(v_qttyexp) LOOP
                    v_evaluator:=substr(v_qttyexp,v_pos_amtexp,2);
                    v_pos_amtexp:=v_pos_amtexp+2;
                    IF (v_evaluator='++' OR  v_evaluator='--' OR  v_evaluator='**' OR  v_evaluator='//' OR  v_evaluator='((' OR v_evaluator='))') THEN
                       v_expression:=v_expression || SUBSTR(v_evaluator,1,1);
                    ELSE
                       BEGIN
                            SELECT NVALUE+TO_NUMBER(NVL(CVALUE,0)) INTO v_symbol_qtty FROM tmp_tbl_tllogfld TL
                            WHERE TXDATE=TO_DATE(pv_txdate,'DD/MM/RRRR') AND TXNUM=pv_txnum AND FLDCD=v_evaluator;
                            v_expression:=v_expression || v_symbol_qtty;
                       END;
                    END IF;
                END LOOP;
IF length(v_expression)>0  THEN
          v_expression:='UPDATE EVAL_EXPRESSTION SET EVAL=' || v_expression;
          execute immediate v_expression;
          pv_errmsg:='Evaluate: ' || v_expression;
          SELECT EVAL INTO v_symbol_qtty FROM EVAL_EXPRESSTION;
UPDATE EVAL_EXPRESSTION SET EVAL =0;
END IF;

end if ;

--LAY GIA TRI APPTYPE_DEBIT va APPTYPE_CREDIT
if length(v_acctno_debit) > 0 then
  select a.actype,cf.custodycd into v_actype_debit,v_custodycd_debit from afmast a,cfmast cf
  WHERE a.custid= cf.custid
  AND  a.acctno = v_acctno_debit;
end if;

if length(v_acctno_credit) > 0 then
  select a.actype,cf.custodycd into v_actype_credit,v_custodycd_credit from afmast a,cfmast cf
  WHERE a.custid= cf.custid
  AND  a.acctno = v_acctno_credit;
end if;


if v_tltxcd in ('1120','1130')  then

  select max(a.corebank) into v_debit_iscorebank from vw_citran_gen a
  where a.acctno = v_acctno_debit and a.TXDATE=TO_DATE(pv_txdate,'DD/MM/RRRR') AND a.TXNUM=pv_txnum;

  select max(a.corebank) into v_credit_iscorebank from vw_citran_gen a
  where a.acctno = v_acctno_credit and a.TXDATE=TO_DATE(pv_txdate,'DD/MM/RRRR') AND a.TXNUM=pv_txnum;

if v_debit_iscorebank='N' and v_credit_iscorebank='N' then
    v_typetrf := '001';
elsif  v_debit_iscorebank='N' and v_credit_iscorebank='Y' then
    v_typetrf := '002';
elsif  v_debit_iscorebank='Y' and v_credit_iscorebank='N' then
    v_typetrf := '003';
elsif  v_debit_iscorebank='Y' and v_credit_iscorebank='Y' then
    v_typetrf := '004';
end if;


v_tobrid:= substr(v_acctno_credit,1,4);

END IF;
------------------------------------------------------------------------------------------

if v_tltxcd in ('8804','8809') then
--select  orgorderid,bors into v_orgorderid,v_bors from  vw_iod_all where TXDATE = TO_DATE (pv_txdate,'DD/MM/YYYY') AND TXNUM = pv_txnum;

select TO_CHAR ( txdate,'DD/MM/YYYY'), case when duetype ='RS' THEN 'B' ELSE 'S' END   into V_TXDATE,v_bors  from   vw_stschd_all sts
where sts.duetype in ('RM','RS') AND orgorderid = v_reftran;

if v_bors ='B' then
v_trans_type:=v_tltxcd||'02';
else
v_trans_type:=v_tltxcd||'03';
end if ;
 v_busdate:=V_TXDATE;

v_amount:= v_symbol_qtty*v_price;

end if;
/*
if v_tltxcd ='8879' then
   select cf.custid,cf.custodycd,cf.fullname,af.actype into v_custid,v_custodycd,v_fullname,v_actype from cfmast cf, afmast af where cf.custid = af.custid
and af.acctno = v_acctno_debit;
end if ;
*/

if v_tltxcd ='8868' AND v_appmapbravo_row.APPTYPE='CI' then
select v_tltxcd || '01'  INTO v_trans_type  from   vw_stschd_all sts
where sts.duetype ='SM' AND orgorderid = v_reftran ;
end if ;
/*
IF v_symbol_qtty >0  AND v_acname IN ('BLOCKED') THEN

SELECT  NVL( REF,'-') INTO V_QTTYTYPE  FROM vw_setran_gen WHERE TXDATE = TO_DATE(pv_txdate ,'DD/MM/YYYY') AND  TXNUM = pv_txnum AND FIELD IN ('BLOCKED','DTOCLOSE')  ;
IF V_QTTYTYPE = '002' THEN
v_trans_type:=v_tltxcd||'06';
END IF;

END IF ;
*/

---Vu them Phan biet CK trong gd 2202
/*if v_tltxcd ='2202' then
    select cvalue into V_QTTYTYPE from tmp_tbl_tllogfld tlfld where tlfld.txnum=pv_txnum
    and tlfld.txdate=TO_DATE(pv_txdate,'DD/MM/RRRR') and fldcd ='12';

    if V_QTTYTYPE ='007' then
        --CK phong toa
        v_trans_type:=v_tltxcd||'07';
        v_acname :='BLOCKED';
        v_dorc :='C';
    else if V_QTTYTYPE ='002' then
        --CK han che chuyen nhuong
        v_trans_type:=v_tltxcd||'06';
    end if;
    end if;
end if;*/
---Vu them Phan biet CK trong gd 2204
if v_tltxcd ='2204' then
    select cvalue into V_QTTYTYPE from tmp_tbl_tllogfld tlfld where tlfld.txnum=pv_txnum
    and tlfld.txdate=TO_DATE(pv_txdate,'DD/MM/RRRR') and fldcd ='11';

    if V_QTTYTYPE ='001' then
        --CK phong toa
        v_trans_type:=v_tltxcd||'01';
    else if V_QTTYTYPE ='002' then
        --CK han che chuyen nhuong
        v_trans_type:=v_tltxcd||'02';
    else if V_QTTYTYPE ='003' then
        --CK han che chuyen nhuong
        v_trans_type:=v_tltxcd||'03';
    end if;
    end if;
    end if;
end if;
---Vu them Phan biet CK trong gd 1190
if v_tltxcd ='1190' then
    select cvalue into V_QTTYTYPE from tmp_tbl_tllogfld tlfld where tlfld.txnum=pv_txnum
    and tlfld.txdate=TO_DATE(pv_txdate,'DD/MM/RRRR') and fldcd ='09';

    v_trans_type := v_tltxcd||substr(V_QTTYTYPE,2);

end if;
---Vu them Phan biet CK trong gd 1191
if v_tltxcd ='1191' then
    select cvalue into V_QTTYTYPE from tmp_tbl_tllogfld tlfld where tlfld.txnum=pv_txnum
    and tlfld.txdate=TO_DATE(pv_txdate,'DD/MM/RRRR') and fldcd ='09';

    v_trans_type := v_tltxcd||substr(V_QTTYTYPE,2);

end if;


V_STRISVAT:='N';

IF v_trans_type IN ('111103','110103','113903','110403','887803','111403') THEN

V_STRISVAT:='Y';

END IF ;
-----vu them
if v_tltxcd='2239' then
  v_custodycd_credit := v_custodycd;
  v_iscorebank := 'N';
end if;
--NamTv chinh sua phan giao dich 1119
if v_tltxcd in ('1119','1106') then
    SELECT max(decode(fldcd, '09' , CVALUE, ''))
    into v_iofee
    FROM tmp_tbl_tllogfld
    where txnum = pv_txnum
    and txdate = TO_DATE(pv_txdate,'DD/MM/RRRR');
    if v_iofee='0' and v_trans_type in ('111903','111904','110603','110604') then
        continue;
    end if;
end if;
--Namtv End
--vu them hach toan tien gd 1101,1104
/*if v_tltxcd ='1101' then
    select max(decode(fldcd, '11' , NVALUE, '')),
           max(decode(fldcd, '12' , NVALUE, '')),
           max(decode(fldcd, '13' , NVALUE, ''))
    into v_amount1,v_amount2,v_amount3
    FROM tmp_tbl_tllogfld
    where txnum = pv_txnum
    and txdate = TO_DATE(pv_txdate,'DD/MM/RRRR');
    if v_trans_type ='110101' then
       v_amount := v_amount3-(v_amount1+v_amount2);
    end if;
end if;

if v_tltxcd ='1104' then
    select max(decode(fldcd, '11' , NVALUE, '')),
           max(decode(fldcd, '12' , NVALUE, '')),
           max(decode(fldcd, '13' , NVALUE, ''))
    into v_amount1,v_amount2,v_amount3
    FROM tmp_tbl_tllogfld
    where txnum = pv_txnum
    and txdate = TO_DATE(pv_txdate,'DD/MM/RRRR');
    if v_trans_type ='110401' then
       v_amount := v_amount2-(v_amount1+v_amount3);
    end if;
end if;


if v_tltxcd ='1111' then
    select max(decode(fldcd, '11' , NVALUE, '')),
           max(decode(fldcd, '12' , NVALUE, '')),
           max(decode(fldcd, '13' , NVALUE, ''))
    into v_amount1,v_amount2,v_amount3
    FROM tmp_tbl_tllogfld
    where txnum = pv_txnum
    and txdate = TO_DATE(pv_txdate,'DD/MM/RRRR');
    if v_trans_type ='111101' then
       v_amount := v_amount3-(v_amount1+v_amount2);
    end if;
end if;*/

IF INSTR(v_custodycd,'P')= 0 THEN

v_acfld:='';

END IF;

--Vu them 8848
if v_tltxcd ='8848' then
   SELECT max(decode(fldcd, '08' , CVALUE, '')),
          max(decode(fldcd, '01' , CVALUE, '')),
          max(decode(fldcd, '22' , CVALUE, '')),
          max(decode(fldcd, '07' , CVALUE, '')),
          max(decode(fldcd, '11' , NVALUE, '')),
          max(decode(fldcd, '12' , NVALUE, ''))
        into v_realdate ,v_orderID , v_NB , v_symcode,v_price ,v_symbol_qtty
        FROM tmp_tbl_tllogfld
        where txnum = pv_txnum
        and txdate = TO_DATE(pv_txdate,'DD/MM/RRRR');
   for rec in (
   select namt,tltxcd from vw_citran_gen
   where custodycd = v_custodycd and txcd ='0011'  and txdate = TO_DATE(v_realdate,'DD/MM/RRRR') and ref=v_orderID and tltxcd in ('8855','8865')
   )
   loop
    if rec.tltxcd = '8865' and v_NB ='NB' then
      v_trans_type := v_tltxcd||'01';
      v_amount := rec.namt;
      insert into gl_exp_tran( ref, txdate, txnum, busdate, custid, custodycd,
       custodycd_debit, custodycd_credit, bankid, trans_type,
       amount, symbol, symbol_qtty, symbol_price, costprice,
       txbrid, brid, tradeplace, iscorebank, status,
       custatcom, custtype, country, sectype, note,bankname,fullname,acname,dorc,reftran,apptype,actype,ISMAGIN,DEPID,TLID,AFACCTNO,alternateacct,typetrf,tobrid,typegr)
VALUES( seq_gltran.nextval,TO_DATE( V_TXDATE ,'DD/MM/YYYY') , pv_txnum,TO_DATE( v_busdate,'DD/MM/YYYY'), v_custid, v_custodycd,
       v_custodycd_debit, v_custodycd_credit, v_bankid, v_trans_type,
       v_amount, v_symbol, v_symbol_qtty, v_price, v_costprice,
       v_txbrid, v_brid, v_tradeplace, v_iscorebank, v_status,
       v_custatcom, v_custtype, v_country, v_sectype, v_note,v_bankname,v_fullname,v_acname,v_dorc,v_reftran,v_apptype,v_actype,v_strismagin,v_strDEPID,v_strTLID,v_acfld,v_alternateacct,v_typetrf,v_tobrid,v_typegr);
    else if rec.tltxcd = '8855' and v_NB ='NB' then
      v_trans_type := v_tltxcd||'02';
      v_amount := rec.namt;
      insert into gl_exp_tran( ref, txdate, txnum, busdate, custid, custodycd,
       custodycd_debit, custodycd_credit, bankid, trans_type,
       amount, symbol, symbol_qtty, symbol_price, costprice,
       txbrid, brid, tradeplace, iscorebank, status,
       custatcom, custtype, country, sectype, note,bankname,fullname,acname,dorc,reftran,apptype,actype,ISMAGIN,DEPID,TLID,AFACCTNO,alternateacct,typetrf,tobrid,typegr)
VALUES( seq_gltran.nextval,TO_DATE( V_TXDATE ,'DD/MM/YYYY') , pv_txnum,TO_DATE( v_busdate,'DD/MM/YYYY'), v_custid, v_custodycd,
       v_custodycd_debit, v_custodycd_credit, v_bankid, v_trans_type,
       v_amount, v_symbol, v_symbol_qtty, v_price, v_costprice,
       v_txbrid, v_brid, v_tradeplace, v_iscorebank, v_status,
       v_custatcom, v_custtype, v_country, v_sectype, v_note,v_bankname,v_fullname,v_acname,v_dorc,v_reftran,v_apptype,v_actype,v_strismagin,v_strDEPID,v_strTLID,v_acfld,v_alternateacct,v_typetrf,v_tobrid,v_typegr);
    end if;
    end if;
   end loop;
   if v_NB in ('NS','MS') then
       v_trans_type := v_tltxcd||'03';
       v_amount := '0';  v_apptype :='SE';
       select symbol into v_symbol from sbsecurities where codeid = v_symcode;
       if v_NB ='NS' then
          v_acname :='TRADE';
       else if v_NB ='MS' then
           v_acname :='MORTAGE';
       end if;
       end if;
       insert into gl_exp_tran( ref, txdate, txnum, busdate, custid, custodycd,
       custodycd_debit, custodycd_credit, bankid, trans_type,
       amount, symbol, symbol_qtty, symbol_price, costprice,
       txbrid, brid, tradeplace, iscorebank, status,
       custatcom, custtype, country, sectype, note,bankname,fullname,acname,dorc,reftran,apptype,actype,ISMAGIN,DEPID,TLID,AFACCTNO,alternateacct,typetrf,tobrid,typegr)
VALUES( seq_gltran.nextval,TO_DATE( V_TXDATE ,'DD/MM/YYYY') , pv_txnum,TO_DATE( v_busdate,'DD/MM/YYYY'), v_custid, v_custodycd,
       v_custodycd_debit, v_custodycd_credit, v_bankid, v_trans_type,
       v_amount, v_symbol, v_symbol_qtty, v_price, v_costprice,
       v_txbrid, v_brid, v_tradeplace, v_iscorebank, v_status,
       v_custatcom, v_custtype, v_country, v_sectype, v_note,v_bankname,v_fullname,v_acname,v_dorc,v_reftran,v_apptype,v_actype,v_strismagin,v_strDEPID,v_strTLID,v_acfld,v_alternateacct,v_typetrf,v_tobrid,v_typegr);
    end if;
end if;

--Vu them 8849

if v_tltxcd ='8849' then
   SELECT max(decode(fldcd, '08' , CVALUE, '')),
          max(decode(fldcd, '01' , CVALUE, '')),
          max(decode(fldcd, '22' , CVALUE, '')),
          max(decode(fldcd, '07' , CVALUE, '')),
          max(decode(fldcd, '11' , NVALUE, '')),
          max(decode(fldcd, '12' , NVALUE, ''))
        into v_realdate ,v_orderID , v_NB , v_symcode,v_price ,v_symbol_qtty
        FROM tmp_tbl_tllogfld
        where txnum = pv_txnum
        and txdate = TO_DATE(pv_txdate,'DD/MM/RRRR');
   select errreason into v_errcode from odmasthist where orderid =  v_orderID;
   for rec in (
   select namt,tltxcd from vw_citran_gen
   where custodycd = v_custodycd and txcd ='0011'  and txdate = TO_DATE(v_realdate,'DD/MM/RRRR') and ref=v_orderID and tltxcd in ('8855','8865')
   )
   loop
    if rec.tltxcd = '8865' and v_NB ='NB' and v_errcode in('02','03') THEN

      v_trans_type := v_tltxcd||'01';
      v_amount := rec.namt;
      insert into gl_exp_tran( ref, txdate, txnum, busdate, custid, custodycd,
       custodycd_debit, custodycd_credit, bankid, trans_type,
       amount, symbol, symbol_qtty, symbol_price, costprice,
       txbrid, brid, tradeplace, iscorebank, status,
       custatcom, custtype, country, sectype, note,bankname,fullname,acname,dorc,reftran,apptype,actype,T3,ismagin,DEPID,TLID,AFACCTNO,alternateacct,typetrf,tobrid,typegr)
VALUES( seq_gltran.nextval,TO_DATE( V_TXDATE ,'DD/MM/YYYY') , pv_txnum,TO_DATE( v_busdate,'DD/MM/YYYY'), v_custid, v_custodycd,
       v_custodycd_debit, v_custodycd_credit, v_bankid, v_trans_type,
       v_amount, v_symbol, v_symbol_qtty, v_price, v_costprice,
       v_txbrid, v_brid, v_tradeplace, v_iscorebank, v_status,
       v_custatcom, v_custtype, v_country, v_sectype, v_note,v_bankname,v_fullname,v_acname,v_dorc,v_reftran,v_apptype,v_actype,V_STRT3,v_strismagin,v_strDEPID,v_strTLID,v_acfld,v_alternateacct,v_typetrf,v_tobrid,v_typegr);
    else if rec.tltxcd = '8855' and v_NB ='NB' and v_errcode in('02','03') then
    SELECT    max(decode(fldcd, '14' , NVALUE, ''))
        into V_STRT3
        FROM tmp_tbl_tllogfld
        where txnum = pv_txnum
        and txdate = TO_DATE(pv_txdate,'DD/MM/RRRR');

    v_trans_type := v_tltxcd||'02';
      v_amount := rec.namt;

      insert into gl_exp_tran( ref, txdate, txnum, busdate, custid, custodycd,
       custodycd_debit, custodycd_credit, bankid, trans_type,
       amount, symbol, symbol_qtty, symbol_price, costprice,
       txbrid, brid, tradeplace, iscorebank, status,
       custatcom, custtype, country, sectype, note,bankname,fullname,acname,dorc,reftran,apptype,actype,T3,ismagin,DEPID,TLID,AFACCTNO,alternateacct,typetrf,tobrid,typegr)
VALUES( seq_gltran.nextval,TO_DATE( V_TXDATE ,'DD/MM/YYYY') , pv_txnum,TO_DATE( v_busdate,'DD/MM/YYYY'), v_custid, v_custodycd,
       v_custodycd_debit, v_custodycd_credit, v_bankid, v_trans_type,
       v_amount, v_symbol, v_symbol_qtty, v_price, v_costprice,
       v_txbrid, v_brid, v_tradeplace, v_iscorebank, v_status,
       v_custatcom, v_custtype, v_country, v_sectype, v_note,v_bankname,v_fullname,v_acname,v_dorc,v_reftran,v_apptype,v_actype,V_STRT3,v_strismagin,v_strDEPID,v_strTLID,v_acfld,v_alternateacct,v_typetrf,v_tobrid,v_typegr);
    end if;
    end if;
   end loop;
   if v_NB in ('NS','MS') and v_errcode in('02','03') then
       v_trans_type := v_tltxcd||'03';
       v_amount := '0'; v_apptype :='SE';
       select symbol into v_symbol from sbsecurities where codeid = v_symcode;
       if v_NB ='NS' then
          v_acname :='TRADE';
       else if v_NB ='MS' then
           v_acname :='MORTAGE';
       end if;
       end if;
       insert into gl_exp_tran( ref, txdate, txnum, busdate, custid, custodycd,
       custodycd_debit, custodycd_credit, bankid, trans_type,
       amount, symbol, symbol_qtty, symbol_price, costprice,
       txbrid, brid, tradeplace, iscorebank, status,
       custatcom, custtype, country, sectype, note,bankname,fullname,acname,dorc,reftran,apptype,actype,tlid,depid,ismagin,AFACCTNO,alternateacct,typetrf,tobrid,typegr)
VALUES( seq_gltran.nextval,TO_DATE( V_TXDATE ,'DD/MM/YYYY') , pv_txnum,TO_DATE( v_busdate,'DD/MM/YYYY'), v_custid, v_custodycd,
       v_custodycd_debit, v_custodycd_credit, v_bankid, v_trans_type,
       v_amount, v_symbol, v_symbol_qtty, v_price, v_costprice,
       v_txbrid, v_brid, v_tradeplace, v_iscorebank, v_status,
       v_custatcom, v_custtype, v_country, v_sectype, v_note,v_bankname,v_fullname,v_acname,v_dorc,v_reftran,v_apptype,v_actype,
        v_strTLID,v_strDEPID,v_strismagin,v_acfld,v_alternateacct,v_typetrf ,v_tobrid,v_typegr);
    end if;
end if;

------------------------------------------
V_STRT3:='';
IF v_tltxcd IN ('8865','8855') THEN

V_STRT3:= 'T'||TO_CHAR(v_str_trfbuyext)  ;
END IF;
IF v_tltxcd IN ('3354','3350') THEN
    begin
        select ca.catype into v_catype
        from vw_tllog_all tl,
        (
            select txnum, txdate, max(decode(fldcd,'02',cvalue,0)) camastid
            from vw_tllogfld_all
            where fldcd in ('02')
            group by txnum, txdate
        ) tf, camast ca
        where tl.txnum=tf.txnum and tl.txdate=tf.txdate
        and tf.camastid=ca.camastid(+)
        and tl.tltxcd IN ('3354','3350')
        and tl.txnum=pv_txnum and tl.txdate=TO_DATE(pv_txdate,'DD/MM/RRRR');
    EXCEPTION
        when OTHERS then
        v_catype := '';
    end;
    if v_catype = '015' and v_trans_type IN ('335402','335403','335002','335003') and nvl(v_symbol_qtty,0)+ nvl(v_amount,0) >0 then
       insert into gl_exp_tran( ref, txdate, txnum, busdate, custid, custodycd,
       custodycd_debit, custodycd_credit, bankid, trans_type,
       amount, symbol, symbol_qtty, symbol_price, costprice,
       txbrid, brid, tradeplace, iscorebank, status,
       custatcom, custtype, country, sectype, note,bankname,fullname,acname,dorc,reftran,apptype,actype,actype_debit,actype_credit,t3,ISVAT,ISMAGIN,DEPID,TLID,AFACCTNO,alternateacct,typetrf,tobrid,typegr)
       VALUES( seq_gltran.nextval,TO_DATE( V_TXDATE ,'DD/MM/YYYY') , pv_txnum,TO_DATE( v_busdate,'DD/MM/YYYY'), v_custid, v_custodycd,
               v_custodycd_debit, v_custodycd_credit, v_bankid, v_trans_type,
               v_amount, v_symbol, v_symbol_qtty, v_price, v_costprice,
               v_txbrid, v_brid, v_tradeplace, v_iscorebank, v_status,
               v_custatcom, v_custtype, v_country, v_sectype, v_note,v_bankname,v_fullname,v_acname,v_dorc,v_reftran,v_apptype,v_actype,v_actype_debit,v_actype_credit,V_STRT3,V_STRISVAT,v_strismagin,v_strDEPID,v_strTLID,v_acfld,v_alternateacct,v_typetrf,v_tobrid,v_typegr);
    else if v_catype <> '015' and nvl(v_symbol_qtty,0)+ nvl(v_amount,0) >0 then
        insert into gl_exp_tran( ref, txdate, txnum, busdate, custid, custodycd,
           custodycd_debit, custodycd_credit, bankid, trans_type,
           amount, symbol, symbol_qtty, symbol_price, costprice,
           txbrid, brid, tradeplace, iscorebank, status,
           custatcom, custtype, country, sectype, note,bankname,fullname,acname,dorc,reftran,apptype,actype,actype_debit,actype_credit,t3,ISVAT,ISMAGIN,DEPID,TLID,AFACCTNO,alternateacct,typetrf,tobrid,typegr)
       VALUES( seq_gltran.nextval,TO_DATE( V_TXDATE ,'DD/MM/YYYY') , pv_txnum,TO_DATE( v_busdate,'DD/MM/YYYY'), v_custid, v_custodycd,
               v_custodycd_debit, v_custodycd_credit, v_bankid, v_trans_type,
               v_amount, v_symbol, v_symbol_qtty, v_price, v_costprice,
               v_txbrid, v_brid, v_tradeplace, v_iscorebank, v_status,
               v_custatcom, v_custtype, v_country, v_sectype, v_note,v_bankname,v_fullname,v_acname,v_dorc,v_reftran,v_apptype,v_actype,v_actype_debit,v_actype_credit,V_STRT3,V_STRISVAT,v_strismagin,v_strDEPID,v_strTLID,v_acfld,v_alternateacct,v_typetrf,v_tobrid,v_typegr);
    end if;
    end if;
END IF;

if nvl(v_symbol_qtty,0)+ nvl(v_amount,0) >0 and v_tltxcd not in ('8848','8849','1134','1135','1136','1115','1121','3354','3350') then
insert into gl_exp_tran( ref, txdate, txnum, busdate, custid, custodycd,
       custodycd_debit, custodycd_credit, bankid, trans_type,
       amount, symbol, symbol_qtty, symbol_price, costprice,
       txbrid, brid, tradeplace, iscorebank, status,
       custatcom, custtype, country, sectype, note,bankname,fullname,acname,dorc,reftran,apptype,actype,actype_debit,actype_credit,t3,ISVAT,ISMAGIN,DEPID,TLID,AFACCTNO,alternateacct,typetrf,tobrid,typegr)
VALUES( seq_gltran.nextval,TO_DATE( V_TXDATE ,'DD/MM/YYYY') , pv_txnum,TO_DATE( v_busdate,'DD/MM/YYYY'), v_custid, v_custodycd,
       v_custodycd_debit, v_custodycd_credit, v_bankid, v_trans_type,
       v_amount, v_symbol, v_symbol_qtty, v_price, v_costprice,
       v_txbrid, v_brid, v_tradeplace, v_iscorebank, v_status,
       v_custatcom, v_custtype, v_country, v_sectype, v_note,v_bankname,v_fullname,v_acname,v_dorc,v_reftran,v_apptype,v_actype,v_actype_debit,v_actype_credit,V_STRT3,V_STRISVAT,v_strismagin,v_strDEPID,v_strTLID,v_acfld,v_alternateacct,v_typetrf,v_tobrid,v_typegr);

end if ;

end loop;
  CLOSE v_cursor_appmapbravo;


plog.error (pkgctx, '<<END OF SP_GENERATE_APPMAPBRAVO' || SYSDATE);

---------------------------------------------------------------------------

--  dbms_output.put_line('End');
EXCEPTION
  WHEN OTHERS
   THEN
        plog.error (pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
      RETURN;
END;
 
/
