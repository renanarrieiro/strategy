# Orientação a Objeto - SOLID - Strategy

Estava hoje fazendo um code review da minha equipe e me deparei com o seguinte trecho de código.

```abap
class zcl_s4_to_btp implementation.
	...
	method prepare_request.
		case im_http_method.
			when zif_s4_to_btp=>http_methods-method_read.
				requisition->request->set_method( zif_s4_to_btp=>http_methods-method_read ).
				cl_http_utility=>set_request_uri( request = requisition->request
																					uri     = '' ).
			when zif_s4_to_btp=>http_methods-method_post.
				cl_http_utility=>set_request_uri( request = requisition->request
																					uri     = '' ).
				requisition->request->set_method( zif_s4_to_btp=>http_methods-method_post ).
				append_data_to_requistion( im_data ).
			when zif_s4_to_btp=>http_methods-method_delete.
				cl_http_utility=>set_request_uri( request = requisition->request
																					uri     = '' ).
				requisition->request->set_method( zif_s4_to_btp=>http_methods-method_delete ).
				append_data_to_requistion( im_data ).
			when others.
				requisition->request->set_method( zif_s4_to_btp=>http_methods-method_read ).
				cl_http_utility=>set_request_uri( request = requisition->request
																					uri     = '' ).
		endcase.
	endmethod.
	...
endclass.
```

Achei que seria uma boa oportunidade de reforçar com a equipe alguns conceitos do mundo mágico da orientação objeto.

Em primeira vista parece um código simples, sem muito o que melhorar, mas aí que mora o engano, nesse pequeno trecho de código podemos aplicar alguns conceitos consolidados no mercado, o que vou tentar me concentrar, são eles a orientação objeto no seu estado puro, o conceito S.O.L.I.D, conceito de Clean Code e padrão de projeto Strategy.

Muitas vezes nos deixamos cair na armadilha do procedural disfarçada de orientação objeto, me incluo muito nisso, às vezes achamos que estamos aplicando o melhor da orientação objeto, que nada, estamos só usando o que temos de modo mais fácil naquele momento.

Quando eu estou ensinando a orientação objeto para alguma pessoa, gosto de dizer para ela pensar que tudo é um objeto, tudo mesmo, esqueça, string, int, float, etc., pense que tudo é um objeto, igual ao mundo real, é isso que vou tentar aplicar neste código.

## O Problema

Os principais problemas que vejo são a violação de alguns conceitos, exemplo, é o Open/Closed Principle (OCP) que para cada novo método HTTP devemos adicionar um case nesse método e em todos os outros que faça a mesma verificação.

Tem vários trechos duplicados, somente alterando um parâmetro e outros nenhum, isso viola o Don't Repeat Yourself Principle (DRY) e pode-se aplicar outros padrões que ajudará nós mesmos no futuro a manter esse código.

## Primeiro Passo - Remover a Duplicação

Primeira coisa que me preocupo aqui é a duplicação de código, essa prática muito comum infringe o princípio do Don't Repeat Yourself, e vou tentar garantir que o 'S' do S.O.L.I.D que é o Single Responsibility Principle (SRP) seja respeitada, deixando esse método somente com uma responsabilidade.

Passei a definição do método para o contrato, interface zif_s4_to_btp, e deixei somente uma chamada do set_method, set_request_uri e append_data_to_requistion.

```abap
method zif_s4_to_btp~prepare_request.
	requisition->request->set_method( zif_s4_to_btp=>http_methods-method_read ).
	cl_http_utility=>set_request_uri( request = requisition->request
																		uri     = '' ).
	append_data_to_requistion( im_data ).
endmethod.
```

## Segundo Passo - Aplicar o Padrão de Projeto Strategy

Agora vou aplicar o conceito do Strategy e orientação objeto, e transformar cada método HTTP em objeto, lembre-se tudo é objeto em orientação objeto hehehe.

Vou criar o contrato, zif_http_method.

```abap
interface zif_http_method public .
	types ty_http_method type string .
	
	constants:
		begin of http_methods,
			method_get type string value 'GET' ##no_text,
			method_post type string value 'POST' ##no_text,
			method_delete type string value 'DELETE' ##no_text,
		end of http_methods .
	
	data http_method type ty_http_method.
	
	methods get_http_method
		returning
			value(result) type ty_http_method.
			
endinterface.
```

Como o ABAP é uma linguagem fortemente tipada e precisar enviar uma string para um método "standard", criei um tipo ty_method_http do tipo primitivo string, caso precise alterar no futuro o tipo, será necessário alterar somente em lugar.

Com o contrato firmado, vou criar a classe concreta desse contrato o zcl_http_method.

```abap
class zcl_http_method definition create public .
	public section.
		interfaces zif_http_method.
		
		aliases get_http_method
			for zif_http_method~get_http_method.

	methods constructor
		importing
			http_method type zif_http_method~ty_http_method.
			
	private section.
		aliases http_method
			for zif_http_method~http_method.
			
endclass.

class zcl_http_method implementation.
	method constructor.
		me->http_method = http_method.
	endmethod.

	method zif_http_method~get_http_method.
		result = me->http_method.
	endmethod.
	
endclass.
```

Essa classe simplesmente recebe o método http em seu construtor e tem um get_http_method, próximo passo é criar os objetos para cada método http, agora as coisas ficam legal.

Criei zcl_http_method_post, zcl_http_method_get e zcl_http_method_delete.

```abap
class zcl_http_method_post definition public final
	create public inheriting from zcl_http_method.
	
	public section.
		methods constructor.
		
endclass.

class zcl_http_method_post implementation.
	method constructor.
		super->constructor( zif_http_method~http_methods-method_post ).
	endmethod.
	
endclass.
```

Essa classe é mais simples ainda, ele só passa o método http que ela é para seu objeto pai no construtor, assim existe a possibilidade futura desses objetos terem ações específicas para cada método, isso faz parte do padrão Strategy, e garantimos o 'O' do S.O.L.I.D que é o Open/Closed Principle (OCP) que as classes só existam para serem estendida e não modificada.

## Terceiro Passo - Refatorar Refatorar e Refatorar

Igualmente em nosso famoso Test Driven Development (TDD) a refatoração sempre anda junto com as nossas boas práticas, então refatorar sempre que possível em busca de melhorias.

Voltando ao contrato zif_s4_to_btp, o método prepare_request.

```abap
interface zif_s4_to_btp public .
	data http_request type ref to if_http_client.

	methods prepare_request
		importing
			http_method type ref to zif_http_method.
			
endinterface.
```

agora ele recebe uma interface, que lindo, não? e vou refatorar nosso método na classe concreta.

```abap
method zif_s4_to_btp~prepare_request.
	http_request->request->set_method( http_method->get_method( ) ).
	cl_http_utility=>set_request_uri(
		request = http_request->request
		uri     = space
	).
endmethod.
```

Como nem todos os métodos exigem um corpo em sua requisição, removi o método append_data_to_requistion e adicionarei em outro ponto, confia hehehe.

## Quarto Passo - Onde Esse Método é Usado?

Preciso tomar cuidado onde o método prepare_request é chamado por que ele foi alterado e pode impactar, e isso pode causar dump, etc., cadê meus testes unitários? hehehe isso é tópico para outro dia hehehe.

Dentro da classe zcl_s4_to_btp existem os métodos post, read e delete, onde invocam o método prepare_request, a seguir os métodos antes da refatoração.

```abap
method post.
	check requisition is bound.
	
	data(json_data) = convert_data_to_json( im_table_data ).
	
	if json_data is initial.
		return.
	endif.
	
	prepare_request(
		im_http_method = zif_s4_to_btp=>http_methods-method_post
		im_data        = json_data 
	).
	
	requisition->send( ).
	
	re_result = validate_response( ).
endmethod.
```

```abap
method read.
	check requisition is bound.

	prepare_request( im_http_method = zif_s4_to_btp=>http_methods-method_read ).
	requisition->send( ).
	
	re_result = validate_response( ).
endmethod.
```

```abap
method delete.
	check requisition is bound.
	
	prepare_request(
		im_http_method = zif_s4_to_btp=>http_methods-method_delete
		im_data        = im_where_clause 
	).
	
	requisition->send( ).
	
	re_result = validate_response( ).
endmethod.
```

Agora vou refatorar esses métodos, mas vou mostrar somente o post por que os outros vão seguir a mesma ideia, e aqui também uso o DRY hehehe.

```abap
interface zif_s4_to_btp public .
	...
	methods send_post
		importing
			request_body_content type any
		returning
			value(result)         type json.
...
endinterface.
```

```abap
method zif_s4_to_btp~send_post.
	check request is bound.

	data(data_json) = convert_internal_table_to_json( request_body_content ).
	
	if data_json is initial.
		" exception - blank body
		...
		return.
	endif.
	
	data(http_post) = new zcl_http_method_post( ).
	
	prepare_request( http_post ).
	set_body_to_request( mrm_data_json ).

	result = call_api( ).
endmethod.

```

Alterei o nome do método para que fique um pouco mais claro qual é a responsabilidade do método, alterei o nome do método que converte a tabela interna em uma string json, tudo isso para deixar o código mais limpo obedecendo o Clean Code.

E agora preciso somente instanciar o método http que são objetos e passar eles para o meu prepare_request que ele vai saber o que fazer, coisa linda né? eu acho hehehe.

Qual o benefício aqui? agora os métodos, send_get, send_delete é só instanciar o objeto que precisa e chamar o prepare_request, não precisa criar aquele case gigante, e o melhor se quiser adicionar o comportamento de outro método http, exemplo o PUT, não vai precisar alterar nenhum método, somente estender os que existem, mas uma vez, coisa linda né?

## Conclusão

Com essas alterações, conseguimos aplicar os princípios de design e o padrão Strategy de forma eficaz. O código agora está mais limpo, mais fácil de manter e extensível para novos métodos HTTP no futuro. Além disso, a responsabilidade de cada classe está bem definida, respeitando os princípios S.O.L.I.D.

[Orientação a Objeto - SOLID - Strategy](https://www.linkedin.com/pulse/orienta%C3%A7%C3%A3o-objeto-solid-strategy-renan-arrieiro-kds1f)
