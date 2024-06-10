package main

import "core:fmt"
import "core:mem"


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
	arena.ponto_da_memoria_antigo = arena.ponto_da_memoria_atual
	arena.ponto_da_memoria_atual += tamanho
	return memoria_alocada, true
}

redimensionar_memoria_arena :: proc (arena: ^Arena, memoria_antiga: []byte, novo_tamanho: uintptr, alinhamento: uintptr) -> ([]u8, bool) {
	assert(e_potencia_de_dois(alinhamento))


	if memoria_antiga == nil || len(memoria_antiga) == 0  {
		return alocar_arena(arena, novo_tamanho, alinhamento)
	} else if rawptr(&arena.memoria[0]) <= rawptr(&memoria_antiga[0]) && rawptr(&memoria_antiga[0]) < rawptr(uintptr(&arena.memoria[0]) + uintptr(len(arena.memoria))) { // checando se a memoria antiga está no buffer do arena 
		// checando se não há nada na frente da memória antiga
		if &arena.memoria[arena.ponto_da_memoria_antigo] == &memoria_antiga[0] {
			if uintptr(len(arena.memoria)) - arena.ponto_da_memoria_atual < novo_tamanho - uintptr(len(memoria_antiga)) {
				return nil, false
			}
			arena.ponto_da_memoria_atual += novo_tamanho - uintptr(len(memoria_antiga))
			
			nova_memoria := arena.memoria[arena.ponto_da_memoria_antigo:arena.ponto_da_memoria_atual]

			return nova_memoria, true			
	   	} else {
	   		fmt.println("chegou aqui")
			nova_memoria, erro := alocar_arena(arena, novo_tamanho, alinhamento)
			if !erro {
				return nil, false
			}

			mem.copy(rawptr(&nova_memoria[0]), rawptr(&memoria_antiga[0]), len(memoria_antiga))

			return nova_memoria, true
	  }
	} else {
		return nil, false		
	}
	
}

main :: proc() {
	// memoria: [16]u8
	// arena := criar_arena(memoria[:])
	// mem, erro := alocar_arena(&arena, size_of(i16), align_of(i16))
	// if(!erro) do fmt.println("Ocorreu um erro na alocação")
	// num1 := transmute(^i16)&(mem[0])
	// num1^ = 259

	// fmt.println(arena)

	// fmt.println(num1^,memoria)

	
	// mem, erro = alocar_arena(&arena, size_of(i32), align_of(i32))
	// if(!erro) do fmt.println("Ocorreu um erro na alocação")
	// num2 := transmute(^i32)&(mem[0])
	// num2^ = 4545
	
	// fmt.println(num1^,num2^,memoria)
	
	// assert(uintptr(num1) % align_of(i16) == 0)
	// assert(uintptr(num2) % align_of(i32) == 0)
	
	// fmt.println(arena)
	
	// mem, erro = alocar_arena(&arena, size_of(i64), align_of(i64))
	// if(!erro) do fmt.println("Ocorreu um erro na alocação")

	memoria2: [16]u8
	arena2 := criar_arena(memoria2[:])

	mem2, erro := alocar_arena(&arena2, 2, align_of(u8))

	if(!erro) do fmt.println("Ocorreu um erro na alocação")

	mem2[0] = 1
	mem2[1] = 2

	fmt.println(memoria2)
	mem2, erro = redimensionar_memoria_arena(&arena2, mem2, 4, align_of(u8))

	assert(len(mem2) == 4)
	
	if(!erro) do fmt.println("Ocorreu um erro na alocação")

	mem2[2] = 3
	mem2[3] = 4

	fmt.println(memoria2)

	mem3: []u8

	//testando o caso de redimensionar uma área de memória nula
	mem3, erro = redimensionar_memoria_arena(&arena2, mem3, 1, align_of(u8))

	if(!erro) do fmt.println("Ocorreu um erro na alocação")

	mem3[0] = 5

	fmt.println(memoria2)


	mem2, erro = redimensionar_memoria_arena(&arena2, mem2, 5, align_of(u8))

	if(!erro) do fmt.println("Ocorreu um erro na alocação")

	mem2[4] = 6

	fmt.println(mem2)
	fmt.println(memoria2)

}
