SET DEFINE OFF;
CREATE OR REPLACE FUNCTION FN_GETAVLROOM(p_afacctno in varchar2, p_codeid in VARCHAR2)
RETURN NUMBER
IS
l_remainqtty number;
l_remainamt number;
l_basicprice number;
l_mrrate    number;
l_margintype char(1);
l_istrfbuy  char(1);
l_chksysctrl    char(1);
L_COUNT         NUMBER;
L_ACTYPE        VARCHAR2(10);
L_BRID         VARCHAR2(10);
l_basketid      VARCHAR2(100);
v_seqtty    number;
l_mrmaxqtty  number;
l_roomchk char(1);
BEGIN
l_remainqtty:=0;

       begin
        select roomchk into l_roomchk from semast se where afacctno = p_afacctno and codeid = p_codeid;
        exception when others then
            l_roomchk:='Y';
       end;
         IF l_roomchk='Y' THEN
              begin
                select nvl((rsk.mrratioloan * rsk.mrpriceloan),0), rsk.mrmaxqtty
                    into l_mrrate, l_mrmaxqtty
                from afserisk rsk, afmast af
                where af.actype = rsk.actype
                and af.acctno = p_afacctno and rsk.codeid = p_codeid;
              exception when others then
                l_mrmaxqtty:= 0;
                l_mrrate:=0;
              end;
              if l_istrfbuy ='N' and l_chksysctrl='Y' then --Margin tuan thu he thong thi check
                    if l_mrrate > 0 then
                      select nvl(max(mrmaxqtty - seqtty),0) into l_remainqtty
                      from v_getmarginroominfo
                      where codeid = p_codeid;

                  end if;
              end if;

              --Check room tang ro chung khoan.
            if l_mrrate>0 then --Ma chung khoan co duoc Margin
                --Lay ra thong tin ro chung khoan cua.
                begin
                    Select lnb.basketid into l_basketid
                    from lnsebasket lnb, lntype lnt, aftype aft, afmast af
                    where lnb.actype= lnt.actype and aft.lntype = lnt.actype
                    and aft.actype = af.actype and af.acctno = p_afacctno;
                exception when others then
                    l_basketid:='';
                end;
                if l_basketid is not null then
                    v_seqtty:=fn_getRoomUsedByBasket(p_codeid, l_basketid);
                    l_remainqtty:=l_mrmaxqtty - v_seqtty ;

                end if;

            end if;


          ELSE

            --Cehck room dac biet. Khi nay khong check theo ro va nguon chung nua
            select nvl(se.selimit - fn_getUsedSeLimitByGroup(se.autoid),0) into l_remainqtty
                from afselimitgrp af, selimitgrp se
                where af.refautoid = se.autoid
                and af.afacctno = p_afacctno
                and se.codeid = p_codeid;

          END IF;

     RETURN L_REMAINQTTY;


EXCEPTION when others then
   RETURN 0;
END FN_GETAVLROOM;

 
 
 
 
/
