delimiter ;
drop procedure if exists MIGRACIONPRO;

delimiter $$
CREATE  PROCEDURE `MIGRACIONPRO`()

TerminaStore: BEGIN


DECLARE Cadena_Vacia	varchar(50);
DECLARE Var_CreditoID       int;
DECLARE Var_AmortizacionID  int;
DECLARE Var_FechaInicio     date;
DECLARE Var_FechaVencim     date;
DECLARE Var_Consecutivo     int;

DECLARE CURSOSCREDITOS CURSOR FOR
    select max(CreditoID), min(Consecutivo), min(date(FechaVencim))FechaInicio  
    from TMPAMORTICREDITOS where  Capital=0 and Interes=0 
    group by CreditoID;



SET Cadena_Vacia    := '';              


        OPEN CURSOSCREDITOS;
					BEGIN
						DECLARE EXIT HANDLER FOR SQLSTATE '02000' BEGIN END;
						CICLOCRE:LOOP

						FETCH CURSOSCREDITOS INTO
                        Var_CreditoID,  Var_Consecutivo,     Var_FechaInicio;

                            set @ID:=-1;
                            set @ID2:=0;

                            drop table if exists tmpFechas;
                            drop table if exists tmpFechas2;

                            CREATE TEMPORARY TABLE tmpFechas
                            SELECT
                                CreditoID, Consecutivo, (@ID:= @ID + 1)AS AmortizacionID, (@ID2:= @ID2 + 1) AS AmortizacionAntID,'1900-01-01' AS FechaInicio,date(FechaVencim)FechaVencim
                            FROM
                                TMPAMORTICREDITOS WHERE CreditoID=Var_CreditoID;

                            -- Sacamos una copia de la tabla temporal
                            CREATE TEMPORARY TABLE tmpFechas2
                                SELECT * FROM tmpFechas;

                            -- Actualizamos las Fechas de Inicio en tabla temporal
                            UPDATE
                                tmpFechas, tmpFechas2
                            SET
                                tmpFechas.FechaInicio = date(tmpFechas2.FechaVencim)
                            WHERE
                                tmpFechas.AmortizacionID = tmpFechas2.AmortizacionAntID;
                                
                            -- Actualizamos  tabla principal


                            UPDATE TMPAMORTICREDITOS amo, tmpFechas fec
                            SET     amo.AmortizacionID=fec.AmortizacionID,
                                    amo.FechaInicio=fec.FechaInicio,
                                    amo.FechaVencim=fec.FechaVencim
                            WHERE 
                            amo.CreditoID=fec.CreditoID
                            and amo.Consecutivo=fec.Consecutivo;
                            

                        END LOOP CICLOCRE;
					END;
		CLOSE CURSOSCREDITOS;

        delete from TMPAMORTICREDITOS where AmortizacionID=0;
        
        create temporary table tmpPagos
        select CreditoID, count(*)NumAmo, sum(case when Estatus="P" then 1 else 0 end)Pagados 
        from TMPAMORTICREDITOS  group by CreditoID;

        update TMPCREDITOS cre ,  tmpPagos tmp
        set Estatus='P' 
        where cre.CreditoID=tmp.CreditoID
        and tmp.NumAmo=tmp.Pagados;

        update TMPCREDITOS cre ,  tmpPagos tmp
        set NumAmortizacion=NumAmo 
        where cre.CreditoID=tmp.CreditoID;


END TerminaStore$$

 create index idxCreditoID on  TMPAMORTICREDITOS(CreditoID);

call `MIGRACIONPRO`();

select * from TMPAMORTICREDITOS

delete from TMPAMORTICREDITOS where AmortizacionID=0;

insert into TMPCREDITOSMOVS
select amo.CreditoID, AmortizacionID,1 , date(FechaIni),date(FechaIni),1,'C',1,Capital,"CAPITAL VIGENTE", concat("Cre.-" ,cre.CreditoID),0,1,1,now(),'127.0.0.1',"Migracion",1,1
from TMPAMORTICREDITOS amo, TMPCREDITOS cre  where amo.CreditoID=cre.CreditoID 