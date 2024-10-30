#Include 'Protheus.ch'

//----------------------------------------------------------------
/*/{Protheus.doc} MA020TDOK
Ponto de Entrada tem a finalidade de validar as informações digitadas 
no cadastro de fornecedor.

@type function
@author Allan da Silva Faria
@since 22/12/2016
@version 1.0
@return Logico, Retorna se verdade, permite salver o cadastro.
/*/
//----------------------------------------------------------------
User Function MA020TDOK()
local lRet:=.T.

//breno nogueira 31/07/2024

//----------------------------------------------
//-- Confirma numeração sequencial fornecedor
//----------------------------------------------
If INCLUI
	SA2->(ConfirmSX8())
EndIf

//Valida se cadastro de cooperado, caso sim não deixa continuar, indica fazer pela rotina de cooperado
lRet:=U_fValCooper('SA2')



Return(lRet)

