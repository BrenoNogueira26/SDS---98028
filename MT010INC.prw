#include "protheus.ch"
#include "fwmvcdef.ch"

/*/{Protheus.doc} mt010inc
PE chamado após a inclusão do produto
@type function
@version P12
@author Não informado
@since 05/08/2023
@see https://tdn.totvs.com/pages/releaseview.action?pageId=6087685
/*/
User Function mt010inc()
	Local cCodusr as Character
	Local cFrom	as Character
	Local cTos	as Character
	Local cCopia as Character
	Local cSubject as Character
	Local cBody as Character
	Local lEnviado as Character
	Local aFile as Character
	Local cAssinatura as Character
	Local cCopiaOculta as Character
	Local lGrpIM := SuperGetMv("CG_GRPIM",.F.,"0108;1200;1208")

	//m->b1_contas := ''
	cCodusr := retcodusr()
	If  !cCodUsr$GETMV("MV_DEPCAD")

		// RETIRADO DO CÓDIGO, POIS ESTÁ FAZENDO O MESMO QUE O UPDATE ABAIXO.
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
		cQry += " B1_MSBLQL = '1' , B1_USER = '" + UsrRetName(cCodusr) + "' "
		cQry += " WHERE "
		cQry += " B1_COD =  '" + SB1->B1_COD + "' "
		cQry += " AND D_E_L_E_T_ = ' ' "

		If (TCSQLExec(cQry) < 0)
			lRetOK   := .F.
			cMsgErr  := "TCSQLError() " + TCSQLError()
		endIf

	ELSE
		msginfo('Informar Contas Contábeis na Rotina de Alteração...!!')
		If Reclock("SB1",.F.)
			SB1->B1_USER 	:= ''
			//SB1->B1_CONTAS 	:= ''
			MsUnlock("SB1")
		ENDIF
	endif

	/*Desenvolvedor: Bruno Davantel Valarini
	Chama a rotina para replicar os dados da F2Q (Complemento Fiscal)
	 */
	u_REPLIF2Q()

	If Alltrim(M->B1_GRUPO) $ SuperGetMv("CG_GRPREG",.F.,"0111;0113;0114;1211;1214;1217")

		cFrom    := SuperGetMv("MV_RELACNT",.F.,"notificacoes@cognycsc.com.br")
		cTos     := SuperGetMv("CG_EMAILREG",.F.,"carlos.silva@cognycsc.com.br")
		cCopia   := "cadastros@cognycsc.com.br"
		cSubject := "Inclusão de Produto Defensivo em " + cValToChar(FWTimeStamp(2))

		cBody    := BodyEmailDef()

		cBody    := StrTran(cBody,"@@CODIGO_PRODUTO@@", AllTrim(M->B1_COD))
		cBody    := StrTran(cBody,"@@DESCRICAO@@",AllTrim(M->B1_DESC))
		cBody    := StrTran(cBody,"@@URL_WHATS@@","https://wa.me/554192738358")
		lEnviado := EnvEmailDefensivos(cFrom, cTos, cSubject, cBody, aFile, cAssinatura, cCopia, cCopiaOculta)
	EndIf

	If !Alltrim(M->B1_GRUPO) $ lGrpIM
		If Alltrim(M->B1_TIPO)='PA' .or. Alltrim(M->B1_TIPO)='ME'
			cFrom    := SuperGetMv("MV_RELACNT",.F.,"notificacoes@cognycsc.com.br")
			cTos     := SuperGetMv("CG_EMAILIM",.F.,"breno.nogueira@cognycsc.com.br")
			cSubject := "Inclusão de Produto..:" + cValToChar(FWTimeStamp(2))
			cBody    := ""
			cBody    := BodyEmailIM()
			cBody    := StrTran(cBody,"@@CODIGO_PRODUTO@@", AllTrim(M->B1_COD))
			cBody    := StrTran(cBody,"@@DESCRICAO@@",AllTrim(M->B1_DESC))
			cBody    := StrTran(cBody,"@@URL_WHATS@@","https://wa.me/554192738358")
			lEnviado := EnvIntMerc(cFrom, cTos, cSubject, cBody, aFile, cAssinatura, cCopia, cCopiaOculta)

		endif
	endif

return
//__________________________________________________________________________________________________________________________________///

/*/{Protheus.doc} BodyEmailAtivo
    Função responsvel para criar o html de clientes inativos.
    @type  Function
    @author Jonivani Pereira
    @since 20/08/2024
    @version 2310
/*/

Static Function BodyEmailDef
	Local cHtml as Character
	//cHtml := '<!DOCTYPE html><html lang="pt-BR"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Notificação de Ativação de Cliente</title><style>body{font-family:Arial,sans-serif;background-color:#f4f4f4;margin:0;padding:0;color:#333}.container{width:100%;max-width:800px;margin:0 auto;background-color:#fff;padding:20px;border-radius:8px;box-shadow:0 0 10px rgba(0,0,0,.1)}.header{background-color:#d4b404;color:#fff;padding:10px 20px;border-radius:8px 8px 0 0;text-align:center}.header h1{margin:0;font-size:24px}.content{padding:20px}.content p{font-size:16px;line-height:1.5;margin-bottom:20px}.content .cta{background-color:#25d366;color:#fff;padding:10px;border-radius:5px;text-align:center;text-decoration:none;display:inline-block;margin-top:20px;font-size:18px}.footer{text-align:center;padding:10px;color:#777;font-size:12px;margin-top:20px}</style></head><body><div class="container"><div class="header"><h1>Novo Produto Defensivo!</h1></div><div class="content"><p>Olá, Tudo bem?</p><p>Incluimos um novo Produto Defensivo <strong>@@CODIGO_PRODUTO@@</strong> - <strong>@@DESCRICAO@@</strong>.</p><p>O mesmo já está liberado para a atualização dos dados no INDEA.</p><p>Caso precise de mais informações, estamos à disposição.</p><a href="@@URL_WHATS@@" class="cta">Iniciar Conversa</a><br><br><p>Atenciosamente,</p><p>Equipe de Cadastro Cogny CSC</p></div><div class="footer"><p>Este é um e-mail automático, por favor, não responda.</p></div></div></body></html>'

	cHtml := '	<!DOCTYPE html>
	cHtml += '<html lang="pt-BR">
	cHtml += '<head>
	cHtml += '    <meta charset="UTF-8">
	cHtml += '    <meta name="viewport" content="width=device-width,initial-scale=1">
	cHtml += '    <title>Notificação de Ativação de Cliente</title>
	cHtml += '    <style>
	cHtml += '        body{font-family:Arial,sans-serif;background-color:#f4f4f4;margin:0;padding:0;color:#333}.container{width:100%;max-width:800px;margin:0 auto;background-color:#fff;padding:20px;border-radius:8px;box-shadow:0 0 10px rgba(0,0,0,.1)}.header{background-color:#d4b404;color:#fff;padding:10px 20px;border-radius:8px 8px 0 0;text-align:center}.header h1{margin:0;font-size:24px}.content{padding:20px}.content p{font-size:16px;line-height:1.5;margin-bottom:20px}.content .cta{background-color:#25d366;color:#fff;padding:10px;border-radius:5px;text-align:center;text-decoration:none;display:inline-block;margin-top:20px;font-size:18px}.footer{text-align:center;padding:10px;color:#777;font-size:12px;margin-top:20px}
	cHtml += '    </style>
	cHtml += '</head>
	cHtml += '<body>
	cHtml += '    <div class="container">
	cHtml += '        <div class="header">
	cHtml += '            <h1>Novo Produto Defensivo!</h1></div>
	cHtml += '        <div class="content">
	cHtml += '            <p>Olá, Tudo bem?</p>
	cHtml += '            <p>Incluimos um novo Produto Defensivo <strong>@@CODIGO_PRODUTO@@</strong> - <strong>@@DESCRICAO@@</strong>.</p>
	cHtml += '            <p>O mesmo já está liberado para a atualização dos dados no INDEA.</p>
	cHtml += '            <p>Caso precise de mais informações, estamos à disposição.</p><a href="@@URL_WHATS@@" class="cta">Iniciar Conversa</a>
	cHtml += '            <br>
	cHtml += '            <br>
	cHtml += '            <p>Atenciosamente,</p>
	cHtml += '            <p>Equipe de Cadastro Cogny CSC</p>
	cHtml += '        </div>
	cHtml += '        <div class="footer">
	cHtml += '            <p>Este é um e-mail automático, por favor, não responda.</p>
	cHtml += '        </div>
	cHtml += '    </div>
	cHtml += '</body>
	cHtml += '</html>

Return cHtml

Static Function BodyEmailIM()
	Local cHtml as Character

	cHtml := ' <!DOCTYPE html>
	cHtml += ' <html lang="pt-BR">
	cHtml += ' <head>
	cHtml += '     <meta charset="UTF-8">
	cHtml += '     <meta name="viewport" content="width=device-width,initial-scale=1">
	cHtml += '     <title>Notificação de Inclusão de Produto</title>
	cHtml += '     <style>
	cHtml += '         body{font-family:Arial,sans-serif;background-color:#f4f4f4;margin:0;padding:0;color:#333}.container{width:100%;max-width:800px;margin:0 auto;background-color:#fff;padding:20px;border-radius:8px;box-shadow:0 0 10px rgba(0,0,0,.1)}.header{background-color:#d4b404;color:#fff;padding:10px 20px;border-radius:8px 8px 0 0;text-align:center}.header h1{margin:0;font-size:24px}.content{padding:20px}.content p{font-size:16px;line-height:1.5;margin-bottom:20px}.content .cta{background-color:#25d366;color:#fff;padding:10px;border-radius:5px;text-align:center;text-decoration:none;display:inline-block;margin-top:20px;font-size:18px}.footer{text-align:center;padding:10px;color:#777;font-size:12px;margin-top:20px}
	cHtml += '     </style>
	cHtml += ' </head>
	cHtml += ' <body>
	cHtml += '     <div class="container">
	cHtml += '         <div class="header">
	cHtml += '             <h1>Novo Produto Incluído!</h1></div>
	cHtml += '         <div class="content">
	cHtml += '             <p>Olá, Tudo bem?</p>
	cHtml += '             <p>Incluimos um novo Produto <strong>@@CODIGO_PRODUTO@@</strong> - <strong>@@DESCRICAO@@</strong>.</p>
	cHtml += '             <p>O mesmo já está liberado para a atualização dos dados .</p>
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

/*/{Protheus.doc} EnvEmailDefensivos
    Função para enviar e-mail para equipe do regulatório 
    @type  Function
    @author Jonivani Pereira
    @since 20/08/2024
    @version 2310
/*/
Static Function EnvEmailDefensivos(cFrom, cTos, cSubject, cBody, aFile, cAssinatura, cCopia, cCopiaOculta)
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

	// Cria o Servidor para disparo de e-mail
	oMail      := TMailManager():New()
	nPortaSMTP := Val( SubStr(cServer, RAT(":", cServer)+1) )
	cServer    := SubStr(cServer, 1, RAT(":", cServer)-1)

	If lAuth
		oMail:SetUseSSL(lAutSSL)
		oMail:SetUseTLS(lAutTLS)
	EndIf

	// Inicia a Conexão
	nret := oMail:Init( "", cServer, cAccount, cPassword, 0,  nPortaSMTP)

	If nRet <> 0
		ConOut("Erro na Função EnvEmailCliInativos - Envia e-mail -> " + oMail:GetErrorString( nRet ))
		Return .F.
	Endif

	// Define Time Out
	nret := oMail:SetSMTPTimeout( 60 ) //1 min

	If nRet <> 0
		ConOut("Erro na Função EnvEmailCliInativos - Envia e-mail -> " + oMail:GetErrorString( nRet ))
		Return .F.
	Endif

	//Conecta no Servidor
	nret := oMail:SMTPConnect()
	If nRet <> 0
		ConOut("Erro na Função EnvEmailCliInativos - Envia e-mail -> " + oMail:GetErrorString( nret ))
		Return .F.
	Endif

	If lAuth
		// Realiza a Autenticação do Usuário e senha
		nErro := oMail:SmtpAuth( cAccount, cPassword )
		If nErro <> 0
			ConOut("Erro na Função EnvEmailCliInativos - Envia e-mail -> " + oMail:GetErrorString( nErro ))
			oMail:SMTPDisconnect()
			Return .F.
		Endif
	EndIf


	// Verificação de ambiente para envio de e-mail(Para testes)
	If  "HML" $ Alltrim( Upper( getEnvServer( ) ) ) .Or. ;
			"MIGRA" $ Alltrim( Upper( getEnvServer( ) ) ) .Or.;
			"DEV" $ Alltrim( Upper( getEnvServer( ) ) ) .Or.;
			"TESTE" $ Alltrim( Upper( getEnvServer( ) ) ) //Ambiente de Homologação
		cTos         := "jonivani.pereira@cognycsc.com.br;daiane.matheus@cognycsc.com.br"
		cCopia       := "carlos.silva@cognycsc.com.br;Gustavo.lopes@cognycsc.com.br"
		// cCopiaOculta := ""
		cSubject     := "Homologação " + cSubject
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

	//Envia a mensagem
	nErro := oMessage:Send( oMail )
	If nErro <> 0
		ConOut("Erro na Função EnvEmailCliInativos - Envia e-mail -> " + oMail:GetErrorString( nErro ))
		oMail:SMTPDisconnect()
		Return .F.
	Endif

	// Disconecta do Servidor
	nRet := oMail:SmtpDisconnect()

Return .T.

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

	// Cria o Servidor para disparo de e-mail
	oMail      := TMailManager():New()
	nPortaSMTP := Val( SubStr(cServer, RAT(":", cServer)+1) )
	cServer    := SubStr(cServer, 1, RAT(":", cServer)-1)

	If lAuth
		oMail:SetUseSSL(lAutSSL)
		oMail:SetUseTLS(lAutTLS)
	EndIf

	// Inicia a Conexão
	nret := oMail:Init( "", cServer, cAccount, cPassword, 0,  nPortaSMTP)

	If nRet <> 0
		ConOut("Erro na Função EnvIntMerc - Envia e-mail -> " + oMail:GetErrorString( nRet ))
		Return .F.
	Endif

	// Define Time Out
	nret := oMail:SetSMTPTimeout( 60 ) //1 min

	If nRet <> 0
		ConOut("Erro na Função EnvIntMerc - Envia e-mail -> " + oMail:GetErrorString( nRet ))
		Return .F.
	Endif

	//Conecta no Servidor
	nret := oMail:SMTPConnect()
	If nRet <> 0
		ConOut("Erro na Função EnvIntMerc - Envia e-mail -> " + oMail:GetErrorString( nret ))
		Return .F.
	Endif

	If lAuth
		// Realiza a Autenticação do Usuário e senha
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

	//Envia a mensagem
	nErro := oMessage:Send( oMail )
	If nErro <> 0
		ConOut("Erro na Função EnvIntMerc - Envia e-mail -> " + oMail:GetErrorString( nErro ))
		oMail:SMTPDisconnect()
		Return .F.
	Endif

	// Disconecta do Servidor
	nRet := oMail:SmtpDisconnect()

Return .T.
