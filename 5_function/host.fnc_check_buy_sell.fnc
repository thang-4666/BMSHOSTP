SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fnc_check_buy_sell
(
v_strAFACCTNO IN Varchar2,
v_txdate date,
v_strCODEID IN Varchar2,
v_strEXECTYPE IN Varchar2,
v_strPRICETYPE IN Varchar2,
v_strMATCHTYPE IN Varchar2,
v_strTRADEPLACE IN Varchar2
)

RETURN  BOOLEAN IS
v_Return BOOLEAN;

--  Select fnc_check_buy_sell('0001000065',to_date('21/06/2012','DD/MM/YYYY'),'000145','NB','LO','N','002') into v_number from dual ;
    l_strControlCode Varchar2(10);
    v_strTemp  Varchar2(100);
    v_strSysCheckBuySell Varchar2(100); -- chan trong SYSVAR co
    v_strORDERTRADEBUYSELL Varchar2(10); -- Chan trong SYVAR co duoc dat truoc lenh cho` hay ko
    l_count number(20,0);
    l_strTRADEBUYSELL Varchar2(10); --chan duoi bang securities_info


BEGIN

 Select tradebuysell into l_strTRADEBUYSELL  from securities_info where codeid=v_strCODEID;
 Select VARVALUE Into v_strORDERTRADEBUYSELL from sysvar where GRNAME ='SYSTEM' and VARNAME ='ORDERTRADEBUYSELL' ;

 ------------------------------------------
   --Kiem tra chung khoan khong duoc vua mua vua ban trong ngay
  -- quyet.kieu Ghep them phan mua ban cung ngay theo thong tu 74




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
                    v_Return := FALSE;
                    Return v_Return;
                    else
                     v_Return := true;
                     Return v_Return;
                End If;

            Elsif l_strTRADEBUYSELL = 'Y' And v_strTRADEPLACE = errnums.gc_TRADEPLACE_HCMCSTC Then

                 Begin
                   Select VARVALUE into v_strSysCheckBuySell from sysvar where GRNAME ='SYSTEM' and VARNAME ='TRADEBUYSELL';
                 Exception When OTHERS Then
                   v_strSysCheckBuySell:='N';
                 End;

          If v_strSysCheckBuySell ='N' Then
                 -- PHAI CHECK DAT LENH DOI UNG MUA BAN TRONG NGAY

                  If v_strORDERTRADEBUYSELL = 'N'  Then
               -- khong duoc phep dat lenh cho ( check tat ca cac loai lenh )
               -- kiem tra tat ca cac loai lenh( LO, ATO , ATC ) neu co lenh nguoc chieu chua khop thi khong cho dat lenh

                If v_strEXECTYPE = 'NB' Or v_strEXECTYPE = 'BC' Then
                    SELECT COUNT(*)  into l_count FROM ODMAST WHERE CODEID= v_strCODEID  AND AFACCTNO IN (SELECT ACCTNO FROM AFMAST WHERE CUSTID=(SELECT CUSTID FROM AFMAST WHERE ACCTNO= v_strAFACCTNO ))
                    AND (EXECTYPE='NS' OR EXECTYPE='SS' OR EXECTYPE='MS') AND DELTD = 'N' AND EXPDATE >= TO_DATE(v_txdate, systemnums.C_DATE_FORMAT) AND REMAINQTTY >0;
                Else
                    SELECT COUNT(*) into l_count FROM ODMAST WHERE CODEID= v_strCODEID  AND AFACCTNO IN (SELECT ACCTNO FROM AFMAST WHERE CUSTID=(SELECT CUSTID FROM AFMAST WHERE ACCTNO= v_strAFACCTNO ))
                    AND (EXECTYPE='NB' OR EXECTYPE='BC') AND DELTD = 'N' AND EXPDATE >= TO_DATE(v_txdate, systemnums.C_DATE_FORMAT)  AND REMAINQTTY >0;
                End If;

                If l_count > 0 Then
                   -- Khong cho phep dat lenh cho khi dang co lenh doi ung chua khop
                    v_Return := false;
                    Return v_Return;
                else
                    -- Lenh qua
                    v_Return := true;
                    Return v_Return;
                End If;

                ELSE
               -- Duoc phep dat lenh cho, nhuwng check theo loai lenh va , theo phien

                                     --Lay thong tin phien
                                      Select sysvalue into l_strControlCode  from ordersys where sysname ='CONTROLCODE';
                                      --Neu dat LO thi check d?? ATC doi ung o phien 2 va LO, ATC doi ung o phien 3.
                                      --Neu dat ATO thi check LO, ATO d?i ?ng.
                                      --?t ATC th?heck ch?n ATC, LO d?i ?ng

                                      If v_strPRICETYPE IN ('LO') And v_strMATCHTYPE <> 'P'   Then
                                            If l_strControlCode ='O' Then
                                                v_strTemp:='ATC';
                                            Elsif l_strControlCode ='A' Then
                                                v_strTemp:='LO,ATC';
                                            End if;
                                      ELSIF v_strPRICETYPE IN ('LO') And v_strMATCHTYPE = 'P'   Then
                                            --Lenh thoa thuan thi chan tat ca lenh doi ung.
                                            v_strTemp:='LO,ATO,ATC';
                                      Elsif v_strPRICETYPE IN ('ATO') Then
                                            v_strTemp:='LO,ATO';
                                      Elsif v_strPRICETYPE IN ('ATC') Then
                                            v_strTemp:='LO,ATC';
                                      End if;


                                    If v_strEXECTYPE = 'NB' Or v_strEXECTYPE = 'BC' Then
                                         SELECT COUNT(*)  into l_count FROM ODMAST WHERE CODEID= v_strCODEID
                                         AND AFACCTNO IN (SELECT ACCTNO FROM AFMAST WHERE CUSTID=(SELECT CUSTID FROM AFMAST WHERE ACCTNO= v_strAFACCTNO ))
                                         AND INSTR(v_strTemp,PRICETYPE)>0
                                         AND (EXECTYPE='NS' OR EXECTYPE='SS' OR EXECTYPE='MS') AND DELTD = 'N'
                                         AND EXPDATE >= TO_DATE(v_txdate, systemnums.C_DATE_FORMAT) AND REMAINQTTY>0;
                                     Else
                                         SELECT COUNT(*) into l_count FROM ODMAST WHERE CODEID= v_strCODEID
                                         AND AFACCTNO IN (SELECT ACCTNO FROM AFMAST WHERE CUSTID=(SELECT CUSTID FROM AFMAST WHERE ACCTNO= v_strAFACCTNO ))
                                         AND INSTR(v_strTemp,PRICETYPE)>0
                                         AND (EXECTYPE='NB' OR EXECTYPE='BC') AND DELTD = 'N'
                                         AND EXPDATE >= TO_DATE(v_txdate, systemnums.C_DATE_FORMAT)  AND REMAINQTTY >0;
                                     End If;


                                     If l_count > 0 Then
                                      -- Neu lenh doi ung con chua khop thi ko dat duoc
                                        v_Return :=FALSE;
                                        Return v_Return;
                                        else
                                      -- Neu da khop thi cho qua lenh
                                        v_Return :=true;
                                        Return v_Return;
                                     End If;


                   End if ;



            End if; --Sysbuysell

        Elsif l_strTRADEBUYSELL = 'Y' And v_strTRADEPLACE = errnums.gc_TRADEPLACE_HNCSTC Then
        --Neu san HNX thi chi check thoan thuan
          Begin
             Select VARVALUE into v_strSysCheckBuySell from sysvar where GRNAME ='SYSTEM' and VARNAME ='TRADEBUYSELL';
           Exception When OTHERS Then
             v_strSysCheckBuySell:='N';
           End;




                  If v_strORDERTRADEBUYSELL = 'N'  Then
               -- khong duoc phep dat lenh cho ( check tat ca cac loai lenh )
               -- kiem tra tat ca cac loai lenh( LO, ATO , ATC ) neu co lenh nguoc chieu chua khop thi khong cho dat lenh

                If v_strEXECTYPE = 'NB' Or v_strEXECTYPE = 'BC' Then
                    SELECT COUNT(*)  into l_count FROM ODMAST WHERE CODEID= v_strCODEID  AND AFACCTNO IN (SELECT ACCTNO FROM AFMAST WHERE CUSTID=(SELECT CUSTID FROM AFMAST WHERE ACCTNO= v_strAFACCTNO ))
                    AND (EXECTYPE='NS' OR EXECTYPE='SS' OR EXECTYPE='MS') AND DELTD = 'N' AND EXPDATE >= TO_DATE(v_txdate, systemnums.C_DATE_FORMAT) AND REMAINQTTY >0;
                Else
                    SELECT COUNT(*) into l_count FROM ODMAST WHERE CODEID= v_strCODEID  AND AFACCTNO IN (SELECT ACCTNO FROM AFMAST WHERE CUSTID=(SELECT CUSTID FROM AFMAST WHERE ACCTNO= v_strAFACCTNO ))
                    AND (EXECTYPE='NB' OR EXECTYPE='BC') AND DELTD = 'N' AND EXPDATE >= TO_DATE(v_txdate, systemnums.C_DATE_FORMAT)  AND REMAINQTTY >0;
                End If;

                If l_count > 0 Then
                   -- Khong cho phep dat lenh cho khi dang co lenh doi ung chua khop
                    v_Return := false;
                    Return v_Return;
                else
                    -- Lenh qua
                    v_Return := true;
                    Return v_Return;
                End If;

                ELSE
                -- Cho phep dat lenh cho
                   If v_strSysCheckBuySell ='N' And v_strMATCHTYPE = 'P'   Then
                   v_strTemp:='LO,ATO,ATC';
                   End if;

                     If v_strEXECTYPE = 'NB' Or v_strEXECTYPE = 'BC' Then

                 SELECT COUNT(*)  into l_count FROM ODMAST WHERE CODEID= v_strCODEID
                     AND AFACCTNO IN (SELECT ACCTNO FROM AFMAST WHERE CUSTID=(SELECT CUSTID FROM AFMAST WHERE ACCTNO= v_strAFACCTNO ))
                     AND INSTR(v_strTemp,PRICETYPE)>0
                     AND (EXECTYPE='NS' OR EXECTYPE='SS' OR EXECTYPE='MS') AND DELTD = 'N'
                     AND EXPDATE >= TO_DATE(v_txdate, systemnums.C_DATE_FORMAT) AND REMAINQTTY>0;
                 Else
                     SELECT COUNT(*) into l_count FROM ODMAST WHERE CODEID= v_strCODEID
                     AND AFACCTNO IN (SELECT ACCTNO FROM AFMAST WHERE CUSTID=(SELECT CUSTID FROM AFMAST WHERE ACCTNO= v_strAFACCTNO ))
                     AND INSTR(v_strTemp,PRICETYPE)>0
                     AND (EXECTYPE='NB' OR EXECTYPE='BC') AND DELTD = 'N'
                     AND EXPDATE >= TO_DATE(v_txdate, systemnums.C_DATE_FORMAT)  AND REMAINQTTY >0;
                 End If;

                 If l_count > 0 Then
                    v_Return:=false;
                    Return v_Return;
                     else
                      v_Return:=true;
                      Return v_Return;
                 End If;


                end if ;




  End if;


 Return v_Return;
END;
 
 
 
 
 
 
 
 
 
 
 
 
 
/
