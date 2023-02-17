SET DEFINE OFF;
CREATE OR REPLACE PACKAGE pks_covert_flex is

  -- Author  : NAMNT
  -- Created : 09/09/2013
  -- Purpose : convert data
  procedure Truncate_table ;
  procedure InsertConvertLog(p_typecv  varchar2, p_description varchar2   );
  procedure ResetSeq;
  procedure Cleandata;
  procedure Cfmastcv;
  procedure Cfauthcv;
  PROCEDURE ImpTableConvert ;
  procedure Cimastcv;
  procedure Semastcv;
  procedure odmastcv;
  procedure lnmastcv;
  procedure adschdcv;
  procedure cfotheracccv;
  procedure tlprofilescv;
  procedure setupconvert;
  procedure userlogincv;
  procedure endconvert;
    PROCEDURE pr_secinfo_convert ( pv_Symbol  VARCHAR2, pv_ceilingprice  VARCHAR2,pv_floorprice  varchar2 ,pv_basicprice  VARCHAR2, pv_tradeplace  varchar2,pv_haltflag  varchar2,pv_FullName varchar2,pv_sectype varchar2, p_err_code in out varchar2);
end pks_covert_flex;
 
 
 
 
/
