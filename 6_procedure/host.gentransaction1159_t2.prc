SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "GENTRANSACTION1159_T2" (p_afacctno IN VARCHAR2,
                                p_TOODAMT in number,   -- Phat vay T0
                                p_TOAMT in number   -- Phan bao lanh co the thu hoi
                                )
  IS
    l_tltxcd             VARCHAR2 (30);
    l_txnum              VARCHAR2 (30);
    l_txdate             VARCHAR2 (30);
    l_tlid               VARCHAR2 (30);
    l_brid               VARCHAR2 (30);
    l_ipaddress          VARCHAR2 (30);
    l_wsname             VARCHAR2 (30);
    l_txtime             VARCHAR2 (30);
    l_txdesc             VARCHAR2 (300);

    l_afacctno  VARCHAR2(20);
    l_TOODAMT number(20,0);
    l_TOAMT number(20,0);
    l_dblAmt number(20,0);
    l_release_advanceline number(20,0);
    l_trfamt_aft_rls number(20,0);
BEGIN
    --0 lay cac tham so
    l_brid := '0000';
    l_tlid := '0000';
    l_ipaddress := 'HOST';
    l_wsname := 'HOST';
    l_tltxcd := '1159';

    l_afacctno:=p_afacctno;
    l_TOODAMT:=p_TOODAMT;
    l_TOAMT:=p_TOAMT;
    --Lay TXNUM
    SELECT    '8000'
                  || SUBSTR ('000000' || seq_batchtxnum.NEXTVAL,
                             LENGTH ('000000' || seq_batchtxnum.NEXTVAL) - 5,
                             6
                            )
             INTO l_txnum
             FROM DUAL;
    --Lay TXtime
    SELECT TO_CHAR (SYSDATE, 'HH24:MI:SS')
              INTO l_txtime
              FROM DUAL;
    --lAY TXDATE
    SELECT varvalue
                INTO l_txdate
                FROM sysvar
               WHERE grname = 'SYSTEM' AND varname = 'CURRDATE';
    --txdesc
    l_txdesc:='Tinh toan vay bao lanh va thu hoi han muc';


    --1.TLLOG
    INSERT INTO tllog
            (autoid, txnum,
             txdate, txtime, brid,
             tlid, offid, ovrrqs, chid, chkid, tltxcd, ibt, brid2, tlid2,
             ccyusage, txstatus, msgacct, msgamt, chktime, offtime, off_line,
             deltd, brdate,
             busdate, msgsts, ovrsts, ipaddress, wsname,
             batchname, carebygrp, txdesc
            )
     VALUES (seq_tllog.NEXTVAL, l_txnum,
             TO_DATE (l_txdate, 'DD/MM/RRRR'), l_txtime, l_brid,
             l_tlid, '', '', '', '', l_tltxcd, '', '', '',
             '00', '1', l_afacctno, l_TOODAMT, '', '', 'N',
             'N', TO_DATE (l_txdate, 'DD/MM/RRRR'),
             TO_DATE (l_txdate, 'DD/MM/RRRR'), '0', '0', l_ipaddress, l_wsname,
             'DAY', '', l_txdesc
            );

    --2.TLLOGFLD
    --Hien tai dang off, khong cho gen vao tllogfld nua

    --3.AFTRAN
/*    --Thuc hien tran ghi giam AF.ADVANCELINE bang l_rlsadvanceline
    INSERT INTO aftran
            (acctno, txnum,txdate, txcd, namt, camt, REF,deltd, autoid)
     VALUES (l_afacctno, l_txnum,TO_DATE (l_txdate, 'DD/MM/RRRR'), '0022', l_release_advanceline, '', '','N', seq_aftran.NEXTVAL);
    --Thuc hien tran ghi tang AF.TOAMT bang l_TOAMT
    INSERT INTO aftran
            (acctno, txnum,txdate, txcd, namt, camt, REF,deltd, autoid)
     VALUES (l_afacctno, l_txnum,TO_DATE (l_txdate, 'DD/MM/RRRR'), '0021', l_release_advanceline-l_TOODAMT, '', '','N', seq_aftran.NEXTVAL);*/
    --4.CITRAN
    INSERT INTO citran
            (acctno, txnum,txdate, txcd, namt, camt, REF,deltd, autoid)
     VALUES (l_afacctno, l_txnum,TO_DATE (l_txdate, 'DD/MM/RRRR'), '0061', l_TOODAMT, '', '','N', seq_citran.NEXTVAL);
     --5.Cap nhat lai AFMAST, CIMASt


/*     update afmast
     set advanceline = advanceline - l_release_advanceline, t0amt= t0amt + (l_release_advanceline - l_TOODAMT)
     where acctno =l_afacctno;*/

     update cimast
     set t0odamt=t0odamt + l_TOODAMT
     where acctno =l_afacctno;


     /*select t0amt into l_TOAMT from afmast where acctno = l_afacctno;*/

     /*-- 29-07-2010 - TruongLD Comment lai ko tu dong thu hoi BL nua
     -- Thu hoi han muc T0 cap trong ngay, cap sau thu hoi truoc
     if l_TOAMT > 0 then
        FOR REC IN
        (SELECT AUTOID, TLID, TYPEALLOCATE, ALLOCATEDLIMIT - RETRIEVEDLIMIT AMT FROM (select * from T0LIMITSCHD union all select * from T0LIMITSCHDHIST)
           WHERE ACCTNO = l_afacctno AND ALLOCATEDLIMIT - RETRIEVEDLIMIT > 0
           ORDER BY AUTOID DESC)
        LOOP
            IF l_TOAMT > 0 THEN
                IF l_TOAMT > REC.AMT THEN
                   l_dblAmt := REC.AMT;
                ELSE
                   l_dblAmt := l_TOAMT;
                END IF;
            l_TOAMT := l_TOAMT - l_dblAmt;
            -- Cap nhat giam so luong da phan bo bao lanh
            UPDATE T0LIMITSCHD SET RETRIEVEDLIMIT = RETRIEVEDLIMIT + l_dblAmt WHERE AUTOID = REC.AUTOID;
            UPDATE T0LIMITSCHDHIST SET RETRIEVEDLIMIT = RETRIEVEDLIMIT + l_dblAmt WHERE AUTOID = REC.AUTOID;

            UPDATE USERAFLIMIT SET ACCLIMIT = ACCLIMIT - l_dblAmt
            WHERE ACCTNO = l_afacctno AND TLIDUSER = REC.TLID AND TYPERECEIVE = 'T0';

            INSERT INTO USERAFLIMITLOG (TXNUM,TXDATE,ACCTNO,ACCLIMIT,TLIDUSER,TYPEALLOCATE,TYPERECEIVE)
            VALUES (l_txnum,TO_DATE (l_txdate, 'DD/MM/RRRR'),l_afacctno,-l_dblAmt,REC.TLID,REC.TYPEALLOCATE,'T0');

            INSERT INTO aftran
                  (acctno, txnum,txdate, txcd, namt, camt, REF,deltd, autoid)
            VALUES (l_afacctno, l_txnum,TO_DATE (l_txdate, 'DD/MM/RRRR'), '0020', l_dblAmt, '', '','N', seq_aftran.NEXTVAL);

            update afmast set t0amt = t0amt - l_dblAmt
            where acctno = l_afacctno;

            END IF;
        END LOOP;
    end if;*/

EXCEPTION
    WHEN others THEN
        return;
END;

 
 
 
 
/
