# Inclusão de Item Contábil Automaticamente

Este projeto trata da inclusão automática do item contábil quando cadastra cliente ou fornecedor e bloqueio de cadastro levando em consideração a primeira posição do código do cliente ou fornecedor.

# Documentação

## Liguaguens de Programação

[![ADVPL Linguagem](https://img.shields.io/badge/Linguagem-ADVPL-8A2BE2.svg?logo=totvs)](https://www.totvs.com/blog/developers/advpl/)
[![SQL Server DB](https://img.shields.io/badge/DB-SQL_Server-yellow.svg?logo=amazondynamodb)](https://learn.microsoft.com/en-us/sql/sql-server/?view=sql-server-ver16)

## Objetivo

* Incluir item contabil quando cadstrar fornecedor
* Incluir item contabil quando cadstrar cliente
* Bloquear cadastro quando codigo do fornecedor iniciar em `A`
* Bloquear cadastro quando codigo do cliente iniciar em `A`

## 1. Inclusão do Item Contábil durante o Cadastro do Fornecedor

Foi utilizado o ponto de entrada `M020INC.prw` que tem a finalidade de realizar gravações adicionais do **cadastro de fornecedor** após sua inclusão,  onde o mesmo chama o fonte `CTDIF01.prw` que realiza as operações.

### 1.1 Fonte CTDIF01

Este fonte faz três operações: 
* Inclusão do item contábil superior (sintético) na tabela `CTD`;
* Inclusão do item contábil inferior (analítico) na tabela `CTD`;
* Grava o item contábil inferior (analítico) no campo `A2_ITEMCC` do cadastro do cliente tabela `SA2`.

#### 1.1.1 Inclusão de Item Contábil Superior (Sintético)

#### Drescição da Operação Realizada

Na primeira operação o fonte valida a existencia do item contábil superior (sintético), no formato descrito mais abaixo, 
caso não localize realiza a inclusão, caso posicione vai para a próxima operação sem realizar alteração.

```advpl
//Cria item contabil superior
//Se nao conseguir posicionar, registro sera criado
If ! CTD->(DbSeek(FWxFilial("CTD") + 'F' + SUBSTR(M->A2_COD,2,5)))

  RecLock("CTD", .T.)
  CTD->CTD_FILIAL := XFILIAL("CTD")
  CTD->CTD_ITEM   := 'F' + SUBSTR(M->A2_COD,2,5)
  CTD->CTD_DESC01 := LEFT(M->A2_NOME,LEN(CRIAVAR("CTD_DESC01")))
  CTD->CTD_CLASSE := "1"
  CTD->CTD_NORMAL := "0"
  CTD->CTD_BLOQ   := "2"
  CTD->CTD_DTEXIS := CTOD("01/01/1980")
  CTD->CTD_ITLP   := 'F' + SUBSTR(M->A2_COD,2,5)
  CTD->CTD_CLOBRG := "2"
  CTD->CTD_ACCLVL := "1"
  CTD->CTD_ITSUP  := "F" 
  CTD->(MsUnLock())

Endif
```

#### Formato do item contábil superior:
Tamanho de `6 Digitos`, sendo o primeiro o identificador de clientes `F` mais o código do cliente a esquerda com 5 digitos.

Exemplo:
```
//Formação
"F"+"00001"
//Resultado
"F00001"
```

#### 1.1.2 Inclusão de Item Contábil Inferior (Analítico)

#### Drescição da Operação Realizada

Na segunda operação o fonte valida a existencia do item contábil inferior (analítico), no formato descrito mais abaixo, 
caso não localize realiza a inclusão, caso posicione vai para a próxima operação sem realizar alteração.

```advpl
//Cria item contabil analitico
//Se nao conseguir posicionar, registro sera criado
If ! CTD->(DbSeek(FWxFilial("CTD") + 'F' + SUBSTR(M->A2_COD,2,5) + M->A2_LOJA))

  RecLock("CTD", .T.)
  CTD->CTD_FILIAL := XFILIAL("CTD")
  CTD->CTD_ITEM   := 'F' + SUBSTR(M->A2_COD,2,5) + M->A2_LOJA
  CTD->CTD_DESC01 := LEFT(M->A2_NOME,LEN(CRIAVAR("CTD_DESC01")))
  CTD->CTD_CLASSE := "2"
  CTD->CTD_NORMAL := "0"
  CTD->CTD_BLOQ   := "2"
  CTD->CTD_DTEXIS := CTOD("01/01/1980")
  CTD->CTD_ITLP   := 'F' + SUBSTR(M->A2_COD,2,5) + M->A2_LOJA
  CTD->CTD_CLOBRG := "2"
  CTD->CTD_ACCLVL := "1"
  CTD->CTD_ITSUP  := 'F' + SUBSTR(M->A2_COD,2,5) 
  CTD->(MsUnLock())
  
Endif
```

#### Formato do item contábil superior:
Tamanho de `8 Digitos`, sendo o primeiro o identificador de clientes `F` mais o código do cliente com 5 digitos mais a loja do cliente com 02 digitos.

Exemplo:
```
//Formação
"F"+"00001"+"01"

//Resultado
"F0000101"
```

#### 1.1.3 Gravação do Item Contábil Inferior (Analítico) no Cadastro do Fornecedor

#### Drescição da Operação Realizada

Na terceira operação o fonte localiza o cadastro do fornecedor na tabela `SA2` e grava o item contábil inferior (analítico) no campo `A2_ITEMCC`

```advpl
//Grava o Item Contabil no cadastro do Fornecedor
//Tenta posicionar na SA2, se localizar grava o item contabil no Fornecedor
IF DBSEEK(FWxFilial("SA2")+SA2->A2_COD+SA2->A2_LOJA,.T.)
  RECLOCK("SA2",.F.)
  SA2->A2_ITEMCC:='F' + SUBSTR(M->A2_COD,2,5) + M->A2_LOJA 
  MSUNLOCK()
ENDIF
```


## 2. Inclusão do Item Contábil durante o Cadastro do Cliente

Foi desenvolvido o fonte `CRMA980_PE.prw` que controla a rotina de **cadastro de clientes** (CRMA980) no padrão **MVC**.

Utilizamos o ponto de entrada MVC `FORMCOMMITTTSPOS` para chamar o fonte `CTDIC01.prw`(que realiza as operações) após a gravação do cliente.

### 2.1 Fonte CTDIC01

Este fonte faz três operações: 
* Inclusão do item contábil superior (sintético) na tabela `CTD`;
* Inclusão do item contábil inferior (analítico) na tabela `CTD`;
* Grava o item contábil inferior (analítico) no campo `A1_ITEMCC` do cadastro do cliente tabela `SA1`.

#### 2.1.1 Inclusão de Item Contábil Superior (Sintético)

#### Drescição da Operação Realizada

Na primeira operação o fonte valida a existencia do item contábil superior (sintético), no formato descrito mais abaixo, 
caso não localize realiza a inclusão, caso posicione vai para a próxima operação sem realizar alteração.

```advpl
/Cria item contabil superior
//Se nao conseguir posicionar, registro sera criado
If ! CTD->(DbSeek(FWxFilial("CTD") + 'C' + SUBSTR(M->A1_COD,2,5)))

  RecLock("CTD", .T.)
  CTD->CTD_FILIAL := XFILIAL("CTD")
  CTD->CTD_ITEM   := 'C' + SUBSTR(M->A1_COD,2,5)
  CTD->CTD_DESC01 := LEFT(M->A1_NOME,LEN(CRIAVAR("CTD_DESC01")))
  CTD->CTD_CLASSE := "1"
  CTD->CTD_NORMAL := "0"
  CTD->CTD_BLOQ   := "2"
  CTD->CTD_DTEXIS := CTOD("01/01/1980")
  CTD->CTD_ITLP   := 'C' + SUBSTR(M->A1_COD,2,5)
  CTD->CTD_CLOBRG := "2"
  CTD->CTD_ACCLVL := "1"
  CTD->CTD_ITSUP  := "C" 
  CTD->(MsUnLock())

Endif
```

#### Formato do item contábil superior:
Tamanho de `6 Digitos`, sendo o primeiro o identificador de clientes `C` mais o código do cliente a esquerda com 5 digitos.

Exemplo:
```
//Formação
"C"+"00001"
//Resultado
"C00001"
```

#### 2.1.2 Inclusão de Item Contábil Inferior (Analítico)

#### Drescição da Operação Realizada

Na segunda operação o fonte valida a existencia do item contábil inferior (analítico), no formato descrito mais abaixo, 
caso não localize realiza a inclusão, caso posicione vai para a próxima operação sem realizar alteração.

```advpl
//Cria item contabil analitico
//Se nao conseguir posicionar, registro sera criado
If ! CTD->(DbSeek(FWxFilial("CTD") + 'C' + SUBSTR(M->A1_COD,2,5) + M->A1_LOJA))

  RecLock("CTD", .T.)
  CTD->CTD_FILIAL := XFILIAL("CTD")
  CTD->CTD_ITEM   := 'C' + SUBSTR(M->A1_COD,2,5) + M->A1_LOJA
  CTD->CTD_DESC01 := LEFT(M->A1_NOME,LEN(CRIAVAR("CTD_DESC01")))
  CTD->CTD_CLASSE := "2"
  CTD->CTD_NORMAL := "0"
  CTD->CTD_BLOQ   := "2"
  CTD->CTD_DTEXIS := CTOD("01/01/1980")
  CTD->CTD_ITLP   := 'C' + SUBSTR(M->A1_COD,2,5) + M->A1_LOJA
  CTD->CTD_CLOBRG := "2"
  CTD->CTD_ACCLVL := "1"
  CTD->CTD_ITSUP  := 'C' + SUBSTR(M->A1_COD,2,5) 
  CTD->(MsUnLock())
  
Endif
```

#### Formato do item contábil superior:
Tamanho de `8 Digitos`, sendo o primeiro o identificador de clientes `C` mais o código do cliente com 5 digitos mais a loja do cliente com 02 digitos.

Exemplo:
```
//Formação
"C"+"00001"+"01"
//Resultado
"C0000101"
```

#### 2.1.3 Gravação do Item Contábil Inferior (Analítico) no Cadastro do Cliente

#### Drescição da Operação Realizada

Na terceira operação o fonte localiza o cadastro do cliente na tabela `SA1` e grava o item contábil inferior (analítico) no campo `A1_ITEMCC`

```advpl
//Grava o Item Contabil no cadastro do Cliente
//Tenta posicionar na SA1, se localizar grava o item contabil no cliente
IF DBSEEK(FWxFilial("SA1")+SA1->A1_COD+SA1->A1_LOJA,.T.)
  RECLOCK("SA1",.F.)
  SA1->A1_ITEMCC:='C' + SUBSTR(M->A1_COD,2,5) + M->A1_LOJA 
  MSUNLOCK()
ENDIF
```

## 3. Bloquear cadastro quando codigo do fornecedor iniciar em `A`

Foi utilizado o Ponto de Entrada `MA020TDOK` que executa na validação dos dados digitados, recebendo o resultado da execução do fonte `fValCooper` que realiza as validações, este fonte deve receber como paramêtro a tabela atual.

Caso o retorno seja `.T.` ele deixa gravar a inclusão, caso seja `.F.` não deixa salvar.

## 4. Bloquear cadastro quando codigo do cliente iniciar em `A`

No fonte `CRMA980_PE.prw` que controla a rotina de **cadastro de clientes** (CRMA980) no padrão **MVC**.

Utilizamos o ponto de entrada MVC `MODELPOS` para armazenar o resultado da execução do fonte `fValCooper` que realiza as validações, este fonte deve receber como paramêtro a tabela atual.

Caso o retorno seja `.T.` ele deixa gravar a inclusão, caso seja `.F.` não deixa salvar.

## Autor

- [@HumbertoQueiroz](https://github.com/HumbertoQueiroz)

### 🚀 Sobre mim

Eu sou um desenvolver apaixonado pela lógica computacional que esta se aprofundando no mundo TOTVS com sua linguem de programação `ADVPL`.
