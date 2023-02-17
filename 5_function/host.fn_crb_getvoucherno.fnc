SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_crb_getvoucherno (v_trfcode in varchar2, v_txdate in DATE, v_version in varchar2) RETURN VARCHAR2 IS
  v_prefixed   VARCHAR2(50);
  v_return   VARCHAR2(50);
BEGIN
--S? ph?i x? l? case cho t?ng tru?ng h?p
IF v_trfcode='TRFSEFEE' THEN
  v_prefixed:='BVSC/SE_TT';  --thu ph?uu k?
ELSIF v_trfcode='SESENDDEPOSIT' THEN
  v_prefixed:='BVSC/SE_LK';     --Luu ky CK
ELSIF v_trfcode='SESENDWITHDRAW' THEN
  v_prefixed:='BVSC/SE_WR';     --Rut LK CK
ELSIF v_trfcode='SEREJECTWITHDRAW' THEN
  v_prefixed:='BVSC/SE_RW';     --Huy rut LK CK
ELSIF v_trfcode='SEREJECTDEPOSIT' THEN
  v_prefixed:='BVSC/SE_RD';     --VSD tu choi tai luu ky
ELSIF v_trfcode='SEODDLOT' THEN
  v_prefixed:='BVSC/SE_LL';     --Bang ke CK lo le
  ELSIF v_trfcode='TRFADVFRBANK' THEN
  v_prefixed:='BVSC/AD_GN';     --Bang ke ung truoc
ELSIF v_trfcode='TRFADV2BANK' THEN
  v_prefixed:='BVSC/AD_TT';     --Bang ke hoan ung
ELSIF v_trfcode='DFDRAWNDOWN' THEN
  v_prefixed:='BVSC/DF_GN';     --Bang ke giai ngan DF
ELSIF v_trfcode='LOANDRAWNDOWN' THEN
  v_prefixed:='BVSC/MR_GN';     --Bang ke giai ngan MR
ELSIF v_trfcode='DFPAYMENT' THEN
  v_prefixed:='BVSC/DF_TT';     --Bang ke tat toan DF
ELSIF v_trfcode='LOANPAYMENT' THEN
  v_prefixed:='BVSC/MR_TT';     --Bang ke tat toan MR
ELSE
  v_prefixed:='BVSC/DEFAULT';
END IF;
SELECT v_prefixed || '/' || TO_CHAR(v_txdate,'ddmmyy') || '/' || lpad(v_version, 3,'0') INTO v_return FROM DUAL;
RETURN v_return;
END;

 
 
 
 
 
 
 
 
 
 
 
 
 
/
