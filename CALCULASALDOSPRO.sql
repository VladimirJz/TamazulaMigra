
/*Calcula los saldos de cartera apartir del detalle de movimientos migrado;*/
/* Vladmiir Jz */
delimiter ;
drop procedure if exists CALCULASALDOSPRO;

delimiter $$
CREATE  PROCEDURE `CALCULASALDOSPRO`()

TerminaStore: BEGIN


DECLARE Cadena_Vacia	varchar(50);
DECLARE Var_CreditoID       int;
DECLARE Var_AmortizacionID  int;
DECLARE Var_FechaInicio     date;
DECLARE Var_FechaVencim     date;
DECLARE Var_Consecutivo     int;
DECLARE Var_Cantidad 		decimal(12,2);
DECLARE Var_NatMovimiento   char(1);
DECLARE Var_TIpoMovCredID	int(11);
DECLARE Var_Provision		int(11);
DECLARE Var_AmortiCreID		int(11);
DECLARE Var_MontoMax		decimal(12,2);
DECLARE Var_SaldoActual		decimal(12,2);
DECLARE Entero_Cero			int(11);
DECLARE Var_MontoAplica		decimal(12,2);




DECLARE CURSORMOVS CURSOR FOR
    select CreditoID, AmortiCreID, TipoMovCreID, NatMovimiento, Cantidad
    from  TMPCREDITOSMOVS /*where CreditoID=21*/ order by FechaAplicacion;

-- seteamos todos las amortizaciones como vigentes
update TMPAMORTICREDITOS set Estatus='V' /*where CreditoID=21*/ ;

SET Cadena_Vacia    := '';              
SET Entero_Cero		:=0;


        OPEN CURSORMOVS;
					BEGIN -- 
						DECLARE EXIT HANDLER FOR SQLSTATE '02000' BEGIN END;
						CICLOMOVS:LOOP

						FETCH CURSORMOVS INTO
                        Var_CreditoID,  Var_AmortiCreID, Var_TipoMovCredID,     Var_NatMovimiento,   Var_Cantidad;
						-- Amortización vigente mas vieja.
						set Var_AmortiCreID:=ifnull(Var_AmortiCreID,Entero_Cero);

						-- Movimientos de Capital
						if (Var_TIpoMovCredID between 1 and 4 )then 

								if(Var_AmortiCreID>0) then  --  Desembolso.
									set Var_AmortizacionID:= Var_AmortiCreID;
									if(Var_NatMovimiento="C")then
										select "Cargo:",Var_CreditoID,Var_AmortizacionID, Var_Cantidad,Var_NatMovimiento;
										update TMPSALDOSAMORTICRE set  SaldoCapital=SaldoCapital + Var_Cantidad where CreditoID=Var_CreditoID and AmortizacionID=Var_AmortizacionID;

									else 
										select "Abono:",Var_CreditoID,Var_AmortizacionID, Var_Cantidad,Var_NatMovimiento;
										update TMPSALDOSAMORTICRE set  SaldoCapital=SaldoCapital - Var_Cantidad where CreditoID=Var_CreditoID and AmortizacionID=Var_AmortizacionID;
									end if;


								else 				

									set Var_AmortizacionID:= (select min(AmortizacionID) from TMPSALDOSAMORTICRE where EstatusCap='V' and CreditoID=Var_CreditoID);
									set Var_SaldoActual:=(select SaldoCapital  from TMPSALDOSAMORTICRE where CreditoID=Var_CreditoID and AmortizacionID=Var_AmortizacionID);
									set Var_MontoMax:=(select Capital  from TMPSALDOSAMORTICRE where CreditoID=Var_CreditoID and AmortizacionID=Var_AmortizacionID);
									-- select "Pago x Monto Mayor:",Var_AmortizacionID,Var_SaldoActual,Var_Cantidad,Var_MontoMax;


									if(Var_NatMovimiento="C")then
                                        set Var_AmortizacionID:=Var_AmortiCreID;
									else -- Si es un Abono de Capital 

										if((Var_SaldoActual -  Var_Cantidad )<Entero_Cero)then -- si es mayor al Saldo de la amortización.
											select "Pago x Monto Mayor:",Var_AmortizacionID,Var_SaldoActual,Var_Cantidad;
										-- while 

											Ciclo: BEGIN
												WHILE(isnull(Var_Cantidad)=0) DO
													-- select Var_CreditoID,Var_AmortizacionID,Var_Cantidad,;
													set Var_SaldoActual:=(select SaldoCapital  from TMPSALDOSAMORTICRE where CreditoID=Var_CreditoID and AmortizacionID=Var_AmortizacionID);
													set Var_MontoMax:=(select Capital  from TMPSALDOSAMORTICRE where CreditoID=Var_CreditoID and AmortizacionID=Var_AmortizacionID);
													
													if((Var_SaldoActual - Var_Cantidad )<Entero_Cero)then
														set Var_MontoAplica:=Var_SaldoActual;
														select "Pago x Monto Mayor:",Var_Cantidad,Var_MontoAplica,Var_SaldoActual,Var_MontoMax;
														update TMPSALDOSAMORTICRE set  SaldoCapital=SaldoCapital - Var_MontoAplica ,EstatusCap='P' where CreditoID=Var_CreditoID and AmortizacionID=Var_AmortizacionID;

														
													else 
														set Var_MontoAplica:=Var_Cantidad;
														select "Pago x Monto Menor:",Var_Cantidad,Var_MontoAplica,Var_SaldoActual,Var_MontoMax;
														update TMPSALDOSAMORTICRE set  SaldoCapital=SaldoCapital - Var_MontoAplica   where CreditoID=Var_CreditoID and AmortizacionID=Var_AmortizacionID;

													end if ;												
													
													set Var_Cantidad:=Var_Cantidad - Var_MontoAplica;
													
													set Var_AmortizacionID:=Var_AmortizacionID + 1;
											
														select "-> while",Var_Cantidad,Var_AmortizacionID;
												
														if(Var_Cantidad<=Entero_Cero )then
														   Select "Salta:Ciclo";
															LEAVE Ciclo;
														end if;


												END WHILE ;


											END Ciclo;

										else
											select "Pago x Monto Menor:", Var_Cantidad,Var_MontoAplica,Var_SaldoActual,Var_MontoMax;
											set Var_MontoAplica:=Var_Cantidad;
											update TMPSALDOSAMORTICRE set  SaldoCapital=SaldoCapital - Var_MontoAplica where CreditoID=Var_CreditoID and AmortizacionID=Var_AmortizacionID;
											set Var_Cantidad:=Var_Cantidad - Var_MontoAplica;

										end if;

									end if; -- Si el Monto a aplicar es mayor que el Saldo.
									
								
								end if;  -- Amortizacion 0


	
						end if;

                        -- Movimientos de Interes.
                     
                        
                        END LOOP CICLOMOVS;
					END;
		CLOSE CURSORMOVS;
		
END TerminaStore$$
