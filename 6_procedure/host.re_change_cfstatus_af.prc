SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "RE_CHANGE_CFSTATUS_AF" is
     v_currdate date;
     v_dmday number(10);
     v_check number(10);
BEGIN
    Select to_date(varvalue,'dd/mm/yyyy') into v_currdate
    From sysvar
    Where varname='CURRDATE' and grname='SYSTEM';
    Begin
        Select to_NUMBER(varvalue) into v_dmday
        From sysvar
        Where varname='DMDAY' and grname='SYSTEM';
    EXCEPTION
    when OTHERS then
        v_dmday:=360;
    End;
       -- Chuyen tu moi -> cu
     For vc in (Select cf.custodycd,cf.lastdate,cf.activedate,cf.dmsts,cf.afstatus
                From  CFmast cf
                Where  dmsts='N' and afstatus='N' and activedate + v_dmday + 1 <= v_currdate) loop

         Update Cfmast
         Set afstatus = 'O'
         where custodycd = vc.custodycd;
         insert into changecfstslog(txdate,custodycd,olddmsts,oldafstatus,oldlastdate,oldactivedate,
               newdmsts,newafstatus,newlastdate,newactivedate)
         values(v_currdate,vc.custodycd,vc.dmsts,vc.afstatus,vc.lastdate,vc.activedate,
               vc.dmsts,'O',vc.lastdate,vc.activedate);

         -- Chuyen doi tk moi gioi cu/moi
         For rec in(SELECT r.autoid, r.txdate, r.txnum, r.refrecflnkid, r.reacctno,
                       r.afacctno, r.frdate, r.todate, r.deltd, r.clstxdate, r.clstxnum,
                       r.pstatus, r.status, r.furefrecflnkid, r.fureacctno
                     From reaflnk r,afmast af, cfmast cf, retype rty
                     WHERE r.status='A'
                      And r.afacctno= af.acctno
                      and af.custid=cf.custid
                      and substr(reacctno,11,4)=rty.actype
                      and rty.rerole in ('RM','BM')
                      And cf.custodycd =  vc.custodycd)
         Loop
                insert into reaflnk(autoid, txdate, txnum, refrecflnkid, reacctno,
                   afacctno, frdate, todate, deltd, clstxdate, clstxnum,
                   pstatus, status, furefrecflnkid, fureacctno)
                          values (seq_reaflnk.nextval,rec.txdate,rec.txnum,rec.furefrecflnkid,rec.fureacctno,
                   rec.afacctno,v_currdate,rec.todate,rec.deltd,null,null,
                   rec.pstatus,rec.status,rec.refrecflnkid,rec.reacctno);

               Update reaflnk
               Set  status='C',
                    clstxdate=v_currdate
               Where autoid = rec.autoid
                    and  reacctno=rec.reacctno
                    and  afacctno=rec.afacctno
                    and   status='A';

               --Kiem tra da ton tai tk moi gioi tuong lai chua
                v_check:=0;
                Begin
                    Select count(custid) into v_check
                    From remast
                    Where status='A' and ACCTNO=rec.fureacctno;
                EXCEPTION when OTHERS then
                     v_check:=0;
                End;
                If v_check=0 then
                     INSERT INTO REMAST (ACCTNO,CUSTID,ACTYPE,STATUS,PSTATUS,
                                        LAST_CHANGE,RATECOMM,BALANCE,DAMTACR,DAMTLASTDT,
                                         IAMTACR, IAMTLASTDT,DIRECTACR,INDIRECTACR,ODFEETYPE,ODFEERATE,COMMTYPE,LASTCOMMDATE)
                     SELECT  rec.fureacctno ACCTNO ,substr(rec.fureacctno,1,10) CUSTID,substr(rec.fureacctno,11,4) ACTYPE, 'A' STATUS,'' PSTATUS,
                                         sysdate LAST_CHANGE, RATECOMM, 0 BALANCE, 0 DAMTACR, v_currdate DAMTLASTDT,
                                         0 IAMTACR , v_currdate IAMTLASTDT , 0 DIRECTACR, 0 INDIRECTACR, ODFEETYPE,ODFEERATE,COMMTYPE,v_currdate  LASTCOMMDATE
                     FROM RETYPE WHERE ACTYPE=substr(rec.fureacctno,11,4);
                End if;
                ----------------

         End loop;
     End loop;

     -- Rut tieu khoan khoi moi gioi khi het han
     update reaflnk
        set status='C',
            clstxdate=v_currdate
        where status='A' and todate<v_currdate;
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        return ;
END; -- Procedure

 
 
 
 
/
