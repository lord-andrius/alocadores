package main

import "core:fmt"
import "core:mem"

Pequena_Pilha :: struct {
	memoria: []u8,
	ponto_da_memoria: uintptr
}

Cabecalho_Pequena_Pilha :: struct {
	//O preenchimento guarda quantos bytes eu devo por ante do procimo cabeçalho para alinhar a proxima alocação de mememória
	preenchimento: u8
}

criar_pequena_pilha :: proc(memoria: []u8) -> Pequena_Pilha {
	return Pequena_Pilha{
		memoria = memoria,
	}	
}

e_potencia_de_dois :: proc(x: uintptr) -> bool {
	return (x & (x - 1)) == 0
}

calcular_preenchimento_com_cabecalho :: proc(ptr, alinhamento,  tamanho_do_cabecalho: uintptr) -> uintptr {
	assert(e_potencia_de_dois(alinhamento))
	
	modulo := ptr % alinhamento
	
	preenchimento := uintptr(0)
	
	// mesma lógica do alinhar_na_frente
	if modulo != 0 {
		preenchimento = alinhamento - modulo
	}

	espaco_necessario := tamanho_do_cabecalho

	if preenchimento < espaco_necessario {
		espaco_necessario -= preenchimento

		if (espaco_necessario % alinhamento != 0) {
			preenchimento += alinhamento * (1 + (espaco_necessario / alinhamento)) 
		} else {
			preenchimento += alinhamento * (espaco_necessario/alinhamento)
			
		}
		
	}

	return preenchimento
}


alocar_pequena_pilha :: proc(pilha: ^Pequena_Pilha, tamanho: uintptr, alinhamento: uintptr = 8) -> ([]byte, bool) {
	using pilha

	alinhamento := alinhamento

	assert(e_potencia_de_dois(alinhamento))

	// O alinhamento só pode ser de até 128(se o preenchimento do cabeçalho for de 8-bits)
	// NOTA: 128 por conta que a proxima potência de 2 é 256 o que precisa de mais de 8-bits
	if alinhamento > 128 {
		alinhamento = 128
	}

	preenchimento := calcular_preenchimento_com_cabecalho(ponto_da_memoria, alinhamento, size_of(Cabecalho_Pequena_Pilha))
	if ponto_da_memoria + preenchimento + tamanho > uintptr(len(memoria)) {
		return nil, false
		
	}

	preenchimento_e_cabecalho := memoria[ponto_da_memoria: ponto_da_memoria + preenchimento]
	ponto_da_memoria += preenchimento
	cabecalho := transmute(^Cabecalho_Pequena_Pilha)&preenchimento_e_cabecalho[uintptr(len(preenchimento_e_cabecalho)) - size_of(Cabecalho_Pequena_Pilha)]
	cabecalho.preenchimento = cast(type_of(cabecalho.preenchimento))preenchimento
	memoria_alocada := memoria[ponto_da_memoria: ponto_da_memoria + tamanho]
	ponto_da_memoria += tamanho
	mem.zero_slice(memoria_alocada)
	return memoria_alocada, true
	
}


main :: proc() {
	memoria: [16]u8
	pilha := criar_pequena_pilha(memoria[:])

	byte: []u8
	if b, erro := alocar_pequena_pilha(&pilha, 1, 1); !erro {
		fmt.println("Ocorreu um erro na alocação")
		return 
	} else {
		
		byte = b
	}

	byte[0] = 255

	fmt.println(memoria)

	
}
