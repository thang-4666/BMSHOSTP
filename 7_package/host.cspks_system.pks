SET DEFINE OFF;
CREATE OR REPLACE PACKAGE cspks_system
IS
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
     **  TienPQ      09-JUNE-2009    Created
     ** (c) 2008 by Financial Software Solutions. JSC.
     ----------------------------------------------------------------------------------------------------*/
     FUNCTION fn_get_sysvar (p_sys_grp IN VARCHAR2, p_sys_name IN VARCHAR2)
        RETURN sysvar.varvalue%TYPE;

     FUNCTION fn_get_errmsg (p_errnum IN varchar2)
        RETURN deferror.errdesc%TYPE;

  PROCEDURE pr_set_sysvar (p_sys_grp IN varchar2,
                            p_sys_name IN varchar2,
                            p_sys_value IN varchar2
   );

  Function fn_NETgen_trandesc (p_xmlmsg     IN varchar2,
                            p_tltxcd IN varchar2,
                            p_apptype IN varchar2,
                            p_apptxcd IN varchar2
   )
   return varchar2;
  Function fn_DBgen_trandesc (p_txmsg IN tx.msg_rectype,
                            p_tltxcd IN varchar2,
                            p_apptype IN varchar2,
                            p_apptxcd IN varchar2
   )
   return varchar2;

   FUNCTION fn_PasswordGenerator (p_PwdLenght IN varchar2)
   RETURN VARCHAR2;

     Function fn_DBgen_trandesc_with_format (p_txmsg IN tx.msg_rectype,
                              p_tltxcd IN varchar2,
                              p_apptype IN varchar2,
                              p_apptxcd IN varchar2,
                              p_txdesc in varchar2
     )
     return varchar2;
   function fn_correct_field(p_txmsg in tx.msg_rectype, p_fldname in varchar2, p_type in varchar2)
    return varchar2;
   function fn_random_str(v_length number) return VARCHAR2;
   function fn_random_num(v_length number) return VARCHAR2;
END;

 
/


CREATE OR REPLACE PACKAGE BODY "CSPKS_SYSTEM"
IS
   -- declare log context
   pkgctx   plog.log_ctx;
   logrow   tlogdebug%ROWTYPE;


    function fn_correct_field(p_txmsg in tx.msg_rectype, p_fldname in varchar2, p_type in varchar2)
    return varchar2
    is
    begin
        return p_txmsg.txfields(p_fldname).value;
    exception when others then
        return case when p_type='N' then '0' else '' end;
    end fn_correct_field;

   PROCEDURE pr_set_sysvar (p_sys_grp IN varchar2,
                            p_sys_name IN varchar2,
                            p_sys_value IN varchar2
   )
   IS
      PRAGMA AUTONOMOUS_TRANSACTION;
   BEGIN
      UPDATE sysvar
      SET varvalue    = p_sys_value
      WHERE varname = p_sys_name AND grname = p_sys_grp;

      COMMIT;
   END;

   PROCEDURE pr_set_sysvar (p_sys_grp IN varchar2,
                            p_sys_name IN varchar2,
                            p_sys_value IN varchar2,
                            p_auto_commit IN boolean
   )
   IS
   BEGIN
      UPDATE sysvar
      SET varvalue    = p_sys_value
      WHERE varname = p_sys_name AND grname = p_sys_grp;

      IF p_auto_commit
      THEN
         COMMIT;
      END IF;
   END;

   FUNCTION fn_get_sysvar (p_sys_grp IN varchar2, p_sys_name IN varchar2)
      RETURN sysvar.varvalue%TYPE
   IS
      l_sys_value   sysvar.varvalue%TYPE;
   BEGIN
      SELECT varvalue
      INTO l_sys_value
      FROM sysvar
      WHERE varname = p_sys_name AND grname = p_sys_grp;

      RETURN l_sys_value;
   END;

   FUNCTION fn_get_errmsg (p_errnum IN varchar2)
      RETURN deferror.errdesc%TYPE
   IS
      l_errdesc   deferror.errdesc%TYPE;
   BEGIN
      FOR i IN (SELECT errdesc
                FROM deferror
                WHERE errnum = p_errnum)
      LOOP
         l_errdesc   := i.errdesc;
      END LOOP;

      RETURN l_errdesc;
   END;

   FUNCTION fn_get_date (p_date IN varchar2, p_date_format IN varchar2)
      RETURN VARCHAR2
   IS
      l_date   DATE;
   BEGIN
      l_date   := TO_DATE (p_date, systemnums.c_date_format);
      RETURN TO_CHAR (l_date, p_date_format);
   END;

   FUNCTION fn_get_param (p_type IN varchar2, p_name IN varchar2)
      RETURN VARCHAR2
   IS
      l_value   VARCHAR2 (20);
   BEGIN
      SELECT a.cdval
      INTO l_value
      FROM allcode a
      WHERE UPPER (a.cdtype) = UPPER (p_type)
            AND UPPER (a.cdname) = UPPER (p_name);

      RETURN l_value;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN NULL;
   END;

   Function fn_NETgen_trandesc (p_xmlmsg     IN varchar2,
                            p_tltxcd IN varchar2,
                            p_apptype IN varchar2,
                            p_apptxcd IN varchar2
   )
   return varchar2
   IS
        p_txmsg tx.msg_rectype;
        var1 varchar2(1000);
        var2 varchar2(1000);
        var3 varchar2(1000);
        p_txdesc varchar2(1000);
   BEGIN
      plog.setbeginsection(pkgctx, 'fn_NETgen_trandesc');
      plog.debug (pkgctx, 'p_tltxcd:' || p_tltxcd);
      plog.debug (pkgctx, 'p_apptype:' || p_apptype);
      plog.debug (pkgctx, 'p_apptxcd:' || p_apptxcd);

      p_txmsg := txpks_msg.fn_xml2obj(p_xmlmsg);
      p_txdesc:='';
      if p_tltxcd ='2670' then
        if p_apptype='CI' and p_apptxcd='0012' then
            select symbol into var1 from sbsecurities where codeid=p_txmsg.txfields('01').value;
            plog.debug (pkgctx, 'var1:' || var1);
            select b.rate3 into var2 from dftype a, lntype b where a.lntype = b.actype and a.actype =p_txmsg.txfields('04').value;
            plog.debug (pkgctx, 'var2:' || var2);
            p_txdesc:='Giải ngân deal ' || p_txmsg.txfields('02').value || ' ( SL: ' || p_txmsg.txfields('40').value || ', CK: ' || var1 || ', %phí: ' || var2 || ')';
            /*plog.setendsection(pkgctx, 'pr_batch');
            return p_txdesc;*/
        end if;
      end if;
      if p_tltxcd ='2678' then
        if p_apptype='CI' and p_apptxcd='0012' then
            select b.rate3 into var1 from dftype a, lntype b, dfmast c
            where a.lntype = b.actype
                  and a.actype = c.actype
                  and c.acctno =p_txmsg.txfields('02').value;
            plog.debug (pkgctx, 'var1:' || var1);

            select sb.symbol into var2 from dfmast df, sbsecurities sb
            where df.acctno =p_txmsg.txfields('02').value
                  and df.codeid = sb.codeid;
            plog.debug (pkgctx, 'var2:' || var2);

            select to_char(p_txmsg.txfields('40').value+p_txmsg.txfields('22').value+p_txmsg.txfields('23').value+p_txmsg.txfields('13').value) into var3
            from dual;
            plog.debug (pkgctx, 'var3:' || var3);

            p_txdesc:='Giải ngân deal ' || p_txmsg.txfields('02').value || ' ( SL: ' || var3 || ', CK: ' || var2 || ', %phí: ' || var1 || ')';
            /*plog.setendsection(pkgctx, 'pr_batch');
            return p_txdesc;*/
        end if;
      end if;
      if p_tltxcd ='2685' then
        if p_apptype='CI' and p_apptxcd='0012' then
            select symbol into var1 from sbsecurities where codeid=p_txmsg.txfields('01').value;
            plog.debug (pkgctx, 'var1:' || var1);
            select b.rate3 into var2 from dftype a, lntype b where a.lntype = b.actype and a.actype =p_txmsg.txfields('04').value;
            plog.debug (pkgctx, 'var2:' || var2);
            p_txdesc:='Giải ngân deal ' || p_txmsg.txfields('02').value || ' ( SL: ' || p_txmsg.txfields('40').value || ', CK: ' || var1 || ', %phí: ' || var2 || ')';

        end if;

        if p_apptype='CI' and p_apptxcd='0011' then
            select symbol into var1 from sbsecurities where codeid=p_txmsg.txfields('01').value;
            plog.debug (pkgctx, 'var1:' || var1);
            select b.rate3 into var2 from dftype a, lntype b where a.lntype = b.actype and a.actype =p_txmsg.txfields('04').value;
            plog.debug (pkgctx, 'var2:' || var2);
            p_txdesc:='Thanh lý deal ' || p_txmsg.txfields('42').value || ' ( SL: ' || p_txmsg.txfields('64').value || ', CK: ' || var1 || ', %phí: ' || var2 || ')';

        end if;

        if p_apptype='CI' and p_apptxcd='0028' then
            select symbol into var1 from sbsecurities where codeid=p_txmsg.txfields('01').value;
            plog.debug (pkgctx, 'var1:' || var1);
            select b.rate3 into var2 from dftype a, lntype b where a.lntype = b.actype and a.actype =p_txmsg.txfields('04').value;
            plog.debug (pkgctx, 'var2:' || var2);
            p_txdesc:='Trả phí deal ' || p_txmsg.txfields('42').value || ' ( SL: ' || p_txmsg.txfields('64').value || ', CK: ' || var1 || ', %phí: ' || var2 || ')';

        end if;
      end if;

      if p_tltxcd ='2642' then
        select symbol into var1 from sbsecurities where codeid=p_txmsg.txfields('01').value;
        plog.debug (pkgctx, 'var1:' || var1);
        var2 := case when to_number(p_txmsg.txfields('16').value)>0
                          then
                               round(100*to_number(p_txmsg.txfields('19').value)/to_number(p_txmsg.txfields('16').value),4)
                          else 0 end;
        plog.debug (pkgctx, 'var2:' || var2);
        if p_apptype='CI' and p_apptxcd='0011' then
            p_txdesc:='Thanh lý deal ' || p_txmsg.txfields('02').value || ' ( SL: ' || p_txmsg.txfields('46').value || ', CK: ' || var1 || ', %phi: ' || var2 || ')';
        end if;
        if p_apptype='CI' and p_apptxcd='0028' then
            p_txdesc:='Phí thanh lý deal ' || p_txmsg.txfields('02').value || ' ( SL: ' || p_txmsg.txfields('46').value || ', CK: ' || var1 || ', %phi: ' || var2 || ')';
        end if;
        if p_apptype='CI' and p_apptxcd='0012' then
            p_txdesc:='Thanh lý deal ' || p_txmsg.txfields('02').value || ' ( SL: ' || p_txmsg.txfields('46').value || ', CK: ' || var1 || ', %phi: ' || var2 || ')';
        end if;
        if p_apptype='CI' and p_apptxcd='0029' then
            p_txdesc:='Phí thanh lý deal ' || p_txmsg.txfields('02').value || ' ( SL: ' || p_txmsg.txfields('46').value || ', CK: ' || var1 || ', %phi: ' || var2 || ')';
        end if;
      end if;

      if p_tltxcd ='2686' then
        if p_apptype='CI' and p_apptxcd='0012' then
            select symbol into var1 from sbsecurities where codeid=p_txmsg.txfields('01').value;
            plog.debug (pkgctx, 'var1:' || var1);
            select b.rate3 into var2 from dftype a, lntype b where a.lntype = b.actype and a.actype =p_txmsg.txfields('04').value;
            plog.debug (pkgctx, 'var2:' || var2);
            p_txdesc:='Gi?i ngân deal ' || p_txmsg.txfields('02').value || ' ( SL: ' || p_txmsg.txfields('40').value || ', CK: ' || var1 || ', %phi: ' || var2 || ')';
            /*plog.setendsection(pkgctx, 'pr_batch');
            return p_txdesc;*/
        end if;
      end if;

      plog.setendsection(pkgctx, 'fn_NETgen_trandesc');
      return p_txdesc;
   exception when others then

    plog.setendsection (pkgctx, 'fn_NETgen_trandesc');
    RETURN '';
   END;

   Function fn_DBgen_trandesc (p_txmsg IN tx.msg_rectype,
                            p_tltxcd IN varchar2,
                            p_apptype IN varchar2,
                            p_apptxcd IN varchar2
   )
   return varchar2
   IS
        p_txdesc varchar2(1000);
        var1 varchar2(1000);
        var2 varchar2(1000);
        --var3 varchar2(1000);
   BEGIN
      plog.setbeginsection(pkgctx, 'fn_DBgen_trandesc');
      plog.debug (pkgctx, 'p_tltxcd:' || p_tltxcd);
      plog.debug (pkgctx, 'p_apptype:' || p_apptype);
      plog.debug (pkgctx, 'p_apptxcd:' || p_apptxcd);

      p_txdesc:='';
      if p_tltxcd ='2642' then
        select symbol into var1 from sbsecurities where codeid=p_txmsg.txfields('01').value;
        plog.debug (pkgctx, 'var1:' || var1);
        --var2 := round(100*to_number(p_txmsg.txfields('19').value)/to_number(p_txmsg.txfields('16').value),4);
        var2 := case when to_number(p_txmsg.txfields('16').value) >0
                          then
                               round(100*to_number(p_txmsg.txfields('19').value)/to_number(p_txmsg.txfields('16').value),4)
                          else 0 end;
        plog.debug (pkgctx, 'var2:' || var2);
        if p_apptype='CI' and p_apptxcd='0011' then
            p_txdesc:='Thanh lý deal ' || p_txmsg.txfields('02').value || ' ( SL: ' || p_txmsg.txfields('46').value || ', CK: ' || var1 || ', %phí: ' || var2 || ')';
        end if;
        if p_apptype='CI' and p_apptxcd='0028' then
            p_txdesc:='Phí thanh lý deal ' || p_txmsg.txfields('02').value || ' ( SL: ' || p_txmsg.txfields('46').value || ', CK: ' || var1 || ', %phí: ' || var2 || ')';
        end if;
        if p_apptype='CI' and p_apptxcd='0012' then
            p_txdesc:='Thanh lý deal ' || p_txmsg.txfields('02').value || ' ( SL: ' || p_txmsg.txfields('46').value || ', CK: ' || var1 || ', %phí: ' || var2 || ')';
        end if;
        if p_apptype='CI' and p_apptxcd='0029' then
            p_txdesc:='Phí thanh lý deal ' || p_txmsg.txfields('02').value || ' ( SL: ' || p_txmsg.txfields('46').value || ', CK: ' || var1 || ', %phí: ' || var2 || ')';
        end if;
      end if;
      if p_tltxcd ='2643' or p_tltxcd ='2660' then
        select sb.symbol into var1 from sbsecurities sb, semast se where sb.codeid= se.codeid and se.acctno=p_txmsg.txfields('06').value;
        plog.debug (pkgctx, 'var1:' || var1);
        var2 := case when to_number(p_txmsg.txfields('63').value+p_txmsg.txfields('65').value)>0 then
                        round(100*to_number(p_txmsg.txfields('72').value +p_txmsg.txfields('74').value+p_txmsg.txfields('77').value+p_txmsg.txfields('80').value+p_txmsg.txfields('90').value)/
                                     to_number(p_txmsg.txfields('63').value+p_txmsg.txfields('65').value),4)
                else 0 end;
        plog.debug (pkgctx, 'var2:' || var2);
        if p_apptype='CI' and p_apptxcd='0011' then
            p_txdesc:='Thanh lý deal ' || p_txmsg.txfields('02').value || ' ( SL: ' || p_txmsg.txfields('10').value || ', CK: ' || var1 || ', %phí: ' || var2 || ')';
        end if;
        if p_apptype='CI' and p_apptxcd='0028' then
            p_txdesc:='Phí thanh lý deal ' || p_txmsg.txfields('02').value || ' ( SL: ' || p_txmsg.txfields('10').value || ', CK: ' || var1 || ', %phí: ' || var2 || ')';
        end if;
        if p_apptype='CI' and p_apptxcd='0012' then
            p_txdesc:='Thanh lý deal ' || p_txmsg.txfields('02').value || ' ( SL: ' || p_txmsg.txfields('10').value || ', CK: ' || var1 || ', %phí: ' || var2 || ')';
        end if;
        if p_apptype='CI' and p_apptxcd='0029' then
            p_txdesc:='Phí thanh lý deal ' || p_txmsg.txfields('02').value || ' ( SL: ' || p_txmsg.txfields('10').value || ', CK: ' || var1 || ', %phi: ' || var2 || ')';
        end if;
      end if;

      plog.setendsection(pkgctx, 'fn_DBgen_trandesc');
      return p_txdesc;
   exception when others then
      plog.setendsection(pkgctx, 'fn_DBgen_trandesc');
    return '';
   END;

   Function fn_DBgen_trandesc_with_format (p_txmsg IN tx.msg_rectype,
                            p_tltxcd IN varchar2,
                            p_apptype IN varchar2,
                            p_apptxcd IN varchar2,
                            p_txdesc in varchar2
   )
   return varchar2
   IS
        l_txdesc varchar2(1000);
        var1 varchar2(1000);
        var2 varchar2(1000);
        var3 varchar2(1000);
        var4 varchar2(1000);
        l_acctno varchar(20);
        l_rlsdate date;
        l_rlsamt number;
        l_catype varchar2(100);
        l_strtxdesc varchar2(100);
   BEGIN
      plog.setbeginsection(pkgctx, 'fn_DBgen_trandesc_with_format');
      begin
          select substr(trdesc,16) into l_txdesc
          from v_appmap_by_tltxcd
          where tltxcd = p_txmsg.tltxcd and apptype = p_apptype and substr(trdesc,9,4) = p_txdesc
          and substr(trdesc,1,7) = 'FORMAT:';
      exception when others then
            l_txdesc:='';
      end;
      --GianhVG add for 3350,3354
      if p_tltxcd in ('3350','3354') then
         var1:='';
         var2:='';
         var3:='';
         var4:='';

         begin
           select catype into l_catype from camast where camastid = p_txmsg.txfields('02').value;
           if l_catype = '010' then --Co tuc bang tien
              select sb.symbol, ca.devidentrate, to_char(ca.reportdate,'DD/MM/RRRR')
                     , (CASE WHEN ca.catype = '010' AND ca.exerate < 100 THEN
                        (CASE WHEN ca.status = 'K' THEN ' ( ' || UTF8NUMS.C_TXDESC_3350_2 || ', ' ||
                              (100-ca.exerate) || '% )'
                            ELSE ' ( ' || UTF8NUMS.C_TXDESC_3350_1 || ca.exerate || '% )' END
                            ) ELSE NULL END)
                     into var1, var2, var3, l_strtxdesc
              from camast ca, sbsecurities sb
              where camastid = p_txmsg.txfields('02').value and ca.codeid = sb.codeid;
              if p_txdesc = '0001' then --So tien Goc
                 l_txdesc:='Cổ tức bằng tiền ' || var1 || ' ' || var2 || '% chốt ngày ' || var3 || ' ' || l_strtxdesc;
              elsif p_txdesc = '0003' then --So thien thue
                 l_txdesc:='Thuế TNCN cổ tức bằng tiền ' || var1 || ' ' || var2 || '% chốt ngày ' || var3 || ' ' || l_strtxdesc;
              --else
              --   l_txdesc:=p_txmsg.txdesc;
              end if;
           elsif  l_catype = '011' then --Co tuc bang co phieu
              select sb.symbol || ' ' || ca.devidentshares,exprice, to_char(ca.reportdate,'DD/MM/RRRR')
                     into var1, var2, var3
              from camast ca, sbsecurities sb
              where camastid = p_txmsg.txfields('02').value and ca.codeid = sb.codeid;
              if p_txdesc = '0001' then --So tien Goc
                 l_txdesc:='CP lẻ trả bằng tiền của cổ tức bằng cổ phiếu ' || var1 || ' chốt ngày ' || var3 || ',giá '|| var2 || ' d/1CP';
              elsif p_txdesc = '0003' then --So thien thue
                 l_txdesc:='Thuế CP lẻ trả bằng tiền của cổ tức bằng cổ phiếu ' || var1 || ' chốt ngày ' || var3 || ', giá '|| var2 ||  'd/1CP';
              --else
              --   l_txdesc:=p_txmsg.txdesc;
              end if;
           elsif  l_catype = '021' then --Co phieu thuong
              select sb.symbol || ' ' || ca.exrate,exprice, to_char(ca.reportdate,'DD/MM/RRRR')
                     into var1, var2, var3
              from camast ca, sbsecurities sb
              where camastid = p_txmsg.txfields('02').value and ca.codeid = sb.codeid;
              if p_txdesc = '0001' then --So tien Goc
                 l_txdesc:='CP lẻ trả bằng tiền của cổ phiếu thưởng ' || var1 || ' chốt ngày ' || var3 || ', giá '|| var2 || ' d/1CP';
              elsif p_txdesc = '0003' then --So thien thue
                 l_txdesc:='Thuế CP lẻ trả bằng tiền của cổ phiếu thưởng ' || var1 || ' chốt ngày ' || var3 || ', giá '|| var2 || ' d/1CP';
              --else
              --   l_txdesc:=p_txmsg.txdesc;
              end if;
           elsif  l_catype in ('015','016') then --Tra lai trai phieu va Lai + goc trai phieu
              select sb.symbol, ca.exrate,to_char(ca.reportdate,'DD/MM/RRRR'),ca.pitrate
                     into var1, var2 , var3,var4
              from camast ca, sbsecurities sb
              where camastid = p_txmsg.txfields('02').value and ca.codeid = sb.codeid;
              if p_txdesc = '0001' then --So tien Goc
                 l_txdesc:='Gốc trái phiếu ' || var1  || ' ' || var2 || ' chốt ngày ' || var3;
              elsif p_txdesc = '0002' then --So ti?n l?
                 l_txdesc:='Lãi trái phiếu ' || var1  || ' ' || var2 || ' chốt ngày ' || var3;
              elsif p_txdesc = '0002' then --So ti?n l?
                 l_txdesc:='Thuế trái tức ' || var1  || ' ' || var4 || ' chốt ngày ' || var3;
              --else
              --   l_txdesc:=p_txmsg.txdesc;
              end if;
           --T9/2019 CW_PhaseII
           elsif  l_catype in ('028') then --Chi tra loi tuc chung quyen bang tien

              select sb.symbol, ca.devidentrate, to_char(ca.reportdate,'DD/MM/RRRR')
                     into var1, var2, var3
              from camast ca, sbsecurities sb
              where ca.camastid = p_txmsg.txfields('02').value
                    and ca.codeid = sb.codeid;

              if p_txdesc = '0001' then --So tien Goc
                 l_txdesc:='Chi trả lợi tức chứng quyền ' || var1 || ' chốt ngày ' || var3 || ' ' || l_strtxdesc;
              elsif p_txdesc = '0003' then --So thien thue
                 l_txdesc:='Thuế TNCN chi trả lợi tức chứng quyền ' || var1 || ' chốt ngày ' || var3 || ' ' || l_strtxdesc;
              end if;
              --End T9/2019 CW_PhaseII
           --else
           --   l_txdesc:=p_txmsg.txdesc;
           end if;
         exception when others then
           l_txdesc:=l_txdesc;
         end;
      end if;
      --End GianhVG add for 3350
      --GianhVG add for 3351
      if p_tltxcd in ('3351') then
         var1:='';
         var2:='';
         var3:='';
         var4:='';
         l_txdesc:=p_txmsg.txdesc;
         begin
           select catype into l_catype from camast where camastid = p_txmsg.txfields('02').value;
           if l_catype = '014' then --quyen mua
              select sb.symbol, to_char(ca.reportdate,'DD/MM/RRRR')
                     into var1, var2
              from camast ca, sbsecurities sb
              where camastid = p_txmsg.txfields('02').value and nvl(ca.tocodeid,ca.codeid) = sb.codeid;
              if p_txdesc = '0001' then --Chung khoan nhan
                 l_txdesc:='Phân bổ chứng khoán mua phát hành thêm' || var1 || ' chốt ngày ' || var2;
              end if;
           elsif  l_catype = '011' then --Co tuc bang co phieu
              select sb.symbol || ' ' || ca.devidentshares,to_char(ca.reportdate,'DD/MM/RRRR')
                     into var1, var2
              from camast ca, sbsecurities sb
              where camastid = p_txmsg.txfields('02').value and ca.codeid = sb.codeid;
              if p_txdesc = '0001' then --Chung khoan nhan
                 l_txdesc:='Cổ tức bằng cổ phiếu ' || var1 || ' chốt ngày ' || var2;
              end if;
           elsif  l_catype = '021' then --Co phieu thuong
              select sb.symbol || ' ' || ca.exrate,to_char(ca.reportdate,'DD/MM/RRRR')
                     into var1, var2
              from camast ca, sbsecurities sb
              where camastid = p_txmsg.txfields('02').value and ca.codeid = sb.codeid;
              if p_txdesc = '0001' then --Chung kho?nhan
                 l_txdesc:='Cổ phiếu thưởng' || var1 || ' chốt ngày ' || var2;
              end if;
           elsif  l_catype in ('020') then --Chuyen chung khoan thanh chung khoan
              select sb.symbol,sbto.symbol, ca.devidentshares,to_char(ca.reportdate,'DD/MM/RRRR')
                     into var1, var2 , var3, var4
              from camast ca, sbsecurities sb , sbsecurities sbto
              where camastid = p_txmsg.txfields('02').value
              and ca.codeid = sb.codeid
              and ca.tocodeid = sbto.codeid;
              if p_txdesc = '0001' then --Chung kho?nhan
                 l_txdesc:='Chuyển chứng khoán' || var1  || ' thành chứng khoán' || var2 || ' tỷ lệ ' || var3;
              elsif p_txdesc = '0002' then --chung khoan chuyen doi
                 l_txdesc:='Chuyển chứng khoán' || var1  || ' thành chứng khoán' || var2 || ' tỷ lệ ' || var3;
              end if;
           --else
           --   l_txdesc:=p_txmsg.txdesc;
           end if;
         exception when others then
           l_txdesc:=l_txdesc;
         end;
      end if;
      --End GianhVG add for 3351
      --GianhVG add for 3382,3383,3385, 3384,3394
      if p_tltxcd in ('3383','3385','3382', '3384', '3394') then
         l_txdesc := l_txdesc || ' ' || trim(to_char(TO_NUMBER(p_txmsg.txfields('21').value), '999,999,999,999,999,999'));
         if   p_tltxcd in ('3384', '3394') then
              l_txdesc := l_txdesc || ' ' || p_txmsg.txfields('04').value;
         else
              l_txdesc := l_txdesc || ' ' || p_txmsg.txfields('35').value;
         end if;
      end if;
      --End GianhVG add add for 3382,3383,3385, 3384,3394


      if p_tltxcd = '0066' then
         if p_txdesc = '0001' then
            l_txdesc:= p_txmsg.txfields('30').value || ' (CK quyền)';
         end if;
      end if;
      if p_tltxcd = '5566' then
            if p_apptype = 'CI' then
                begin
                    select nvl(nvl(cf.mnemonic,cf.shortname),cspks_system.fn_get_sysvar('SYSTEM','COMPANYSHORTNAME'))
                        into var1
                    from lnmast ln, cfmast cf
                    where ln.custbank = cf.custid(+) and ln.acctno = to_char(p_txmsg.txfields('03').value);
                exception when others then
                    var1:='';
                end;
                l_txdesc:= replace(l_txdesc,'<$BANKNAME>',var1);
                l_txdesc:= replace(l_txdesc,'<$TXDATE>',to_char(p_txmsg.txdate,'DD.MM.RRRR'));
                /*
10  FORMAT:[0001]>>Giai ngan <$BANKNAME>/CL/<$TXDATE>/<$AMT>
11  FORMAT:[0002]>>Giai ngan BVSC/BL/<$TXDATE>/<$AMT>
10  FORMAT:[0003]>>Giai ngan <$BANKNAME>/CL/<$TXDATE>/<$AMT>
11  FORMAT:[0004]>>Giai ngan BVSC/BL/<$TXDATE>/<$AMT>
                */
                if p_txdesc = '0001' then
                    l_txdesc:= replace(l_txdesc,'<$AMT>',trim(to_char(TO_NUMBER(p_txmsg.txfields('10').value), '999,999,999,999,999,999')));
                end if;
                if p_txdesc = '0002' then
                    l_txdesc:= replace(l_txdesc,'<$AMT>',trim(to_char(TO_NUMBER(p_txmsg.txfields('11').value), '999,999,999,999,999,999')));
                end if;
                if p_txdesc = '0003' then
                    l_txdesc:= replace(l_txdesc,'<$AMT>',trim(to_char(TO_NUMBER(p_txmsg.txfields('10').value), '999,999,999,999,999,999')));
                end if;
                if p_txdesc = '0004' then
                    l_txdesc:= replace(l_txdesc,'<$AMT>',trim(to_char(TO_NUMBER(p_txmsg.txfields('11').value), '999,999,999,999,999,999')));
                end if;
            end if;
      end if;
      if p_tltxcd ='5567' then
            if p_apptype='CI' then
                begin
                    select nvl(nvl(cf.mnemonic,cf.shortname),cspks_system.fn_get_sysvar('SYSTEM','COMPANYSHORTNAME'))
                        into var1
                    from lnmast ln, cfmast cf
                    where ln.custbank = cf.custid(+) and ln.acctno = to_char(p_txmsg.txfields('03').value);
                exception when others then
                    var1:='';
                end;
                l_txdesc:= replace(l_txdesc,'<$BANKNAME>',var1);

                begin
                    select to_char(rlsdate,'DD.MM.RRRR'), trim(to_char((nml+ovd+paid), '999,999,999,999,999,999'))
                        into var1, var2
                    from lnschd where autoid = to_number(p_txmsg.txfields('01').value) and reftype in ('P','GP');
                exception when others then
                    var1:='';
                    var2:='';
                end;
                l_txdesc:= replace(l_txdesc,'<$TXDATE>',var1);
                l_txdesc:= replace(l_txdesc,'<$AMT>',var2);
            end if;
      end if;
      if p_tltxcd ='5540' then
            if p_apptype='CI' then
                begin
                    select nvl(nvl(cf.mnemonic,cf.shortname),cspks_system.fn_get_sysvar('SYSTEM','COMPANYSHORTNAME'))
                        into var1
                    from lnmast ln, cfmast cf
                    where ln.custbank = cf.custid(+) and ln.acctno = to_char(p_txmsg.txfields('03').value);
                exception when others then
                    var1:='';
                end;
                l_txdesc:= replace(l_txdesc,'<$BANKNAME>',var1);

                begin
                    select to_char(rlsdate,'DD.MM.RRRR'), trim(to_char((nml+ovd+paid), '999,999,999,999,999,999'))
                        into var1, var2
                    from lnschd where autoid = to_number(p_txmsg.txfields('01').value) and reftype in ('P','GP');
                exception when others then
                    var1:='';
                    var2:='';
                end;
                l_txdesc:= replace(l_txdesc,'<$TXDATE>',var1);
                l_txdesc:= replace(l_txdesc,'<$AMT>',var2);
            end if;
      end if;
      if p_tltxcd IN ('2673') then
            if p_apptype='SE' then
                l_txdesc:= replace(l_txdesc,'<$TXDATE>',to_char(p_txmsg.txdate,'DD.MM.RRRR'));
                /*
42  FORMAT:[0001]>>Nhap CK cam co/DF/<$TXDATE>/<$AMT>
42  FORMAT:[0002]>>Xuat CK giao dich/DF/<$TXDATE>/<$AMT>
42  FORMAT:[0003]>>Xuat CK phong toa/DF/<$TXDATE>/<$AMT>
                */
                if p_txdesc = '0001' then
                    l_txdesc:= replace(l_txdesc,'<$AMT>',trim(to_char(TO_NUMBER(p_txmsg.txfields('42').value), '999,999,999,999,999,999')));
                end if;
                if p_txdesc = '0002' then
                    l_txdesc:= replace(l_txdesc,'<$AMT>',trim(to_char(TO_NUMBER(p_txmsg.txfields('42').value), '999,999,999,999,999,999')));
                end if;
                if p_txdesc = '0003' then
                    l_txdesc:= replace(l_txdesc,'<$AMT>',trim(to_char(TO_NUMBER(p_txmsg.txfields('42').value), '999,999,999,999,999,999')));
                end if;
            end if;
      end if;
      if p_tltxcd IN ('2661') then
            if p_apptype='SE' then
                l_txdesc:= replace(l_txdesc,'<$TXDATE>',to_char(p_txmsg.txdate,'DD.MM.RRRR'));
                /*
FORMAT:[0001]>>Nh?p ch?ng kho?c?m c? d? b?<$DEALID>
FORMAT:[0002]>>Xu?t ch?ng kho?ch? v? d? b?<$DEALID>
                */
                if p_txdesc = '0001' then
                    l_txdesc:= replace(l_txdesc,'<$DEALID>',trim(to_char(TO_NUMBER(p_txmsg.txfields('02').value), '999,999,999,999,999,999')));
                end if;
                if p_txdesc = '0002' then
                    l_txdesc:= replace(l_txdesc,'<$DEALID>',trim(to_char(TO_NUMBER(p_txmsg.txfields('02').value), '999,999,999,999,999,999')));
                end if;
            end if;
      end if;

      if p_tltxcd IN ('2673','2674','2624') then
            if p_apptype='CI' then
                begin
                    if p_tltxcd = '2624' then
                      select nvl(nvl(cf.mnemonic,cf.shortname),cspks_system.fn_get_sysvar('SYSTEM','COMPANYSHORTNAME'))
                          into var1
                      from dftype dft, lntype lnt, cfmast cf
                      where dft.lntype = lnt.actype and lnt.custbank = cf.custid(+)
                      and dft.actype in (select actype from dfgroup where groupid = p_txmsg.txfields('20').value ) ;

                    else
                      select nvl(nvl(cf.mnemonic,cf.shortname),cspks_system.fn_get_sysvar('SYSTEM','COMPANYSHORTNAME'))
                          into var1
                      from dftype dft, lntype lnt, cfmast cf
                      where dft.lntype = lnt.actype and lnt.custbank = cf.custid(+)
                      and dft.actype = to_char(p_txmsg.txfields('04').value);
                    end if;

                exception when others then
                    var1:='';
                end;
                l_txdesc:= replace(l_txdesc,'<$BANKNAME>',var1);
                l_txdesc:= replace(l_txdesc,'<$TXDATE>',to_char(p_txmsg.txdate,'DD.MM.RRRR'));
                /*
41  FORMAT:[0002]>>Giai ngan <$BANKNAME>/DF/<$TXDATE>/<$AMT>
41  FORMAT:[0001]>>Giai ngan <$BANKNAME>/DF/<$TXDATE>/<$AMT>
                */
                if p_txdesc = '0001' then
                    l_txdesc:= replace(l_txdesc,'<$AMT>',trim(to_char(TO_NUMBER(p_txmsg.txfields('41').value), '999,999,999,999,999,999')));
                end if;
                if p_txdesc = '0002' then
                    l_txdesc:= replace(l_txdesc,'<$AMT>',trim(to_char(TO_NUMBER(p_txmsg.txfields('42').value), '999,999,999,999,999,999')));
                end if;
            end if;
      end if;


      if p_tltxcd in ('2646','2648','2664','2665','2636','2635') then
            if p_apptype='CI' then

                if p_tltxcd in ('2646','2635','2664') then
                   l_acctno:=p_txmsg.txfields('20').value ;
                elsif p_tltxcd IN ('2648','2665') then
                    l_acctno:=p_txmsg.txfields('05').value ;
                end if;

                begin
                    SELECT nvl(nvl(cf.mnemonic,cf.shortname),cspks_system.fn_get_sysvar('SYSTEM','COMPANYSHORTNAME')), lnm.rlsdate, lnm.rlsamt
                    into var1, l_rlsdate, l_rlsamt
                    FROM LNTYPE LNT, CFMAST cf, lnmast lnm
                    where  lnt.actype=lnm.actype and lnt.custbank = cf.custid(+)
                    and lnm.acctno in (SELECT LNACCTNO FROM DFGROUP WHERE GROUPID = l_acctno );
                exception when others then
                    var1:='';
                end;

                if p_tltxcd = '2636' then
                    begin
                        SELECT nvl(nvl(cf.mnemonic,cf.shortname),cspks_system.fn_get_sysvar('SYSTEM','COMPANYSHORTNAME')), lnm.rlsdate, lnm.rlsamt
                        into var1, l_rlsdate, l_rlsamt
                        FROM LNTYPE LNT, CFMAST cf, lnmast lnm
                        where  lnt.actype=lnm.actype and lnt.custbank = cf.custid(+)
                        and lnm.acctno = p_txmsg.txfields('05').value ;
                    exception when others then
                        var1:='';
                    end;
                END IF;

                l_txdesc:= replace(l_txdesc,'<$BANKNAME>',var1);
                l_txdesc:= replace(l_txdesc,'<$TXDATE>',to_char(l_rlsdate,'DD.MM.RRRR'));

                if p_txdesc = '0001' then
                    l_txdesc:= replace(l_txdesc,'<$AMT>',trim(to_char(TO_NUMBER(l_rlsamt), '999,999,999,999,999,999')));
                end if;
                if p_txdesc = '0002' then
                    l_txdesc:= replace(l_txdesc,'<$AMT>',trim(to_char(TO_NUMBER(l_rlsamt), '999,999,999,999,999,999')));
                end if;
                if p_txdesc = '0003' then
                    l_txdesc:= replace(l_txdesc,'<$AMT>',trim(to_char(TO_NUMBER(l_rlsamt), '999,999,999,999,999,999')));
                end if;
                if p_txdesc = '0004' then
                    l_txdesc:= replace(l_txdesc,'<$AMT>',trim(to_char(TO_NUMBER(l_rlsamt), '999,999,999,999,999,999')));
                end if;
            end if;
      end if;
      if p_tltxcd = '0088' then
            if p_apptype = 'CI' then
               if p_txdesc = '0001' then
                l_txdesc:= replace(l_txdesc,'<$TXDATE>',to_char(p_txmsg.txdate,'MM/RRRR'));
                END IF;
               if p_txdesc = '0002' then
                l_txdesc:= replace(l_txdesc,'<$TXDATE>',to_char(p_txmsg.txdate,'MM/RRRR'));
                END IF;
            end if;
      end if;
      if p_tltxcd = '8894' THEN
          if p_apptype = 'CI' then
              if p_txdesc = '0001'  then
                  l_txdesc:= 'Thuế giao dịch cổ phiếu lô lẻ';
              END IF;
              if p_txdesc = '0002' then
                  l_txdesc:= 'Thuế TNCN cổ phiếu lô lẻ';
              END IF;
              if p_txdesc = '0003' then
                  l_txdesc:= 'Phí cổ phiếu lô lẻ';
              END IF;
              if p_txdesc = '0004' then
                  l_txdesc:= 'Thuế TNCN khi bán từ nguồn CT=CP';
              END IF;
          end if;
      end if;
     if p_tltxcd = '1670' then
            if p_apptype = 'TD' then
               if p_txdesc = '0001' then
                l_txdesc:= 'Gửi '|| p_txmsg.txfields('10').value || ' tiết kiệm, loại hình ' || p_txmsg.txfields('81').value;
                END IF;
              end if;
      end if;
       if p_tltxcd='1610' then
            if p_apptype = 'TD' then
               if p_txdesc = '0001' then
                l_txdesc:= 'Nhập ' || p_txmsg.txfields('11').value ||' lãi vào gốc'  ;
                END IF;
              end if;
      end if;
      if p_tltxcd='5574' then
            if p_apptype = 'CI' then
               if p_txdesc = '0001' then
                l_txdesc:='Trả phí gia hạn vay ký quỹ món '|| p_txmsg.txfields('12').value||
                           'giải ngân ngày '|| p_txmsg.txfields('91').value|| 'đến hạn ngày ' ||
                            p_txmsg.txfields('90').VALUE;
                END IF;
              end if;
      end if;
      if p_tltxcd='1184' then
            if p_apptype = 'CI' then
               if p_txdesc = '0001' then
                l_txdesc:='Thu phí nhận chuyển khoản chứng khoán còn nợ';
                END IF;
              end if;
      end if;
      if p_tltxcd = '1153' then
            if p_apptype = 'CI' then
               if p_txdesc in ('0001', '0002','0003','0004') then
                l_txdesc:= replace(l_txdesc,'<$42>', p_txmsg.txfields('42').value);
                l_txdesc:= replace(l_txdesc,'<$08>',p_txmsg.txfields('08').value);
                END IF;

            end if;
      end if;
      plog.setendsection(pkgctx, 'fn_DBgen_trandesc_with_format');
      return l_txdesc;
   exception when others then
        plog.setendsection(pkgctx, 'fn_DBgen_trandesc_with_format');
        return '';
   END fn_DBgen_trandesc_with_format;

   FUNCTION fn_PasswordGenerator (p_PwdLenght IN varchar2)
      RETURN VARCHAR2
   IS
      l_Password   sysvar.varvalue%TYPE;
   BEGIN

     -- SELECT upper(dbms_random.string('U', 10)) str INTO l_Password from dual;
      SELECT   ROUND (dbms_random.value(100000,999998)) str INTO l_Password from dual;
      RETURN l_Password;
   END;


   Function fn_CRBGen_trandesc (p_txmsg IN tx.msg_rectype,
                            p_tltxcd IN varchar2,
                            p_apptxcd IN varchar2
   )
   return varchar2
   IS
        p_txdesc varchar2(1000);
        --var1 varchar2(1000);
        --var2 varchar2(1000);
        --var3 varchar2(1000);
   BEGIN
      plog.setbeginsection(pkgctx, 'fn_CRBGen_trandesc');
      plog.debug (pkgctx, 'p_tltxcd:' || p_tltxcd);
      plog.debug (pkgctx, 'p_apptxcd:' || p_apptxcd);

      p_txdesc:='';

      Select max(trdesc) into p_txdesc
      from citran tr
      where tr.txnum = p_txmsg.txnum
           and tr.txdate = to_date(p_txmsg.txdate, 'DD/MM/RRRR')
           and tr.tltxcd = p_tltxcd
           and tr.txcd = p_apptxcd;



      plog.setendsection(pkgctx, 'fn_CRBGen_trandesc');
      return p_txdesc;
   exception when others then
      plog.setendsection(pkgctx, 'fn_CRBGen_trandesc');
    return '';
   END fn_CRBGen_trandesc;

   function fn_random_str(v_length number) return varchar2 is
    my_str varchar2(4000);
    begin
    for i in 1..v_length loop
        my_str := my_str || dbms_random.string(
            case when dbms_random.value(0, 1) < 0.5 then 'l' else 'x' end, 1);
    end loop;
    return my_str;
    END;
    function fn_random_num(v_length number) return varchar2 is
    my_str varchar2(4000);
    begin
    for i in 1..v_length loop
        my_str := my_str || TRUNC(DBMS_RANDOM.value(1,9));
    end loop;
    return my_str;
    END;

-- initial LOG
BEGIN
   SELECT *
   INTO logrow
   FROM tlogdebug
   WHERE ROWNUM <= 1;

   pkgctx    :=
      plog.init ('CSPKS_SYSTEM',
                 plevel => logrow.loglevel,
                 plogtable => (logrow.log4table = 'Y'),
                 palert => (logrow.log4alert = 'Y'),
                 ptrace => (logrow.log4trace = 'Y')
      );
END;

/
