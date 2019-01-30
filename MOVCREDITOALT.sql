delimiter ;
drop procedure if exists MOVCREDITOALT;

delimiter $$

CREATE  PROCEDURE `MOVCREDITOALT`(

            Par_CuentaID        varchar(50),
            Par_CreditoID       int(50),
            Par_Fecha           varchar(50),
            Par_Monto           decimal(12,2)

)
TerminaStore: BEGIN


DECLARE Cadena_Vacia	varchar(50);
DECLARE Var_CreditoID       int;
DECLARE Var_AmortizacionID  int;
DECLARE Var_FechaOperacion     date;
DECLARE Var_FechaAplicacion     date;
DECLARE Entero_Cero             int(9);

DECLARE Var_Consecutivo     int;
DECLARE Var_CuentaCompleta  varchar(300);
DECLARE Var_Descripcion     varchar(1200);
DECLARE Var_CuentaPadre		varchar(400);
DECLARE Var_NombreCuenta	varchar(600);
DECLARE Var_Moneda	        int(11);
DECLARE Var_Referencia	        varchar(50);
DECLARE Var_PolizaID	        int(11);
DECLARE Var_Poliza	        int(11);
DECLARE Var_TipoMovCreID	int(11);
DECLARE Var_NumTransaccion	        int(11);
DECLARE Aud_EmpresaID	        int(11);
DECLARE UsuarioID	        int(11);
DECLARE SucursalID	        int(11);


SET Cadena_Vacia:="";
SET Var_Moneda:=1;


SET Var_FechaAplicacion:=date(Par_Fecha);
SET Var_FechaOperacion:=date(Par_Fecha);
set Var_TipoMovCreID:=(select TipoMovCreID from TIPOSMOVS where CuentaID= Par_CuentaID);
set Var_TipoMovCreID:=ifnull(Var_TipoMovCreID,Entero_Cero);
set Var_NumTransaccion:=1;
set Var_Descripcion:=(select NombreCuenta from TIPOSMOVS where CuentaID= Par_CuentaID);
set Var_Referencia:= concat("Cre.-",Var_CreditoID);
set Var_PolizaID:=0;
set Aud_EmpresaID:=1;
set UsuarioID:=1;
set SucursalID:=1;


insert into TMPCREDITOSMOVS values(
    Par_CreditoID,      Var_AmortizacionID,    Var_NumTransaccion,     Var_FechaOperacion,    Var_FechaAplicacion,
    Var_TipoMovCreID,(Case When Par_Monto>0 then "A" else "C" end),   Var_Moneda,         abs(Par_Monto),           Var_Descripcion,        Var_Referencia,
    Var_PolizaID,       Aud_EmpresaID,      UsuarioID,              now(),                  '127.0.0.1',
    "Migracion",        SucursalID,          Var_NumTransaccion 
);






END TerminaStore$$





