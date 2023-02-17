SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "GLGROUP" is

BEGIN
--NHOM NOI BANG
FOR rec IN (
SELECT  tl.tltxcd, gl.txdate , tl.busdate , '9800'||max(substr(gl.txnum,5)) txnum, gl.acctno , gl.dorc , gl.subtxno , SUM (gl.amt) amt
,max(mi.taskcd) taskcd , max(mi.deptcd)deptcd , max(mi.micd) micd,max(mi.custid)custid ,max(custname) custname
FROM gltrandtl gl , mitrandtl mi , tllog tl, gltrandtl cogl
WHERE tl.txdate = gl.txdate AND tl.txnum = gl.txnum
AND gl.txdate = mi.txdate AND gl.txnum  = mi.txnum
AND gl.acctno =mi.acctno AND gl.subtxno = mi.subtxno
AND gl.dorc = mi.dorc
AND gl.txdate = cogl.txdate(+)  AND gl.txnum  = cogl.txnum(+)
AND gl.subtxno = cogl.subtxno(+)
AND cogl.dorc(+) = (CASE WHEN gl.DORC='D' THEN 'C' ELSE 'D' END)
AND tl.deltd <>'Y'
AND substr(gl.acctno,7,1)<>'0'
GROUP BY tl.tltxcd, gl.txdate , tl.busdate , gl.acctno , gl.dorc , gl.subtxno , gl.glgrp,cogl.acctno  )
LOOP

INSERT INTO gltran
(ACCTNO,TXDATE,TXNUM,BKDATE,CCYCD,DORC,SUBTXNO,AMT,DELTD,AUTOID)
VALUES
(rec.acctno ,rec.txdate,rec.txnum,rec.busdate,'00',rec.dorc,rec.subtxno,rec.amt,'N',seq_gltran.NEXTVAL );

INSERT INTO mitran
(TXDATE,TXNUM,SUBTXNO,DORC,ACCTNO,CUSTID,CUSTNAME,TASKCD,DEPTCD,MICD,DESCRIPTION,DELTD,AUTOID)
VALUES
(rec.txdate,rec.txnum,rec.SUBTXNO,rec.dorc,rec.acctno,rec.custid,rec.custname,rec.taskcd,rec.DEPTCD,rec.MICD,null,'N',seq_mitran.NEXTVAL);

END LOOP;

FOR rec IN (
SELECT  DISTINCT   gl.txdate , tl.busdate , '9800'||max(substr(gl.txnum,5)) txnum, tl.tltxcd,gl.GLGRP
FROM gltrandtl gl , mitrandtl mi , tllog tl, gltrandtl cogl
WHERE tl.txdate = gl.txdate AND tl.txnum = gl.txnum
AND gl.txdate = mi.txdate AND gl.txnum  = mi.txnum
AND gl.acctno =mi.acctno AND gl.subtxno = mi.subtxno
AND gl.dorc = mi.dorc
AND gl.txdate = cogl.txdate(+)  AND gl.txnum  = cogl.txnum(+)
AND gl.subtxno = cogl.subtxno(+)
AND cogl.dorc(+) = (CASE WHEN gl.DORC='D' THEN 'C' ELSE 'D' END)
AND tl.deltd <>'Y'
AND substr(gl.acctno,7,1)<>'0'
GROUP BY tl.tltxcd, gl.txdate , tl.busdate , gl.acctno , gl.dorc , gl.subtxno, gl.GLGRP,cogl.acctno )
LOOP

INSERT INTO tllog
(AUTOID,TXNUM,TXDATE,TXTIME,BRID,TLID,OFFID,OVRRQS,CHID,CHKID,TLTXCD,IBT,BRID2,TLID2,CCYUSAGE,OFF_LINE,DELTD,BRDATE,BUSDATE,TXDESC,IPADDRESS,WSNAME,TXSTATUS,MSGSTS,OVRSTS,BATCHNAME,MSGAMT,MSGACCT,CHKTIME,OFFTIME)
VALUES
(seq_tllog.NEXTVAL ,rec.txnum ,rec.txdate,'15:28:28','0000','0000',NULL,NULL,NULL,NULL,'9900','0',NULL,NULL,'00','N','N',rec.txdate,rec.busdate,'Gop GL '||rec.tltxcd ||' ' || rec.GLGRP,'HOST','HOST','1','0','0','DAY ',0,NULL,NULL,'03:42:32');

END LOOP;

-- khong co trong mitran


FOR rec IN (
SELECT  tl.tltxcd, gl.txdate , tl.busdate , '9800'||max(substr(gl.txnum,5)) txnum, gl.acctno , gl.dorc , gl.subtxno , SUM (gl.amt) amt
FROM gltrandtl gl , mitrandtl mi , tllog tl, gltrandtl cogl
WHERE tl.txdate = gl.txdate AND tl.txnum = gl.txnum
AND gl.txdate = mi.txdate (+)AND gl.txnum  = mi.txnum(+)
AND gl.acctno =mi.acctno(+) AND gl.subtxno = mi.subtxno(+)
AND gl.dorc = mi.dorc(+)
AND gl.txdate = cogl.txdate(+)  AND gl.txnum  = cogl.txnum(+)
AND gl.subtxno = cogl.subtxno(+)
AND cogl.dorc(+) = (CASE WHEN gl.DORC='D' THEN 'C' ELSE 'D' END)
AND tl.deltd <>'Y'
AND substr(gl.acctno,7,1)<>'0'
AND mi.txdate IS  NULL
GROUP BY tl.tltxcd, gl.txdate , tl.busdate , gl.acctno , gl.dorc , gl.subtxno , gl.glgrp ,cogl.acctno )
LOOP

INSERT INTO gltran
(ACCTNO,TXDATE,TXNUM,BKDATE,CCYCD,DORC,SUBTXNO,AMT,DELTD,AUTOID)
VALUES
(rec.acctno ,rec.txdate,rec.txnum,rec.busdate,'00',rec.dorc,rec.subtxno,rec.amt,'N',seq_gltran.NEXTVAL );

END LOOP;

FOR rec IN (
SELECT  DISTINCT   gl.txdate , tl.busdate , '9800'||max(substr(gl.txnum,5)) txnum, tl.tltxcd,gl.GLGRP
FROM gltrandtl gl , mitrandtl mi , tllog tl, gltrandtl cogl
WHERE tl.txdate = gl.txdate AND tl.txnum = gl.txnum
AND gl.txdate = mi.txdate (+)AND gl.txnum  = mi.txnum(+)
AND gl.acctno =mi.acctno(+) AND gl.subtxno = mi.subtxno(+)
AND gl.dorc = mi.dorc(+)
AND gl.txdate = cogl.txdate(+)  AND gl.txnum  = cogl.txnum(+)
AND gl.subtxno = cogl.subtxno(+)
AND cogl.dorc(+) = (CASE WHEN gl.DORC='D' THEN 'C' ELSE 'D' END)
AND tl.deltd <>'Y'
AND mi.txdate IS NULL
AND substr(gl.acctno,7,1)<>'0'
GROUP BY tl.tltxcd, gl.txdate , tl.busdate , gl.acctno , gl.dorc , gl.subtxno , gl.glgrp ,cogl.acctno )
LOOP

INSERT INTO tllog
(AUTOID,TXNUM,TXDATE,TXTIME,BRID,TLID,OFFID,OVRRQS,CHID,CHKID,TLTXCD,IBT,BRID2,TLID2,CCYUSAGE,OFF_LINE,DELTD,BRDATE,BUSDATE,TXDESC,IPADDRESS,WSNAME,TXSTATUS,MSGSTS,OVRSTS,BATCHNAME,MSGAMT,MSGACCT,CHKTIME,OFFTIME)
VALUES
(seq_tllog.NEXTVAL ,rec.txnum ,rec.txdate,'15:28:28','0000','0000',NULL,NULL,NULL,NULL,'9900','0',NULL,NULL,'00','N','N',rec.txdate,rec.busdate,'Gop GL '||rec.tltxcd ||' ' || rec.GLGRP,'HOST','HOST','1','0','0','DAY ',0,NULL,NULL,'03:42:32');

END LOOP;

--NHOM NGOAI BANG

-- khong co trong mitran


FOR rec IN (
SELECT  tl.tltxcd, gl.txdate , tl.busdate , '9700'||max(substr(gl.txnum,5)) txnum, gl.acctno , gl.dorc , gl.subtxno , SUM (gl.amt) amt
FROM gltrandtl gl ,  tllog tl
WHERE tl.txdate = gl.txdate AND tl.txnum = gl.txnum
AND tl.deltd <>'Y'
AND substr(gl.acctno,7,1)='0'
GROUP BY tl.tltxcd, gl.txdate , tl.busdate , gl.acctno , gl.dorc , gl.subtxno , gl.glgrp )
LOOP

INSERT INTO gltran
(ACCTNO,TXDATE,TXNUM,BKDATE,CCYCD,DORC,SUBTXNO,AMT,DELTD,AUTOID)
VALUES
(rec.acctno ,rec.txdate,rec.txnum,rec.busdate,'00',rec.dorc,rec.subtxno,rec.amt,'N',seq_gltran.NEXTVAL );

END LOOP;

FOR rec IN (
SELECT  DISTINCT   gl.txdate , tl.busdate , '9700'||max(substr(gl.txnum,5)) txnum, tl.tltxcd,gl.GLGRP
FROM gltrandtl gl ,  tllog tl
WHERE tl.txdate = gl.txdate AND tl.txnum = gl.txnum
AND tl.deltd <>'Y'
AND substr(gl.acctno,7,1)='0'
GROUP BY tl.tltxcd, gl.txdate , tl.busdate , gl.acctno , gl.dorc , gl.subtxno , gl.glgrp )
LOOP

INSERT INTO tllog
(AUTOID,TXNUM,TXDATE,TXTIME,BRID,TLID,OFFID,OVRRQS,CHID,CHKID,TLTXCD,IBT,BRID2,TLID2,CCYUSAGE,OFF_LINE,DELTD,BRDATE,BUSDATE,TXDESC,IPADDRESS,WSNAME,TXSTATUS,MSGSTS,OVRSTS,BATCHNAME,MSGAMT,MSGACCT,CHKTIME,OFFTIME)
VALUES
(seq_tllog.NEXTVAL ,rec.txnum ,rec.txdate,'15:28:28','0000','0000',NULL,NULL,NULL,NULL,'9900','0',NULL,NULL,'00','N','N',rec.txdate,rec.busdate,'Gop GL '||rec.tltxcd ||' ' || rec.GLGRP,'HOST','HOST','1','0','0','DAY ',0,NULL,NULL,'03:42:32');

END LOOP;


/*INSERT INTO gltranadtl SELECT * FROM  gltrandtl;
INSERT INTO mitranadtl SELECT * FROM  mitrandtl;

DELETE from   gltrandtl;
DELETE from    mitrandtl;*/


END; -- Procedure

 
 
 
 
/
