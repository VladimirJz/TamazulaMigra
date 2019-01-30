delimiter ;
drop procedure if exists CREDITOSMOVSPRO;

delimiter $$
CREATE  PROCEDURE `CREDITOSMOVSPRO`()

TerminaStore: BEGIN


DECLARE Cadena_Vacia	varchar(50);
DECLARE Var_CreditoID       int;
DECLARE Var_PolizaID        int;
DECLARE Var_Fecha           varchar(50)
DECLARE Var_CuentaContable  Varchar(50);
DECLARE Var_Monto           decimal(12,2);

DECLARE CURSOSCREDITOS CURSOR FOR
  select max(mov.creditoid)creditoid,max(Polizaid)polizaid, max(mov.Fecha)Fecha 
  from movimientos_cuenta mov , TMPCREDITOS cre
    where  mov.creditoid=cre.CreditoID
    and cre.Estatus <>'P'
    and mov.creditoid>0
    group by mov.creditoid,mov.polizaid
    order by mov.creditoid;
    

DECLARE CURSORDETALLE CURSOR FOR
    select cuentaid, Monto from polizacuenta where polizaid=Var_PolizaID;



SET Cadena_Vacia    := '';              


        OPEN CURSOSCREDITOS;
					BEGIN
						DECLARE EXIT HANDLER FOR SQLSTATE '02000' BEGIN END;
						CICLOCRE:LOOP

						FETCH CURSOSCREDITOS INTO
                        Var_CreditoID,  Var_PolizaID, Var_Fecha  ;


                                OPEN CURSORDETALLE;
                                            BEGIN
                                                DECLARE EXIT HANDLER FOR SQLSTATE '02000' BEGIN END;
                                                CICLODET:LOOP

                                                FETCH CURSORDETALLE INTO
                                                    Var_CuentaContable, Var_Monto  ;
                                                    call MOVCREDITOALT(Var_CreditoID,Var_CuentaContable,Var_Fecha,Var_Monto);                   
                                                END LOOP CICLODET;
                                            END;
                                CLOSE CURSORDETALLE;
                    
                            

                        END LOOP CICLOCRE;
					END;
		CLOSE CURSOSCREDITOS;
END TerminaStore$$

