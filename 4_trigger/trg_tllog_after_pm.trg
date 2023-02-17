SET DEFINE OFF;
CREATE OR REPLACE TRIGGER TRG_TLLOG_AFTER_PM 
 AFTER
  INSERT OR UPDATE
 ON tllog
REFERENCING NEW AS NEW OLD AS OLD
 FOR EACH ROW
declare pkgctx     plog.log_ctx;
     l_count number;
     l_delete varchar2(1);

     l_tltxcd varchar2(10);
     l_txnum varchar2(10);
     l_txdate Date;
     l_msgacct varchar2(50);
     
     l_orstatus varchar2(1);
     l_orderid varchar2(50);
     l_catype   varchar2(10);
begin

   Select count(txcode) into l_count from pmtxmap where tltxcd = :NEW.tltxcd OR tltxcd = :OLD.tltxcd;

   if l_count > 0 then
        l_delete := 'X';

        if UPDATING then
            if :NEW.DELTD = 'Y' AND :OLD.DELTD <> 'Y' AND :NEW.TXSTATUS IN ('7', '8','9')  then
                l_delete := 'Y';
            end if;
        ELSIF INSERTING then
            l_delete := 'N';
        end if;

        if l_delete = 'Y' then
            l_txnum := :OLD.txnum;
            l_txdate := :OLD.txdate;
            l_msgacct := :OLD.msgacct;
        else
            l_txnum := :NEW.txnum;
            l_txdate := :NEW.txdate;
            l_msgacct := :NEW.msgacct;
        end if;
        select nvl(max(catype),'0000') into l_catype from camast where camastid = l_msgacct;
        if l_delete <> 'X' then
            --Rieng 2 giao dich 8877 va 8876 se khong insert vi da day sang PM khi duyet lenh
            /*if :NEW.tltxcd not in ('2242','3375','8877','8876','3370') then
                Insert into pmtxmsg(autoid, txnum, txdate, status, isdelete)
                Select seq_pmtxmsg_id.NEXTVAL, l_txnum, l_txdate, 'P', l_delete From dual
                Where Exists (Select tlf.cvalue from TLLOGFLD TLF, fldmaster fld, afmast af
                    Where TLF.txnum = l_txnum And TLF.txdate = l_txdate
                        And TLF.fldcd = fld.fldname
                        And :NEW.tltxcd = fld.objname
                        And tlf.cvalue = af.acctno
                        And af.ispm = 'Y'
                    UNION ALL Select af.acctno From afmast af Where l_msgacct = af.acctno And af.ispm = 'Y');
            else*/
                IF :NEW.tltxcd = '3375' and nvl(l_catype,'0000') not in ('014','009','010','011','021') then
                    Insert into pmtxmsg(autoid, txnum, txdate, status, isdelete)
                    Select seq_pmtxmsg_id.NEXTVAL, l_txnum, l_txdate, 'P', l_delete From dual;
                    /*Where Exists (Select TLF.cvalue From TLLOGFLD TLF, caschd cas, afmast af
                        Where tlf.cvalue = cas.camastid
                            And cas.afacctno = af.acctno
                            And af.ispm = 'Y'
                            And TLF.txdate = :NEW.txdate And TLF.txnum = :NEW.txnum
                        UNION ALL Select af.acctno From afmast af Where :NEW.msgacct = af.acctno And af.ispm = 'Y');*/
                ELSIF :NEW.tltxcd IN ('3371','3322') and nvl(l_catype,'0000') in ('009','010','011','021') then
                    Insert into pmtxmsg(autoid, txnum, txdate, status, isdelete)
                    Select seq_pmtxmsg_id.NEXTVAL, l_txnum, l_txdate, 'P', l_delete From dual;
                ELSIF :NEW.tltxcd IN ('3370') and nvl(l_catype,'0000') not in ('014','009','010','011','021') then
                    Insert into pmtxmsg(autoid, txnum, txdate, status, isdelete)
                    Select seq_pmtxmsg_id.NEXTVAL, l_txnum, l_txdate, 'P', l_delete From dual
                    Where Exists (Select TLF.cvalue From TLLOGFLD TLF, caschd cas, afmast af
                        Where tlf.cvalue = cas.camastid
                            And cas.afacctno = af.acctno
                            And af.ispm = 'Y'
                            And TLF.txdate = l_txdate And TLF.txnum = l_txnum
                        UNION ALL Select af.acctno From afmast af Where l_msgacct = af.acctno And af.ispm = 'Y');
                ELSIF :NEW.tltxcd = '2242' then
                    Insert into pmtxmsg(autoid, txnum, txdate, status, isdelete)
                    Select seq_pmtxmsg_id.NEXTVAL, l_txnum, l_txdate, 'P', l_delete From dual
                    Where Exists (Select TLF.cvalue From TLLOGFLD TLF, afmast af
                        Where tlf.cvalue = af.acctno
                            And af.ispm = 'Y'
                            And TLF.txdate = l_txdate And TLF.txnum = l_txnum
                        UNION ALL Select af.acctno From afmast af Where l_msgacct = af.acctno And af.ispm = 'Y');
                ELSIF :NEW.tltxcd IN ('8804','8807','8808','8810','8811','8890','8891') then
                    Insert into pmtxmsg(autoid, txnum, txdate, status, isdelete)
                    Select seq_pmtxmsg_id.NEXTVAL, l_txnum, l_txdate, 'P', l_delete From dual
                    Where Exists (Select od.afacctno from odmast od, afmast af
                        where od.orderid = :NEW.msgacct
                        and od.afacctno = af.acctno and af.ispm = 'Y');
                /*ELSIF :NEW.tltxcd IN ('8882','8883') then
                    Select cvalue into l_orderid from tllogfld where txnum = :NEW.txnum And fldcd = '08';
                    Select orstatus into l_orstatus from odmast where orderid = l_orderid;
                    IF l_orstatus = '8' THEN
                        Insert into pmtxmsg(autoid, txnum, txdate, status, isdelete)
                        Select seq_pmtxmsg_id.NEXTVAL, l_txnum, l_txdate, 'P', l_delete From dual
                        Where Exists (Select tlf.cvalue from TLLOGFLD TLF, fldmaster fld, afmast af
                            Where TLF.txnum = l_txnum And TLF.txdate = l_txdate
                                And TLF.fldcd = fld.fldname
                                And :NEW.tltxcd = fld.objname
                                And tlf.cvalue = af.acctno
                                And af.ispm = 'Y'
                            UNION ALL Select af.acctno From afmast af Where l_msgacct = af.acctno And af.ispm = 'Y');
                    END IF;*/
                ELSIF :NEW.tltxcd not in ('8877','8876') Then  --Rieng 2 giao dich 8877 va 8876 se khong insert vi da day sang PM khi duyet lenh
                    Insert into pmtxmsg(autoid, txnum, txdate, status, isdelete)
                    Select seq_pmtxmsg_id.NEXTVAL, l_txnum, l_txdate, 'P', l_delete From dual
                    Where Exists (Select tlf.cvalue from TLLOGFLD TLF, fldmaster fld, afmast af
                        Where TLF.txnum = l_txnum And TLF.txdate = l_txdate
                            And TLF.fldcd = fld.fldname
                            And :NEW.tltxcd = fld.objname
                            And tlf.cvalue = af.acctno
                            And af.ispm = 'Y'
                        UNION ALL Select af.acctno From afmast af Where l_msgacct = af.acctno And af.ispm = 'Y');
            end if;
        end if;

   end if;

exception
  when others then
    plog.error(pkgctx, 'trg_tllog_after_pm: ' || :NEW.tltxcd || '|' || l_txnum || '|' || TO_CHAR(l_txdate));
    plog.error(pkgctx, 'trg_tllog_after_pm: ' || SQLERRM);
    plog.setEndSection(pkgctx, 'trg_tllog_after_pm');
end;
/
