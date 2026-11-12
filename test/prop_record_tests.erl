-module(prop_record_tests).

-export([address/0, comments/0, name/0, phone/0]).

-include_lib("proper/include/proper.hrl").

-record(person, {name, phone, address, comments}).

%%%%%%%%%%%%%%%%%%
%%% Properties %%%
%%%%%%%%%%%%%%%%%%

prop_record_get_attribute() ->
  ?FORALL({Record, Attribute}, {person(), attribute()},
    begin
      {ok, Erl0} = erlog:new(),
      {ok, Erl1} = erlog:consult("stdlib/erlang.pl", Erl0),
      Fields = record_info(fields, person),
      {{succeed,_}, Erl2} = erlog:prove({record, person, Fields}, Erl1),
      {{succeed,[{'Value', Value}]},_} = erlog:prove({person, Attribute, Record, {'Value'}}, Erl2),
      output_record_attribute(Record, Attribute, Value)
    end).

prop_record_set_attribute() ->
  ?FORALL(Attribute, attribute(),
    begin
      ?FORALL({Record0, Value}, {person(), apply(prop_record_tests, Attribute, [])},
        begin
          {ok, Erl0} = erlog:new(),
          {ok, Erl1} = erlog:consult("stdlib/erlang.pl", Erl0),
          Fields = record_info(fields, person),
          {{succeed,_}, Erl2} = erlog:prove({record, person, Fields}, Erl1),
          {{succeed,[{'Record', Record1}]},_} = erlog:prove({person, Attribute, Record0, Value, {'Record'}}, Erl2),
          output_record_attribute(Record1, Attribute, Value)
        end)
    end).

%%%%%%%%%%%%%%%
%%% Helpers %%%
%%%%%%%%%%%%%%%

output_record_attribute(Record, address, Value) when is_record(Record, person) -> Record#person.address == Value;
output_record_attribute(Record, comments, Value) when is_record(Record, person) -> Record#person.comments == Value;
output_record_attribute(Record, name, Value) when is_record(Record, person) -> Record#person.name == Value;
output_record_attribute(Record, phone, Value) when is_record(Record, person) -> Record#person.phone == Value.

%%%%%%%%%%%%%%%%%%
%%% Generators %%%
%%%%%%%%%%%%%%%%%%

person() -> #person{name = name(), phone	= phone(), address	= address(), comments	= comments()}.

attribute() -> elements(record_info(fields, person)).

address() -> list(char()).

comments() -> binary().

name() -> elements(["Adam", "Bob", "Charlie"]).

phone() -> vector(1, choose(48,57)).
