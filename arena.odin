package main

import "core:fmt"


Arena :: struct {
	memoria: []u8,
	ponto_da_memoria_antigo: uintptr,
	ponto_da_memoria_atual: uintptr,
}

criar_arena :: proc(memoria: []u8) -> Arena {
	return Arena {
		memoria = memoria
	}
}


e_potencia_de_dois :: proc (x: uintptr) -> bool {
	return (x & (x - 1)) == 0;
}

alinhar_na_frente :: proc (ponto_da_memoria: uintptr, alinhamento: uintptr) -> uintptr {
	assert(e_potencia_de_dois(alinhamento))
	
	if ponto_da_memoria % alinhamento == 0 {
		return ponto_da_memoria
	}
	
	novo_ponto_da_memoria := ponto_da_memoria + (alinhamento  -  (ponto_da_memoria % alinhamento))
	return novo_ponto_da_memoria
}

alocar_arena :: proc(arena: ^Arena, tamanho: uintptr, alinhamento: uintptr = 2 * align_of(rawptr)) -> ([]u8, bool) {
	arena.ponto_da_memoria_atual = alinhar_na_frente(arena.ponto_da_memoria_atual, alinhamento);
	if uintptr(len(arena.memoria)) - arena.ponto_da_memoria_atual < tamanho {
		return nil, false
	}
	memoria_alocada :=  arena.memoria[arena.ponto_da_memoria_atual:arena.ponto_da_memoria_atual + tamanho]
	arena.ponto_da_memoria_atual += tamanho
	return memoria_alocada, true
}



main :: proc() {
	memoria: [16]u8
	arena := criar_arena(memoria[:])
	mem, erro := alocar_arena(&arena, size_of(i16), align_of(i16))
	if(!erro) do fmt.println("Ocorreu um erro na alocação")
	num1 := transmute(^i16)&(mem[0])
	num1^ = 259

	fmt.println(arena)

	fmt.println(num1^,memoria)

	
	mem, erro = alocar_arena(&arena, size_of(i32), align_of(i32))
	if(!erro) do fmt.println("Ocorreu um erro na alocação")
	num2 := transmute(^i32)&(mem[0])
	num2^ = 4545
	
	fmt.println(num1^,num2^,memoria)
	
	assert(uintptr(num1) % align_of(i16) == 0)
	assert(uintptr(num2) % align_of(i32) == 0)
	
	fmt.println(arena)
	
	mem, erro = alocar_arena(&arena, size_of(i64), align_of(i64))
	if(!erro) do fmt.println("Ocorreu um erro na alocação")
	
}