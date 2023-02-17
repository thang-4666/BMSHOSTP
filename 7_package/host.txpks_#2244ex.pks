SET DEFINE OFF;
CREATE OR REPLACE PACKAGE txpks_#2244ex
/**----------------------------------------------------------------------------------------------------
 ** Package: TXPKS_#2244EX
 ** and is copyrighted by FSS.
 **
 **    All rights reserved.  No part of this work may be reproduced, stored in a retrieval system,
 **    adopted or transmitted in any form or by any means, electronic, mechanical, photographic,
 **    graphic, optic recording or otherwise, translated in any language or computer language,
 **    without the prior written permission of Financial Software Solutions. JSC.
 **
 **  MODIFICATION HISTORY
 **  Person      Date           Comments
 **  System      13/09/2011     Created
 **
 ** (c) 2008 by Financial Software Solutions. JSC.
 ** ----------------------------------------------------------------------------------------------------*/
IS
FUNCTION fn_txPreAppCheck(p_txmsg in out tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER;
FUNCTION fn_txAftAppCheck(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER;
FUNCTION fn_txPreAppUpdate(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER;
FUNCTION fn_txAftAppUpdate(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER;
END;
 
/


CREATE OR REPLACE PACKAGE BODY txpks_#2244ex
IS
   pkgctx   plog.log_ctx;
   logrow   tlogdebug%ROWTYPE;

   c_codeid           CONSTANT CHAR(2) := '01';
   c_afacctno         CONSTANT CHAR(2) := '02';
   c_acctno           CONSTANT CHAR(2) := '03';
   c_custname         CONSTANT CHAR(2) := '90';
   c_address          CONSTANT CHAR(2) := '91';
   c_license          CONSTANT CHAR(2) := '92';
   c_outward          CONSTANT CHAR(2) := '05';
   c_depoblock        CONSTANT CHAR(2) := '06';
   c_price            CONSTANT CHAR(2) := '09';
   c_amt              CONSTANT CHAR(2) := '10';
   c_parvalue         CONSTANT CHAR(2) := '11';
   c_qtty             CONSTANT CHAR(2) := '12';
   c_trtype           CONSTANT CHAR(2) := '31';
   c_qttytype         CONSTANT CHAR(2) := '14';
   c_desc             CONSTANT CHAR(2) := '30';
   c_catax            CONSTANT CHAR(2) := '48';
FUNCTION fn_txPreAppCheck(p_txmsg in out tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER
IS
    l_mrrate number;
    l_mrirate number;
    l_marginrate number;
    v_mnemonic varchar2(50);
    v_CUSTATCOM varchar2(50);
    v_status varchar2(1);
    v_firm VARCHAR2(3);
    l_count NUMBER;
    v_afstatus VARCHAR2(1);
    l_cimastcheck_arr txpks_check.cimastcheck_arrtype;
    l_baldefovd_released_depofee apprules.field%TYPE;
    v_countAcc NUMBER;
    l_custid  varchar2(50);
    v_balance   NUMBER;
    v_bchsts    varchar2(4);
    l_symbol varchar2(50);
BEGIN
   plog.setbeginsection (pkgctx, 'fn_txPreAppCheck');
   plog.debug(pkgctx,'BEGIN OF fn_txPreAppCheck');
   /***************************************************************************************************
    * PUT YOUR SPECIFIC RULE HERE, FOR EXAMPLE:
    * IF NOT <<YOUR BIZ CONDITION>> THEN
    *    p_err_code := '<<ERRNUM>>'; -- Pre-defined in DEFERROR table
    *    plog.setendsection (pkgctx, 'fn_txPreAppCheck');
    *    RETURN errnums.C_BIZ_RULE_INVALID;
    * END IF;
    ***************************************************************************************************/

    IF p_txmsg.deltd <> 'Y' THEN
       --check ma dot phat hanh doi voi ck WFT
        select symbol into l_symbol from sbsecurities where codeid = p_txmsg.txfields('01').value;

        if instr(l_symbol,'_WFT') > 0 and p_txmsg.txfields('77').value is null then
            p_err_code := '-150016';
            RETURN errnums.C_BIZ_RULE_INVALID;
        end if;

        --check chi cho nhap 1 loai CK
        if p_txmsg.txfields('06').value > 0 and p_txmsg.txfields('10').value > 0 then
            p_err_code := '-200112';
            RETURN errnums.C_BIZ_RULE_INVALID;
        end if;

        --neu la tat toan thi phai chuyen het quyen
        if p_txmsg.txfields('31').value = '014' and p_txmsg.txfields('29').value = '001' then
            p_err_code := '-150017';
            RETURN errnums.C_BIZ_RULE_INVALID;
        end if;

        --tk nhan phai nhap va hop le

        if LENGTH(p_txmsg.txfields('88').value) < 10 then
            p_err_code := '-200423';
            RETURN errnums.C_BIZ_RULE_INVALID;
        end if;
       --Canh bao neu GD su dung tien ung truoc
         BEGIN
            SELECT nvl(bchsts, 'N') INTO v_bchsts FROM sbbatchsts WHERE bchdate = getcurrdate AND bchmdl = 'SAAFINDAYPROCESS';
        EXCEPTION WHEN NO_DATA_FOUND THEN
            v_bchsts := 'N';
        END;
        IF v_bchsts = 'Y' then
            SELECT balance INTO v_balance FROM cimast ci WHERE ci.acctno = p_txmsg.txfields('02').value;
            IF p_txmsg.tlid <> '0000' AND p_txmsg.tlid <> '6868' AND p_txmsg.txfields('45').value + p_txmsg.txfields('46').value> v_balance THEN
                p_txmsg.txWarningException('-4001411').value:= cspks_system.fn_get_errmsg('-400141');
                p_txmsg.txWarningException('-4001411').errlev:= '1';
            END IF;
        END IF;


    --Check xem co tieu khoan nao bi call khong
    if not cspks_cfproc.pr_check_Account_Call(p_txmsg.txfields('15').value) then
        p_err_code := '-200900';
        RETURN errnums.C_BIZ_RULE_INVALID;
    end if;

    select nvl(max(rsk.mrratiorate * least(rsk.mrpricerate,se.margincallprice) / 100),0)
        into l_mrrate
    from afserisk rsk, afmast af, aftype aft, mrtype mrt, securities_info se
    where af.actype = rsk.actype and af.actype = aft.actype and aft.mrtype = mrt.actype and mrt.mrtype = 'T' and aft.istrfbuy = 'N'
    and af.acctno = p_txmsg.txfields('02').value and rsk.codeid = p_txmsg.txfields('01').value and rsk.codeid = se.codeid;

    if l_mrrate > 0 then -- check them khi chuyen chung khoan di, tai san con lai phai dam bao ty le.
        select round((case when ci.balance +LEAST(nvl(af.MRCRLIMIT,0),nvl(sec.secureamt,0) + ci.trfbuyamt)+ nvl(sec.avladvance,0) - ci.odamt - nvl(sec.secureamt,0) - ci.trfbuyamt - ci.ramt-to_number(p_txmsg.txfields('45').value)-to_number(p_txmsg.txfields('46').value)/*-CI.CIDEPOFEEACR-CI.DEPOFEEAMT*/>=0 then 100000
                --else least( greatest(nvl(sec.SEASS,0) - to_number(p_txmsg.txfields('10').value) * l_mrrate,0), af.mrcrlimitmax - dfodamt)
                else  greatest(nvl(sec.SEASS,0) - to_number(p_txmsg.txfields('10').value) * l_mrrate,0)
                    / abs(ci.balance +LEAST(nvl(af.MRCRLIMIT,0),nvl(sec.secureamt,0) + ci.trfbuyamt)+ nvl(sec.avladvance,0) - ci.odamt - nvl(sec.secureamt,0) - ci.trfbuyamt - ci.ramt/*-CI.CIDEPOFEEACR-CI.DEPOFEEAMT*/-to_number(p_txmsg.txfields('45').value)-to_number(p_txmsg.txfields('46').value)) end),4) * 100 MARGINRATE,
                af.mrirate
                    into l_marginrate, l_mrirate
        from afmast af, cimast ci, v_getsecmarginratio sec
        where af.acctno = ci.acctno and af.acctno = sec.afacctno(+)
        and af.acctno = p_txmsg.txfields('02').value;

        if l_marginrate < l_mrirate then
            p_err_code:='-180064';
            plog.setendsection (pkgctx, 'fn_txPreAppCheck');
            RETURN errnums.C_BIZ_RULE_INVALID;
        end if;
    end if;
     SELECT varvalue INTO v_firm FROM sysvar  WHERE varname ='COMPANYCD' ;
    --  plog.error (pkgctx, '57'||p_txmsg.txfields('57').value||'v_firm'||v_firm);
     IF p_txmsg.txfields('05').value=v_firm THEN

       --Khong chuyen cugn so luu ky
       IF   p_txmsg.txfields('15').value=p_txmsg.txfields('88').value THEN
           p_err_code:='-260168';
           plog.setendsection (pkgctx, 'fn_txPreAppCheck');
           RETURN errnums.C_BIZ_RULE_INVALID;
         END IF ;
       -- Truong hop ben nhan la tk o VCBS
       SELECT nvl(COUNT(*),0) INTO l_count FROM afmast WHERE acctno =p_txmsg.txfields('04').value ;
        IF l_count=0 THEN
           p_err_code:='-200012';
           plog.setendsection (pkgctx, 'fn_txPreAppCheck');
           RETURN errnums.C_BIZ_RULE_INVALID;
          END IF;
          SELECT nvl(COUNT(*),0) INTO  l_count FROM afmast WHERE acctno =p_txmsg.txfields('04').value and status ='B';
          --Kiem tra trang thai tieu khoan ko bi phong toa
        IF l_count > 0 THEN
            p_err_code:='-260167';
            plog.setendsection (pkgctx, 'fn_txPreAppCheck');
            RETURN errnums.C_BIZ_RULE_INVALID;
        END IF;
         -- Ktra so tien phi ben nhan phai < Tien duoc rut cua ben nhan
        l_CIMASTcheck_arr := txpks_check.fn_CIMASTcheck(p_txmsg.txfields('04').value,'CIMAST','ACCTNO');
        l_BALDEFOVD_RELEASED_DEPOFEE := l_CIMASTcheck_arr(0).BALDEFOVD_RELEASED_DEPOFEE;
        if to_number(p_txmsg.txfields('57').value) > to_number(l_BALDEFOVD_RELEASED_DEPOFEE) then
            p_err_code:='-400005';
            plog.setendsection (pkgctx, 'fn_txPreAppCheck');
            RETURN errnums.C_BIZ_RULE_INVALID;
        end if;

         SELECT aft.MNEMONIC INTO v_mnemonic from afmast af, aftype aft where af.actype = aft.actype and af.acctno = p_txmsg.txfields('04').value;

        if v_mnemonic in ('T3','Margin') then
            p_err_code:='-400122';
            plog.setendsection (pkgctx, 'fn_txPreAppCheck');
            RETURN errnums.C_BIZ_RULE_INVALID;
        end if;

        select status into v_status from afmast where acctno = p_txmsg.txfields('04').value;
        IF NOT ( INSTR('ANTG',v_status) > 0) THEN
            p_err_code := '-200010';
            plog.setendsection (pkgctx, 'fn_txAppAutoCheck');
            RETURN errnums.C_BIZ_RULE_INVALID;
        END IF;

        IF NOT ( INSTR('N',v_status) = 0) THEN
            p_err_code := '-200010';
            plog.setendsection (pkgctx, 'fn_txAppAutoCheck');
            RETURN errnums.C_BIZ_RULE_INVALID;
        END IF;
    end if;
    IF p_txmsg.txfields('29').value = '002' then
        -- check khong co su kien quyen nao moi lam 3375 ma chua lam 3340

    SELECT custid into  l_custid FROM cfmast WHERE custodycd =p_txmsg.txfields('15').value;



   FOR recall  IN (SELECT acctno FROM afmast WHERE custid = l_custid )
    LOOP

       SELECT COUNT(*) INTO L_COUNT
          FROM CASCHD SCHD, AFMAST AF, CAMAST CA
          WHERE SCHD.AFACCTNO=AF.ACCTNO
              AND SCHD.DELTD <> 'Y'
              AND SCHD.STATUS IN ('A','P','N')
              AND CA.CAMASTID=SCHD.CAMASTID
              AND( (CASE WHEN CA.CATYPE ='014' THEN SCHD.PBALANCE ELSE 0 END )
                  +(CASE WHEN CA.CATYPE IN ('017','020','023','011','021') THEN SCHD.QTTY ELSE 0 END)
                  + SCHD.AMT+CASE WHEN CA.CATYPE IN ('005','006') THEN 0 ELSE  SCHD.RQTTY END
                  ) >0
               AND AF.ACCTNO=recall.acctno
               AND CA.CODEID=p_txmsg.txfields('01').value ;
         IF L_COUNT>0 THEN
                p_err_code:='-400051';
                plog.setendsection (pkgctx, 'fn_txPreAppCheck');
                RETURN errnums.C_BIZ_RULE_INVALID;
         ENd IF;
         IF SUBSTR(p_txmsg.txfields('88').value,1,3) = systemnums.C_COMPANYCD THEN
            p_err_code:='-400035';
            plog.setendsection (pkgctx, 'fn_txPreAppCheck');
            RETURN errnums.C_BIZ_RULE_INVALID;
         END IF;
    END LOOP;

    end if;
    else
        SELECT count(1) into l_count FROM sesendout WHERE txnum=p_txmsg.txnum AND txdate=p_txmsg.txdate and status <> 'N';
        if l_count>0 then
            --Giao dich da lam buoc ke tiep, khong duoc xoa.
              p_err_code := '-200404'; -- Pre-defined in DEFERROR table
              plog.setendsection (pkgctx, 'fn_txPreAppUpdate');
              RETURN errnums.C_BIZ_RULE_INVALID;
        end if;
    end if;
    plog.debug (pkgctx, '<<END OF fn_txPreAppCheck');
    plog.setendsection (pkgctx, 'fn_txPreAppCheck');
    RETURN systemnums.C_SUCCESS;
EXCEPTION
WHEN OTHERS
   THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error (pkgctx, SQLERRM);
      plog.setendsection (pkgctx, 'fn_txPreAppCheck');
      RAISE errnums.E_SYSTEM_ERROR;
END fn_txPreAppCheck;

FUNCTION fn_txAftAppCheck(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER
IS
    l_Count number;
    v_blockqtty number;
BEGIN
   plog.setbeginsection (pkgctx, 'fn_txAftAppCheck');
   plog.debug (pkgctx, '<<BEGIN OF fn_txAftAppCheck>>');
   /***************************************************************************************************
    * PUT YOUR SPECIFIC RULE HERE, FOR EXAMPLE:
    * IF NOT <<YOUR BIZ CONDITION>> THEN
    *    p_err_code := '<<ERRNUM>>'; -- Pre-defined in DEFERROR table
    *    plog.setendsection (pkgctx, 'fn_txAftAppCheck');
    *    RETURN errnums.C_BIZ_RULE_INVALID;
    * END IF;
    ***************************************************************************************************/
   /*if  p_txmsg.txfields('06').VALUE > 0 Then
        Begin
            select Count(1) into l_Count from SEMASTDTL
            where acctno = p_txmsg.txfields('03').VALUE
                  and QTTYTYPE = p_txmsg.txfields('14').VALUE
                  and qtty >= p_txmsg.txfields('06').VALUE and autoid =(p_txmsg.txfields('18').value);
        EXCEPTION
        WHEN OTHERS THEN
            l_Count :=0;
        End;

        IF l_count = 0 THEN
            plog.error(pkgctx,'l_lngErrCode: ' || '-900055');
            p_err_code := -900055;
            return errnums.C_SYSTEM_ERROR;
        END IF;
   End if;*/

        /*IF l_count = 0 THEN
            plog.error(pkgctx,'l_lngErrCode: ' || '-900055');
            p_err_code := -900055;
            return errnums.C_SYSTEM_ERROR;
        END IF;*/


   plog.debug (pkgctx, '<<END OF fn_txAftAppCheck>>');
   plog.setendsection (pkgctx, 'fn_txAftAppCheck');
   RETURN systemnums.C_SUCCESS;
EXCEPTION
WHEN OTHERS
   THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error (pkgctx, SQLERRM);
      plog.setendsection (pkgctx, 'fn_txAftAppCheck');
      RAISE errnums.E_SYSTEM_ERROR;
END fn_txAftAppCheck;

FUNCTION fn_txPreAppUpdate(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER
IS
l_count NUMBER(20);
l_trade NUMBER(20);
l_blocked NUMBER(20);
l_caqtty NUMBER(20);
BEGIN
    plog.setbeginsection (pkgctx, 'fn_txPreAppUpdate');
    plog.debug (pkgctx, '<<BEGIN OF fn_txPreAppUpdate');
   /***************************************************************************************************
    ** PUT YOUR SPECIFIC PROCESS HERE. . DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT
    ***************************************************************************************************/
    /*IF p_txmsg.deltd = 'Y' THEN
     l_trade:=p_txmsg.txfields('10').value;
     l_blocked:=p_txmsg.txfields('06').value;
     l_caqtty:=p_txmsg.txfields('13').value;

          BEGIN
                   SELECT COUNT(*) INTO L_count
                   FROM sesendout
                   WHERE
                   txdate=p_txmsg.txdate AND TXnum=p_txmsg.txnum
                   AND  ((trade >= l_trade) AND (blocked >=l_blocked) AND(caqtty>=l_caqtty))
                   AND deltd='N';
          EXCEPTION WHEN OTHERS THEN
                    p_err_code:='-200404';
                    plog.setendsection (pkgctx, 'fn_txPreAppUpdate');
                    RETURN errnums.C_BIZ_RULE_INVALID;
          END;
           IF(l_count <=0) THEN
              p_err_code := '-200404'; -- Pre-defined in DEFERROR table
              plog.setendsection (pkgctx, 'fn_txPreAppUpdate');
              RETURN errnums.C_BIZ_RULE_INVALID;
           END IF;


    END IF;*/
    plog.debug (pkgctx, '<<END OF fn_txPreAppUpdate');
    plog.setendsection (pkgctx, 'fn_txPreAppUpdate');
    RETURN systemnums.C_SUCCESS;
EXCEPTION
WHEN OTHERS
   THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error (pkgctx, SQLERRM);
       plog.setendsection (pkgctx, 'fn_txPreAppUpdate');
      RAISE errnums.E_SYSTEM_ERROR;
END fn_txPreAppUpdate;

FUNCTION fn_txAftAppUpdate(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER
IS
v_caqtty number;
v_nDEPOBLOCK number;
v_sendoutid number;
v_firm VARCHAR2(3);
v_count number;

l_RIGHTQTTY NUMBER;
l_RIGHTOFFQTTY NUMBER;
l_CAQTTYRECEIV NUMBER;
l_CAQTTYDB NUMBER;
l_CAAMTRECEIV NUMBER;
L_SEACCTNO VARCHAR2(20);
L_CODEIDWFT   VARCHAR2(6);
l_custid   VARCHAR2(60);
v_custid VARCHAR2(60);
BEGIN
    plog.setbeginsection (pkgctx, 'fn_txAftAppUpdate');
    plog.debug (pkgctx, '<<BEGIN OF fn_txAftAppUpdate');
   /***************************************************************************************************
    ** PUT YOUR SPECIFIC AFTER PROCESS HERE. DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT
    ***************************************************************************************************/
    SELECT varvalue INTO v_firm FROM sysvar  WHERE varname ='COMPANYCD' ;
    IF p_txmsg.deltd <> 'Y' THEN
      -- begin binhvt
       select af.custid into v_custid from afmast af  where af.acctno = p_txmsg.txfields('02').value;
        insert into SETYPETRF(AUTOID,NAMT,TXNUM,TXDATE,TLTXCD,TYPETRF,DELTD,Busdate,Afacctno,Custid,Depoblock,Trtype,RCUSTODYCD,INWARDNAME,INFULLNAME,AMT) valueS
        (SEQ_SETYPETRF.Nextval, p_txmsg.txfields('45').value,p_txmsg.txnum,p_txmsg.txdate,'2244',p_txmsg.txfields('99').value,'N',p_txmsg.busdate,p_txmsg.txfields('02').value,v_custid
        ,p_txmsg.txfields('06').value,p_txmsg.txfields('31').value,p_txmsg.txfields('88').value,p_txmsg.txfields('05').value,p_txmsg.txfields('49').value,p_txmsg.txfields('10').value);
         -- end binhvt

        /*UPDATE SEMASTDTL
        SET QTTY=QTTY-(p_txmsg.txfields('06').value)
        WHERE autoid =(p_txmsg.txfields('18').value);*/
        v_nDEPOBLOCK:=p_txmsg.txfields('06').value;


        --Phan bo phan chung khoan quyen, chuyen sang tai khoan nhan chuyen nhuong
        v_caqtty:= p_txmsg.txfields('13').value;

        v_sendoutid := SEQ_SESENDOUT.NEXTVAL;

        for rec in (
            select * from sepitlog where acctno = p_txmsg.txfields('03').value
            and deltd <> 'Y' and qtty - mapqtty >0 and pitrate >0
            order by txdate
        )
        loop
                --Phuc add 05/02/2021
                insert into revert_2254log(id, sepitid, qtty) values
                (seq_revert_2254log.NEXTVAL, rec.autoid,rec.mapqtty);
            if v_caqtty >= rec.qtty - rec.mapqtty then

                update sepitlog set mapqtty = mapqtty + rec.qtty - rec.mapqtty, status ='C' where autoid = rec.autoid;

                INSERT INTO se2244_log (sendoutid, codeid, camastid, afacctno, qtty, deltd, sepitid)
                    VALUES (v_sendoutid, rec.codeid, rec.camastid, rec.afacctno, rec.qtty - rec.mapqtty, 'N',rec.autoid);
                v_caqtty:=v_caqtty-(rec.qtty-rec.mapqtty);

            else

                update sepitlog set mapqtty = mapqtty + v_caqtty where autoid = rec.autoid;

                INSERT INTO se2244_log (sendoutid, codeid, camastid, afacctno, qtty, deltd, sepitid)
                    VALUES (v_sendoutid, rec.codeid, rec.camastid, rec.afacctno, v_caqtty, 'N', rec.autoid);
                v_caqtty:=0;
            end if;


            exit when v_caqtty<=0;
        end loop;
        -- insert v?SESENDOUT
          INSERT INTO SESENDOUT
          (AUTOID, TXNUM, TXDATE, ACCTNO, TRADE,
          BLOCKED,CAQTTY,STRADE,SBLOCKED,SCAQTTY,CTRADE,CBLOCKED,CCAQTTY,DELTD,STATUS,RECUSTODYCD,REAFACCTNO,RECUSTNAME,codeid,PRICE,OUTWARD,TRTYPE,QTTYTYPE,FEE,TAX,FEESV,ISTRFCA,GTCG, vsdmessagetype,reidcode,reidate,reidplace,CATAX)
          VALUES (v_sendoutid, p_txmsg.txnum,p_txmsg.txdate,p_txmsg.txfields('03').value,
          p_txmsg.txfields('10').value, p_txmsg.txfields('06').value,p_txmsg.txfields('13').value,
          0,0,0,0,0,0,'N','N',p_txmsg.txfields('88').value, p_txmsg.txfields('04').value, p_txmsg.txfields('49').value,p_txmsg.txfields('01').value,p_txmsg.txfields('09').value,p_txmsg.txfields('05').value,
          p_txmsg.txfields('31').value,p_txmsg.txfields('14').value,p_txmsg.txfields('45').value,p_txmsg.txfields('46').value,p_txmsg.txfields('57').value,'N',p_txmsg.txfields('60').value, p_txmsg.txfields('97').value,p_txmsg.txfields('50').value,p_txmsg.txfields('51').value,p_txmsg.txfields('52').value,
          to_number(p_txmsg.txfields(c_catax).value));

          --Neu cung cty tim tk nhan de tru phi
          IF p_txmsg.txfields('05').value=v_firm THEN
                UPDATE CIMAST
                SET
                         BALANCE = BALANCE - (ROUND(p_txmsg.txfields('57').value,0)), LAST_CHANGE = SYSTIMESTAMP
                WHERE ACCTNO=p_txmsg.txfields('04').value;


                INSERT INTO CITRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
                VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields ('04').value,'0011',ROUND(p_txmsg.txfields('57').value,0),NULL,'',p_txmsg.deltd,'',seq_CITRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');

            END IF;
    Else
        /*SELECT count(1) into v_count FROM sesendout WHERE txnum=p_txmsg.txnum AND txdate=p_txmsg.txdate and status <> 'N';
        if v_count>0 then
            --Giao dich da lam buoc ke tiep, khong duoc xoa.
              p_err_code := '-200404'; -- Pre-defined in DEFERROR table
              plog.setendsection (pkgctx, 'fn_txPreAppUpdate');
              RETURN errnums.C_BIZ_RULE_INVALID;
        end if;*/
        --Neu cung cty tim tk nhan de tra phi
        IF p_txmsg.txfields('05').value=v_firm THEN
                UPDATE CIMAST
                SET
                     BALANCE=BALANCE + (ROUND(p_txmsg.txfields('57').value,0)), LAST_CHANGE = SYSTIMESTAMP
                  WHERE ACCTNO=p_txmsg.txfields('04').value;
        END IF;
         for rec in (
            select * from sepitlog where acctno = p_txmsg.txfields('03').value
            and deltd <> 'Y' --and qtty - mapqtty >0
            order by txdate desc
        )
        loop
            if v_caqtty >= rec.mapqtty then

                update sepitlog set mapqtty = 0, status ='P' where autoid = rec.autoid;
                v_caqtty:=v_caqtty-rec.mapqtty;
            else

                update sepitlog set mapqtty = mapqtty - v_caqtty, status =(case when status='C' then 'N' else status end) where autoid = rec.autoid;
                v_caqtty:=0;
            end if;
            exit when v_caqtty<=0;
        end loop;


        FOR rec1 IN (SELECT * FROM sesendout WHERE txnum=p_txmsg.txnum AND txdate=p_txmsg.txdate)
        LOOP
            UPDATE sesendout SET deltd='Y' WHERE autoid = rec1.autoid;
            UPDATE se2244_log SET deltd='Y' WHERE sendoutid = rec1.autoid;
        END LOOP;

    End If;
    IF P_TXMSG.TXFIELDS('29').VALUE = '002' THEN
        UPDATE sesendout SET ISTRFCA = 'Y' WHERE txnum=p_txmsg.txnum AND txdate=p_txmsg.txdate;

   SELECT custid into  l_custid FROM cfmast WHERE custodycd =p_txmsg.txfields('15').value;


        if(p_txmsg.deltd <> 'Y') THEN
       --- v_sendoutid
       -- ghi jam so luong CA cho ve theo thu tu uu tien giong giao dich 2247
   FOR recall  IN (SELECT acctno FROM afmast WHERE custid = l_custid )
        loop

            SELECT sum(CASE WHEN (schd.catype='014' AND schd.castatus NOT IN ('A','P','N','C') AND schd.duedate >=GETCURRDATE )
                          THEN schd.pbalance ELSE 0 END) ,
                    sum(CASE WHEN (schd.catype='014' AND schd.status IN ('M','S','I','G','O','W') AND isse='N') THEN schd.qtty
                          WHEN (schd.catype IN ('017','020','023') AND schd.status IN ('G','S','I','O','W')  AND isse='N' AND istocodeid='Y') THEN schd.qtty
                          WHEN (schd.catype IN ('011','021') AND schd.status  IN ('G','S','I','O','W') AND isse='N' ) THEN schd.qtty
                          ELSE 0 END) ,
                    sum(CASE WHEN (schd.catype IN ('016') AND schd.status  IN ('G','S','I','O','W') AND isse='N') THEN nvl(se.trade,0)
                                WHEN (schd.catype IN ('017','020','023') AND schd.status  IN ('G','S','I','O','W') AND isse='N') THEN schd.aqtty
                                ELSE 0 END) ,
                    sum(CASE WHEN  (schd.status  IN ('H','S','I','O','W') AND isci='N' AND schd.isexec='Y') THEN SCHD.AMT
                                WHEN  SCHD.STATUS = 'K' THEN SCHD.AMT*(1-SCHD.EXERATE/100)
                                ELSE 0 END) ,
                    sum(CASE WHEN (schd.catype IN ('005','006','022') AND schd.status IN ('H','G','S','I','J','O','W')) THEN schd.rqtty ELSE 0 END)
                into l_RIGHTOFFQTTY, l_CAQTTYRECEIV, l_CAQTTYDB, l_CAAMTRECEIV, l_RIGHTQTTY
            FROM
                (SELECT schd.rqtty,schd.autoid,schd.status,camast.catype,camast.duedate,camast.status castatus,schd.afacctno,camast.codeid,
                camast.tocodeid, schd.camastid,schd.balance,schd.qtty,schd.aqtty,schd.amt,schd.aamt,schd.pbalance,schd.pqtty ,
                schd.isci,schd.isexec,reportdate ,'N' istocodeid, NVL(ISWFT,'Y') ISWFT, camast.optcodeid, SCHD.ISSE
                ,CAMAST.EXERATE
                FROM caschd schd ,camast WHERE schd.camastid=camast.camastid AND schd.deltd='N' AND camast.deltd='N' AND camast.status <> 'C'
                UNION ALL
                SELECT schd.rqtty,schd.autoid,  schd.status,camast.catype,camast.duedate,camast.status castatus,schd.afacctno, camast.tocodeid codeid,
                '',schd.camastid,0,schd.qtty,0,0,0,0,0,
                schd.isci,schd.isexec ,reportdate ,'Y' istocodeid, NVL(ISWFT,'Y') ISWFT, camast.optcodeid, SCHD.ISSE
                ,CAMAST.EXERATE
                FROM caschd schd, camast
                WHERE schd.camastid=camast.camastid AND camast.catype IN ('017','020','023')AND schd.deltd='N' AND camast.deltd='N' AND camast.status <> 'C'
                ) SCHD, semast se
            WHERE schd.codeid = p_txmsg.txfields('01').value
                AND  schd.afacctno = recall.acctno
                AND se.acctno(+) = (schd.afacctno||schd.codeid);
            insert into se2244_catrflog
            (sendoutid,codeid,afacctno,rightoffqtty,caqttyreceiv,caqttydb,caamtreceiv,rightqtty,deltd) VALUES
            (v_sendoutid,p_txmsg.txfields('01').value,recall.acctno||p_txmsg.txfields('01').value,l_RIGHTOFFQTTY, l_CAQTTYRECEIV, l_CAQTTYDB, l_CAAMTRECEIV, l_RIGHTQTTY,'N');
            FOR rec IN (
                          SELECT schd.status,autoid,camastid,reportdate,catype,
                          schd.codeid, schd.afacctno,(schd.afacctno||schd.codeid) seacctno,
                          (CASE WHEN (schd.catype='014' AND schd.castatus NOT IN ('A','P','N','C') AND schd.duedate >=GETCURRDATE )
                          THEN schd.pbalance ELSE 0 END) RIGHTOFFQTTY,
                          (CASE WHEN (schd.catype='014' AND schd.status IN ('M','S','I','G','O','W') AND isse='N') THEN schd.qtty
                          WHEN (schd.catype IN ('017','020','023') AND schd.status IN ('G','S','I','O','W')  AND isse='N' AND istocodeid='Y') THEN schd.qtty
                          WHEN (schd.catype IN ('011','021') AND schd.status  IN ('G','S','I','O','W') AND isse='N' ) THEN schd.qtty
                          ELSE 0 END) CAQTTYRECEIV,
                          (CASE WHEN (schd.catype IN ('016') AND schd.status  IN ('G','S','I','O','W') AND isse='N') THEN nvl(se.trade,0)
                                WHEN (schd.catype IN ('017','020','023') AND schd.status  IN ('G','S','I','O','W') AND isse='N') THEN schd.aqtty
                                ELSE 0 END) CAQTTYDB,
                          (CASE  WHEN (schd.catype IN ('016') AND schd.status  IN ('G','S','I','O','W') AND isse='N' ) THEN 1 ELSE 0 END) ISDBSEALL,
                          (CASE WHEN  (schd.status  IN ('H','S','I','O','W') AND isci='N' AND schd.isexec='Y') THEN SCHD.AMT
                                WHEN  SCHD.STATUS = 'K' THEN SCHD.AMT*(1-SCHD.EXERATE/100)
                                ELSE 0 END) CAAMTRECEIV,
                          (CASE WHEN (schd.catype IN ('005','006','022') AND schd.status IN ('H','G','S','I','J','O','W')) THEN schd.rqtty ELSE 0 END) RIGHTQTTY,
                          ISWFT,optcodeid,schd.trade
                          FROM
                                (SELECT schd.rqtty,schd.autoid,schd.status,camast.catype,camast.duedate,camast.status castatus,schd.afacctno,camast.codeid,
                                camast.tocodeid, schd.camastid,schd.balance,schd.qtty,schd.aqtty,schd.amt,schd.aamt,schd.pbalance,schd.pqtty ,
                                schd.isci,schd.isexec,reportdate ,'N' istocodeid, NVL(ISWFT,'Y') ISWFT, camast.optcodeid, SCHD.ISSE,schd.trade
                                ,CAMAST.EXERATE
                                FROM caschd schd ,camast WHERE schd.camastid=camast.camastid AND schd.deltd='N' AND camast.deltd='N' AND camast.status <> 'C'
                                UNION ALL
                                SELECT schd.rqtty,schd.autoid,  schd.status,camast.catype,camast.duedate,camast.status castatus,schd.afacctno, camast.tocodeid codeid,
                                '',schd.camastid,0,schd.qtty,0,0,0,0,0,
                                schd.isci,schd.isexec ,reportdate ,'Y' istocodeid, NVL(ISWFT,'Y') ISWFT, camast.optcodeid, SCHD.ISSE,schd.trade
                                ,CAMAST.EXERATE
                                FROM caschd schd, camast
                                WHERE schd.camastid=camast.camastid AND camast.catype IN ('017','020','023')AND schd.deltd='N' AND camast.deltd='N' AND camast.status <> 'C'
                                ) SCHD, semast se
                           WHERE schd.codeid=p_txmsg.txfields('01').value
                           AND  schd.afacctno=recall.acctno
                           AND se.acctno(+)=(schd.afacctno||schd.codeid)
                          ORDER BY reportdate
                       )
            LOOP
                     IF ( LEAST(rec.RIGHTQTTY,l_RIGHTQTTY)+LEAST(rec.RIGHTOFFQTTY,l_RIGHTOFFQTTY)+
                          LEAST(rec.CAQTTYRECEIV,l_CAQTTYRECEIV)+LEAST(rec.CAQTTYDB,l_CAQTTYDB)+
                          LEAST(rec.CAAMTRECEIV,l_CAAMTRECEIV)> 0) THEN
                        if(rec.catype <> '016') THEN
                             if(rec.status <> 'O' ) THEN
                                 UPDATE caschd SET status='O',pbalance=pbalance-least(rec.RIGHTOFFQTTY,l_RIGHTOFFQTTY),
                                                   qtty=qtty-least(rec.CAQTTYRECEIV,l_CAQTTYRECEIV),
                                                   rqtty=rqtty-least(rec.RIGHTQTTY,l_RIGHTQTTY),
                                                   aqtty=aqtty-least(rec.CAQTTYDB,l_CAQTTYDB),
                                                   amt=amt-least(rec.CAAMTRECEIV,l_CAAMTRECEIV),
                                                   SENDPBALANCE=SENDPBALANCE+least(rec.RIGHTOFFQTTY,l_RIGHTOFFQTTY),
                                                   SENDQTTY=SENDQTTY+least(rec.CAQTTYRECEIV,l_CAQTTYRECEIV)
                                                   +least(rec.RIGHTQTTY,l_RIGHTQTTY),
                                                   SENDAQTTY=SENDAQTTY+least(rec.CAQTTYDB,l_CAQTTYDB),
                                                   SENDAMT=SENDAMT+least(rec.CAAMTRECEIV,l_CAAMTRECEIV),
                                                   pstatus= pstatus||status
                                  WHERE autoid=rec.autoid;
                              ELSE
                                  UPDATE caschd SET pbalance=pbalance-least(rec.RIGHTOFFQTTY,l_RIGHTOFFQTTY),
                                                   qtty=qtty-least(rec.CAQTTYRECEIV,l_CAQTTYRECEIV),
                                                   rqtty=rqtty-least(rec.RIGHTQTTY,l_RIGHTQTTY),
                                                   aqtty=aqtty-least(rec.CAQTTYDB,l_CAQTTYDB),
                                                   amt=amt-least(rec.CAAMTRECEIV,l_CAAMTRECEIV),
                                                   SENDPBALANCE=SENDPBALANCE+least(rec.RIGHTOFFQTTY,l_RIGHTOFFQTTY),
                                                   SENDQTTY=SENDQTTY+least(rec.CAQTTYRECEIV,l_CAQTTYRECEIV)
                                                   +least(rec.RIGHTQTTY,l_RIGHTQTTY),
                                                   SENDAQTTY=SENDAQTTY+least(rec.CAQTTYDB,l_CAQTTYDB),
                                                   SENDAMT=SENDAMT+least(rec.CAAMTRECEIV,l_CAAMTRECEIV)
                                  WHERE autoid=rec.autoid;
                              END IF;
                        ELSE -- su kien tra goc lai trai phieu: khong tru o aqtty
                            if(rec.status <> 'O' ) THEN
                                 UPDATE caschd SET status='O',pbalance=pbalance-least(rec.RIGHTOFFQTTY,l_RIGHTOFFQTTY),
                                                   qtty=qtty-least(rec.CAQTTYRECEIV,l_CAQTTYRECEIV),
                                                   rqtty=rqtty-least(rec.RIGHTQTTY,l_RIGHTQTTY),
                                                   amt=amt-least(rec.CAAMTRECEIV,l_CAAMTRECEIV),
                                                   SENDPBALANCE=SENDPBALANCE+least(rec.RIGHTOFFQTTY,l_RIGHTOFFQTTY),
                                                   SENDQTTY=SENDQTTY+least(rec.CAQTTYRECEIV,l_CAQTTYRECEIV)
                                                   +least(rec.RIGHTQTTY,l_RIGHTQTTY),
                                                   SENDAQTTY=SENDAQTTY+least(rec.CAQTTYDB,l_CAQTTYDB),
                                                   SENDAMT=SENDAMT+least(rec.CAAMTRECEIV,l_CAAMTRECEIV),
                                                   pstatus= pstatus||status
                                  WHERE autoid=rec.autoid;
                              ELSE
                                  UPDATE caschd SET pbalance=pbalance-least(rec.RIGHTOFFQTTY,l_RIGHTOFFQTTY),
                                                   qtty=qtty-least(rec.CAQTTYRECEIV,l_CAQTTYRECEIV),
                                                   rqtty=rqtty-least(rec.RIGHTQTTY,l_RIGHTQTTY),
                                                   amt=amt-least(rec.CAAMTRECEIV,l_CAAMTRECEIV),
                                                   SENDPBALANCE=SENDPBALANCE+least(rec.RIGHTOFFQTTY,l_RIGHTOFFQTTY),
                                                   SENDQTTY=SENDQTTY+least(rec.CAQTTYRECEIV,l_CAQTTYRECEIV)
                                                   +least(rec.RIGHTQTTY,l_RIGHTQTTY),
                                                   SENDAQTTY=SENDAQTTY+least(rec.CAQTTYDB,l_CAQTTYDB),
                                                   SENDAMT=SENDAMT+least(rec.CAAMTRECEIV,l_CAAMTRECEIV)
                                  WHERE autoid=rec.autoid;
                              END IF;
                        END IF;
                         -- CAT RECEIVING TRONG SEMAST
                        IF(LEAST(rec.CAQTTYRECEIV,l_CAQTTYRECEIV) >0) THEN
                            IF(REC.ISWFT='Y') THEN
                               SELECT CODEID INTO L_CODEIDWFT FROM SBSECURITIES WHERE REFCODEID=REC.CODEID;
                               l_SEACCTNO:=REC.AFACCTNO||L_CODEIDWFT;
                            ELSE
                               l_SEACCTNO:=REC.AFACCTNO||REC.CODEID;
                            END IF;
                            UPDATE SEMAST SET RECEIVING=RECEIVING-LEAST(rec.CAQTTYRECEIV,l_CAQTTYRECEIV)
                            WHERE ACCTNO=l_SEACCTNO;
                             INSERT INTO SETRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
                             VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),l_SEACCTNO,
                             '0015',LEAST(rec.CAQTTYRECEIV,l_CAQTTYRECEIV),NULL,NULL,p_txmsg.deltd,NULL,seq_SETRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');

                          -- neu la sk quyen mua: tru o semast cua ck quyen
                        if(rec.optcodeid IS NOT NULL ) THEN
                          UPDATE semast SET trade=trade-least(rec.CAQTTYRECEIV,l_CAQTTYRECEIV)
                          WHERE acctno=rec.afacctno||rec.optcodeid;

                          INSERT INTO SETRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
                             VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),rec.afacctno||rec.optcodeid,
                             '0040',LEAST(rec.CAQTTYRECEIV,l_CAQTTYRECEIV),NULL,NULL,p_txmsg.deltd,NULL,seq_SETRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');
                        END IF;

                        END IF;

                        l_RIGHTQTTY :=l_RIGHTQTTY-LEAST(rec.RIGHTQTTY,l_RIGHTQTTY);
                        l_RIGHTOFFQTTY :=l_RIGHTOFFQTTY-LEAST(rec.RIGHTOFFQTTY,l_RIGHTOFFQTTY);
                        l_CAQTTYRECEIV :=l_CAQTTYRECEIV-LEAST(rec.CAQTTYRECEIV,l_CAQTTYRECEIV);
                        l_CAQTTYDB :=l_CAQTTYDB-LEAST(rec.CAQTTYDB,l_CAQTTYDB);
                        l_CAAMTRECEIV :=l_CAAMTRECEIV-LEAST(rec.CAAMTRECEIV,l_CAAMTRECEIV);

                     INSERT INTO catrflog (AUTOID,TXDATE,TXNUM,CAMASTID,OPTSEACCTNOCR,OPTSEACCTNODR,CODEID,OPTCODEID,balance,AMT,qtty,CUSTODYCDCR,CUSTODYCDDR,STATUS)
                       VALUES(seq_catrflog.NEXTVAL,TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txnum,rec.camastid,null,rec.seacctno,rec.codeid,rec.codeid,
                      rec.trade,rec.CAAMTRECEIV,rec.RIGHTQTTY+ rec.CAQTTYRECEIV+rec.RIGHTOFFQTTY ,p_txmsg.txfields('88').value,p_txmsg.txfields('15').value,'N');

                        EXIT WHEN (l_RIGHTQTTY+l_RIGHTOFFQTTY+l_CAQTTYRECEIV+l_CAQTTYDB+l_CAAMTRECEIV=0);
                    END IF;


         END LOOP;
        END LOOP;
        ELSE -- xoa jao dich
      -- begin binhvt 09-2016
        UPDATE SETYPETRF set DELTD = 'Y' where txnum = P_TXMSG.TXNUM AND TXDATE=P_TXMSG.TXDATE;
        -- end binhvt

    FOR recall  IN (SELECT acctno FROM afmast WHERE custid = l_custid )
        LOOP

            FOR rec1 IN (SELECT * FROM sesendout WHERE txnum=p_txmsg.txnum AND txdate=p_txmsg.txdate)
            LOOP
                select rightoffqtty,caqttyreceiv,caqttydb,caamtreceiv,rightqtty
                into l_RIGHTOFFQTTY, l_CAQTTYRECEIV, l_CAQTTYDB, l_CAAMTRECEIV, l_RIGHTQTTY
                from se2244_catrflog
                where sendoutid = rec1.autoid AND SUBSTR( afacctno,1,10) = recall.acctno   ;
                UPDATE se2244_catrflog SET deltd='Y' WHERE sendoutid = rec1.autoid;
            END LOOP;

                FOR rec IN (
                     SELECT schd.autoid, schd.codeid, schd.afacctno,(schd.afacctno||schd.codeid) seacctno,
                     schd.SENDPBALANCE  RIGHTOFFQTTY,
                     schd.SENDAMT CAAMTRECEIV,
                     schd.SENDAQTTY CAQTTYDB,
                     (CASE WHEN (ca.catype IN ('005','006','022')) THEN schd.SENDQTTY ELSE 0 END) RIGHTQTTY,
                     (CASE WHEN (ca.catype NOT IN ('005','006','022'))THEN schd.SENDQTTY ELSE 0 END) CAQTTYRECEIV,
                     ca.catype,ISWFT,optcodeid
                    FROM (
                    SELECT schd.autoid,schd.status,camast.catype,camast.duedate,camast.status castatus,schd.afacctno,camast.codeid,
                    camast.tocodeid, schd.camastid,schd.balance,schd.qtty,schd.aqtty,schd.amt,schd.aamt,schd.pbalance,schd.pqtty ,
                    schd.isci,schd.isse ,SENDPBALANCE,SENDAMT,SENDAQTTY,
                    (CASE WHEN (catype IN ('017','020','023')) THEN 0 ELSE SENDQTTY END )SENDQTTY
                    FROM caschd schd ,camast WHERE schd.status='O' AND schd.camastid=camast.camastid AND schd.deltd='N' AND camast.deltd='N' AND camast.status <> 'C'
                    UNION ALL
                    SELECT schd.autoid,  schd.status,camast.catype,camast.duedate,camast.status castatus,schd.afacctno, camast.tocodeid codeid,
                    '',schd.camastid,0,schd.qtty,0,0,0,0,0,
                    schd.isci,schd.isse  ,0,0,0,  SENDQTTY
                    FROM caschd schd, camast
                    WHERE schd.status='O' AND schd.camastid=camast.camastid AND camast.catype IN ('017','020','023')AND schd.deltd='N' AND camast.deltd='N' AND camast.status <> 'C'
                     ) schd, camast ca
                      WHERE schd.camastid=ca.camastid
                                        and schd.codeid=p_txmsg.txfields('01').value
                      AND  schd.afacctno=recall.acctno
                      ORDER BY reportdate
                   )
                LOOP
                if(rec.catype <> '016') THEN
                      UPDATE caschd SET  status=SUBSTR(pstatus,LENGTH(pstatus)),
                                         pbalance=pbalance+least(rec.RIGHTOFFQTTY,l_RIGHTOFFQTTY),
                                         qtty=qtty+least(rec.CAQTTYRECEIV,l_CAQTTYRECEIV),
                                         rqtty=rqtty+ least(rec.RIGHTQTTY,l_RIGHTQTTY),
                                         aqtty=aqtty+least(rec.CAQTTYDB,l_CAQTTYDB),
                                         amt=amt+least(rec.CAAMTRECEIV,l_CAAMTRECEIV),
                                         SENDPBALANCE=SENDPBALANCE-least(rec.RIGHTOFFQTTY,l_RIGHTOFFQTTY),
                                         SENDQTTY=SENDQTTY-least(rec.CAQTTYRECEIV,l_CAQTTYRECEIV)
                                         -least(rec.RIGHTQTTY,l_RIGHTQTTY),
                                         SENDAQTTY=SENDAQTTY-least(rec.CAQTTYDB,l_CAQTTYDB),
                                         SENDAMT=SENDAMT-least(rec.CAAMTRECEIV,l_CAAMTRECEIV),
                                         pstatus=pstatus||status
                        WHERE autoid=rec.autoid;
                  ELSE -- su kien tra goc lai trai phieu ko update o AQTTY
                         UPDATE caschd SET  status=SUBSTR(pstatus,LENGTH(pstatus)),
                                         pbalance=pbalance+least(rec.RIGHTOFFQTTY,l_RIGHTOFFQTTY),
                                         qtty=qtty+least(rec.CAQTTYRECEIV,l_CAQTTYRECEIV),
                                         rqtty=rqtty+ least(rec.RIGHTQTTY,l_RIGHTQTTY),
                                         amt=amt+least(rec.CAAMTRECEIV,l_CAAMTRECEIV),
                                         SENDPBALANCE=SENDPBALANCE-least(rec.RIGHTOFFQTTY,l_RIGHTOFFQTTY),
                                         SENDQTTY=SENDQTTY-least(rec.CAQTTYRECEIV,l_CAQTTYRECEIV)
                                         -least(rec.RIGHTQTTY,l_RIGHTQTTY),
                                         SENDAQTTY=SENDAQTTY-least(rec.CAQTTYDB,l_CAQTTYDB),
                                         SENDAMT=SENDAMT-least(rec.CAAMTRECEIV,l_CAAMTRECEIV),
                                         pstatus=pstatus||status
                        WHERE autoid=rec.autoid;
                  END IF;
                   -- CONG RECEIVING TRONG SEMAST
                        IF(LEAST(rec.CAQTTYRECEIV,l_CAQTTYRECEIV) >0) THEN
                            IF(REC.ISWFT='Y') THEN
                               SELECT CODEID INTO L_CODEIDWFT FROM SBSECURITIES WHERE REFCODEID=REC.CODEID;
                               l_SEACCTNO:=REC.AFACCTNO||L_CODEIDWFT;
                            ELSE
                               l_SEACCTNO:=REC.AFACCTNO||REC.CODEID;
                            END IF;
                            UPDATE SEMAST SET RECEIVING=RECEIVING+LEAST(rec.CAQTTYRECEIV,l_CAQTTYRECEIV)
                            WHERE ACCTNO=l_SEACCTNO;

                       IF(REC.OPTCODEID IS NOT NULL ) THEN
                          UPDATE SEMAST SET TRADE=TRADE+LEAST(REC.CAQTTYRECEIV,L_CAQTTYRECEIV)
                          WHERE ACCTNO=REC.AFACCTNO||REC.OPTCODEID;
                          UPDATE setran SET deltd ='Y' WHERE TXNUM = P_TXMSG.TXNUM AND TXDATE =TO_DATE (P_TXMSG.TXDATE, SYSTEMNUMS.C_DATE_FORMAT);

                        END IF;
                        END IF;

                    l_RIGHTQTTY :=l_RIGHTQTTY-LEAST(rec.RIGHTQTTY,l_RIGHTQTTY);
                    l_RIGHTOFFQTTY :=l_RIGHTOFFQTTY-LEAST(rec.RIGHTOFFQTTY,l_RIGHTOFFQTTY);
                    l_CAQTTYRECEIV :=l_CAQTTYRECEIV-LEAST(rec.CAQTTYRECEIV,l_CAQTTYRECEIV);
                    l_CAQTTYDB :=l_CAQTTYDB-LEAST(rec.CAQTTYDB,l_CAQTTYDB);
                    l_CAAMTRECEIV :=l_CAAMTRECEIV-LEAST(rec.CAAMTRECEIV,l_CAAMTRECEIV);
                    EXIT WHEN (l_RIGHTQTTY+l_RIGHTOFFQTTY+l_CAQTTYRECEIV+l_CAQTTYDB+l_CAAMTRECEIV=0);
                END LOOP;
         END LOOP;
           DELETE FROM  catrflog WHERE TXNUM =p_txmsg.txnum AND TXDATE = TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT);
        END IF;
    END IF;

    plog.debug (pkgctx, '<<END OF fn_txAftAppUpdate');
    plog.setendsection (pkgctx, 'fn_txAftAppUpdate');
    RETURN systemnums.C_SUCCESS;
EXCEPTION
WHEN OTHERS
   THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
---      plog.error (pkgctx, SQLERRM);
      plog.error (pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
       plog.setendsection (pkgctx, 'fn_txAftAppUpdate');
      RAISE errnums.E_SYSTEM_ERROR;
END fn_txAftAppUpdate;

BEGIN
      FOR i IN (SELECT *
                FROM tlogdebug)
      LOOP
         logrow.loglevel    := i.loglevel;
         logrow.log4table   := i.log4table;
         logrow.log4alert   := i.log4alert;
         logrow.log4trace   := i.log4trace;
      END LOOP;
      pkgctx    :=
         plog.init ('TXPKS_#2244EX',
                    plevel => NVL(logrow.loglevel,30),
                    plogtable => (NVL(logrow.log4table,'N') = 'Y'),
                    palert => (NVL(logrow.log4alert,'N') = 'Y'),
                    ptrace => (NVL(logrow.log4trace,'N') = 'Y')
            );
END TXPKS_#2244EX;
/
