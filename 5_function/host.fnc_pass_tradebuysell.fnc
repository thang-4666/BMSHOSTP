SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fnc_pass_tradebuysell(
v_strAFACCTNO IN Varchar2,
v_txdate date,
v_strCODEID IN Varchar2,
v_strEXECTYPE IN Varchar2,
v_strPRICETYPE IN Varchar2,
v_strMATCHTYPE IN Varchar2,
v_strTRADEPLACE IN VARCHAR2,
l_strSYMBOL IN VARCHAR2,
p_isoddlot in varchar2 default 'N'  --ThangPV chinh sua lo le HSX 19-05-2022
)

RETURN  BOOLEAN IS

v_Return BOOLEAN;

--  Select fnc_check_buy_sell('0001000065',to_date('21/06/2012','DD/MM/YYYY'),'000145','NB','LO','N','002') into v_number from dual ;
    l_strControlCode Varchar2(10);
    v_strTemp  Varchar2(100);
    v_strSysCheckBuySell Varchar2(100); -- chan trong SYSVAR co
    v_strORDERTRADEBUYSELL Varchar2(10); -- sysvar.ORDERTRADEBUYSELL ='N' -> Khong cho dat lenh cho doi ung
    l_count number(20,0);
    l_strTRADEBUYSELL  VARCHAR2(10);-- securities_info.tradebuysell
    v_temp_hosesession  VARCHAR2(20);
    l_strTRADEBUYSELLPT  VARCHAR2(10); -- Y Thi cho phep dat lenh thoa thuan doi ung
    v_Tradelot number;

BEGIN
           v_Return := FALSE;

          /* 1.DucNV kiem tra khi khong cho dat lenh cho doi ung:
              'Y' cho dat lenh cho doi ung ->buoc nay khong check gi
              'N' khong cho dat lenh cho doi ung
          */
          Begin
              Select VARVALUE Into v_strORDERTRADEBUYSELL
              From sysvar
              Where GRNAME ='SYSTEM' and VARNAME ='ORDERTRADEBUYSELL' ;
          EXCEPTION when OTHERS Then
              v_strORDERTRADEBUYSELL:='N';
          End;

          Begin
              Select VARVALUE Into l_strTRADEBUYSELLPT
              From sysvar
              Where GRNAME ='SYSTEM' and VARNAME ='TRADEBUYSELLPT' ;
          EXCEPTION when OTHERS Then
              l_strTRADEBUYSELLPT:='N';
          End;

          -- Neu la lenh thoa thuan va khong check doi ung thoa thuan thi pass luon
          If l_strTRADEBUYSELLPT ='Y' and v_strMATCHTYPE ='P' then
              Return true;
          End if;
          --ThangPV chinh sua lo le HSX 30-05-2022 ROC 1.3
          --Lay thong tin tradelot cua ma chung khoan
          SELECT NVL(Tradelot,0) tradelot, tradebuysell INTO v_tradelot,l_strTRADEBUYSELL FROM securities_info where symbol = l_strSYMBOL;

          l_strControlCode:=fn_get_controlcode(l_strSYMBOL);
          --ThangPV chinh sua lo le HSX 19-05-2022
         /* IF (p_isoddlot = 'Y' AND v_strMATCHTYPE='N') or (p_isoddlot = 'Y' AND v_strMATCHTYPE='P' AND l_strControlCode = 'P') THEN
            return true;
          END IF; */
          --ThangPV chinh sua lo le HSX 30-05-2022 ROC 1.3
          IF (p_isoddlot = 'Y' AND v_strMATCHTYPE='N') THEN
            return true;
          END IF;
          --end ThangPV chinh sua lo le HSX 30-05-2022 ROC 1.3


          IF v_strTRADEPLACE <> '001' THEN          -- ThangPV chinh sua lo le HSX 30-05-2022 ROC 1.3
            If v_strORDERTRADEBUYSELL = 'N'  Then
                If v_strPRICETYPE in('ATC','ATO') then -- chan khong cho nhap 2 lenh ATO,ATC doi ung
                    If v_strEXECTYPE = 'NB' Or v_strEXECTYPE = 'BC' Then
                        SELECT COUNT(*)  into l_count
                        FROM ODMAST
                        WHERE CODEID= v_strCODEID
                            and deltd<>'Y'
                            AND AFACCTNO IN (SELECT ACCTNO FROM AFMAST WHERE CUSTID=(SELECT CUSTID FROM AFMAST WHERE ACCTNO= v_strAFACCTNO ))
                            AND (EXECTYPE='NS' OR EXECTYPE='SS' OR EXECTYPE='MS') AND DELTD = 'N' AND EXPDATE >= TO_DATE(v_txdate, systemnums.C_DATE_FORMAT) AND REMAINQTTY >0
                            and (PRICETYPE=v_strPRICETYPE);
                    Else
                        SELECT COUNT(*) into l_count
                        FROM ODMAST
                        WHERE CODEID= v_strCODEID
                            and deltd<>'Y'
                            AND AFACCTNO IN (SELECT ACCTNO FROM AFMAST WHERE CUSTID=(SELECT CUSTID FROM AFMAST WHERE ACCTNO= v_strAFACCTNO ))
                            AND (EXECTYPE='NB' OR EXECTYPE='BC') AND DELTD = 'N' AND EXPDATE >= TO_DATE(v_txdate, systemnums.C_DATE_FORMAT)  AND REMAINQTTY >0
                            and (PRICETYPE=v_strPRICETYPE);
                    End If;

                    If l_count > 0 Then
                       -- Khong cho phep dat lenh cho khi dang co lenh doi ung chua khop
                        Return v_Return;
                    End If;

                End if;
                If (
                    v_strTRADEPLACE = '001'
                    and  l_strControlCode not in('O','I','C')
                    )
                    or
                    (
                    v_strTRADEPLACE in('002','005')
                    and l_strControlCode  in('CLOSE','CLOSE_BL')
                    )
                    Then
                        v_temp_hosesession:='';
                        If v_strTRADEPLACE = '001' then
                            If l_strControlCode in ('A') then
                                v_temp_hosesession:='A';
                            else
                                v_temp_hosesession:='ALL';
                            end if;
                        else
                            If l_strControlCode in ('CLOSE','CLOSE_BL') then
                                v_temp_hosesession:='CLOSE%';
                            else
                                v_temp_hosesession:='ALL';
                            end if;
                        end if;
                        If v_strEXECTYPE = 'NB' Or v_strEXECTYPE = 'BC' Then
                            SELECT COUNT(*)  into l_count
                            FROM ODMAST
                            WHERE CODEID= v_strCODEID
                                and deltd<>'Y'
                                AND AFACCTNO IN (SELECT ACCTNO FROM AFMAST WHERE CUSTID=(SELECT CUSTID FROM AFMAST WHERE ACCTNO= v_strAFACCTNO ))
                                AND (EXECTYPE='NS' OR EXECTYPE='SS' OR EXECTYPE='MS') AND DELTD = 'N' AND EXPDATE >= TO_DATE(v_txdate, systemnums.C_DATE_FORMAT) AND REMAINQTTY >0
                                and (v_temp_hosesession='ALL' or nvl(hosesession,'N') like v_temp_hosesession)
                                and (    l_strTRADEBUYSELLPT ='N'
                                    OR (l_strTRADEBUYSELLPT ='Y' AND matchtype<>'P'
                                    ));

                        Else
                            SELECT COUNT(*) into l_count
                            FROM ODMAST
                            WHERE CODEID= v_strCODEID
                            and deltd<>'Y'
                            AND AFACCTNO IN (SELECT ACCTNO FROM AFMAST WHERE CUSTID=(SELECT CUSTID FROM AFMAST WHERE ACCTNO= v_strAFACCTNO ))
                            AND (EXECTYPE='NB' OR EXECTYPE='BC') AND DELTD = 'N' AND EXPDATE >= TO_DATE(v_txdate, systemnums.C_DATE_FORMAT)  AND REMAINQTTY >0
                            and (v_temp_hosesession='ALL' or nvl(hosesession,'N') like v_temp_hosesession)
                            and (    l_strTRADEBUYSELLPT ='N'
                                 OR (l_strTRADEBUYSELLPT ='Y' AND matchtype<>'P'
                                 ));
                        End If;

                    If l_count > 0 Then
                       -- Khong cho phep dat lenh cho khi dang co lenh doi ung chua khop
                        Return v_Return;
                    End If;
                End if;
            End if ;
          else  -- ThangPV chinh sua lo le HSX 30-05-2022 ROC 1.3
            If v_strORDERTRADEBUYSELL = 'N' Then
               If v_strPRICETYPE in('ATC','ATO') then -- chan khong cho nhap 2 lenh ATO,ATC doi ung
                 If v_strEXECTYPE = 'NB' Or v_strEXECTYPE = 'BC' Then
                   SELECT COUNT(*)  into l_count
                   FROM ODMAST
                   WHERE CODEID= v_strCODEID
                         and deltd<>'Y'
                         AND AFACCTNO IN (SELECT ACCTNO FROM AFMAST WHERE CUSTID=(SELECT CUSTID FROM AFMAST WHERE ACCTNO= v_strAFACCTNO ))
                         AND (EXECTYPE='NS' OR EXECTYPE='SS' OR EXECTYPE='MS') AND DELTD = 'N' AND EXPDATE >= TO_DATE(v_txdate, systemnums.C_DATE_FORMAT) AND REMAINQTTY >0
                         and (PRICETYPE=v_strPRICETYPE)
                          AND ( (l_strTRADEBUYSELLPT ='Y' AND ORDERQTTY >= v_tradelot  AND MATCHTYPE='N' )-- neu lenh thuong lo chan va khong check voi thoa thuan-> thi chi check doi ung voi lenh thuong lo chan
                             OR
                             (l_strTRADEBUYSELLPT ='N' And (MATCHTYPE='P' OR (MATCHTYPE='N' AND ORDERQTTY >= v_tradelot) ))
                             );
                 Else
                   SELECT COUNT(*) into l_count
                   FROM ODMAST
                   WHERE CODEID= v_strCODEID
                         and deltd<>'Y'
                         AND AFACCTNO IN (SELECT ACCTNO FROM AFMAST WHERE CUSTID=(SELECT CUSTID FROM AFMAST WHERE ACCTNO= v_strAFACCTNO ))
                         AND (EXECTYPE='NB' OR EXECTYPE='BC') AND DELTD = 'N' AND EXPDATE >= TO_DATE(v_txdate, systemnums.C_DATE_FORMAT)  AND REMAINQTTY >0
                         and (PRICETYPE=v_strPRICETYPE)
                         AND ( (l_strTRADEBUYSELLPT ='Y' AND ORDERQTTY >= v_tradelot  AND MATCHTYPE='N' )-- neu lenh thuong lo chan va khong check voi thoa thuan-> thi chi check doi ung voi lenh thuong lo chan
                             OR
                             (l_strTRADEBUYSELLPT ='N' And (MATCHTYPE='P' OR (MATCHTYPE='N' AND ORDERQTTY >= v_tradelot) ))
                             );
                 End If;

                 If l_count > 0 Then
                   -- Khong cho phep dat lenh cho khi dang co lenh doi ung chua khop
                   Return v_Return;
                 End If;
               End if;

               If ( v_strTRADEPLACE = '001' and  l_strControlCode not in('O','I','C'))
                or
                  (v_strTRADEPLACE in('002','005') and l_strControlCode  in('CLOSE','CLOSE_BL'))
               Then
                 v_temp_hosesession:='';
                 If v_strTRADEPLACE = '001' then
                   If l_strControlCode in ('A') then
                     v_temp_hosesession:='A';
                   else
                     v_temp_hosesession:='ALL';
                   end if;
                 else
                   If l_strControlCode in ('CLOSE','CLOSE_BL') then
                     v_temp_hosesession:='CLOSE%';
                   else
                     v_temp_hosesession:='ALL';
                   end if;
                 end if;
                 If v_strEXECTYPE = 'NB' Or v_strEXECTYPE = 'BC' Then
                   SELECT COUNT(*)  into l_count
                   FROM ODMAST
                   WHERE CODEID= v_strCODEID
                         and deltd<>'Y'
                         AND AFACCTNO IN (SELECT ACCTNO FROM AFMAST WHERE CUSTID=(SELECT CUSTID FROM AFMAST WHERE ACCTNO= v_strAFACCTNO ))
                         AND (EXECTYPE='NS' OR EXECTYPE='SS' OR EXECTYPE='MS') AND DELTD = 'N' AND EXPDATE >= TO_DATE(v_txdate, systemnums.C_DATE_FORMAT) AND REMAINQTTY >0
                         and (v_temp_hosesession='ALL' or nvl(hosesession,'N') like v_temp_hosesession)
                         AND ( (l_strTRADEBUYSELLPT ='Y' AND ORDERQTTY >= v_tradelot  AND MATCHTYPE='N' )-- neu lenh thuong lo chan va khong check voi thoa thuan-> thi chi check doi ung voi lenh thuong lo chan
                             OR
                             (l_strTRADEBUYSELLPT ='N' And (MATCHTYPE='P' OR (MATCHTYPE='N' AND ORDERQTTY >= v_tradelot) ))
                             );

                 Else
                   SELECT COUNT(*) into l_count
                   FROM ODMAST
                   WHERE CODEID= v_strCODEID
                         and deltd<>'Y'
                         AND AFACCTNO IN (SELECT ACCTNO FROM AFMAST WHERE CUSTID=(SELECT CUSTID FROM AFMAST WHERE ACCTNO= v_strAFACCTNO ))
                         AND (EXECTYPE='NB' OR EXECTYPE='BC') AND DELTD = 'N' AND EXPDATE >= TO_DATE(v_txdate, systemnums.C_DATE_FORMAT)  AND REMAINQTTY >0
                         and (v_temp_hosesession='ALL' or nvl(hosesession,'N') like v_temp_hosesession)
                          AND ( (l_strTRADEBUYSELLPT ='Y' AND ORDERQTTY >= v_tradelot  AND MATCHTYPE='N' )-- neu lenh thuong lo chan va khong check voi thoa thuan-> thi chi check doi ung voi lenh thuong lo chan
                             OR
                             (l_strTRADEBUYSELLPT ='N' And (MATCHTYPE='P' OR (MATCHTYPE='N' AND ORDERQTTY >= v_tradelot) ))
                             );
                 End If;

                 If l_count > 0 Then
                    -- Khong cho phep dat lenh cho khi dang co lenh doi ung chua khop
                    Return v_Return;
                 End If;
               End if;
             End if ;
          end if;
        --end ThangPV chinh sua lo le HSX 30-05-2022 ROC 1.3

         -- 2.Chan lenh doi ung khi khai bao o Securies_info.tradebuysel into l_strTRADEBUYSELL
         Select tradebuysell into l_strTRADEBUYSELL
          From securities_info
          where symbol=l_strSYMBOL;
         If l_strTRADEBUYSELL = 'N' Then
                If v_strEXECTYPE = 'NB' Or v_strEXECTYPE = 'BC' Then
                    SELECT COUNT(*)  into l_count FROM ODMAST WHERE CODEID= v_strCODEID  AND AFACCTNO IN (SELECT ACCTNO FROM AFMAST WHERE CUSTID=(SELECT CUSTID FROM AFMAST WHERE ACCTNO= v_strAFACCTNO ))
                    AND (EXECTYPE='NS' OR EXECTYPE='SS' OR EXECTYPE='MS') AND DELTD = 'N' AND EXPDATE >= TO_DATE(v_txdate, systemnums.C_DATE_FORMAT) AND REMAINQTTY+EXECQTTY>0;
                Else
                    SELECT COUNT(*) into l_count FROM ODMAST WHERE CODEID= v_strCODEID  AND AFACCTNO IN (SELECT ACCTNO FROM AFMAST WHERE CUSTID=(SELECT CUSTID FROM AFMAST WHERE ACCTNO= v_strAFACCTNO ))
                    AND (EXECTYPE='NB' OR EXECTYPE='BC') AND DELTD = 'N' AND EXPDATE >= TO_DATE(v_txdate, systemnums.C_DATE_FORMAT)  AND REMAINQTTY+EXECQTTY>0;
                End If;
                If l_count > 0 Then
                    --Bao loi khong duoc mua ban mot chung khoan trong cuang 1 ngay
                    Return v_Return;
                End If;
        End if;
        -- Ket thuc chan lenh doi ung
        v_Return := TRUE;
 Return v_Return;
EXCEPTION when OTHERS Then
    Return true;
END;
 
/
