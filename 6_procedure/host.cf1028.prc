SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "CF1028" (
   PV_REFCURSOR           IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   pv_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   PV_MAKER       IN       VARCHAR2,
   PV_CHEKER      IN       VARCHAR2
     )
IS
--
   CUR            PKG_REPORT.REF_CURSOR;
   V_STROPT       VARCHAR2 (5);            -- A: ALL; B: BRANCH; S: SUB-BRANCH
   V_STRBRID      VARCHAR2 (100);                   -- USED WHEN V_NUMOPTION > 0
   V_STRMAKER     VARCHAR2 (100);
   V_STRCHEKER    VARCHAR2 (100);
   v_currdate     DATE ;
   v_t1_date     DATE ;
BEGIN

IF  (PV_MAKER <> 'ALL')
THEN
   V_STRMAKER := upper(PV_MAKER);
ELSE
   V_STRMAKER := '%';
END IF;

IF  (PV_CHEKER <> 'ALL')
THEN
   V_STRCHEKER := upper(PV_CHEKER);
ELSE
   V_STRCHEKER := '%';
END IF;

v_currdate := to_date( to_char( SYSDATE,'DD/MM/YYYY'),'dd/mm/yyyy');
SELECT get_t_date ( v_currdate,1 ) INTO v_t1_date  FROM dual ;

-- Main report
OPEN PV_REFCURSOR FOR

--CHI TIEU 1.1  MO tai khoan nhung chua duoc duyet
SELECT max(af.brid) brid,'001' TYPE,'CFMAST' TLTXCD, cf.custodycd, maker_dt,maker_time,approve_dt,approve_time ,tlp1.tlname maker,tlp2.tlname checker
from maintain_log m,tlprofiles tlp1, tlprofiles tlp2, afmast af, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf
WHERE maker_dt = v_currdate and child_table_name ='AFMAST' AND column_name ='ACCTNO'
AND action_flag ='ADD' and m.maker_id =tlp1.tlid(+) and m.approve_id =tlp2.tlid(+)
AND to_value = af.acctno AND af.custid = cf.custid
AND (TO_NUMBER( nvl( SUBSTR(approve_time,4,2),to_char(SYSDATE,'mi')))- TO_NUMBER(SUBSTR(maker_time,4,2))>45
     OR
     TO_NUMBER( nvl( SUBSTR(approve_time,1,2),to_char(SYSDATE,'hh')))- TO_NUMBER(SUBSTR(maker_time,1,2))>1)
AND maker_time < '16:00:00'
AND NVL(m.maker_id,'-') LIKE   V_STRMAKER
AND NVL(m.approve_id,'-') LIKE   V_STRCHEKER
GROUP BY  cf.custodycd, maker_dt,maker_time,approve_dt,approve_time ,tlp1.tlname ,tlp2.tlname

UNION ALL
--m? sau 5h th?h?i duy?t tru?c 9h h?au
SELECT max(af.brid) brid,'001' TYPE, 'CFMAST' TLTXCD,cf.custodycd, maker_dt,maker_time,approve_dt,approve_time ,tlp1.tlname maker,tlp2.tlname checker
from maintain_log m,tlprofiles tlp1, tlprofiles tlp2, afmast af, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf
where maker_dt <  v_currdate
and child_table_name ='AFMAST' AND column_name ='ACCTNO'
AND action_flag ='ADD' and m.maker_id =tlp1.tlid(+) and m.approve_id =tlp2.tlid(+)
AND to_value = af.acctno AND af.custid = cf.custid
AND approve_time IS NULL
AND maker_dt >=  '01-MAR-2014'
AND NVL(m.maker_id,'-') LIKE   V_STRMAKER
AND NVL(m.approve_id,'-') LIKE   V_STRCHEKER
GROUP BY  cf.custodycd, maker_dt,maker_time,approve_dt,approve_time ,tlp1.tlname ,tlp2.tlname

UNION
--m? sau 5h th?h?i duy?t tru?c 9h h?au
SELECT max(af.brid) brid,'001' TYPE, 'CFMAST' TLTXCD,cf.custodycd, maker_dt,maker_time,approve_dt,approve_time ,tlp1.tlname maker,tlp2.tlname checker
from maintain_log m,tlprofiles tlp1, tlprofiles tlp2, afmast af, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf
where approve_dt = v_currdate AND maker_dt = v_t1_date
and child_table_name ='AFMAST' AND column_name ='ACCTNO'
AND action_flag ='ADD' and m.maker_id =tlp1.tlid(+) and m.approve_id =tlp2.tlid(+)
AND to_value = af.acctno AND af.custid = cf.custid
AND maker_time >= '16:00:00' AND  approve_time >'09:00:00'
AND NVL(m.maker_id,'-') LIKE   V_STRMAKER
AND NVL(m.approve_id,'-') LIKE   V_STRCHEKER
GROUP BY  cf.custodycd, maker_dt,maker_time,approve_dt,approve_time ,tlp1.tlname ,tlp2.tlname

UNION ALL
--CHI TIEU 2 mo tieu khoan duyet nhung chua co chu ky
SELECT (af.brid) brid,'002' TYPE,'CFMAST' TLTXCD, cf.custodycd, maker_dt,maker_time,approve_dt,approve_time ,tlp1.tlname maker,tlp2.tlname checker
from maintain_log m,tlprofiles tlp1, tlprofiles tlp2, afmast af, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf
where approve_dt = v_currdate and child_table_name ='AFMAST' AND column_name ='ACCTNO'
AND action_flag ='ADD' and m.maker_id =tlp1.tlid(+) and m.approve_id =tlp2.tlid(+)
AND to_value = af.acctno AND af.custid = cf.custid
AND cf.custid NOT IN (SELECT custid FROM cfsign )
AND NVL(m.maker_id,'-') LIKE   V_STRMAKER
AND NVL(m.approve_id,'-') LIKE   V_STRCHEKER
--AND AF.corebank ='N'

union all
--CHI TIEU 3 tai khoan corebank nhung chua co so tai khoan ngan hang
SELECT (af.brid) brid,'003' TYPE,'CFMAST' TLTXCD, cf.custodycd, maker_dt,maker_time,approve_dt,approve_time ,tlp1.tlname maker,tlp2.tlname checker
from maintain_log m,tlprofiles tlp1, tlprofiles tlp2, afmast af, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf
where approve_dt =v_currdate  and child_table_name ='AFMAST' AND column_name ='ACCTNO'
AND action_flag ='ADD' and m.maker_id =tlp1.tlid(+) and m.approve_id =tlp2.tlid(+)
AND to_value = af.acctno AND af.custid = cf.custid
AND af. bankacctno is  null
AND AF.corebank ='Y'
AND NVL(m.maker_id,'-') LIKE   V_STRMAKER
AND NVL(m.approve_id,'-') LIKE   V_STRCHEKER

UNION ALL
--CHI TIEU 41 mo tieu khoan nhung chua duoc acctive
SELECT (af.brid) brid,'004' TYPE,'CFMAST' TLTXCD, cf.custodycd, maker_dt,maker_time,approve_dt,approve_time ,tlp1.tlname maker,tlp2.tlname checker
from maintain_log m,tlprofiles tlp1, tlprofiles tlp2, afmast af, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf
where maker_dt =v_currdate and child_table_name ='AFMAST' AND column_name ='ACCTNO'
AND action_flag ='ADD' and m.maker_id =tlp1.tlid and m.approve_id =tlp2.tlid
AND to_value = af.acctno AND af.custid = cf.custid
AND cf.activests ='N' AND maker_time < '16:00:00'
AND NVL(m.maker_id,'-') LIKE   V_STRMAKER
AND NVL(m.approve_id,'-') LIKE   V_STRCHEKER

UNION ALL
SELECT (af.brid) brid,'004' TYPE,'CFMAST' TLTXCD, cf.custodycd, maker_dt,maker_time, approve_dt, approve_time ,tlp1.tlname maker,tlp2.tlname checker
from maintain_log m,tlprofiles tlp1, tlprofiles tlp2, afmast af, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf
where maker_dt < v_currdate
and child_table_name ='AFMAST' AND column_name ='ACCTNO'
AND action_flag ='ADD' and m.maker_id =tlp1.tlid and m.approve_id =tlp2.tlid
AND to_value = af.acctno AND af.custid = cf.custid
AND cf.activests ='N'
AND NVL(m.maker_id,'-') LIKE   V_STRMAKER
AND NVL(m.approve_id,'-') LIKE   V_STRCHEKER
UNION ALL

SELECT (af.brid) brid, '004' TYPE,'CFMAST' TLTXCD, cf.custodycd, maker_dt,maker_time, TXDATE approve_dt,txtime approve_time ,tlp1.tlname maker,tlp2.tlname checker
from maintain_log m,tlprofiles tlp1, tlprofiles tlp2, afmast af, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf,
(SELECT msgacct ,txtime,TXDATE  FROM vw_tllog_all WHERE  TXDATE = v_currdate AND TLTXCD ='0012') TL
where maker_dt = v_t1_date
and child_table_name ='AFMAST' AND column_name ='ACCTNO'
AND action_flag ='ADD' and m.maker_id =tlp1.tlid and m.approve_id =tlp2.tlid
AND to_value = af.acctno AND af.custid = cf.custid
AND AF.acctno = TL.msgacct
AND txtime >'09:00:00'
AND NVL(m.maker_id,'-') LIKE   V_STRMAKER
AND NVL(m.approve_id,'-') LIKE   V_STRCHEKER
UNION ALL

SELECT (af.brid) brid, '006' TYPE , '2240' TLTXCD, cf.custodycd, tl.txdate maker_dt , tl.txtime maker_time, tl.txdate approve_dt  , '' approve_time , tlp1.tlname maker,tlp2.tlname checker
from sedeposit se, vw_tllog_all tl, afmast af, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf ,tlprofiles tlp1, tlprofiles tlp2,tllogfldall tlfld
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

 Union all
-- Chi tieu tai khoan ngan hang nhung chua duoc active ben ngan hang
SELECT (af.brid) brid,'007' TYPE,'CFMAST' TLTXCD, cf.custodycd, maker_dt,maker_time,approve_dt,approve_time ,tlp1.tlname maker,tlp2.tlname checker
from maintain_log m,tlprofiles tlp1, tlprofiles tlp2, afmast af, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf
where  child_table_name ='AFMAST' AND column_name ='ACCTNO'
AND action_flag ='ADD' and m.maker_id =tlp1.tlid(+) and m.approve_id =tlp2.tlid(+)
AND to_value = af.acctno AND af.custid = cf.custid
and cf.custodycd in (Select custodycd from CFBankstatus where banksts ='N' )
AND af.corebank='Y'
AND NVL(m.maker_id,'-') LIKE   V_STRMAKER
AND NVL(m.approve_id,'-') LIKE   V_STRCHEKER
AND CASE WHEN approve_dt = v_currdate THEN   maker_time ELSE '15:00:00' END  < '16:00:00'
UNION ALL

SELECT  tl.brid ,
'009' TYPE , TLTXCD TLTXCD, cfcustodycd TXNUM, tl.txdate maker_dt , tl.txtime maker_time, tl.txdate approve_dt  , '' approve_time , tlp1.tlname maker,tlp2.tlname checker
FROM  (SELECT * FROM tllog4dr UNION ALL SELECT * FROM tllog4drall) tl,tlprofiles tlp1, tlprofiles tlp2
WHERE txstatus in('5','8')
AND   tl.tlid = tlp1.tlid(+) and tl.offid =tlp2.tlid(+)
AND tl.tlid <> tl.offid
AND tl.txdate = v_currdate
 AND tl.tlid LIKE   V_STRMAKER
 AND tl.offid LIKE   V_STRCHEKER
;

EXCEPTION
  WHEN OTHERS
   THEN
   dbms_output.put_line('12233');
      RETURN;
END;
 
 
 

 
/
