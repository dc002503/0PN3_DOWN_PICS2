---ft
create or replace and compile java source named "ftdir"
as
  import java.io.*;
public class ftdir extends Object {
  public static void Create(String ftdir) {
   File f = new File(ftdir);
   f.mkdir();
  }
}
;

create or replace procedure FT_MKFILE(p in varchar2)
as
language java
name 'ftdir.Create(java.lang.String)';
/
;

--crear una carpeta solo para verficar que se tenga los permisos necesarios
execute FT_MKFILE('/opensmartflex15/imagenes2020');