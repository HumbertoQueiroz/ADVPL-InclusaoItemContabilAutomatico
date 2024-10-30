#include "protheus.ch"
#include "parmtype.ch"

/*/{Protheus.doc} CTDIF01
Cria item contabil na CTD e grava o item contabil *(A2_ITEMCC)* no Fornecedor na SA2, chamada no fonte *CRMA980_PE*, ponto de entrada (PA) *FORMCOMMITTTSPOS*, apos a gravacao do Fornecedor
@Activation Chamada no fonte CRMA980_PE. 
@type function
@version 1.0
@author HUmberto Queiroz
@since 23/10/2024
@return Logico
/*/
User Function CTDIF01()
	Local aArea  := GetArea()
	Local lRet   := .T.

	//Abre a tabela CTD
	DbSelectarea("CTD")
	CTD->(DbSetOrder(1))

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

	DBSELECTAREA("SA2")
	DBSETORDER(1)

	//Grava o Item Contabil no cadastro do Fornecedor
	//Tenta posicionar na SA2, se localizar grava o item contabil no Fornecedor
	IF DBSEEK(FWxFilial("SA2")+SA2->A2_COD+SA2->A2_LOJA,.T.)
	 	RECLOCK("SA2",.F.)
	 	SA2->A2_ITEMCC:='F' + SUBSTR(M->A2_COD,2,5) + M->A2_LOJA 
	 	MSUNLOCK()
	ENDIF

	RestArea(aArea)
Return lRet
