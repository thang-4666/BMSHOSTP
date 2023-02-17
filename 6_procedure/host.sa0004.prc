SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "SA0004" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   PV_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2,
   TLTXCD         IN       VARCHAR2,
   MAKER          IN       VARCHAR2,
   CHECKER        IN       VARCHAR2,
   PV_CUSTODYCD      IN       VARCHAR2
 )
IS
--
-- PURPOSE: BRIEFLY EXPLAIN THE FUNCTIONALITY OF THE PROCEDURE
--
-- MODIFICATION HISTORY
-- PERSON      DATE    COMMENTS
-- HUNG.LB   26-Aug-10  UPDATED
-- ANH.PT    17-Sep-10  UPDATED
-- ANH.PT   23-Sep-10  UPDATED, CHANGE ID 38
-- HUYNH.ND 06-Oct-10  UPDATED, ADD filter CUSTOCYCD ( Chon tai khoan luu ky )
-- HUYNH.ND 13-Oct-10  UPDATED, Doi ten tham so dau vao CUSTODYCD -> PV_CUSTODYCD
-- HUNG.LB  27-Oct-10  UPDATED  CHANGE ID 102
-- SINH.TN  01-Nov-10  UPDATED, Them ma giao dich 5573 cho bao cao va thay the dieu kien cf.custodycd<>'017P000002' thanh nvl(cf.custodycd,'-')<>'017P000002' trong dk where
-- HUYNH.ND 05-Nov-2010 UPDATE, CHANGE ID 118: GD 8879 bi trung` records
-- HUYNH.ND 12-Nov-2010  UPDATE, CHANGE ID   : GD 3387 them thong tin MaCK & SL Ck vao thong tin mieu ta.
-- HUYNH.ND 16-Nov-2010  UPDATE, CHANGE ID   : GD 2650 2675 khong tao duoc bao cao.
-- HUYNH.ND 16-Nov-2010   UPDATE, CHANGE ID  : GD 3386 them thong tin MaCK & chinh sua gia tri cot "so tien/SL" tu` SL thanh So Tien.
-- ---------   ------  -------------------------------------------
   V_STROPTION        VARCHAR2 (5);       -- A: ALL; B: BRANCH; S: SUB-BRANCH
   V_STRBRID          VARCHAR2 (40);        -- USED WHEN V_NUMOPTION > 0
   V_STRINBRID        VARCHAR2 (4);

   V_STRTLTXCD              VARCHAR2 (6);
   V_STRMAKER            VARCHAR2 (20);
   V_STRCHECKER             VARCHAR2 (20);
   V_STRCUSTOCYCD           VARCHAR2 (20);
-- DECLARE PROGRAM VARIABLES AS SHOWN ABOVE
BEGIN
-- INSERT INTO TEMP_BUG(TEXT) VALUES('CF0001');COMMIT;
   V_STROPTION := upper(OPT);
   V_STRINBRID := PV_BRID;

   IF (V_STROPTION = 'A' )
   THEN
      V_STRBRID := '%';
   ELSE if(V_STROPTION = 'B') then
            select brgrp.mapid into V_STRBRID from brgrp where brgrp.brid = V_STRINBRID;
        else
            V_STRBRID := V_STRINBRID;
        end if;
   END IF;

   IF (TLTXCD <> 'ALL')
   THEN
      V_STRTLTXCD := TLTXCD;
   ELSE
      V_STRTLTXCD := '%%';
   END IF;

   IF (MAKER <> 'ALL')
   THEN
      V_STRMAKER := MAKER;
   ELSE
      V_STRMAKER := '%%';
   END IF;



   IF (CHECKER <> 'ALL')
   THEN
      V_STRCHECKER := CHECKER;
   ELSE
      V_STRCHECKER := '%%';
   END IF;

   IF (PV_CUSTODYCD <> 'ALL')
   THEN
      V_STRCUSTOCYCD := PV_CUSTODYCD;
   ELSE
      V_STRCUSTOCYCD := '%%';
   END IF;

OPEN PV_REFCURSOR
  FOR
select * from(
SELECT cf.custodycd,TL.TLTXCD ,TL.TXNUM,TL.TXDATE,TL.BUSDATE ,TL.MSGAMT,substr(TL.MSGACCT,1,10) MSGACCT, to_char(TL.TXDESC) txdesc ,TLPR1.TLNAME MAKER ,TLPR2.TLNAME CHECKER ,AL.CDCONTENT STATUS
FROM TLLOGALL TL,ALLCODE AL ,TLPROFILES TLPR1 ,TLPROFILES TLPR2,afmast af, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf
WHERE AL.CDTYPE ='SY' AND AL.CDNAME ='TXSTATUS' AND AL.CDVAL =TL.TXSTATUS
AND  TLPR1.TLID(+) =TL.TLID  AND TLPR2.TLID (+)=TL.OFFID
and af.acctno(+)= substr(TL.MSGACCT,1,10)
and cf.custid (+)= af.custid
and tl.txdate <= to_date(T_DATE,'DD/MM/YYYY' )
and tl.txdate >= to_date(F_DATE,'DD/MM/YYYY' )
AND nvl(TL.tlID,'-') LIKE V_STRMAKER
AND nvl(TL.offid,'-') LIKE V_STRCHECKER
AND TL.tltxcd LIKE V_STRTLTXCD
and (tl.brid like V_STRBRID or instr(V_STRBRID,tl.brid) <> 0)
AND (af.brid LIKE V_STRBRID or instr(V_STRBRID,af.brid) <> 0 )
And Tl.Deltd <>'Y'
and TL.tltxcd not in ('2650','2675','3386','3387','2643','2642','1196','2297','2298','0071','1171','2271','1172','0072','2272','8871','8872','8864','8878','8879','8804', '8809','8822','8824','9900','5573')
and nvl(cf.custodycd,'-')<>'017P000002' -- Sinh fixed (old: cf.custodycd<>'017P000002')
and cf.custodycd like V_STRCUSTOCYCD
--AND nvl(TL.briD,'-') LIKE V_STRBRID
UNION ALL
SELECT cf.custodycd,TL.TLTXCD ,TL.TXNUM,TL.TXDATE,TL.BUSDATE ,TL.MSGAMT,substr(TL.MSGACCT,1,10) MSGACCT, to_char(TL.TXDESC) txdesc ,TLPR1.TLNAME MAKER ,TLPR2.TLNAME CHECKER ,AL.CDCONTENT STATUS
FROM TLLOGALL TL,ALLCODE AL ,TLPROFILES TLPR1 ,TLPROFILES TLPR2,afmast af, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf, VW_DFMAST_ALL DF
WHERE AL.CDTYPE ='SY' AND AL.CDNAME ='TXSTATUS' AND AL.CDVAL =TL.TXSTATUS
AND  TLPR1.TLID(+) =TL.TLID  AND TLPR2.TLID (+)=TL.OFFID
and af.acctno(+)= DF.AFACCTNO
AND DF.ACCTNO = TL.MSGACCT
and cf.custid (+)= af.custid
and tl.txdate <= to_date(T_DATE,'DD/MM/YYYY' )
and tl.txdate >= to_date(F_DATE,'DD/MM/YYYY' )
AND nvl(TL.tlID,'-') LIKE V_STRMAKER
AND nvl(TL.offid,'-') LIKE V_STRCHECKER
AND TL.tltxcd LIKE V_STRTLTXCD
/*and (tl.brid like V_STRBRID or instr(V_STRBRID,tl.brid) <> 0)
AND (af.brid LIKE V_STRBRID or instr(V_STRBRID,af.brid) <> 0 )*/
And Tl.Deltd <>'Y'
and TL.tltxcd IN  ('2643','2642')
and nvl(cf.custodycd,'-')<>'017P000002' -- Sinh fixed (old: cf.custodycd<>'017P000002')
and cf.custodycd like V_STRCUSTOCYCD
UNION ALL
SELECT cf.custodycd,TL.TLTXCD ,TL.TXNUM,TL.TXDATE,TL.BUSDATE ,TL.MSGAMT,TL.MSGACCT MSGACCT , to_char(TL.TXDESC) txdesc ,TLPR1.TLNAME MAKER ,TLPR2.TLNAME CHECKER ,AL.CDCONTENT STATUS
FROM TLLOG TL,ALLCODE AL ,TLPROFILES TLPR1 ,TLPROFILES TLPR2,afmast af, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf
WHERE AL.CDTYPE ='SY' AND AL.CDNAME ='TXSTATUS' AND AL.CDVAL =TL.TXSTATUS
AND  TLPR1.TLID(+) =TL.TLID  AND TLPR2.TLID (+)=TL.OFFID
and af.acctno(+)= substr(TL.MSGACCT,1,10)
and cf.custid (+)= af.custid
and tl.txdate <= to_date(T_DATE,'DD/MM/YYYY' )
and tl.txdate >= to_date(F_DATE,'DD/MM/YYYY' )
And Tl.Tltxcd Like V_Strtltxcd
/*and (tl.brid like V_STRBRID or instr(V_STRBRID,tl.brid) <> 0)
AND (af.brid LIKE V_STRBRID or instr(V_STRBRID,af.brid) <> 0 )*/
and TL.tltxcd not in ('2650','2675','3386','3387','2643','1196','2297','2298','0071','1171','2271','1172','0072','2272','8871','8872','8864','8878','8879','8804','8809','8822','8824','9900','5573')
AND nvl(TL.tlID,'-') LIKE V_STRMAKER
AND nvl(TL.offid,'-') LIKE V_STRCHECKER
--AND nvl(TL.briD,'-') LIKE V_STRBRID
and tl.deltd <>'Y'
and nvl(cf.custodycd,'-')<>'017P000002' -- Sinh fixed (old: cf.custodycd<>'017P000002')
and cf.custodycd like V_STRCUSTOCYCD
UNION ALL
SELECT cf.custodycd,TL.TLTXCD ,TL.TXNUM,TL.TXDATE,TL.BUSDATE ,TL.MSGAMT,substr(TL.MSGACCT,1,10) MSGACCT, to_char(TL.TXDESC) txdesc ,TLPR1.TLNAME MAKER ,TLPR2.TLNAME CHECKER ,AL.CDCONTENT STATUS
FROM TLLOG TL,ALLCODE AL ,TLPROFILES TLPR1 ,TLPROFILES TLPR2,afmast af, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf, VW_DFMAST_ALL DF
WHERE AL.CDTYPE ='SY' AND AL.CDNAME ='TXSTATUS' AND AL.CDVAL =TL.TXSTATUS
AND  TLPR1.TLID(+) =TL.TLID  AND TLPR2.TLID (+)=TL.OFFID
and af.acctno(+)= DF.AFACCTNO
AND DF.ACCTNO = TL.MSGACCT
and cf.custid (+)= af.custid
and tl.txdate <= to_date(T_DATE,'DD/MM/YYYY' )
and tl.txdate >= to_date(F_DATE,'DD/MM/YYYY' )
AND nvl(TL.tlID,'-') LIKE V_STRMAKER
AND nvl(TL.offid,'-') LIKE V_STRCHECKER
AND TL.tltxcd LIKE V_STRTLTXCD
and (tl.brid like V_STRBRID or instr(V_STRBRID,tl.brid) <> 0)
AND (af.brid LIKE V_STRBRID or instr(V_STRBRID,af.brid) <> 0 )
And Tl.Deltd <>'Y'
and TL.tltxcd IN  ('2643','2642')
and nvl(cf.custodycd,'-')<>'017P000002' -- Sinh fixed (old: cf.custodycd<>'017P000002')
and cf.custodycd like V_STRCUSTOCYCD

------------------- GD 2650 & 2675 ------------------------------------------
UNION ALL
SELECT TLF.CVALUE CUSTODYCD,TL.TLTXCD ,TL.TXNUM,TL.TXDATE,TL.BUSDATE ,TL.MSGAMT,substr(TL.MSGACCT,1,10) MSGACCT, to_char(TL.TXDESC) txdesc ,TLPR1.TLNAME MAKER ,TLPR2.TLNAME CHECKER ,AL.CDCONTENT STATUS
FROM TLLOG TL,ALLCODE AL ,TLPROFILES TLPR1 ,TLPROFILES TLPR2,afmast af, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf,TLLOGFLD TLF
WHERE AL.CDTYPE ='SY' AND AL.CDNAME ='TXSTATUS' AND AL.CDVAL =TL.TXSTATUS
AND  TLPR1.TLID(+) =TL.TLID  AND TLPR2.TLID (+)=TL.OFFID
and af.acctno(+)= substr(TL.MSGACCT,1,10)
and cf.custid (+)= af.custid
and tl.txdate between to_date(F_DATE,'DD/MM/YYYY') and  to_date(T_DATE,'DD/MM/YYYY')
And Tl.Deltd <>'Y'
AND TL.TLTXCD IN ('2650','2675')
AND TL.TXDATE=TLF.TXDATE AND TL.TXNUM=TLF.TXNUM
AND TLF.FLDCD='88'
AND nvl(TL.tlID,'-') LIKE V_STRMAKER
AND nvl(TL.offid,'-') LIKE V_STRCHECKER
AND TL.tltxcd like V_STRTLTXCD
AND TLF.CVALUE like V_STRCUSTOCYCD
and (tl.brid like V_STRBRID or instr(V_STRBRID,tl.brid) <> 0)
AND (af.brid LIKE V_STRBRID or instr(V_STRBRID,af.brid) <> 0 )
and nvl(cf.custodycd,'-')<>'017P000002'
UNION ALL
SELECT TLF.CVALUE CUSTODYCD,TL.TLTXCD ,TL.TXNUM,TL.TXDATE,TL.BUSDATE ,TL.MSGAMT,substr(TL.MSGACCT,1,10) MSGACCT, to_char(TL.TXDESC) txdesc ,TLPR1.TLNAME MAKER ,TLPR2.TLNAME CHECKER ,AL.CDCONTENT STATUS
FROM TLLOGALL TL,ALLCODE AL ,TLPROFILES TLPR1 ,TLPROFILES TLPR2,afmast af, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf,TLLOGFLDALL TLF
WHERE AL.CDTYPE ='SY' AND AL.CDNAME ='TXSTATUS' AND AL.CDVAL =TL.TXSTATUS
AND  TLPR1.TLID(+) =TL.TLID  AND TLPR2.TLID (+)=TL.OFFID
and af.acctno(+)= substr(TL.MSGACCT,1,10)
and cf.custid (+)= af.custid
and tl.txdate between to_date(F_DATE,'DD/MM/YYYY') and  to_date(T_DATE,'DD/MM/YYYY')
And Tl.Deltd <>'Y'
AND TL.TLTXCD IN ('2650','2675')
AND TL.TXDATE=TLF.TXDATE AND TL.TXNUM=TLF.TXNUM
AND TLF.FLDCD='88'
AND nvl(TL.tlID,'-') LIKE V_STRMAKER
AND nvl(TL.offid,'-') LIKE V_STRCHECKER
AND TL.tltxcd like V_STRTLTXCD
AND TLF.CVALUE like V_STRCUSTOCYCD
and (tl.brid like V_STRBRID or instr(V_STRBRID,tl.brid) <> 0)
AND (af.brid LIKE V_STRBRID or instr(V_STRBRID,af.brid) <> 0 )
and nvl(cf.custodycd,'-')<>'017P000002'

------------------- GD 3386 them thong tin MaCK & chinh sua gia tri cot "so tien/soluong" tu` SL thanh So Tien.
UNION ALL
SELECT cf.custodycd,TL.TLTXCD ,TL.TXNUM,TL.TXDATE,TL.BUSDATE ,tlf.qtty*tlf.price MSGAMT,TL.MSGACCT MSGACCT,
  to_char(TL.TXDESC||'-M? CK:'||tlf.symbol||'-SL:'||tlf.qtty) as TXDESC,TLPR1.TLNAME MAKER ,TLPR2.TLNAME CHECKER ,AL.CDCONTENT STATUS
FROM tllog TL,ALLCODE AL ,TLPROFILES TLPR1 ,TLPROFILES TLPR2,afmast af, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf,
    (select txdate,txnum,sum(decode(fldcd,05,nvalue)) price,
  sum(decode(fldcd,21,nvalue)) qtty,
  LISTAGG(decode(fldcd,04,cvalue)) within group (order by  cvalue) symbol
  from tllogfld where fldcd in ('04','05','21') -- 04: Price, 05: symbol, 21: MaxQtty
  and txdate between to_date(F_DATE,'DD/MM/YYYY') and  to_date(T_DATE,'DD/MM/YYYY')
  --and txnum='0001000847' and txdate='01/JUN/10'
  group by txdate,txnum) tlf
WHERE AL.CDTYPE ='SY' AND AL.CDNAME ='TXSTATUS' AND AL.CDVAL =TL.TXSTATUS
  AND  TLPR1.TLID(+) =TL.TLID  AND TLPR2.TLID (+)=TL.OFFID
  and af.acctno(+)= substr(TL.MSGACCT,1,10)
  and cf.custid (+)= af.custid
  and tl.txdate between to_date(F_DATE,'DD/MM/YYYY') and  to_date(T_DATE,'DD/MM/YYYY')
  AND tl.tltxcd IN('3386')
  and tl.deltd <>'Y'
  and nvl(cf.custodycd,'-')<>'017P000002'
  and tlf.txnum=tl.txnum
  and tlf.txdate=tl.txdate
   AND nvl(TL.tlID,'-') LIKE V_STRMAKER
  AND nvl(TL.offid,'-') LIKE V_STRCHECKER
  and (tl.brid like V_STRBRID or instr(V_STRBRID,tl.brid) <> 0)
  AND (af.brid LIKE V_STRBRID or instr(V_STRBRID,af.brid) <> 0 )
  And Tl.Tltxcd Like V_STRTLTXCD
  and cf.custodycd like V_STRCUSTOCYCD
UNION ALL
SELECT cf.custodycd,TL.TLTXCD ,TL.TXNUM,TL.TXDATE,TL.BUSDATE ,tlf.qtty*tlf.price MSGAMT,TL.MSGACCT MSGACCT,
  to_char(TL.TXDESC||'-M? CK:'||tlf.symbol||'-SL:'||tlf.qtty) as TXDESC,TLPR1.TLNAME MAKER ,TLPR2.TLNAME CHECKER ,AL.CDCONTENT STATUS
FROM tllogall TL,ALLCODE AL ,TLPROFILES TLPR1 ,TLPROFILES TLPR2,afmast af, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf,
    (select txdate,txnum,sum(decode(fldcd,05,nvalue)) price,
  sum(decode(fldcd,21,nvalue)) qtty,
  LISTAGG(decode(fldcd,04,cvalue)) within group (order by  cvalue) symbol
  from tllogfldall where fldcd in ('04','05','21') -- 04: Price, 05: symbol, 21: MaxQtty
  and txdate between to_date(F_DATE,'DD/MM/YYYY') and  to_date(T_DATE,'DD/MM/YYYY')
  group by txdate,txnum) tlf
WHERE AL.CDTYPE ='SY' AND AL.CDNAME ='TXSTATUS' AND AL.CDVAL =TL.TXSTATUS
  AND  TLPR1.TLID(+) =TL.TLID  AND TLPR2.TLID (+)=TL.OFFID
  and af.acctno(+)= substr(TL.MSGACCT,1,10)
  and cf.custid (+)= af.custid
  and tl.txdate between to_date(F_DATE,'DD/MM/YYYY') and  to_date(T_DATE,'DD/MM/YYYY')
  AND tl.tltxcd IN('3386')
  and tl.deltd <>'Y'
  and nvl(cf.custodycd,'-')<>'017P000002'
  and tlf.txnum=tl.txnum
  and tlf.txdate=tl.txdate
  AND nvl(TL.tlID,'-') LIKE V_STRMAKER
  AND nvl(TL.offid,'-') LIKE V_STRCHECKER
  and (tl.brid like V_STRBRID or instr(V_STRBRID,tl.brid) <> 0)
  AND (af.brid LIKE V_STRBRID or instr(V_STRBRID,af.brid) <> 0 )
  And Tl.Tltxcd Like V_STRTLTXCD
  and cf.custodycd like V_STRCUSTOCYCD

------------------- GD 3387 them thong tin MaCK & SL Ck vao thong tin mieu ta
UNION ALL
SELECT cf.custodycd,TL.TLTXCD ,TL.TXNUM,TL.TXDATE,TL.BUSDATE ,TL.MSGAMT,TL.MSGACCT MSGACCT , to_char(TL.TXDESC) ||'-'|| tlf.cnvalue as TXDESC ,TLPR1.TLNAME MAKER ,TLPR2.TLNAME CHECKER ,AL.CDCONTENT STATUS
FROM TLLOG TL,ALLCODE AL ,TLPROFILES TLPR1 ,TLPROFILES TLPR2,afmast af, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf,
    (select txdate,txnum,'M?:'||LISTAGG(decode(fldcd,04,cvalue,nvalue),' - KL: ') WITHIN GROUP (ORDER BY cvalue,nvalue) AS cnvalue
    from tllogfld where fldcd in ('04','21')
    group by txdate,txnum) tlf
WHERE AL.CDTYPE ='SY' AND AL.CDNAME ='TXSTATUS' AND AL.CDVAL =TL.TXSTATUS
    AND  TLPR1.TLID(+) =TL.TLID  AND TLPR2.TLID (+)=TL.OFFID
    and af.acctno(+)= substr(TL.MSGACCT,1,10)
    and cf.custid (+)= af.custid
    and tl.txdate between to_date(F_DATE,'DD/MM/YYYY') and  to_date(T_DATE,'DD/MM/YYYY')
    AND nvl(TL.tlID,'-') LIKE V_STRMAKER
    AND nvl(TL.offid,'-') LIKE V_STRCHECKER
    And Tl.Tltxcd Like V_STRTLTXCD
    AND tl.tltxcd IN('3387')
    and tl.deltd <>'Y'
    and nvl(cf.custodycd,'-')<>'017P000002'
    and cf.custodycd like V_STRCUSTOCYCD
    and (tl.brid like V_STRBRID or instr(V_STRBRID,tl.brid) <> 0)
    AND (af.brid LIKE V_STRBRID or instr(V_STRBRID,af.brid) <> 0 )
    and tlf.txnum=tl.txnum
    and tlf.txdate=tl.txdate
UNION ALL
SELECT cf.custodycd,TL.TLTXCD ,TL.TXNUM,TL.TXDATE,TL.BUSDATE ,TL.MSGAMT,TL.MSGACCT MSGACCT , to_char(TL.TXDESC) ||'-'|| tlf.cnvalue as TXDESC ,TLPR1.TLNAME MAKER ,TLPR2.TLNAME CHECKER ,AL.CDCONTENT STATUS
FROM TLLOGALL TL,ALLCODE AL ,TLPROFILES TLPR1 ,TLPROFILES TLPR2,afmast af, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf,
      (select txdate,txnum,'M?:'||LISTAGG(decode(fldcd,04,cvalue,nvalue),' - KL: ') WITHIN GROUP (ORDER BY cvalue,nvalue) AS cnvalue
      from tllogfldall where fldcd in ('04','21')
      group by txdate,txnum) tlf
WHERE AL.CDTYPE ='SY' AND AL.CDNAME ='TXSTATUS' AND AL.CDVAL =TL.TXSTATUS
    AND  TLPR1.TLID(+) =TL.TLID  AND TLPR2.TLID (+)=TL.OFFID
    and af.acctno(+)= substr(TL.MSGACCT,1,10)
    and cf.custid (+)= af.custid
    and tl.txdate between to_date(F_DATE,'DD/MM/YYYY') and  to_date(T_DATE,'DD/MM/YYYY')
    AND nvl(TL.tlID,'-') LIKE V_STRMAKER
    AND nvl(TL.offid,'-') LIKE V_STRCHECKER
    And Tl.Tltxcd Like V_STRTLTXCD
    AND tl.tltxcd IN('3387')
    and tl.deltd <>'Y'
    and nvl(cf.custodycd,'-')<>'017P000002'
    and cf.custodycd like V_STRCUSTOCYCD
    and (tl.brid like V_STRBRID or instr(V_STRBRID,tl.brid) <> 0)
    AND (af.brid LIKE V_STRBRID or instr(V_STRBRID,af.brid) <> 0 )
    and tlf.txnum=tl.txnum
    and tlf.txdate=tl.txdate

-----------------GD 8878 8879
UNION ALL
SELECT cf.custodycd, TL.tltxcd , TL.txnum,TL.TXDATE,TL.BUSDATE, SE.namt, TL.MSGACCT MSGACCT, to_char(TL.TXDESC) txdesc ,TLPR1.TLNAME MAKER ,TLPR2.TLNAME CHECKER ,AL.CDCONTENT STATUS
FROM TLLOG TL, SETRAN SE, ALLCODE AL ,TLPROFILES TLPR1 ,TLPROFILES TLPR2,afmast af, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf
WHERE tl.txnum = se.txnum
AND tl.txdate = se.txdate
AND AL.CDTYPE ='SY' AND AL.CDNAME ='TXSTATUS' AND AL.CDVAL =TL.TXSTATUS
AND  TLPR1.TLID(+) =TL.TLID  AND TLPR2.TLID (+)=TL.OFFID
and af.acctno(+)= substr(TL.MSGACCT,1,10)
and cf.custid (+)= af.custid
and tl.txdate <= to_date(T_DATE,'DD/MM/YYYY' )
and tl.txdate >= to_date(F_DATE,'DD/MM/YYYY' )
AND nvl(TL.tlID,'-') LIKE V_STRMAKER
AND nvl(TL.offid,'-') LIKE V_STRCHECKER
AND tl.tltxcd IN('8878','8879')
AND TL.tltxcd LIKE V_STRTLTXCD
and (tl.brid like V_STRBRID or instr(V_STRBRID,tl.brid) <> 0)
AND (af.brid LIKE V_STRBRID or instr(V_STRBRID,af.brid) <> 0 )
and tl.deltd <>'Y'
and nvl(cf.custodycd,'-')<>'017P000002' -- Sinh fixed (old: cf.custodycd<>'017P000002')
and cf.custodycd like V_STRCUSTOCYCD
and se.txcd in ('0019','0020') -- Fix 8879 8879 bi trung records CHANGE ID 118
UNION ALL
SELECT cf.custodycd,TL.tltxcd , TL.txnum,TL.TXDATE,TL.BUSDATE, SE.namt, TL.MSGACCT MSGACCT, to_char(TL.TXDESC) txdesc ,TLPR1.TLNAME MAKER ,TLPR2.TLNAME CHECKER ,AL.CDCONTENT STATUS
FROM TLLOGALL TL, SETRANA SE, ALLCODE AL ,TLPROFILES TLPR1 ,TLPROFILES TLPR2,afmast af, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf
WHERE tl.txnum = se.txnum
AND tl.txdate = se.txdate
AND AL.CDTYPE ='SY' AND AL.CDNAME ='TXSTATUS' AND AL.CDVAL =TL.TXSTATUS
AND  TLPR1.TLID(+) =TL.TLID  AND TLPR2.TLID (+)=TL.OFFID
and af.acctno(+)= substr(TL.MSGACCT,1,10)
and cf.custid (+)= af.custid
and tl.txdate <= to_date(T_DATE,'DD/MM/YYYY' )
and tl.txdate >= to_date(F_DATE,'DD/MM/YYYY' )
AND nvl(TL.tlID,'-') LIKE V_STRMAKER
AND nvl(TL.offid,'-') LIKE V_STRCHECKER
AND tl.tltxcd IN('8878','8879')
AND TL.tltxcd LIKE V_STRTLTXCD
and (tl.brid like V_STRBRID or instr(V_STRBRID,tl.brid) <> 0)
AND (af.brid LIKE V_STRBRID or instr(V_STRBRID,af.brid) <> 0 )
and tl.deltd <>'Y'
and nvl(cf.custodycd,'-')<>'017P000002' -- Sinh fixed (old: cf.custodycd<>'017P000002')
and cf.custodycd like V_STRCUSTOCYCD
and se.txcd in ('0019','0020')  -- Fix 8879 8879 bi trung records CHANGE ID 118

UNION ALL -- Diem Huong added
SELECT tci.custodycd,tci.TLTXCD ,TO_CHAR(tci.TXNUM) TXNUM
,tci.TXDATE,tci.BUSDATE ,nvl(tci.namt,0) namt,substr(tci.dfacctno,1,10) MSGACCT,
to_char(decode(tci.txtype,'D',N'Phi ung truoc',tci.txdesc)) txdesc
--tci.txdesc

,TLPR1.TLNAME MAKER ,TLPR2.TLNAME CHECKER ,AL.CDCONTENT STATUS
from vw_CITRAN_gen tci,tlprofiles tlpr1, tlprofiles tlpr2, allcode al, afmast af, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf
where  tci.busdate between to_date(F_DATE,'DD/MM/YYYY' ) and to_date(T_DATE,'DD/MM/YYYY' )
       and tci.field = 'BALANCE'
       and tci.tltxcd =1153
       and tci.txtype='D'
       and al.cdtype='SY' and al.cdname='TXSTATUS' and al.cdval =1
       and  TLPR1.TLID(+) =tci.TLID  AND TLPR2.TLID (+)=tci.OFFID
       and af.acctno(+)= substr(tci.dfacctno,1,10)
       and cf.custid (+)= af.custid
       AND nvl(tci.tlID,'-') LIKE V_STRMAKER
       AND nvl(tci.offid,'-') LIKE V_STRCHECKER
       AND tci.tltxcd LIKE V_STRTLTXCD
       and (tci.brid like V_STRBRID or instr(V_STRBRID,tci.brid) <> 0)
       AND (af.brid LIKE V_STRBRID or instr(V_STRBRID,af.brid) <> 0 )
       and tci.deltd <>'Y'
       and nvl(tci.custodycd,'-')<>'017P000002' -- Sinh fixed (old: tci.custodycd<>'017P000002')
       and tci.custodycd like V_STRCUSTOCYCD

 -- Sinh added (1-nov-2010)
UNION ALL
SELECT cf.custodycd,TL.TLTXCD ,TL.TXNUM,TL.TXDATE,TL.BUSDATE ,TL.MSGAMT,substr(TL.MSGACCT,1,10) MSGACCT, to_char(TL.TXDESC) txdesc ,TLPR1.TLNAME MAKER ,TLPR2.TLNAME CHECKER ,AL.CDCONTENT STATUS
FROM TLLOG TL,ALLCODE AL ,TLPROFILES TLPR1 ,TLPROFILES TLPR2,afmast af, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf, VW_DFMAST_ALL DF
WHERE AL.CDTYPE ='SY' AND AL.CDNAME ='TXSTATUS' AND AL.CDVAL =TL.TXSTATUS
    AND  TLPR1.TLID =TL.TLID  AND TLPR2.TLID =TL.OFFID
    and af.acctno(+)= DF.AFACCTNO
    AND DF.LNACCTNO = TL.MSGACCT
    and cf.custid (+)= af.custid
    and tl.txdate between to_date(F_DATE,'DD/MM/YYYY' ) and to_date(T_DATE,'DD/MM/YYYY' )
    AND nvl(TL.tlID,'-') LIKE V_STRMAKER
    AND nvl(TL.offid,'-') LIKE V_STRCHECKER
    AND TL.tltxcd LIKE V_STRTLTXCD
    and (tl.brid like V_STRBRID or instr(V_STRBRID,tl.brid) <> 0)
    AND (af.brid LIKE V_STRBRID or instr(V_STRBRID,af.brid) <> 0 )
    And Tl.Deltd <>'Y'
    and TL.tltxcd IN  ('5573')
    and nvl(cf.custodycd,'-') <>'017P000002'
    and cf.custodycd like V_STRCUSTOCYCD
UNION ALL
SELECT cf.custodycd,TL.TLTXCD ,TL.TXNUM,TL.TXDATE,TL.BUSDATE ,TL.MSGAMT,substr(TL.MSGACCT,1,10) MSGACCT, to_char(TL.TXDESC) txdesc ,TLPR1.TLNAME MAKER ,TLPR2.TLNAME CHECKER ,AL.CDCONTENT STATUS
FROM TLLOGALL TL,ALLCODE AL ,TLPROFILES TLPR1 ,TLPROFILES TLPR2,afmast af, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf, VW_DFMAST_ALL DF
WHERE AL.CDTYPE ='SY' AND AL.CDNAME ='TXSTATUS' AND AL.CDVAL =TL.TXSTATUS
    AND  TLPR1.TLID =TL.TLID  AND TLPR2.TLID =TL.OFFID
    and af.acctno(+)= DF.AFACCTNO
    AND DF.LNACCTNO = TL.MSGACCT
    and cf.custid (+)= af.custid
    and tl.txdate between to_date(F_DATE,'DD/MM/YYYY' ) and to_date(T_DATE,'DD/MM/YYYY' )
    AND nvl(TL.tlID,'-') LIKE V_STRMAKER
    AND nvl(TL.offid,'-') LIKE V_STRCHECKER
    AND TL.tltxcd LIKE V_STRTLTXCD
    and (tl.brid like V_STRBRID or instr(V_STRBRID,tl.brid) <> 0)
    AND (af.brid LIKE V_STRBRID or instr(V_STRBRID,af.brid) <> 0 )
    And Tl.Deltd <>'Y'
    and TL.tltxcd IN  ('5573')
    and nvl(cf.custodycd,'-') <>'017P000002'
    and cf.custodycd like V_STRCUSTOCYCD
 -- End, Sinh added (1-nov-2010)

union all
select tr.custodycd, to_char(tr.tltxcd), to_char(tr.TXNUM) , tr.txdate, tr.busdate , tr.namt, to_char(tr.acctno) MSGACCT , to_char(tr.trdesc) txdesc  , TLPR1.TLNAME MAKER ,TLPR2.TLNAME CHECKER ,'Hoan tat' STATUS
--select cf.custodycd, tl.tltxcd ,tl.txnum, tl.txdate, tl.busdate, tlf.nvalue MSGAMT, substr(TL.MSGACCT,1,10) MSGACCT, to_char(TL.TXDESC) , TLPR1.TLNAME MAKER ,TLPR2.TLNAME CHECKER ,to_char(to_char(AL.CDCONTENT)) STATUS
from vw_citran_gen tr ,TLPROFILES TLPR1 ,TLPROFILES TLPR2, afmast af
where tr.tltxcd = '3350'
aND  TLPR1.TLID =tr.TLID  AND TLPR2.TLID(+) =tr.OFFID
and tr.txdate between to_date(F_DATE,'DD/MM/YYYY' ) and to_date(T_DATE,'DD/MM/YYYY' )
    AND nvl(tr.tlID,'-') LIKE V_STRMAKER
    AND nvl(tr.offid,'-') LIKE V_STRCHECKER
    AND tr.tltxcd LIKE V_STRTLTXCD
    And tr.Deltd <>'Y'
    and tr.tltxcd IN  ('3350')
    and tr.custodycd <>'017P000002'
    and tr.custodycd like V_STRCUSTOCYCD
    AND tr.acctno=af.acctno
    and (tr.brid like V_STRBRID or instr(V_STRBRID,tr.brid) <> 0)
    AND (af.brid LIKE V_STRBRID or instr(V_STRBRID,af.brid) <> 0 )
    and tr.namt > 0
    and field = 'BALANCE'
    and txtype = 'D'
union all
SELECT cf.custodycd,TL.TLTXCD ,TL.TXNUM,TL.TXDATE,TL.BUSDATE ,TL.MSGAMT, od.afacctno MSGACCT, to_char(TL.TXDESC) txdesc ,TLPR1.TLNAME MAKER ,TLPR2.TLNAME CHECKER ,AL.CDCONTENT STATUS
FROM VW_TLLOG_ALL TL,ALLCODE AL ,TLPROFILES TLPR1 ,TLPROFILES TLPR2,afmast af, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf,
    (select * from vw_odmast_all where txdate <= to_date(T_DATE,'DD/MM/YYYY' ) and txdate >= to_date(F_DATE,'DD/MM/YYYY' )) od
WHERE AL.CDTYPE ='SY' AND AL.CDNAME ='TXSTATUS' AND AL.CDVAL =TL.TXSTATUS
AND  TLPR1.TLID(+) =TL.TLID  AND TLPR2.TLID (+)=TL.OFFID
and (af.acctno = substr(TL.MSGACCT,1,10) or od.orderid = TL.MSGACCT)
and af.acctno = od.afacctno
and cf.custid = af.custid
and tl.txdate <= to_date(T_DATE,'DD/MM/YYYY' )
and tl.txdate >= to_date(F_DATE,'DD/MM/YYYY' )
AND nvl(TL.tlID,'-') LIKE V_STRMAKER
AND nvl(TL.offid,'-') LIKE V_STRCHECKER
AND TL.tltxcd LIKE V_STRTLTXCD
and (tl.brid like V_STRBRID or instr(V_STRBRID,tl.brid) <> 0)
and (af.brid LIKE V_STRBRID or instr(V_STRBRID,af.brid) <> 0 )
And Tl.Deltd <>'Y'
and TL.tltxcd in ('8829')
and nvl(cf.custodycd,'-')<>'017P000002'
and cf.custodycd like V_STRCUSTOCYCD
UNION ALL
SELECT cf.custodycd,TL.TLTXCD ,TL.TXNUM,TL.TXDATE,TL.BUSDATE ,TL.MSGAMT,substr(TL.MSGACCT,1,10) MSGACCT, to_char(TL.TXDESC) txdesc ,TLPR1.TLNAME MAKER ,TLPR2.TLNAME CHECKER ,AL.CDCONTENT STATUS
FROM TLLOGALL TL,ALLCODE AL ,TLPROFILES TLPR1 ,TLPROFILES TLPR2, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf
WHERE AL.CDTYPE ='SY' AND AL.CDNAME ='TXSTATUS' AND AL.CDVAL =TL.TXSTATUS
AND  TLPR1.TLID(+) =TL.TLID  AND TLPR2.TLID (+)=TL.OFFID
and cf.custodycd(+)= substr(TL.MSGACCT,1,10)
and tl.txdate <= to_date(T_DATE,'DD/MM/YYYY' )
and tl.txdate >= to_date(F_DATE,'DD/MM/YYYY' )
AND nvl(TL.tlID,'-') LIKE V_STRMAKER
AND nvl(TL.offid,'-') LIKE V_STRCHECKER
AND TL.tltxcd LIKE V_STRTLTXCD
and (tl.brid like V_STRBRID or instr(V_STRBRID,tl.brid) <> 0)
AND (cf.brid LIKE V_STRBRID or instr(V_STRBRID,cf.brid) <> 0 )
And Tl.Deltd <>'Y'
and TL.tltxcd = '0025'
and nvl(cf.custodycd,'-')<>'017P000002' -- Sinh fixed (old: cf.custodycd<>'017P000002')
and cf.custodycd like V_STRCUSTOCYCD


/*
UNION ALL
SELECT distinct TL.tltxcd , TL.txnum,TL.TXDATE,TL.BUSDATE, tl.msgamt,  af.acctno MSGACCT,
        TL.TXDESC ,TLPR1.TLNAME MAKER ,TLPR2.TLNAME CHECKER ,AL.CDCONTENT STATUS
FROM TLLOGALL TL, ALLCODE AL ,TLPROFILES TLPR1 ,TLPROFILES TLPR2, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf, afmast af, iodhist io
WHERE  AL.CDTYPE ='SY' AND AL.CDNAME ='TXSTATUS' AND AL.CDVAL =TL.TXSTATUS
AND  TLPR1.TLID(+) =TL.TLID  AND TLPR2.TLID (+)=TL.OFFID
AND tl.txnum = io.txnum
AND tl.txdate = io.txdate
AND af.custid = cf.custid
AND cf.custodycd = io.custodycd
and tl.txdate <= to_date(T_DATE,'DD/MM/YYYY' )
and tl.txdate >= to_date(F_DATE,'DD/MM/YYYY' )
AND nvl(TL.tlID,'-') LIKE '%%'
AND nvl(TL.offid,'-') LIKE '%%'
AND tl.tltxcd IN('8804', '8809','8822','8824','9900')
AND tl.deltd <> 'Y'
AND cf.status = 'A'
UNION ALL
SELECT distinct TL.tltxcd , TL.txnum,TL.TXDATE,TL.BUSDATE, tl.msgamt,  af.acctno MSGACCT,
        TL.TXDESC ,TLPR1.TLNAME MAKER ,TLPR2.TLNAME CHECKER ,AL.CDCONTENT STATUS
FROM TLLOG TL, ALLCODE AL ,TLPROFILES TLPR1 ,TLPROFILES TLPR2, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf, afmast af, iod io
WHERE  AL.CDTYPE ='SY' AND AL.CDNAME ='TXSTATUS' AND AL.CDVAL =TL.TXSTATUS
AND  TLPR1.TLID(+) =TL.TLID  AND TLPR2.TLID (+)=TL.OFFID
AND tl.txnum = io.txnum
AND tl.txdate = io.txdate
AND af.custid = cf.custid
AND cf.custodycd = io.custodycd
and tl.txdate <= to_date(T_DATE,'DD/MM/YYYY' )
and tl.txdate >= to_date(F_DATE,'DD/MM/YYYY' )
AND nvl(TL.tlID,'-') LIKE '%%'
AND nvl(TL.offid,'-') LIKE '%%'
AND tl.tltxcd IN('8804', '8809','8822','8824','9900')
AND tl.deltd <> 'Y'
AND cf.status = 'A'*/
)
ORDER BY tltxcd,BUSDATE,TXNUM,MAKER
;

EXCEPTION
   WHEN OTHERS
   THEN

      RETURN;
End;
 
 
 
 
/
