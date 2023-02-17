SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE sp_generate_gljournal_inday
(  pv_txdate in VARCHAR,
   pv_txnum in VARCHAR,
   pv_errmsg out VARCHAR ) IS

  pkgctx   plog.log_ctx;
  logrow   tlogdebug%ROWTYPE;

v_txdate                         DATE;
v_txnum                          VARCHAR2(10);
v_busdate                        DATE;
v_custid                         VARCHAR2(10);
v_afacctno                       VARCHAR2(10);
v_custodycd                      VARCHAR2(10);
v_TLTXCD                         VARCHAR2(10);
v_POSTING_CODE                   VARCHAR2(50);
V_BANKID                        VARCHAR2(10);
v_BRID                           VARCHAR2(10);
v_GLGRP                          VARCHAR2(50);
v_AMOUNT                         NUMBER ;
v_BRDEBITACCT                    VARCHAR2(50);
v_BRCREDITACCT                   VARCHAR2(50);
v_BRNOTES                        VARCHAR2(500);
v_BRGRPTYPE                        VARCHAR2(10);
v_HODEBITACCT                    VARCHAR2(50);
v_HOCREDITACCT                   VARCHAR2(50);
v_HONOTES                        VARCHAR2(500);
v_HOGRPTYPE                      VARCHAR2(10);
v_REFCUSTOMER                    VARCHAR2(50);
v_currdate                       DATE ;
v_amtexp                          VARCHAR2(100);
v_pos_amtexp                      VARCHAR2(100);
v_expression                      VARCHAR2(100);
v_evaluator                       VARCHAR2(100);
v_ruBrid                          VARCHAR2(100);
v_actype                          VARCHAR2(100);
v_defbrid                         VARCHAR2(100);
v_code                            VARCHAR2(100);
V_gltypesubcd                     VARCHAR2(100);
V_glcusttype                      VARCHAR2(100);
V_SYMBOL                          VARCHAR2(100);
v_bridgl                          VARCHAR2(100);
V_typebridgl                       VARCHAR2(100);
v_class                            VARCHAR2(100);
v_fullname                          VARCHAR2(100);
v_autoid_glrule                VARCHAR2(100);
v_refci                        VARCHAR2(100);
v_catype                        VARCHAR2(100);
v_sumfeamtadv                  number ;
V_feeamtadv                    NUMBER ;
v_groupid                      VARCHAR2(100);
V_dueno                        VARCHAR2(100);
v_cfbrid                       VARCHAR2(100);
V_FEE_POSTING_CODE                    VARCHAR2(100);
v_parvalue                      number;
v_TYPEGL                         VARCHAR2(100);
--Khai bao con tro
cursor v_cursor_txmapglrules (v_tltxcd varchar2) is
select  * from txmapglrules
where tltxcd =v_tltxcd

;

v_txmapglrules_row v_cursor_txmapglrules%ROWTYPE;

BEGIN

v_txdate:= to_date( pv_txdate,'dd/mm/yyyy');
select to_date(varvalue,'dd/mm/yyyy') into v_currdate from sysvar where varname = 'CURRDATE';
delete from gljournal where txdate=to_date(pv_txdate,'dd/mm/rrrr') and txnum=pv_txnum;

--thong tin giao dich
 select tltxcd into v_tltxcd
 from TLLOG tl
 where tl.txdate=to_date(pv_txdate,'dd/mm/rrrr') and tl.txnum=pv_txnum;



--xac dinh so tieu khoan
begin
if v_tltxcd ='3387' then
    SELECT cvalue into v_afacctno  FROM TLLOGFLD WHERE TXNUM =pv_txnum and txdate =v_txdate and fldcd ='03';
ELSIF v_tltxcd IN ('1192','8894','2251','2266') then
    select substr(msgacct,1,10) into v_afacctno  from TLLOG where tltxcd IN('1192','8894','2251','2266') and TXNUM =pv_txnum and txdate =v_txdate;
else
    select max(acctno), max( bkdate), max(ref) into v_afacctno, v_busdate,v_refci  from citran where txnum = pv_txnum and txdate = v_txdate ;
end if ;
exception  when others then
v_afacctno :='';
v_busdate :='';
end ;

--xac dinh ma ck


begin
if v_tltxcd in ('8865','8856','8868','8866','8855','8867') then
select sb.symbol into v_symbol  from vw_odmast_all od,sbsecurities sb  where od.codeid = sb.codeid and  orderid = v_refci;
elsif v_tltxcd in ('3354','3384','3350','3386') then
select sb.symbol into v_symbol  from caschd ca,sbsecurities sb  where ca.codeid = sb.codeid and  CA.AUTOID = v_refci AND CA.deltd='N';
elsif v_tltxcd ='3387' then
    SELECT cvalue into v_symbol  FROM TLLOGFLD WHERE TXNUM =pv_txnum and txdate =v_txdate and fldcd ='04';
ELSE
--NGOAI BANG
select max(symbol),NVL( MAX(AFACCTNO),v_afacctno) into v_symbol,v_afacctno  from vw_setran_gen where txnum = pv_txnum and txdate = v_txdate ;
end if;
exception  when others then
v_symbol :='';
end ;


BEGIN
SELECT  parvalue INTO v_parvalue FROM  sbsecurities WHERE symbol = V_SYMBOL;
exception  when others then
v_parvalue :=0;

END ;


-- thong tin khach hang
begin

/*
select  cf.custid, custodycd,aftype.glgrptype,  aftype.actype , ( CASE WHEN  substr(custodycd,4,1) NOT IN ( 'C','F','P') THEN 'C' ELSE substr(custodycd,4,1) END  )
,cf.custtype, CASE WHEN tlgroups.shortname IN ('ANG','DON','VTU','HPH','CAT') THEN brgrp.glmapid ELSE brcf.glmapid END glmapid,fullname,cf.class,
brcf.glmapid||CASE WHEN tlgroups.shortname IN ('ANG','DON','VTU','HPH','CAT') THEN tlgroups.shortname ELSE '' END   CFBRID
into v_custid, v_custodycd, v_GLGRP,v_actype, V_gltypesubcd,V_glcusttype, v_BRIDGL,v_fullname,v_class,v_cfbrid
from cfmast cf, afmast af,aftype,brgrp ,tlgroups, brgrp brcf
where cf.custid = af.custid
and af.actype = aftype.actype
and cf.brid = brcf.brid
and cf.careby = tlgroups.grpid
and tlgroups.bridgl =brgrp.brid(+)
and af.acctno = v_afacctno;*/
select  cf.custid, custodycd,aftype.glgrptype,  aftype.actype , ( CASE WHEN  substr(custodycd,4,1) NOT IN ( 'C','F','P') THEN 'C' ELSE substr(custodycd,4,1) END  )
,cf.custtype, NVL( brgrp.glmapid , brcf.glmapid) glmapid ,fullname,cf.class,
brcf.glmapid||GRPGLMAP.glname   CFBRID
into v_custid, v_custodycd, v_GLGRP,v_actype, V_gltypesubcd,V_glcusttype, v_BRIDGL,v_fullname,v_class,v_cfbrid
from cfmast cf, afmast af,aftype,brgrp ,(SELECT * FROM GRPGLMAP WHERE status ='A') GRPGLMAP, brgrp brcf
where cf.custid = af.custid
and af.actype = aftype.actype
and cf.brid = brcf.brid
and cf.careby = GRPGLMAP.grpid(+)
and GRPGLMAP.bridgl =brgrp.brid(+)
and af.acctno = v_afacctno
;


exception  when others then
v_afacctno :='';
end ;


--xac dinh but toan
 OPEN v_cursor_txmapglrules(v_tltxcd);
      LOOP
        pv_errmsg:='Begin';
       FETCH v_cursor_txmapglrules INTO v_txmapglrules_row;
       EXIT WHEN v_cursor_txmapglrules%NOTFOUND;

v_defbrid := v_txmapglrules_row.defbrid;
v_amtexp := v_txmapglrules_row.amtexp;
v_posting_code := v_txmapglrules_row.POSTING_CODE;
v_TYPEGL := v_txmapglrules_row.TYPEGL;

if v_tltxcd in ('3350','3354') then
select ca.catype into v_catype from camast ca, caschd cas
where ca.camastid = cas.camastid
and cas.autoid = v_refci
and cas.deltd <>'Y';
    if substr(v_txmapglrules_row.amtexp,3,3)= v_catype then
    v_amtexp := substr( v_txmapglrules_row.amtexp,7);
    else
    continue;
    end if;
end if ;


-- xac dinh bankid

v_bankid:='-';
if v_tltxcd in ('1114','1141') then
select max(cvalue) into v_bankid  from TLLOGFLD where txnum = pv_txnum and txdate = v_txdate and fldcd ='02'  ;
end if ;

if v_tltxcd in ('1104','3387') then
select max(cvalue) into v_bankid  from TLLOGFLD where txnum = pv_txnum and txdate = v_txdate and fldcd ='05'  ;
end if ;

if v_tltxcd in ('2624','2646','2648') then
select max(cvalue) into v_groupid  from TLLOGFLD where txnum = pv_txnum and txdate = v_txdate and fldcd =case when v_tltxcd= '2648' then '05' else '20' end ;
select CASE WHEN RRTYPE ='B' THEN (SELECT SHORTNAME FROM CFMAST WHERE CUSTID= dfgroup.custbank  ) ELSE 'BMSC'  END  INTO V_BANKID
from (select * from dfgroup union all select * from dfgrouphist) dfgroup where groupid=v_groupid;
end if ;



IF  v_TLTXCD IN ('1153')  THEN

SELECT feeamt into V_SUMFEAMTADV  FROM adschd WHERE TXNUM =pv_txnum AND TXDATE = v_txdate;

if v_posting_code IN ('ADVPAYMENT_FEE','ADVPAYMENT_BANKINCOME','ADVPAYMENT_TAX')
 then
CONTINUE;
end if;


FOR REC IN (
/*    SELECT nvl( CF.shortname,'VCBS') BANKID, SUM( AD.AMT)  AMT
    ,ROUND( SUM(    ad.amt* ad.bankrate*(ADs.cleardt -ads.txdate)/(360*100) /(1 + ad.bankrate*(ADs.cleardt -ads.txdate)/(360*100) ) )) fee ,
     max(adtype.advrate) advrate,
     ROUND( SUM(ad.amt* (adtype.advrate)*(ADs.cleardt -ads.txdate)/(360*100)/ (1+(adtype.advrate)*(ADs.cleardt -ads.txdate)/(360*100))     ))-
     ROUND( SUM(ad.amt* ad.bankrate*(ADs.cleardt -ads.txdate)/(360*100) /( 1+ ad.bankrate*(ADs.cleardt -ads.txdate)/(360*100)  )   ))feec,
     ROUND( SUM(ad.amt* (adtype.advrate)*(ADs.cleardt -ads.txdate)/(360*100)/(1+(adtype.advrate)*(ADs.cleardt -ads.txdate)/(360*100))  ))feea,
     MAX(ads.feeamt) feeamt ,AD.rrtype
     FROM vw_advsreslog_all AD, CFMAST CF,adschd ads,adtype
    WHERE ad.txdate = ads.txdate
        and ad.txnum = ads.txnum
        AND AD.CUSTBANK = CF.CUSTID
        and ads.adtype= adtype.actype
        and ad.TXNUM =pv_txnum AND ad.TXDATE = v_txdate
    GROUP BY  CF.shortname,AD.rrtype
    order by AD.rrtype*/
     SELECT nvl( CF.shortname,'BMSC') BANKID, SUM( AD.AMT)  AMT
    --PHI NGAN HANG
    ,SUM( feeadvb ) fee ,
     max(adtype.advrate) advrate,
     SUM(feeadv)-
     SUM(feeadvb)feec,
     SUM(feeadv )feea,
     MAX(ads.feeamt) feeamt ,AD.rrtype
     FROM vw_advsreslog_all AD, CFMAST CF,adschd ads,adtype
    WHERE ad.txdate = ads.txdate
        and ad.txnum = ads.txnum
        AND AD.CUSTBANK = CF.CUSTID
        and ads.adtype= adtype.actype
        and ad.TXNUM =pv_txnum AND ad.TXDATE = v_txdate
    GROUP BY  CF.shortname,AD.rrtype
    order by AD.rrtype

    )
loop
-- goc
    SELECT max(brid||gltypesubcd||glcusttype||BANKID||class) into v_code from glrules
    where posting_code ='ADVPAYMENT_DISBURSEMENT'
    AND instr( decode (gltypesubcd,'ALL',V_gltypesubcd,gltypesubcd), V_gltypesubcd)>0
    AND  decode( GLCUSTTYPE,'ALL', V_glcusttype,GLCUSTTYPE)= V_glcusttype
    AND decode( brid,'BR0000', v_bridgl,brid) = v_bridgl
    AND decode( BANKID,'ALL', V_BANKID,BANKID) = rec.BANKID
    and class = v_class
    AND CHSTATUS ='C';



    select max(autoid) into  v_autoid_glrule  from glrules where posting_code =v_posting_code and  brid||gltypesubcd||glcusttype||BANKID||class = v_code AND CHSTATUS ='C';

   -- lAY THONG TIN BO BUT  TOAN
    SELECT GLGRP, BRDEBITACCT,BRCREDITACCT,BRNOTES,brGRPTYPE,HODEBITACCT,HOCREDITACCT,HONOTES,HOGRPTYPE,BRNOTES,HONOTES,bridgl
    into
    v_GLGRP, v_BRDEBITACCT,v_BRCREDITACCT,v_BRNOTES,v_brGRPTYPE,v_HODEBITACCT,v_HOCREDITACCT,v_HONOTES,v_HOGRPTYPE, v_BRNOTES,v_HONOTES,V_typebridgl
    FROM glrules where posting_code =v_posting_code AND autoid = v_autoid_glrule AND CHSTATUS ='C';

   IF V_TYPEBRIDGL ='HS' THEN
   v_BRID :='BR001';
   ELSE
   v_BRID := v_bridgl ;
   END IF ;

   V_BRNOTES:= REPLACE(  REPLACE( REPLACE( REPLACE( REPLACE( REPLACE ( V_BRNOTES,'DDMMYYYY',PV_TXDATE),'CUSTODYCD',V_CUSTODYCD),'AFACCTNO',V_AFACCTNO),'SYMBOL',V_SYMBOL),'NAME',v_fullname),'BRID',v_bridgl);
   V_HONOTES:= REPLACE( REPLACE( REPLACE( REPLACE( REPLACE( REPLACE ( V_HONOTES,'DDMMYYYY',PV_TXDATE),'CUSTODYCD',V_CUSTODYCD),'AFACCTNO',V_AFACCTNO),'SYMBOL',V_SYMBOL),'NAME',v_fullname),'BRID',v_bridgl);

    INSERT INTO gljournal
    (ref,txdate,txnum,busdate,custid,afacctno,custodycd,tltxcd,posting_code,bankid,brid,glgrp,amount,brdebitacct,brcreditacct,brnotes,grptype,hodebitacct,hocreditacct,honotes,hogrptype,refcustomer,BRIDGL,cfbrid)
    VALUES (seq_gljournal.NEXTVAL, V_TXDATE,pv_txnum ,v_BUSDATE,v_custid,v_afacctno,v_custodycd,v_TLTXCD,'ADVPAYMENT_DISBURSEMENT',V_BANKID,v_BRID,v_GLGRP,rec.amt,v_BRDEBITACCT,v_BRCREDITACCT ,v_BRNOTES,v_BRGRPTYPE,v_HODEBITACCT,v_HOCREDITACCT,v_HONOTES,v_HOGRPTYPE,v_REFCUSTOMER,v_bridgl,v_cfbrid );
--lai

    if rec.rrtype ='B' then
    V_feeamtadv :=  rec.fee;
    v_sumfeamtadv:=v_sumfeamtadv - rec.feea ;
    ELSIF rec.rrtype ='C' then
     V_feeamtadv := v_sumfeamtadv ;
    end if;

    IF rec.rrtype ='B' THEN
        V_FEE_POSTING_CODE:='ADVPAYMENT_BANKINCOME';
        else
       V_FEE_POSTING_CODE:='ADVPAYMENT_FEE';
   end if;


    SELECT max(brid||gltypesubcd||glcusttype||BANKID||class) into v_code from glrules
    where posting_code =V_FEE_POSTING_CODE
    AND instr( decode (gltypesubcd,'ALL',V_gltypesubcd,gltypesubcd), V_gltypesubcd)>0
    AND  decode( GLCUSTTYPE,'ALL', V_glcusttype,GLCUSTTYPE)= V_glcusttype
    AND decode( brid,'BR0000', v_bridgl,brid) = v_bridgl
    AND decode( BANKID,'ALL', V_BANKID,BANKID) = rec.BANKID
    and class = v_class
    AND CHSTATUS ='C';



    select max(autoid) into  v_autoid_glrule  from glrules where posting_code =V_FEE_POSTING_CODE and  brid||gltypesubcd||glcusttype||BANKID||class = v_code AND CHSTATUS ='C';

   -- lAY THONG TIN BO BUT  TOAN
    SELECT GLGRP, BRDEBITACCT,BRCREDITACCT,BRNOTES,brGRPTYPE,HODEBITACCT,HOCREDITACCT,HONOTES,HOGRPTYPE,BRNOTES,HONOTES,bridgl
    into
    v_GLGRP, v_BRDEBITACCT,v_BRCREDITACCT,v_BRNOTES,v_brGRPTYPE,v_HODEBITACCT,v_HOCREDITACCT,v_HONOTES,v_HOGRPTYPE, v_BRNOTES,v_HONOTES,V_typebridgl
    FROM glrules where posting_code =V_FEE_POSTING_CODE AND autoid = v_autoid_glrule AND CHSTATUS ='C';

  if V_typebridgl ='HS' THEN
   v_BRID :='BR001';
   ELSE
   v_BRID := v_bridgl ;
   END IF ;

   V_BRNOTES:= REPLACE(  REPLACE( REPLACE( REPLACE( REPLACE( REPLACE ( V_BRNOTES,'DDMMYYYY',PV_TXDATE),'CUSTODYCD',V_CUSTODYCD),'AFACCTNO',V_AFACCTNO),'SYMBOL',V_SYMBOL),'NAME',v_fullname),'BRID',v_bridgl);
   V_HONOTES:= REPLACE( REPLACE( REPLACE( REPLACE( REPLACE( REPLACE ( V_HONOTES,'DDMMYYYY',PV_TXDATE),'CUSTODYCD',V_CUSTODYCD),'AFACCTNO',V_AFACCTNO),'SYMBOL',V_SYMBOL),'NAME',v_fullname),'BRID',v_bridgl);

  INSERT INTO gljournal
    (ref,txdate,txnum,busdate,custid,afacctno,custodycd,tltxcd,posting_code,bankid,brid,glgrp,amount,brdebitacct,brcreditacct,brnotes,grptype,hodebitacct,hocreditacct,honotes,hogrptype,refcustomer,BRIDGL,cfbrid)
    VALUES (seq_gljournal.NEXTVAL, V_TXDATE,pv_txnum ,v_BUSDATE,v_custid,v_afacctno,v_custodycd,v_TLTXCD,V_FEE_POSTING_CODE,V_BANKID,v_BRID,v_GLGRP,V_feeamtadv,v_BRDEBITACCT,v_BRCREDITACCT ,v_BRNOTES,v_BRGRPTYPE,v_HODEBITACCT,v_HOCREDITACCT,v_HONOTES,v_HOGRPTYPE,v_REFCUSTOMER,v_bridgl,v_cfbrid );

if rec.rrtype ='B' THEN

  SELECT max(brid||gltypesubcd||glcusttype||BANKID||class) into v_code from glrules
    where posting_code =V_FEE_POSTING_CODE
    AND instr( decode (gltypesubcd,'ALL',V_gltypesubcd,gltypesubcd), V_gltypesubcd)>0
    AND  decode( GLCUSTTYPE,'ALL', V_glcusttype,GLCUSTTYPE)= V_glcusttype
    AND decode( brid,'BR0000', v_bridgl,brid) = v_bridgl
    AND decode( BANKID,'ALL', V_BANKID,BANKID) = 'BMSC'
    and class = v_class
    AND CHSTATUS ='C';

    select max(autoid) into  v_autoid_glrule  from glrules where posting_code =V_FEE_POSTING_CODE and  brid||gltypesubcd||glcusttype||BANKID||class = v_code AND CHSTATUS ='C';

   -- lAY THONG TIN BO BUT  TOAN
    SELECT GLGRP, BRDEBITACCT,BRCREDITACCT,BRNOTES,brGRPTYPE,HODEBITACCT,HOCREDITACCT,HONOTES,HOGRPTYPE,BRNOTES,HONOTES,bridgl
    into
    v_GLGRP, v_BRDEBITACCT,v_BRCREDITACCT,v_BRNOTES,v_brGRPTYPE,v_HODEBITACCT,v_HOCREDITACCT,v_HONOTES,v_HOGRPTYPE, v_BRNOTES,v_HONOTES,V_typebridgl
    FROM glrules where posting_code =V_FEE_POSTING_CODE  AND autoid = v_autoid_glrule AND CHSTATUS ='C';

  if V_typebridgl ='HS' THEN
   v_BRID :='BR001';
   ELSE
   v_BRID := v_bridgl ;
   END IF ;

   V_BRNOTES:= REPLACE(  REPLACE( REPLACE( REPLACE( REPLACE( REPLACE ( V_BRNOTES,'DDMMYYYY',PV_TXDATE),'CUSTODYCD',V_CUSTODYCD),'AFACCTNO',V_AFACCTNO),'SYMBOL',V_SYMBOL),'NAME',v_fullname),'BRID',v_bridgl);
   V_HONOTES:= REPLACE( REPLACE( REPLACE( REPLACE( REPLACE( REPLACE ( V_HONOTES,'DDMMYYYY',PV_TXDATE),'CUSTODYCD',V_CUSTODYCD),'AFACCTNO',V_AFACCTNO),'SYMBOL',V_SYMBOL),'NAME',v_fullname),'BRID',v_bridgl);


  INSERT INTO gljournal
    (ref,txdate,txnum,busdate,custid,afacctno,custodycd,tltxcd,posting_code,bankid,brid,glgrp,amount,brdebitacct,brcreditacct,brnotes,grptype,hodebitacct,hocreditacct,honotes,hogrptype,refcustomer,BRIDGL,cfbrid)
    VALUES (seq_gljournal.NEXTVAL, V_TXDATE,pv_txnum ,v_BUSDATE,v_custid,v_afacctno,v_custodycd,v_TLTXCD,V_FEE_POSTING_CODE,V_BANKID,v_BRID,v_GLGRP,round(rec.feec/1.1),v_BRDEBITACCT,v_BRCREDITACCT ,v_BRNOTES,v_BRGRPTYPE,v_HODEBITACCT,v_HOCREDITACCT,v_HONOTES,v_HOGRPTYPE,v_REFCUSTOMER,v_bridgl,v_cfbrid );


  SELECT max(brid||gltypesubcd||glcusttype||BANKID||class) into v_code from glrules
    where posting_code ='ADVPAYMENT_TAX'
    AND instr( decode (gltypesubcd,'ALL',V_gltypesubcd,gltypesubcd), V_gltypesubcd)>0
    AND  decode( GLCUSTTYPE,'ALL', V_glcusttype,GLCUSTTYPE)= V_glcusttype
    AND decode( brid,'BR0000', v_bridgl,brid) = v_bridgl
--    AND decode( BANKID,'ALL', V_BANKID,BANKID) =   'VCBS'
    and class = v_class AND CHSTATUS ='C';

    select max(autoid) into  v_autoid_glrule  from glrules where posting_code ='ADVPAYMENT_TAX' and  brid||gltypesubcd||glcusttype||BANKID||class = v_code AND CHSTATUS ='C';

   -- lAY THONG TIN BO BUT  TOAN
    SELECT GLGRP, BRDEBITACCT,BRCREDITACCT,BRNOTES,brGRPTYPE,HODEBITACCT,HOCREDITACCT,HONOTES,HOGRPTYPE,BRNOTES,HONOTES,bridgl
    into
    v_GLGRP, v_BRDEBITACCT,v_BRCREDITACCT,v_BRNOTES,v_brGRPTYPE,v_HODEBITACCT,v_HOCREDITACCT,v_HONOTES,v_HOGRPTYPE, v_BRNOTES,v_HONOTES,V_typebridgl
    FROM glrules where posting_code ='ADVPAYMENT_TAX'  AND autoid = v_autoid_glrule AND CHSTATUS ='C';

  if V_typebridgl ='HS' THEN
   v_BRID :='BR001';
   ELSE
   v_BRID := v_bridgl ;
   END IF ;

   V_BRNOTES:= REPLACE(  REPLACE( REPLACE( REPLACE( REPLACE( REPLACE ( V_BRNOTES,'DDMMYYYY',PV_TXDATE),'CUSTODYCD',V_CUSTODYCD),'AFACCTNO',V_AFACCTNO),'SYMBOL',V_SYMBOL),'NAME',v_fullname),'BRID',v_bridgl);
   V_HONOTES:= REPLACE( REPLACE( REPLACE( REPLACE( REPLACE( REPLACE ( V_HONOTES,'DDMMYYYY',PV_TXDATE),'CUSTODYCD',V_CUSTODYCD),'AFACCTNO',V_AFACCTNO),'SYMBOL',V_SYMBOL),'NAME',v_fullname),'BRID',v_bridgl);


  INSERT INTO gljournal
    (ref,txdate,txnum,busdate,custid,afacctno,custodycd,tltxcd,posting_code,bankid,brid,glgrp,amount,brdebitacct,brcreditacct,brnotes,grptype,hodebitacct,hocreditacct,honotes,hogrptype,refcustomer,BRIDGL,cfbrid)
    VALUES (seq_gljournal.NEXTVAL, V_TXDATE,pv_txnum ,v_BUSDATE,v_custid,v_afacctno,v_custodycd,v_TLTXCD,'ADVPAYMENT_TAX',V_BANKID,v_BRID,v_GLGRP,round(rec.feec*10/110),v_BRDEBITACCT,v_BRCREDITACCT ,v_BRNOTES,v_BRGRPTYPE,v_HODEBITACCT,v_HOCREDITACCT,v_HONOTES,v_HOGRPTYPE,v_REFCUSTOMER,v_bridgl,v_cfbrid );

END IF;


end loop ;


--HOAN UNG
ELSIF v_TLTXCD IN ('8851') THEN

SELECT nvalue into V_dueno FROM TLLOGFLD WHERE  TXNUM = pv_txnum AND TXDATE  =v_txdate AND fldcd='09';

for rec in (
SELECT nvl( CF.shortname,'BMSC') BANKID, AD.AMT  , ads.feeamt,AD.rrtype
 FROM vw_advsreslog_all AD, CFMAST CF,adschd ads
WHERE ad.txdate = ads.txdate
and ad.txnum = ads.txnum
and ads.autoid =V_dueno
AND AD.CUSTBANK = CF.CUSTID(+)
order by AD.rrtype
)
loop

-- goc

    SELECT max(brid||gltypesubcd||glcusttype||BANKID||class) into v_code from glrules
    where posting_code =v_posting_code
    AND instr( decode (gltypesubcd,'ALL',V_gltypesubcd,gltypesubcd), V_gltypesubcd)>0
    AND  decode( GLCUSTTYPE,'ALL', V_glcusttype,GLCUSTTYPE)= V_glcusttype
    AND decode( brid,'BR0000', v_bridgl,brid) = v_bridgl
    AND decode( BANKID,'ALL', V_BANKID,BANKID) = rec.BANKID
    and class = v_class AND CHSTATUS ='C';

    select max(autoid) into  v_autoid_glrule  from glrules where posting_code =v_posting_code and  brid||gltypesubcd||glcusttype||BANKID||class = v_code AND CHSTATUS ='C';

   -- lAY THONG TIN BO BUT  TOAN
    SELECT GLGRP, BRDEBITACCT,BRCREDITACCT,BRNOTES,brGRPTYPE,HODEBITACCT,HOCREDITACCT,HONOTES,HOGRPTYPE,BRNOTES,HONOTES,bridgl
    into
    v_GLGRP, v_BRDEBITACCT,v_BRCREDITACCT,v_BRNOTES,v_brGRPTYPE,v_HODEBITACCT,v_HOCREDITACCT,v_HONOTES,v_HOGRPTYPE, v_BRNOTES,v_HONOTES,V_typebridgl
    FROM glrules where posting_code =v_posting_code AND autoid = v_autoid_glrule AND CHSTATUS ='C';

   if V_typebridgl ='HS' THEN
   v_BRID :='BR001';
   ELSE
   v_BRID := v_bridgl ;
   END IF ;

   V_BRNOTES:= REPLACE(  REPLACE( REPLACE( REPLACE( REPLACE( REPLACE ( V_BRNOTES,'DDMMYYYY',PV_TXDATE),'CUSTODYCD',V_CUSTODYCD),'AFACCTNO',V_AFACCTNO),'SYMBOL',V_SYMBOL),'NAME',v_fullname),'BRID',v_bridgl);
   V_HONOTES:= REPLACE( REPLACE( REPLACE( REPLACE( REPLACE( REPLACE ( V_HONOTES,'DDMMYYYY',PV_TXDATE),'CUSTODYCD',V_CUSTODYCD),'AFACCTNO',V_AFACCTNO),'SYMBOL',V_SYMBOL),'NAME',v_fullname),'BRID',v_bridgl);


    INSERT INTO gljournal
    (ref,txdate,txnum,busdate,custid,afacctno,custodycd,tltxcd,posting_code,bankid,brid,glgrp,amount,brdebitacct,brcreditacct,brnotes,grptype,hodebitacct,hocreditacct,honotes,hogrptype,refcustomer,BRIDGL,cfbrid)
    VALUES (seq_gljournal.NEXTVAL, V_TXDATE,pv_txnum ,v_BUSDATE,v_custid,v_afacctno,v_custodycd,v_TLTXCD,v_posting_code,V_BANKID,v_BRID,v_GLGRP,rec.amt,v_BRDEBITACCT,v_BRCREDITACCT ,v_BRNOTES,v_BRGRPTYPE,v_HODEBITACCT,v_HOCREDITACCT,v_HONOTES,v_HOGRPTYPE,v_REFCUSTOMER,v_bridgl,v_cfbrid );


END LOOP;

ELSIF v_TLTXCD IN ('0088') THEN


for rec in (
SELECT NAMT, CASE WHEN txcd ='0012' THEN 'CLOSE_ACCOUNT_INTEREST'
                  WHEN txcd ='0011' AND  INSTR (trdesc,'TK')=0 THEN 'COLLECT_DEPOSITORY_FEE'
                  WHEN txcd ='0011' AND  INSTR (trdesc,'TK')>0 THEN 'PHI CHUYEN KHOAN CHUNG KHOAN'
                  END posting_code
  FROM vw_citran_gen where tltxcd ='0088' and field='BALANCE' AND   TXNUM = pv_txnum AND TXDATE  =v_txdate
  AND  CASE WHEN txcd ='0012' THEN 'CLOSE_ACCOUNT_INTEREST'
                  WHEN txcd ='0011' AND  INSTR (trdesc,'TK')=0 THEN 'COLLECT_DEPOSITORY_FEE'
                  WHEN txcd ='0011' AND  INSTR (trdesc,'TK')>0 THEN 'PHI CHUYEN KHOAN CHUNG KHOAN'
                  END =v_posting_code
           )
loop
-- goc

    SELECT max(brid||gltypesubcd||glcusttype||BANKID||class) into v_code from glrules
    where posting_code =v_posting_code
    AND instr( decode (gltypesubcd,'ALL',V_gltypesubcd,gltypesubcd), V_gltypesubcd)>0
    AND  decode( GLCUSTTYPE,'ALL', V_glcusttype,GLCUSTTYPE)= V_glcusttype
    AND decode( brid,'BR0000', v_bridgl,brid) = v_bridgl
    AND decode( BANKID,'ALL', V_BANKID,BANKID) = V_BANKID
    and class = v_class AND CHSTATUS ='C';

    select max(autoid) into  v_autoid_glrule  from glrules where posting_code =v_posting_code and  brid||gltypesubcd||glcusttype||BANKID||class = v_code AND CHSTATUS ='C';

   -- lAY THONG TIN BO BUT  TOAN
    SELECT GLGRP, BRDEBITACCT,BRCREDITACCT,BRNOTES,brGRPTYPE,HODEBITACCT,HOCREDITACCT,HONOTES,HOGRPTYPE,BRNOTES,HONOTES,bridgl
    into
    v_GLGRP, v_BRDEBITACCT,v_BRCREDITACCT,v_BRNOTES,v_brGRPTYPE,v_HODEBITACCT,v_HOCREDITACCT,v_HONOTES,v_HOGRPTYPE, v_BRNOTES,v_HONOTES,V_typebridgl
    FROM glrules where posting_code =v_posting_code AND autoid = v_autoid_glrule AND CHSTATUS ='C';

   if V_typebridgl ='HS' THEN
   v_BRID :='BR001';
   ELSE
   v_BRID := v_bridgl ;
   END IF ;

   V_BRNOTES:= REPLACE(  REPLACE( REPLACE( REPLACE( REPLACE( REPLACE ( V_BRNOTES,'DDMMYYYY',PV_TXDATE),'CUSTODYCD',V_CUSTODYCD),'AFACCTNO',V_AFACCTNO),'SYMBOL',V_SYMBOL),'NAME',v_fullname),'BRID',v_bridgl);
   V_HONOTES:= REPLACE( REPLACE( REPLACE( REPLACE( REPLACE( REPLACE ( V_HONOTES,'DDMMYYYY',PV_TXDATE),'CUSTODYCD',V_CUSTODYCD),'AFACCTNO',V_AFACCTNO),'SYMBOL',V_SYMBOL),'NAME',v_fullname),'BRID',v_bridgl);


    INSERT INTO gljournal
    (ref,txdate,txnum,busdate,custid,afacctno,custodycd,tltxcd,posting_code,bankid,brid,glgrp,amount,brdebitacct,brcreditacct,brnotes,grptype,hodebitacct,hocreditacct,honotes,hogrptype,refcustomer,BRIDGL,cfbrid)
    VALUES (seq_gljournal.NEXTVAL, V_TXDATE,pv_txnum ,v_BUSDATE,v_custid,v_afacctno,v_custodycd,v_TLTXCD,v_posting_code,V_BANKID,v_BRID,v_GLGRP,rec.namt,v_BRDEBITACCT,v_BRCREDITACCT ,v_BRNOTES,v_BRGRPTYPE,v_HODEBITACCT,v_HOCREDITACCT,v_HONOTES,v_HOGRPTYPE,v_REFCUSTOMER,v_bridgl,v_cfbrid );


END LOOP;

ELSE



-- voi giao dich hach toan 2 tieu khoan tien
IF v_TLTXCD in ('2244','2266') then

            if v_TLTXCD = '2244' then
                if v_txmapglrules_row.amtexp  in ('45','46') then
                   select SUBSTR(msgacct,1,10)  into v_afacctno  from vw_tllog_all where tltxcd ='2244' and TXNUM =pv_txnum and txdate =v_txdate;
                else
                   select SUBSTR(msgacct,1,10)  into v_afacctno  from vw_tllog_all where tltxcd ='2244' and TXNUM =pv_txnum and txdate =v_txdate;
                   select max(acctno)  into v_afacctno  from vw_citran_gen where acctno <> v_afacctno and TXNUM =pv_txnum and txdate =v_txdate ;
                 end if  ;
            end if ;
            if v_TLTXCD = '2266' then
                 if v_txmapglrules_row.amtexp  in ('27','26') then
                    select SUBSTR(msgacct,1,10)  into v_afacctno  from vw_tllog_all where tltxcd ='2266' and TXNUM =pv_txnum and txdate =v_txdate;
                 else
                  SELECT ACCTNO  into v_afacctno FROM AFMAST WHERE ACCTNO IN ( SELECT cvalue  FROM TLLOGFLD WHERE TXNUM =pv_txnum and txdate =v_txdate and fldcd ='55');
                 end if  ;
            end if;

 IF v_afacctno is null
 THEN
CONTINUE;
END IF;
    begin

/*    select  cf.custid, custodycd,aftype.glgrptype,  aftype.actype , ( CASE WHEN  substr(custodycd,4,1) NOT IN ( 'C','F','P') THEN 'C' ELSE substr(custodycd,4,1) END  )
    ,cf.custtype, CASE WHEN tlgroups.shortname IN ('ANG','DON','VTU','HPH','CAT') THEN brgrp.glmapid ELSE brcf.glmapid END glmapid ,fullname,cf.class,
    brcf.glmapid||CASE WHEN tlgroups.shortname IN ('ANG','DON','VTU','HPH','CAT') THEN tlgroups.shortname ELSE '' END   CFBRID
    into v_custid, v_custodycd, v_GLGRP,v_actype, V_gltypesubcd,V_glcusttype, v_BRIDGL,v_fullname,v_class,v_cfbrid
    from cfmast cf, afmast af,aftype,brgrp ,tlgroups, brgrp brcf
    where cf.custid = af.custid
    and af.actype = aftype.actype
    and cf.brid = brcf.brid
    and cf.careby = tlgroups.grpid
    and tlgroups.bridgl =brgrp.brid(+)
    and af.acctno = v_afacctno;
*/
select  cf.custid, custodycd,aftype.glgrptype,  aftype.actype , ( CASE WHEN  substr(custodycd,4,1) NOT IN ( 'C','F','P') THEN 'C' ELSE substr(custodycd,4,1) END  )
,cf.custtype, NVL( brgrp.glmapid , brcf.glmapid) glmapid ,fullname,cf.class,
brcf.glmapid||GRPGLMAP.glname   CFBRID
into v_custid, v_custodycd, v_GLGRP,v_actype, V_gltypesubcd,V_glcusttype, v_BRIDGL,v_fullname,v_class,v_cfbrid
from cfmast cf, afmast af,aftype,brgrp ,(SELECT * FROM GRPGLMAP WHERE status ='A') GRPGLMAP, brgrp brcf
where cf.custid = af.custid
and af.actype = aftype.actype
and cf.brid = brcf.brid
and cf.careby = GRPGLMAP.grpid(+)
and GRPGLMAP.bridgl =brgrp.brid(+)
and af.acctno = v_afacctno
;
    exception  when others then
    v_afacctno :='';
    end ;

end if ;

-- XAC DINH BUT TOAN THEO BRID GLTYPESUBCD GLCUSTTYPE
BEGIN
    -- XAC DINH BUT TOAN THEO BRID GLTYPESUBCD GLCUSTTYPE
SELECT max(brid||gltypesubcd||glcusttype||BANKID||class||GLGRP) into v_code from glrules
    where posting_code =v_posting_code
    AND instr( decode (gltypesubcd,'ALL',V_gltypesubcd,gltypesubcd), V_gltypesubcd)>0
    AND  decode( GLCUSTTYPE,'ALL', V_glcusttype,GLCUSTTYPE)= V_glcusttype
    AND decode( brid,'BR0000', v_bridgl,brid) = v_bridgl
    AND decode( BANKID,'ALL', V_BANKID,BANKID) = V_BANKID
     AND decode( GLGRP,'ALL', v_actype,GLGRP) = v_actype
    and class = v_class
    AND CHSTATUS ='C'
    ;


  plog.debug(pkgctx, '01_GL v_posting_code:'||v_posting_code);
  plog.debug(pkgctx, '02_GL v_custodycd:'||v_custodycd);
  plog.debug(pkgctx, '03_GL V_gltypesubcd:'||V_gltypesubcd);
  plog.debug(pkgctx, '04_GL V_glcusttype:'||V_glcusttype);
  plog.debug(pkgctx, '05_GL v_bridgl:'||v_bridgl);
  plog.debug(pkgctx, '06_GL V_BANKID:'||V_BANKID);
  plog.debug(pkgctx, '07_GL v_class:'||v_class);
  plog.debug(pkgctx, '08_GL v_cfbrid:'||v_cfbrid);
  plog.debug(pkgctx, '09_GL v_code:'||v_code);


    select max(autoid) into  v_autoid_glrule  from glrules where posting_code =v_posting_code and  brid||gltypesubcd||glcusttype||BANKID||class||GLGRP  = v_code AND CHSTATUS ='C';

 plog.debug(pkgctx, '10_GL v_autoid_glrule:'||v_autoid_glrule);

   -- lAY THONG TIN BO BUT  TOAN
    SELECT GLGRP, BRDEBITACCT,BRCREDITACCT,BRNOTES,brGRPTYPE,HODEBITACCT,HOCREDITACCT,HONOTES,HOGRPTYPE,BRNOTES,HONOTES,bridgl
    into
    v_GLGRP, v_BRDEBITACCT,v_BRCREDITACCT,v_BRNOTES,v_brGRPTYPE,v_HODEBITACCT,v_HOCREDITACCT,v_HONOTES,v_HOGRPTYPE, v_BRNOTES,v_HONOTES,V_typebridgl
    FROM glrules where posting_code =v_posting_code AND autoid = v_autoid_glrule AND CHSTATUS ='C';

EXCEPTION
    WHEN OTHERS THEN
v_BRDEBITACCT:='';
v_BRCREDITACCT:='';
END ;


IF v_BRDEBITACCT is NOT NULL OR  v_BRCREDITACCT is NOT NULL THEN

--gan gia tri
--tinh gia tri amount
if v_amtexp is not null then

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
                  /*     IF TO_DATE(pv_txdate,'DD/MM/RRRR') = getcurrdate THEN

                       SELECT NVALUE+TO_NUMBER(NVL(CVALUE,0)) INTO v_amount FROM  TLLOGFLD
                       WHERE TXDATE=TO_DATE(pv_txdate,'DD/MM/RRRR') AND TXNUM=pv_txnum AND FLDCD=v_evaluator;
                       v_expression:=v_expression || v_amount;

                       ELSE*/

                       SELECT NVALUE+TO_NUMBER(NVL(CVALUE,0)) INTO v_amount FROM  TLLOGFLD TL
                       WHERE TXDATE=TO_DATE(pv_txdate,'DD/MM/RRRR') AND TXNUM=pv_txnum AND FLDCD=v_evaluator;
                       v_expression:=v_expression || v_amount;

--                       END IF;
                       END;
                    END IF;
                END LOOP;
          v_expression:='UPDATE EVAL_EXPRESSTION SET EVAL=' || v_expression;
          execute immediate v_expression;
          pv_errmsg:='Evaluate: ' || v_expression;
          SELECT round(EVAL) INTO v_amount FROM EVAL_EXPRESSTION;
UPDATE EVAL_EXPRESSTION SET EVAL =0;

end if;

   if V_typebridgl ='HS' THEN
   v_BRID :='BR001';
   ELSE
   v_BRID := v_bridgl ;
   END IF ;

   V_BRNOTES:= REPLACE(  REPLACE( REPLACE( REPLACE( REPLACE( REPLACE ( V_BRNOTES,'DDMMYYYY',PV_TXDATE),'CUSTODYCD',V_CUSTODYCD),'AFACCTNO',V_AFACCTNO),'SYMBOL',V_SYMBOL),'NAME',v_fullname),'BRID',v_bridgl);
   V_HONOTES:= REPLACE( REPLACE( REPLACE( REPLACE( REPLACE( REPLACE ( V_HONOTES,'DDMMYYYY',PV_TXDATE),'CUSTODYCD',V_CUSTODYCD),'AFACCTNO',V_AFACCTNO),'SYMBOL',V_SYMBOL),'NAME',v_fullname),'BRID',v_bridgl);


IF v_AMOUNT>0 THEN

IF V_TLTXCD ='1138' THEN
V_AMOUNT :=V_AMOUNT*(-1);
END IF;
IF v_TYPEGL='SE' THEN
v_AMOUNT := v_AMOUNT*v_parvalue;
END IF;

INSERT INTO gljournal
(ref,txdate,txnum,busdate,custid,afacctno,custodycd,tltxcd,posting_code,bankid,brid,glgrp,amount,brdebitacct,brcreditacct,brnotes,grptype,hodebitacct,hocreditacct,honotes,hogrptype,refcustomer,BRIDGL,cfbrid,SYMBOL,TYPEGL)
VALUES (seq_gljournal.NEXTVAL, V_TXDATE,pv_txnum ,v_BUSDATE,v_custid,v_afacctno,v_custodycd,v_TLTXCD,v_POSTING_CODE,V_BANKID,v_BRID,v_GLGRP,v_AMOUNT,v_BRDEBITACCT,v_BRCREDITACCT ,v_BRNOTES,v_BRGRPTYPE,v_HODEBITACCT,v_HOCREDITACCT,v_HONOTES,v_HOGRPTYPE,v_REFCUSTOMER,v_bridgl,v_cfbrid,V_SYMBOL,v_TYPEGL );
END IF ;

END IF;

END IF;
END LOOP;



  CLOSE v_cursor_txmapglrules;
---------------------------------------------------------------------------

--  dbms_output.put_line('End');
EXCEPTION
  WHEN OTHERS THEN
  return;

END;
 
 
 
 
/
