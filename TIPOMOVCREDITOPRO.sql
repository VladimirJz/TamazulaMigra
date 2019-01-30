delimiter ;
drop procedure if exists TIPOMOVCREDITOPRO;

delimiter $$
CREATE  PROCEDURE `TIPOMOVCREDITOPRO`()

TerminaStore: BEGIN


DECLARE Cadena_Vacia	varchar(50);
DECLARE Var_CreditoID       int;
DECLARE Var_PolizaID        int;
DECLARE Var_CuentaContable  Varchar(50);

DECLARE CURSOSCREDITOS CURSOR FOR
    select max(creditoid)creditoid,max(Polizaid)polizaid from movimientos_cuenta
    where creditoid>0 /* and polizaid=342444 */
    group by creditoid,polizaid
    order by creditoid;


DECLARE CURSORDETALLE CURSOR FOR
    select cuentaid from polizacuenta where polizaid=Var_PolizaID;



SET Cadena_Vacia    := '';              


        OPEN CURSOSCREDITOS;
					BEGIN
						DECLARE EXIT HANDLER FOR SQLSTATE '02000' BEGIN END;
						CICLOCRE:LOOP

						FETCH CURSOSCREDITOS INTO
                        Var_CreditoID,  Var_PolizaID  ;


                                OPEN CURSORDETALLE;
                                            BEGIN
                                                DECLARE EXIT HANDLER FOR SQLSTATE '02000' BEGIN END;
                                                CICLODET:LOOP

                                                FETCH CURSORDETALLE INTO
                                                    Var_CuentaContable  ;
                                                    
                                                call TIPOMOVCREDITOALT(Var_CuentaContable);                   
                                                END LOOP CICLODET;
                                            END;
                                CLOSE CURSORDETALLE;
                    
                            

                        END LOOP CICLOCRE;
					END;
		CLOSE CURSOSCREDITOS;
END TerminaStore$$

-- 38,287
truncate TIPOSMOVS;