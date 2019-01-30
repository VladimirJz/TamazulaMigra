delimiter ;
drop procedure if exists TIPOMOVCREDITOALT;

delimiter $$

CREATE  PROCEDURE `TIPOMOVCREDITOALT`(

            Par_CuentaID        varchar(50)
)
TerminaStore: BEGIN


DECLARE Cadena_Vacia	varchar(50);
DECLARE Var_CreditoID       int;
DECLARE Var_AmortizacionID  int;
DECLARE Var_FechaInicio     date;
DECLARE Var_FechaVencim     date;
DECLARE Var_Consecutivo     int;
DECLARE Var_CuentaCompleta  varchar(300);
DECLARE Var_Descripcion     varchar(800);
DECLARE Var_CuentaPadre		varchar(400);
DECLARE Var_NombreCuenta	varchar(600);






SET Cadena_Vacia:="";
set Var_CuentaCompleta :=(select CuentaCompleta from TIPOSMOVS where CuentaID=Par_CuentaID);
-- set Var_Descripcion :=(select CuentaCompleta from TIPOSMOVS where CuentaID=Par_CuentaID);
set Var_Descripcion:=Cadena_Vacia;
set Var_CuentaCompleta :=ifnull(Var_CuentaCompleta,Cadena_Vacia);

if(Var_CuentaCompleta=Cadena_Vacia )then
        -- set Var_CuentaPadre:=(select cuentaPadreid from cuenta where cuentaid=Par_CuentaID);
        set Var_NombreCuenta:=(select nombreCuenta from cuenta where cuentaid=Par_CuentaID);
        -- set Var_CuentaCompleta:=Par_CuentaID;
        set Var_CuentaPadre:=Par_CuentaID;
        -- set Var_NombreCuenta:=Var_Descripcion;
        -- select isnull(Var_CuentaPadre);
        BEGIN
            WHILE(isnull(Var_CuentaPadre)=0) DO
                    -- select "entra";
                    set Var_CuentaCompleta:= concat(Var_CuentaPadre,"-",Var_CuentaCompleta);
                    set Var_Descripcion:=concat( ifnull(Var_NombreCuenta,Cadena_Vacia),"-",Var_Descripcion);
                    
                    set Var_CuentaPadre:=(select cuentaPadreid from cuenta where cuentaid=Var_CuentaPadre);
                    set Var_NombreCuenta:=(select ifnull(nombreCuenta,Cadena_Vacia) from cuenta where cuentaid=Var_CuentaPadre);
        
                -- select Var_CuentaPadre;
            -- insert into TIPOSMOVS values (Par_CuentaID,Var_CuentaPadre,Var_NombreCuenta,0);

                
            END WHILE;
            END;

        insert into TIPOSMOVS values (Par_CuentaID,Var_CuentaCompleta,Var_Descripcion,0);
        -- set Par_MovCreditoID:=0;
        -- select Var_Descripcion;
end if;

END TerminaStore$$




