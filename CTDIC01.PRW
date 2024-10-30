#include "protheus.ch"
#include "parmtype.ch"

/*/{Protheus.doc} CTDIC01
Cria item contabil na CTD e grava o item contabil *(A1_ITEMCC)* no cliente na SA1, chamada no fonte *CRMA9800_PE*, ponto de entrada (PA) *FORMCOMMITTTSPOS*, apos a gravacao do Cliente
@Activation Chamada no fonte CRMA980_PE. 
@type function
@version 1.0
@author HUmberto Queiroz
@since 23/10/2024
@return Logico
/*/
User Function CTDIC01()
	Local aArea  := GetArea()
	Local lRet   := .T.

	//Abre a tabela CTD
	DbSelectarea("CTD")
     	CTD->(DbSetOrder(1))

	//Cria item contabil superior
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

	DBSELECTAREA("SA1")
	DBSETORDER(1)

	//Grava o Item Contabil no cadastro do Cliente
	//Tenta posicionar na SA1, se localizar grava o item contabil no cliente
	IF DBSEEK(FWxFilial("SA1")+SA1->A1_COD+SA1->A1_LOJA,.T.)
	 	RECLOCK("SA1",.F.)
	 	SA1->A1_ITEMCC:='C' + SUBSTR(M->A1_COD,2,5) + M->A1_LOJA 
	 	MSUNLOCK()
	ENDIF

	RestArea(aArea)
Return lRet
