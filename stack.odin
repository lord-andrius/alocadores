package main

import "core:fmt"
import "core:mem"

Pequena_Pilha :: struct {
	memoria: []u8,
	ponto_da_memoria: uintptr
}

Cabecalho_Pequena_Pilha :: struct {
	//O preenchimento guarda quantos bytes eu devo por ante do procimo cabeçalho para alinhar a proxima alocação de memória
	preenchimento: u8
}

criar_pequena_pilha :: proc(memoria: []u8) -> Pequena_Pilha {
	return Pequena_Pilha{
		memoria = memoria,
		ponto_da_memoria = 0,
	}
	
}

e_potencia_de_dois :: proc(x: uintptr) -> bool {
	return (x & (x - 1)) == 0
}




main :: proc() {
	fmt.println("Olá, mundo!")
	
}
