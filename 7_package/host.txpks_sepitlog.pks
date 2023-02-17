SET DEFINE OFF;
CREATE OR REPLACE PACKAGE txpks_sepitlog IS

  /*----------------------------------------------------------------------------------------------------
  ** Module   : COMMODITY SYSTEM
  ** and is copyrighted by FSS.
  **
  **    All rights reserved.  No part of this work may be reproduced, stored in a retrieval system,
  **    adopted or transmitted in any form or by any means, electronic, mechanical, photographic,
  **    graphic, optic recording or otherwise, translated in any language or computer language,
  **    without the prior written permission of Financial Software Solutions. JSC.
  **
  **  MODIFICATION HISTORY
  **  Person      Date           Comments
  **  Fsser      09-JUNE-2009    Created
  ** (c) 2008 by Financial Software Solutions. JSC.
  ----------------------------------------------------------------------------------------------------*/
  /*
  Purpose: Thuc hien khau tru thue TNCN khi ban co phieu thuong
  Input: p_Acctno: Tieu khoan SEMAST
         p_CodeID: Ban chung khoan nao
         p_Qtty:   Ban bao nhieu
  Output: p_err_code := errnums.C_SYSTEM_ERROR if failed
  Author: KhanhND
  Date created: 05/04/2011
  */
  PROCEDURE pr_DeductionPIT(p_OrderID  varchar2,
                            p_Acctno   varchar2,
                            p_AfAcctno varchar2,
                            p_CodeID   varchar2,
                            p_Qtty     number,
                            p_err_code OUT varchar2);
  PROCEDURE pr_SellStockCALog(p_OrderID  varchar2,
                              p_Acctno   varchar2,
                              p_AfAcctno varchar2,
                              p_SeAcctno varchar2,
                              p_CodeID   varchar2,
                              p_Qtty     number,
                              p_actype   varchar2,
                              p_txdate   varchar2,
                              p_err_code OUT varchar2);
  PROCEDURE pr_CalcPIT(p_bchmdl   varchar,
                       p_err_code OUT varchar2,
                       p_FromRow  number,
                       p_ToRow    number,
                       p_lastRun  OUT varchar2);
END; -- Package spec

 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
/


CREATE OR REPLACE PACKAGE BODY txpks_sepitlog IS
  pkgctx plog.log_ctx;
  logrow tlogdebug%ROWTYPE;
  /*
  Purpose: Thuc hien ghi nhan lenh ban chung khoan co nguon tu co tuc = co phieu
  Input: p_Acctno: Tieu khoan SEMAST
         p_CodeID: Ban chung khoan nao
         p_Qtty:   Ban bao nhieu,
         p_OrderID: Lenh nao,
         p_actype: Loai hinh lenh,
  Output: p_err_code := errnums.C_SYSTEM_ERROR if failed
  Author: KhanhND
  Date created: 05/04/2011
  */
  PROCEDURE pr_SellStockCALog(p_OrderID  varchar2,
                              p_Acctno   varchar2,
                              p_AfAcctno varchar2,
                              p_SeAcctno varchar2,
                              p_CodeID   varchar2,
                              p_Qtty     number,
                              p_actype   varchar2,
                              p_txdate   varchar2,
                              p_err_code OUT varchar2) IS
    v_isHas number;
  BEGIN
    plog.setbeginsection(pkgctx, 'pr_SellStockCALog');
    plog.error(pkgctx,
               'Begin pr_SellStockCALog: ' || p_OrderID || ',' || p_AcctNo || ', ' ||
               p_AfAcctno || ', ' || p_CodeID || ',' || p_Qtty || ',' ||
               p_actype || ',' || p_txdate);
    ---1. Kiem tra xem chung khoan nay co dot thuc hien quyen co tuc = co phieu hay khong
    SELECT COUNT(AUTOID)
      INTO v_isHas
      FROM SEPITLOG
     WHERE ACCTNO = p_AcctNo
       AND CODEID = p_CodeID
       AND QTTY > 0;
    IF v_isHas > 0 THEN
      ---2. Neu co thuc hien ghi nhan vao bang nay
      INSERT INTO SELLSTOCKCALOG
        (AUTOID,
         TXDATE,
         ORDERID,
         CODEID,
         QTTY,
         AMT,
         INTAMT,
         STATUS,
         AFACCTNO,
         ACTYPE,
         SEACCTNO)
      VALUES
        (SEQ_SELLSTOCKCALOG.NEXTVAL,
         p_txdate,
         p_OrderID,
         p_CodeID,
         p_Qtty,
         0,
         0,
         'P',
         p_AfAcctno,
         p_actype,
         p_SeAcctno);
    END IF;
    p_err_code := '0';
    plog.setendsection(pkgctx, 'END pr_SellStockCALog');
  EXCEPTION
    WHEN OTHERS THEN
      plog.error(pkgctx,
                 'got error on release pr_SellStockCALog: ' || p_AcctNo || ', ' ||
                 p_AfAcctno || ', ' || p_CodeID || ',' || p_Qtty);
      ROLLBACK;
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error(pkgctx, SQLERRM);
      plog.setendsection(pkgctx, 'pr_SellStockCALog');
      RAISE errnums.E_SYSTEM_ERROR;
  END;
  /*
  Purpose: Thuc hien tinh toan thue TNCN khi ban chung khoan tu nguon co tuc = co phieu
  Input:
  Output: p_err_code := errnums.C_SYSTEM_ERROR if failed
  Author: KhanhND
  Date created: 05/04/2011
  */
  PROCEDURE pr_CalcPIT(p_bchmdl   varchar,
                       p_err_code OUT varchar2,
                       p_FromRow  number,
                       p_ToRow    number,
                       p_lastRun  OUT varchar2) IS
    l_txmsg         tx.msg_rectype;
    v_OrderID       varchar2(100);
    v_CodeID        varchar2(10);
    p_Qtty          number;
    v_Actype        varchar2(10);
    v_AfAcctno      varchar2(20);
    v_TotalIntAmt   number; ---Tong so tien thue phai thu
    v_TotalAmt      number; ---Tong gia tri giao dich
    v_INTAMT        number;
    v_AMT           number;
    v_PitRate       number;
    v_PitRateMethod varchar2(10);
    v_ContainPITLOG number;
    l_actype        varchar2(10);
    l_icrate        number;
    l_ruletype      varchar2(10);
    v_delta         number;
    l_amount        number;
    l_feeamt        number;
    v_strCURRDATE   varchar2(20);
    v_strPREVDATE   varchar2(20);
    v_strNEXTDATE   varchar2(20);
    v_strDesc       varchar2(1000);
    v_strEN_Desc    varchar2(1000);
    l_err_param     varchar2(300);
    v_intItemAF     number := 0;
    v_intItemOrder  number := 0;
    v_intItemPitLog number := 0;
    v_QttySett      number := 0;
    l_MaxRow        number(20, 0) := 0;
  BEGIN
    plog.setbeginsection(pkgctx, 'Begin pr_CalcPIT');
    BEGIN
      SELECT COUNT(*) MAXROW
        into l_MaxRow
        FROM sellstockcalog
       WHERE STATUS = 'P';
      IF l_MaxRow > p_ToRow THEN
        p_lastRun := 'N';
      ELSE
        p_lastRun := 'Y';
      END IF;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        plog.error(pkgctx, 'Loi tai tinh tong so dong du lieu');
    END;
    ----DUYET THEO TUNG TIEU KHOAN AF
    FOR RECAFACCTNO IN (SELECT AFACCTNO
                          FROM sellstockcalog
                         WHERE STATUS = 'P'
                           AND ROWNUM BETWEEN p_FromRow AND p_ToRow
                         GROUP BY AFACCTNO) LOOP
    
      v_intItemAF := v_intItemAF + 1;
      plog.error(pkgctx,
                 v_intItemAF || ' - AFACCTNO:  ' || RECAFACCTNO.AFACCTNO);
      ---1. DUYET TOAN BO BANG LOG LENH BAN CHUNG KHOAN CO NGUON TU CO TUC = CO PHIEU
      FOR RECSELLLOG IN (SELECT CODEID,
                                ORDERID,
                                AFACCTNO,
                                SEACCTNO,
                                ACTYPE,
                                QTTY
                           FROM sellstockcalog
                          WHERE AFACCTNO = RECAFACCTNO.AFACCTNO
                            AND STATUS = 'P'
                          ORDER BY TXDATE, autoid) LOOP
        v_TotalIntAmt  := 0;
        v_TotalAmt     := 0;
        v_intItemOrder := v_intItemOrder + 1;
        plog.error(pkgctx,
                   v_intItemAF || '.' || v_intItemOrder || ': ' ||
                   RECSELLLOG.ORDERID);
        p_Qtty := RECSELLLOG.QTTY; ---Khoi luong ban
        ----DUYET TOAN BO CAC DOT THUC HIEN QUYEN CUA TIEU KHOAN NAY
        FOR REC IN (SELECT SUM(PRICE) PRICE, CAMASTID, SUM(QTTY) QTTY
                      FROM SEPITLOG
                     WHERE AFACCTNO = RECSELLLOG.SEACCTNO
                       AND CODEID = RECSELLLOG.CODEID
                       AND ACCTNO = RECSELLLOG.AFACCTNO
                       AND QTTY > 0
                     GROUP BY CAMASTID, TXDATE ---,TXNUM
                     ORDER BY TXDATE DESC) LOOP
          v_intItemPitLog := v_intItemPitLog + 1;
          plog.error(pkgctx,
                     v_intItemAF || '.' || v_intItemOrder || '.' ||
                     v_intItemPitLog || ': ' || REC.CAMASTID);
          ---NEU KHOI LUONG BAN LON HON KHOI LUONG THUC HIEN QUYEN THI LAY KHOI LUONG THUC HIEN QUYEN
          IF p_Qtty > REC.QTTY THEN
            v_QttySett := REC.QTTY;
          ELSE
            v_QttySett := p_Qtty;
          END IF;
          plog.error(pkgctx,
                     v_intItemAF || '.' || v_intItemOrder || '.' ||
                     'v_QttySett: ' || v_QttySett || ',REC.QTTY: ' ||
                     REC.QTTY || ',RECSELLLOG.QTTY: ' || RECSELLLOG.QTTY);
          ----2: Kiem tra trong CAMAST xem phuong thuc thu thue la gi, o dau, neu la o CTCK (SC) thi moi tinh toan
        
          BEGIN
            SELECT PITRATE, PITRATEMETHOD
              INTO v_PitRate, v_PitRateMethod
              FROM CAMAST
             WHERE CAMASTID = REC.CAMASTID;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              v_ContainPITLOG := 0;
              plog.error(pkgctx, 'No data found set v_ContainPITLOG = 0');
          END;
          ----Neu thu tai CTCK thi moi tinh toan
          IF v_PitRateMethod = 'SC' THEN
            ----Thu tai CTCK
            ---LAY THONG TIN BIEU PHI TINH THUE TNCN
            BEGIN
              SELECT decode(i.ictype, 'F', i.icflat, i.icrate) icrate,
                     i.ruletype,
                     i.actype
                INTO l_icrate, l_ruletype, l_actype
                FROM SEMAST S, ICCFTYPEDEF I
               WHERE S.ACCTNO = RECSELLLOG.SEACCTNO
                    ---AND S.ACCTNO =RECSELLLOG.AFACCTNO ----AND O.EXECTYPE  IN ('NS','MS')
                 AND I.ACTYPE = RECSELLLOG.ACTYPE
                 AND I.MODCODE = 'OD'
                 AND I.ICCFSTATUS = 'A'
                 AND I.EVENTCODE = 'ODFEEPIT';
            EXCEPTION
              WHEN NO_DATA_FOUND THEN
                plog.error(pkgctx,
                           'No data found xac dinh icrate RECSELLLOG.AFACCTNO ' ||
                           RECSELLLOG.SEACCTNO || ',RECSELLLOG.ACTYPE' ||
                           RECSELLLOG.ACTYPE);
                return;
            END;
            ----TINH THUE
            IF v_QttySett > 0 THEN
              if l_ruletype <> 'C' then
                --If la Cluster
                --Luat tinh theo fixed hoac tier, Neu co trong loai hinh ICCF thi xac dinh rate theo loai hinh
                begin
                  --Xac dinh tier
                  if l_ruletype = 'T' then
                    SELECT DELTA
                      INTO v_delta
                      FROM ICCFTIER
                     WHERE ACTYPE = L_ACTYPE
                       AND MODCODE = 'OD'
                       AND EVENTCODE = 'ODFEEPIT'
                       AND DELTD <> 'Y'
                       and framt < v_QttySett
                       and toamt >= v_QttySett;
                  else
                    v_delta := 0;
                  end if;
                  l_icrate := l_icrate + v_delta;
                exception
                  when others then
                    l_icrate := l_icrate;
                end;
                l_amount      := v_QttySett;
                v_AMT         := nvl(v_AMT, 0) +
                                 round(l_amount * rec.price, 0);
                v_INTAMT      := nvl(v_INTAMT, 0) +
                                 round(l_icrate / 100 *
                                       (l_amount * rec.price),
                                       0);
                v_TotalAmt    := v_TotalAmt +
                                 round(l_amount * rec.price, 0);
                v_TotalIntAmt := v_TotalIntAmt +
                                 round(l_icrate / 100 *
                                       (l_amount * rec.price),
                                       0);
              else
                ----else of if l_ruletype<>'C' then
                --Luat tinh theo cluster, Neu co trong loai hinh ICCF thi xac dinh rate theo loai hinh
                l_feeamt := 0;
                for rec_tier in (select delta, framt, toamt
                                   from iccftier
                                  where actype = L_ACTYPE
                                    and modcode = 'OD'
                                    and eventcode = 'ODFEEPIT'
                                    and deltd <> 'Y'
                                  order by framt) loop
                  exit when v_QttySett < rec_tier.framt;
                  if v_QttySett > rec_tier.framt and
                     v_QttySett < rec_tier.toamt then
                    l_amount := v_QttySett - rec_tier.framt;
                  ELSE
                    l_amount := rec_tier.toamt - rec_tier.framt;
                  end if;
                  l_icrate := l_icrate + rec_tier.delta;
                  l_feeamt := l_feeamt + round((l_amount * rec.price) *
                                               (l_icrate / 100),
                                               0);
                end loop;
                v_AMT         := nvl(v_AMT, 0) +
                                 round(l_amount * rec.price, 0);
                v_INTAMT      := nvl(v_INTAMT, 0) +
                                 round(((l_feeamt / (l_amount * rec.price)) / 100) *
                                       (l_amount * rec.price),
                                       0);
                v_TotalAmt    := v_TotalAmt +
                                 round(l_amount * rec.price, 0);
                v_TotalIntAmt := v_TotalIntAmt +
                                 round(((l_feeamt / (l_amount * rec.price)) / 100) *
                                       (l_amount * rec.price),
                                       0);
              end if; ----end of if l_ruletype<>'C' then
            END IF; ----IF RECSELLOG.QTTY > 0 THEN
            ---END OF TINH THUE
          
            ---GHI NHAN TRONG PITLOG
            ---GIAM QTTY, TANG MAPQTTY
            plog.error(pkgctx,
                       'Cap nhat lai vao SEPITLOG - p_Qtty:' || p_Qtty ||
                       ',ACCTNO: ' || RECSELLLOG.AFACCTNO || ',AFACCTNO:' ||
                       RECSELLLOG.SEACCTNO || ',CamastID: ' || rec.CamastID);
            ---plog.error(pkgctx, 'p_Qtty: '|| p_Qtty);
            UPDATE SEPITLOG
               SET QTTY    = NVL(QTTY, 0) - v_QttySett,
                   MAPQTTY = NVL(MAPQTTY, 0) + v_QttySett
             WHERE ACCTNO = RECSELLLOG.AFACCTNO
               AND AFACCTNO = RECSELLLOG.SEACCTNO
               AND CAMASTID = rec.CamastID;
            p_Qtty := p_Qtty - v_QttySett;
            EXIT WHEN p_Qtty <= 0; ----REC.QTTY - RECSELLLOG.QTTY < 0;
          ELSE
            plog.error(pkgctx,
                       'pr_CalcPIT KHONG THU PHI TAI CTCK: ' ||
                       v_PitRateMethod);
          END IF; ----IF v_PitRateMethod = 'SC'
        END LOOP; ---FOR REC IN, dot thuc hien quyen
        ----TINH TOAN THUE TNCN XONG THUC HIEN GHI NHAN VAO TRONG SELLSTOCKLOG TUONG UNG VOI LENH DANG XU LY
        plog.error(pkgctx,
                   'Cap nhat lai vao sellstockcalog - v_AMT: ' || v_AMT ||
                   ', ORDERID: ' || RECSELLLOG.ORDERID || ', AFACCTNO: ' ||
                   RECSELLLOG.AFACCTNO || ', SEACCTNO: ' ||
                   RECSELLLOG.SEACCTNO);
        /*plog.error(pkgctx, 'v_AMT: '|| v_AMT);
        plog.error(pkgctx, 'v_INTAMT: '|| v_INTAMT);            */
        UPDATE sellstockcalog
           SET AMT = v_AMT, INTAMT = v_INTAMT, STATUS = 'C'
         WHERE ORDERID = RECSELLLOG.ORDERID
           AND AFACCTNO = RECSELLLOG.AFACCTNO
           AND SEACCTNO = RECSELLLOG.SEACCTNO;
        v_AMT    := 0;
        v_INTAMT := 0;
      END LOOP; ----FOR RECSELLLOG IN (
      ----Thuc hien goi giao dich 8818
      SELECT TXDESC, EN_TXDESC
        into v_strDesc, v_strEN_Desc
        FROM TLTX
       WHERE TLTXCD = '8818';
      ---Lay Current Date, Previous Date
      SELECT varvalue
        INTO v_strCURRDATE
        FROM sysvar
       WHERE grname = 'SYSTEM'
         AND varname = 'CURRDATE';
      SELECT varvalue
        INTO v_strPREVDATE
        FROM sysvar
       WHERE grname = 'SYSTEM'
         AND varname = 'PREVDATE';
      l_txmsg.msgtype := 'T';
      l_txmsg.local   := 'N';
      l_txmsg.tlid    := systemnums.c_system_userid;
      plog.error(pkgctx, '8818- l_txmsg.tlid' || l_txmsg.tlid);
      SELECT SYS_CONTEXT('USERENV', 'HOST'),
             SYS_CONTEXT('USERENV', 'IP_ADDRESS', 15)
        INTO l_txmsg.wsname, l_txmsg.ipaddress
        FROM DUAL;
      l_txmsg.off_line  := 'N';
      l_txmsg.deltd     := txnums.c_deltd_txnormal;
      l_txmsg.txstatus  := txstatusnums.c_txcompleted;
      l_txmsg.msgsts    := '0';
      l_txmsg.ovrsts    := '0';
      l_txmsg.txdate    := to_date(v_strCURRDATE, systemnums.c_date_format);
      l_txmsg.busdate   := to_date(v_strCURRDATE, systemnums.c_date_format);
      l_txmsg.batchname := p_bchmdl;
      l_txmsg.tltxcd    := '8818';
      SELECT systemnums.C_BATCH_PREFIXED ||
             LPAD(seq_BATCHTXNUM.NEXTVAL, 8, '0')
        INTO l_txmsg.txnum
        FROM DUAL;
      l_txmsg.txfields('03').defname := 'ACCTNO';
      l_txmsg.txfields('03').TYPE := 'C';
      l_txmsg.txfields('03').VALUE := RECAFACCTNO.AFACCTNO; ---p_AcctNo;
      --07  PERCENT     N
      l_txmsg.txfields('07').defname := 'PERCENT';
      l_txmsg.txfields('07').TYPE := 'N';
      l_txmsg.txfields('07').VALUE := 100;
    
      --08  ICCFBAL     N
      l_txmsg.txfields('08').defname := 'ICCFBAL';
      l_txmsg.txfields('08').TYPE := 'N';
      l_txmsg.txfields('08').VALUE := v_TotalAmt;
      --10  INTAMT      N
      l_txmsg.txfields('10').defname := 'INTAMT';
      l_txmsg.txfields('10').TYPE := 'N';
      l_txmsg.txfields('10').VALUE := v_TotalIntAmt;
    
      --09  ICCFRATE    N
      l_txmsg.txfields('09').defname := 'FEEAMT';
      l_txmsg.txfields('09').TYPE := 'N';
      l_txmsg.txfields('09').VALUE := l_icrate;
    
      --30    DESC        C
      l_txmsg.txfields('30').defname := 'DESC';
      l_txmsg.txfields('30').TYPE := 'C';
      l_txmsg.txfields('30').VALUE := 'Thue TNCN khi ban co phieu tu nguon co tuc';
      plog.error(pkgctx,
                 'Thue TNCN khi ban co phieu tu nguon co tuc- v_TotalAmt: ' ||
                 v_TotalAmt || ', v_TotalIntAmt: ' || v_TotalIntAmt);
      BEGIN
        IF txpks_#8818.fn_batchtxprocess(l_txmsg, p_err_code, l_err_param) <>
           systemnums.c_success THEN
          plog.debug(pkgctx, 'got error 8818: ' || p_err_code);
          ROLLBACK;
          RETURN;
        END IF;
      END;
    END LOOP;
    plog.setbeginsection(pkgctx, 'pr_CalcPIT');
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error(pkgctx, SQLERRM);
      plog.setendsection(pkgctx, 'pr_CalcPIT');
      RAISE errnums.E_SYSTEM_ERROR;
  END;
  /*
  Purpose: Thuc hien khau tru thue TNCN khi ban co phieu thuong
  Input: p_Acctno: Tieu khoan SEMAST
         p_CodeID: Ban chung khoan nao
         p_Qtty:   Ban bao nhieu,
         p_OrderID: Lenh nao
  Output: p_err_code := errnums.C_SYSTEM_ERROR if failed
  Author: KhanhND
  Date created: 05/04/2011
  */
  PROCEDURE pr_DeductionPIT(p_OrderID  varchar2,
                            p_AcctNo   varchar2,
                            p_AfAcctno varchar2,
                            p_CodeID   varchar2,
                            p_Qtty     number,
                            p_err_code OUT varchar2) IS
    l_txmsg         tx.msg_rectype;
    v_ContainPITLOG number;
    v_PitRate       number;
    v_PitRateMethod varchar2(10);
    l_actype        varchar2(10);
    l_icrate        number;
    l_ruletype      varchar2(10);
    v_delta         number;
    l_amount        number;
    l_feeamt        number;
    v_strCURRDATE   varchar2(20);
    v_strPREVDATE   varchar2(20);
    v_strNEXTDATE   varchar2(20);
    v_strDesc       varchar2(1000);
    v_strEN_Desc    varchar2(1000);
    l_err_param     varchar2(300);
    --v_price number;
    --v_CamastID number;
    v_CodeIDOrder varchar2(100);
    ---v_QttyOrder number;
    ---v_TxNum varchar2(30);
    v_OrderID  varchar2(100);
    v_Qtty     number;
    v_Actype   varchar2(10);
    v_AfAcctno varchar2(20);
  BEGIN
    plog.setbeginsection(pkgctx, 'pr_DeductionPIT');
    plog.error(pkgctx,
               'Begin pr_DeductionPIT: ' || p_OrderID || ',' || p_AcctNo || ', ' ||
               p_AfAcctno || ', ' || p_CodeID || ',' || p_Qtty);
  
    ----0: Lay thong tin cua lenh: Chung khoan, khoi luong
    BEGIN
      SELECT CODEID
        INTO v_CodeIDOrder
        FROM ODMAST
       WHERE ORDERID = p_OrderID;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        p_err_code := '-1';
        plog.error(pkgctx, 'OrderID not exits: ' || p_OrderID);
        return;
    END;
    ----1: DUYET TOAN BO TRONG SEPITLOG LAY THONG TIN CAC DOT THUC HIEN QUYEN, THUC HIEN TU BAN GHI OLDEST TRO DI
    FOR REC IN (SELECT SUM(PRICE) PRICE, CAMASTID ---INTO v_ContainPITLOG, v_price,v_CamastID  ---, v_TxNum
                  FROM SEPITLOG
                 WHERE AFACCTNO = p_AfAcctno
                   AND QTTY > 0
                   AND CODEID = v_CodeIDOrder
                   AND ACCTNO = p_AcctNo
                 GROUP BY CAMASTID, TXDATE ---,TXNUM
                 ORDER BY TXDATE DESC) LOOP
      SELECT TXDESC, EN_TXDESC
        into v_strDesc, v_strEN_Desc
        FROM TLTX
       WHERE TLTXCD = '8818';
      ---Lay Current Date, Previous Date
      SELECT varvalue
        INTO v_strCURRDATE
        FROM sysvar
       WHERE grname = 'SYSTEM'
         AND varname = 'CURRDATE';
      SELECT varvalue
        INTO v_strPREVDATE
        FROM sysvar
       WHERE grname = 'SYSTEM'
         AND varname = 'PREVDATE';
      l_txmsg.msgtype := 'T';
      l_txmsg.local   := 'N';
      l_txmsg.tlid    := systemnums.c_system_userid;
      --plog.debug(pkgctx, 'l_txmsg.tlid' || l_txmsg.tlid);
      plog.error(pkgctx, '8818- l_txmsg.tlid' || l_txmsg.tlid);
      SELECT SYS_CONTEXT('USERENV', 'HOST'),
             SYS_CONTEXT('USERENV', 'IP_ADDRESS', 15)
        INTO l_txmsg.wsname, l_txmsg.ipaddress
        FROM DUAL;
      l_txmsg.off_line := 'N';
      l_txmsg.deltd    := txnums.c_deltd_txnormal;
      l_txmsg.txstatus := txstatusnums.c_txcompleted;
      l_txmsg.msgsts   := '0';
      l_txmsg.ovrsts   := '0';
      ----l_txmsg.batchname   := p_bchmdl;
      l_txmsg.txdate  := to_date(v_strCURRDATE, systemnums.c_date_format);
      l_txmsg.busdate := to_date(v_strCURRDATE, systemnums.c_date_format);
      l_txmsg.tltxcd  := '8818';
      BEGIN
        ----2: Kiem tra trong CAMAST xem phuong thuc thu thue la gi, o dau, neu la o CTCK (SC) thi moi tinh toan
        SELECT PITRATE, PITRATEMETHOD
          INTO v_PitRate, v_PitRateMethod
          FROM CAMAST
         WHERE CAMASTID = REC.CAMASTID;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          v_ContainPITLOG := 0;
          plog.error(pkgctx,
                     'v_CamastID: ' || rec.CamastID || ', p_AfAcctno:' ||
                     p_AfAcctno);
      END;
      IF v_PitRateMethod = 'SC' THEN
        ----Thu tai CTCK
        ----3: Tinh phi
        SELECT decode(i.ictype, 'F', i.icflat, i.icrate) icrate,
               i.ruletype,
               i.actype
          INTO l_icrate, l_ruletype, l_actype
          FROM SEMAST S, ICCFTYPEDEF I, ODMAST O
         WHERE S.ACCTNO = p_AfAcctno
           AND O.orderid = p_OrderID
           AND S.ACCTNO = O.SEACCTNO
           AND O.EXECTYPE IN ('NS', 'MS')
           AND O.ACTYPE = I.ACTYPE
           AND I.MODCODE = 'OD'
           AND I.ICCFSTATUS = 'A'
           AND I.EVENTCODE = 'ODFEEPIT';
        plog.error(pkgctx, '8818: icrate: ' || l_icrate);
        IF p_Qtty > 0 THEN
          ----set TxNum
          SELECT systemnums.C_BATCH_PREFIXED ||
                 LPAD(seq_BATCHTXNUM.NEXTVAL, 8, '0')
            INTO l_txmsg.txnum
            FROM DUAL;
          --Set cac field giao dich
          --03  ACCTNO      C
          l_txmsg.txfields('03').defname := 'ACCTNO';
          l_txmsg.txfields('03').TYPE := 'C';
          l_txmsg.txfields('03').VALUE := p_AcctNo;
          --07  PERCENT     N
          l_txmsg.txfields('07').defname := 'PERCENT';
          l_txmsg.txfields('07').TYPE := 'N';
          l_txmsg.txfields('07').VALUE := 100;
          if l_ruletype <> 'C' then
            --If la Cluster
            --Luat tinh theo fixed hoac tier, Neu co trong loai hinh ICCF thi xac dinh rate theo loai hinh
            begin
              --Xac dinh tier
              if l_ruletype = 'T' then
                SELECT DELTA
                  INTO v_delta
                  FROM ICCFTIER
                 WHERE ACTYPE = L_ACTYPE
                   AND MODCODE = 'OD'
                   AND EVENTCODE = 'ODFEEPIT'
                   AND DELTD <> 'Y'
                   and framt < p_Qtty
                   and toamt >= p_Qtty;
              else
                v_delta := 0;
              end if;
              l_icrate := l_icrate + v_delta;
            exception
              when others then
                l_icrate := l_icrate;
            end;
            l_amount := p_Qtty;
            --08  ICCFBAL     N
            l_txmsg.txfields('08').defname := 'ICCFBAL';
            l_txmsg.txfields('08').TYPE := 'N';
            l_txmsg.txfields('08').VALUE := round(l_amount * rec.price, 0);
            --10  INTAMT      N
            l_txmsg.txfields('10').defname := 'INTAMT';
            l_txmsg.txfields('10').TYPE := 'N'; ----round(((l_feeamt/l_iccfbal)/100)*EXECAMT, 0) round((l_icrate/100)*EXECAMT, 0)
            l_txmsg.txfields('10').VALUE := round(l_icrate / 100 *
                                                  (l_amount * rec.price),
                                                  0);
          else
            ----else of if l_ruletype<>'C' then
            --Luat tinh theo cluster, Neu co trong loai hinh ICCF thi xac dinh rate theo loai hinh
            l_feeamt := 0;
            for rec_tier in (select delta, framt, toamt
                               from iccftier
                              where actype = L_ACTYPE
                                and modcode = 'OD'
                                and eventcode = 'ODFEEPIT'
                                and deltd <> 'Y'
                              order by framt) loop
              exit when p_Qtty < rec_tier.framt;
              if p_Qtty > rec_tier.framt and p_Qtty < rec_tier.toamt then
                l_amount := p_Qtty - rec_tier.framt;
              ELSE
                l_amount := rec_tier.toamt - rec_tier.framt;
              end if;
              l_icrate := l_icrate + rec_tier.delta;
              l_feeamt := l_feeamt +
                          round((l_amount * rec.price) * (l_icrate / 100),
                                0);
            end loop;
            --08  ICCFBAL     N
            l_txmsg.txfields('08').defname := 'ICCFBAL';
            l_txmsg.txfields('08').TYPE := 'N';
            l_txmsg.txfields('08').VALUE := round(l_amount * rec.price, 0);
            --10  INTAMT      N
            l_txmsg.txfields('10').defname := 'INTAMT';
            l_txmsg.txfields('10').TYPE := 'N'; ----round(((l_feeamt/l_iccfbal)/100)*EXECAMT, 0) round((l_icrate/100)*EXECAMT, 0)
            l_txmsg.txfields('10').VALUE := round(((l_feeamt /
                                                  (l_amount * rec.price)) / 100) *
                                                  (l_amount * rec.price),
                                                  0); ---round(l_icrate/100*l_amount,0);
          
          end if; ----end of if l_ruletype<>'C' then
          --09  ICCFRATE    N
          l_txmsg.txfields('09').defname := 'FEEAMT';
          l_txmsg.txfields('09').TYPE := 'N';
          l_txmsg.txfields('09').VALUE := l_icrate;
        
          --30    DESC        C
          l_txmsg.txfields('30').defname := 'DESC';
          l_txmsg.txfields('30').TYPE := 'C';
          l_txmsg.txfields('30').VALUE := 'Thue TNCN khi ban co phieu tu nguon co tuc';
          BEGIN
            IF txpks_#8818.fn_batchtxprocess(l_txmsg,
                                             p_err_code,
                                             l_err_param) <>
               systemnums.c_success THEN
              plog.debug(pkgctx, 'got error 8818: ' || p_err_code);
              ROLLBACK;
              RETURN;
            ELSE
              ---GHI NHAN TRONG PITLOG
              ---GIAM QTTY, TANG MAPQTTY
              UPDATE SEPITLOG
                 SET QTTY    = NVL(QTTY, 0) - p_Qtty,
                     MAPQTTY = NVL(MAPQTTY, 0) + p_Qtty
               WHERE ACCTNO = p_AcctNo
                 AND AFACCTNO = p_AfAcctno
                 AND CAMASTID = rec.CamastID;
            END IF;
          END;
        ELSE
          plog.debug(pkgctx, 'p_Qtty<0: ' || p_Qtty);
        END IF; ---end of IF p_Qtty >0 THEN
        p_err_code := '0';
      END IF;
    END LOOP;
    p_err_code := '0';
    plog.setendsection(pkgctx, 'pr_DeductionPIT');
  EXCEPTION
    WHEN OTHERS THEN
      plog.error(pkgctx,
                 'got error on release pr_DeductionPIT: ' || p_AcctNo || ', ' ||
                 p_AfAcctno || ', ' || p_CodeID || ',' || p_Qtty);
      ROLLBACK;
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error(pkgctx, SQLERRM);
      plog.setendsection(pkgctx, 'pr_DeductionPIT');
      RAISE errnums.E_SYSTEM_ERROR;
  END;

-- Enter further code below as specified in the Package spec.
END;

/
