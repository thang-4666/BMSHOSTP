SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE gen_gltran_batch (l_tltxcd varchar2,l_txdate  VARCHAR2) IS
a VARCHAR2(1000);
v_tltxcd varchar (30);
v_custid varchar (30);
v_custodycd varchar (30);
v_iscorebank varchar (30);
v_custatcom varchar (30);
v_custtype varchar (30);
v_country varchar (30);
v_bankname varchar (3000);
v_fullname varchar (3000);
v_bankid varchar (300);
pkgctx   plog.log_ctx;
logrow   tlogdebug%ROWTYPE;

BEGIN
    plog.error (pkgctx, '<<BEGIN OF GEN_GLTRAN_BATCH' || SYSDATE);

    if UPPER(l_tltxcd )='ALL' THEN
    v_tltxcd:='%';
    ELSE
    v_tltxcd:=l_tltxcd;
    END IF;

    --Ngay 25/11/2016 NamTv Them bang tam tllog
    DELETE TMP_TBL_TLLOG;

    INSERT INTO TMP_TBL_TLLOG
        SELECT * FROM VW_TLLOG_ALL vw WHERE (vw.TXDATE=TO_DATE(l_txdate,'DD/MM/RRRR')
            AND EXISTS( select tltxcd from appmapbravo a WHERE a.tltxcd =vw.tltxcd))
            OR (vw.tltxcd in('8879') AND vw.TXDATE=TO_DATE(l_txdate,'DD/MM/RRRR'));

    DELETE TMP_TBL_TLLOGFLD;

    INSERT INTO TMP_TBL_TLLOGFLD
        SELECT VW1.* FROM VW_TLLOGFLD_ALL VW1, TMP_TBL_TLLOG VW2
        WHERE
            vw1.txdate=vw2.txdate AND vw1.txnum=vw2.txnum;
    --Ngay 25/11/2016 NamTv End

    delete gl_exp_tran where txdate =to_date(l_txdate,'DD/MM/YYYY') and INSTR(trans_type, decode( UPPER(l_tltxcd ),'ALL',trans_type,l_tltxcd))>0;

    delete gl_exp_tran_hist where txdate =to_date(l_txdate,'DD/MM/RRRR') and INSTR(trans_type, decode( UPPER(l_tltxcd ),'ALL',trans_type,l_tltxcd))>0;

    FOR REC IN
            (
             select to_CHAR(TXDATE,'DD/MM/YYYY')  TXDATE , TXNUM  from vw_tllog_all
             where tltxcd in( select  DISTINCT tltxcd from appmapbravo)
             and  txdate = to_date(l_txdate,'DD/MM/YYYY') and tltxcd like v_tltxcd
            )
    LOOP
           sp_generate_appmapbravo(REC.TXDATE,REC.TXNUM,a);
    END LOOP;

    IF UPPER(l_tltxcd )='ALL' then

        INSERT INTO gl_exp_tran (REF,TXDATE,TXNUM,BUSDATE,CUSTID,CUSTODYCD,CUSTODYCD_DEBIT,CUSTODYCD_CREDIT,BANKID,TRANS_TYPE,AMOUNT,SYMBOL,SYMBOL_QTTY,
        SYMBOL_PRICE,COSTPRICE,TXBRID,BRID,TRADEPLACE,ISCOREBANK,STATUS,CUSTATCOM,CUSTTYPE,COUNTRY,SECTYPE,NOTE,BANKNAME,FULLNAME,ACNAME,DORC,REFTRAN,APPTYPE,ACTYPE,ACTYPE_DEBIT,ACTYPE_CREDIT,TLNAME,TLID,DEPID,T3,ISVAT,ISMAGIN)

        select seq_gltran.nextval, se.txdate, se.txnum, se.busdate, se.custid, se.custodycd, '' custodycd_debit,'' custodycd_credit,'' bankid,
        case when se.tltxcd in ('2202','2203') then
                    (case when tl.blocktype='B' then case when se.field in ('EMKQTTY') then se.tltxcd || '08'
                        else se.tltxcd || '10' end
                        else case when se.field in ('EMKQTTY') then se.tltxcd || '08'
                        else se.tltxcd || '11' end
                        end)
             else (case when se.field in ('TRADE','WITHDRAW','EMKQTTY','MORTAGE') then se.tltxcd || '08' else se.tltxcd || '09' end) end trans_type,
        0 amount, se.symbol, nvl(se.namt,0) symbol_qtty, nvl(sec.parvalue,0) symbol_price, nvl(cost.costprice,0)  costprice,
        tlid txbrid, brid, tradeplace, cf.corebank, '' status, cf.custatcom, cf.custtype, DECODE (cf.country,'234','001','002') country, sec.sectype, se.txdesc note, '' bankname,
        cf.fullname, se.field acname, txtype dorc, '' reftran, 'SE' apptype, cf.actype, '' actype_debit, '' actype_credit, '' tlname, '' tlid, '' depid, '' t3, cf.whtax isvat, cf.ismagin
        from vw_setran_gen se, secostprice cost,
            (select cf.custodycd, af.acctno, cf.custtype, cf.custatcom, af.corebank, cf.country, cf.fullname, cf.whtax, upper(aftype.mnemonic) ismagin, aftype.actype
                from cfmast cf, afmast af, aftype, mrtype
                where cf.custid=af.custid
                   and af.actype=aftype.actype and aftype.mrtype=mrtype.actype
            ) cf,
            (select sec.*, sb.sectype, sb.parvalue
                from securities_info sec, sbsecurities sb
                where sec.codeid(+)=sb.codeid
            ) sec,
            (select tl.txnum, tl.txdate, max(decode(tf.fldcd,'06',cvalue,'')) BLOCKTYPE
                from TMP_TBL_TLLOG tl, TMP_TBL_TLLOGFLD tf
                where tl.txnum=tf.txnum
                and tl.txdate=tf.txdate
                and tf.fldcd in ('06')
                and tl.tltxcd in ('2202','2203')
                group by tl.txnum, tl.txdate
            ) tl
        where se.symbol=sec.symbol(+)
        and se.acctno=cost.acctno(+)
        and se.txdate=cost.txdate(+)
        and se.afacctno=cf.acctno(+)
        and se.txnum=tl.txnum(+)
        and se.txdate=tl.txdate(+)
        and sec.sectype <> '004'
        and SUBSTR(se.custodycd,4,1)='P'
        and (field in ('TRADE','BLOCKED','EMKQTTY','MORTAGE') OR field in ('WITHDRAW', 'BLOCKWITHDRAW') and se.txtype='D')
        and se.txdate = to_date(l_txdate,'DD/MM/YYYY');
    END IF;
    plog.error (pkgctx, '<<END OF GEN_GLTRAN_BATCH' || SYSDATE);
  EXCEPTION
WHEN OTHERS
   THEN
      plog.error (pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
      RETURN;
  END ;
 
 
 
/
