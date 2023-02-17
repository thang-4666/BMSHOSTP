SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "LOAD_TEST_ORDER" (
   P_Afacctno     IN       VARCHAR2,  -- So tieu khoan dat lenh
   P_BORS         IN       VARCHAR2,  -- Mua hay ban B,S
   P_PRICETYPE    IN       VARCHAR2,  -- LO,ATO,ATC
   P_strSymbol    IN       VARCHAR2,
   P_Qtty         IN       NUMERIC ,
   P_Soluonglenh  IN       NUMERIC ,
   P_strError   out       VARCHAR2
)
IS
--
-- PURPOSE: DAY LENH LOAD TEST SAN HOSE
-- MODIFICATION HISTORY
-- PERSON      DATE    COMMENTS
-- QUYETKD   11-Dec-01  CREATED
-- ---------   ------  -------------------------------------------
------------- Khai bao tham so dat lenh -----------------------
v_order_id varchar(20);
v_txnum    varchar(20);
v_txdate date;
v_strSymbol varchar2(500):=P_strSymbol;
v_Qtty Number(10):=P_Qtty;
v_Afacctno varchar2(100):=P_Afacctno;
v_CustodyCD varchar2(200);
v_Soluonglenh number(10):=P_Soluonglenh;
v_PRICETYPE varchar2(10):=P_PRICETYPE ; --'LO'; --ATO/ATC
v_BORS varchar2(10):=P_BORS; --B: Buy or S: Sell
v_EXECTYPE varchar2(10);
i number(10);
v_TEST varchar2(1000);
---------------------------------------------------------------


TYPE EmpCurTyp IS REF CURSOR;
Ho_symbol EmpCurTyp;
symbol securities_info.symbol%TYPE;
price securities_info.CEILINGPRICE%TYPE;
codeid securities_info.codeid%TYPE;


BEGIN
---------- Phan Dat lenh -------------------------
--Lay so HD

If v_Bors ='S' then
 v_EXECTYPE:='NS';
Else
  v_EXECTYPE:='NB';
End if;


Begin
Select custodycd into v_CustodyCD from cfmast
where custid in (select custid from afmast where acctno =v_Afacctno and Status='A');
Exception when others then
 P_strError:= 'So tai khoan khong hop le '|| v_Afacctno ;
 Return;
End;


v_TEST:='SELECT symbol,  CEILINGPRICE, codeid  FROM  securities_info WHERE symbol in ' || P_strSymbol  || ' and decode(substr(''' || v_CustodyCD ||''',4,1),''F'',current_room,' || to_char(v_Qtty+1) || ')>' || to_Char(v_Qtty) ;
i:=0;

WHILE i < v_Soluonglenh

LOOP
OPEN Ho_symbol FOR
 v_TEST;
LOOP

FETCH Ho_symbol into symbol, price,codeid;

EXIT WHEN Ho_symbol%NOTFOUND or i=v_Soluonglenh;

 INSERT INTO log_err
                  (id,date_log, POSITION, text)
           VALUES ( seq_log_err.NEXTVAL,SYSDATE, 'Load test lenh thu ' || i,symbol);
           commit;
  --------------------DAT LENH ------------------------------
    i:=i+1;
      SELECT to_date(VARVALUE,'dd/mm/yyyy') INTO v_txdate FROM sysvar WHERE VARNAME='CURRDATE';
      SELECT '0001'||to_char(v_txdate,'ddmmyy')||lpad(SEQ_ODMAST.NEXTVAL,6,'0') INTO v_order_id FROM dual;
      SELECT '0001'||lpad(SEQ_TXNUM.NEXTVAL,6,'0') INTO v_txnum FROM dual;
      dbms_output.put_line('v_order_id = '||v_order_id);
      dbms_output.put_line('v_txnum = '||v_txnum);

        INSERT INTO tllog
                    (autoid, txnum,
                     txdate, txtime, brid,
                     tlid, offid, ovrrqs, chid, chkid, tltxcd, ibt, brid2, tlid2,
                     ccyusage, txstatus, msgacct, msgamt, chktime, offtime, off_line,
                     deltd, brdate,
                     busdate, msgsts, ovrsts, ipaddress,
                     wsname, batchname,
                     txdesc
                    )
             VALUES (seq_tllog.NEXTVAL, v_txnum,
                     v_txdate, '16:26:20', '0001',
                     '0001', '', '', '', '', '8876', '', '', '',
                     '00', '1', v_afacctno, price, '', '', 'N',
                     'N', v_txdate,
                     v_txdate, '0', '0', '10.26.0.253',
                     'thanh_fss', 'DAY',
                     v_afacctno||'.Nguy?n Vu Th�.NB.'||symbol||'.10.105'
                    );
        INSERT INTO tllogfld
                    (autoid, txnum,
                     txdate, fldcd, cvalue, nvalue
                    )
             VALUES (seq_tllogfld.NEXTVAL, v_txnum,
                     v_txdate, '32', 'A', 0
                    );
        INSERT INTO tllogfld
                    (autoid, txnum,
                     txdate, fldcd, cvalue, nvalue
                    )
             VALUES (seq_tllogfld.NEXTVAL, v_txnum,
                     v_txdate, '31', 'A', 0
                    );
        INSERT INTO tllogfld
                    (autoid, txnum,
                     txdate, fldcd, cvalue, nvalue
                    )
             VALUES (seq_tllogfld.NEXTVAL, v_txnum,
                     v_txdate, '33', 'A', 0
                    );
        INSERT INTO tllogfld
                    (autoid, txnum,
                     txdate, fldcd, cvalue, nvalue
                    )
             VALUES (seq_tllogfld.NEXTVAL, v_txnum,
                     v_txdate, '97', 'A', 0
                    );
        INSERT INTO tllogfld
                    (autoid, txnum,
                     txdate, fldcd, cvalue, nvalue
                    )
             VALUES (seq_tllogfld.NEXTVAL, v_txnum,
                     v_txdate, '98', '', 1000
                    );
        INSERT INTO tllogfld
                    (autoid, txnum,
                     txdate, fldcd, cvalue, nvalue
                    )
             VALUES (seq_tllogfld.NEXTVAL, v_txnum,
                     v_txdate, '99', '', 100
                    );
        INSERT INTO tllogfld
                    (autoid, txnum,
                     txdate, fldcd,
                     cvalue, nvalue
                    )
             VALUES (seq_tllogfld.NEXTVAL, v_txnum,
                     v_txdate, '30',
                     v_afacctno||'.LOAD TEST.'|| v_EXECTYPE || '.' || symbol, 0
                    );
        INSERT INTO tllogfld
                    (autoid, txnum,
                     txdate, fldcd, cvalue, nvalue
                    )
             VALUES (seq_tllogfld.NEXTVAL, v_txnum,
                     v_txdate, '04', '0001130808004324', 0
                    );
        INSERT INTO tllogfld
                    (autoid, txnum,
                     txdate, fldcd, cvalue, nvalue
                    )
             VALUES (seq_tllogfld.NEXTVAL, v_txnum,
                     v_txdate, '29', 'C', 0
                    );
        INSERT INTO tllogfld
                    (autoid, txnum,
                     txdate, fldcd, cvalue, nvalue
                    )
             VALUES (seq_tllogfld.NEXTVAL, v_txnum,
                     v_txdate, '28', 'P', 0
                    );
        INSERT INTO tllogfld
                    (autoid, txnum,
                     txdate, fldcd, cvalue, nvalue
                    )
             VALUES (seq_tllogfld.NEXTVAL, v_txnum,
                     v_txdate, '14', '', 0
                    );
        INSERT INTO tllogfld
                    (autoid, txnum,
                     txdate, fldcd, cvalue, nvalue
                    )
             VALUES (seq_tllogfld.NEXTVAL, v_txnum,
                     v_txdate, '13', '', 100
                    );
        INSERT INTO tllogfld
                    (autoid, txnum,
                     txdate, fldcd, cvalue, nvalue
                    )
             VALUES (seq_tllogfld.NEXTVAL, v_txnum,
                     v_txdate, '12', '', 10
                    );
        INSERT INTO tllogfld
                    (autoid, txnum,
                     txdate, fldcd, cvalue, nvalue
                    )
             VALUES (seq_tllogfld.NEXTVAL, v_txnum,
                     v_txdate, '11', '', 43
                    );
        INSERT INTO tllogfld
                    (autoid, txnum,
                     txdate, fldcd, cvalue, nvalue
                    )
             VALUES (seq_tllogfld.NEXTVAL, v_txnum,
                     v_txdate, '27', P_PRICETYPE, 0
                    );
        INSERT INTO tllogfld
                    (autoid, txnum,
                     txdate, fldcd, cvalue, nvalue
                    )
             VALUES (seq_tllogfld.NEXTVAL, v_txnum,
                     v_txdate, '26', 'B', 0
                    );
        INSERT INTO tllogfld
                    (autoid, txnum,
                     txdate, fldcd, cvalue, nvalue
                    )
             VALUES (seq_tllogfld.NEXTVAL, v_txnum,
                     v_txdate, '10', '', 3
                    );
        INSERT INTO tllogfld
                    (autoid, txnum,
                     txdate, fldcd, cvalue, nvalue
                    )
             VALUES (seq_tllogfld.NEXTVAL, v_txnum,
                     v_txdate, '25', 'T', 0
                    );
        INSERT INTO tllogfld
                    (autoid, txnum,
                     txdate, fldcd, cvalue, nvalue
                    )
             VALUES (seq_tllogfld.NEXTVAL, v_txnum,
                     v_txdate, '24', 'N', 0
                    );
        INSERT INTO tllogfld
                    (autoid, txnum,
                     txdate, fldcd, cvalue, nvalue
                    )
             VALUES (seq_tllogfld.NEXTVAL, v_txnum,
                     v_txdate, '23', 'N', 0
                    );
        INSERT INTO tllogfld
                    (autoid, txnum,
                     txdate, fldcd, cvalue, nvalue
                    )
             VALUES (seq_tllogfld.NEXTVAL, v_txnum,
                     v_txdate, '22', 'NB', 0
                    );
        INSERT INTO tllogfld
                    (autoid, txnum,
                     txdate, fldcd, cvalue, nvalue
                    )
             VALUES (seq_tllogfld.NEXTVAL, v_txnum,
                     v_txdate, '21', v_txdate, 0
                    );
        INSERT INTO tllogfld
                    (autoid, txnum,
                     txdate, fldcd, cvalue, nvalue
                    )
             VALUES (seq_tllogfld.NEXTVAL, v_txnum,
                     v_txdate, '20', 'T', 0
                    );
        INSERT INTO tllogfld
                    (autoid, txnum,
                     txdate, fldcd, cvalue, nvalue
                    )
             VALUES (seq_tllogfld.NEXTVAL, v_txnum,
                     v_txdate, '50', v_afacctno, 0
                    );
        INSERT INTO tllogfld
                    (autoid, txnum,
                     txdate, fldcd, cvalue, nvalue
                    )
             VALUES (seq_tllogfld.NEXTVAL, v_txnum,
                     v_txdate, '03', v_afacctno, 0
                    );
        INSERT INTO tllogfld
                    (autoid, txnum,
                     txdate, fldcd, cvalue, nvalue
                    )
             VALUES (seq_tllogfld.NEXTVAL, v_txnum,
                     v_txdate, '02', '0001', 0
                    );
        INSERT INTO tllogfld
                    (autoid, txnum,
                     txdate, fldcd, cvalue, nvalue
                    )
             VALUES (seq_tllogfld.NEXTVAL, v_txnum,
                     v_txdate, '01', codeid, 0
                    );
        UPDATE cimast
           SET balance = balance - (price),
               bamt = bamt + (price),
               lastdate = v_txdate
         WHERE acctno = v_afacctno;
        INSERT INTO citran
                    (acctno, txnum,
                     txdate, txcd, namt, camt,
                     REF, deltd, autoid
                    )
             VALUES (v_afacctno, v_txnum,
                     v_txdate, '0018', price, '',
                     '0001130808004324', 'N', seq_citran.NEXTVAL
                    );
        INSERT INTO citran
                    (acctno, txnum,
                     txdate, txcd, namt, camt,
                     REF, deltd, autoid
                    )
             VALUES (v_afacctno, v_txnum,
                     v_txdate, '0011', price, '',
                     '0001130808004324', 'N', seq_citran.NEXTVAL
                    );
        INSERT INTO ood
                    (orgorderid, codeid, symbol, custodycd, bors, norp,
                     aorn, price, qtty, securedratio, oodstatus, txdate,
                     txnum, deltd, brid
                    )
             VALUES (v_order_id, codeid, symbol, v_custodycd, v_Bors, 'N',
                     'N', price, v_Qtty, 100, 'N', v_txdate,
                     v_txnum, 'N', '0001'
                    );
        INSERT INTO odmast
                    (orderid, custid, actype, codeid,
                     afacctno, seacctno, ciacctno, txnum,
                     txdate, txtime,
                     expdate, bratio, timetype, exectype, nork, matchtype,
                     via, clearday, clearcd, orstatus, porstatus, pricetype,
                     quoteprice, stopprice, limitprice, orderqtty, remainqtty,
                     exprice, exqtty, securedamt, execqtty, standqtty, cancelqtty,
                     adjustqtty, rejectqtty, rejectcd, voucher, consultant,
                     contrafirm, traderid, clientid
                    )
             VALUES (v_order_id, v_afacctno, '1001', codeid,
                     v_afacctno, v_afacctno||codeid, v_afacctno, v_txnum,
                     v_txdate, '16:26:21',
                     v_txdate, 100, 'T', v_exectype, 'N', 'N',
                     'T', 3, 'B', '8', '8', v_PRICETYPE,
                     price, 0, 0, v_Qtty, v_Qtty,
                     price, v_Qtty, price, 0, 0, 0,
                     0, 0, '001', 'P', 'C',
                     'A', 'A', 'A'
                    );

      commit;
  --------------------END DAT LENH---------------------------

END LOOP;
CLOSE Ho_symbol;
End Loop;

P_strError:=' Da Load test thanh cong ' || to_char(i)|| ' Lenh ';
----------End phan Dat lenh -------------------------
 EXCEPTION
   WHEN OTHERS
   THEN
   P_strError:=SQLERRM;
      RETURN;
END;

 
 
 
 
/
