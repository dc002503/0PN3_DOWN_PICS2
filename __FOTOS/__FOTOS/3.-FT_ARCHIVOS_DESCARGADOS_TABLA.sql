CREATE TABLE OPEN.YZ_ARCHIVOS_DESCARGAD 
(
 ID_UNK NUMBER NOT NULL PRIMARY KEY
, ID_CCFILE NUMBER 
, NOMBRE_FILE VARCHAR2(4000 BYTE) 
, DIRECCION VARCHAR2(4000 BYTE) 
)
;


SELECT  *
  FROM  YZ_ARCHIVOS_DESCARGAD
  ;

SELECT  *
  FROM  LQ_PROCESS_LOG 
 WHERE  PROCESS_DATE    >   '19/05/2020'
 ORDER  BY PROCESS_DATE DESC
