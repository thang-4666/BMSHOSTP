SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "CF2000" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   pv_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2,
   PV_CUSTODYCD     IN       VARCHAR2,
   PV_AFACCTNO      IN       VARCHAR2,
   PV_TLTXCD      IN       VARCHAR2
 )
IS
--
-- PURPOSE: BRIEFLY EXPLAIN THE FUNCTIONALITY OF THE PROCEDURE
--
-- MODIFICATION HISTORY
-- PERSON      DATE       COMMENTS
-- Diennt      30/09/2011 Create
-- ---------   ------     -------------------------------------------
   V_STROPTION        VARCHAR2 (5);       -- A: ALL; B: BRANCH; S: SUB-BRANCH
   V_STRBRID          VARCHAR2 (4);        -- USED WHEN V_NUMOPTION > 0
   V_busdate             DATE;
   V_msgacct0            VARCHAR2 (30);
   V_msgacct            VARCHAR2 (30);
   V_txnum          VARCHAR2 (10);
   V_T_CValue       VARCHAR2 (1000);
   V_F_CValue       VARCHAR2 (1000);
   v_CustodyCD      varchar2(10);
   v_AfAcctno       varchar2(10);
   V_TLTXCD          varchar2(10);
   V_Fillter1   number;
   V_PV_TLTXCD          varchar2(20);
    test    varchar2(1000);
-- DECLARE PROGRAM VARIABLES AS SHOWN ABOVE
CURSOR CURSOR_T
IS
select busdate, msgacct, txnum, T_CValue, TLTXCD
    from Temp_CF2000
    ORDER BY msgacct, busdate, txnum;

BEGIN

   V_STROPTION := OPT;

   IF (V_STROPTION <> 'A') AND (pv_BRID <> 'ALL')
   THEN
      V_STRBRID := pv_BRID;
   ELSE
      V_STRBRID := '%%';
   END IF;

    if PV_CUSTODYCD = 'ALL' or PV_CUSTODYCD is null then
        v_CustodyCD := '%';
    else
        v_CustodyCD := PV_CUSTODYCD;
    end if;

    if PV_AFACCTNO = 'ALL' or PV_AFACCTNO is null then
        v_AFAcctno := '%';
    else
        v_AFAcctno := PV_AFACCTNO;
    end if;

    --- xoa du lieu trong table temp
    delete from Temp_CF2000;
    commit;

    --insert du lieu giao dich 0090 v 0033 vao table temp
    if PV_TLTXCD = 'ALL' or PV_TLTXCD is null then
        INSERT INTO Temp_CF2000 (txnum, txdate, txtime, brid, tlid, offid,
           ovrrqs, chid, chkid, tltxcd, ibt, brid2, tlid2, ccyusage, off_line, deltd, brdate, busdate, txdesc,
           ipaddress, wsname, txstatus, msgsts, ovrsts, batchname, msgamt, msgacct, chktime, offtime, carebygrp,
           F_CValue, T_CValue)
           SELECT tl.txnum, tl.txdate, tl.txtime, tl.brid, tl.tlid, tl.offid,
               tl.ovrrqs, tl.chid, tl.chkid, tl.tltxcd, tl.ibt, tl.brid2, tl.tlid2, tl.ccyusage, tl.off_line, tl.deltd, tl.brdate, tl.busdate, tl.txdesc,
               tl.ipaddress, tl.wsname, tl.txstatus, tl.msgsts, tl.ovrsts, tl.batchname, tl.msgamt, tl.msgacct, tl.chktime, tl.offtime, tl.carebygrp,
                '' F_CValue, tlfld.Cvalue
           from vw_tllog_all tl ,vw_tllogfld_all tlfld, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf
            where tl.txnum = tlfld.txnum and tl.txdate = tlfld.txdate
            and cf.custid = tl.msgacct
            and cf.custodycd like v_CustodyCD
            AND tl.busdate >= to_date(F_DATE,'DD/MM/YYYY' )
            AND tl.busdate <= to_date(T_DATE,'DD/MM/YYYY' )
            and tl.tltxcd in ('0033','0090') and tlfld.fldcd = '15';

        V_Fillter1 := 0;
    else
        INSERT INTO Temp_CF2000 (txnum, txdate, txtime, brid, tlid, offid,
           ovrrqs, chid, chkid, tltxcd, ibt, brid2, tlid2, ccyusage, off_line, deltd, brdate, busdate, txdesc,
           ipaddress, wsname, txstatus, msgsts, ovrsts, batchname, msgamt, msgacct, chktime, offtime, carebygrp,
           F_CValue, T_CValue)
           SELECT tl.txnum, tl.txdate, tl.txtime, tl.brid, tl.tlid, tl.offid,
               tl.ovrrqs, tl.chid, tl.chkid, tl.tltxcd, tl.ibt, tl.brid2, tl.tlid2, tl.ccyusage, tl.off_line, tl.deltd, tl.brdate, tl.busdate, tl.txdesc,
               tl.ipaddress, tl.wsname, tl.txstatus, tl.msgsts, tl.ovrsts, tl.batchname, tl.msgamt, tl.msgacct, tl.chktime, tl.offtime, tl.carebygrp,
                '' F_CValue, tlfld.Cvalue
           from vw_tllog_all tl ,vw_tllogfld_all tlfld, Cfmast cf
            where tl.txnum = tlfld.txnum and tl.txdate = tlfld.txdate
            and cf.custid = tl.msgacct
            and cf.custodycd like v_CustodyCD
            AND tl.busdate >= to_date(F_DATE,'DD/MM/YYYY' )
            AND tl.busdate <= to_date(T_DATE,'DD/MM/YYYY' )
            and tl.tltxcd = PV_TLTXCD and tlfld.fldcd = '15';

        V_Fillter1 := 1;
    end if;




    V_msgacct0 := '';
    V_F_CValue := '';
    open CURSOR_T;
    LOOP
        FETCH CURSOR_T into V_busdate, V_msgacct, V_txnum, V_T_CValue, V_TLTXCD;
        EXIT WHEN CURSOR_T%NOTFOUND;
        IF V_msgacct0 <> V_msgacct and V_TLTXCD = '0033' THEN
            SELECT Cvalue INTO V_F_CValue
            FROM(SELECT tl.busdate, tl.txnum, tlfld.Cvalue
                from vw_tllog_all tl ,vw_tllogfld_all tlfld
                where tl.txnum = tlfld.txnum and tl.txdate = tlfld.txdate
                AND tl.busdate < V_busdate
                AND tl.tltxcd IN ('0090', '0033') and tlfld.fldcd = '15'
                AND tl.msgacct = V_msgacct
                UNION
                SELECT TO_DATE('1/1/1900','DD/MM/YYYY') busdate, '' txnum, '' Cvalue FROM DUAL
                ORDER BY busdate DESC, txnum DESC)
            WHERE ROWNUM <= 1;

        END IF;
        UPDATE Temp_CF2000 SET F_CVALUE = V_F_CValue
        WHERE busdate = V_busdate  AND txnum = V_txnum;


        V_msgacct0 := V_msgacct;
        V_F_CValue := V_T_CValue;
    END LOOP;

    CLOSE CURSOR_T;

OPEN PV_REFCURSOR
  FOR
  SELECT ID, maker_id, maker_dt,
         approve_id, approve_dt, column_name, from_value, to_value, action_flag,
         Field_name, ghi_chu, custodycd, cf_idcode,
         tltxcd, maker_time
  FROM(
  SELECT af.acctno ID, tl1.tlfullname maker_id, ma.maker_dt maker_dt,
             tl2.tlfullname approve_id, ma.approve_dt, ma.column_name, from_value from_value, to_value, ma.action_flag,
             afn.caption Field_name,
             Case when ma.column_name = 'ACNIDCODE' AND cf.idcode <> to_value THEN
                'Khac chu tai khoan'
             ELSE
                ''
             END ghi_chu, cf.custodycd, cf.idcode cf_idcode,
             '' tltxcd, ma.maker_time
      FROM maintain_log ma, afmast af, tlprofiles tl1, tlprofiles tl2, Cfmast cf,
            (select fldname, caption from fldmaster  where obJname  = 'SA.CFOTHERACC') afn
      WHERE ma.table_name='AFMAST'
        and ma.action_flag in ('EDIT', 'ADD')
        and ma.child_table_name = 'CFOTHERACC'
        and ma.column_name in('BANKACC','BANKACNAME','BANKNAME','CITYBANK','ACNIDPLACE','ACNIDCODE','ACNIDDATE','ACNIDPLACE')
        and af.acctno=substr(trim(ma.record_key),11,10)
        and tl1.tlid(+)=ma.maker_id
        and tl2.tlid(+)=ma.approve_id
        AND CF.custid (+)= af.custid
        and afn.fldname(+)=ma.column_name
        AND ma.maker_dt <= to_date(T_DATE,'DD/MM/YYYY' )
        AND ma.maker_dt >= to_date(F_DATE,'DD/MM/YYYY' )
        and af.acctno like v_AFAcctno
        and cf.custodycd like v_CustodyCD
        and 0 = V_Fillter1
        --order by af.acctno

      UNiON ALL --email tieu khoan
      SELECT af.acctno ID, tl1.tlfullname maker_id, ma.maker_dt maker_dt,
             tl2.tlfullname approve_id, ma.approve_dt, ma.column_name, from_value from_value, to_value, ma.action_flag,
             afn.caption || '-Tieu khoan' Field_name, '' ghi_chu, cf.custodycd, cf.idcode cf_idcode,
             '' tltxcd, ma.maker_time
      FROM maintain_log ma, afmast af, tlprofiles tl1, tlprofiles tl2, Cfmast cf,
            (select fldname, caption from fldmaster  where obJname  = 'CF.AFMAST') afn
      WHERE ma.table_name='AFMAST'
        and ma.action_flag in ('EDIT', 'ADD')
        and ma.column_name in('EMAIL')
        and af.acctno=substr(trim(ma.record_key),11,10)
        and tl1.tlid(+)=ma.maker_id
        and tl2.tlid(+)=ma.approve_id
        AND CF.custid (+)= af.custid
        and afn.fldname(+)=ma.column_name
        AND ma.maker_dt <= to_date(T_DATE,'DD/MM/YYYY' )
        AND ma.maker_dt >= to_date(F_DATE,'DD/MM/YYYY' )
        and af.acctno like v_AFAcctno
        and cf.custodycd like v_CustodyCD
        and 0 = V_Fillter1

      UNiON ALL --email khach hang
      SELECT '' ID, tl1.tlfullname maker_id, ma.maker_dt maker_dt,
             tl2.tlfullname approve_id, ma.approve_dt, ma.column_name, from_value from_value, to_value, ma.action_flag,
             afn.caption || '-Khach hang' Field_name, '' ghi_chu, cf.custodycd, cf.idcode cf_idcode,
             '' tltxcd, ma.maker_time
      FROM maintain_log ma, tlprofiles tl1, tlprofiles tl2, Cfmast cf,
            (select fldname, caption from fldmaster  where obJname  = 'CF.CFMAST') afn
      WHERE ma.table_name='CFMAST'
        and ma.action_flag in ('EDIT', 'ADD')
        and ma.column_name in('EMAIL')
        and cf.custid=substr(trim(ma.record_key),11,10)
        and tl1.tlid(+)=ma.maker_id
        and tl2.tlid(+)=ma.approve_id
        and afn.fldname(+)=ma.column_name
        AND ma.maker_dt <= to_date(T_DATE,'DD/MM/YYYY' )
        AND ma.maker_dt >= to_date(F_DATE,'DD/MM/YYYY' )
        and cf.custodycd like v_CustodyCD
        and 0 = V_Fillter1

     UNiON ALL --giao dich 0090, 0033

      SELECT '' ID, tl1.tlfullname maker_id, ma.txdate maker_dt,
             tl2.tlfullname approve_id, ma.busdate approve_dt, 'Token Id' column_name, ma.f_cvalue from_value,
             ma.t_cvalue to_value,
             decode(ma.tltxcd, '0090', 'ADD', '0033', 'EDIT', '') action_flag,
             'So dt token' Field_name, '' ghi_chu, cf.custodycd, cf.idcode cf_idcode,
             ma.tltxcd, ma.txtime maker_time
      FROM Temp_CF2000 ma, tlprofiles tl1, tlprofiles tl2, Cfmast cf
      WHERE cf.custid=ma.msgacct
        and tl1.tlid(+)=ma.tlid
        and tl2.tlid(+)=ma.offid
       )


  ORDER BY maker_dt ASC, maker_time DESC

;

EXCEPTION
   WHEN OTHERS
   THEN

      RETURN;
End;

 
 
 
 
/
