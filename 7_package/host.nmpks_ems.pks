SET DEFINE OFF;
CREATE OR REPLACE PACKAGE nmpks_ems is

  -- Author  : THONGPM
  -- Created : 29/02/2012 4:55:43 PM
  -- Purpose : Lay thong tin cho email, sms template

  -- Public type declarations
  --type <TypeName> is <Datatype>;

  -- Public constant declarations
  --<ConstantName> constant <Datatype> := <Value>;

  -- Public variable declarations
  --<VariableName> <Datatype>;

  -- Public function and procedure declarations
  --function <FunctionName>(<Parameter> <Datatype>) return <Datatype>;
  procedure GenNotifyEvent(p_message_type varchar2, p_key_value varchar2);
  procedure GenTemplates(p_message_type varchar2, p_key_value varchar2);
  procedure GenTemplate0223(p_ca_id varchar2, p_old_duedate VARCHAR2, p_old_begindate VARCHAR2, p_old_frtranferdate VARCHAR2, p_old_totranferdate VARCHAR2) ;
  /*procedure GenTemplate0215(p_template_id varchar2);*/
  procedure GenTemplate0216(p_ca_id varchar2);
  procedure GenTemplate0217(p_ca_id varchar2);
  procedure GenTemplate0219(p_template_id varchar2);
  procedure GenTemplate0323(p_account varchar2);
  procedure GenTemplate0326(p_template_id varchar2);
  procedure GenTemplate0322(p_od_id varchar2);
  procedure GenTemplate0321(p_ca_id varchar2);
  procedure GenTemplate0320(p_ca_id varchar2);
  procedure GenTemplate327C(p_key_value varchar2);
  procedure GenTemplate0304(p_key_value varchar2) ;
      procedure GenTemplate0224(p_key_value varchar2) ;
        procedure GenTemplate0215(p_template_id VARCHAR2);
                procedure GenTemplateEOM(p_template_id varchar2);
  procedure GenTemplateTransaction(p_transaction_number varchar2);
  procedure GenTemplateScheduler(p_template_id varchar2);
    PROCEDURE smsbatchwarnming (p_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR,detail VARCHAR2) ;
  procedure CheckEarlyDay;
  procedure CheckSystem;
  procedure CheckSoDuGD;
  procedure CheckKhopLenh;
  procedure CheckKLCuoiNgay;
  procedure Gent3indue;
  procedure EmailsmsAuto;
  procedure GenTemplate0332 ;
  procedure GenTemplate0331(i_date date) ;
  --procedure Emailsmsafterbatch;
  function CheckEmail(p_email varchar2) return boolean;
  procedure InsertEmailLog(p_email       varchar2,
                           p_template_id varchar2,
                           p_data_source varchar2,
                           p_account     varchar2);
  function fn_convert_to_vn(strinput in nvarchar2) return nvarchar2;
  function fn_GetNextRunDate(p_last_start_date in date, cycle in char)
    return date;

end NMPKS_EMS;
 
 
 
/


CREATE OR REPLACE PACKAGE BODY nmpks_ems is

  -- Private type declarations
  --type <TypeName> is <Datatype>;

  -- Private constant declarations
  --<ConstantName> constant <Datatype> := <Value>;

  -- Private variable declarations
  --<VariableName> <Datatype>;
  pkgctx plog.log_ctx;
  logrow tlogdebug%rowtype;

  -- Function and procedure implementations
  /*
  function <FunctionName>(<Parameter> <Datatype>) return <Datatype> is
    <LocalVariable> <Datatype>;
  begin
    <Statement>;
    return(<Result>);
  end;
  */

procedure EmailsmsAuto is
    l_datasource  varchar2(2000);
    l_hour        varchar2(20);

    v_currdate    DATE ;
    v_t1_date     DATE ;
    v_type_001    NUMBER;
    v_type_002    NUMBER;
    v_type_003    NUMBER;
    v_type_004    NUMBER;
    v_type_006    NUMBER;
    v_type_007    NUMBER;
    v_type_009    NUMBER;
    v_type_001cn    NUMBER;
    v_type_002cn    NUMBER;
    v_type_003cn    NUMBER;
    v_type_004cn    NUMBER;
    v_type_006cn    NUMBER;
    v_type_007cn    NUMBER;
    v_type_009cn    NUMBER;
 begin

 select TO_CHAR(SYSDATE,'hh.AM') into l_hour from dual;
 v_currdate := to_date( to_char( SYSDATE,'DD/MM/YYYY'),'dd/mm/yyyy');
 SELECT get_t_date ( v_currdate,1 ) INTO v_t1_date  FROM dual ;

 plog.setBeginSection(pkgctx, 'GenTemplate0551');

--CHI TIEU 1.1  MO tai khoan nhung chua duoc duyet
BEGIN

SELECT count( *) INTO v_type_001  FROM (
SELECT max(af.brid) brid,'001' TYPE,'CFMAST' TLTXCD, cf.custodycd, maker_dt,maker_time,approve_dt,approve_time ,tlp1.tlname maker,tlp2.tlname checker
from maintain_log m,tlprofiles tlp1, tlprofiles tlp2, afmast af, cfmast cf
WHERE maker_dt = v_currdate and child_table_name ='AFMAST' AND column_name ='ACCTNO'
AND action_flag ='ADD' and m.maker_id =tlp1.tlid(+) and m.approve_id =tlp2.tlid(+)
AND to_value = af.acctno AND af.custid = cf.custid
AND (TO_NUMBER( nvl( SUBSTR(approve_time,4,2),to_char(SYSDATE,'mi')))- TO_NUMBER(SUBSTR(maker_time,4,2))>45
     OR
     TO_NUMBER( nvl( SUBSTR(approve_time,1,2),to_char(SYSDATE,'hh')))- TO_NUMBER(SUBSTR(maker_time,1,2))>1)
AND maker_time < '16:00:00'
and af.brid ='0001'
GROUP BY  cf.custodycd, maker_dt,maker_time,approve_dt,approve_time ,tlp1.tlname ,tlp2.tlname

UNION ALL
--m? sau 5h th?h?i duy?t tru?c 9h h?au
SELECT max(af.brid) brid,'001' TYPE, 'CFMAST' TLTXCD,cf.custodycd, maker_dt,maker_time,approve_dt,approve_time ,tlp1.tlname maker,tlp2.tlname checker
from maintain_log m,tlprofiles tlp1, tlprofiles tlp2, afmast af, cfmast cf
where maker_dt <  v_currdate
and child_table_name ='AFMAST' AND column_name ='ACCTNO'
AND action_flag ='ADD' and m.maker_id =tlp1.tlid(+) and m.approve_id =tlp2.tlid(+)
AND to_value = af.acctno AND af.custid = cf.custid
AND approve_time IS NULL
AND maker_dt >=  '01-MAR-2014'
and af.brid ='0001'
GROUP BY  cf.custodycd, maker_dt,maker_time,approve_dt,approve_time ,tlp1.tlname ,tlp2.tlname

UNION
--m? sau 5h th?h?i duy?t tru?c 9h h?au
SELECT max(af.brid) brid,'001' TYPE, 'CFMAST' TLTXCD,cf.custodycd, maker_dt,maker_time,approve_dt,approve_time ,tlp1.tlname maker,tlp2.tlname checker
from maintain_log m,tlprofiles tlp1, tlprofiles tlp2, afmast af, cfmast cf
where approve_dt = v_currdate AND maker_dt = v_t1_date
and child_table_name ='AFMAST' AND column_name ='ACCTNO'
AND action_flag ='ADD' and m.maker_id =tlp1.tlid(+) and m.approve_id =tlp2.tlid(+)
AND to_value = af.acctno AND af.custid = cf.custid
AND maker_time >= '16:00:00' AND  approve_time >'09:00:00'
and af.brid ='0001'
GROUP BY  cf.custodycd, maker_dt,maker_time,approve_dt,approve_time ,tlp1.tlname ,tlp2.tlname
) ;

 exception
    when others THEN
    v_type_001:=0;

 END ;


BEGIN

SELECT count( *) INTO v_type_002  FROM (
SELECT (af.brid) brid,'002' TYPE,'CFMAST' TLTXCD, cf.custodycd, maker_dt,maker_time,approve_dt,approve_time ,tlp1.tlname maker,tlp2.tlname checker
from maintain_log m,tlprofiles tlp1, tlprofiles tlp2, afmast af, cfmast cf
where approve_dt = v_currdate and child_table_name ='AFMAST' AND column_name ='ACCTNO'
AND action_flag ='ADD' and m.maker_id =tlp1.tlid(+) and m.approve_id =tlp2.tlid(+)
AND to_value = af.acctno AND af.custid = cf.custid
AND cf.custid NOT IN (SELECT custid FROM cfsign )
and af.brid ='0001'
) ;

 exception
    when others THEN
    v_type_002:=0;

 END ;


BEGIN

SELECT count( *) INTO v_type_003  FROM (
SELECT (af.brid) brid,'003' TYPE,'CFMAST' TLTXCD, cf.custodycd, maker_dt,maker_time,approve_dt,approve_time ,tlp1.tlname maker,tlp2.tlname checker
from maintain_log m,tlprofiles tlp1, tlprofiles tlp2, afmast af, cfmast cf
where approve_dt =v_currdate  and child_table_name ='AFMAST' AND column_name ='ACCTNO'
AND action_flag ='ADD' and m.maker_id =tlp1.tlid(+) and m.approve_id =tlp2.tlid(+)
AND to_value = af.acctno AND af.custid = cf.custid
AND af. bankacctno is  null
AND AF.corebank ='Y'
and af.brid ='0001'
) ;

 exception
    when others THEN
    v_type_003:=0;
 END ;

BEGIN
SELECT count( *) INTO v_type_004  FROM (
SELECT (af.brid) brid,'004' TYPE,'CFMAST' TLTXCD, cf.custodycd, maker_dt,maker_time,approve_dt,approve_time ,tlp1.tlname maker,tlp2.tlname checker
from maintain_log m,tlprofiles tlp1, tlprofiles tlp2, afmast af, cfmast cf
where maker_dt =v_currdate and child_table_name ='AFMAST' AND column_name ='ACCTNO'
AND action_flag ='ADD' and m.maker_id =tlp1.tlid and m.approve_id =tlp2.tlid
AND to_value = af.acctno AND af.custid = cf.custid
AND cf.activests ='N' AND maker_time < '16:00:00'
and af.brid ='0001'

UNION ALL
SELECT (af.brid) brid,'004' TYPE,'CFMAST' TLTXCD, cf.custodycd, maker_dt,maker_time, approve_dt, approve_time ,tlp1.tlname maker,tlp2.tlname checker
from maintain_log m,tlprofiles tlp1, tlprofiles tlp2, afmast af, cfmast cf
where maker_dt < v_currdate
and child_table_name ='AFMAST' AND column_name ='ACCTNO'
AND action_flag ='ADD' and m.maker_id =tlp1.tlid and m.approve_id =tlp2.tlid
AND to_value = af.acctno AND af.custid = cf.custid
AND cf.activests ='N'
and af.brid ='0001'
UNION ALL

SELECT (af.brid) brid, '004' TYPE,'CFMAST' TLTXCD, cf.custodycd, maker_dt,maker_time, TXDATE approve_dt,txtime approve_time ,tlp1.tlname maker,tlp2.tlname checker
from maintain_log m,tlprofiles tlp1, tlprofiles tlp2, afmast af, cfmast cf,
(SELECT msgacct ,txtime,TXDATE  FROM vw_tllog_all WHERE  TXDATE = v_currdate AND TLTXCD ='0012') TL
where maker_dt = v_t1_date
and child_table_name ='AFMAST' AND column_name ='ACCTNO'
AND action_flag ='ADD' and m.maker_id =tlp1.tlid and m.approve_id =tlp2.tlid
AND to_value = af.acctno AND af.custid = cf.custid
AND AF.acctno = TL.msgacct
AND txtime >'09:00:00'
and af.brid ='0001'

) ;

 exception
    when others THEN
    v_type_004:=0;
 END ;



BEGIN
SELECT count( *) INTO v_type_006  FROM (
SELECT (af.brid) brid, '006' TYPE , '2240' TLTXCD, cf.custodycd, tl.txdate maker_dt , tl.txtime maker_time, tl.txdate approve_dt  , '' approve_time , tlp1.tlname maker,tlp2.tlname checker
from sedeposit se, vw_tllog_all tl, afmast af, cfmast cf ,tlprofiles tlp1, tlprofiles tlp2,tllogfldall tlfld
 where se.txnum = tl.txnum
 AND se.txdate = tl.txdate
 AND TL.TXDATE = TLFLD.TXDATE
 AND TL.TXNUM = TLFLD.TXNUM
 AND tl.tltxcd ='2240'
 AND tlfld.fldcd ='99'
 AND v_currdate   >  getduedate(depodate ,'B' , '000' ,  3)
 AND SE.DELTD <>'Y'
 AND se.STATUS NOT IN ('C')
 AND substr(se.acctno,1,10)=af.acctno
 AND af.custid = cf.custid
 AND tl.tlid = tlp1.tlid(+) and tl.offid =tlp2.tlid(+)
 AND cvalue ='N'
 and af.brid ='0001')
;
 exception
    when others THEN
    v_type_006:=0;
 END ;

BEGIN
SELECT count( *) INTO v_type_007  FROM (
SELECT (af.brid) brid,'007' TYPE,'CFMAST' TLTXCD, cf.custodycd, maker_dt,maker_time,approve_dt,approve_time ,tlp1.tlname maker,tlp2.tlname checker
from maintain_log m,tlprofiles tlp1, tlprofiles tlp2, afmast af, cfmast cf
where  child_table_name ='AFMAST' AND column_name ='ACCTNO'
AND action_flag ='ADD' and m.maker_id =tlp1.tlid(+) and m.approve_id =tlp2.tlid(+)
AND to_value = af.acctno AND af.custid = cf.custid
and cf.custodycd in (Select custodycd from CFBankstatus where banksts ='N' )
AND af.corebank='Y'
and af.brid ='0001'
AND CASE WHEN approve_dt = v_currdate THEN   maker_time ELSE '15:00:00' END  < '16:00:00'
) ;
 exception
    when others THEN
    v_type_007:=0;
 END ;

BEGIN
SELECT count( *) INTO v_type_009  FROM (
SELECT  tl.brid ,
'009' TYPE , TLTXCD TLTXCD, cfcustodycd TXNUM, tl.txdate maker_dt , tl.txtime maker_time, tl.txdate approve_dt  , '' approve_time , tlp1.tlname maker,tlp2.tlname checker
FROM  (SELECT * FROM tllog4dr UNION ALL SELECT * FROM tllog4drall) tl,tlprofiles tlp1, tlprofiles tlp2
WHERE txstatus in('5','8')
AND   tl.tlid = tlp1.tlid(+) and tl.offid =tlp2.tlid(+)
AND tl.tlid <> tl.offid
AND tl.txdate = v_currdate
and tl.brid ='0001'
) ;
 exception
    when others THEN
    v_type_009:=0;
 END ;




begin
SELECT count( *) INTO v_type_001cn  FROM (
SELECT max(af.brid) brid,'001' TYPE,'CFMAST' TLTXCD, cf.custodycd, maker_dt,maker_time,approve_dt,approve_time ,tlp1.tlname maker,tlp2.tlname checker
from maintain_log m,tlprofiles tlp1, tlprofiles tlp2, afmast af, cfmast cf
WHERE maker_dt = v_currdate and child_table_name ='AFMAST' AND column_name ='ACCTNO'
AND action_flag ='ADD' and m.maker_id =tlp1.tlid(+) and m.approve_id =tlp2.tlid(+)
AND to_value = af.acctno AND af.custid = cf.custid
AND (TO_NUMBER( nvl( SUBSTR(approve_time,4,2),to_char(SYSDATE,'mi')))- TO_NUMBER(SUBSTR(maker_time,4,2))>45
     OR
     TO_NUMBER( nvl( SUBSTR(approve_time,1,2),to_char(SYSDATE,'hh')))- TO_NUMBER(SUBSTR(maker_time,1,2))>1)
AND maker_time < '16:00:00'
and af.brid <>'0001'
GROUP BY  cf.custodycd, maker_dt,maker_time,approve_dt,approve_time ,tlp1.tlname ,tlp2.tlname

UNION ALL
--m? sau 5h th?h?i duy?t tru?c 9h h?au
SELECT max(af.brid) brid,'001' TYPE, 'CFMAST' TLTXCD,cf.custodycd, maker_dt,maker_time,approve_dt,approve_time ,tlp1.tlname maker,tlp2.tlname checker
from maintain_log m,tlprofiles tlp1, tlprofiles tlp2, afmast af, cfmast cf
where maker_dt <  v_currdate
and child_table_name ='AFMAST' AND column_name ='ACCTNO'
AND action_flag ='ADD' and m.maker_id =tlp1.tlid(+) and m.approve_id =tlp2.tlid(+)
AND to_value = af.acctno AND af.custid = cf.custid
AND approve_time IS NULL
AND maker_dt >=  '01-MAR-2014'
and af.brid <>'0001'
GROUP BY  cf.custodycd, maker_dt,maker_time,approve_dt,approve_time ,tlp1.tlname ,tlp2.tlname

UNION
--m? sau 5h th?h?i duy?t tru?c 9h h?au
SELECT max(af.brid) brid,'001' TYPE, 'CFMAST' TLTXCD,cf.custodycd, maker_dt,maker_time,approve_dt,approve_time ,tlp1.tlname maker,tlp2.tlname checker
from maintain_log m,tlprofiles tlp1, tlprofiles tlp2, afmast af, cfmast cf
where approve_dt = v_currdate AND maker_dt = v_t1_date
and child_table_name ='AFMAST' AND column_name ='ACCTNO'
AND action_flag ='ADD' and m.maker_id =tlp1.tlid(+) and m.approve_id =tlp2.tlid(+)
AND to_value = af.acctno AND af.custid = cf.custid
AND maker_time >= '16:00:00' AND  approve_time >'09:00:00'
and af.brid <>'0001'
GROUP BY  cf.custodycd, maker_dt,maker_time,approve_dt,approve_time ,tlp1.tlname ,tlp2.tlname
) ;

 exception
    when others THEN
    v_type_001cn:=0;

 END ;


BEGIN

SELECT count( *) INTO v_type_002cn  FROM (
SELECT (af.brid) brid,'002' TYPE,'CFMAST' TLTXCD, cf.custodycd, maker_dt,maker_time,approve_dt,approve_time ,tlp1.tlname maker,tlp2.tlname checker
from maintain_log m,tlprofiles tlp1, tlprofiles tlp2, afmast af, cfmast cf
where approve_dt = v_currdate and child_table_name ='AFMAST' AND column_name ='ACCTNO'
AND action_flag ='ADD' and m.maker_id =tlp1.tlid(+) and m.approve_id =tlp2.tlid(+)
AND to_value = af.acctno AND af.custid = cf.custid
AND cf.custid NOT IN (SELECT custid FROM cfsign )
and af.brid <>'0001'
) ;

 exception
    when others THEN
    v_type_002cn :=0;

 END ;


BEGIN

SELECT count( *) INTO v_type_003cn  FROM (
SELECT (af.brid) brid,'003' TYPE,'CFMAST' TLTXCD, cf.custodycd, maker_dt,maker_time,approve_dt,approve_time ,tlp1.tlname maker,tlp2.tlname checker
from maintain_log m,tlprofiles tlp1, tlprofiles tlp2, afmast af, cfmast cf
where approve_dt =v_currdate  and child_table_name ='AFMAST' AND column_name ='ACCTNO'
AND action_flag ='ADD' and m.maker_id =tlp1.tlid(+) and m.approve_id =tlp2.tlid(+)
AND to_value = af.acctno AND af.custid = cf.custid
AND af. bankacctno is  null
AND AF.corebank ='Y'
and af.brid <>'0001'
) ;

 exception
    when others THEN
    v_type_003cn :=0;
 END ;

BEGIN
SELECT count( *) INTO v_type_004cn  FROM (
SELECT (af.brid) brid,'004' TYPE,'CFMAST' TLTXCD, cf.custodycd, maker_dt,maker_time,approve_dt,approve_time ,tlp1.tlname maker,tlp2.tlname checker
from maintain_log m,tlprofiles tlp1, tlprofiles tlp2, afmast af, cfmast cf
where maker_dt =v_currdate and child_table_name ='AFMAST' AND column_name ='ACCTNO'
AND action_flag ='ADD' and m.maker_id =tlp1.tlid and m.approve_id =tlp2.tlid
AND to_value = af.acctno AND af.custid = cf.custid
AND cf.activests ='N' AND maker_time < '16:00:00'
and af.brid <>'0001'

UNION ALL
SELECT (af.brid) brid,'004' TYPE,'CFMAST' TLTXCD, cf.custodycd, maker_dt,maker_time, approve_dt, approve_time ,tlp1.tlname maker,tlp2.tlname checker
from maintain_log m,tlprofiles tlp1, tlprofiles tlp2, afmast af, cfmast cf
where maker_dt < v_currdate
and child_table_name ='AFMAST' AND column_name ='ACCTNO'
AND action_flag ='ADD' and m.maker_id =tlp1.tlid and m.approve_id =tlp2.tlid
AND to_value = af.acctno AND af.custid = cf.custid
AND cf.activests ='N'
and af.brid <>'0001'
UNION ALL

SELECT (af.brid) brid, '004' TYPE,'CFMAST' TLTXCD, cf.custodycd, maker_dt,maker_time, TXDATE approve_dt,txtime approve_time ,tlp1.tlname maker,tlp2.tlname checker
from maintain_log m,tlprofiles tlp1, tlprofiles tlp2, afmast af, cfmast cf,
(SELECT msgacct ,txtime,TXDATE  FROM vw_tllog_all WHERE  TXDATE = v_currdate AND TLTXCD ='0012') TL
where maker_dt = v_t1_date
and child_table_name ='AFMAST' AND column_name ='ACCTNO'
AND action_flag ='ADD' and m.maker_id =tlp1.tlid and m.approve_id =tlp2.tlid
AND to_value = af.acctno AND af.custid = cf.custid
AND AF.acctno = TL.msgacct
AND txtime >'09:00:00'
and af.brid <>'0001'

) ;

 exception
    when others THEN
    v_type_004cn :=0;
 END ;



BEGIN
SELECT count( *) INTO v_type_006cn  FROM (
SELECT (af.brid) brid, '006' TYPE , '2240' TLTXCD, cf.custodycd, tl.txdate maker_dt , tl.txtime maker_time, tl.txdate approve_dt  , '' approve_time , tlp1.tlname maker,tlp2.tlname checker
from sedeposit se, vw_tllog_all tl, afmast af, cfmast cf ,tlprofiles tlp1, tlprofiles tlp2,tllogfldall tlfld
 where se.txnum = tl.txnum
 AND se.txdate = tl.txdate
 AND TL.TXDATE = TLFLD.TXDATE
 AND TL.TXNUM = TLFLD.TXNUM
 AND tl.tltxcd ='2240'
 AND tlfld.fldcd ='99'
 AND v_currdate   >  getduedate(depodate ,'B' , '000' ,  3)
 AND SE.DELTD <>'Y'
 AND se.STATUS NOT IN ('C')
 AND substr(se.acctno,1,10)=af.acctno
 AND af.custid = cf.custid
 AND tl.tlid = tlp1.tlid(+) and tl.offid =tlp2.tlid(+)
 AND cvalue ='N'
 and af.brid <>'0001') ;
 exception
    when others THEN
    v_type_006cn:=0;
 END ;

BEGIN
SELECT count( *) INTO v_type_007cn  FROM (
SELECT (af.brid) brid,'007' TYPE,'CFMAST' TLTXCD, cf.custodycd, maker_dt,maker_time,approve_dt,approve_time ,tlp1.tlname maker,tlp2.tlname checker
from maintain_log m,tlprofiles tlp1, tlprofiles tlp2, afmast af, cfmast cf
where  child_table_name ='AFMAST' AND column_name ='ACCTNO'
AND action_flag ='ADD' and m.maker_id =tlp1.tlid(+) and m.approve_id =tlp2.tlid(+)
AND to_value = af.acctno AND af.custid = cf.custid
and cf.custodycd in (Select custodycd from CFBankstatus where banksts ='N' )
AND af.corebank='Y'
and af.brid <>'0001'
AND CASE WHEN approve_dt = v_currdate THEN   maker_time ELSE '15:00:00' END  < '16:00:00'
) ;
 exception
    when others THEN
    v_type_007cn :=0;
 END ;

BEGIN
SELECT count( *) INTO v_type_009cn  FROM (
SELECT  tl.brid ,
'009' TYPE , TLTXCD TLTXCD, cfcustodycd TXNUM, tl.txdate maker_dt , tl.txtime maker_time, tl.txdate approve_dt  , '' approve_time , tlp1.tlname maker,tlp2.tlname checker
FROM  (SELECT * FROM tllog4dr UNION ALL SELECT * FROM tllog4drall) tl,tlprofiles tlp1, tlprofiles tlp2
WHERE txstatus in('5','8')
AND   tl.tlid = tlp1.tlid(+) and tl.offid =tlp2.tlid(+)
AND tl.tlid <> tl.offid
AND tl.txdate = v_currdate
and tl.brid <>'0001'
) ;
 exception
    when others THEN
    v_type_009cn :=0;
 END ;










for
   rec IN (select mobilesms , custodycd from smsServiceTemplates smst,smsserviceuser smss
    where smst.codeid = smss.codeid  and smss.codeid ='4'
          )
loop

  l_datasource:= 'select  '''|| rec.custodycd ||''' custodycd, ''' || v_type_001 || ''' TYPE001 , ''' || v_type_002 || ''' TYPE002 ,'''
   || v_type_003 || ''' TYPE003 , ''' || v_type_004 || ''' TYPE004 ,''' || v_type_006 || ''' TYPE006 ,''' || v_type_007 || ''' TYPE007 ,'''
   || v_type_009 || ''' TYPE009 ,'''
   || v_type_001cn || ''' TYPE001cn , ''' || v_type_002cn || ''' TYPE002cn ,''' || v_type_003cn || ''' TYPE003cn ,''' || v_type_004cn || ''' TYPE004cn ,'''
   || v_type_006cn || ''' TYPE006cn , ''' || v_type_007cn || ''' TYPE007cn ,''' || v_type_009cn || ''' TYPE009cn , TO_CHAR(SYSDATE,''DD/MM/YYYY'') txdate from  dual';
  InsertEmailLog(rec.mobilesms, '0222', l_datasource, rec.custodycd);
end loop;


  plog.setEndSection(pkgctx, 'GenTemplate0551');
  exception
    when others then
      plog.error(pkgctx, sqlerrm);
      plog.setEndSection(pkgctx, 'GenTemplate0551');
 end;

  procedure GenNotifyEvent(p_message_type varchar2, p_key_value varchar2) is
  begin
    plog.setBeginSection(pkgctx, 'GenNotifyEvent');

    insert into log_notify_event
      (AUTOID,
       MSGTYPE,
       KEYVALUE,
       STATUS,
       LOGTIME,
       APPLYTIME,
       COMMANDTYPE,
       COMMANDTEXT)
    values
      (seq_log_notify_event.nextval,
       p_message_type,
       p_key_value,
       'A',
       sysdate,
       null,
       'P',
       'GENERATE_TEMPLATES');

    plog.setEndSection(pkgctx, 'GenNotifyEvent');
  exception
    when others then
      plog.error(pkgctx, sqlerrm);
      plog.setEndSection(pkgctx, 'GenNotifyEvent');
  end;

  procedure GenTemplates(p_message_type varchar2, p_key_value varchar2) is
  begin
    plog.setBeginSection(pkgctx, 'GenTemplates');
    plog.debug(pkgctx,
               '[message_type]: ' || p_message_type || ' - [key_value]: ' ||
               p_key_value);
    if p_message_type = 'CAMAST_V' or p_message_type = 'CAMAST_S' then
      -- Mau thu thong bao thuc hien quyen
      GenTemplate0216(p_key_value);
    elsif p_message_type = 'CAMAST_A' then
      -- Mau thu thong bao thuc hien quyen mua phat hanh them
      GenTemplate0217(p_key_value);
    elsif p_message_type = 'CAMASTSMS_V' then
      -- Mau sms thong bao thuc hien quyen mua phat hanh them
      GenTemplate0321(p_key_value);
   /* elsif p_message_type = 'CAMAST_C' then
      -- Mau email thong bao gia han thuc hien quyen
            --14/09/2015:  goi bang giao dich 3389
      GenTemplate0223(p_key_value);*/
    elsif p_message_type = 'ODMATCHED' then
      -- SMS thong bao ket qua khop lenh
      GenTemplate0323(p_key_value);
    elsif p_message_type = 'TRANSACT' then
      GenTemplateTransaction(p_key_value);
    elsif p_message_type = 'LNREMINDER' then
      GenTemplate327C(p_key_value);
    elsif p_message_type = 'QAREMINDER' then
      GenTemplate0304(p_key_value);
    elsif p_message_type = 'SCHD0320' then
      GenTemplate0320(p_key_value);
    elsif p_message_type = 'SCHD0322' then
      GenTemplate0322(p_key_value);
    elsif p_message_type = 'SCHD0326' then
      GenTemplate0326(p_key_value);
   /* elsif p_message_type = 'SCHD0215' then
      GenTemplate0215(p_key_value);*/
    elsif p_message_type = 'SCHD0219' then
      GenTemplate0219(p_key_value);
    /*elsif substr(p_message_type, 1, 4) = 'SCHD' then
      GenTemplateScheduler(p_key_value);*/
    ELSIF  p_message_type = 'EODORDER' THEN
           GenTemplate0215(p_key_value);
        ELSIF p_message_type = 'EOMEMAIL' THEN
                gentemplateEOM(p_key_value);
    end if;

    GenTemplate0332 ;
    plog.setEndSection(pkgctx, 'GenTemplates');
  exception
    when others then
      plog.error(pkgctx, sqlerrm);
      plog.setEndSection(pkgctx, 'GenTemplates');
  end;

--procedure GenTemplate0223(p_ca_id VARCHAR2) IS
procedure GenTemplate0223(p_ca_id varchar2, p_old_duedate VARCHAR2, p_old_begindate VARCHAR2, p_old_frtranferdate VARCHAR2, p_old_totranferdate VARCHAR2) is
    l_emailtemplateid varchar2(10);
        l_smstemplateid varchar2(10);
    l_rate varchar2(10);
    l_datasource varchar2(1000);
        v_currdate DATE;
        l_message VARCHAR2(1000);

  begin
    plog.setBeginSection(pkgctx, 'GenTemplate0223');
        plog.error(pkgctx,p_ca_id || p_old_duedate || p_old_begindate || p_old_frtranferdate || p_old_totranferdate);
    l_emailtemplateid := '0223';
        l_smstemplateid := '0330';
        SELECT TO_date(getcurrdate,'DD/MM/RRRR') INTO v_currdate FROM dual;
 for rec in (
    select s.symbol,
           a.cdcontent tradeplace,
           nvl(i.fullname, i.shortname) issuer,
           ca.catype,
           ca.devidentrate,
           ca.devidentshares,
           ca.rightoffrate,
           ca.reportdate,
           nvl(ca.actiondate, ca.actiondate) actiondate,
           ca.advdesc,
           a.cdcontent,
           ca.purposedesc,
           ca.interestrate,
           ca.typerate,
           ca.exrate,
           ca.exprice,
           ca.tocodeid,
           tosec.symbol tosymbol,
           --ca.totradeplace,
           ca.begindate,
           ca.duedate,
           to_char(ca.frdatetransfer,'DD/MM/RRRR') frdatetransfer,
           to_char(ca.todatetransfer,'DD/MM/RRRR') todatetransfer,
           ca.devidentvalue,
           ca.frtradeplace,
           cf.custodycd, cf.email, cf.fullname, cf.mobilesms,
           af.acctno afacctno,
           c.trade, c.pqtty, tosec.tradeplace totradeplace,
                     c.balance + c.pbalance balance,
                     CASE WHEN tosec.sectype IN ('001','002') THEN 'Co phieu' ELSE 'Trai phieu' END sectype
      from camast ca, sbsecurities s, issuers i, allcode a, caschd c, vw_cfmast_sms cf, afmast af, sbsecurities tosec
     where ca.codeid = s.codeid
       and s.issuerid = i.issuerid
       and a.cdval = s.tradeplace
       and a.cdtype = 'SE'
       and a.cdname = 'TRADEPLACE'
       and ca.camastid = p_ca_id and c.camastid = ca.camastid and ca.deltd <> 'Y'
       and cf.custid = af.custid and af.acctno = c.afacctno and nvl(ca.tocodeid, ca.codeid) = tosec.codeid
       )

   loop

         if instr('006,005,010,011,020,022',rec.catype) <> 0 then
            l_rate:= rec.devidentshares;
         elsif instr('014,023', rec.catype) <> 0 then
            l_rate:= rec.rightoffrate;
         elsif instr('015,016', rec.catype) <> 0 then
            l_rate:=  rec.interestrate;
         elsif instr('017,021', rec.catype) <> 0 then
            l_rate:= rec.exrate;
         else --'019'
            l_rate:= 0;
         end if;

          l_datasource := 'select ''' || rec.fullname || ''' fullname, ''' ||
                          rec.custodycd || ''' custodycode, ''' ||
                          rec.afacctno || ''' account, ''' ||
                          rec.symbol || ''' symbol, ''' || rec.issuer ||
                          ''' issuer, ''' ||
                          to_char(rec.cdcontent) ||
                          ''' tradeplace, ''' || rec.trade ||
                          ''' trade, ''' ||
                          to_char(rec.reportdate, 'DD/MM/RRRR') ||
                          ''' reportdate, ''' || rec.advdesc ||
                          ''' advdesc, ''' || l_rate || ''' rate, ''' ||
                          to_char(rec.actiondate, 'DD/MM/RRRR') || ''' inactiondate, ''' ||
                          rec.purposedesc || ''' purpose, ''' || rec.exrate ||
                          ''' exrate, ''' || rec.tosymbol ||
                          ''' tosymbol, ''' ||
                           to_char(rec.begindate, 'DD/MM/RRRR') ||
                          ''' begindate, ''' ||
                          to_char(rec.duedate, 'DD/MM/RRRR') ||
                          ''' duedate, ''' ||
                          rec.frdatetransfer ||
                          ''' frdatetransfer, ''' ||
                          rec.todatetransfer ||
                          ''' todatetransfer, ''' ||
                          ltrim(to_char(rec.exprice, '9,999,999,999')) ||
                          ''' exprice, ''' || rec.pqtty ||
                          ''' pqtty, ''' ||
                           ltrim(to_char(rec.devidentvalue, '9,999,999,999')) ||
                           ''' gia, ''' ||
                          rec.totradeplace ||
                          ''' totradeplace, ''' || rec.tradeplace ||
                          ''' frtradeplace from dual';
          --email
                    IF checkemail(rec.email) THEN
          InsertEmailLog(rec.email,
                         l_emailtemplateid,
                         l_datasource,
                         rec.afacctno);
                    END IF;
                    --sms:3389
                    IF rec.mobilesms is not null and length(rec.mobilesms) > 0 THEN /* ' || rec.balance || '*/
                        /* l_message:= 'Tai khoan '|| rec.custodycd ||' duoc quyen mua  ' || rec.sectype || ' ' ||  rec.symbol || ' Gia ' || rec.exprice||
                                             ' Thoi gian thong bao: dang ky tu ' || p_old_begindate  || ' den ' || p_old_duedate  ||
                                                                 ' Thoi gian dieu chinh: dang ky tu '|| rec.begindate ||' den ' || rec.duedate ||
                                                                 ' Chuyen nhuong tu ' || rec.frdatetransfer || ' den ' || rec.todatetransfer
                                                 ;*/
                        /*l_message:= 'Quyen mua chung khoan ' ||  rec.symbol || ' duoc gia han thoi gian dang ky tu '|| rec.begindate ||' den ' || rec.duedate ||
                                                                 ', chuyen nhuong quyen tu ' || rec.frdatetransfer || ' den ' || rec.todatetransfer
                                                 ;
                         l_datasource:= 'select '''||rec.custodycd || ''' custodycd,  ''' || l_message || ''' detail from dual';
                         */
                        /*l_message:= 'BMSC xin thong bao tin gia han quyen mua cua quy khach TK ' || rec.custodycd || ' mua CK ' || rec.symbol ||
                                    ' SLCP duoc mua ' || rec.pqtty || ' gia ' || rec.exprice || ' duoc gia han nhu sau: thoi gian dang ky tu ngay ' ||
                                    p_old_begindate || ' den ngay ' || p_old_duedate || ', thoi gian chuyen nhuong quyen mua tu ngay ' || rec.frdatetransfer ||
                                    ' den ngay ' || rec.todatetransfer;*/
                        l_datasource:= 'select ''' || rec.custodycd || ''' taikhoan, ''' || rec.symbol || ''' mack, ''' || rec.pqtty || ''' slcp, ''' || rec.exprice ||
                        ''' gia, ''' || rec.begindate || ''' tungaydk, ''' || rec.duedate || ''' denngaydk, ''' || rec.frdatetransfer || ''' tungaycn, ''' || rec.todatetransfer ||
                        ''' denngaycn from dual';
                       insertemaillog(rec.mobilesms,l_smstemplateid,l_datasource,rec.afacctno);
                    END IF;



    end loop;

    plog.setEndSection(pkgctx, 'GenTemplate0223');
  exception
    when others then
      plog.error(pkgctx, sqlerrm);
      plog.setEndSection(pkgctx, 'GenTemplate0223');
  end;

  /*procedure GenTemplate0215(p_template_id varchar2) is

    --l_next_run_date date;
    l_data_source   varchar2(4000);
    l_template_id   templates.code%type;
    l_afacctno      afmast.acctno%type;
    l_address       varchar2(100);
    l_fullname      cfmast.fullname%type;
    l_custody_code  cfmast.custodycd%type;

    type scheduler_cursor is ref cursor;

    type scheduler_record is record(
      template_id templates.code%type,
      afacctno    afmast.acctno%type,
      address     varchar2(100));

    c_scheduler   scheduler_cursor;
    scheduler_row scheduler_record;

    type ty_scheduler is table of scheduler_record index by binary_integer;

    scheduler_list         ty_scheduler;
    l_scheduler_cache_size number(23) := 1000;
    l_row                  pls_integer;
  begin
    plog.setBeginSection(pkgctx, 'GenTemplate0215');

    open c_scheduler for
      select t.code,
             mst.acctno,
             decode(t.type, 'E', cf.email, 'S', cf.mobilesms) address
        from templates t,
             aftemplates a,
             afmast mst,
             vw_cfmast_sms cf,
             (select afacctno
                from odmast
               where txdate =
                     to_date(cspks_system.fn_get_sysvar('SYSTEM', 'PREVDATE'),
                             'DD/MM/RRRR')
                 and deltd <> 'Y'
                 and execqtty > 0
               group by afacctno) od
       where a.template_code = t.code
         and a.custid = cf.custid
         and mst.acctno = od.afacctno and mst.custid = cf.custid
         and decode(t.type, 'E', cf.email, 'S', cf.mobilesms) is not null
         and t.code = p_template_id;

    loop
      fetch c_scheduler bulk collect
        into scheduler_list limit l_scheduler_cache_size;

      plog.DEBUG(pkgctx, 'CNT: ' || scheduler_list.COUNT);

      exit when scheduler_list.COUNT = 0;
      l_row := scheduler_list.FIRST;

      while (l_row is not null)

       loop
        scheduler_row := scheduler_list(l_row);
        l_template_id := scheduler_row.template_id;
        l_afacctno    := scheduler_row.afacctno;
        l_address     := scheduler_row.address;

        begin
          select a.custodycd, a.fullname
            into l_custody_code, l_fullname
            from cfmast a, afmast b
           where a.custid = b.custid
             and b.acctno = l_afacctno;
        exception
          when NO_DATA_FOUND then
            plog.error(pkgctx,
                       'Sub account ' || l_afacctno || ' not found');
            l_custody_code := 'No Data Found';
            l_fullname     := 'No Data Found';
        end;

        l_data_source := 'select ''' || l_custody_code ||
                         ''' custodycode, ''' || l_fullname ||
                         ''' fullname, ''' || l_afacctno ||
                         ''' account, ''' ||
                         fn_get_sysvar_for_report('SYSTEM', 'PREVDATE') ||
                         ''' daily from dual;';

        InsertEmailLog(l_address, l_template_id, l_data_source, l_afacctno);

        l_row := scheduler_list.NEXT(l_row);
      end loop;
    end loop;

    insert into templates_scheduler_log
      (template_id, log_date)
    values
      (p_template_id, getcurrdate);

    update templates_scheduler
       set last_start_date = getcurrdate,
           next_run_date   = fn_GetNextRunDate(getcurrdate, repeat_interval)
     where template_id = p_template_id;

    plog.setEndSection(pkgctx, 'GenTemplate0215');
  exception
    when others then
      plog.error(pkgctx, sqlerrm);
      plog.setEndSection(pkgctx, 'GenTemplate0215');
  end;*/

  -- Mau thu thong bao thuc hien quyen
  procedure GenTemplate0216(p_ca_id varchar2) is
    l_custodycd  cfmast.custodycd%type;
    l_fullname   cfmast.fullname%type;
    l_email      cfmast.email%type;
    l_mobilesms      cfmast.mobilesms%type;
    l_templateid varchar2(6);
    l_datasource varchar2(2000);
    l_symbol     sbsecurities.symbol%type;
    l_tocodeid   camast.tocodeid%type;
    l_to_symbol  sbsecurities.symbol%type;

    l_catype camast.catype%type;

    l_report_date     date;
    --l_trade_date      date ;
    l_begin_date      date;
    l_due_date        date ;
    l_frdate_transfer varchar2(20);
    l_todate_transfer varchar2(20);

    l_rate            varchar2(50);
    l_devident_shares varchar2(50);
    l_devident_value  varchar2(50);
    l_exrate          varchar2(50);
    l_gia            varchar2(10);

    l_right_off_rate varchar2(50);
    l_devident_rate  varchar2(50);
    l_interest_rate  varchar2(50);
    l_trade_place    varchar2(10);
    l_to_floor_code  varchar2(10);
    l_fr_floor_code  varchar2(10);
    l_fr_trade_place varchar2(10);
    l_to_trade_place varchar2(10);
    l_issuer         varchar2(250);
    l_tradeplace_desc varchar2(250);
    l_inaction_date  date ;
    l_typerate       char(1);
    l_exprice        camast.exprice%type;
    l_advdesc        camast.advdesc%type;
    l_purpose_desc   camast.purposedesc%type;

    --l_to_codeid       varchar2(10);
    --l_to_symbol       varchar2(10);
    --l_catype_desc     varchar2(100);
    --l_floor_code      varchar2(10);

    type caschd_cursor is ref cursor;

    c_caschd  caschd_cursor;
    caschdrow caschd%rowtype;

    type ty_caschd is table of caschd%rowtype index by binary_integer;

    caschd_list         ty_caschd;
    l_caschd_cache_size number(23) := 1000000;
    l_row               pls_integer;
  begin
    plog.setBeginSection(pkgctx, 'GenTemplate0216');
    l_templateid := '0216';

    select s.symbol,
           s.tradeplace,
           nvl(i.fullname, i.shortname) issuer,
           ca.catype,
           ca.devidentrate,
           ca.devidentshares,
           ca.rightoffrate,
           ca.reportdate,
           nvl(ca.actiondate, ca.actiondate) actiondate,
           ca.advdesc,
           a.cdcontent,
           ca.purposedesc,
           ca.interestrate,
           ca.typerate,
           ca.exrate,
           ca.exprice,
           ca.tocodeid,
           ca.totradeplace,
           ca.begindate,
           ca.duedate,
           to_char(ca.frdatetransfer,'DD/MM/RRRR') frdatetransfer,
           to_char(ca.todatetransfer,'DD/MM/RRRR') todatetransfer,
           ca.devidentvalue,
           ca.frtradeplace
      into l_symbol,
           l_trade_place,
           l_issuer,
           l_catype,
           l_devident_rate,
           l_devident_shares,
           l_right_off_rate,
           l_report_date,
           l_inaction_date,
           l_advdesc,
           l_tradeplace_desc,
           l_purpose_desc,
           l_interest_rate,
           l_typerate,
           l_exrate,
           l_exprice,
           l_tocodeid,
           l_to_floor_code,
           l_begin_date,
           l_due_date,
           l_frdate_transfer,
           l_todate_transfer,
           l_devident_value,
           l_fr_floor_code
      from camast ca, sbsecurities s, issuers i, allcode a
     where ca.codeid = s.codeid
       and s.issuerid = i.issuerid
       and a.cdval = s.tradeplace
       and a.cdtype = 'SE'
       and a.cdname = 'TRADEPLACE'
       and ca.camastid = p_ca_id;
    --plog.error(pkgctx, 'camastid:'||p_ca_id);
    -- CATYPE : 011, 014
    /*
    001 ?u gi    002 T?m ng?ng giao d?ch
    003 H?y ni?y?t
    004 Mua l?i
    005 Tham d? d?i h?i c? d?    006 L?y ? ki?n c? d?    007 B?c? phi?u qu?
    008 C?p nh?t t.tin
    009 Tr? c? t?c b?ng c? phi?u kh?    010 Chia c? t?c b?ng ti?n
    011 Chia c? t?c b?ng c? phi?u
    012 T? c? phi?u
    013 G?p c? phi?u
    014 Quy?n mua
    015 Tr? l?tr?phi?u
    016 Tr? g?c v??tr?phi?u
    017 Chuy?n d?i tr?phi?u th? c? phi?u
    018 Chuy?n quy?n th? c? phi?u
    019 Chuy?n s?    020 Chuy?n d?i c? phi?u th? c? phi?u
    021 C? phi?u thu?ng
    022 Quy?n b? phi?u
    026 Chuy?n c? phi?u ch? giao d?ch th? giao d?ch
    */

    if l_catype = '005' then
      l_rate       := l_devident_shares;
      l_templateid := '216A';
    elsif l_catype = '006' then
      l_rate       := l_devident_shares;
      l_templateid := '216A';
    elsif l_catype = '010' then
      if l_typerate = 'R' then
        l_rate := l_devident_rate || '%';
        l_gia := l_devident_rate*100;
      elsif l_typerate = 'V' then
        l_rate := l_devident_value || ' d/CP';
        l_gia := l_devident_value;
      end if;

      l_templateid := '0216';
    elsif l_catype = '011' then
      l_rate       := l_devident_shares;
      l_templateid := '216B';
    elsif l_catype in ('014', '023') then
      l_rate       := l_right_off_rate;
      l_exrate     := l_exrate;
      l_templateid := '216D';
    elsif l_catype = '010' then
      l_rate := l_right_off_rate;
    elsif l_catype in ('015', '016') then
      l_rate       := l_interest_rate || '%';
      l_templateid := '216C';
    elsif l_catype = '017' then
      l_rate       := l_exrate;
      l_templateid := '216E';

      select symbol
        into l_to_symbol
        from sbsecurities
       where codeid = l_tocodeid;
    elsif l_catype = '019' then
      l_templateid := '216F';
      l_rate       := '0';
      select cdcontent
        into l_to_trade_place
        from allcode
       where cdtype = 'SE'
         and cdname = 'TRADEPLACE'
         and cdval = l_to_floor_code;

      select cdcontent
        into l_fr_trade_place
        from allcode
       where cdtype = 'SE'
         and cdname = 'TRADEPLACE'
         and cdval = l_fr_floor_code;

    elsif l_catype = '020' then
      l_rate       := l_devident_shares;
      l_templateid := '216E';

      select symbol
        into l_to_symbol
        from sbsecurities
       where codeid = l_tocodeid;
    elsif l_catype = '021' then
      l_rate       := l_exrate;
      l_templateid := '216B';
    elsif l_catype = '022' then
      l_rate       := l_devident_shares;
      l_templateid := '216A';
    end if;
    for rec in
        (select cf.custodycd, cf.custid, cf.email, cf.fullname, cf.mobilesms,af.acctno, sum(ca.trade) trade, sum(ca.pqtty) pqtty
            from caschd ca, vw_cfmast_sms cf, afmast af
            where cf.custid = af.custid and ca.afacctno = af.acctno and ca.camastid = p_ca_id and ca.deltd <> 'Y'
            group by cf.custodycd, cf.custid, cf.email, cf.fullname, cf.mobilesms ,af.acctno )
    loop

        if CheckEmail(rec.email) and length(l_rate) > 0 then
          l_datasource := 'select ''' || rec.fullname || ''' fullname, ''' ||
                          rec.custodycd || ''' custodycode, ''' ||
                          --rec.afacctno || ''' account, ''' ||
                          p_ca_id || ''' camastid, ''' ||
                          l_symbol || ''' symbol, ''' || l_issuer ||
                          ''' issuer, ''' ||
                          to_char(l_tradeplace_desc) ||
                          ''' tradeplace, ''' || rec.trade ||
                          ''' trade, ''' ||
                          to_char(l_report_date, 'DD/MM/RRRR') ||
                          ''' reportdate, ''' || l_advdesc ||
                          ''' advdesc, ''' || l_rate || ''' rate, ''' ||
                          to_char(l_inaction_date, 'DD/MM/RRRR') || ''' inactiondate, ''' ||
                          l_purpose_desc || ''' purpose, ''' || l_exrate ||
                          ''' exrate, ''' || l_to_symbol ||
                          ''' tosymbol, ''' ||
                           to_char(l_begin_date, 'DD/MM/RRRR') ||
                          ''' begindate, ''' ||
                          to_char(l_due_date, 'DD/MM/RRRR') ||
                          ''' duedate, ''' ||
                          l_frdate_transfer ||
                          ''' frdatetransfer, ''' ||
                          l_todate_transfer ||
                          ''' todatetransfer, ''' ||
                          ltrim(to_char(l_exprice, '9,999,999,999')) ||
                          ''' exprice, ''' || rec.pqtty ||
                          ''' pqtty, ''' ||
                           ltrim(to_char(l_gia, '9,999,999,999')) ||
                           ''' gia, ''' ||
                          l_to_trade_place ||
                          ''' totradeplace, ''' || l_fr_trade_place ||
                          ''' frtradeplace from dual';

          /*plog.debug(pkgctx, 'EMAIL DATA: ' || l_datasource);

          plog.error(pkgctx,l_email ||' '||
                         l_templateid ||' '||
                         l_datasource ||' '||
                         caschdrow.afacctno );*/
          InsertEmailLog(rec.email,
                         l_templateid,
                         l_datasource,
                         rec.acctno);

        end if;


      end loop;



    plog.setEndSection(pkgctx, 'GenTemplate0216');
  exception
    when others then
      plog.error(pkgctx, sqlerrm);
      plog.setEndSection(pkgctx, 'GenTemplate0216');
  end;

procedure Gent3indue is
    l_datasource  varchar2(2000);
    l_hour  varchar2(20);
    begin

 select TO_CHAR(SYSDATE,'hh.AM') into l_hour from dual;

 if l_hour = '08.AM' THEN

    for rec in (
            select CF.custodycd,ADDT3, ADVT3 , to_char( get_t_date(getcurrdate,3),'DD/MM/YYYY') dateorder ,CF.mobilesms,MR.acctno
            from vw_mr0002 mr,vw_cfmast_sms cf
            where dueamount > 0 and ADDVND >0 and mnemonic ='T3'
            and mr.custodycd= cf.custodycd
            AND CF.mobilesms IS NOT NULL
            and TO_CHAR( getcurrdate(),'DD/MM/YYYY')= to_CHAR (sysdate,'DD/MM/YYYY')
              )
     loop
            l_datasource := 'select ''' || rec.ADDT3  || ''' ADDT3, ''' ||rec.ADVT3  || ''' ADVT3, ''' ||
                         rec.custodycd || ''' custodycd, ''' ||
                         REC.dateorder||''' dateorder from dual';

          InsertEmailLog(rec.mobilesms, '0551', l_datasource, rec.acctno);
     END LOOP;
   END IF;

    plog.setEndSection(pkgctx, 'GenTemplate0551');
  exception
    when others then
      plog.error(pkgctx, sqlerrm);
      plog.setEndSection(pkgctx, 'GenTemplate0551');
  end;

  -- Mau thu thong bao thuc hien quyen mua phat hanh them
  procedure GenTemplate0217(p_ca_id varchar2) is

    l_custodycd   cfmast.custodycd%type;
    l_fullname    cfmast.fullname%type;
    l_email       cfmast.email%type;
    l_datasource  varchar2(2000);
    l_idcode      cfmast.idcode%type;
    l_iddate      varchar2(10);
    l_phone       cfmast.mobilesms%type;
    l_address     cfmast.address%type;
    l_symbol      sbsecurities.symbol%type;
    l_exprice     camast.exprice%type;
    l_duedate     varchar2(10);
    l_parvalue    sbsecurities.parvalue%type;
    l_issuer_name issuers.fullname%type;
    type caschd_cursor is ref cursor;
    c_caschd  caschd_cursor;
    caschdrow caschd%rowtype;
    type ty_caschd is table of caschd%rowtype index by binary_integer;
    caschd_list         ty_caschd;
    l_caschd_cache_size number(23) := 1000000;
    l_row               pls_integer;

        l_is_required VARCHAR2(1);
        can_create_message NUMBER := 1;
  begin
    plog.setBeginSection(pkgctx, 'GenTemplate0217');

    select se.symbol,
           ca.exprice,
           to_char(ca.duedate, 'DD/MM/RRRR'),
           se.parvalue,
           i.fullname
      into l_symbol, l_exprice, l_duedate, l_parvalue, l_issuer_name
      from camast ca, sbsecurities se, issuers i
     where ca.camastid = p_ca_id
       and ca.codeid = se.codeid
       and se.issuerid = i.issuerid;

    --open c_caschd for
     -- select * from caschd where camastid = p_ca_id;
    for rec in
        (select cf.custodycd, cf.custid, cf.email, cf.fullname, cf.mobilesms,
                cf.address, cf.idcode, to_char(cf.iddate,'DD/MM/RRRR') iddate, ca.camastid,
                sum(ca.trade) trade, sum(ca.pqtty) pqtty
            from caschd ca, vw_cfmast_sms cf, afmast af
            where cf.custid = af.custid and ca.afacctno = af.acctno and ca.camastid = p_ca_id and ca.deltd <> 'Y'
            group by cf.custodycd, cf.custid, cf.email, cf.fullname, cf.mobilesms,
                  cf.address, cf.idcode, to_char(cf.iddate,'DD/MM/RRRR'), ca.camastid
            )
    loop
      /*fetch c_caschd bulk collect
        into caschd_list limit l_caschd_cache_size;

      plog.DEBUG(pkgctx, 'count ' || caschd_list.COUNT);
      exit when caschd_list.COUNT = 0;
      l_row := caschd_list.FIRST;

      while (l_row is not null)
       loop
        caschdrow := caschd_list(l_row);*/
                can_create_message:= 1;
        ----check mau co phai dang ky khong
                SELECT require_register INTO l_is_required FROM templates WHERE code = '0217';
                IF l_is_required = 'Y' THEN
                    SELECT COUNT(1) INTO can_create_message FROM aftemplates WHERE template_code = '0217' AND custid = rec.custid;
                END IF;
                ----
        l_datasource := 'select ''' || rec.fullname || ''' fullname, ''' ||
                        rec.custodycd || ''' custodycode, ''' ||
                        substr(rec.camastid, 7,10) || ''' account, ''' ||
                        p_ca_id ||  ''' cacode, ''' || l_symbol || ''' symbol, ''' ||
                        rec.fullname || ''' p_custname, ''' || rec.idcode ||
                        ''' p_license, ''' || rec.iddate || ''' p_iddate, ''' ||
                        rec.mobilesms || ''' p_phone, ''' || rec.address ||
                        ''' p_address, ''' || l_symbol || ''' p_symbol, ''' ||
                        ltrim(to_char(l_exprice, '9,999,999,999')) ||
                        ''' p_price, ''' || l_duedate || ''' p_duedate, ''' ||
                        ltrim(to_char(rec.trade, '9,999,999,999')) ||
                        ''' p_balance, ''' ||
                        ltrim(to_char(rec.pqtty, '9,999,999,999')) ||
                        ''' p_mqtty, ''' ||
                        ltrim(to_char(l_parvalue, '9,999,999,999')) ||
                        ''' p_parvalue, ''' || rec.custodycd ||
                        ''' p_custodycd, ''' || substr(rec.camastid, 7,10)||
                        ''' p_afacctno, ''' || l_issuer_name ||
                        ''' p_issname, ''dang ky mua co phieu phat hanh them'' p_desc from dual';

        --plog.error(pkgctx, 'EMAIL DATA: ' || l_datasource);
        if CheckEmail(rec.email) AND can_create_message <> 0  then
           insert into emaillog
          (autoid,
           email,
           templateid,
           datasource,
           status,
           createtime,
           afacctno)
        values
          (seq_emaillog.nextval,
           rec.email,
           '0217',
           l_datasource,
           'A',
           sysdate,
           substr(rec.camastid, 7,10));
        end if;

       -- l_row := caschd_list.NEXT(l_row);
     -- end loop;

    end loop;

    plog.setEndSection(pkgctx, 'GenTemplate0217');
  exception
    when others then
      plog.error(pkgctx, sqlerrm);
      plog.setEndSection(pkgctx, 'GenTemplate0217');
  end;

procedure GenTemplate0219(p_template_id varchar2) is
    l_datasource  varchar2(2000);
    BEGIN
            ---mr0057
    for rec in (
        SELECT getcurrdate INDATE,LN.AUTOID,LN.CUSTID,LN.FULLNAME,LN.BRID,LN.BRNAME,LN.CUSTODYCD ,LN.trfacctno acctno,RLSDATE,
           LN.OVERDUEDATE,LN.NML,LN.LAI_DUKIEN intnmlacr,LN.ADDRESS,MOBILEsms, ln.nml + ln.lai_dukien totalamt, 0 feeintnmlacr, email
   FROM ( SELECT to_date(getcurrdate,'dd/mm/rrrr') INDATE,LNS.AUTOID,lnm.acctno,cf.custid, cf.fullname,cf.brid, br.brname, cf.custodycd, lnm.trfacctno,LNS.RLSDATE,lns.overduedate,LNS.NML,cf.mobilesms,cf.email,
               (CASE WHEN LNS.ACRDATE<LNS.DUEDATE THEN
               --TY LE RATE1
               (  sum(lnS.INTNMLACR + ROUND((lnS.NML * lnS.RATE1 / 100 * TO_NUMBER(LNS.DUEDATE -lnS.acrdate)+lnS.NML * lnS.RATE2 / 100 * TO_NUMBER(LNS.OVERDUEDATE  -lnS.DUEDATE))
                                      /(Case When LNM.DRATE= 'D1' then  30
                                                 When LNM.DRATE= 'D2' then  TO_NUMBER(TO_CHAR(LAST_DAY(TO_DATE(LNS.OVERDUEDATE + 1,'dd/mm/rrrr')),'dd'))
                                                 When LNM.DRATE= 'Y1' then  360
                                                 When LNM.DRATE= 'Y2' then
                                                         TO_DATE(CONCAT('31/12/',SUBSTR(LNS.OVERDUEDATE + 1,7)),'dd/mm/rrrr') - TO_DATE(CONCAT('01/01/',SUBSTR(LNS.OVERDUEDATE + 1,7)),'dd/mm/rrrr') + 1
                                                 When LNM.DRATE= 'Y3' then  365
                                             End
                                             )
                                     ,4))+
                 sum(lnS.FEEINTNMLACR + ROUND((lnS.NML * lnS.CFRATE1 / 100 * TO_NUMBER(LNS.DUEDATE -lnS.acrdate)+lnS.NML * lnS.CFRATE2 / 100 * TO_NUMBER(LNS.OVERDUEDATE  -lnS.DUEDATE))
                          / (Case When LNM.DRATE= 'D1' then  30
                                                 When LNM.DRATE= 'D2' then  TO_NUMBER(TO_CHAR(LAST_DAY(TO_DATE(LNS.OVERDUEDATE + 1,'dd/mm/rrrr')),'dd'))
                                                 When LNM.DRATE= 'Y1' then  360
                                                 When LNM.DRATE= 'Y2' then
                                                         TO_DATE(CONCAT('31/12/',SUBSTR(LNS.OVERDUEDATE + 1,7)),'dd/mm/rrrr') - TO_DATE(CONCAT('01/01/',SUBSTR(LNS.OVERDUEDATE + 1,7)),'dd/mm/rrrr') + 1
                                                 When LNM.DRATE= 'Y3' then  365
                                             End
                                             )
                    ,4)))
                    --TY LE RATE2
                ELSE ( sum(lnS.INTNMLACR + ROUND(lnS.NML * lnS.RATE2 / 100 * TO_NUMBER(LNS.OVERDUEDATE  -lnS.acrdate)
                                      /(Case When LNM.DRATE= 'D1' then  30
                                                 When LNM.DRATE= 'D2' then  TO_NUMBER(TO_CHAR(LAST_DAY(TO_DATE(LNS.OVERDUEDATE + 1,'dd/mm/rrrr')),'dd'))
                                                 When LNM.DRATE= 'Y1' then  360
                                                 When LNM.DRATE= 'Y2' then
                                                         TO_DATE(CONCAT('31/12/',SUBSTR(LNS.OVERDUEDATE + 1,7)),'dd/mm/rrrr') - TO_DATE(CONCAT('01/01/',SUBSTR(LNS.OVERDUEDATE + 1,7)),'dd/mm/rrrr') + 1
                                                 When LNM.DRATE= 'Y3' then  365
                                             End
                                             )
                                     ,4))+
                 sum( lnS.FEEINTNMLACR + ROUND(lnS.NML * lnS.CFRATE2 / 100 * TO_NUMBER(LNS.OVERDUEDATE  -lnS.acrdate)
                          / (Case When LNM.DRATE= 'D1' then  30
                                                 When LNM.DRATE= 'D2' then  TO_NUMBER(TO_CHAR(LAST_DAY(TO_DATE(LNS.OVERDUEDATE + 1,'dd/mm/rrrr')),'dd'))
                                                 When LNM.DRATE= 'Y1' then  360
                                                 When LNM.DRATE= 'Y2' then
                                                         TO_DATE(CONCAT('31/12/',SUBSTR(LNS.OVERDUEDATE + 1,7)),'dd/mm/rrrr') - TO_DATE(CONCAT('01/01/',SUBSTR(LNS.OVERDUEDATE + 1,7)),'dd/mm/rrrr') + 1
                                                 When LNM.DRATE= 'Y3' then  365
                                             End
                                             ) ,4))) END)  LAI_DUKIEN,
                  CF.ADDRESS,NVL(CF.MOBILESMS,'') MOBILE
             FROM lnmast  lnm, cfmast cf,  afmast af, brgrp br, lnschd lns, LNTYPE LNT
             WHERE  af.custid=cf.custid
                  AND LNM.ACCTNO=LNS.ACCTNO
                  AND af.acctno =lnm.trfacctno
                  AND br.brid=cf.brid
                  and lnm.rlsamt >0
                  AND LNM.STATUS<>'Y'
                  AND LNS.NML >0
                  AND LNM.FTYPE='AF'
                  and lns.RLSDATE is not null
                   AND LNT.ACTYPE=LNM.ACTYPE
                --  AND fn_get_prevdate(LNS.OVERDUEDATE,LNT.WARNINGDAYS) <=to_date(getcurrdate,'dd/mm/rrrr')
                 AND fn_get_prevdate(LNS.OVERDUEDATE,LNT.WARNINGDAYS) =to_date(getcurrdate,'dd/mm/rrrr')
                   AND LNS.OVERDUEDATE >to_date(getcurrdate,'dd/mm/rrrr')
                  GROUP BY LNS.AUTOID,lnm.acctno,cf.custid, cf.fullname, br.brname, cf.brid,cf.custodycd, lnm.trfacctno,LNS.RLSDATE,lns.overduedate,
                LNS.NML,CF.ADDRESS,NVL(CF.MOBILESMS,''),LNS.ACRDATE,LNS.DUEDATE, cf.mobilesms, cf.email
                ) LN

ORDER BY LN.INDATE,LN.overduedate
        )
        loop
            if checkemail(rec.email) then
                l_datasource := 'select ''' || rec.fullname || ''' fullname, ''' ||
                        rec.custodycd || ''' custodycd, ''' ||
                        rec.ADDRESS || ''' address, ''' ||
                        rec.mobilesms || ''' mobilesms, ''' ||
                        rec.autoid || ''' acctno, ''' ||
                        to_char(rec.rlsdate, 'DD/MM/RRRR') || ''' rlsdate, ''' ||
                        to_char(rec.overduedate, 'DD/MM/RRRR') || ''' overduedate, ''' ||
                        ltrim(to_char(rec.nml, '9,999,999,999')) || ''' nml, '''||
                        ltrim(to_char(rec.INTNMLACR, '9,999,999,999')) || ''' intnmlacr, '''||
                                                ltrim(to_char(rec.totalamt, '9,999,999,999')) || ''' totalamt, '''||
                        ltrim(to_char(rec.FEEINTNMLACR,'9,999,999,999')) || ''' feeintnmlacr from dual';

                InsertEmailLog(rec.email, '0219', l_datasource, rec.acctno);
            end if;


    end loop;
  exception
    when others then
      plog.error(pkgctx, sqlerrm);
      plog.setEndSection(pkgctx, 'GenTemplate0219');
  end;

---------------0215
procedure GenTemplate0215(p_template_id varchar2) is
    l_data_source  varchar2(2000);
    BEGIN

  ---voi nhung mau email khong can phai dang ky
            --mau email ket qua khop lenh cuoi ngay 0215
            FOR rec IN
            (
                SELECT od.afacctno, cf.email address, cf.custodycd, cf.fullname  FROM vw_odmast_all od, vw_cfmast_sms cf
          WHERE txdate = (SELECT to_date(varvalue,'DD/MM/RRRR') FROM sysvar WHERE varname = 'PREVDATE') --PREVDATE
          AND od.custid = cf.custid AND p_template_id = '0215'
                    AND od.MATCHAMT > 0
                    GROUP BY od.afacctno, cf.email , cf.custodycd, cf.fullname
            )
            LOOP
                  l_data_source := 'select ''' || rec.custodycd ||
                                                                 ''' custodycode, ''' || rec.fullname ||
                                                                 ''' fullname, ''' || rec.afacctno ||
                                                                 ''' account, ''' ||  rec.afacctno ||
                                                                 ''' AFACCTNO, ''' || rec.custodycd ||
                                                                 ''' PV_CUSTODYCD, ''' || rec.afacctno ||
                                                                 ''' PV_AFACCTNO, ''' || to_char(getcurrdate,'DD/MM/RRRR') ||
                                                                 ''' F_DATE, '''|| to_char(getcurrdate,'DD/MM/RRRR') ||
                                                                 ''' T_DATE, ''' || rec.custodycd ||
                                                                 ''' CUSTODYCD, ''' || 'ALL' ||
                                                                 ''' EXECTYPE, ''' || 'ALL' ||
                                                                 ''' PV_SYMBOL, ''' || 'ALL' ||
                                                                 ''' VIA, ''' ||
                                                                 fn_get_sysvar_for_report('SYSTEM', 'PREVDATE') ||
                                                                 ''' daily from dual;';
                        if /*instr(rec.address,'@') = 0 or*/ CheckEmail(rec.address) then
                                    InsertEmailLog(rec.address, '0215', l_data_source, rec.afacctno);
                            end if;
            END LOOP;


  exception
    when others then
      plog.error(pkgctx, sqlerrm);
      plog.setEndSection(pkgctx, 'GenTemplate0215');
  end;
-----END 0215
---------------templates gui cuoi thang
procedure GenTemplateEOM(p_template_id varchar2) is
            l_require_register VARCHAR2(1);
              can_create_message NUMBER := 1;
                    v_firstdate DATE;
                    v_todate DATE;
                    l_data_source VARCHAR2(1000);
  begin
    plog.setBeginSection(pkgctx, 'GenTemplateEOM');

    IF p_template_id = '0214' THEN
            ---lay ngay dau thang truoc
            SELECT trunc( to_date(varvalue,'DD/MM/RRRR'),'MONTH')  INTO v_firstdate FROM sysvar WHERE varname = 'PREVDATE';
            SELECT TO_Date(getcurrdate, 'DD/MM/RRRR') INTO v_todate FROM dual;
            SELECT require_register INTO l_require_register FROM templates WHERE code = '0214';
            IF l_require_register = 'N' THEN  --in tat ca
                FOR rec IN
                    (
                     SELECT a.custid, a.custodycd, max(a.acctno) acctno, cf.fullname, cf.email FROM
                     (
                        SELECT custid, custodycd, acctno FROM vw_citran_gen
                        WHERE busdate BETWEEN v_firstdate AND v_todate
                            and field in ('BALANCE','RECEIVING','EMKAMT','DFDEBTAMT')
                            and TLTXCD NOT IN ('6690','6691','6621','6660','6600','6601','6602','1144','1145')
                        GROUP BY custid, custodycd, acctno
                        UNION
                        SELECT custid, custodycd, afacctno acctno
                        FROM vw_setran_gen
                        WHERE busdate BETWEEN v_firstdate AND v_todate
                            and field in ('TRADE','MORTAGE','BLOCKED','DTOCLOSE','WITHDRAW','RECEIVING')
                            and sectype <> '004'
                        GROUP BY custid, custodycd, afacctno
                        ) a, cfmast cf WHERE cf.custodycd = a.custodycd
                        group by a.custid, a.custodycd, cf.fullname, cf.email
                    )
                LOOP
                    ----------------insert into emaillog
                    l_data_source := 'select ''' || rec.custodycd ||
                                                                 ''' custodycode, '''  || rec.acctno ||
                                                                 ''' account, ''' || rec.fullname ||
                                                                 ''' fullname, ''' ||rec.custodycd ||
                                                                 ''' pv_CUSTODYCD, ''' || 'ALL'/*rec.acctno*/ ||
                                                                 ''' PV_AFACCTNO, ''' ||to_char(v_firstdate,'DD/MM/RRRR') ||
                                                                 ''' F_DATE, ''' || to_char(v_todate,'DD/MM/RRRR') ||
                                                                 ''' T_DATE, ''' || '0001' ||
                                                                 ''' TLID, ''' ||
                                                                 to_char(to_date(fn_get_sysvar_for_report(p_sys_grp  => 'SYSTEM',
                                                                                                                                                    p_sys_name => 'PREVDATE'),
                                                                                                 'DD/MM/RRRR'),
                                                                                 'MM/RRRR') || ''' monthly from dual;';

                    --------------------------------------------------
           if  CheckEmail(rec.email) then
                                    InsertEmailLog(rec.email, '0214', l_data_source, rec.acctno);
                     END IF;
                end LOOP;
            ELSE --chi in khach hang dang ky
                FOR rec IN
                    (
                      SELECT a.custid, a.custodycd, max(a.acctno) acctno, cf.fullname, cf.email FROM
                     (
                        SELECT custid, custodycd, acctno FROM vw_citran_gen
                        WHERE busdate BETWEEN v_firstdate AND v_todate
                            and field in ('BALANCE','RECEIVING','EMKAMT','DFDEBTAMT')
                            and TLTXCD NOT IN ('6690','6691','6621','6660','6600','6601','6602','1144','1145')
                        GROUP BY custid, custodycd, acctno
                        UNION
                        SELECT custid, custodycd, afacctno acctno FROM vw_setran_gen
                        WHERE busdate BETWEEN v_firstdate AND v_todate
                            and field in ('TRADE','MORTAGE','BLOCKED','DTOCLOSE','WITHDRAW','RECEIVING')
                            and sectype <> '004'
                        GROUP BY custid, custodycd, afacctno
                        ) a, aftemplates aft, cfmast cf
                        WHERE aft.custid = a.custid AND aft.template_code = '0214' AND cf.custodycd = a.custodycd
                        group by a.custid, a.custodycd, cf.fullname, cf.email
                    )
                    LOOP
                        ----------------insert into emaillog
                    l_data_source := 'select ''' || rec.custodycd ||
                                                                 ''' custodycode, '''  || rec.acctno ||
                                                                 ''' account, ''' || rec.fullname ||
                                                                 ''' fullname, ''' ||rec.custodycd ||
                                                                 ''' pv_CUSTODYCD, ''' || 'ALL'/*rec.acctno*/ ||
                                                                 ''' PV_AFACCTNO, ''' ||to_char(v_firstdate,'DD/MM/RRRR') ||
                                                                 ''' F_DATE, ''' || to_char(v_todate,'DD/MM/RRRR') ||
                                                                 ''' T_DATE, ''' || '0001' ||
                                                                 ''' TLID, ''' ||
                                                                 to_char(to_date(fn_get_sysvar_for_report(p_sys_grp  => 'SYSTEM',
                                                                                                                                                    p_sys_name => 'PREVDATE'),
                                                                                                 'DD/MM/RRRR'),
                                                                                 'MM/RRRR') || ''' monthly from dual;';

                    --------------------------------------------------
           if  CheckEmail(rec.email) then
                                    InsertEmailLog(rec.email, '0214', l_data_source, rec.acctno);
                     END IF;
                    END LOOP;
            END IF;
    END IF;
    plog.setEndSection(pkgctx, 'GenTemplateEOM');
  exception
    when others then
      plog.error(pkgctx, sqlerrm||'-'||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
      plog.setEndSection(pkgctx, 'GenTemplateEOM');
  end;

  procedure GenTemplate0326(p_template_id varchar2) is

    l_datasource varchar2(4000);


  begin
    plog.setBeginSection(pkgctx, 'GenTemplate0326');


        FOR rec IN
            (
      select mst.camastid,
             mst.duedate,
             mst.todatetransfer,
             mst.exprice,
             s.symbol,
             cf.custodycd,
             schd.afacctno,
                         cf.custid,
             schd.pqtty,
             cf.mobilesms mobile
        from camast mst, caschd schd, sbsecurities s, afmast af, vw_cfmast_sms cf
       where mst.camastid = schd.camastid
         and mst.codeid = s.codeid
         and schd.afacctno = af.acctno
         and af.custid = cf.custid
                 AND mst.status IN ('M','V')
         and schd.pqtty > 0
         and fn_get_prevdate(mst.duedate, 3) = getcurrdate
         and mst.catype = '014' and schd.deltd <> 'Y'
         and cf.mobilesms is not NULL
                 )

    loop


        l_datasource := 'select ''' || rec.custodycd ||
                        ''' custodycode, ''' ||rec.afacctno||
                        ''' afacctno, ''' || rec.pqtty ||
                        ''' pqtty, ''' || rec.symbol || ''' symbol, ''' ||
                        ltrim(to_char( rec.exprice, '9,999,999,999'))
                        || ''' exprice, ''' ||
                        to_char(rec.todatetransfer, 'DD/MM/RRRR')
                         || ''' todatetransfer, ''' ||
                         to_char(rec.duedate, 'DD/MM/RRRR')
                         || ''' duedate from dual';

        InsertEmailLog(rec.mobile,
                       p_template_id,
                       l_datasource,
                       rec.afacctno);
      end loop;



    /*update templates_scheduler
       set last_start_date = getcurrdate,
           next_run_date   = fn_GetNextRunDate(getcurrdate, repeat_interval)
     where template_id = p_template_id;
*/
    plog.setEndSection(pkgctx, 'GenTemplate0326');
  exception
    when others then
      plog.error(pkgctx, sqlerrm);
      plog.setEndSection(pkgctx, 'GenTemplate0326');
  end;

  procedure GenTemplate0323(p_account varchar2) is
    type smsmatched_cursor is ref cursor;

    type smsmatch is record(
      autoid     smsmatched.autoid%type,
      custodycd  smsmatched.custodycd%type,
      orderid    smsmatched.orderid%type,
      txdate     smsmatched.txdate%type,
      header     smsmatched.header%type,
      detail     varchar2(300),
      footer     varchar2(1000)--,
      --matchprice smsmatched.matchprice%type--,
      --KLCL       smsmatched.matchqtty%type

      );

    c_smsmatched  smsmatched_cursor;
    smsmatchedrow smsmatch;

    type ty_smsmatched is table of smsmatch index by binary_integer;

    smsmatched_list         ty_smsmatched;
    l_smsmatched_cache_size number(23) := 1000;
    l_row                   pls_integer;

    l_message_template varchar2(240) := cspks_system.fn_get_sysvar('SYSTEM','COMPANYSHORTNAME') || '-KQKL TK [custodycode] ngay [txdate]: [detail]';
    l_template_id      char(4) := '0323';
    l_prefix_message   varchar2(160) := '';
    l_message          varchar2(300) := '';
    l_message_temp     varchar2(300) := '';
    l_previous_message varchar2(160) := '';
    l_detail           varchar2(300) := '';
    l_custodycd        varchar2(10) := '';
    l_smsmobile        varchar2(20) := '';
    l_datasource       varchar2(1000) := '';
    l_previous_header  varchar2(20) := '';
    l_header           varchar2(20) := '';
    l_orderid          varchar2(20) := '';
    l_previous_orderid varchar2(20) := '';
    l_footer           varchar2(1000) := '';
    l_previous_footer  varchar2(1000) := '';
    l_autoid           number(20);
    l_status           char(1) := 'L'; -- L: Less than, E: equal, G: greater than
  begin
    plog.setBeginSection(pkgctx, 'GenTemplate0323');

    select c.custodycd, c.mobilesms
      into l_custodycd, l_smsmobile
      from cfmast c, afmast a
     where c.custid = a.custid
       and a.acctno = p_account;

    -- Init prefix message
    l_prefix_message := replace(l_message_template,
                                '[custodycode]',
                                l_custodycd);
    l_prefix_message := replace(l_prefix_message,
                                '[txdate]',
                                to_char(getcurrdate,
                                        systemnums.C_DATE_FORMAT));
    l_prefix_message := replace(l_prefix_message, '[detail]');

    plog.debug(pkgctx, 'SMS prefix: ' || l_prefix_message);

     open c_smsmatched for
         --vu sua
       /*select max(autoid) autoid, custodycd, orderid, txdate, header,
          'KL ' || MAX(ORDERQTTY) || ' gia ' || price as detail,
          listagg(detail, ',') within group(order by detail)  as footer, matchprice,
          (MAX(ORDERQTTY) - max(TOTALQTTY)) as KLCL,
          'TONG_KHOP ' || sum(MATCHQTTY) || '/' || sum(orderqtty) as TONG_KHOP
          from (
                  select a.*, rownum top
                   from (select max(autoid) autoid, txdate,
                   custodycd,orderid, header,TOTALQTTY,ORDERQTTY,price,
                  ' KHOP ' || sum(matchqtty) || ' GIA ' || matchprice as detail, matchprice, sum(matchqtty) matchqtty
                   from smsmatched
                   where status = 'N'
                   and afacctno = p_account
                   group by txdate, custodycd, orderid,
                   header, matchprice ,TOTALQTTY,ORDERQTTY,price
                   order by autoid) a
               )
      group by custodycd, orderid, txdate, header ,price,  matchprice
      having MAX(ORDERQTTY) = max(TOTALQTTY)
      order by autoid;*/
      --chaunh begin
      /*select max(autoid) autoid, custodycd, orderid, txdate, header,
          listagg(detail, ',') within group(order by detail)  as detail
          ,'TONG_KHOP ' || sum(matchqtty) || '/' || orderqtty as footer
          from (
                  select a.*, rownum top
                   from
                   (
                       select max(autoid) autoid, txdate,
                       custodycd,orderid, header,sum(Matchqtty) matchqtty,price,
                       matchprice,
                       ' KHOP ' || sum(matchqtty) || ' GIA ' || matchprice as detail, orderqtty
                       from smsmatched
                       where status = 'N' AND custodycd = l_custodycd
                       group by txdate, custodycd, orderid,
                       header, matchprice ,price, orderqtty
                       order by autoid
                   ) a
               )
      group by custodycd, orderid, txdate, header ,price, orderqtty
      order by autoid;*/
          SELECT MAX(autoid) autoid, custodycd, orderid, txdate,HEADER,
       --listagg(detail,',') WITHIN GROUP (ORDER BY HEADER)  AS detail,  'TONG_KHOP ' || MAX(totalqtty)||'/'||  orderqtty AS footer
       listagg(detail,',') WITHIN GROUP (ORDER BY HEADER)  AS detail, '' AS footer
       FROM
       (
                  /*    select max(autoid) autoid, txdate,
                       custodycd,orderid, HEADER ,
                       ' KHOP ' || SUM(matchqtty) || ' GIA ' || matchprice as detail, MAX(totalqtty) totalqtty, orderqtty
                       from smsmatched
                       where status = 'N' AND custodycd = l_custodycd
                                             GROUP BY txdate, custodycd, orderid, matchprice,HEADER,orderqtty*/
                       select max(autoid) autoid, txdate,
                       custodycd,orderid, HEADER ,
                       ' KHOP ' || SUM(matchqtty) || ' GIA ' || matchprice as detail, MAX(totalqtty) totalqtty
                       from smsmatched
                       where status = 'N' AND custodycd = l_custodycd
                       GROUP BY txdate, custodycd, matchprice,HEADER,orderid

                       )
       GROUP BY HEADER, custodycd, txdate,orderid;
    loop
      fetch c_smsmatched bulk collect
        into smsmatched_list limit l_smsmatched_cache_size;

      plog.DEBUG(pkgctx, 'CNT: ' || smsmatched_list.COUNT);
      exit when smsmatched_list.COUNT = 0;
      l_row := smsmatched_list.FIRST;

      while (l_row is not null)

       loop
        smsmatchedrow := smsmatched_list(l_row);

        plog.DEBUG(pkgctx, 'Round [' || l_row || ']');

        l_detail  := smsmatchedrow.detail;
        l_header  := smsmatchedrow.header;
        l_orderid := smsmatchedrow.orderid;
        l_footer  := smsmatchedrow.footer;
        l_autoid  := smsmatchedrow.autoid;

        plog.debug(pkgctx, 'Previous SMS: ' || l_previous_message);
        if l_previous_message = '' or l_previous_message is null then
          l_message_temp := l_prefix_message || l_header || l_detail;
        else
          l_message_temp := l_previous_message; -- || ',' || l_header || l_detail;
        end if;

        plog.debug(pkgctx, 'orderid: ' || l_orderid);

        if l_previous_orderid <> '' or l_previous_orderid is not null then
          plog.debug(pkgctx, 'prev. orderid: ' || l_previous_orderid);
          if l_orderid = l_previous_orderid then
            l_message      := l_message_temp || ', ' || l_detail /*|| ', ' ||
                              l_footer*/
                              ;
            l_message_temp := l_message_temp || ', ' || l_detail;
          else
            l_message_temp := l_message_temp /*|| ', ' || l_previous_footer*/;

            if l_previous_header <> l_header then
              l_message_temp := l_message_temp || ', ' || l_header ||
                                l_detail;
            else
              l_message_temp := l_message_temp || ', ' || l_detail;
            end if;

            l_message := l_message_temp /*|| ', ' || l_footer*/;
          end if;
        else
          l_message := l_message_temp /*|| ', ' || l_footer*/;
        end if;

        plog.debug(pkgctx, 'Message temp: ' || l_message_temp);
        plog.debug(pkgctx,
                   'SMS message: ' || l_message || ' [' ||
                   length(l_message) || ']');


        if length(l_message) < 160 then
          l_previous_message := l_message_temp;
          l_previous_orderid := l_orderid;
          l_previous_footer  := l_footer;
          l_previous_header  := l_header;
          l_status           := 'L';

        elsif length(l_message) = 160 then

          plog.debug(pkgctx, 'SMS length equal 160');


          l_datasource := 'SELECT ''' || l_custodycd ||
                          ''' custodycode, ''' ||
                          to_char(smsmatchedrow.txdate, 'DD/MM/RRRR') ||
                          ''' txdate, ''' || l_message ||
                          ''' detail FROM DUAL';

          if l_smsmobile is not null and length(l_smsmobile) > 0 then

            InsertEmailLog(l_smsmobile,
                           l_template_id,
                           l_datasource,
                           p_account);

            /*            insert into emaillog
              (autoid, email, templateid, datasource, status, createtime)
            values
              (seq_emaillog.nextval,
               l_smsmobile,
               l_template_id,
               l_datasource,
               'A',
               sysdate);*/
          end if;

          l_previous_message := '';
          l_previous_orderid := '';
          l_previous_footer  := '';
          l_previous_header  := '';
          l_status           := 'E';

        else

          plog.debug(pkgctx, 'SMS length greater than 160');


          l_datasource := 'SELECT ''' || l_custodycd ||
                          ''' custodycode, ''' ||
                          to_char(smsmatchedrow.txdate, 'DD/MM/RRRR') ||
                          ''' txdate, ''' || l_previous_message || ', ' ||
                          l_previous_footer || ''' detail FROM DUAL';

          if l_smsmobile is not null and length(l_smsmobile) > 0 then
            InsertEmailLog(l_smsmobile,
                           l_template_id,
                           l_datasource,
                           p_account);
            /*            insert into emaillog
              (autoid, email, templateid, datasource, status, createtime)
            values
              (seq_emaillog.nextval,
               l_smsmobile,
               l_template_id,
               l_datasource,
               'A',
               sysdate);*/
          end if;

          l_message          := l_prefix_message || l_header || l_detail;
          l_previous_message := l_message;
          l_previous_orderid := l_orderid;
          l_previous_footer  := l_footer;
          l_previous_header  := l_header;
          l_status           := 'G';
          plog.debug(pkgctx, 'NEW SMS: ' || l_message);


        end if;

        if l_row = smsmatched_list.COUNT and l_status <> 'E' then

          if l_status = 'G' then
            l_message := l_message || ', ' || l_footer;
          end if;

          l_datasource := 'SELECT ''' || l_custodycd ||
                          ''' custodycode, ''' ||
                          to_char(smsmatchedrow.txdate, 'DD/MM/RRRR') ||
                          ''' txdate, ''' || l_message || --', ' || l_footer ||
                          ''' detail FROM DUAL';

          if l_smsmobile is not null and length(l_smsmobile) > 0 then

            InsertEmailLog(l_smsmobile,
                           l_template_id,
                           l_datasource,
                           p_account);
            /*            insert into emaillog
              (autoid, email, templateid, datasource, status, createtime)
            values
              (seq_emaillog.nextval,
               l_smsmobile,
               l_template_id,
               l_datasource,
               'A',
               sysdate);*/
          end if;

        end if;

        --Danh dau lenh khop
       /* plog.debug(pkgctx,
                   'AUTOID: [' || l_autoid || '] - ORDERID: [' || l_orderid ||
                   '] MATCHED PRICE: [' || smsmatchedrow.matchprice || ']');

       plog.error(pkgctx,
                   'AUTOID: [' || l_autoid || '] - ORDERID: [' || l_orderid ||
                   '] MATCHED PRICE: [' || smsmatchedrow.matchprice || ']');*/
        update smsmatched
           set status = 'M', sentdate = sysdate
         where orderid = l_orderid
           --and matchprice = smsmatchedrow.matchprice
           and autoid <= l_autoid;

        l_row := smsmatched_list.NEXT(l_row);
      end loop;

    end loop;
    update smsmatched
       set status = 'S'
     where afacctno = p_account
       and status = 'M';

    plog.setEndSection(pkgctx, 'GenTemplate0323');
  exception
    when others then
      update smsmatched set status = 'R' where afacctno = p_account;
      plog.error(pkgctx, sqlerrm);
      plog.setEndSection(pkgctx, 'GenTemplate0323');
  end;


procedure GenTemplate0322(p_od_id varchar2) is
    l_datasource  varchar2(2000);

    begin

    for rec in (
        select cf.fullname, cf.custodycd, cf.mobilesms , od.txdate ,od.orderqtty, od.quoteprice , sb.symbol, af.acctno afacctno
        from odmast od, vw_cfmast_sms cf, afmast af , sbsecurities sb, aftemplates aft
        where cf.custid = af.custid
        and cf.custid = aft.custid
        and sb.codeid = od.codeid
        and af.acctno = od.afacctno
        and od.exectype in('CB','CS')
        and aft.template_code = '0322'
        and od.orderid = p_od_id
                )
        loop

            l_datasource := 'select ''' || rec.fullname || ''' fullname, ''' ||
                        rec.custodycd || ''' custodycode, ''' ||
                        to_char(rec.txdate, 'DD/MM/RRRR')||
                        ''' txdate, ''' || rec.orderqtty ||
                        ''' orderqtty, ''' || ltrim(to_char(rec.quoteprice, '9,999,999,999')) || ''' quoteprice, ''' ||
                        rec.symbol || ''' symbol from dual';


          InsertEmailLog(rec.mobilesms, '0322', l_datasource, rec.afacctno);


          end loop;

    plog.setEndSection(pkgctx, 'GenTemplate0322');
  exception
    when others then
      plog.error(pkgctx, sqlerrm);
      plog.setEndSection(pkgctx, 'GenTemplate0322');
  end;

--mau sms thong bao quyen phat hanh them
  procedure GenTemplate0321(p_ca_id varchar2) is
    l_datasource  varchar2(4000);

  begin
    plog.setBeginSection(pkgctx, 'GenTemplate0321');

FOR  rec  IN (
      select cf.custodycd,cf.custid,
            max(ca.afacctno)afacctno,
            se.symbol,
           c.exprice,
           to_char(c.duedate, 'DD/MM/RRRR') duedate,
           se.parvalue,
           to_char(c.reportdate, 'DD/MM/RRRR') reportdate,
           c.exrate ,
           c.rightoffrate  ,
           to_char(c.todatetransfer, 'DD/MM/RRRR') todatetransfer,
           to_char(c.frdatetransfer, 'DD/MM/RRRR') frdatetransfer,
           to_char(c.begindate, 'DD/MM/RRRR') begindate,
           sum(CA.balance + CA.pbalance) balance,
           sum(ca.qtty + ca.pqtty) QTTY,
           cf.mobilesms
      from caschd ca, afmast af, vw_cfmast_sms cf, camast c, sbsecurities se
      WHERE ca.afacctno = af.acctno and ca.camastid = c.camastid
      AND af.custid = cf.custid  and nvl(c.tocodeid, c.codeid) = se.codeid
      and ca.camastid = p_ca_id  and ca.deltd <> 'Y'
      AND cf.mobilesms IS NOT NULL
      GROUP BY cf.custodycd,cf.custid,
            --ca.afacctno,
            se.symbol,
           c.exprice,
           to_char(c.duedate, 'DD/MM/RRRR') ,
           se.parvalue,
           to_char(c.reportdate, 'DD/MM/RRRR') ,
           c.exrate ,
           c.rightoffrate  ,
           to_char(c.todatetransfer, 'DD/MM/RRRR') ,
           to_char(c.frdatetransfer, 'DD/MM/RRRR') ,
           to_char(c.begindate, 'DD/MM/RRRR') ,
           cf.mobilesms
      )
loop


         l_datasource := 'select ''' || rec.custodycd || ''' custodycode, '''
                        --|| rec.afacctno ||''' afacctno, '''
                        || p_ca_id ||''' camastid, '''
                        || ltrim(to_char(rec.balance,'9,999,999,999')) ||''' balance, '''
                        || ltrim(to_char(rec.qtty,'9,999,999,999')) ||''' qtty, '''
                        || ltrim(to_char(rec.exprice,'9,999,999,999')) ||''' exprice, '''
                        || to_char(getcurrdate,'DD/MM/YYYY') || ''' txdate, '''
                        || rec.symbol || ''' symbol, '''
                        || rec.frdatetransfer || ''' frdatetransfer, '''
                        || rec.todatetransfer || ''' todatetransfer, '''
                        || rec.begindate || ''' begindate, '''
                        || rec.duedate || ''' duedate, '''
                        || rec.reportdate || ''' reportdate, '''
                        || rec.exrate || ''' exrate, '''
                        || rec.rightoffrate || ''' rightoffrate from dual';


       /*l_datasource :='Select ''BSC thong bao: TK '||l_custodycd||' duoc mua them co phieu ' || l_symbol ||' gia '||l_exprice || '. So luong CP duoc mua: ' || l_temp
                 ||' Ngay chot: '|| l_reportdate||', Ty le: ' ||l_rightoffrate || '. Thoi gian dang ky: Tu '|| l_begindate ||' den ' || l_duedate||', Thoi gian chuyen nhuong tu '||l_frdatetransfer||' den ' ||l_todatetransfer||'.'' detail from dual';
*/
        InsertEmailLog(rec.mobilesms, '0321', l_datasource, rec.afacctno);

      end loop;



    plog.setEndSection(pkgctx, 'GenTemplate0321');
  exception
    when others then
      plog.error(pkgctx, sqlerrm);
      plog.setEndSection(pkgctx, 'GenTemplate0321');
  end;

  --mau sms thong bao sap den han nop tien (5 ngay)
procedure GenTemplate327C(p_key_value varchar2) is
    l_datasource  varchar2(4000);

begin
    plog.setBeginSection(pkgctx, 'GenTemplate0327C');

    FOR  rec  IN (
            SELECT nvl( case  when LENGTH(cf.mobilesms)>=10 and substr(cf.mobilesms,1,2) in ('01','09') then  cf.mobilesms else '' end ,
                        case  when LENGTH(cf.mobile)>=10 and substr(cf.mobile,1,2) in ('01','09') then  cf.mobile else '' end  ) mobilesms,
                  SCHD.AUTOID, CF.CUSTODYCD,AF.ACCTNO,
                 SCHD.OVERDUEDATE PRINPERIOD
            FROM LNSCHD SCHD, LNMAST MST, CFMAST CF, CIMAST CI, AFMAST AF, CFMAST CFB, ALLCODE C1, ALLCODE C2, ALLCODE C3,
                AFTYPE AFT,
                (SELECT VARVALUE BUSDATE FROM SYSVAR WHERE VARNAME='BUSDATE')SYS
            WHERE SCHD.ACCTNO = MST.ACCTNO AND SCHD.REFTYPE IN ('P','GP')
            AND MST.TRFACCTNO = AF.ACCTNO AND AF.CUSTID = CF.CUSTID and mst.custbank = cfb.custid(+)
            AND AF.actype = AFT.actype
            AND AF.ACCTNO = CI.AFACCTNO
            and c1.cdtype = 'LN' and c1.cdname = 'INTPAIDMETHOD' and mst.intpaidmethod = c1.cdval
            and c2.cdtype = 'LN' and c2.cdname = 'DRATE' and mst.drate = c2.cdval
            and c3.cdtype = 'LN' and c3.cdname = 'AUTOAPPLY' and mst.autoapply = c3.cdval
            and fn_get_prevdate(schd.OVERDUEDATE,5) = getcurrdate
            and nvl( case  when LENGTH(cf.mobilesms)>=10 and substr(cf.mobilesms,1,2) in ('01','09') then  cf.mobilesms else '' end ,
                        case  when LENGTH(cf.mobile)>=10 and substr(cf.mobile,1,2) in ('01','09') then  cf.mobile else '' end  ) is not null
      )
    loop


         l_datasource := 'select ''' || rec.AUTOID || ''' autoid, '''
                                 || rec.custodycd || ''' custodycd, '''
                         || to_char(rec.PRINPERIOD,'DD/MM/YYYY') || ''' overduedate  from dual';

        InsertEmailLog(rec.mobilesms, p_key_value, l_datasource, rec.ACCTNO);

      end loop;



    plog.setEndSection(pkgctx, 'GenTemplate327C');
  exception
    when others then
      plog.error(pkgctx, sqlerrm);
      plog.setEndSection(pkgctx, 'GenTemplate327C');
  end;

--mau sms gui thong bao cho quan tri rui ro
procedure GenTemplate0304(p_key_value varchar2) is
    l_datasource  varchar2(4000);

begin
    plog.setBeginSection(pkgctx, 'GenTemplate0304');
for rec in (
    select to_char(getcurrdate,'DD/MM/RRRR') txdate,a.Call, b.XL, c.XLKQ, trim(d.PHone) phone from
    (SELECT COUNT(1) CALL FROM tbl_mr0063 WHERE indate =  getcurrdate ) a,
    (SELECT COUNT(1) XL FROM tbl_mr0059 WHERE indate = getcurrdate) b,
    ( SELECT COUNT(1) XLKQ  FROM tbl_mr0058 WHERE indate = getcurrdate ) c,
    (select trim(regexp_substr(VARVALUE,'[^,]+', 1, level)) phone from (SELECT varvalue FROM sysvar WHERE varname = 'QAREMINDER' )
    connect by regexp_substr(VARVALUE, '[^,]+', 1, level) is not NULL
    ) d
    where a.call + b.xl + c.xlkq <> 0
 )
 loop
     l_datasource := 'select '''|| rec.txdate || ''' txdate, '''
                                || rec.call || ''' call, '''
                                || rec.XL || ''' XL, '''
                                || rec.XLKQ || ''' XLKQ  from dual';

        insert into emaillog
          (autoid, email, templateid, datasource, status, createtime, note)
        values
          (seq_emaillog.nextval,
           rec.phone,
           '0304',
           l_datasource,
           'A',
           sysdate,
           '---');
 end loop;
  plog.setEndSection(pkgctx, 'GenTemplate0304');
  exception
    when others then
      plog.error(pkgctx, sqlerrm);
      plog.setEndSection(pkgctx, 'GenTemplate0304');
  end;

 -- Mau sms thong bao thuc hien quyen
  procedure GenTemplate0320(p_ca_id varchar2) is
    l_custodycd  cfmast.custodycd%type;
    l_fullname   cfmast.fullname%type;
    l_mobilesms   varchar2(100);
    l_templateid varchar2(6);
    l_datasource varchar2(2000);
    l_symbol     sbsecurities.symbol%type;
    l_tocodeid   camast.tocodeid%type;
    l_to_symbol  sbsecurities.symbol%type;

    l_catype camast.catype%type;

    l_report_date     date;
    --l_trade_date      date ;
    l_begin_date      date;
    l_due_date        date ;
    l_frdate_transfer varchar2(10);
    l_todate_transfer varchar2(10);

    l_rate            varchar2(10);
    l_devident_shares varchar2(10);
    l_devident_value  varchar2(10);
    l_exrate          varchar2(10);
    l_gia             varchar2(10);
    l_right_off_rate varchar2(10);
    l_devident_rate  varchar2(10);
    l_interest_rate  varchar2(10);
    l_trade_place    varchar2(10);
    l_to_floor_code  varchar2(10);
    l_fr_floor_code  varchar2(10);
    l_fr_trade_place varchar2(10);
    l_to_trade_place varchar2(10);
    l_issuer         varchar2(250);
    l_tradeplace_desc varchar2(250);
    l_inaction_date  date ;
    l_typerate       char(1);
    l_exprice        camast.exprice%type;
    l_advdesc        camast.advdesc%type;
    l_purpose_desc   camast.purposedesc%type;

    --l_to_codeid       varchar2(10);
    --l_to_symbol       varchar2(10);
    --l_catype_desc     varchar2(100);
    --l_floor_code      varchar2(10);

    type caschd_cursor is ref cursor;

    c_caschd  caschd_cursor;
    caschdrow caschd%rowtype;

    type ty_caschd is table of caschd%rowtype index by binary_integer;

    caschd_list         ty_caschd;
    l_caschd_cache_size number(23) := 1000000;
    l_row               pls_integer;
  begin
    plog.setBeginSection(pkgctx, 'GenTemplate0320');
    l_templateid := '320A';

    select s.symbol,
           s.tradeplace,
           nvl(i.fullname, i.shortname) issuer,
           ca.catype,
           ca.devidentrate,
           ca.devidentshares,
           ca.rightoffrate,
           ca.reportdate,
           nvl(ca.actiondate, ca.actiondate) actiondate,
           ca.advdesc,
           a.cdcontent,
           ca.purposedesc,
           ca.interestrate,
           ca.typerate,
           ca.exrate,
           ca.exprice,
           ca.tocodeid,
           ca.totradeplace,
           ca.begindate,
           ca.duedate,
           ca.frdatetransfer,
           ca.todatetransfer,
           ca.devidentvalue,
           ca.frtradeplace
      into l_symbol,
           l_trade_place,
           l_issuer,
           l_catype,
           l_devident_rate,
           l_devident_shares,
           l_right_off_rate,
           l_report_date,
           l_inaction_date,
           l_advdesc,
           l_tradeplace_desc,
           l_purpose_desc,
           l_interest_rate,
           l_typerate,
           l_exrate,
           l_exprice,
           l_tocodeid,
           l_to_floor_code,
           l_begin_date,
           l_due_date,
           l_frdate_transfer,
           l_todate_transfer,
           l_devident_value,
           l_fr_floor_code
      from camast ca, sbsecurities s, issuers i, allcode a
     where ca.codeid = s.codeid
       and s.issuerid = i.issuerid
       and a.cdval = s.tradeplace
       and a.cdtype = 'SE'
       and a.cdname = 'TRADEPLACE'
       and ca.camastid = p_ca_id;


    if l_catype = '010' then
      if l_typerate = 'R' then
        l_rate := l_devident_rate || '%';
        l_gia := l_devident_rate * 100;
      elsif l_typerate = 'V' then
        l_rate := l_devident_value || ' d/CP';
      end if;

      l_templateid := '320A';

    elsif l_catype = '011' then
      l_rate       := l_devident_shares;
      l_templateid := '320B';

    begin
      select symbol
        into l_to_symbol
        from sbsecurities
        where codeid = l_tocodeid;

         exception
        when others then
        l_to_symbol:='';
    end;

    elsif l_catype = '021' then
      l_rate       := l_exrate;
      l_templateid := '320B';

    end if;

    open c_caschd for
      select * from caschd where camastid = p_ca_id and deltd <> 'Y';

    loop
      fetch c_caschd bulk collect
        into caschd_list limit l_caschd_cache_size;

      plog.DEBUG(pkgctx, 'count ' || caschd_list.COUNT);
      exit when caschd_list.COUNT = 0;
      l_row := caschd_list.FIRST;

      while (l_row is not null)

       loop
        caschdrow := caschd_list(l_row);

        -- Thong tin khach hang
        select c.custodycd, c.mobilesms, c.fullname
          into l_custodycd, l_mobilesms, l_fullname
          from cfmast c, afmast a
         where c.custid = a.custid
           and a.acctno = caschdrow.afacctno;

        if length(l_rate) > 0 then

         l_datasource := 'select ''' || l_fullname || ''' fullname, ''' ||
                          l_custodycd || ''' custodycode, ''' ||
                          caschdrow.afacctno || ''' account, ''' ||
                          l_symbol || ''' symbol, ''' || l_issuer ||
                          ''' issuer, ''' ||
                          to_char(l_tradeplace_desc) ||
                          ''' tradeplace, ''' || caschdrow.trade ||
                          ''' trade, ''' ||
                          to_char(l_report_date, 'DD/MM/RRRR') ||
                          ''' reportdate, ''' || l_advdesc ||
                          ''' advdesc, ''' || l_rate || ''' rate, ''' ||
                          to_char(l_inaction_date, 'DD/MM/RRRR') || ''' inactiondate, ''' ||
                          l_purpose_desc || ''' purpose, ''' || l_exrate ||
                          ''' exrate, ''' || l_to_symbol ||
                          ''' tosymbol, ''' ||
                           to_char(l_begin_date, 'DD/MM/RRRR') ||
                          ''' begindate, ''' ||
                          to_char(l_due_date, 'DD/MM/RRRR') ||
                          ''' duedate, ''' ||
                          to_char(l_frdate_transfer, 'DD/MM/RRRR') ||
                          ''' frdatetransfer, ''' ||
                          to_char(l_todate_transfer, 'DD/MM/RRRR') ||
                          ''' todatetransfer, ''' ||
                          ltrim(to_char(l_exprice, '9,999,999,999')) ||
                          ''' exprice, ''' || caschdrow.pqtty ||
                          ''' pqtty, ''' ||
                           ltrim(to_char(l_gia, '9,999,999,999')) ||
                           ''' gia, ''' ||
                          l_to_trade_place || ''' totradeplace, ''' || l_fr_trade_place ||
                          ''' frtradeplace from dual';

          /*          insert into emaillog
            (autoid, email, templateid, datasource, status, createtime)
          values
            (seq_emaillog.nextval,
             l_email,
             l_templateid,
             l_datasource,
             'A',
             sysdate);*/
          InsertEmailLog(l_mobilesms,
                         l_templateid,
                         l_datasource,
                         caschdrow.afacctno);

        end if;

        l_row := caschd_list.NEXT(l_row);
      end loop;

    end loop;

    plog.setEndSection(pkgctx, 'GenTemplate0320');
  exception
    when others then
      plog.error(pkgctx, sqlerrm);
      plog.setEndSection(pkgctx, 'GenTemplate0320');
  end;
--'0224'  --email canh bao ty le duoi muc call
--0327 --  sms th?b?b? sung t?s?n d?m b?o ho?c tr? n? :
procedure GenTemplate0224(p_key_value varchar2) is
    l_data_source  varchar2(4000);
        v_count NUMBER;

begin
    plog.setBeginSection(pkgctx, 'GenTemplate0304');
        --0224
   for rec in
       (----vw_mr0005
                         select  cf.custodycd, af.acctno, cf.fullname, cf.mobilesms, cf.email, cf.address,
                                         to_char(getcurrdate,'DD/MM/YYYY') txdate,
                                         ltrim(to_char(sec.marginrate,'9,999.99')) marginrate ,
                                         ltrim(to_char(af.mrmrate ,'9,999.99')) mrmrate
                        from cfmast cf, afmast af, cimast ci, aftype aft,mrtype mrt,
                                (select afacctno, marginrate,se_outstanding outstanding,se_navaccount navaccount,seass, seamt,avladvance from buf_ci_account ) sec,
                             (
                             select max(txdate) CALLDATE, max(txtime) CALLTIME, acctno from sendmsglog group by acctno
                        ) SMS

                        where cf.custid = af.custid
                        and cf.custatcom = 'Y'
                        and af.actype = aft.actype and aft.mrtype =mrt.actype and af.actype <> '0000'
                        and af.acctno = ci.acctno
                        and af.acctno = sec.afacctno
                        and af.acctno = sms.acctno(+)
                        and (CI.OVAMT+CI.DUEAMT=0)
                        AND (
                                (AFT.MNEMONIC <>'T3') and
                                                        ((sec.marginrate<AF.MRwRATE and sec.marginrate>=AF.MRCRATE)-- chi pham ti le canh bao
                                                        OR (SEC.MARGINRATE<AF.MRCRATE AND SEC.MARGINRATE>=AF.MRMRATE AND AF.Callday=0)-- vi pham R thoat Call nhung callday=0
                                                            /*OR (EXISTS (SELECT * FROM LNSCHD SCHD,LNMAST MST,LNTYPE TYPE --den ngay canh bao
                                                                                    WHERE MST.ACCTNO=SCHD.ACCTNO AND MST.TRFACCTNO=AF.ACCTNO AND MST.ACTYPE=TYPE.ACTYPE
                                                                                    AND fn_get_prevdate(SCHD.OVERDUEDATE,TYPE.Warningdays)<=GETCURRDATE  AND SCHD.OVERDUEDATE >GETCURRDATE)
                                                                             and af.callday = 0 and sec.marginrate > af.mrcrate
                                                                     )*/
                                                            )

                                 )

       )
   loop
        if  checkemail(rec.email) then
           l_data_source := 'select ''' || rec.fullname || ''' fullname, '''
                                        || rec.address || ''' address, '''
                                        || rec.mobilesms || ''' mobilesms, '''
                                        || rec.custodycd || ''' custodycd, '''
                                        || rec.txdate || ''' txdate,'''
                                        || rec.marginrate || ''' marginrate, '''
                                        || rec.mrmrate || ''' mrmrate '
                                        || ' from dual;';

            InsertEmailLog(rec.email, '0224', l_data_source, rec.acctno);

       end if;

             -------------0328: tai khoan vi pham ti le
        SELECT length(TRIM(rec.mobilesms)) INTO v_count FROM dual;
        IF v_count > 0 THEN
                 l_data_source := 'select ''' || rec.custodycd || ''' custodycd, '''
                                        || rec.txdate || ''' txdate from dual;';
         InsertEmailLog(rec.mobilesms, '0328', l_data_source, rec.acctno);
            END IF;

  end loop;

   ---0327: lay ra nhung tai khoan co no 5 ngay nua het han: vi pham ti le 5 ngay
     FOR r IN
   (
         select  cf.custodycd, af.acctno, cf.fullname, cf.mobilesms, cf.email, cf.address, ln.overduedate
            from cfmast cf, afmast af, cimast ci, aftype aft,mrtype mrt,
                    (select afacctno, marginrate,se_outstanding outstanding,se_navaccount navaccount,seass, seamt,avladvance from buf_ci_account ) sec
                    ,
                    (SELECT * FROM LNSCHD SCHD,LNMAST MST,LNTYPE TYPE --den ngay canh bao
                            WHERE MST.ACCTNO=SCHD.ACCTNO AND MST.ACTYPE=TYPE.ACTYPE
                            AND fn_get_prevdate(SCHD.OVERDUEDATE,TYPE.Warningdays) = GETCURRDATE
                            AND SCHD.OVERDUEDATE >GETCURRDATE) LN
            WHERE cf.custid = af.custid
            and cf.custatcom = 'Y'
            and af.actype = aft.actype and aft.mrtype =mrt.actype and af.actype <> '0000'
            and af.acctno = ci.acctno
            and af.acctno = sec.afacctno
            and (CI.OVAMT+CI.DUEAMT=0)
            AND af.callday = 0 AND sec.marginrate > af.mrcrate
            AND aft.mnemonic <> 'T3'
            AND ln.TRFACCTNO=AF.ACCTNO
            GROUP BY  cf.custodycd, af.acctno, cf.fullname, cf.mobilesms, cf.email, cf.address, ln.overduedate
     )
     LOOP
        SELECT length(TRIM(r.mobilesms)) INTO v_count FROM dual;
        IF v_count > 0 THEN
                 l_data_source := 'select ''' || to_date(r.overduedate,'DD/MM/RRRR') || ''' overduedate,  ''' || r.custodycd || ''' custodycd  from dual;';
         InsertEmailLog(r.mobilesms, '0327', l_data_source, r.acctno);
            END IF;
    END LOOP;
    ---0329: vi pham G<G duy tri
    FOR rc IN
        ( --vw_mr0002
          SELECT getcurrdate currdate,
                cf.custodycd,af.acctno,af.groupleader, cf.fullname, cf.mobilesms, cf.email,
                af.actype, aft.typename,aft.mnemonic,
                nvl(sec.marginrate,0) marginrate,
                af.mrirate, af.mrmrate, af.mrlrate,AF.MRCRATE,
                ROUND(ci.balance + avladvance) totalvnd, af.advanceline, --nvl(t0.advanceline,0) advanceline,
                sec.seass seass, af.mrcrlimit,
                af.mrcrlimitmax, ROUND(ci.dfodamt) dfodamt,af.mrcrlimitmax - ROUND(ci.dfodamt) mrcrlimitremain, af.status, ROUND(ci.dueamt) dueamount, ROUND(ci.ovamt) ovdamount,
                 af.callday,
                case when aft.mnemonic<>'T3' then
                    ltrim(to_char(ROUND(greatest(round((case when nvl(sec.marginrate,0) * af.MRCRATE =0 then - nvl(sec.outstanding,0) else greatest( 0,- nvl(sec.outstanding,0) - nvl(sec.navaccount,0) *100/af.MRCRATE) end),0),greatest(ROUND(ci.dueamt)+ROUND(ci.ovamt)/*+ROUND(ci.depofeeamt)*/ - ci.balance - avladvance,0))),'9,999,999,999'))
                else
                    ltrim(to_char(ROUND(greatest(ROUND(ci.dueamt)+ROUND(ci.ovamt)/*+ROUND(ci.depofeeamt)*/ - ci.balance - avladvance,0)),'9,999,999,999'))
                end moneypay
            from cfmast cf, afmast af, cimast ci, aftype aft,mrtype mrt,
                (select afacctno, marginrate,se_outstanding outstanding,se_navaccount navaccount,seass, seamt,avladvance from buf_ci_account ) sec
            where cf.custid = af.custid
            and cf.custatcom = 'Y'
            and af.actype = aft.actype and aft.mrtype = mrt.actype and mrt.mrtype ='T'
            and af.acctno = ci.acctno
            and af.acctno = sec.afacctno
            and aft.istrfbuy <> 'Y'
            and ((AFT.MNEMONIC <>'T3'
                        AND (
                                    (af.mrlrate <= sec.marginrate AND sec.marginrate < AF.MRMRATE )-- Rtt<Rcall
                                OR (AF.Mrlrate<=SEC.MARGINRATE AND SEC.MARGINRATE<AF.MRCRATE AND AF.Callday>0
                                        -- Rtt<Rt.call va call k ngay lien tiep
                                )
                            )
                        AND (AF.CALLDAY<AF.K1DAYS ))
                     -- or ((ci.dueamt-GREATEST(0,CI.BALANCE+NVL(AVLADVANCE,0)- CI.BUYSECAMT))>1)
                        )
            AND CI.OVAMT =0
            AND (AF.CALLDAY<AF.K1DAYS or AF.CALLDAY =0)
            AND af.mrlrate <= sec.marginrate
        )
    LOOP
         SELECT length(TRIM(rc.mobilesms)) INTO v_count FROM dual;
        IF v_count > 0 THEN
                 l_data_source := 'select ''' || rc.custodycd || ''' custodycd, ''' || rc.moneypay || ''' moneypay, ''' ||to_date(rc.currdate,'DD/MM/RRRR') || ''' currdate  from dual;';
         InsertEmailLog(rc.mobilesms, '327A', l_data_source, rc.acctno);
            END IF;
    END LOOP;

                --------------------------------------------------
  plog.setEndSection(pkgctx, 'GenTemplate0224');
  exception
    when others then
      plog.error(pkgctx, sqlerrm);
      plog.setEndSection(pkgctx, 'GenTemplate0224');
  end;

 procedure GenTemplate0332 is

   l_datasource varchar2(100);
  begin
    plog.setBeginSection(pkgctx, 'GenTemplate0332');
    for v_rec in (select e.email,p.autoid from EMGRPDTL E, EMGRP p,EMGRPCUST t
               where e.emgid = p.autoid and p.autoid = t.emgid
                     and p.status = 'A'
                     and p.timetemp <= to_char(sysdate,'hhmi')
                     and not EXISTS (select * from emaillog where templateid ='0332'  )
                  ) loop

          l_datasource :=     'select '''  || v_rec.autoid || ''' custodycode  from dual ';
            --plog.error(pkgctx, 'EMAIL DATA: ' || l_datasource);

           insert into emaillog
          (autoid,
           email,
           templateid,
           datasource,
           status,
           createtime,
           afacctno)
        values
          (seq_emaillog.nextval,
           v_rec.email,
           '0332',
           l_datasource,
           'A',
           sysdate,
           null);

     end loop;






    plog.setEndSection(pkgctx, 'GenTemplate0332');
  exception
    when others then
      plog.error(pkgctx, sqlerrm);
      plog.setEndSection(pkgctx, 'GenTemplate0332');
  end;
--
procedure GenTemplate0331(i_date date) is

   l_datasource varchar2(500);
  begin
    plog.setBeginSection(pkgctx, 'GenTemplate0331');
    for v_rec in (select ca.reportdate,-- ng?chot ds
       ca.nodate,-- ngay thong bao khac
       ca.actiondate,-- ngay thanh toan
       ca.NDUEDATE,--ngay xd lai suat
       ca.NRATENEXTDATE,-- ngay dang ky cuoi cung
       s.mobile
  from camast ca, SMSOTCTP s
 where ca.catype = '027' and s.status = 'A'
   and ca.camastid = s.camastid
   and to_date(s.ngaythongbao,'dd/MM/rrrr') = to_date(i_date,'dd/MM/rrrr')

                  ) loop

            l_datasource :=     'select '''  || to_char(v_rec.nodate,'dd/MM/yyyy') || ''' pv_nodate,
           ''' || to_char(v_rec.reportdate,'dd/MM/yyyy') || ''' pv_reortdate,
           ''' || to_char(v_rec.actiondate,'dd/MM/yyyy') || ''' pv_actiondate,
           ''' || to_char(v_rec.nratenextdate,'dd/MM/yyyy') || ''' pv_nratenextdate,
           ''' || to_char(v_rec.NDUEDATE,'dd/MM/yyyy') || ''' pv_nduedate  from dual ';


           insert into emaillog
          (autoid,
           email,
           templateid,
           datasource,
           status,
           createtime,
           afacctno)
        values
          (seq_emaillog.nextval,
           v_rec.mobile,
           '0331',
           l_datasource,
           'A',
           sysdate,
           null);

     end loop;

    plog.setEndSection(pkgctx, 'GenTemplate0331');
  exception
    when others then
      plog.error(pkgctx, sqlerrm);
      plog.setEndSection(pkgctx, 'GenTemplate0331');
end;

    PROCEDURE smsbatchwarnming (p_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR,detail VARCHAR2) IS
        v_count NUMBER;
        v_string VARCHAR2(1000);

                 l_data_source varchar2(2000);
         l_mobile varchar2(20);
         l_hour varchar2(10);


        v_isholiday VARCHAR2(1);

        v_hostatus char(1);
        v_currdate varchar2(100);
        v_prevdate varchar2(100);
        v_message varchar2(1000);
        v_countAllBatch number;
        v_countBFBatch number;
        v_BFCount number;
        v_bchsqn_endBFBatch varchar2(10);
        v_brstatsus VARCHAR2(1);
  BEGIN
        IF detail = 'Success' THEN
                      v_hostatus:= CSPKS_SYSTEM.fn_get_sysvar('SYSTEM','HOSTATUS');
                v_currdate:= CSPKS_SYSTEM.fn_get_sysvar('SYSTEM','CURRDATE');
                v_prevdate:= CSPKS_SYSTEM.fn_get_sysvar('SYSTEM','PREVDATE');
                select count(1) into v_count from sbbatchsts where bchdate = to_date(v_currdate,'DD/MM/RRRR') and trim(bchsts) = 'Y';

                if v_count=0 and v_hostatus='1' then
                        --He thong dang hoat dong binh thuong ngay v_currdate
                        v_message:='He thong dang hoat dong, ngay he thong ' || v_currdate || '!';

                end if;

                select bchsqn into v_bchsqn_endBFBatch from sbbatchctl where bchmdl='SAAFINDAYPROCESS';
                select count(1) into v_countAllBatch from  sbbatchctl where status ='Y';
                select count(1) into v_countBFBatch from  sbbatchctl where status ='Y' and bchsqn <=v_bchsqn_endBFBatch;

                if v_count=0 and v_hostatus='0' then
                        select count(1) into v_count from sbbatchsts where bchdate = to_date(v_prevdate,'DD/MM/RRRR') and trim(bchsts) = 'Y';
                        --he thong dang chay batch buoc v_count/v_countAllBatch va da chuyen ngay moi
                        v_message:='He thong dang chay batch tai buoc ' || to_char(v_count) || '/' || to_char(v_countAllBatch) || ' va da chuyen sang ngay moi. ' || v_currdate || '!';

                end if;
                select count(1) into v_BFCount from sbbatchsts where
                             bchdate = to_date(v_currdate,'DD/MM/RRRR')
                             and bchmdl='SAAFINDAYPROCESS' and trim(bchsts)='Y';
                if v_count>0 then
                        if v_count<v_countBFBatch and v_BFCount = 0 then
                                --He thong dang chay buoc xu ly truoc cuoi ngay tai buoc v_count/v_countBFBatch
                                v_message:='He thong dang xy ly truoc cuoi ngay tai buoc ' || to_char(v_count) || '/' || to_char(v_countBFBatch) || ' .';

                        end if;
                        if v_BFCount>0 and v_hostatus='1' then
                             --He thong dang hoat dong sau buoc xu ly truoc cuoi ngay
                                v_message:='He thong dang hoat dong va da chay buoc xu ly truoc cuoi ngay, ngay he thong ' || v_currdate  || '!';

                        end if;
                        if v_BFCount>0 and v_hostatus='0' then
                                --He thong danh chay batch cuoi ngay tai buoc
                                v_message:='He thong dang xu ly cuoi ngay tai buoc ' || to_char(v_count) || '/' || to_char(v_countAllBatch) || '.';

                        end if;
                end if;
                            SELECT status INTO v_brstatsus FROM brgrp WHERE brid = '0001';
                            IF v_brstatsus = 'A' THEN
                                     v_message:= v_message || ' Da khoi tao BR001.';
                            ELSE
                                     v_message:= v_message || ' BR001 chua khoi tao.';
                            END IF;

                                FOR rec IN
                                                (
                                                                SELECT * FROM
                                                                                                                 (select trim(regexp_substr(VARVALUE,'[^,]+', 1, level)) phone
                                                                                                                 from (SELECT varvalue FROM sysvar WHERE varname = 'BATCHREMINDER' )
                                                                                                                 connect by regexp_substr(VARVALUE, '[^,]+', 1, level) is not NULL) a
                                                )
                                LOOP
                                                 v_string:= 'select '''|| v_message || ''' detail from dual';
                                                 InsertEmailLog(rec.phone , '0305', v_string,'');
                                END LOOP;


        ELSE
             v_string:= 'select '''|| detail || ''' detail from dual';
        FOR rec IN
                (
                        SELECT * FROM
                                                 (select trim(regexp_substr(VARVALUE,'[^,]+', 1, level)) phone
                                                 from (SELECT varvalue FROM sysvar WHERE varname = 'BATCHREMINDER' )
                                                 connect by regexp_substr(VARVALUE, '[^,]+', 1, level) is not NULL) a
                )
        LOOP

                 InsertEmailLog(rec.phone , '0305', v_string,'');
        END LOOP;
    END IF;
        OPEN p_REFCURSOR FOR SELECT 1 FROM DUAL;

    exception
    when others then
      plog.error(pkgctx, sqlerrm);
      plog.setEndSection(pkgctx, 'smsbatchwarnming');
    END;

  procedure GenTemplateTransaction(p_transaction_number varchar2) is

    type transaction_cursor is ref cursor;

    type transaction_record is record(
      apptype apptx.apptype%type,
      TXTYPE  apptx.txtype%type,
      namt    citran.namt%type,
      acctno  citran.acctno%type,
      trdesc  citran.trdesc%type,
      balance cimast.balance%type);

    c_transaction   transaction_cursor;
    transaction_row transaction_record;

    type ty_transaction is table of transaction_record index by binary_integer;

    transaction_list         ty_transaction;
    l_transaction_cache_size number(23) := 1000;
    l_row                    pls_integer;

    l_message_type     tltx.msgtype%type;
    l_message_content  allcode.cdcontent%type;
    l_message_account  tllog.msgacct%type;
    l_message_amount   tllog.msgamt%type;
    l_transaction_date tllog.txdate%type;
    l_custody_code     cfmast.custodycd%type;
    l_txtype           apptx.txtype%type;
    l_amount           number(20);
    l_account          varchar2(20);
    l_transaction_desc appmap.trdesc%type;
    l_balance          cimast.balance%type;
    --l_trade            semast.trade%type;
    l_sms_number cfmast.mobilesms%type;
    l_symbol     sbsecurities.symbol%type;

    l_app_type          char(2);
    l_template_id       char(4);
    l_message_ci_credit char(4) := '324A';
    l_message_ci_dedit  char(4) := '324B';
    l_message_se_credit char(4) := '325E';
    l_message_se_dedit  char(4) := '325F';
    l_datasource        varchar2(1000);
    l_ccyusage varchar2(20);
    l_tltxcd varchar2(20);

        l_deltd CHAR(1);

  begin
    plog.setBeginSection(pkgctx, 'GenTemplateTransaction');

plog.error('GenTemplateTransaction PROCESS: [TXNUM: ' || p_transaction_number || '], '
         ||'[TXDATE: '||l_transaction_date||'] ');

  --VuTN 22/12/2016
           select t.msgtype,
           nmpks_ems.fn_convert_to_vn(NVL(b.cdcontent,l.txdesc)) cdcontent,
           l.msgamt,
           l.msgacct,
           l.txdate ,l.deltd, l.ccyusage,l.tltxcd
           into l_message_type,
           l_message_content,
           l_message_amount,
           l_message_account, --l_custody_code,
           l_transaction_date, --, l_sms_number
           l_deltd, l_ccyusage,l_tltxcd
      from tllog l, tltx t,
      (select * from allcode a where a.cdtype = 'NM' and a.cdname = 'MSGTYPE') b
     where t.tltxcd = l.tltxcd
       and t.msgtype = b.cdval(+)
       and l.txnum = p_transaction_number ;--and l.txdate= to_date(l_transaction_date,systemnums.C_DATE_FORMAT);

     plog.error('GenTemplateTransaction PROCESS: [TXNUM: ' || p_transaction_number || '], '
                ||'[TXDATE: '||l_transaction_date||'] ');
    --END VuTN
    plog.info(pkgctx,
              'TYPE: [' || l_message_type || '] CONTENT: [' ||
              l_message_content || '] AMOUNT: [' || l_message_amount ||
              '] ACCOUNT: [' || l_message_account || '] TRANS. DATE [' ||
              to_char(l_transaction_date, 'DD/MM/RRRR') || ']');

    open c_transaction for
      select a.apptype,
             a.txtype,
             sum(t.namt) namt,
             t.acctno,
            nmpks_ems.fn_convert_to_vn( max(CASE WHEN t.deltd = 'Y' THEN  'Huy gd ' || t.trdesc ELSE t.trdesc END)) trdesc,
             max(m.trade + m.blocked) balance
        from setran t, semast m, apptx a
       where t.txcd = a.txcd
         and a.apptype = 'SE'
         and a.field IN ('TRADE','BLOCKED')
         and a.txtype in ('C', 'D')
         and t.namt > 0
         and t.acctno = m.acctno
         and t.txdate = l_transaction_date
         and t.txnum = p_transaction_number
                 GROUP BY a.apptype, a.txtype, t.acctno--, CASE WHEN t.deltd = 'Y' THEN  'Huy gd ' || t.trdesc ELSE t.trdesc END

      union all
      select a.apptype, a.txtype, t.namt, t.acctno,
                   nmpks_ems.fn_convert_to_vn(CASE WHEN t.deltd = 'Y' THEN 'Huy gd' || t.trdesc ELSE t.trdesc END) trdesc,
                   --m.balance Ngay 30/11/2018 NamTv chinh sua lay so tien duoc rut
                   getbaldefovd(t.acctno) balance
        from citran t, cimast m, apptx a
       where t.txcd = a.txcd
         and a.apptype = 'CI'
         and a.field = 'BALANCE'
         and a.txtype in ('C', 'D')
         and t.namt > 0
         and t.acctno = m.acctno
         and t.txdate = l_transaction_date
         and t.txnum = p_transaction_number;

    loop
      fetch c_transaction bulk collect
        into transaction_list limit l_transaction_cache_size;

      plog.DEBUG(pkgctx, 'CNT: ' || transaction_list.COUNT);

      exit when transaction_list.COUNT = 0;
      l_row := transaction_list.FIRST;

      while (l_row is not null)

       loop

        transaction_row    := transaction_list(l_row);
        l_app_type         := transaction_row.apptype;
        l_txtype           := transaction_row.TXTYPE;
        l_amount           := transaction_row.namt;
        l_account          := substr(transaction_row.acctno, 1, 10);
        l_transaction_desc := transaction_row.trdesc;
        l_balance          := transaction_row.balance;

        plog.info(pkgctx,
                  'TXTYPE: [' || l_txtype || '] AMT: [' || l_amount ||
                  '] ACCT: [' || l_account || '] TRANS. DESC. [' ||
                  l_transaction_desc || '] BAL. [' || l_balance || ']');

        select c.custodycd, c.mobilesms
          into l_custody_code, l_sms_number
          from afmast a, vw_cfmast_sms c
         where a.custid = c.custid
           and a.acctno = l_account;

        plog.info(pkgctx,
                  'CUSTODY CODE: [' || l_custody_code || '] SMS NO: [' ||
                  l_sms_number || ']');
-- case rieng cho bao minh
        if l_tltxcd ='3342' then
           select l_message_content||' '||symbol
           into l_message_content
           from sbsecurities
           where codeid = l_ccyusage;
        elsif l_transaction_desc <> '' or l_transaction_desc is not null then
          l_message_content := l_transaction_desc;
        end if;

        if l_app_type = 'CI' then
          if l_txtype = 'C'  THEN
                        IF l_Deltd = 'N' THEN
            l_template_id := l_message_ci_credit;
                        ELSE
                             l_template_id := l_message_ci_dedit;
                        END IF;
          ELSE
                      IF l_deltd = 'N' THEN
            l_template_id := l_message_ci_dedit;
                        ELSE
                            l_template_id := l_message_ci_credit;
                            END IF;
          end if;

          l_datasource := 'select ''' || l_custody_code || ''' custodycode, ''' ||
                           l_account ||  ''' acctno, ''' ||
                           to_char(l_transaction_date, 'DD/MM/RRRR') ||
                          ''' txdate, ''' || l_message_content ||
                          ''' txdesc, ''' ||
                          ltrim(replace(to_char(l_amount,
                                                '9,999,999,999,999'),
                                        ',',
                                        '.')) || ''' amount, ''' ||
                          ltrim(replace(to_char(l_balance,
                                                '9,999,999,999,999'),
                                        ',',
                                        '.')) || ''' balance from dual';

        elsif l_app_type = 'SE' then
          if l_txtype = 'C'  THEN
                        IF l_Deltd = 'N' THEN
            l_template_id := l_message_se_credit;
                        ELSE
                             l_template_id := l_message_se_dedit;
                        END IF;
          ELSE
                      IF l_deltd = 'N' THEN
            l_template_id := l_message_se_dedit;
                        ELSE
                            l_template_id := l_message_se_credit;
                            END IF;
          end if;

          select b.symbol
            into l_symbol
            from semast a, sbsecurities b
           where a.codeid = b.codeid
             and a.acctno = transaction_row.acctno;

          l_datasource := 'select ''' || l_custody_code || ''' custodycode, ''' ||
                           l_account || ''' acctno, ''' ||
                           to_char(l_transaction_date, 'DD/MM/RRRR') ||
                          ''' txdate, ''' || l_message_content ||
                          ''' txdesc, ''' ||
                          ltrim(replace(to_char(l_amount,
                                                '9,999,999,999,999'),
                                        ',',
                                        '.')) || ''' amount, ''' ||
                          ltrim(replace(to_char(l_balance,
                                                '9,999,999,999,999'),
                                        ',',
                                        '.')) || ''' trade, ''' || l_symbol ||
                          ''' symbol from dual';
        end if;

        if (l_template_id <> '' or l_template_id is not null) and length(trim(l_sms_number)) > 0 then

          InsertEmailLog(l_sms_number,
                         l_template_id,
                         l_datasource,
                         l_account);
        end if;

        l_row := transaction_list.NEXT(l_row);
      end loop;
    end loop;

    plog.setEndSection(pkgctx, 'GenTemplateTransaction');
  exception
    when others then
      plog.error(pkgctx, sqlerrm);
      plog.setEndSection(pkgctx, 'GenTemplateTransaction');
  end;

  procedure GenTemplateScheduler(p_template_id varchar2) is
    --l_next_run_date date;
    l_data_source   varchar2(4000);
    l_template_id   templates.code%type;
    l_afacctno      afmast.acctno%type;
    l_address       varchar2(100);
    l_fullname      cfmast.fullname%type;
    l_custody_code  cfmast.custodycd%type;
        l_require  VARCHAR2(1);

    type scheduler_cursor is ref cursor;

    type scheduler_record is record(
      template_id templates.code%type,
      afacctno    afmast.acctno%type,
      address     varchar2(100));

    c_scheduler   scheduler_cursor;
    scheduler_row scheduler_record;

    type ty_scheduler is table of scheduler_record index by binary_integer;

    scheduler_list         ty_scheduler;
    l_scheduler_cache_size number(23) := 1000;
    l_row                  pls_integer;
  begin
    plog.setBeginSection(pkgctx, 'GenTemplateScheduler');
        --sms, mail phai dang ky moi gui theo scheduler

                    open c_scheduler FOR
                        select t.code,
                                     mst.acctno afacctno,
                                     decode(t.type, 'E', cf.email, 'S', cf.mobilesms) address
                            from templates t, aftemplates a, afmast mst, vw_cfmast_sms cf
                         where a.template_code = t.code
                             and a.custid = cf.custid and cf.custid = mst.custid
                             and decode(t.type, 'E', cf.email, 'S', cf.mobilesms) is not null
                             and t.code = p_template_id;

                    loop
                        fetch c_scheduler bulk collect
                            into scheduler_list limit l_scheduler_cache_size;

                        plog.DEBUG(pkgctx, 'CNT: ' || scheduler_list.COUNT);

                        exit when scheduler_list.COUNT = 0;
                        l_row := scheduler_list.FIRST;

                        while (l_row is not null)

                         loop
                            scheduler_row := scheduler_list(l_row);
                            l_template_id := scheduler_row.template_id;
                            l_afacctno    := scheduler_row.afacctno;
                            l_address     := scheduler_row.address;

                            begin
                                select a.custodycd, a.fullname
                                    into l_custody_code, l_fullname
                                    from vw_cfmast_sms a, afmast b
                                 where a.custid = b.custid
                                     and b.acctno = l_afacctno;
                            exception
                                when NO_DATA_FOUND then
                                    plog.error(pkgctx,
                                                         'Sub account ' || l_afacctno || ' not found');
                                    l_custody_code := 'No Data Found';
                                    l_fullname     := 'No Data Found';
                            end;

                            if p_template_id = '0214' then
                                l_data_source := 'select ''' || l_custody_code ||
                                                                 ''' custodycode, ''' || l_fullname ||
                                                                 ''' fullname, ''' || l_afacctno ||
                                                                 ''' account, ''' ||
                                                                 to_char(to_date(fn_get_sysvar_for_report(p_sys_grp  => 'SYSTEM',
                                                                                                                                                    p_sys_name => 'PREVDATE'),
                                                                                                 'DD/MM/RRRR'),
                                                                                 'MM/RRRR') || ''' monthly from dual;';
                           /* elsif p_template_id = '0215' then
                                l_data_source := 'select ''' || l_custody_code ||
                                                                 ''' custodycode, ''' || l_fullname ||
                                                                 ''' fullname, ''' || l_afacctno ||
                                                                 ''' account, ''' ||
                                                                 fn_get_sysvar_for_report('SYSTEM', 'PREVDATE') ||
                                                                 ''' daily from dual;';
*/


                          /*  else

                                l_data_source := 'select ''' || l_custody_code ||
                                                                 ''' custodycode, ''' || l_fullname ||
                                                                 ''' fullname, ''' || l_afacctno ||
                                                                 ''' account from dual;';*/

                            end if;
                            if /*instr(l_address,'@') = 0 or*/ CheckEmail(l_address) then
                                    InsertEmailLog(l_address, l_template_id, l_data_source, l_afacctno);
                            end if;

                            l_row := scheduler_list.NEXT(l_row);
                        end loop;
                    end loop;



    insert into templates_scheduler_log
      (template_id, log_date)
    values
      (p_template_id, getcurrdate);

    update templates_scheduler
       set last_start_date = getcurrdate,
           next_run_date   = fn_GetNextRunDate(next_run_date, repeat_interval)
     where template_id = p_template_id;

    plog.setEndSection(pkgctx, 'GenTemplateScheduler');
  exception
    when others then
      plog.error(pkgctx, sqlerrm);
      plog.setEndSection(pkgctx, 'GenTemplateScheduler');
  end;

  procedure CheckEarlyDay is
    l_data_source  varchar2(2000);
    p_count varchar2(5);
    p_hour varchar2(5);
    p_hoursend varchar2(10);
    begin
    plog.setBeginSection(pkgctx, 'CheckEarlyDay');

    select TO_CHAR(SYSDATE,'hh.AM') into p_hour from dual;
    begin
    select hours into p_hoursend from smsServiceTemplates where codeid='1';
    exception
    when others then
       p_hoursend:= '';
    end ;
    --if  p_hour = '08.AM' then
    if  p_hour = p_hoursend then
            begin
                 SELECT COUNT(acctno) into p_count  from sedeposit
                 where (SELECT TO_DATE(VARVALUE,'DD/MM/YYYY') CURRDATE
                 FROM SYSVAR WHERE GRNAME = 'SYSTEM' AND VARNAME ='CURRDATE') - TXDATE >= 3
                 and STATUS not in ('C');
                 exception
            when others then
                 p_count:=0;
            end ;

       for rec in (
        --select EmailSms,templateid from fixtemp where status ='LK'
        select st.templates, su.mobilesms
        from smsServiceUser su, smsServiceTemplates st
        where st.codeid = su.codeid
        and st.codeid = '1'
        )
        loop
        l_data_source := 'select ''' || p_count ||
                           ''' count from dual;';

        InsertEmailLog(rec.mobilesms, rec.templates , l_data_source, '');

        /*insert into emaillog
          (autoid, email, templateid, datasource, status, createtime, note)
         values
          (seq_emaillog.nextval,
           v_mobile,
           '0340',
           l_data_source,
           'A',
           sysdate,
           '---');*/

        end loop;

    end if;
    plog.setEndSection(pkgctx, 'CheckEarlyDay');
  exception
    when others then
      plog.error(pkgctx, sqlerrm);
      plog.setEndSection(pkgctx, 'CheckEarlyDay');
  end;

  procedure CheckSystem is
    l_data_source  varchar2(2000);
    p_hour varchar2(100);
    p_sysdate varchar2(100);
    p_daydate varchar2(100);
    p_status varchar2(100);
    p_hoursend varchar2(10);

    begin
    plog.setBeginSection(pkgctx, 'CheckSystem');

    select TO_CHAR(SYSDATE,'hh.AM') into p_hour from dual;
    select TO_CHAR(SYSDATE,'DD/MM/YYYY') into p_daydate from dual;
    SELECT VARVALUE into p_sysdate FROM SYSVAR WHERE GRNAME = 'SYSTEM' AND VARNAME ='CURRDATE';
    begin
    SELECT STATUS into p_status FROM brgrp where brid='0001';
    exception
    when others then
       p_status:= '';
    end ;
    if p_status = 'A' then
        p_status := 'MO';
    else
        p_status := 'DONG';
    end if;
    begin
    select hours into p_hoursend from smsServiceTemplates where codeid='2';
    exception
    when others then
       p_hoursend:= '';
    end ;
    --if p_hour = '10.PM' then
    if p_hour = p_hoursend then
      for rec in (
          --select EmailSms,templateid from fixtemp where status ='IT'
          select st.templates, su.mobilesms
          from smsServiceUser su, smsServiceTemplates st
          where st.codeid = su.codeid
          and st.codeid = '2'
          )
          loop
          l_data_source := 'select ''' || p_daydate ||
           ''' presentdate,''' || p_sysdate ||
           ''' systemdate,''' || p_status ||
           ''' status from dual;';

          InsertEmailLog(rec.mobilesms, rec.templates , l_data_source, '');

          end loop;
    end if;

    exception
    when others then
      plog.error(pkgctx, sqlerrm);
      plog.setEndSection(pkgctx, 'CheckSystem');
  end;

  procedure CheckSoDuGD is
    l_data_source  varchar2(2000);
    p_date varchar2(100);
    p_HST3 varchar2(100);
    p_HSMR varchar2(100);
    p_CNT3 varchar2(100);
    p_CNMR varchar2(100);
    p_TongT3 varchar2(100);
    p_TongMR varchar2(100);
    p_hour varchar2(100);
    p_hoursend varchar2(100);
    begin
    plog.setBeginSection(pkgctx, 'CheckSoDuGD');

    SELECT TO_DATE(VARVALUE,'dd/MM/YYYY') into p_date FROM SYSVAR WHERE GRNAME = 'SYSTEM' AND VARNAME ='PREVDATE';
    begin
   /* select  sum(dtl.t3_hs), sum(dtl.t3_cn), sum(dtl.m_hs), sum(dtl.m_cn) into p_HST3, p_CNT3, p_HSMR, p_CNMR from
    (
    SELECT  CASE WHEN  aft.istrfbuy = 'Y' AND aft.trfbuyext > 0  AND cf.brid ='0001' THEN (i.matchqtty*matchprice) ELSE 0 END  t3_hs,
             CASE WHEN  aft.istrfbuy = 'Y' AND aft.trfbuyext > 0 AND cf.brid <>'0001' THEN (i.matchqtty*matchprice) ELSE 0 END  t3_cn,
             CASE WHEN  aft.istrfbuy = 'N' AND mr.mrtype='T'   AND cf.brid ='0001' THEN (i.matchqtty*matchprice) ELSE 0 END  m_hs,
             CASE WHEN  aft.istrfbuy = 'N' AND mr.mrtype='T'   AND cf.brid <>'0001' THEN (i.matchqtty*matchprice) ELSE 0 END  m_cn
    from iodhist i , cfmast cf , odmast od, afmast af, aftype aft, mrtype mr
    where cf.custodycd = i.custodycd
    and i.orgorderid = od.orderid
    and od.afacctno = af.acctno
    and af.actype = aft.actype
    and aft.mrtype = mr.actype
    and i.txdate = p_date
    ) dtl;*/

         SELECT SUM ( CASE WHEN SUBSTR(AFACCTNO,1,4)='0001' AND AFTYPE.mnemonic ='T3' THEN  (PRINNML+PRINDUE+PRINOVD) ELSE 0 END ),
        SUM ( CASE WHEN SUBSTR(AFACCTNO,1,4)='0101' AND AFTYPE.mnemonic ='T3' THEN  (PRINNML+PRINDUE+PRINOVD) ELSE 0 END ),
        SUM ( CASE WHEN SUBSTR(AFACCTNO,1,4)='0001' AND AFTYPE.mnemonic ='Margin' THEN  (PRINNML+PRINDUE+PRINOVD) ELSE 0 END ),
        SUM ( CASE WHEN SUBSTR(AFACCTNO,1,4)='0101' AND AFTYPE.mnemonic ='Margin' THEN  (PRINNML+PRINDUE+PRINOVD) ELSE 0 END )
         into p_HST3, p_CNT3, p_HSMR, p_CNMR
        FROM VW_LN0001 LN, AFMAST AF, AFTYPE
        WHERE LN.AFACCTNO = AF.ACCTNO
        AND AF.ACTYPE = AFTYPE.ACTYPE;
    exception
    when others then
       p_HST3:= ''; p_CNT3:= ''; p_HSMR:= ''; p_CNMR:= '';
    end ;

    p_TongT3 := p_HST3 + p_CNT3;
    p_TongMR := p_HSMR + p_CNMR;

    select TO_CHAR(SYSDATE,'hh.AM') into p_hour from dual;
    begin
    select hours into p_hoursend from smsServiceTemplates where codeid='3';
    exception
    when others then
       p_hoursend:= '';
    end ;
    --if p_hour = '08.AM' then
    if p_hour = p_hoursend then
      for rec in (
          --select EmailSms,templateid from fixtemp where status ='GD'
          select st.templates, su.mobilesms
          from smsServiceUser su, smsServiceTemplates st
          where st.codeid = su.codeid
          and st.codeid = '3'
          and TO_CHAR( getcurrdate(),'DD/MM/YYYY')= to_CHAR (sysdate,'DD/MM/YYYY')
          )
          loop
          l_data_source := 'select ''' ||
            ltrim(to_char(p_TongMR, '9,999,999,999,999,999'))  ||
           ''' tongmr,''' ||
            ltrim(to_char(p_TongT3, '9,999,999,999,999,999'))||
           ''' tongt3,''' ||
            ltrim(to_char(p_HST3, '9,999,999,999,999,999')) ||
           ''' hst3,''' ||
            ltrim(to_char(p_CNT3, '9,999,999,999,999,999')) ||
           ''' cnt3,''' ||
            ltrim(to_char(p_HSMR, '9,999,999,999,999,999')) ||
           ''' hsmr,''' ||
            ltrim(to_char(p_CNMR, '9,999,999,999,999,999')) ||
           ''' cnmr from dual;';

          InsertEmailLog(rec.mobilesms, rec.templates , l_data_source, '');

          end loop;
    end if;

    exception
    when others then
      plog.error(pkgctx, sqlerrm);
      plog.setEndSection(pkgctx, 'CheckSoDuGD');
  end;
  ------------VU THEM
  procedure CheckKhopLenh is
    l_data_source varchar2(2000);
    l_mobile varchar2(20);
  begin
    for rec in (
       select max(autoid) autoid, custodycd, orderid, txdate, header,ltrim(MAX(ORDERQTTY)) as slck,mck,
   (MAX(ORDERQTTY) - max(TOTALQTTY)) as KLCL ,
    'gia ' || price as detaildl,
    listagg(detail, ', ') within group(order by detail)  as detail
        from (select a.*, rownum top
             from (select max(autoid) autoid, txdate,
             custodycd, orderid, lower(substr(header,1,3)) header, ltrim(substr(header,4)) mck,max(TOTALQTTY) TOTALQTTY,ORDERQTTY,price,
             sum(matchqtty) || ' gia ' || matchprice as detail
             from smsmatched
             where status = 'N'
             group by txdate, custodycd, orderid,
             header, matchprice ,ORDERQTTY,price
             order by autoid) a)
        group by custodycd, orderid, txdate, header ,price, MCK
        order by autoid
      )
   loop
     if rec.KLCL = 0 then
        select mobilesms into l_mobile
        from vw_cfmast_sms where custodycd=rec.custodycd;

        l_data_source := 'select ''' ||
           rec.custodycd ||''' custodycd,''' ||
           to_char(rec.txdate,'DD/MM/YYYY') ||''' txdate,''' ||
           rec.header || ''' header,''' ||
           rec.SLCK || ''' slck,''' ||
           rec.mck || ''' mck,''' ||
           rec.detaildl || ''' detaildl,''' ||
           rec.detail || ''' detail from dual;';
        InsertEmailLog(l_mobile, '0337', l_data_source, '');


        update smsmatched
        set status = 'S'
        where orderid = rec.orderid
        and status = 'N';

     end if;
   end loop;
  exception
    when others then
      plog.error(pkgctx, sqlerrm);
      plog.setEndSection(pkgctx, 'CheckKhopLenh');
  end;
  ------------------------------------------
  procedure CheckKLCuoiNgay is
    l_data_source varchar2(2000);
    l_mobile varchar2(20);
    l_hour varchar2(10);
    v_count number;
    v_string varchar2(1000);
        v_isholiday VARCHAR2(1);

        v_hostatus char(1);
    v_currdate varchar2(100);
    v_prevdate varchar2(100);
   v_message varchar2(1000);
   v_countAllBatch number;
   v_countBFBatch number;
   v_BFCount number;
   v_bchsqn_endBFBatch varchar2(10);
     v_brstatsus VARCHAR2(1);
  begin
  --message khop lenh cuoi ngay
    SELECT MAX(holiday) INTO v_isholiday FROM sbcldr WHERE sbdate = to_date(SYSDATE,'DD/MM/RRRR');
    IF v_isholiday = 'N' THEN  --chi gui neu khong phai ngay nghi
    /*IF TO_CHAR(SYSDATE,'hh.AM') = '04.PM' AND v_isholiday = 'N' THEN
    for rec in (

       select custodycd, listagg(detail, ', ') within group(order by detail) || '. Tong ' || Bors ||': '  || sum(matchqtty)  as detail ,txdate
       from (
                select max(autoid) autoid, custodycd,  txdate, substr(header,1,3) BORS, matchqtty,
                header  || listagg(detail, ', ') within group(order by detail) as detail
                from (select a.*, rownum top
                        from (select max(autoid) autoid, txdate, custodycd, header,
                                 'TONG KL ' || sum(matchqtty) || ' GIA BQ ' || round(sum(matchqtty*matchprice)/sum(matchqtty),0)
                                  as detail,  sum(matchqtty) matchqtty
                                from smsmatched
                                where txdate = getcurrdate---status = 'N'
                                group by txdate, custodycd, orderid, header
                                order by autoid
                            ) a
                     )
                group by custodycd, txdate, header , matchqtty
                order by autoid
            )
            group by custodycd, txdate, BORS
      )

   loop
      begin
            select mobilesms into l_mobile
            from vw_cfmast_sms where custodycd=rec.custodycd;
      exception
      when others then
            l_mobile:= '';
      end ;

           l_data_source := 'select ''' ||
           rec.custodycd ||''' custodycode,''' ||
           to_char(rec.txdate,'DD/MM/YYYY') ||''' txdate,''' ||
           rec.detail || ''' detail from dual;';

           IF length(TRIM(l_mobile)) > 0 THEN
              InsertEmailLog(l_mobile, '0338', l_data_source, '');
           END IF;

            \*update smsmatched
            set status = 'S'
            where  status = 'N'
            and custodycd=rec.custodycd;*\


   end loop;
   END IF;*/
     --message nhac quan tri rui ro het room
   for rec in
    (
                select prcode, warningamt, pravllimit, cdval,CF.CUSTODYCD CUSTODYCD
        from
        (
            SELECT MST.PRCODE, MST.warningamt,
            GREATEST(MST.PRLIMIT - NVL(MST.PRINUSED,0) - NVL(prlog.prinused,0)
                                 - (case when mst.pooltype='SY' then nvl(afpool.afpoolused,0) else 0 end)
                     ,0) PRAVLLIMIT, a.cdval,prlog.afacctno

            FROM PRMASTER MST,
            (select regexp_substr(VARVALUE,'[^,.;]+', 1, level) cdval
                from (SELECT varvalue FROM sysvar WHERE varname = 'PRREMINDER' )
                connect by regexp_substr(VARVALUE, '[^,.;]+', 1, level) is not NULL) a,
            (select prcode,afacctno, sum(prinused) prinused from prinusedlog where deltd <> 'Y' group by prcode,afacctno) prlog,
            (SELECT SUM(prlimit) afpoolused  from prmaster WHERE pooltype IN ('AF','GR') AND prstatus='A' ) afpool
            WHERE  mst.prcode = prlog.prcode(+)
            and mst.pooltype = 'SY'
        )PR,
        AFMAST AF, CFMAST CF
        where pravllimit <= warningamt
        and AF.ACCTNO = PR.afacctno
        and AF.CUSTID = CF.CUSTID

    )
    LOOP

        select to_number(TO_CHAR(SYSDATE,'hh24')) into l_hour from dual;
        IF l_hour <= 17 AND l_hour >= 9 THEN
                  v_string:= 'select '''|| rec.CUSTODYCD || '''sotk, ''' || ltrim(to_char( rec.pravllimit, '9,999,999,999,999')) || ''' pravllimit, '''
                                ||ltrim(to_char( rec.warningamt, '9,999,999,999,999'))  || ''' warningamt '
                      || 'from dual';
                      InsertEmailLog(rec.cdval , '0307', v_string,'');
         END IF;

    end loop;

 -- sms,email khong can dang ky van gui theo scheduler
    --sms check trang thai he thong chay batch luc 21h:  0305
    BEGIN
            SELECT COUNT(1) INTO v_count FROM emaillog WHERE templateid = '0305';
             v_hostatus:= CSPKS_SYSTEM.fn_get_sysvar('SYSTEM','HOSTATUS');
   IF    TO_CHAR(SYSDATE,'hh.AM') = '09.PM' AND (v_hostatus = '0' OR v_count = 0) THEN
                --v_hostatus:= CSPKS_SYSTEM.fn_get_sysvar('SYSTEM','HOSTATUS');
                v_currdate:= CSPKS_SYSTEM.fn_get_sysvar('SYSTEM','CURRDATE');
                v_prevdate:= CSPKS_SYSTEM.fn_get_sysvar('SYSTEM','PREVDATE');
                select count(1) into v_count from sbbatchsts where bchdate = to_date(v_currdate,'DD/MM/RRRR') and trim(bchsts) = 'Y';

                if v_count=0 and v_hostatus='1' then
                        --He thong dang hoat dong binh thuong ngay v_currdate
                        v_message:='He thong dang hoat dong, ngay he thong ' || v_currdate || '!';

                end if;

                select bchsqn into v_bchsqn_endBFBatch from sbbatchctl where bchmdl='SAAFINDAYPROCESS';
                select count(1) into v_countAllBatch from  sbbatchctl where status ='Y';
                select count(1) into v_countBFBatch from  sbbatchctl where status ='Y' and bchsqn <=v_bchsqn_endBFBatch;

                if v_count=0 and v_hostatus='0' then
                        select count(1) into v_count from sbbatchsts where bchdate = to_date(v_prevdate,'DD/MM/RRRR') and trim(bchsts) = 'Y';
                        --he thong dang chay batch buoc v_count/v_countAllBatch va da chuyen ngay moi
                        v_message:='He thong dang chay batch tai buoc ' || to_char(v_count) || '/' || to_char(v_countAllBatch) || ' va da chuyen sang ngay moi. ' || v_currdate || '!';

                end if;
                select count(1) into v_BFCount from sbbatchsts where
                             bchdate = to_date(v_currdate,'DD/MM/RRRR')
                             and bchmdl='SAAFINDAYPROCESS' and trim(bchsts)='Y';
                if v_count>0 then
                        if v_count<v_countBFBatch and v_BFCount = 0 then
                                --He thong dang chay buoc xu ly truoc cuoi ngay tai buoc v_count/v_countBFBatch
                                v_message:='He thong dang xy ly truoc cuoi ngay tai buoc ' || to_char(v_count) || '/' || to_char(v_countBFBatch) || ' .';

                        end if;
                        if v_BFCount>0 and v_hostatus='1' then
                             --He thong dang hoat dong sau buoc xu ly truoc cuoi ngay
                                v_message:='He thong dang hoat dong va da chay buoc xu ly truoc cuoi ngay, ngay he thong ' || v_currdate  || '!';

                        end if;
                        if v_BFCount>0 and v_hostatus='0' then
                                --He thong danh chay batch cuoi ngay tai buoc
                                v_message:='He thong dang xu ly cuoi ngay tai buoc ' || to_char(v_count) || '/' || to_char(v_countAllBatch) || '.';

                        end if;
                                end if;
                                SELECT status INTO v_brstatsus FROM brgrp WHERE brid = '0001';
                                IF v_brstatsus = 'A' THEN
                                     v_message:= v_message || ' Da khoi tao BR001.';
                                ELSE
                                     v_message:= v_message || ' BR001 chua khoi tao.';
                                END IF;
                                        FOR rec IN
                                                (
                                                        SELECT * FROM
                                                                                 (select trim(regexp_substr(VARVALUE,'[^,]+', 1, level)) phone
                                                                                 from (SELECT varvalue FROM sysvar WHERE varname = 'BATCHREMINDER' )
                                                                                 connect by regexp_substr(VARVALUE, '[^,]+', 1, level) is not NULL) a
                                                )
                                        LOOP
                                                 v_string:= 'select '''|| v_message || ''' detail from dual';
                             InsertEmailLog(rec.phone , '0305', v_string,'');
                                        END LOOP;
                    END IF;
        END;
   END IF;
  exception
    when others then
      plog.error(pkgctx, sqlerrm);
      plog.setEndSection(pkgctx, 'CheckKLCuoiNgay');
  end;
  ------------------------------------------
  function CheckEmail(p_email varchar2) return boolean as

    l_is_email_valid boolean;
  begin

    plog.setBeginSection(pkgctx, 'CheckEmail');

   if owa_pattern.match(p_email,
                       '^\w{1,}[.0-9a-zA-Z_]\w{1,}' ||
                       '@\w{1,}[.0-9a-zA-Z_]\w{1,}[.0-9a-zA-Z_]\w{1,}[.0-9a-zA-Z_]\w{1,}$') then
      l_is_email_valid := true;
    else
      l_is_email_valid := false;
    end if;

    /*IF( ( REPLACE( p_email, ' ','') IS NOT NULL ) AND
         ( NOT owa_pattern.match(
                   p_email, '^[a-z]+[\.\_\-[a-z0-9]+]*[a-z0-9]@[a-z0-9]+\-?[a-z0-9]{1,63}\.?[a-z0-9]{0,6}\.?[a-z0-9]{0,6}\.[a-z]{0,6}$') ) ) THEN
        RETURN FALSE;
    ELSE
        RETURN TRUE;
    END IF;*/

    plog.setEndSection(pkgctx, 'CheckEmail');

    return l_is_email_valid;

  exception
    when others then
      plog.error(pkgctx, sqlerrm);
      plog.setEndSection(pkgctx, 'CheckEmail');
  end;

  procedure InsertEmailLog(p_email       varchar2,
                           p_template_id varchar2,
                           p_data_source varchar2,
                           p_account     varchar2) is

    l_status             char(1) := 'A';
    l_reject_status      char(1) := 'R';
    l_receiver_address   emaillog.email%type;
    l_template_id        emaillog.templateid%type;
    l_datasource         emaillog.datasource%type;
    l_account            emaillog.afacctno%type;
    l_message_type       templates.type%type;
    l_is_required        templates.require_register%type;
    l_aftemplates_autoid aftemplates.autoid%type;
    l_can_create_message boolean := true;
  begin

   -- plog.setBeginSection(pkgctx, 'InsertEmailLog');

    plog.error( 'l_template_id: ' || p_template_id);

    l_receiver_address := p_email;
    l_template_id      := p_template_id;
    l_account          := p_account;


    select t.type, t.require_register
      into l_message_type, l_is_required
      from templates t
     where code = p_template_id;


    if l_message_type = 'S' AND p_template_id<>'0321'  then
      l_datasource := fn_convert_to_vn(p_data_source);
    else
      l_datasource := p_data_source;
    end if;

    --Kiem tra xem mau co bat buoc dang ky khong,
    --neu co thi kiem tra xem da duoc dang ky chua
    if l_is_required = 'Y' then
      begin
        select temp.autoid
          into l_aftemplates_autoid
          from aftemplates temp, afmast af
         where af.acctno = l_account and af.custid = temp.custid
           and temp.template_code = l_template_id;

        l_can_create_message := true;

      exception
        when NO_DATA_FOUND then
          l_can_create_message := false;
      end;
    end if;

    if l_can_create_message then
      if l_receiver_address is not null and length(trim(l_receiver_address)) > 0 then
        insert into emaillog
          (autoid,
           email,
           templateid,
           datasource,
           status,
           createtime,
           afacctno)
        values
          (seq_emaillog.nextval,
           l_receiver_address,
           l_template_id,
           l_datasource,
           l_status,
           sysdate,
           l_account);
      else
        insert into emaillog
          (autoid, email, templateid, datasource, status, createtime, note)
        values
          (seq_emaillog.nextval,
           l_receiver_address,
           l_template_id,
           l_datasource,
           l_reject_status,
           sysdate,
           '---');
      end if;
    else
      insert into emaillog
        (autoid, email, templateid, datasource, status, createtime, note)
      values
        (seq_emaillog.nextval,
         l_receiver_address,
         l_template_id,
         l_datasource,
         l_reject_status,
         sysdate,
         'This template not registed yet');
    end if;
  --  plog.setEndSection(pkgctx, 'InsertEmailLog');

  exception
    when others then
      plog.error(pkgctx, sqlerrm);
      plog.setEndSection(pkgctx, 'InsertEmailLog');
  end;

  function fn_convert_to_vn(strinput in nvarchar2) return nvarchar2 is
    strconvert nvarchar2(32527);
  begin
    strconvert := translate(strinput,
                            utf8nums.c_FindText,
                            utf8nums.c_ReplText);
                  ---'???????a?????d????????i??????o????????u?u???????????????????A????????????????I?????????O???????U?U?????????',
                     ----       'aaaaaaaaaaaaaaaaadeeeeeeeeeeeiiiiiooooooooooooooooouuuuuuuuuuuyyyyyAAAAAAAAAAAAAAAAADEEEEEEEEEEEIIIIIOOOOOOOOOOOOOOOOOUUUUUUUUUUUYYYYY');

    return strconvert;
  end;

  function fn_GetNextRunDate(p_last_start_date in date, cycle in char)
    return date is
    l_next_run_date date;
  begin

    if cycle = 'D' then
      l_next_run_date := p_last_start_date + 1;
      /*          update templates_scheduler
        set repeat_interval = :new.cycle,
            next_run_date   = last_start_date + 1
      where template_id = l_template_id;*/
    elsif cycle = 'M' then

      l_next_run_date := add_months(p_last_start_date, 1);
      /*          update templates_scheduler
        set repeat_interval = :new.cycle,
            next_run_date   = add_months(last_start_date, 1)
      where template_id = l_template_id;*/
    elsif cycle = 'Y' then
      l_next_run_date := add_months(p_last_start_date, 12);
      /*          update templates_scheduler
        set repeat_interval = :new.cycle,
            next_run_date   =  add_months(last_start_date, 12)
      where template_id = l_template_id;*/
    end if;

    return l_next_run_date;
  end;



begin
  -- Initialization
  -- <Statement>;
  for i in (select * from tlogdebug) loop
    logrow.loglevel  := i.loglevel;
    logrow.log4table := i.log4table;
    logrow.log4alert := i.log4alert;
    logrow.log4trace := i.log4trace;
  end loop;

  pkgctx := plog.init('NMPKS_EMS',
                      plevel     => nvl(logrow.loglevel, 30),
                      plogtable  => (nvl(logrow.log4table, 'N') = 'Y'),
                      palert     => (nvl(logrow.log4alert, 'N') = 'Y'),
                      ptrace     => (nvl(logrow.log4trace, 'N') = 'Y'));
end NMPKS_EMS;
/
