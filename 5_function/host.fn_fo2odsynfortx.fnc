SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_fo2odsynfortx (p_orderid varchar2) return long
   IS
      l_txmsg               tx.msg_rectype;
      l_orders_cache_size   NUMBER (10) := 10000;
      l_commit_freq         NUMBER (10) := 10;
      l_count               NUMBER (10) := 0;
      l_order_count         NUMBER (10) := 0;
      l_err_param           deferror.errdesc%TYPE;

      l_mktstatus           ordersys.sysvalue%TYPE;
      l_atcstarttime        sysvar.varvalue%TYPE;

      l_typebratio          odtype.bratio%TYPE;
      l_afbratio            afmast.bratio%TYPE;
      l_securedratio        odtype.bratio%TYPE;
      l_actype              odtype.actype%TYPE;
      l_remainqtty          odmast.orderqtty%TYPE;
      l_fullname            cfmast.fullname%TYPE;

      l_feeamountmin        NUMBER;
      l_feerate             NUMBER;
      l_feesecureratiomin   NUMBER;
      l_hosebreakingsize    NUMBER;
      l_breakingsize        NUMBER;
      l_strMarginType       mrtype.mrtype%TYPE;
      l_dblMarginRatioRate  afserisk.MRRATIOLOAN%TYPE;
      l_dblSecMarginPrice   afserisk.MRPRICELOAN%TYPE;
      l_dblIsPPUsed         mrtype.ISPPUSED%TYPE;
      l_strEXECTYPE         odmast.exectype%TYPE;
      p_err_code            VARCHAR2(1000);
      pkgctx   plog.log_ctx:= plog.init ('pr_fo2odsynfortx',
                 plevel => 30,
                 plogtable => true,
                 palert => false,
                 ptrace => false);
      logrow   tlogdebug%ROWTYPE;


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
         plog.init ('pr_fo2odsynfortx',
                    plevel => NVL(logrow.loglevel,30),
                    plogtable => (NVL(logrow.log4table,'N') = 'Y'),
                    palert => (NVL(logrow.log4alert,'N') = 'Y'),
                    ptrace => (NVL(logrow.log4trace,'N') = 'Y')
            );

        p_err_code := 0;
      plog.setbeginsection (pkgctx, 'pr_fo2odsynfortx');
      plog.debug (pkgctx, 'BEGIN OF pr_fo2odsynfortx');
      /***************************************************************************************************
       ** PUT YOUR CODE HERE, FOLLOW THE BELOW TEMPLATE:
       ** IF NECCESSARY, USING BULK COLLECTION IN THE CASE YOU MUST POPULATE LARGE DATA
      ****************************************************************************************************/
      l_atcstarttime      :=
         cspks_system.fn_get_sysvar ('SYSTEM', 'ATCSTARTTIME');
      l_hosebreakingsize   :=
         cspks_system.fn_get_sysvar ('SYSTEM', 'HOSEBREAKSIZE');

      plog.debug (pkgctx,
                     'got l_atcstarttime,l_hosebreakingsize,l_commit_freq'
                  || l_atcstarttime
                  || ','
                  || l_hosebreakingsize
                  || ','
                  || l_commit_freq
      );
      -- 1. Set common values
      l_txmsg.brid        := systemnums.c_ho_brid;
      l_txmsg.tlid        := systemnums.c_system_userid;
      l_txmsg.off_line    := 'N';
      l_txmsg.deltd       := txnums.c_deltd_txnormal;
      l_txmsg.txstatus    := txstatusnums.c_txcompleted;
      l_txmsg.msgsts      := '0';
      l_txmsg.ovrsts      := '0';
      l_txmsg.batchname   := 'AUTO';

      SELECT SYS_CONTEXT ('USERENV', 'HOST'),
             SYS_CONTEXT ('USERENV', 'IP_ADDRESS', 15)
      INTO l_txmsg.wsname, l_txmsg.ipaddress
      FROM DUAL;

      plog.debug (pkgctx,
                     'wsname,ipaddress:'
                  || l_txmsg.wsname
                  || ','
                  || l_txmsg.ipaddress
      );

      -- 2. Set specific value for each transaction
      for l_build_msg in
      (
         SELECT  a.codeid fld01,
                 a.symbol fld07,
                 DECODE (a.exectype, 'MS', '1', '0') fld60, --ismortage   fld60, -- FOR 8885
                 a.actype fld02,
                 a.afacctno || a.codeid fld06,                --seacctno    fld06,
                 a.afacctno fld03,
                 a.timetype fld20,
                 a.effdate fld19,
                 a.expdate fld21,
                 a.exectype fld22,
                 a.outpriceallow fld34,
                 a.nork fld23,
                 a.matchtype fld24,
                 a.via fld25,
                 a.clearday fld10,
                 a.clearcd fld26,
                 'O' fld72,                                       --puttype fld72,
                 a.pricetype fld27,
                 a.quantity fld12,                      --a.ORDERQTTY       fld12,
                 a.quoteprice fld11,
                 0 fld18,                               --a.ADVSCRAMT       fld18,
                 0 fld17,                               --a.ORGQUOTEPRICE   fld17,
                 0 fld16,                               --a.ORGORDERQTTY    fld16,
                 0 fld31,                               --a.ORGSTOPPRICE    fld31,
                 a.bratio fld13,
                 0 fld14,                               --a.LIMITPRICE      fld14,
                 0 fld40,                                                -- FEEAMT
                 a.reforderid fld08,
                 b.parvalue fld15,
                 a.dfacctno fld95,
                 100 fld99,                             --a.HUNDRED         fld99,
                 c.tradeunit fld98,
                 1 fld96,                                                   -- GTC
                 '' fld97,                                                  --mode
                 '' fld33,                                              --clientid
                 '' fld73,                                            --contrafirm
                 '' fld32,                                              --traderid
                 '' fld71,                                             --contracus
                 a.acctno,                              -- only for test mktstatus
                 '' fld30,                              --a.DESC            fld30,
                 a.refacctno,
                 a.orgacctno,
                 a.refprice,
                 a.refquantity,
                 c.ceilingprice,
                 c.floorprice,
                 c.marginprice,
                 b.tradeplace,
                 b.sectype,
                 c.tradelot,
                 c.securedratiomin,
                 c.securedratiomax,
                 a.SPLOPT,
                 a.SPLVAL,
                 a.username,
                 a.SSAFACCTNO fld94

          FROM fomast a, sbsecurities b, securities_info c
          WHERE     a.book = 'A'
                AND a.timetype <> 'G'
                AND a.status = 'P'
                and a.direct='Y'
                AND a.codeid = b.codeid
                AND a.codeid = c.codeid
                and a.acctno = p_orderid
      )
      LOOP
            BEGIN
               -- Check Market status
               SELECT sysvalue
               INTO l_mktstatus
               FROM ordersys
               WHERE sysname = 'CONTROLCODE';

               plog.debug (pkgctx,
                              'l_mktstatus,pricetype: '
                           || l_mktstatus
                           || ','
                           || l_build_msg.fld27
               );

               -- l_mktstatus=P: 8h30-->9h00 session 1 ATO
               -- l_mktstatus=O: 9h00-->10h15 session 2 MP
               -- l_mktstatus=A: 10h15-->10h30 session 3 ATC

               -- </ TruongLD Add
               l_txmsg.tlid := l_build_msg.username;
               --/>

               IF l_build_msg.fld27 = 'ATO'
               THEN                                        -- fld27: pricetype
                  IF l_mktstatus IN ('O', 'A')
                  THEN
                     RAISE errnums.e_invalid_session;
                  END IF;

               ELSIF l_build_msg.fld27 = 'ATC'
               THEN
                  IF not(l_mktstatus = 'A'
                            or (l_mktstatus = 'O'
                                    AND l_atcstarttime <=
                                        TO_CHAR (SYSDATE, 'HH24MISS')))
                  THEN
                     RAISE errnums.e_invalid_session;
                  END IF;
               ELSIF l_build_msg.fld27 = 'MO'
               THEN
                  IF l_mktstatus <> 'O'
                  THEN
                     RAISE errnums.e_invalid_session;
                  END IF;
               END IF;

               plog.debug (pkgctx,
                           'length(truong 22): ' || 'a'
               );

               l_txmsg.txfields ('22').VALUE     := l_build_msg.fld22; --set vale for Execution TYPE
               plog.debug (pkgctx,
                           'exectype1: ' || l_txmsg.txfields ('22').VALUE
               );
               l_strEXECTYPE:=l_build_msg.fld22;
               plog.debug (pkgctx,
                           'exectype: ' || l_txmsg.txfields ('22').VALUE
               );

               IF LENGTH (l_build_msg.refacctno) > 0
               THEN                                             --lENH HUY SUA
                  FOR i IN (SELECT exectype
                            FROM fomast
                            WHERE orgacctno = l_build_msg.refacctno)
                  LOOP
                     --l_txmsg.txfields ('22').VALUE   := i.exectype;
                     l_strEXECTYPE:=i.exectype;
                     plog.debug (pkgctx,
                                 'cancel orders, set exectype: '
                                 || l_txmsg.txfields('22').VALUE
                     );
                  END LOOP;
               END IF;

               IF l_build_msg.fld27 <> 'LO'
               THEN                                               -- Pricetype
                  IF l_strEXECTYPE='NB'--l_build_msg (indx).fld22 = 'NB'
                  THEN                                             -- exectype
                     l_build_msg.fld11   :=
                        l_build_msg.ceilingprice
                        / l_build_msg.fld98;                --tradeunit
                  ELSE
                     l_build_msg.fld11   :=
                        l_build_msg.floorprice
                        / l_build_msg.fld98;
                  END IF;
               END IF;

               plog.debug (pkgctx, 'ACCTNO: ' || l_build_msg.fld03);

               /*FOR i IN (SELECT mst.bratio, cf.custodycd, cf.fullname, mst.actype
                         FROM afmast mst, cfmast cf
                         WHERE acctno = l_build_msg (indx).fld03
                               AND mst.custid = cf.custid)
               LOOP
                  l_txmsg.txfields ('09').VALUE   := i.custodycd;
                  l_actype                        := i.actype;
                  l_afbratio                      := i.bratio;
                  l_txmsg.txfields ('50').VALUE   := i.fullname;
               END LOOP;*/

               FOR i IN (SELECT MST.BRATIO, CF.CUSTODYCD,CF.FULLNAME,MST.ACTYPE,MRT.MRTYPE,MRT.ISPPUSED,
                        NVL(RSK.MRRATIOLOAN,0) MRRATIOLOAN, NVL(MRPRICELOAN,0) MRPRICELOAN
                        FROM AFMAST MST, CFMAST CF ,AFTYPE AFT, MRTYPE MRT,
                        (SELECT * FROM AFSERISK WHERE CODEID=l_build_msg.fld01 ) RSK
                        WHERE MST.ACCTNO=l_build_msg.fld03
                        AND MST.CUSTID=CF.CUSTID
                        and mst.actype =aft.actype and aft.mrtype = mrt.actype
                        AND AFT.ACTYPE =RSK.ACTYPE(+))
               LOOP
                  l_txmsg.txfields ('09').VALUE   := i.custodycd;
                  l_actype                        := i.actype;
                  l_afbratio                      := i.bratio;
                  l_txmsg.txfields ('50').VALUE   := 'FO';
                  l_fullname                      := i.fullname;
                  l_strMarginType                 := i.MRTYPE;
                  l_dblMarginRatioRate            := i.MRRATIOLOAN;
                  l_dblSecMarginPrice             := i.MRPRICELOAN;
                  l_dblIsPPUsed                   := i.ISPPUSED;
                  If l_dblMarginRatioRate >= 100 Or l_dblMarginRatioRate < 0
                  Then
                        l_dblMarginRatioRate := 0;
                  END IF;
                  if l_build_msg.marginprice > l_dblSecMarginPrice
                  then
                        l_dblSecMarginPrice := l_dblSecMarginPrice;
                  else
                        l_dblSecMarginPrice := l_build_msg.marginprice;
                  end if;
               END LOOP;


               plog.debug (pkgctx, 'VIA: ' || l_build_msg.fld25);
               plog.debug (pkgctx, 'CLEARCD: ' || l_build_msg.fld26);
               plog.debug (pkgctx, 'EXECTYPE: ' || l_build_msg.fld22);
               plog.debug (pkgctx, 'TIMETYPE: ' || l_build_msg.fld20);
               plog.debug (pkgctx, 'PRICETYPE: ' || l_build_msg.fld27);
               plog.debug (pkgctx, 'MATCHTYPE: ' || l_build_msg.fld24);
               plog.debug (pkgctx, 'NORK: ' || l_build_msg.fld23);
               plog.debug (pkgctx, 'sectype: ' || l_build_msg.sectype);
               plog.debug (pkgctx,
                           'tradeplace: ' || l_build_msg.tradeplace
               );

               BEGIN
/* vinh comment de cap nhat tinh nang nhieu bieu phi
                  SELECT actype, clearday, bratio, minfeeamt, deffeerate
                  --to_char(sysdate,systemnums.C_TIME_FORMAT) TXTIME
                  INTO l_txmsg.txfields ('02').VALUE,                 --ACTYPE
                       l_txmsg.txfields ('10').VALUE,               --CLEARDAY
                       l_typebratio,                          --BRATIO (fld13)
                       l_feeamountmin,
                       l_feerate
                  FROM odtype a
                  WHERE     status = 'Y'
                        AND (via = l_build_msg.fld25 OR via = 'A') --VIA
                        AND clearcd = l_build_msg.fld26       --CLEARCD
                        AND (exectype = l_strEXECTYPE           --l_build_msg.fld22
                             OR exectype = 'AA')                    --EXECTYPE
                        AND (timetype = l_build_msg.fld20
                             OR timetype = 'A')                     --TIMETYPE
                        AND (pricetype = l_build_msg.fld27
                             OR pricetype = 'AA')                  --PRICETYPE
                        AND (matchtype = l_build_msg.fld24
                             OR matchtype = 'A')                   --MATCHTYPE
                        AND (tradeplace = l_build_msg.tradeplace
                             OR tradeplace = '000')
--                        AND (sectype = l_build_msg.sectype
--                             OR sectype = '000')
                        AND (instr(case when l_build_msg.sectype in ('001','002','008') then l_build_msg.sectype || ',' || '111'
                                       when l_build_msg.sectype in ('003','006') then l_build_msg.sectype || ',' || '222'
                                       else l_build_msg.sectype end , sectype)>0 OR sectype = '000')
                        AND (nork = l_build_msg.fld23 OR nork = 'A') --NORK
                        AND EXISTS
                              (SELECT 1
                               FROM afidtype
                               WHERE     objname = 'OD.ODTYPE'
                                     AND aftype = l_actype
                                     AND actype = a.actype);
*/
                  SELECT actype, clearday, bratio, minfeeamt, deffeerate
                  --to_char(sysdate,systemnums.C_TIME_FORMAT) TXTIME
                  INTO l_txmsg.txfields ('02').VALUE,                 --ACTYPE
                       l_txmsg.txfields ('10').VALUE,               --CLEARDAY
                       l_typebratio,                          --BRATIO (fld13)
                       l_feeamountmin,
                       l_feerate
                  FROM (SELECT a.actype, a.clearday, a.bratio, a.minfeeamt, a.deffeerate, b.ODRNUM
                  FROM odtype a, afidtype b
                  WHERE     a.status = 'Y'
                        AND (a.via = l_build_msg.fld25 OR a.via = 'A') --VIA
                        AND a.clearcd = l_build_msg.fld26       --CLEARCD
                        AND (a.exectype = l_strEXECTYPE           --l_build_msg.fld22
                             OR a.exectype = 'AA')                    --EXECTYPE
                        AND (a.timetype = l_build_msg.fld20
                             OR a.timetype = 'A')                     --TIMETYPE
                        AND (a.pricetype = l_build_msg.fld27
                             OR a.pricetype = 'AA')                  --PRICETYPE
                        AND (a.matchtype = l_build_msg.fld24
                             OR a.matchtype = 'A')                   --MATCHTYPE
                        AND (a.tradeplace = l_build_msg.tradeplace
                             OR a.tradeplace = '000')
--                        AND (sectype = l_build_msg.sectype
--                             OR sectype = '000')
                        AND (instr(case when l_build_msg.sectype in ('001','002') then l_build_msg.sectype || ',' || '111,333'
                                       when l_build_msg.sectype in ('003','006') then l_build_msg.sectype || ',' || '222,333,444'
                                       when l_build_msg.sectype in ('008') then l_build_msg.sectype || ',' || '111,444'
                                       else l_build_msg.sectype end, a.sectype)>0 OR a.sectype = '000')
                        AND (a.nork = l_build_msg.fld23 OR a.nork = 'A') --NORK
                        AND (CASE WHEN A.CODEID IS NULL THEN l_build_msg.fld01 ELSE A.CODEID END)=l_build_msg.fld01
                        AND a.actype = b.actype and b.aftype=l_actype and b.objname='OD.ODTYPE'
                        order by b.odrnum desc) where rownum<=1;
               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                  RAISE errnums.e_od_odtype_notfound;
               END;

               plog.debug (pkgctx,
                           'ACTYPE: ' || l_txmsg.txfields ('02').VALUE
               );
               if l_strMarginType='S' or l_strMarginType='T' or l_strMarginType='N' then
                   --Tai khoan margin va tai khoan binh thuong ky quy 100%
                    l_securedratio:=100;
               elsif l_strMarginType='L' then --Cho tai khoan margin loan
                    begin
                        select (case when nvl(dfprice,0)>0 then least(nvl(dfrate,0),round(nvl(dfprice,0)/ l_build_msg.fld11/l_build_msg.fld98 * 100,4)) else nvl(dfrate,0) end ) dfrate
                        into l_securedratio
                        from (select * from dfbasket where symbol=l_build_msg.fld07) bk,
                        aftype aft, dftype dft,afmast af
                        where af.actype = aft.actype and aft.dftype = dft.actype and dft.basketid = bk.basketid (+)
                        and af.acctno = l_build_msg.fld03;
                        l_securedratio:=greatest (100-l_securedratio,0);
                    exception
                    when others then
                         l_securedratio:=100;
                    end;
               else
                    l_securedratio                    :=
                    GREATEST (LEAST (l_typebratio + l_afbratio, 100),
                            l_build_msg.securedratiomin
                    );
                    l_securedratio                    :=
                      CASE
                         WHEN l_securedratio > l_build_msg.securedratiomax
                         THEN
                            l_build_msg.securedratiomax
                         ELSE
                            l_securedratio
                      END;
               end if;

               --FeeSecureRatioMin = mv_dblFeeAmountMin * 100 / (CDbl(v_strQUANTITY) * CDbl(v_strQUOTEPRICE) * CDbl(v_strTRADEUNIT))
               l_feesecureratiomin               :=
                  l_feeamountmin * 100
                  / (  TO_NUMBER (l_build_msg.fld12)         --quantity
                     * TO_NUMBER (l_build_msg.fld11)       --quoteprice
                     * TO_NUMBER (l_build_msg.fld98));      --tradeunit

               IF l_feesecureratiomin > l_feerate
               THEN
                  l_securedratio   := l_securedratio + l_feesecureratiomin;
               ELSE
                  l_securedratio   := l_securedratio + l_feerate;
               END IF;
               l_txmsg.txfields ('40').VALUE     :=
                    greatest(l_feerate/100 * TO_NUMBER (l_build_msg.fld12)         --quantity
                     * TO_NUMBER (l_build_msg.fld11)       --quoteprice
                     * TO_NUMBER (l_build_msg.fld98),l_feeamountmin);
               l_txmsg.txfields ('13').VALUE     := l_securedratio;

               IF (  TO_NUMBER (l_build_msg.fld12)
                   * TO_NUMBER (l_build_msg.fld11)
                   * l_securedratio
                   / 100
                   -   TO_NUMBER (l_build_msg.refprice)
                     * TO_NUMBER (l_build_msg.refquantity)
                     * l_securedratio
                     / 100 > 0)
               THEN
                  l_txmsg.txfields ('18').VALUE   :=
                       TO_NUMBER (l_build_msg.fld12)
                     * TO_NUMBER (l_build_msg.fld11)
                     * l_securedratio
                     / 100
                     -   TO_NUMBER (l_build_msg.refprice)
                       * TO_NUMBER (l_build_msg.refquantity)
                       * l_securedratio
                       / 100;
               ELSE
                  l_txmsg.txfields ('18').VALUE   := '0'; --AdvanceSecuredAmount
               END IF;



               --2.2 Set txtime
               l_txmsg.txtime                    :=
                  TO_CHAR (SYSDATE, systemnums.c_time_format);

               l_txmsg.chktime                   := l_txmsg.txtime;
               l_txmsg.offtime                   := l_txmsg.txtime;

               --2.3 Set txdate
               SELECT TO_DATE (varvalue, systemnums.c_date_format)
               INTO l_txmsg.txdate
               FROM sysvar
               WHERE grname = 'SYSTEM' AND varname = 'CURRDATE';

               l_txmsg.brdate                    := l_txmsg.txdate;
               l_txmsg.busdate                   := l_txmsg.txdate;

               --2.4 Set fld value
               l_txmsg.txfields ('01').defname   := 'CODEID';
               l_txmsg.txfields ('01').TYPE      := 'C';
               l_txmsg.txfields ('01').VALUE     := l_build_msg.fld01; --set vale for CODEID

               l_txmsg.txfields ('07').defname   := 'SYMBOL';
               l_txmsg.txfields ('07').TYPE      := 'C';
               l_txmsg.txfields ('07').VALUE     := l_build_msg.fld07; --set vale for Symbol

               l_txmsg.txfields ('60').defname   := 'ISMORTAGE';
               l_txmsg.txfields ('60').TYPE      := 'N';
               l_txmsg.txfields ('60').VALUE     := l_build_msg.fld60; --set vale for Is mortage sell
               l_txmsg.txfields ('02').defname   := 'ACTYPE';
               l_txmsg.txfields ('02').TYPE      := 'C';
               -- l_txmsg.txfields ('02').VALUE     := l_build_msg.fld02; --set vale for Product code
               -- this is set above
               l_txmsg.txfields ('03').defname   := 'AFACCTNO';
               l_txmsg.txfields ('03').TYPE      := 'C';
               l_txmsg.txfields ('03').VALUE     := l_build_msg.fld03; --set vale for Contract number
               l_txmsg.txfields ('06').defname   := 'SEACCTNO';
               l_txmsg.txfields ('06').TYPE      := 'C';
               l_txmsg.txfields ('06').VALUE     := l_build_msg.fld06; --set vale for SE account number
               l_txmsg.txfields ('50').defname   := 'CUSTNAME';
               l_txmsg.txfields ('50').TYPE      := 'C';
               --l_txmsg.txfields ('50').VALUE     := ''; --set vale for Customer name

               -- this was set above already
               l_txmsg.txfields ('20').defname   := 'TIMETYPE';
               l_txmsg.txfields ('20').TYPE      := 'C';
               l_txmsg.txfields ('20').VALUE     := l_build_msg.fld20; --set vale for Duration
               l_txmsg.txfields ('21').defname   := 'EXPDATE';
               l_txmsg.txfields ('21').TYPE      := 'D';
               l_txmsg.txfields ('21').VALUE     := l_build_msg.fld21; --set vale for Expired date
               l_txmsg.txfields ('19').defname   := 'EFFDATE';
               l_txmsg.txfields ('19').TYPE      := 'D';
               l_txmsg.txfields ('19').VALUE     := l_build_msg.fld19; --set vale for Expired date
               l_txmsg.txfields ('22').defname   := 'EXECTYPE';
               l_txmsg.txfields ('22').TYPE      := 'C';
               --l_txmsg.txfields ('22').VALUE     := l_build_msg.fld22; --set vale for Execution type
               l_txmsg.txfields ('23').defname   := 'NORK';
               l_txmsg.txfields ('23').TYPE      := 'C';
               l_txmsg.txfields ('23').VALUE     := l_build_msg.fld23; --set vale for All or none?
               l_txmsg.txfields ('34').defname   := 'OUTPRICEALLOW';
               l_txmsg.txfields ('34').TYPE      := 'C';
               l_txmsg.txfields ('34').VALUE     := l_build_msg.fld34; --set vale for Accept out amplitute price
               l_txmsg.txfields ('24').defname   := 'MATCHTYPE';
               l_txmsg.txfields ('24').TYPE      := 'C';
               l_txmsg.txfields ('24').VALUE     := l_build_msg.fld24; --set vale for Matching type
               l_txmsg.txfields ('25').defname   := 'VIA';
               l_txmsg.txfields ('25').TYPE      := 'C';
               l_txmsg.txfields ('25').VALUE     := l_build_msg.fld25; --set vale for Via
               l_txmsg.txfields ('10').defname   := 'CLEARDAY';
               l_txmsg.txfields ('10').TYPE      := 'N';
               l_txmsg.txfields ('10').VALUE     := l_build_msg.fld10; --set vale for Clearing day
               l_txmsg.txfields ('26').defname   := 'CLEARCD';
               l_txmsg.txfields ('26').TYPE      := 'C';
               l_txmsg.txfields ('26').VALUE     := l_build_msg.fld26; --set vale for Calendar
               l_txmsg.txfields ('72').defname   := 'PUTTYPE';
               l_txmsg.txfields ('72').TYPE      := 'C';
               l_txmsg.txfields ('72').VALUE     := l_build_msg.fld72; --set vale for Puthought type
               l_txmsg.txfields ('27').defname   := 'PRICETYPE';
               l_txmsg.txfields ('27').TYPE      := 'C';
               l_txmsg.txfields ('27').VALUE     := l_build_msg.fld27; --set vale for Price type

               l_txmsg.txfields ('11').defname   := 'QUOTEPRICE';
               l_txmsg.txfields ('11').TYPE      := 'N';
               l_txmsg.txfields ('11').VALUE     := l_build_msg.fld11; --set vale for Limit price

               IF l_build_msg.fld27 <> 'LO'
               THEN                                               -- Pricetype
                  IF l_strEXECTYPE='NB' --l_build_msg.fld22 = 'NB'
                  THEN                                             -- exectype
                     l_txmsg.txfields ('11').VALUE   :=
                        l_build_msg.ceilingprice
                        / l_build_msg.fld98;                --tradeunit
                  ELSE
                     l_txmsg.txfields ('11').VALUE   :=
                        l_build_msg.floorprice
                        / l_build_msg.fld98;
                  END IF;
               END IF;

               plog.debug (pkgctx,
                           'Quoteprice: ' || l_txmsg.txfields ('11').VALUE
               );

               l_txmsg.txfields ('12').defname   := 'ORDERQTTY';
               l_txmsg.txfields ('12').TYPE      := 'N';
               l_txmsg.txfields ('12').VALUE     := l_build_msg.fld12; --set vale for Quantity
               l_txmsg.txfields ('13').defname   := 'BRATIO';
               l_txmsg.txfields ('13').TYPE      := 'N';
               --l_txmsg.txfields ('13').VALUE     := l_build_msg.fld13; --set vale for Block ration
               l_txmsg.txfields ('14').defname   := 'LIMITPRICE';
               l_txmsg.txfields ('14').TYPE      := 'N';
               l_txmsg.txfields ('14').VALUE     := l_build_msg.fld14; --set vale for Stop price
               l_txmsg.txfields ('40').defname   := 'FEEAMT';
               l_txmsg.txfields ('40').TYPE      := 'N';
               --l_txmsg.txfields ('40').VALUE     := l_build_msg.fld40; --set vale for Fee amount
               l_txmsg.txfields ('28').defname   := 'VOUCHER';
               l_txmsg.txfields ('28').TYPE      := 'C';
               l_txmsg.txfields ('28').VALUE     := ''; --l_build_msg.fld28; --set vale for Voucher status
               l_txmsg.txfields ('29').defname   := 'CONSULTANT';
               l_txmsg.txfields ('29').TYPE      := 'C';
               l_txmsg.txfields ('29').VALUE     := ''; --l_build_msg.fld29; --set vale for Consultant status
               l_txmsg.txfields ('04').defname   := 'ORDERID';
               l_txmsg.txfields ('04').TYPE      := 'C';
               --l_txmsg.txfields ('04').VALUE     := l_build_msg.fld04; --set vale for Order ID
               --this is set below
               l_txmsg.txfields ('15').defname   := 'PARVALUE';
               l_txmsg.txfields ('15').TYPE      := 'N';
               l_txmsg.txfields ('15').VALUE     := l_build_msg.fld15; --set vale for Parvalue
               l_txmsg.txfields ('30').defname   := 'DESC';
               l_txmsg.txfields ('30').TYPE      := 'C';
               l_txmsg.txfields ('30').VALUE     := l_build_msg.fld30; --set vale for Description

               l_txmsg.txfields ('95').defname   := 'DFACCTNO';
               l_txmsg.txfields ('95').TYPE      := 'C';
               l_txmsg.txfields ('95').VALUE     := l_build_msg.fld95; --set vale for deal id

               l_txmsg.txfields ('94').defname   := 'SSAFACCTNO';
               l_txmsg.txfields ('94').TYPE      := 'C';
               l_txmsg.txfields ('94').VALUE     := l_build_msg.fld94; --set vale for short sale account

               l_txmsg.txfields ('99').defname   := 'HUNDRED';
               l_txmsg.txfields ('99').TYPE      := 'N';
               If l_strMarginType = 'N' Then
                    l_txmsg.txfields ('99').VALUE     := l_build_msg.fld99;
               Else
                    If l_dblIsPPUsed = 1 Then
                        l_txmsg.txfields ('99').VALUE     := to_char(100 / (1 - l_dblMarginRatioRate / 100 * l_dblSecMarginPrice / l_build_msg.fld11 / l_build_msg.fld98));
                    Else
                        l_txmsg.txfields ('99').VALUE     := l_build_msg.fld99;
                    End If;
               End If;

               l_txmsg.txfields ('98').defname   := 'TRADEUNIT';
               l_txmsg.txfields ('98').TYPE      := 'N';
               l_txmsg.txfields ('98').VALUE     := l_build_msg.fld98; --set vale for Trade unit

               l_txmsg.txfields ('96').defname   := 'TRADEUNIT';
               l_txmsg.txfields ('96').TYPE      := 'N';
               l_txmsg.txfields ('96').VALUE     := 1; --l_build_msg.fld96; --set vale for GTC

               l_txmsg.txfields ('97').defname   := 'MODE';
               l_txmsg.txfields ('97').TYPE      := 'C';
               l_txmsg.txfields ('97').VALUE     := l_build_msg.fld97; --set vale for MODE DAT LENH
               l_txmsg.txfields ('33').defname   := 'CLIENTID';
               l_txmsg.txfields ('33').TYPE      := 'C';
               l_txmsg.txfields ('33').VALUE     := l_build_msg.fld33; --set vale for ClientID
               l_txmsg.txfields ('73').defname   := 'CONTRAFIRM';
               l_txmsg.txfields ('73').TYPE      := 'C';
               l_txmsg.txfields ('73').VALUE     := l_build_msg.fld73; --set vale for Contrafirm
               l_txmsg.txfields ('32').defname   := 'TRADERID';
               l_txmsg.txfields ('32').TYPE      := 'C';
               l_txmsg.txfields ('32').VALUE     := l_build_msg.fld32; --set vale for TraderID
               l_txmsg.txfields ('71').defname   := 'CONTRACUS';
               l_txmsg.txfields ('71').TYPE      := 'C';
               l_txmsg.txfields ('71').VALUE     := ''; --l_build_msg.fld71; --set vale for Contra custody
               l_txmsg.txfields ('31').defname   := 'CONTRAFIRM';
               l_txmsg.txfields ('31').TYPE      := 'C';
               l_txmsg.txfields ('31').VALUE     := l_build_msg.fld31; --set vale for Contrafirm

               l_remainqtty                      :=
                  l_txmsg.txfields ('12').VALUE;

               l_txmsg.txfields ('08').VALUE     :=
                  l_build_msg.orgacctno;
               plog.debug (pkgctx,
                           'cancel orderid: '
                           || l_txmsg.txfields ('08').VALUE
               );

               l_order_count                     := 0;         --RESET COUNTER

               plog.debug (pkgctx, 'l_remainqtty: ' || l_remainqtty);
               if l_build_msg.SPLOPT='Q' then --Tach theo so lenh
                        l_breakingsize:= l_build_msg.SPLVAL;
               elsif l_build_msg.SPLOPT='O' then
                        l_breakingsize:= round(l_remainqtty/to_number(l_build_msg.SPLVAL) +
                                                case when l_build_msg.tradeplace='001' then 5-0.01
                                                     when l_build_msg.tradeplace='002' then 50-0.01
                                                     else 0.5-0.01 end,
                                                case when l_build_msg.tradeplace='001' then -1
                                                     when l_build_msg.tradeplace='002' then -2
                                                     else 0 end);
               else
                        l_breakingsize:= l_remainqtty;
               end if;
               IF l_build_msg.tradeplace = '001' then
                    --Neu san HN thi xe toi da theo l_hosebreakingsize
                    if l_breakingsize > l_hosebreakingsize then
                        l_breakingsize:=l_hosebreakingsize;
                    else
                        l_breakingsize:=l_breakingsize;
                    end if;
               end if;
               --WHILE l_remainqtty > 0                               --quantity
               --LOOP
                  --SAVEPOINT sp#2;
                  l_order_count   := l_order_count + 1;

                  l_txmsg.txfields ('12').VALUE   :=
                        CASE
                           WHEN l_remainqtty > l_breakingsize
                           THEN
                              l_breakingsize
                           ELSE
                              l_remainqtty
                        END;

                  --2.1 Set txnum
                  SELECT systemnums.c_fo_prefixed
                         || LPAD (seq_fotxnum.NEXTVAL, 8, '0')
                  INTO l_txmsg.txnum
                  FROM DUAL;

                  SELECT    systemnums.c_fo_prefixed
                         || '00'
                         || TO_CHAR(TO_DATE (VARVALUE, 'DD\MM\RR'),'DDMMRR')
                         || LPAD (seq_odmast.NEXTVAL, 6, '0')
                  INTO l_txmsg.txfields ('04').VALUE
                  FROM SYSVAR WHERE VARNAME ='CURRDATE' AND GRNAME='SYSTEM';

                  plog.debug (pkgctx,
                              'ORDERID: ' || l_txmsg.txfields ('04').VALUE
                  );

                  plog.debug (pkgctx,
                              'MATCHTYPE: ' || l_txmsg.txfields ('24').VALUE
                  );
                  plog.debug (pkgctx,
                              'ORGEXECTYPE: '
                              || l_txmsg.txfields ('22').VALUE
                  );
                  plog.debug (pkgctx,
                              'SYMBOL: ' || l_txmsg.txfields ('07').VALUE
                  );
                  plog.debug (pkgctx,
                              'QTTY: ' || l_txmsg.txfields ('12').VALUE
                  );
                  plog.debug (pkgctx,
                              'QUOTEPRICE: ' || l_txmsg.txfields ('11').VALUE
                  );

                  SELECT REGEXP_REPLACE (l_txmsg.txfields ('04').VALUE,
                                         '(^[[:digit:]]{4})([[:digit:]]{2})([[:digit:]]{10}$)',
                                         '\1.\2.\3.'
                         )
                         || l_fullname
                         || '.'
                         || l_txmsg.txfields ('24').VALUE          --MATCHTYPE
                         || l_txmsg.txfields ('22').VALUE       ---ORGEXECTYPE
                         || '.'
                         || l_txmsg.txfields ('07').VALUE             --SYMBOL
                         || '.'
                         || l_txmsg.txfields ('12').VALUE
                         || '.'
                         || l_txmsg.txfields ('11').VALUE         --QUOTEPRICE
                  INTO l_txmsg.txfields ('30').VALUE
                  FROM DUAL;

                  plog.debug (pkgctx,
                              'DESC: ' || l_txmsg.txfields ('30').VALUE
                  );


                  -- Get tltxcd from EXECTYPE
                  IF l_txmsg.txfields ('22').VALUE = 'NB'               --8887
                  THEN
                     BEGIN
                        l_txmsg.tltxcd   := '8887'; -- gc_OD_PLACENORMALBUYORDER_ADVANCED
                        -- 2: Process
                        IF txpks_#8887.fn_autotxprocess (l_txmsg,
                                                         p_err_code,
                                                         l_err_param
                           ) <> systemnums.c_success
                        THEN
                           plog.debug (pkgctx,
                                       'got error 8887: ' || p_err_code
                           );
                        END IF;
                     END;                                               --8887
                  ELSIF l_build_msg.fld22 IN ('NS', 'MS', 'SS')  --8888
                  THEN
                     BEGIN
                        l_txmsg.tltxcd   := '8888'; --gc_OD_PLACENORMALSELLORDER_ADVANCED

                        -- 2: Process
                        IF txpks_#8888.fn_autotxprocess (l_txmsg,
                                                         p_err_code,
                                                         l_err_param
                           ) <> systemnums.c_success
                        THEN
                           plog.debug (pkgctx,
                                          '8888: '
                                       || p_err_code
                                       || ':'
                                       || l_err_param
                           );
                        END IF;
                     END;                                              -- 8887
                  ELSIF l_build_msg.fld22 = 'AB'                 --8884
                  THEN
                     BEGIN
                        l_txmsg.tltxcd   := '8884';  --gc_OD_AMENDMENTBUYORDER

                        -- 2: Process
                        IF txpks_#8884.fn_autotxprocess (l_txmsg,
                                                         p_err_code,
                                                         l_err_param
                           ) <> systemnums.c_success
                        THEN
                           plog.debug (pkgctx,
                                       'got error 8884: ' || p_err_code
                           );
                        END IF;
                     END;                                               --8884
                  ELSIF l_build_msg.fld22 = 'AS'                 --8885
                  THEN
                     BEGIN
                        l_txmsg.tltxcd   := '8885'; --gc_OD_AMENDMENTSELLORDER

                        -- 2: Process
                        IF txpks_#8885.fn_autotxprocess (l_txmsg,
                                                         p_err_code,
                                                         l_err_param
                           ) <> systemnums.c_success
                        THEN
                           plog.debug (pkgctx,
                                       'got error 8885: ' || p_err_code
                           );
                        END IF;
                     END;                                               --8885
                  ELSIF l_build_msg.fld22 = 'CB'                 --8882
                  THEN
                     BEGIN
                        l_txmsg.tltxcd   := '8882';     --gc_OD_CANCELBUYORDER

                        -- 2: Process
                        IF txpks_#8882.fn_autotxprocess (l_txmsg,
                                                         p_err_code,
                                                         l_err_param
                           ) <> systemnums.c_success
                        THEN
                           plog.debug (pkgctx,
                                       'got error 8882: ' || p_err_code
                           );
                        END IF;
                     END;                                               --8882
                  ELSIF l_build_msg.fld22 = 'CS'                 --8883
                  THEN
                     BEGIN
                        l_txmsg.tltxcd   := '8883';    --gc_OD_CANCELSELLORDER

                        -- 2: Process
                        IF txpks_#8883.fn_autotxprocess (l_txmsg,
                                                         p_err_code,
                                                         l_err_param
                           ) <> systemnums.c_success
                        THEN
                           plog.debug (pkgctx,
                                       'got error 8883: ' || p_err_code
                           );
                        END IF;
                     END;
                  END IF;

                  UPDATE fomast
                  SET orgacctno    = l_txmsg.txfields ('04').VALUE,
                      status       = 'A',
                      feedbackmsg   =
                         'Order is active and sucessfull processed: '
                         || l_txmsg.txfields ('04').VALUE
                  WHERE acctno = l_build_msg.acctno;

                  INSERT INTO rootordermap
                 (
                     foacctno,
                     orderid,
                     status,
                     MESSAGE,
                     id
                 )
                  VALUES (
                            l_build_msg.acctno,
                            l_txmsg.txfields ('04').VALUE,
                            'A',
                            '[' || systemnums.c_success || '] OK,',
                            l_order_count
                         );

                  l_remainqtty    :=
                     l_remainqtty - TO_NUMBER (l_txmsg.txfields ('12').VALUE);
                  plog.debug (pkgctx,
                                 'l_remainqtty('
                              || l_order_count
                              || '):'
                              || l_remainqtty
                  );
               --END LOOP;
            EXCEPTION
               WHEN errnums.e_od_odtype_notfound
               THEN
                  p_err_code:=errnums.c_od_odtype_notfound;
                  UPDATE fomast
                  SET status    = 'R',
                             feedbackmsg   =
                                '[' || errnums.c_od_odtype_notfound || '] '
                                || cspks_system.fn_get_errmsg(errnums.c_od_odtype_notfound)
                  WHERE acctno = l_build_msg.acctno;
               WHEN errnums.e_invalid_session
               THEN
                  -- Log error and continue to process the next order
                  plog.error (pkgctx,
                                 'INVALID SESSION(pricetype,mktstatus):'
                              || l_build_msg.fld27
                              || ','
                              || l_mktstatus
                  );
                  p_err_code:=errnums.c_invalid_session;
                  UPDATE fomast
                  SET status    = 'R',
                      feedbackmsg   =
                         '[' || errnums.c_invalid_session || '] '
                         || cspks_system.fn_get_errmsg(errnums.c_invalid_session)
                  WHERE acctno = l_build_msg.acctno;
               --LogOrderMessage(v_ds.Tables(0).Rows(i)("ACCTNO"))
               WHEN errnums.e_biz_rule_invalid
               THEN
                  UPDATE fomast
                  SET status        = 'R',
                      feedbackmsg   = '[' || p_err_code || '] ' || l_err_param
                  WHERE acctno = l_build_msg.acctno;

                  INSERT INTO rootordermap
                 (
                     foacctno,
                     orderid,
                     status,
                     MESSAGE,
                     id
                 )
                  VALUES (
                            l_build_msg.acctno,
                            '',
                            'R',
                            '[' || p_err_code || '] ' || l_err_param,
                            l_order_count
                         );
                when others
                then
                  p_err_code:=errnums.C_SYSTEM_ERROR;
                  plog.error (pkgctx,'Error when send syn order!' || sqlerrm || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
            END;
      plog.debug (pkgctx, '<<END OF pr_fo2odsynfortx');
      plog.setendsection (pkgctx, 'pr_fo2odsynfortx');
      END LOOP;
      return nvl(p_err_code,0);
   EXCEPTION
      WHEN OTHERS
      THEN
         ROLLBACK;
         plog.error (pkgctx, SQLERRM);
         plog.error (pkgctx, DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);

         plog.setendsection (pkgctx, 'pr_fo2odsynfortx');
   END;

 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
/
