%% @author Ricardo A. Harari - ricardo.harari@gmail.com
%% @doc print/1 - spell out a given number (ptBR monetary format - integer or float).
%% @doc ex: extenso:print(15718.42) -> quinze mil e setecentos e dezoito Reais e quarenta e dois centavos

-module(extenso).

%% ====================================================================
%% API functions
%% ====================================================================
-export([print/1]).

print(N) when is_number(N) ->
	P1 = trunc(N),
	P2 = round((N-P1) * 100),
	L1 = normalizeList(integer_to_list(P1)),
	S1 = length(L1) div 3,
	numero(L1, S1, 0) ++ moeda(P1) ++ centavos(P1, P2);
print(N) -> 
	error(io:format("O argumento '~w' nao e valido", [N])).

%% ====================================================================
%% Internal functions
%% ====================================================================

normalizeList(L) ->
	N = length(L),
	if (N / 3 == trunc(N/3)) -> L;
	   true -> normalizeList("0" ++ L)
	end.

centavos(_,0) -> [];
centavos(0,1) -> "um centavo";
centavos(0,V) -> printNum(V, 0, "") ++ "centavos";
centavos(_,1) -> " e um centavo";
centavos(_,V) -> " e " ++ printNum(V, 0, "") ++ "centavos".


moeda(0) -> "";
moeda(V) when V < 2 -> "Real";
moeda(_) when true -> "Reais".

numero(L, P, Count) when P > 0 ->
	{L1, L2} = lists:split(3, L),
	{V, _} = string:to_integer(L1),
	{V2, _} = string:to_integer(L2),
	if 
		(Count =:= 0) -> E = "";
		(P =:= 1 andalso V<1000) -> E = " e ";
		(V2 =:= 0) -> E = " e ";
        true -> E = ", "
	end,
	printNum(V, P, E) ++ printGroup(P, V, V2) ++ numero(L2, P-1, Count+1);
numero(L,_,_) when L=:=0  -> "zero ";
numero(_,_,_) when true -> [].


printNum(N, P, E) when N>100 ->
	L = ["cento", "duzentos", "trezentos", "quatrocentos", "quinhentos", "seiscentos", "setecentos", "oitocentos", "novecentos"],
	K = N div 100,
	E ++ lists:nth(K, L) ++ printNum(N - K*100, P, " e ");
printNum(N, P, E) when N=:=100 ->
	E ++ "cem " ++ printNum(0, P, "");
printNum(N, P, E) when N>19 ->
	L = ["vinte", "trinta", "quarenta", "cinquenta", "sessenta", "setenta", "oitenta", "noventa"],
	K = N div 10,
	E ++ lists:nth(K-1, L) ++ " " ++ printNum(N - K * 10, P, "e ");
printNum(N, _, E) when N>0 ->
	L = ["um", "dois", "tres", "quatro", "cinco", "seis", "sete", "oito", "nove", "dez", "onze", "doze", "treze", "quatorze", "quinze", "dezesseis", "dezessete", "dezoito", "dezenove"],	
	E ++ lists:nth(N, L) ++ " "; 
printNum(_,_,_) when true -> [].

printGroup(P, N, V2) ->
	if (V2 =:= 0) -> S = " "; 
		true -> S = ""
	end,
	case N of
		0 ->[];
		1 ->
			L = ["", "mil", "milhao", "bilhao", "trilhao", "quatrilhao", "quintilhao", "sextilhao", "septilhao"],
			lists:nth(P, L) ++ S;
		_Else ->
			L = ["", "mil", "milhoes", "bilhoes", "trilhoes", "quatrilhoes", "quintilhoes", "sextilhoes", "septilhoes"],
			lists:nth(P, L) ++ S
	end.
	
