SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "RE_CHANGE_CFSTATUS_BF" is
     v_currdate date;
     v_dmday number(10);
     v_olddmsts VARCHAR2(1);
     v_oldafstatus varchar2(1);
     v_oldlastdate date;
     v_oldactivedate date;
     v_newdmsts VARCHAR2(1);
     v_newafstatus varchar2(1);
     v_newlastdate date;
     v_newactivedate date;
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
    -- Cac tk co gd trong ngay
    For vc in (Select distinct cf.custodycd, cf.lastdate,cf.activedate,cf.dmsts,cf.afstatus
            From iod i, cfmast cf
            where i.deltd<>'Y'
            and i.custodycd=cf.custodycd)
    Loop
      v_olddmsts:=vc.dmsts;
      v_oldafstatus:=vc.afstatus;
      v_oldlastdate:=vc.lastdate;
      v_oldactivedate:=vc.activedate;
      v_newdmsts:=vc.dmsts;
      v_newafstatus:=vc.afstatus;
      v_newlastdate:=v_currdate;
      v_newactivedate:=vc.activedate;
      If vc.dmsts='Y' then
         -- Danh dau thuc
         Update cfmast cf
         Set dmsts='N',
             activedate =  v_currdate
         Where cf.custodycd=vc.custodycd;
         v_newdmsts:='N';
         v_newactivedate:=v_currdate;
         -- Chuyen tu khach hang cu ->kh moi
         If vc.afstatus='O' then
             Update Cfmast
             Set afstatus = 'N'
             where custodycd = vc.custodycd;
             v_newafstatus:='N';
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
                   Insert into reaflnk(autoid, txdate, txnum, refrecflnkid, reacctno,
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
         End if;--vc.afstatus='O'
        insert into changecfstslog(txdate,custodycd,olddmsts,oldafstatus,oldlastdate,oldactivedate,
               newdmsts,newafstatus,newlastdate,newactivedate)
        values(v_currdate,vc.custodycd,v_olddmsts,v_oldafstatus,v_oldlastdate,v_oldactivedate,
               v_newdmsts,v_newafstatus,v_newlastdate,v_newactivedate);
      End if; --   vc.dmsts='Y'

     -- Cap nhat ngay gd cuoi cung
     Update CFMAST cf
     Set lastdate = v_currdate
     where cf.custodycd = vc.custodycd;
    End loop;

    -- Danh dau ngu
    insert into changecfstslog(txdate,custodycd,olddmsts,oldafstatus,oldlastdate,oldactivedate,
               newdmsts,newafstatus,newlastdate,newactivedate)
    select v_currdate txdate , custodycd,dmsts,afstatus,lastdate,activedate,
           'Y',afstatus,lastdate,activedate
    from cfmast cf
    where cf.lastdate + v_dmday <= v_currdate
         and dmsts='N';
    Update cfmast cf
    Set dmsts='Y'
    Where  cf.lastdate + v_dmday <= v_currdate
         and dmsts='N';
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        return ;
END; -- Procedure

 
 
 
 
/
