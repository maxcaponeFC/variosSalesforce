Presupuesto_temp = obtenerPresupuesto(recordId);
fechamaxdesistir = Now();
contador_bucle = 1;
Viene_de_anular = false;
If(Presupuesto_temp.Fecha_max_desistir_ppto__c ==null || Presupuesto_temp.Fecha_max_desistir_ppto__c >= fechamaxdesistir){
	pantallaNoSePuedeDesistir();
	return;
}
if(Presupuesto_temp.Formas_de_pago__c==null){
	pantallaErrorFormaDePago();
	return;
}
Obtener_record_type_sin_botones_opp = getTipoRegistro(Opp_sin_Ppto_total_y_parcial);
oportunidad_temp = getOportunidad(Presupuesto_temp.OpportunityId);
Partidas_ppto_all = getPartida(recordId);
All_OLI_s = getProductoOportunidad(Presupuesto_temp.OpportunityId);

for(Partidas_ppto_bucle:Partidas_ppto_all){
	Partidas_ppto_bucle.Cantidad_reservada__c = 0;
	Partidas_ppto_bucle.CheckEditarPartPresu__c = true;
	for(OLI_s_bucle:All_OLI_s){
		if(Partidas_ppto_bucle.Product2Id == OLI_s_bucle.Product2Id){ //mismo producto
			OLI_s_bucle.Cantidad_presupuestada__c -= Partidas_ppto_bucle.Quantity;
			OLI_s_actualizadas.add(OLI_s_bucle);
		}
		QLI_s_actualizadas.add(Partidas_ppto_bucle);
	}
}
oportunidad_temp.Importe_Presupuestado__c = Presupuesto_temp.Subtotal;
update QLI_s_actualizadas;
for(Recorro_partidas:Partidas_ppto_all){
	Recorro_partidas.CheckEditarPartPresu__c = false;
	Conj_QLIs_a_actualizar.add(Recorro_partidas);
}
update Conj_QLIs_a_actualizar;
update OLI_s_actualizadas;
if(Presupuesto_temp.Centro__c == null){
	pantallaInfor();
	return;
}
Presupuestos_restantes_en_opp = getPresupuesto(recordId, oportunidad_temp.Id, Caducado, Anulado, Rechazado cliente, Desistido);
for( loopRestoPptos:Presupuestos_restantes_en_opp){
	if(loopRestoPptos.Status IN (Aceptado cliente,Facturado parcial,Pagado parcial,Anticipo pendiente de conciliar,Facturado total,Pagado total,Impagado parcial,Impagado total)){
		countAceptados++;
	}
}
numero_de_pptos_restantes = Presupuestos_restantes_en_opp.size();
if(Presupuesto_temp.Status IN (Borrador,Pendiente Validar,Validado,Enviado)){ //no tiene pedidos
	Cuenta_temp = getCuenta(Presupuesto_temp.AccountId);
	Inscripciones_all = getReservaInscripcion(Presupuesto_temp.Id); //Presupuesto_I__c
	Reservas_all = getReservaInscripcion(Presupuesto_temp.Id); //Presupuesto__c
	
	for(Inscripciones_bucle:Inscripciones_all){
		Numero_inscripciones++;
		Inscripciones_bucle.Estado__c = Cancelado;
		Nuevo_estado_reservas_all.add(Inscripciones_bucle);
	}
	for(Inscripciones_bucle:Reservas_all){
		Numero_inscripciones++;
		Inscripciones_bucle.Estado__c = Cancelado;
		Nuevo_estado_reservas_all.add(Inscripciones_bucle);
	}
	if(numero_de_pptos_restantes != 0){ //hay pptos restantes
		if(countAceptados > 0){ //presupuestos aceptados
			if(oportunidad_temp.StageName == Parcialmente ganada){
				mostrarPantallaDevolucion();
				
				
			}else{ //otro	
				oportunidad_temp.StageName = Parcialmente ganada;
				oportunidad_temp.Desde_codigo__c = true;
				mostrarPantallaDevolucion();
			}
		}else{ //no
			if(oportunidad_temp.StageName ==  Negociacion){
				mostrarPantallaDevolucion();
			}else{ //otro
				oportunidad_temp.StageName = Negociacion;
				oportunidad_temp.Desde_codigo__c = true;
				mostrarPantallaDevolucion();
			}
		}
		if(Por_el_cliente_Motivo_Lista IN (motivosCliente)){ //motivo desistimento
				updatePresupuesto(recordId, Desde_codigo__c=false, Motivo_de_rechazo__c=motivoCliente);
				
			}else{ //por la fundacion
				updatePresupuesto(recordId, Desde_codigo__c=false, Motivo_de_rechazo__c=motivoFundacion);
		
			}
	}else{ //no hay ppts restantes
		mostrarPantallaDevolucion();
		oportunidad_temp.StageName = Perdida;
		oportunidad_temp.Desde_codigo__c = true;
		oportunidad_temp.RecordTypeId = Obtener_record_type_sin_botones_opp.Id;
	
		if(Por_el_cliente_Motivo_Lista IN (motivosCliente)){
			updatePresupuesto(recordId, Desde_codigo__c=false, Motivo_de_rechazo__c=motivoCliente);
			
		}else{ //por la fundacion
			updatePresupuesto(recordId, Desde_codigo__c=false, Motivo_de_rechazo__c=motivoFundacion);
	
		}
	}
	updateOpp(oportunidad_temp);
	Numero_de_bucles = Numero_inscripciones/12 +1;
	if(Numero_de_bucles < contador_bucle){
		RT_antiguo_temp = getTipoRegistro(Presupuesto_anulado);
		if(Viene_de_anular){
			updateQuote(Desde_codigo__c=true, recordTypeId=RT_antiguo_temp.Id, Status=Desistido);
			updateQuote(Desde_codigo__c=false);
			updateOpp(Desde_codigo__c=false);
			mostrarPantallaExito();
		}else{
			updateQuote(Desde_codigo__c=true, recordTypeId=RT_antiguo_temp.Id, Status=Anulado);
			updateQuote(Desde_codigo__c=false);
			updateOpp(Desde_codigo__c=false);
			mostrarPantallaExito();
			
		}
	}else{ //no
		for(Inscripciones_bucle:Nuevo_estado_reservas_all){
			contador_dentro_del_bucle++;
			if(contador_dentro_del_bucle>13){
			
			}else if(contador_dentro_del_bucle<13){
				grupo_12_inscripciones.add(Inscripciones_bucle);
			}else{
				Nuevo_estado_reservas_all.remove(Inscripciones_bucle);
				contador_dentro_del_bucle++;
			}
		}
		update(grupo_12_inscripciones);
		contador_bucle = 1;
		contador_dentro_del_bucle = 0;
		grupo_12_inscripciones = null;
	}
}else{ //si tiene pedidos
	Cuenta_temp = getCuenta(Presupuesto_temp.AccountId);
	Inscripciones_all = getReservaInscripcion(Presupuesto_temp.Id); //Presupuesto_I__c
	Reservas_all = getReservaInscripcion(Presupuesto_temp.Id); //Presupuesto__c
	
	for(Inscripciones_bucle:Inscripciones_all){
		Numero_inscripciones++;
		Inscripciones_bucle.Estado__c = Cancelado;
		Nuevo_estado_reservas_all.add(Inscripciones_bucle);
	}
	for(Inscripciones_bucle:Reservas_all){
		Numero_inscripciones++;
		Inscripciones_bucle.Estado__c = Cancelado;
		Nuevo_estado_reservas_all.add(Inscripciones_bucle);
	}
	if(numero_de_pptos_restantes != 0){ //si hay
		mostrarPantallaDevolucion();
		if(countAceptados > 0){ //presupuestos aceptados
			if(oportunidad_temp.StageName == Parcialmente ganada){
			
			}else{ //otro
				oportunidad_temp.StageName = Parcialmente ganada;
				oportunidad_temp.Desde_codigo__c = true;
			}
			
		}else{ //no
			if(oportunidad_temp.StageName == Negociacion){
			
			}else{ //otro
				oportunidad_temp.StageName = Negociacion;
				oportunidad_temp.Desde_codigo__c = true;
			}
		}
		if(Por_el_cliente_Motivo_Lista IN (motivosCliente)){ //motivo desistimento
			udpateQuote(recordId,Cuenta_bancaria__cm=Cuenta_bancaria_0,Desde_codigo__c=false,Motivo_de_rechazo__c=Por_el_cliente_Motivo_Lista_0_0_0);
		}else{ //por la fundacion
			udpateQuote(recordId,Cuenta_bancaria__cm=Cuenta_bancaria_0,Desde_codigo__c=false,Motivo_de_rechazo__c=Por_la_Fundacion_Motivo_Lista_0_0_0);
			
		}
	}else{ //no hay mas pptos
		mostrarPantallaDevolucion();
		oportunidad_temp.StageName = Perdida;
		oportunidad_temp.Desde_codigo__c = true;
		oportunidad_temp.RecordTypeId = Obtener_record_type_sin_botones_opp.Id;
		if(Por_el_cliente_Motivo_Lista IN (motivosCliente)){ //motivo desistimento
			udpateQuote(recordId,Cuenta_bancaria__cm=Cuenta_bancaria_0,Desde_codigo__c=false,Motivo_de_rechazo__c=Por_el_cliente_Motivo_Lista_0_0);
		}else{ //por la fundacion
			udpateQuote(recordId,Cuenta_bancaria__cm=Cuenta_bancaria_0,Desde_codigo__c=false,Motivo_de_rechazo__c=Por_la_Fundacion_Motivo_Lista_0_0);
			
		}
	}
	updateOpp(oportunidad_temp);
	Obtener_pedidos_positivos = getCartaDePago();
	for(Recorrer_pedidos_positivos:Obtener_pedidos_positivos){
		If(Recorrer_pedidos_positivos.Type == NOR){ //normal
			Recorrer_pedidos_positivos.CC_Crear_pedido_negativo__c = true;
		}else{ //normal cambio convocatoria
			Recorrer_pedidos_positivos.CC_Crear_pedido_negativo__c = true;
			Obtener_pedido_del_id_pedido_ref = getCartaDePago(OrderNumber=Recorrer_pedidos_positivos.id_pedido_ref__c);
			Obtener_pedido_del_id_pedido_ref.CC_Crear_pedido_negativo__c = false;
			Pedidos_a_actualizar.add(Obtener_pedido_del_id_pedido_ref);
		}
		Pedidos_a_actualizar.add(Recorrer_pedidos_positivos);
		updatePedidos(Pedidos_a_actualizar);
		Pedidos_a_actualizar = null;
	}
	Obtener_pedidos_con_check=getCartaDePago(CC_Crear_pedido_negativo__c=true,QuoteId=recordId);
	for(Recorro_pedidos_con_check:Obtener_pedidos_con_check){
		Obtener_prod_pedido = getOrderProduct(OrderId=Recorro_pedidos_con_check.Id);
		orderIdCreado = creoPedido(Recorro_pedidos_con_check);
		Esqueleto_prod_pedido.OrderId = orderIdCreado;
		new_prod_pedido_all.add(Esqueleto_prod_pedido);
	}
	create new_prod_pedido_all;
	update cartaDePago;
	if(Numero_de_bucles < contador_bucle){
		RT_antiguo_temp = getTipoRegistro(Presupuesto_anulado);
		if(Viene_de_anular){
			updateQuote(Desde_codigo__c=true, recordTypeId=RT_antiguo_temp.Id, Status=Desistido);
			updateQuote(Desde_codigo__c=false);
			updateOpp(Desde_codigo__c=false);
			mostrarPantallaExito();
		}else{
			updateQuote(Desde_codigo__c=true, recordTypeId=RT_antiguo_temp.Id, Status=Anulado);
			updateQuote(Desde_codigo__c=false);
			updateOpp(Desde_codigo__c=false);
			mostrarPantallaExito();
			
		}
	}else{ //no
		for(Inscripciones_bucle:Nuevo_estado_reservas_all){
			contador_dentro_del_bucle++;
			if(contador_dentro_del_bucle>13){
			
			}else if(contador_dentro_del_bucle<13){
				grupo_12_inscripciones.add(Inscripciones_bucle);
			}else{
				Nuevo_estado_reservas_all.remove(Inscripciones_bucle);
				contador_dentro_del_bucle++;
			}
		}
		update grupo_12_inscripciones; //cancelo reservas
		contador_bucle++;
		contador_dentro_del_bucle = 0;
		grupo_12_inscripciones = null;
	}
}
