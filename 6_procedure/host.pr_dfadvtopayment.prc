SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "PR_DFADVTOPAYMENT" (p_bchmdl varchar,p_err_code  OUT varchar2,p_FromRow number,p_ToRow number, p_lastRun OUT varchar2)
  IS
      l_txmsg               tx.msg_rectype;
      v_strCURRDATE varchar2(20);
      v_strPREVDATE varchar2(20);
      v_strNEXTDATE varchar2(20);
      v_strDesc varchar2(1000);
      v_strEN_Desc varchar2(1000);
      v_blnVietnamese BOOLEAN;
      l_err_param varchar2(300);
      l_MaxRow NUMBER(20,0);
      v_totalpaidamt NUMBER(20,0);
      v_pqtty   number(20,0);
      v_paidamt  number(20,0);
      v_advamt   number(20,0);
  BEGIN
    SELECT COUNT(*) MAXROW into l_MaxRow FROM  STSCHD;
    IF l_MaxRow>p_ToRow THEN
        p_lastRun:='N';
    ELSE
        p_lastRun:='Y';
    END IF;
    SELECT TO_DATE (varvalue, systemnums.c_date_format)
               INTO v_strCURRDATE
               FROM sysvar
               WHERE grname = 'SYSTEM' AND varname = 'CURRDATE';

    v_pqtty:=0;
    v_totalpaidamt:=0;
    for rec in
    (
       select sts.autoid,od.orderid, v.acctno,sts.qtty, sts.aqtty,sts.qtty-sts.aqtty pqtty, v.dfqtty ,v.bqtty,v.rlsqtty
        from stschd sts, odmast od, v_getDealInfo v
        where sts.orgorderid = od.orderid and od.dfacctno = v.acctno
            AND STS.DELTD <> 'Y' AND STS.STATUS='N' AND STS.DUETYPE='RM'
            and od.EXECTYPE='MS' and sts.qtty-aqtty>0 and sts.orgorderid='8000040610004250'
        order by v.acctno, od.txdate
    )
    loop
        v_pqtty:=rec.pqtty;
        v_totalpaidamt:=0;
        --1.Tra no cho cac phan deal ban ma chua thanh toan het nghia vu tra no
        --sts.Aqtty: Phan da thanh toan nghia vu tra no
        --sts.qtty: Phan ban khop cua deal
        --sts.qtty-sts.aqtty: Phan chung khoan ban ma  chau thuc hien nghia vu tra no.
        --GIAO DICH 2643
        cspks_dfproc.pr_DealAutoPayment(l_txmsg,rec.acctno,rec.autoid ,v_pqtty,0,v_paidamt ,p_err_code);
        v_totalpaidamt:=v_totalpaidamt+v_paidamt;
        --2.Ung truoc tien ban bu cho cac deal
        --Phan tien se lay o phan ung truoc. Va ung toi da bang kha nang ung cua lenh ban
        --Neu ung het cua lenh ban ma khong du tra cho deal thi se khau tru tu CI.Balance
        --GIAO DICH 1143
        if v_totalpaidamt>0 then
            cspks_ciproc.pr_CIAutoAdvance(l_txmsg,rec.orderid,v_totalpaidamt,v_advamt,p_err_code);
        end if;
    end loop;
    p_err_code:=0;
  EXCEPTION
  WHEN OTHERS
   THEN
      ROLLBACK;
      p_err_code := errnums.C_SYSTEM_ERROR;
      RAISE errnums.E_SYSTEM_ERROR;
  END pr_DFAdvToPayment;

 
 
 
 
/
