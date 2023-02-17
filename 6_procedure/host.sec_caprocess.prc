SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "SEC_CAPROCESS" (pv_strTxDate IN VARCHAR2)
IS
/* pv_strTxDate: Ngay xu ly */
-- Purpose: Tao deal mo trang thai cua khach hang
--
-- MODIFICATION HISTORY
-- Person      Date        Comments
-- VinhLD      19/07/2012
-- ---------   ------  -------------------------------------------
-- Declare program variables as shown above
    v_a         NUMBER ;
    v_b         NUMBER ;
    v_CURRDATE  date;
    v_indate    date;
    v_isholiday CHAR;
    v_qtty      number;
    v_aamt      number;
    v_rfprice   number;
    v_count     number;
    l_sectype   varchar2(20);
    l_custid    varchar2(20);

    v_costprice number;
    V_TXDATe    date;
    V_PREVDATE VARCHAR2(10);


BEGIN
    v_a := 0;
    v_b := 0;
    v_indate := to_date(pv_strTxDate,'dd/mm/rrrr');
    v_isholiday := 'Y';
---    v_isholiday := true;

    select min(holiday) into v_isholiday
    from sbcldr where sbdate = v_indate and cldrtype = '000';

    select to_date(varvalue,'dd/mm/rrrr') into v_CURRDATE
    from sysvar where varname = 'CURRDATE' and grname = 'SYSTEM';

    V_PREVDATE:=cspks_system.fn_get_sysvar ('SYSTEM', 'PREVDATE');

    ---delete from dlmast where txdate = v_indate and PSRC = 'C';

----    V_TXDATe := getduedate(to_date(pv_strTxDate,'dd/mm/rrrr'), 'B', '000',2);
    V_TXDATe := to_date(pv_strTxDate,'dd/mm/rrrr');

    if(v_isholiday = 'N') then
        /*for rec in(
            select AF.camastid, AF.Afacctno, AF.CODEID
            from camast ca, focaschd af
            where ca.camastid = AF.camastid and ca.deltd = 'Y' AND AF.DELTD = 'N'
        )
        loop
            UPDATE FOcaschd SET  DELTD  = 'Y'
            WHERE camastid =  REC.camastid AND Afacctno =REC.Afacctno AND CODEID = REC.CODEID ;
        end loop;*/

    --- Co tuc bang co phieu,co phieu thuong.
    for rec in (
        select sb.symbol, ca.catype, ca.camastid, ca.reportdate, ca.duedate,
            ca.devidentshares, ca.rightoffrate, ca.splitrate, ca.exrate, ca.actiondate,
            nvl(ca.tocodeid,ca.excodeid)  excodeid
        from camast ca, sbsecurities sb, vw_tllog_all tl
        where /*ca.STATUS not in ('R','D','E')
            and*/ tl.tltxcd = '3375' and tl.txdate = V_TXDATe
            and ca.codeid = sb.codeid and ca.catype in ('011','021')
            and ca.deltd = 'N' and ca.camastid = tl.msgacct
    )
    loop
        for rec_af in(
            select ca.afacctno, ca.codeid, ca.excodeid, ca.balance, ca.qtty
            from caschd ca, afmast af
            where ca.camastid = rec.camastid and ca.deltd  = 'N'
                and ca.afacctno = af.acctno and af.actype = '0000'
        )
        loop
            INSERT INTO FOcaschd (CAMASTID,QTTY,STATUS,AFACCTNO,CODEID,DELTD,REPORTDATE,ACTIONDATE)
            VALUES(rec.camastid,rec_af.qtty,'N',rec_af.afacctno,rec.excodeid,'N',V_TXDATe,NULL);
        end loop;
        ---co tuc bang co phieu, co phieu thuong.
        for rec_af in(
            select afacctno, codeid, excodeid, balance, qtty
            from caschd where camastid = rec.camastid and deltd = 'N'
        )
        loop
            SELECT count(*) INTO v_count
            FROM SEMAST
            WHERE afACCTNO = rec_af.afacctno and codeid = rec.excodeid;
            IF v_count = 0 THEN
                SELECT max(b.setype), max(a.custid)
                INTO l_sectype,l_custid
                FROM AFMAST A, aftype B
                WHERE A.actype= B.actype
                    AND a.ACCTNO = rec_af.afacctno;
                INSERT INTO SEMAST
                    (ACTYPE,CUSTID,ACCTNO,CODEID,AFACCTNO,OPNDATE,LASTDATE,COSTDT,TBALDT,STATUS,IRTIED,IRCD,
                    COSTPRICE,TRADE,MORTAGE,MARGIN,NETTING,STANDING,WITHDRAW,DEPOSIT,LOAN)
                VALUES(l_sectype, l_custid, rec_af.afacctno || rec.excodeid, rec.excodeid, rec_af.afacctno,
                v_indate, v_indate, v_indate, v_indate, 'A','Y','000', 0,0,0,0,0,0,0,0,0);
            END IF;
            UPDATE SEMAST SET DCRAMT = DCRAMT + 0 , DCRQTTY = DCRQTTY + rec_af.qtty
            WHERE afacctno = rec_af.afacctno and codeid = rec.excodeid;
        end loop;

    end loop;

    ----Tach/gop co phieu , chuyen trai phieu thanh co phieu, chuyen co phieu thanh co phieu, hoan doi co phieu.
    ----
    for rec in (
        select sb.symbol, ca.catype, ca.camastid, ca.reportdate, ca.duedate,
            ca.devidentshares, ca.rightoffrate, ca.splitrate, ca.exrate, ca.actiondate,
            nvl(ca.tocodeid,ca.excodeid) excodeid, ca.codeid
        from camast ca, sbsecurities sb, vw_tllog_all tl
        where ca.codeid = sb.codeid
            and ca.catype in ('012','013','017','018','020')
            and ca.deltd = 'N' and ca.camastid = tl.msgacct
            and tl.tltxcd = '3375' and tl.txdate = V_TXDATe
    )
    loop
        for rec_af in(
            select ca.afacctno, ca.codeid, ca.excodeid excodeid, ca.balance, ca.qtty
            from caschd ca, afmast af
            where ca.camastid = rec.camastid and ca.deltd  = 'N'
                and ca.afacctno = af.acctno and af.actype = '0000'
        )
        loop
            INSERT INTO FOcaschd (CAMASTID,QTTY,STATUS,AFACCTNO,CODEID,DELTD,REPORTDATE,ACTIONDATE)
            VALUES(rec.camastid,rec_af.qtty,'N',rec_af.afacctno,rec.excodeid,'N',V_TXDATe,NULL);
        end loop;

        for rec_af in(
            select afacctno, codeid, excodeid, balance, qtty
            from caschd where camastid = rec.camastid and deltd = 'N'
        )
        loop
            SELECT count(*) INTO v_count
            FROM SEMAST
            WHERE afACCTNO = rec_af.afacctno and codeid = rec.excodeid;
            IF v_count = 0 THEN
                SELECT max(b.setype), max(a.custid)
                INTO l_sectype,l_custid
                FROM AFMAST A, aftype B
                WHERE A.actype= B.actype
                    AND a.ACCTNO = rec_af.afacctno;
                INSERT INTO SEMAST
                    (ACTYPE,CUSTID,ACCTNO,CODEID,AFACCTNO,OPNDATE,LASTDATE,COSTDT,TBALDT,STATUS,IRTIED,IRCD,
                    COSTPRICE,TRADE,MORTAGE,MARGIN,NETTING,STANDING,WITHDRAW,DEPOSIT,LOAN)
                VALUES(l_sectype, l_custid, rec_af.afacctno || rec.excodeid, rec.excodeid, rec_af.afacctno,
                v_indate, v_indate, v_indate, v_indate, 'A','Y','000', 0,0,0,0,0,0,0,0,0);
            END IF;
            select max(costprice) into v_costprice from semast
            where afACCTNO = rec_af.afacctno and codeid = rec.codeid;

            UPDATE SEMAST SET DCRAMT = DCRAMT + rec_af.qtty*v_costprice, DCRQTTY = DCRQTTY + rec_af.qtty
            WHERE afacctno = rec_af.afacctno and codeid = rec.excodeid;
        end loop;
    end loop;

    for rec in(
            select sb.symbol, ca.catype, ca.camastid, ca.reportdate, ca.duedate,
            ca.devidentshares, ca.rightoffrate, ca.splitrate, ca.exrate, ca.actiondate
        from camast ca, sbsecurities sb, vw_tllog_all tl
        where ca.codeid = sb.codeid
            and ca.catype in ('012','013','017','018','020','011','021')
            and ca.deltd = 'N' and ca.camastid = tl.msgacct
            and tl.tltxcd = '3380' and tl.txdate = V_TXDATe
        )
        loop
            update FOcaschd set ACTIONDATE = V_TXDATe, STATUS = 'C'
            where CAMASTID = rec.camastid and DELTD = 'N';
        end loop;

    end if;

EXCEPTION
   WHEN OTHERS THEN
        BEGIN
            dbms_output.put_line('Error... ');
            rollback;
            raise;
            return;
        END;
END;

 
 
 
 
/
