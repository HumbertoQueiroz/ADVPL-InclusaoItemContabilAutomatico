#include "protheus.ch"
#include "parmtype.ch"

/*/{Protheus.doc} User Function CRMA980
Validações no cadastro de Clientes em MVC, MODELPOS:bloqeio de cadastro cooperado por esta rotina e FORMCOMMITTTSPOS: gera item contabil
@author Humberto Queiroz
@since 21/10/2024
@version 1.0
@obs Em que momento: **MODELPOS** no momento que clica em salvar e **FORMCOMMITTTSPOS ** após a gravação
     *-------------------------------------------------*
     Por se tratar de um p.e. em MVC, salve o nome do 
     arquivo diferente, por exemplo, CRMA980_pe.prw 
     *-----------------------------------------------*
     A documentacao de como fazer o p.e. esta disponivel em:
      https://tdn.totvs.com/pages/releaseview.action?pageId=208345968 
      https://terminaldeinformacao.com/2023/03/10/exemplo-de-ponto-de-entrada-no-novo-cadastro-de-clientes-crma980/
/*/
User Function CRMA980()
  Local aArea := FWGetArea()
  Local aParam := PARAMIXB                       // Recebe todos os parametros
  Local lRet := .T.
  Local oObj := Nil                              // Recebera o Objeto do formulário ou do modelo
  Local cIdPonto := ''                           // Recebera o ID (Nome) do Ponto de Entrada
  Local cIdModel := ''
  Local cCodClient := ''

  If aParam <> NIL
    oObj := aParam[1]                            // Recebe o Objeto do formulário ou do modelo
    cIdPonto := aParam[2]                        // Recebe o ID (Nome) do Ponto de Entrada
    cIdModel := aParam[3]                        // Recebe o Modelo

                                                 // PE (ponto de entrada) Na validação total do modelo
    if cIdPonto == 'MODELPOS'                    //Valida quando clica em salvar
        lRet:=U_fValCooper('SA1')               //Valida se cadastro de cooperado, caso sim não deixa continuar, indica fazer pela rotina de cooperado

                                                  // PE (ponto de entrada) Na validação total do modelo
    ElseIf cIdPonto=='FORMCOMMITTTSPOS'
      U_CTDIC01()                                 //Cria item contabil na CTD
    EndIf
    
  EndIf
  FWRestArea(aArea)
Return lRet
