SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW CF_INFO_VIEW
(PHONE1, PHONE2, CUSTID, ACCTNO, NAME, 
 PIN, CLASS, TEXT)
BEQUEATH DEFINER
AS 
(
select cf.mobilesms phone1
       , cf.mobile phone2
       , af.custid Custid
       , af.acctno
       ,cf.fullname name
       ,cf.pin pin
       , a.cdcontent class
       ,cf.fullname    ||' : '|| af.acctno text
From cfmast cf, afmast af,allcode a
where cf.custid=af.custid
and a.cdtype='CF'
and a.cdname='CLASS'
and a.cdval=cf.class
)
/
