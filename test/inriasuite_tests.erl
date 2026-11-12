-module(inriasuite_tests).
-author("frans-de-boer").

-include_lib("eunit/include/eunit.hrl").

-define(SERVER, erlog_server).

start() -> ?SERVER:start_link().

stop({ok, Pid}) -> ?SERVER:stop(Pid).

sp(String) ->
  try
    {ok, Tokens, _} = erlog_scan:string(String ++ ". ", 1),
    {ok, Goal} = erlog_parse:term(Tokens),
    Goal
  catch
    error:Err -> Err
  end.

call_test_() -> {setup, fun start/0, fun stop/1, [fun call_9/0, fun call_10/0, fun call_11/0]}.

call_9() -> ?assertEqual({error,{type_error,callable,{',',fail,1}}}, gen_server:call(?SERVER, {prove, sp("call((fail, 1))")})).

call_10() -> ?assertEqual({error,{type_error,callable,{',',{write,3},1}}}, gen_server:call(?SERVER, {prove, sp("call((write(3), 1))")})).

call_11() -> ?assertEqual({error,{type_error,callable,{';',1,true}}}, gen_server:call(?SERVER, {prove, sp("call((1; true))")})).


unify_test_() -> {setup, fun start/0, fun stop/1, [fun unify_3/0, fun unify_7/0, fun unify_11/0]}.

unify_3() -> ?assertEqual({succeed,[{'X','Y'}]}, gen_server:call(?SERVER, {prove, sp("=(X,Y)")})).

unify_7() -> ?assertEqual(fail, gen_server:call(?SERVER, {prove, sp("=(1,1.0)")})).

unify_11() -> ?assertEqual({succeed,[{'A',{g,{g,{g,'D','D'},{g,'D','D'}},
  {g,{g,'D','D'},{g,'D','D'}}}},
  {'B',{g,{g,'D','D'},{g,'D','D'}}},
  {'C',{g,'D','D'}}]}, gen_server:call(?SERVER, {prove, sp("=(f(A,B,C),f(g(B,B),g(C,C),g(D,D)))")})).


not_unify_test_() -> {setup, fun start/0, fun stop/1, [fun not_unify_7/0, fun not_unify_8/0, fun not_unify_9/0, fun not_unify_10/0]}.

not_unify_7() -> ?assertEqual({succeed,[]}, gen_server:call(?SERVER, {prove, sp("\\=(1,1.0)")})).

not_unify_8() -> ?assertEqual({succeed,[]}, gen_server:call(?SERVER, {prove, sp("\\=(g(X),f(f(X)))")})).

not_unify_9() -> ?assertEqual({succeed,[]}, gen_server:call(?SERVER, {prove, sp("\\=(f(X,1),f(a(X)))")})).

not_unify_10() -> ?assertEqual({succeed,[]}, gen_server:call(?SERVER, {prove, sp("\\=(f(X,Y,X),f(a(X),a(Y),Y,2))")})).


atom_test_() -> {setup, fun start/0, fun stop/1, [fun atom_5/0]}.

atom_5() -> ?assertEqual({succeed,[]}, gen_server:call(?SERVER, {prove, sp("atom([])")})).


integer_test_() -> {setup, fun start/0, fun stop/1, [fun integer_2/0]}.

integer_2() -> ?assertEqual({succeed,[]}, gen_server:call(?SERVER, {prove, sp("integer(-3)")})).


float_test_() -> {setup, fun start/0, fun stop/1, [fun float_2/0]}.

float_2() -> ?assertEqual({succeed,[]}, gen_server:call(?SERVER, {prove, sp("float(-3.3)")})).


atomic_test_() -> {setup, fun start/0, fun stop/1, [fun atomic_4/0]}.

atomic_4() -> ?assertEqual({succeed,[]}, gen_server:call(?SERVER, {prove, sp("atomic([])")})).


compound_test_() -> {setup, fun start/0, fun stop/1, [fun compound_2/0, fun compound_4/0]}.

compound_2() -> ?assertEqual(fail, gen_server:call(?SERVER, {prove, sp("compound(-33.3)")})).

compound_4() -> ?assertEqual(fail, gen_server:call(?SERVER, {prove, sp("compound(_)")})).


number_test_() -> {setup, fun start/0, fun stop/1, [fun number_3/0]}.

number_3() -> ?assertEqual({succeed,[]}, gen_server:call(?SERVER, {prove, sp("number(-3)")})).


'term_lt=_test_'() -> {setup, fun start/0, fun stop/1, [fun 'term_lt=_6'/0, fun 'term_lt=_7'/0]}.

'term_lt=_6'() -> ?assertEqual({succeed,[]}, gen_server:call(?SERVER, {prove, sp("@=<(X,X)")})).

'term_lt=_7'() -> ?assertEqual({succeed,[]}, gen_server:call(?SERVER, {prove, sp("@=<(foo(a,X),foo(b,Y))")})).


term_eq_test_() -> {setup, fun start/0, fun stop/1, [fun term_eq_2/0]}.

term_eq_2() -> ?assertEqual({succeed,[]}, gen_server:call(?SERVER, {prove, sp("==(X,X)")})).


term_diff_test_() -> {setup, fun start/0, fun stop/1, [fun term_diff_4/0, fun term_diff_5/0, fun term_diff_7/0]}.

term_diff_4() -> ?assertEqual({succeed,[]}, gen_server:call(?SERVER, {prove, sp("\\==(X,1)")})).

term_diff_5() -> ?assertEqual({succeed,[]}, gen_server:call(?SERVER, {prove, sp("\\==(X,Y)")})).

term_diff_7() -> ?assertEqual({succeed,[]}, gen_server:call(?SERVER, {prove, sp("\\==(X,a(X))")})).


term_lt_test_() -> {setup, fun start/0, fun stop/1, [fun term_lt_7/0]}.

term_lt_7() -> ?assertEqual({succeed,[]}, gen_server:call(?SERVER, {prove, sp("@<(foo(a,X),foo(b,Y))")})).


'term_gt=_test_'() -> {setup, fun start/0, fun stop/1, [fun 'term_gt=_1'/0, fun 'term_gt=_6'/0]}.

'term_gt=_1'() -> ?assertEqual(fail, gen_server:call(?SERVER, {prove, sp("1.0 @>= 1")})).

'term_gt=_6'() -> ?assertEqual({succeed,[]}, gen_server:call(?SERVER, {prove, sp("@>=(X,X)")})).


functor_test_() -> {setup, fun start/0, fun stop/1, [fun functor_13/0, fun functor_16/0, fun functor_17/0, fun functor_18/0]}.

functor_13() -> ?assertEqual({error,instantiation_error}, gen_server:call(?SERVER, {prove, sp("functor(X, foo, N)")})).

functor_16() -> ?assertEqual({error,{type_error,atomic,{foo,a}}}, gen_server:call(?SERVER, {prove, sp("functor(F,foo(a),1)")})).

functor_17() -> ?assertEqual({error,{representation_error,max_arity}}, gen_server:call(?SERVER, {prove, sp("(current_prolog_flag(max_arity,A), X is A + 1, functor(T, foo, X))")})).

functor_18() -> ?assertEqual({error,{domain_error,not_less_than_zero,-1}}, gen_server:call(?SERVER, {prove, sp("functor(T, foo, -1)")})).


arg_test_() -> {setup, fun start/0, fun stop/1, [fun arg_5/0, fun arg_9/0, fun arg_10/0, fun arg_13/0]}.

arg_5() -> ?assertEqual({succeed,[{'X','Y'}]}, gen_server:call(?SERVER, {prove, sp("arg(1,foo(X,b),Y)")})).

arg_9() -> ?assertEqual({error,instantiation_error}, gen_server:call(?SERVER, {prove, sp("arg(X,foo(a,b),a)")})).

arg_10() -> ?assertEqual({error,instantiation_error}, gen_server:call(?SERVER, {prove, sp("arg(1,X,a)")})).

arg_13() -> ?assertEqual({error,{domain_error,not_less_than_zero,-3}}, gen_server:call(?SERVER, {prove, sp("arg(-3,foo(a,b),A)")})).


copy_term_test_() -> {setup, fun start/0, fun stop/1, [fun copy_term_1/0, fun copy_term_2/0, fun copy_term_6/0]}.

copy_term_1() -> ?assertEqual({succeed,[]}, gen_server:call(?SERVER, {prove, sp("copy_term(X,Y)")})).

copy_term_2() -> ?assertEqual({succeed,[]}, gen_server:call(?SERVER, {prove, sp("copy_term(X,3)")})).

copy_term_6() -> ?assertEqual({succeed,[{'A','B'}]}, gen_server:call(?SERVER, {prove, sp("copy_term(X+X+Y,A+B+B)")})).


is_test_() -> {setup, fun start/0, fun stop/1, [fun is_5/0]}.

is_5() -> ?assertEqual({error,{type_error,evaluable,'foo/0'}}, gen_server:call(?SERVER, {prove, sp("is(77, foo)")})).


clause_test_() -> {setup, fun start/0, fun stop/1, [fun clause_2/0, fun clause_4/0]}.

clause_2() -> ?assertEqual({error,instantiation_error}, gen_server:call(?SERVER, {prove, sp("clause(_,B)")})).

% fails also in scryer prolog
clause_4() -> ?assertEqual({error,{type_error,callable,5}}, gen_server:call(?SERVER, {prove, sp("clause(f(_),5)")})).


asserta_test_() -> {setup, fun start/0, fun stop/1, [fun asserta_1/0, fun asserta_2/0]}.

asserta_1() -> ?assertEqual({succeed,[{'B',{call,'X'}}]}, gen_server:call(?SERVER, {prove, sp("(asserta((bar(X) :- X)), clause(bar(X), B))")})).

asserta_2() -> ?assertEqual({error,instantiation_error}, gen_server:call(?SERVER, {prove, sp("asserta(_)")})).


assertz_test_() -> {setup, fun start/0, fun stop/1, [fun assertz_1/0, fun assertz_2/0]}.

assertz_1() -> ?assertEqual({succeed,[]}, gen_server:call(?SERVER, {prove, sp("assertz((foo(X) :- X -> call(X)))")})).

assertz_2() -> ?assertEqual({error,instantiation_error}, gen_server:call(?SERVER, {prove, sp("assertz(_)")})).


abolish_test_() -> {setup, fun start/0, fun stop/1, [fun abolish_2/0, fun abolish_3/0, fun abolish_4/0, fun abolish_5/0]}.

abolish_2() -> ?assertEqual({error,{type_error,integer,a}}, gen_server:call(?SERVER, {prove, sp("abolish(foo/a)")})).

abolish_3() -> ?assertEqual({error,{domain_error,not_less_than_zero,-1}}, gen_server:call(?SERVER, {prove, sp("abolish(foo/(-1))")})).

abolish_4() -> ?assertEqual({error,{representation_error,max_arity}}, gen_server:call(?SERVER, {prove, sp("(current_prolog_flag(max_arity,A), X is A + 1, abolish(foo/X))")})).

abolish_5() -> ?assertEqual({error,{type_error,atom,5}}, gen_server:call(?SERVER, {prove, sp("abolish(5/2)")})).


findall_test_() -> {setup, fun start/0, fun stop/1, [fun findall_1/0, fun findall_2/0, fun findall_3/0, fun findall_4/0]}.

findall_1() -> ?assertEqual({succeed,[{'S',[1,2]}]}, gen_server:call(?SERVER, {prove, sp("findall(X,(X=1 ; X=2),S)")})).

findall_2() -> ?assertEqual({succeed,[{'S',[{'+',1,{4}}]}]}, gen_server:call(?SERVER, {prove, sp("findall(X+Y,(X=1),S)")})). % _4 instead of {4}?

findall_3() -> ?assertEqual({succeed,[{'L',[]}]}, gen_server:call(?SERVER, {prove, sp("findall(X,fail,L)")})).

findall_4() -> ?assertEqual({succeed,[{'S',[1,1]}]}, gen_server:call(?SERVER, {prove, sp("findall(X,(X=1 ; X=1),S)")})).


not_provable_test_() -> {setup, fun start/0, fun stop/1, [fun not_provable_3/0, fun not_provable_4/0]}.

not_provable_3() -> ?assertEqual({succeed,[]}, gen_server:call(?SERVER, {prove, sp("\\+((!,fail))")})).

not_provable_4() -> ?assertEqual({succeed,[{'X',1}]}, gen_server:call(?SERVER, {prove, sp("((X=1;X=2), \\+((!,fail)))")})).


atom_chars_test_() ->
  {setup, fun start/0, fun stop/1, [fun atom_chars_2/0, fun atom_chars_3/0, fun atom_chars_14/0]}.

atom_chars_2() -> ?assertEqual({succeed,[{'L',['[',']']}]}, gen_server:call(?SERVER, {prove, sp("atom_chars([],L)")})).

atom_chars_3() -> ?assertEqual({succeed,[{'L',['\'']}]}, sp("atom_chars('''',L)")).

atom_chars_14() -> ?assertEqual({error,{type_error,evaluable, {'/',12,0}}}, gen_server:call(?SERVER, {prove, sp("(atom_chars(X,['1','2']), Y is X + 1)")})).


atom_codes_test_() ->
  {setup, fun start/0, fun stop/1, [fun atom_codes_2/0, fun atom_codes_3/0, fun atom_codes_11/0, fun atom_codes_11_alt/0]}.

atom_codes_2() -> ?assertEqual({succeed,[{'L',[91,93]}]}, gen_server:call(?SERVER, {prove, sp("atom_codes([],L)")})).

atom_codes_3() -> ?assertEqual({success,[{'L',39}]}, sp("atom_codes('''',L)")).

atom_codes_11() -> ?assertEqual({success,[{'L','is\x{3E8}'}]}, gen_server:call(?SERVER, {prove, sp("atom_codes(A,[0'i, 0's, 1000])")})).

atom_codes_11_alt() -> ?assertEqual({error,{representation_error, character_code}}, gen_server:call(?SERVER, {prove, sp("atom_codes(A,[0'i, 0's, 10000000])")})).


set_prolog_flag_test_() ->
  {setup, fun start/0, fun stop/1, [fun set_prolog_flag_3/0, fun set_prolog_flag_6/0]}.

set_prolog_flag_3() -> ?assertEqual({error,{type_error,atom,5}}, gen_server:call(?SERVER, {prove, sp("set_prolog_flag(5, decimals)")})).

set_prolog_flag_6() -> ?assertEqual({error,{permission_error,modify,flag,max_arity}}, gen_server:call(?SERVER, {prove, sp("set_prolog_flag(max_arity, 40)")})).
