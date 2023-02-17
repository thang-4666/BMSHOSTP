SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE EXECORDER_UPDATE_AFT
    (
        PV_ORDERID      IN VARCHAR2, ---So hieu lenh
        PV_QTTY         IN NUMBER,   ---Khoi Luong Khop
        PV_PRICE    IN NUMBER,   ---Gia khop
        PV_TYPE       IN VARCHAR2, ---1: khop 0 huy khop
        PV_TXNUM      IN VARCHAR2,
        PV_TXDATE     IN VARCHAR2,
        pv_strErrorCode IN OUT Varchar2,
        pv_option_exec  IN varchar2 default '0' -- 0: tang/giam all, 1: tang/giam khop, 2: tang/giam ung
    )
IS
  pkgctx   plog.log_ctx;
  v_Exectype odmast.exectype%type;
  v_Bratio   odmast.bratio%type;
  v_seacctno odmast.seacctno%type;
  v_afacctno odmast.afacctno%type;
  v_codeid   odmast.codeid%type;
  v_strclearcd   odmast.clearcd%type;
  v_strclearday  odmast.clearday%type;
  v_txdate varchar2(20);
  v_clearDate date;
  v_dblExecAmt number;
  v_AdvDays number;
  v_feeAmt number;
  v_dblAdvRate number;
  v_dblVatAmt number;
  v_dblADVANCEDAYS  NUMBER; -- so ngay ung trong nam
  v_dblVATRATE      NUMBER; -- thue ban
  v_dblWhTax      NUMBER;
  v_dblNewAright    number; -- thue quyen ban chung khoan
  v_price_Aright      number;
  v_recSTSCHD         number;
  v_dblAdvFeeAmt      number;
  v_cfVat cfmast.vat%type;
  v_cfWhtax     cfmast.whtax%type;
  mv_IsAdvAllow   varchar2(1) ;



BEGIN
    plog.setbeginsection (pkgctx, 'EXECORDER_UPDATE_AFT');


    select od.exectype , od.bratio, od.seacctno, od.afacctno, od.codeid, od.clearcd, od.clearday,
    nvl(cf.vat,'N') cfVat,cf.whtax, feeacr,CASE WHEN CF.CUSTATCOM ='Y' and nvl(od.grporder,'N')<> 'Y' THEN 'Y' ELSE 'N' END 
    into  v_Exectype, v_Bratio, v_seacctno, v_afacctno,v_codeid,v_strclearcd, v_strclearday,v_cfVat,v_cfWhtax,v_feeAmt,mv_IsAdvAllow
    from odmast od, cfmast cf, afmast af
    where cf.custid = af.custid and od.afacctno = af.acctno and od.orderid = PV_ORDERID;
     -- lay thong tin phi ung
     SELECT adt.advrate + adt.advbankrate
     INTO v_dblAdvRate
     FROM afmast af, aftype aft, adtype adt
     WHERE af.actype = aft.actype AND aft.adtype = adt.actype AND af.acctno = v_afacctno;
    
    v_dblExecAmt := PV_QTTY * PV_PRICE ; -- gia tri khop
    v_feeAmt := case when v_feeAmt >0 then v_feeAmt else v_dblExecAmt * ( v_Bratio - 100 ) /100 end; -- phi lenh, truong hop l?nh repo lenh da dc update feeeacr

    SELECT varvalue INTO v_txdate FROM sysvar WHERE grname = 'SYSTEM' AND varname = 'CURRDATE';
    --SELECT varvalue INTO v_dblADVANCEDAYS FROM sysvar WHERE grname = 'SYSTEM' AND varname = 'ADVANCEDAYS';
    v_dblADVANCEDAYS := 360;
    SELECT varvalue INTO v_dblVATRATE FROM sysvar WHERE grname = 'SYSTEM' AND varname = 'ADVSELLDUTY';
    SELECT varvalue INTO v_dblWhTax FROM sysvar WHERE grname = 'SYSTEM' AND varname = 'WHTAX';

    if (PV_TYPE ='1') then
      if ( v_Exectype = 'NB') then
        UPDATE semast se SET se.execbuyqtty = se.execbuyqtty + PV_QTTY
        WHERE acctno = v_seacctno;
        UPDATE cimast ci
        SET ci.execbuyamt = ci.execbuyamt +  v_dblExecAmt,
            ci.execfeebuyamt = ci.execfeebuyamt +  v_feeAmt
        WHERE ci.acctno = v_afacctno;
     else
          UPDATE semast se
        SET se.execsellqtty = se.execsellqtty +  case when (v_Exectype = 'MS') then 0 else 1 end *  PV_QTTY,
            se.execmsqtty = se.execmsqtty +  case when (v_Exectype = 'MS') then 1 else 0 end *  PV_QTTY
        WHERE acctno = v_seacctno;
        UPDATE cimast ci
        SET ci.execsellamt = ci.execsellamt + v_dblExecAmt,
            ci.execfeevatsellamt = ci.execfeevatsellamt + v_FeeAmt 
        WHERE ci.acctno = v_afacctno;
        
        if (mv_IsAdvAllow = 'Y') then
          select nvl(sum(ARIGHT),0) INTO v_dblNewAright
          from SEPITALLOCATE
          where orgorderid = PV_ORDERID
          AND TXNUM = PV_TXNUM  AND TXDATE = TO_DATE ( PV_TXDATE ,'DD/MM/RRRR') ;

          v_clearDate := getduedate(TO_DATE (v_txdate, 'DD/MM/RRRR'),v_strclearcd,'000',v_strclearday);
          v_AdvDays := case when  v_clearDate - TO_DATE (v_txdate, 'DD/MM/RRRR') = 0  and TO_NUMBER(v_strclearday) > 0 then 1 else v_clearDate - TO_DATE (v_txdate, 'DD/MM/RRRR') end;

          --v_dblVatAmt := case when v_cfVat ='Y' then  v_dblExecAmt * v_dblVATRATE / 100 else 0 end + v_dblNewAright;  -- thue ban + thue quyen
          select (decode(v_cfVat,'Y',v_dblVATRATE,'N',0)+decode(v_cfWhtax,'Y',v_dblWhTax,'N',0)) * v_dblExecAmt/100  + v_dblNewAright 
                 into v_dblVatAmt from dual ;
          v_dblAdvFeeAmt := (v_dblExecAmt - v_feeAmt - v_dblVatAmt) * v_AdvDays * v_dblAdvRate / 100  / ( v_dblADVANCEDAYS + v_AdvDays * (v_dblAdvRate/100)); -- phi ung

             MERGE INTO cimastext  ext
              USING ( SELECT v_afacctno afacctno,
               case when v_AdvDays = 0 then v_dblExecAmt- v_FeeAmt - v_dblVatAmt else 0 END advamtbuyin,
               case when v_AdvDays = 0 then v_dblAdvFeeAmt else 0 END advfeebuyin,
               case when v_AdvDays = 1 then v_dblExecAmt- v_FeeAmt - v_dblVatAmt else 0 END advamtt0,
               case when v_AdvDays = 1 then v_dblAdvFeeAmt else 0 END advfeet0,
               case when v_AdvDays >1 and v_strclearday = 1 then v_dblExecAmt- v_FeeAmt - v_dblVatAmt  else 0 end advamtt1,
               case when v_AdvDays >1 and v_strclearday = 1 then v_dblAdvFeeAmt else 0 end advfeet1,
               case when v_AdvDays >1 and v_strclearday = 2 then v_dblExecAmt- v_FeeAmt - v_dblVatAmt  else 0 end advamtt2,
               case when v_AdvDays >1 and v_strclearday = 2 then v_dblAdvFeeAmt else 0 end advfeet2,
               case when v_AdvDays >1 and v_strclearday > 2 then v_dblExecAmt- v_FeeAmt - v_dblVatAmt else 0 end advamttn,
               case when v_AdvDays >1 and v_strclearday > 2 then v_dblAdvFeeAmt else 0 end advfeetn
                FROM dual
                  ) ci ON (ext.afacctno = ci.afacctno)
               WHEN MATCHED THEN
              UPDATE SET ext.advamtbuyin = ext.advamtbuyin + ci.advamtbuyin,
                         ext.advfeebuyin = ext.advfeebuyin + ci.advfeebuyin,
                         ext.advamtt0 = ext.advamtt0 + ci.advamtt0,
                         ext.advfeet0 = ext.advfeet0 + ci.advfeet0,
                         ext.advamtt1 = ext.advamtt1 + ci.advamtt1,
                         ext.advfeet1 = ext.advfeet1 + ci.advfeet1,
                         ext.advamtt2 = ext.advamtt2 + ci.advamtt2,
                         ext.advfeet2 = ext.advfeet2 + ci.advfeet2,
                         ext.advamttn = ext.advamttn + ci.advamttn,
                         ext.advfeetn = ext.advfeetn + ci.advfeetn
              WHEN NOT MATCHED THEN
                INSERT (afacctno, advamtbuyin, advfeebuyin, advamtt0, advfeet0, advamtt1, advfeet1, advamtt2, advfeet2, advamttn, advfeetn)
                VALUES (ci.afacctno, ci.advamtbuyin, ci.advfeebuyin, ci.advamtt0, ci.advfeet0, ci.advamtt1, ci.advfeet1, ci.advamtt2, ci.advfeet2, ci.advamttn, ci.advfeetn);
           END IF;
     end if;

   else    -- huy khop
       if ( v_Exectype = 'NB') then
           if ( nvl(pv_option_exec, '0') in ('0','1')) then 
              UPDATE semast se SET se.execbuyqtty = se.execbuyqtty - PV_QTTY
              WHERE acctno = v_seacctno;
              UPDATE cimast ci
              SET ci.execbuyamt = ci.execbuyamt -  v_dblExecAmt,
                  ci.execfeebuyamt = ci.execfeebuyamt - v_feeAmt
              WHERE ci.acctno = v_afacctno;
           end if;
      else
          if ( nvl(pv_option_exec, '0') in ('0','1')) then 
              UPDATE semast se 
              SET se.execsellqtty = se.execsellqtty -  case when (v_Exectype = 'MS') then 0 else 1 end * PV_QTTY,
                   se.execmsqtty = se.execmsqtty - case when (v_Exectype = 'MS') then 1 else 0 end * PV_QTTY
              WHERE acctno = v_seacctno;
              UPDATE cimast ci
               SET ci.execsellamt = ci.execsellamt - v_dblExecAmt,
               ci.execfeevatsellamt = ci.execfeevatsellamt - v_FeeAmt 
               WHERE ci.acctno = v_afacctno;              
           end if;

           if (mv_IsAdvAllow ='Y') then
           select s.aright, (CASE WHEN s.CLEARDATE - TO_DATE (v_txdate, 'DD/MM/RRRR') =0  and TO_NUMBER(v_strclearday) > 0 THEN 1 ELSE s.CLEARDATE - TO_DATE (v_txdate, 'DD/MM/RRRR') END) DAYS
           into v_dblNewAright,v_AdvDays
           from stschd s where ORGORDERID = pv_orderid and duetype ='RM';

           select (decode(v_cfVat,'Y',v_dblVATRATE,'N',0)+decode(v_cfWhtax,'Y',v_dblWhTax,'N',0)) * v_dblExecAmt/100  + v_dblNewAright 
                     into v_dblVatAmt from dual ;
           v_dblAdvFeeAmt := (v_dblExecAmt - v_FeeAmt - v_dblVatAmt) * v_AdvDays * v_dblAdvRate / 100  / ( v_dblADVANCEDAYS + v_AdvDays * (v_dblAdvRate/100)); -- phi ung

             if ( nvl(pv_option_exec, '0') in ('0','2')) then 
                UPDATE CIMASTEXT CI
                   SET   ci.advamtbuyin = ci.advamtbuyin - case when v_AdvDays = 0 then v_dblExecAmt- v_FeeAmt - v_dblVatAmt else 0 end  ,
                         ci.advfeebuyin = ci.advfeebuyin - case when v_AdvDays = 0 then v_dblAdvFeeAmt else 0 end ,
                         ci.advamtt0 = ci.advamtt0 - case when v_AdvDays = 1 then v_dblExecAmt- v_FeeAmt - v_dblVatAmt else 0 end  ,
                         ci.advfeet0 = ci.advfeet0 - case when v_AdvDays = 1 then v_dblAdvFeeAmt else 0 end ,
                         ci.advamtt1 = ci.advamtt1 - case when v_AdvDays >1 and v_strclearday = 1 then v_dblExecAmt- v_FeeAmt - v_dblVatAmt  else 0 end ,
                         ci.advfeet1 = ci.advfeet1 - case when v_AdvDays >1 and v_strclearday = 1 then v_dblAdvFeeAmt else 0 end ,
                         ci.advamtt2 = ci.advamtt2 - case when v_strclearday = 2 then v_dblExecAmt- v_FeeAmt - v_dblVatAmt  else 0 end ,
                         ci.advfeet2 = ci.advfeet2 - case when v_strclearday = 2 then v_dblAdvFeeAmt else 0 end ,
                         ci.advamttn = ci.advamttn - case when v_strclearday > 2 then v_dblExecAmt- v_FeeAmt - v_dblVatAmt  else 0 end ,
                         ci.advfeetn = ci.advfeetn - case when v_strclearday > 2 then v_dblAdvFeeAmt else 0 end
                   where afacctno = v_afacctno;
               end if;
           end if;

      end if;
    end if;
    pv_strErrorCode := '0';
    plog.setendsection (pkgctx, 'EXECORDER_UPDATE_AFT');
EXCEPTION
   WHEN OTHERS THEN
        pv_strErrorCode:='-1';
        plog.error (pkgctx, '[Format_error_backtrace] ' || dbms_utility.format_error_backtrace); --Log trace
        plog.setendsection (pkgctx, 'EXECORDER_UPDATE_AFT');
        RAISE errnums.E_SYSTEM_ERROR;
END;
/
