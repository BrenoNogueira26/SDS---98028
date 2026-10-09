#include "protheus.ch"
#include "fwmvcdef.ch"

/*/{Protheus.doc} mt010alt
PE chamado após a alteração do produto PE DENTRO DE TRANSAÇÃO
@type function
@version P12
@author Não informado 
@since 03/05/2023
@see https://tdn.totvs.com/pages/releaseview.action?pageId=6087681
/*/
User Function mt010alt()

	Local cCodusr  := ""
	Local lGrpIM   := SuperGetMv("CG_GRPIM",.F.,"0108;1200;1208")
	Local lRetOk   := .T.
	Local cBody    := ""
	Local cFrom    := ""
	Local cTos     := ""
	Local cSubject := ""
	Local lEnviado := .T.
	Local aFile := {}
	Local cAssinatura as Character
	Local cCopiaOculta as Character
	LOCAL cCopia as Character

	cCodusr := retcodusr()

	/*Desenvolvedor: Bruno Davantel Valarini
	Chama a rotina para replicar os dados da F2Q (Complemento Fiscal)
	*/
	u_REPLIF2Q()

	If !cCodUsr$GETMV("MV_DEPCAD") //usuarios que liberam produtos

		/*
		If Reclock("SB1",.F.)
			SB1->B1_MSBLQL 	:= '1'
			SB1->B1_USER 	:= UsrRetName(cCodusr)
			MsUnlock("SB1")
		ENDIF
		*/

		CQRY:= ""
		cQry += " UPDATE "+RetSqlName("SB1")
		cQry += " SET "
		cQry += " B1_MSBLQL = '1', B1_USER = '" + UsrRetName(cCodusr) + "' "
		cQry += " WHERE "
		cQry += " B1_COD =  '" + SB1->B1_COD + "' "
		cQry += " AND D_E_L_E_T_ = ' ' "

		If (TCSQLExec(cQry) < 0)
			lRetOK   := .F.
			cMsgErr  := "TCSQLError() " + TCSQLError()
		endIf
	ELSE
		If Reclock("SB1",.F.)
			SB1->B1_USER 	:= ''
			MsUnlock("SB1")
		ENDIF
		IF EMPTY(SB1->B1_CONTAS)
			MsgAlert("As Contas contábeis complementares desse produto estão em branco, é necessário Registrar as Informações...!!!","Atenção")
			lRetOk := .F.
		endif
	endif

	If lRetOk
		If Alltrim(M->B1_MSBLQL) = '2'
			If !Alltrim(M->B1_GRUPO) $ lGrpIM
				If Alltrim(M->B1_TIPO)='PA' .or. Alltrim(M->B1_TIPO)='ME'
					cFrom    := SuperGetMv("MV_RELACNT",.F.,"notificacoes@cognycsc.com.br")
					cTos     := SuperGetMv("CG_EMAILIM",.F.,"breno.nogueira@cognycsc.com.br")
					cSubject := "Bloqueio de Produto..:" + cValToChar(FWTimeStamp(2))
					cBody    := ""
					cBody    := BodyEmailIM(2)
					cBody    := StrTran(cBody,"@@CODIGO_PRODUTO@@", AllTrim(M->B1_COD))
					cBody    := StrTran(cBody,"@@DESCRICAO@@",AllTrim(M->B1_DESC))
					cBody    := StrTran(cBody,"@@URL_WHATS@@","https://wa.me/554192738358")
					lEnviado := EnvIntMerc(cFrom, cTos, cSubject, cBody, aFile, cAssinatura, cCopia, cCopiaOculta)
				endif
			endif
		else
			If !Alltrim(M->B1_GRUPO) $ lGrpIM
				If Alltrim(M->B1_TIPO)='PA' .or. Alltrim(M->B1_TIPO)='ME'
					cFrom    := SuperGetMv("MV_RELACNT",.F.,"notificacoes@cognycsc.com.br")
					cTos     := SuperGetMv("CG_EMAILIM",.F.,"breno.nogueira@cognycsc.com.br")
					cSubject := "Alteração de Produto..:" + cValToChar(FWTimeStamp(2))
					cBody    := ""
					cBody    := BodyEmailIM(1)
					cBody    := StrTran(cBody,"@@CODIGO_PRODUTO@@", AllTrim(M->B1_COD))
					cBody    := StrTran(cBody,"@@DESCRICAO@@",AllTrim(M->B1_DESC))
					cBody    := StrTran(cBody,"@@URL_WHATS@@","https://wa.me/554192738358")
					lEnviado := EnvIntMerc(cFrom, cTos, cSubject, cBody, aFile, cAssinatura, cCopia, cCopiaOculta)
				endif
			endif
		endif
	endif
return

Static Function BodyEmailIM(nTipo)
	Local cHtml as Character

	cHtml := ' '
	cHtml := ' <!DOCTYPE html>
	cHtml += ' <html lang="pt-BR">
	cHtml += ' <head>
	cHtml += '     <meta charset="UTF-8">
	cHtml += '     <meta name="viewport" content="width=device-width,initial-scale=1">
	cHtml += '     <title>Notificação de Alteração de Produto</title>
	cHtml += '     <style>
	cHtml += '         body{font-family:Arial,sans-serif;background-color:#f4f4f4;margin:0;padding:0;color:#333}.container{width:100%;max-width:800px;margin:0 auto;background-color:#fff;padding:20px;border-radius:8px;box-shadow:0 0 10px rgba(0,0,0,.1)}.header{background-color:#d4b404;color:#fff;padding:10px 20px;border-radius:8px 8px 0 0;text-align:center}.header h1{margin:0;font-size:24px}.content{padding:20px}.content p{font-size:16px;line-height:1.5;margin-bottom:20px}.content .cta{background-color:#25d366;color:#fff;padding:10px;border-radius:5px;text-align:center;text-decoration:none;display:inline-block;margin-top:20px;font-size:18px}.footer{text-align:center;padding:10px;color:#777;font-size:12px;margin-top:20px}
	cHtml += '     </style>
	cHtml += ' </head>
	cHtml += ' <body>
	cHtml += '     <div class="container">
	cHtml += '         <div class="header">
	cHtml += '             <h1>Produto Alterado!</h1></div>
	cHtml += '         <div class="content">
	cHtml += '             <p>Olá, Tudo bem?</p>
	cHtml += '             <p>Informamos que ocorreram alterações no Produto <strong>@@CODIGO_PRODUTO@@</strong> - <strong>@@DESCRICAO@@</strong>.</p>
	
	If nTipo = 1
		cHtml += '             <p>O mesmo foi bloqueado.</p>
	Else
		cHtml += '             <p>O mesmo já está liberado para a atualização dos dados .</p>
	endif
	
	cHtml += '             <p>Caso precise de mais informações, estamos à disposição.</p><a href="@@URL_WHATS@@" class="cta">Iniciar Conversa</a>
	cHtml += '             <br>
	cHtml += '             <br>
	cHtml += '             <p>Atenciosamente,</p>
	cHtml += '             <p>Equipe de Cadastro Cogny CSC</p>
	cHtml += '         </div>
	cHtml += '         <div class="footer">
	cHtml += '             <p>Este é um e-mail automático, por favor, não responda.</p>
	cHtml += '         </div>
	cHtml += '     </div>
	cHtml += ' </body>
	cHtml += ' </html>

Return cHtml

Static Function EnvIntMerc(cFrom, cTos, cSubject, cBody, aFile, cAssinatura, cCopia, cCopiaOculta)
	Local cServer        := GETMV("MV_RELSERV") // Nome do servidor de envio de e-mail utilizado nos relatórios
	Local cAccount       := GETMV("MV_RELACNT") // Conta a ser utilizada no envio de e-mail para os relatórios
	Local cPassword      := GETMV("MV_RELPSW")  // Senha da conta de e-mail para envio de relatórios
	Local lAuth          := GETMV("MV_RELAUTH") // Servidor de EMAIL necessita de Autenticacão?
	Local lAutSSL        := GetMv("MV_RELSSL")  // Define se o envio e recebimento de e-mails utilizará conexão segura (SSL).
	Local lAutTLS        := GetMv("MV_RELTLS")  // Informe se o servidor de SMTP possui conexão do tipo segura ( SSL/TLS ).
	Local iCount         := 0
	Local nPortaSMTP     := 0
	Local oMail          := Nil
	Default aFile        := {}
	Default cAssinatura  := ""
	Default cCopia       := ""
	Default cCopiaOculta := ""

	oMail      := TMailManager():New()
	nPortaSMTP := Val( SubStr(cServer, RAT(":", cServer)+1) )
	cServer    := SubStr(cServer, 1, RAT(":", cServer)-1)
	If lAuth
		oMail:SetUseSSL(lAutSSL)
		oMail:SetUseTLS(lAutTLS)
	EndIf
	nret := oMail:Init( "", cServer, cAccount, cPassword, 0,  nPortaSMTP)
	If nRet <> 0
		ConOut("Erro na Função EnvIntMerc - Envia e-mail -> " + oMail:GetErrorString( nRet ))
		Return .F.
	Endif
	nret := oMail:SetSMTPTimeout( 60 ) //1 min
	If nRet <> 0
		ConOut("Erro na Função EnvIntMerc - Envia e-mail -> " + oMail:GetErrorString( nRet ))
		Return .F.
	Endif
	nret := oMail:SMTPConnect()
	If nRet <> 0
		ConOut("Erro na Função EnvIntMerc - Envia e-mail -> " + oMail:GetErrorString( nret ))
		Return .F.
	Endif
	If lAuth
		nErro := oMail:SmtpAuth( cAccount, cPassword )
		If nErro <> 0
			ConOut("Erro na Função EnvIntMerc - Envia e-mail -> " + oMail:GetErrorString( nErro ))
			oMail:SMTPDisconnect()
			Return .F.
		Endif
	EndIf
	oMessage          := TMailMessage():New()
	oMessage:Clear()
	oMessage:cFrom    := cFrom
	oMessage:cTo      := cTos
	oMessage:cCc      := cCopia
	oMessage:cBCc     := cCopiaOculta
	oMessage:cSubject := cSubject
	oMessage:cBody    := cBody
	For iCount := 1 To Len(aFile)
		If !Empty(aFile[iCount]) .And. oMessage:AttachFile( AllTrim(aFile[iCount]) ) < 0
			return .F.
		Endif
	Next
	If !Empty(cAssinatura)
		oMessage:AddAttHTag( "Content-Disposition: attachment; filename=" + AllTrim(cAssinatura) )
	EndIf
	nErro := oMessage:Send( oMail )
	If nErro <> 0
		ConOut("Erro na Função EnvIntMerc - Envia e-mail -> " + oMail:GetErrorString( nErro ))
		oMail:SMTPDisconnect()
		Return .F.
	Endif
	nRet := oMail:SmtpDisconnect()
Return .T.

