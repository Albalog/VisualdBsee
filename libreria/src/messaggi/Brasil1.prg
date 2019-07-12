// *****************************************************************************
// Copyright (C) ISA - Italian Software Agency
//                   - Tradu��o Di�c. C.J.Moretti
// Descri��o: Biblioteca de Mensagens
// *****************************************************************************
#include "dfMsg1.ch"

// Attenzione: questo file usa il character set ANSI
//             deve essere modificato con un editor WINDOWS
//             (notepad, editpad ecc.)
//
// #pragma necessario per gestire caratteri 
// brasiliani tipo "a" con il "~" sopra
#pragma Ansi2Oem(ON)

* =============================================================================
FUNCTION dfStdMsg1( nMsg )
* =============================================================================
LOCAL cMsg := ""
DO CASE
   // .........................................................................
   CASE nMsg == MSG1_LANGUAGE       ; cMsg := "BRASIL"
   // .........................................................................
   // .........................................................................
   CASE nMsg == MSG1_INITAPPS01     ; cMsg := "Encontrado dbupdate.log !!"
   CASE nMsg == MSG1_INITAPPS02     ; cMsg := "Aplica��o sob atualiza��o"
   CASE nMsg == MSG1_INITAPPS03     ; cMsg := "Por favor tente mais tarde"
   CASE nMsg == MSG1_INITAPPS04     ; cMsg := "Bootstrap segundos : "
   // .........................................................................
   // .........................................................................
   CASE nMsg == MSG1_DBINK01        ; cMsg := "Vo�e tem "
   CASE nMsg == MSG1_DBINK02        ; cMsg := " segundos para sair"
   CASE nMsg == MSG1_DBINK03        ; cMsg := "Segundos : "
   // .........................................................................
   // .........................................................................
   CASE nMsg == MSG1_TBBRWNEW36     ; cMsg := "Imprimir a tela"
   // .........................................................................
   // .........................................................................
   CASE nMsg == MSG1_DFDBFNTX01     ; cMsg := "Database engine DBFDBE n�o est� carregado"
   CASE nMsg == MSG1_DFDBFNTX02     ; cMsg := "Database engine NTXDBE n�o est� carregado"
   CASE nMsg == MSG1_DFDBFNTX03     ; cMsg := "DBFNTX database engine n�o pode ser criado"
   // .........................................................................
   // .........................................................................
   CASE nMsg == MSG1_DFDBFCDX01     ; cMsg := "Database engine FOXDBE n�o est� carregado"
   CASE nMsg == MSG1_DFDBFCDX02     ; cMsg := "Database engine CDXDBE n�o est� carregado"
   CASE nMsg == MSG1_DFDBFCDX03     ; cMsg := "DBFCDX database engine n�o pode ser criado"
   // .........................................................................
   // .........................................................................
   CASE nMsg == MSG1_S2GETMEN01     ; cMsg := "&Cancelar"
   CASE nMsg == MSG1_S2GETMEN02     ; cMsg := "&Recortar"
   CASE nMsg == MSG1_S2GETMEN03     ; cMsg := "C&opiar"
   CASE nMsg == MSG1_S2GETMEN04     ; cMsg := "Co&lar"
   CASE nMsg == MSG1_S2GETMEN05     ; cMsg := "&Apagar"
   // .........................................................................
   // .........................................................................
   CASE nMsg == MSG1_DFPRNMENU01    ; cMsg := "Fon^te"
   CASE nMsg == MSG1_DFPRNMENU02    ; cMsg := "Impressora n�o v�lida"
   CASE nMsg == MSG1_DFPRNMENU03    ; cMsg := "P�gina"
   CASE nMsg == MSG1_DFPRNMENU04    ; cMsg := "Ver p�gina "
   CASE nMsg == MSG1_DFPRNMENU05    ; cMsg := "Impressora n�o definida!"
   CASE nMsg == MSG1_DFPRNMENU06    ; cMsg := "Imprime p�gina "
   CASE nMsg == MSG1_DFPRNMENU07    ; cMsg := "Espere..."
   CASE nMsg == MSG1_DFPRNMENU08    ; cMsg := "It is necessary to install a printer in the system"
   CASE nMsg == MSG1_DFPRNMENU09    ; cMsg := "No property to set"

   // .........................................................................
   // .........................................................................
   CASE nMsg == MSG1_DFMAILCO01     ; cMsg := "^Para:"
   CASE nMsg == MSG1_DFMAILCO02     ; cMsg := "Enviar para"
   CASE nMsg == MSG1_DFMAILCO03     ; cMsg := "^CC:"
   CASE nMsg == MSG1_DFMAILCO04     ; cMsg := "Enviar CC"
   CASE nMsg == MSG1_DFMAILCO05     ; cMsg := "^BCC:"
   CASE nMsg == MSG1_DFMAILCO06     ; cMsg := "Enviar BCC"
   CASE nMsg == MSG1_DFMAILCO07     ; cMsg := "Ass^unto:"
   CASE nMsg == MSG1_DFMAILCO08     ; cMsg := "Assunto da mensagem"
   CASE nMsg == MSG1_DFMAILCO09     ; cMsg := "^Texto"
   CASE nMsg == MSG1_DFMAILCO10     ; cMsg := "Texto da mensagem"
   CASE nMsg == MSG1_DFMAILCO11     ; cMsg := "^Enviar"
   CASE nMsg == MSG1_DFMAILCO12     ; cMsg := "^Arquivos anexos"
   CASE nMsg == MSG1_DFMAILCO13     ; cMsg := "Inserir arquivo em anexo"
   CASE nMsg == MSG1_DFMAILCO14     ; cMsg := "Apagar arquivo em anexo"
   CASE nMsg == MSG1_DFMAILCO15     ; cMsg := "Mensagem"
   CASE nMsg == MSG1_DFMAILCO16     ; cMsg := "Anexar arquivos"
   CASE nMsg == MSG1_DFMAILCO17     ; cMsg := "O assunto n�o foi especificado//Enviar a mensagem?"
   CASE nMsg == MSG1_DFMAILCO18     ; cMsg := "Favor informar um endere�o de eMail v�lido."
   // .........................................................................
   // .........................................................................
   CASE nMsg == MSG1_DFGETW01       ; cMsg := "Pedido"
   // .........................................................................
   // .........................................................................
   CASE nMsg == MSG1_S2PI01         ; cMsg := "Parar ?"
   CASE nMsg == MSG1_S2PI02         ; cMsg := "Cancelar"
   CASE nMsg == MSG1_S2PI03         ; cMsg := "Espere"
   CASE nMsg == MSG1_S2PI04         ; cMsg := "Favor esperar..."
   // .........................................................................
   // .........................................................................
   CASE nMsg == MSG1_S2CALENDAR01   ; cMsg := "Calend�rio"
   CASE nMsg == MSG1_S2CALENDAR02   ; cMsg := "Hoje"
   CASE nMsg == MSG1_S2CALENDAR03   ; cMsg := "Sa�da"
   // .........................................................................
   // .........................................................................
   CASE nMsg == MSG1_S2PRNMNU01     ; cMsg := "Menu impress�o"
   CASE nMsg == MSG1_S2PRNMNU02     ; cMsg := "&Filtro"
   CASE nMsg == MSG1_S2PRNMNU03     ; cMsg := "Visuali&za��o"
   CASE nMsg == MSG1_S2PRNMNU04     ; cMsg := "&Imprimir"
   CASE nMsg == MSG1_S2PRNMNU05     ; cMsg := "&Cancelar"
   CASE nMsg == MSG1_S2PRNMNU06     ; cMsg := "Op��o impress�o"
   CASE nMsg == MSG1_S2PRNMNU07     ; cMsg := "&Dispositivos"
   CASE nMsg == MSG1_S2PRNMNU08     ; cMsg := "Fonte"
   CASE nMsg == MSG1_S2PRNMNU09     ; cMsg := "Normal"
   CASE nMsg == MSG1_S2PRNMNU10     ; cMsg := "Compactar"
   CASE nMsg == MSG1_S2PRNMNU11     ; cMsg := "Pa&ginas"
   CASE nMsg == MSG1_S2PRNMNU12     ; cMsg := "&Margens"
   CASE nMsg == MSG1_S2PRNMNU13     ; cMsg := "Impress�o dispositivos n. "
   // .........................................................................
   // .........................................................................
   CASE nMsg == MSG1_S2PDISWP01     ; cMsg := "Windows Impressoras"
   CASE nMsg == MSG1_S2PDISWP02     ; cMsg := "Impress�o &on"
   CASE nMsg == MSG1_S2PDISWP03     ; cMsg := "&Propiedades"
   CASE nMsg == MSG1_S2PDISWP04     ; cMsg := "&Set fonte"
   CASE nMsg == MSG1_S2PDISWP05     ; cMsg := "&Formato papel"
   CASE nMsg == MSG1_S2PDISWP06     ; cMsg := "A&limenta��o"
   CASE nMsg == MSG1_S2PDISWP07     ; cMsg := "Copi&as"
   CASE nMsg == MSG1_S2PDISWP08     ; cMsg := "N�o h� impressoras instalada"
   CASE nMsg == MSG1_S2PDISWP09     ; cMsg := "(desconhecido)"
   CASE nMsg == MSG1_S2PDISWP10     ; cMsg := "Incapaz de imprimir//"
   CASE nMsg == MSG1_S2PDISWP11     ; cMsg := "//Erro acessando driver da impressora"
   CASE nMsg == MSG1_S2PDISWP12     ; cMsg := "%printer% em %name%"
   // ........................................................................
   // ........................................................................
   CASE nMsg == MSG1_S2PDIS01       ; cMsg := "Dispositivo gen�rico impress�o"
   // .........................................................................
   // .........................................................................
   CASE nMsg == MSG1_S2PDISCL01     ; cMsg := "Impress�o para Clipboard"
   // .........................................................................
   // .........................................................................
   CASE nMsg == MSG1_S2PDISPR01     ; cMsg := "Visualiza��o da impress�o"
   CASE nMsg == MSG1_S2PDISPR02     ; cMsg := "Incapaz de usar impressora//"
   CASE nMsg == MSG1_S2PDISPR03     ; cMsg := "//Erro acessando drive da impressora"
   CASE nMsg == MSG1_S2PDISPR04     ; cMsg := "(desconhecido)"
   // .........................................................................
   // .........................................................................
   CASE nMsg == MSG1_S2PDISFI01     ; cMsg := "Impress�o para arquivo"
   CASE nMsg == MSG1_S2PDISFI02     ; cMsg := "&Nome arquivo"
   CASE nMsg == MSG1_S2PDISFI03     ; cMsg := "&Folhar"
   CASE nMsg == MSG1_S2PDISFI04     ; cMsg := "Criar arquivo"
   CASE nMsg == MSG1_S2PDISFI05     ; cMsg := "Selecionar arquivo &Type"
   CASE nMsg == MSG1_S2PDISFI06     ; cMsg := "Abrir arquivo"
   CASE nMsg == MSG1_S2PDISFI07     ; cMsg := "Dire��o de impress�o"
   CASE nMsg == MSG1_S2PDISFI08     ; cMsg := "Erro na gera��o do arquivo Pdf"
   CASE nMsg == MSG1_S2PDISFI09     ; cMsg := "Vertical"
   CASE nMsg == MSG1_S2PDISFI10     ; cMsg := "Horizontal"
   CASE nMsg == MSG1_S2PDISFI11     ; cMsg := "Impress�o Pdf terminada"
   CASE nMsg == MSG1_S2PDISFI12     ; cMsg := "Nome de arquivo obrigat�rio"
   CASE nMsg == MSG1_S2PDISFI13     ; cMsg := "Collate"

   // .........................................................................
   // .........................................................................
   CASE nMsg == MSG1_S2PDISMF01     ; cMsg := "Impress�o para FAX (MAPI)"
   CASE nMsg == MSG1_S2PDISMF02     ; cMsg := "N�mero &telefone"
   CASE nMsg == MSG1_S2PDISMF03     ; cMsg := "N�mero Fax n�o especificado"
   CASE nMsg == MSG1_S2PDISMF04     ; cMsg := "Enviando FAX...//"
   CASE nMsg == MSG1_S2PDISMF05     ; cMsg := "Impress�o"
   CASE nMsg == MSG1_S2PDISMF06     ; cMsg := "Veja arquivo anexo"
   CASE nMsg == MSG1_S2PDISMF07     ; cMsg := "Erro enviando Fax:"
   CASE nMsg == MSG1_S2PDISMF08     ; cMsg := "Erro na gera��o do arquivo Pdf-Fax"
   CASE nMsg == MSG1_S2PDISMF09     ; cMsg := "Fax menssagem..."
   CASE nMsg == MSG1_S2PDISMF10     ; cMsg := "Orienta��o da p�gina:"
   CASE nMsg == MSG1_S2PDISMF11     ; cMsg := "Formato da &P�gina:"
   CASE nMsg == MSG1_S2PDISMF12     ; cMsg := "Mainta&in Image,Border and Boldface"
   CASE nMsg == MSG1_S2PDISMF13     ; cMsg := "Fax assunto:"
   CASE nMsg == MSG1_S2PDISMF14     ; cMsg := "Fax corpo:"
   CASE nMsg == MSG1_S2PDISMF15     ; cMsg := "Mapi Fax enviado"
   CASE nMsg == MSG1_S2PDISMF16     ; cMsg := "Os seguintes campos est�o vazios. Enviar Fax?"
   // .........................................................................
   // .........................................................................
   CASE nMsg == MSG1_S2PDISMM01     ; cMsg := "Impress�o para eMail (MAPI)"
   CASE nMsg == MSG1_S2PDISMM02     ; cMsg := "Endere�o de &eMail"
   CASE nMsg == MSG1_S2PDISMM03     ; cMsg := "Endere�o de eMail n�o especificado"
   CASE nMsg == MSG1_S2PDISMM04     ; cMsg := "Enviando mensagem...//"
   CASE nMsg == MSG1_S2PDISMM05     ; cMsg := "Impress�o"
   CASE nMsg == MSG1_S2PDISMM06     ; cMsg := "Veja arquivo anexo"
   CASE nMsg == MSG1_S2PDISMM07     ; cMsg := "Erro enviando eMail:"
   CASE nMsg == MSG1_S2PDISMM08     ; cMsg := "Mapi eMail enviado"
   CASE nMsg == MSG1_S2PDISMM09     ; cMsg := "arquivo &ZIP"
   CASE nMsg == MSG1_S2PDISMM10     ; cMsg := "arquivo zip: %file%"
   // .........................................................................
   // .........................................................................
   CASE nMsg == MSG1_S2PDISSM01     ; cMsg := "Impress�o para eMail (SMTP)"
   CASE nMsg == MSG1_S2PDISSM02     ; cMsg := "Endere�o de &eMail"
   CASE nMsg == MSG1_S2PDISSM03     ; cMsg := "Endere�o de eMail n�o especificado"
   CASE nMsg == MSG1_S2PDISSM04     ; cMsg := "Servidor SMTP n�o foi especificado (XBaseSMTPServer)"
   CASE nMsg == MSG1_S2PDISSM05     ; cMsg := "Remetente eMail n�o foi especificado (XBaseSMTPFrom)"
   CASE nMsg == MSG1_S2PDISSM06     ; cMsg := "Enviando message...//"
   CASE nMsg == MSG1_S2PDISSM07     ; cMsg := "Impress�o"
   CASE nMsg == MSG1_S2PDISSM08     ; cMsg := "Veja arquivo anexo"
   CASE nMsg == MSG1_S2PDISSM09     ; cMsg := "Erro enviando E-Mail:"
   CASE nMsg == MSG1_S2PDISSM10     ; cMsg := "Assunto:"
   CASE nMsg == MSG1_S2PDISSM11     ; cMsg := "Corpo do eMail:"
   CASE nMsg == MSG1_S2PDISSM12     ; cMsg := "Smtp eMail enviado"
   CASE nMsg == MSG1_S2PDISSM13     ; cMsg := "Os seguintes campos est�o vazios. Enviar eMail?"
   // .........................................................................
   // .........................................................................
   CASE nMsg == MSG1_S2PDISDP01     ; cMsg := "DOS Impressoras"
   CASE nMsg == MSG1_S2PDISDP02     ; cMsg := "Impress�o &on"
   CASE nMsg == MSG1_S2PDISDP03     ; cMsg := "Porta &Impressora"
   CASE nMsg == MSG1_S2PDISDP04     ; cMsg := "Qualidade"
   CASE nMsg == MSG1_S2PDISDP05     ; cMsg := "N&ormal"
   CASE nMsg == MSG1_S2PDISDP06     ; cMsg := "&Alto"
   CASE nMsg == MSG1_S2PDISDP07     ; cMsg := "Setup"
   CASE nMsg == MSG1_S2PDISDP08     ; cMsg := "Use Setup &1"
   CASE nMsg == MSG1_S2PDISDP09     ; cMsg := "Use Setup &2"
   CASE nMsg == MSG1_S2PDISDP10     ; cMsg := "Use Setup &3"
   CASE nMsg == MSG1_S2PDISDP11     ; cMsg := "Copia&s"
   CASE nMsg == MSG1_S2PDISDP12     ; cMsg := "N�o h� impressora instalada"
   // .........................................................................
   // .........................................................................
   CASE nMsg == MSG1_DFWINPRN01     ; cMsg := "Set Fonte "
   // .........................................................................
   // .........................................................................
   CASE nMsg == MSG1_DFWINPRD01     ; cMsg := "Normal"
   CASE nMsg == MSG1_DFWINPRD02     ; cMsg := "Set"
   CASE nMsg == MSG1_DFWINPRD03     ; cMsg := "Normal Fonte"
   CASE nMsg == MSG1_DFWINPRD04     ; cMsg := "Bold Fonte"
   CASE nMsg == MSG1_DFWINPRD05     ; cMsg := "Compactado Fonte"
   CASE nMsg == MSG1_DFWINPRD06     ; cMsg := "Bold Compactado Fonte"
   CASE nMsg == MSG1_DFWINPRD07     ; cMsg := "&Ok"
   CASE nMsg == MSG1_DFWINPRD08     ; cMsg := "&Cancelar"
   // .........................................................................
   // .........................................................................
   CASE nMsg == MSG1_DBMSGERR01     ; cMsg := "Erro"
   // .........................................................................
   // .........................................................................
   CASE nMsg == MSG1_DFALERT01      ; cMsg := "Cuidado"
   // .........................................................................
   // .........................................................................
   CASE nMsg == MSG1_DFYESNO01      ; cMsg := "Pedido"
   // .........................................................................
   // .........................................................................
   CASE nMsg == MSG1_S2PDISCP01     ; cMsg := "Windows Impressora"
   CASE nMsg == MSG1_S2PDISCP02     ; cMsg := "Arquivo n�o encontrado: "
   CASE nMsg == MSG1_S2PDISCP03     ; cMsg := "Arquivo criado: "
   CASE nMsg == MSG1_S2PDISCP04     ; cMsg := "Erro carregando Crystal Report Print Engine (CRPE32.DLL)"
   CASE nMsg == MSG1_S2PDISCP05     ; cMsg := "Erro na impress�o: "
   // .........................................................................
   // .........................................................................
   CASE nMsg == MSG1_S2PDISCV01     ; cMsg := "Visualiza��o"
   CASE nMsg == MSG1_S2PDISCV02     ; cMsg := "Arquivo n�o encontrado: "
   CASE nMsg == MSG1_S2PDISCV03     ; cMsg := "Arquivo n�o criado: "
   CASE nMsg == MSG1_S2PDISCV04     ; cMsg := "Erro carregando Crystal Report Print Engine (CRPE32.DLL)"
   CASE nMsg == MSG1_S2PDISCV05     ; cMsg := "Erro na visualiza��o: "
   // .........................................................................
   // .........................................................................
   CASE nMsg == MSG1_S2PDISCF01     ; cMsg := "Impress�o para arquivo"
   CASE nMsg == MSG1_S2PDISCF02     ; cMsg := "Arquivo n�o encontrado: "
   CASE nMsg == MSG1_S2PDISCF03     ; cMsg := "Arquivo criado: "
   CASE nMsg == MSG1_S2PDISCF04     ; cMsg := "Erro carregando Crystal Report Print Engine (CRPE32.DLL)"
   CASE nMsg == MSG1_S2PDISCF05     ; cMsg := "Erro exportando: "
   CASE nMsg == MSG1_S2PDISCF06     ; cMsg := "Exporta��o na dispon�vel"
   // ........................................................................
   // ........................................................................
   //CASE nMsg == MSG1_DFPDF01        ; cMsg := "Pdf Erro de inicializa��o"
   CASE nMsg == MSG1_DFPDF02        ; cMsg := "Criando p�gina arquivo PDF "
   //CASE nMsg == MSG1_DFPDF03        ; cMsg := "Erro de carregamento Classe PdfFont"
   //CASE nMsg == MSG1_DFPDF04        ; cMsg := "Formato de nome errado Compound"
   CASE nMsg == MSG1_DFPDF05        ; cMsg := "ACROBAT READER n�o instalado corretamente"
   CASE nMsg == MSG1_DFPDF06        ; cMsg := "Em progresso a elabora��o da imagem..."
   // ........................................................................
   // ........................................................................
   CASE nMsg == MSG1_DFTIFF01       ; cMsg := "Erro carregando Dll dbImage.dll!"
   CASE nMsg == MSG1_DFTIFF02       ; cMsg := "Erro de convers�o Bmp -> Tiff"
   CASE nMsg == MSG1_DFTIFF03       ; cMsg := "TIFF solu��o Tag N�o encontrado!"
   CASE nMsg == MSG1_DFTIFF04       ; cMsg := "Erro Setando Resolu��o"
   // .........................................................................
   // .........................................................................
   CASE nMsg == MSG1_DFJPG01        ; cMsg := "JPEG solu��o Tag N�o encontrado"
   CASE nMsg == MSG1_DFJPG02        ; cMsg := "Erro de convers�o Bmp -> JPEG"
   CASE nMsg == MSG1_DFJPG03        ; cMsg := "Erro Setando Resolu��o"
   // .........................................................................
   // .........................................................................
   CASE nMsg == MSG1_DFBMP01        ; cMsg := "BMP solu��o Tag n�o encontrado!"
   // .........................................................................
   // .........................................................................
   CASE nMsg == MSG1_CRW01          ; cMsg := "Erro: Corpo do relat�rio Alias <%band%> n�o cont�m//"+;
                                              "todos campos chave n. %nrel%//"+;
                                              "Os seguintes campos s�o necess�rio: %fields%//"+;
                                              "Ser� imposs�vel criar a rela��o no Crystal Report!"
   // ........................................................................
   // ........................................................................
   CASE nMsg == MSG1_DFREPTYP01; cMsg := "Report Manager mecanismo de impress�o (reportman.ocx) n�o encontrado//N�o � poss�vel imprimir"
   CASE nMsg == MSG1_DFREPTYP02; cMsg := "Relat�rio n�o encontrado//%file%"
   // .........................................................................
   // .........................................................................
   CASE nMsg == MSG1_DFWAIT01       ; cMsg := "Favor esperar..."
   // .........................................................................
   // .........................................................................
   CASE nMsg == MSG1_TOOLCLASS01    ; cMsg := "Configure Barra de ferramentas..."
   // .........................................................................
   // .........................................................................
   CASE nMsg == MSG1_TOOLTIPMINCHARS; cMsg := "Caracteres restantes: %nchars%"
   // �������������������������������������������������������������������������
   // �������������������������������������������������������������������������
   CASE nMsg == MSG1_DDKEYWIN0000  ; cMsg := "Pesquisa"
   CASE nMsg == MSG1_DDKEYWIN0010  ; cMsg := "Pesquisa"
   CASE nMsg == MSG1_DDKEYWIN0020  ; cMsg := "Filtro de Gen�rico"
   CASE nMsg == MSG1_DDKEYWIN0030  ; cMsg := "Imprimir"
   CASE nMsg == MSG1_DDKEYWIN0040  ; cMsg := "Imprimir registros listados"
   CASE nMsg == MSG1_DDKEYWIN0050  ; cMsg := "Confirmar (F10)"
   CASE nMsg == MSG1_DDKEYWIN0060  ; cMsg := "Cancelar (Esc)"
   CASE nMsg == MSG1_DDKEYWIN0070  ; cMsg := "Ajuda (F1)"
   CASE nMsg == MSG1_DDKEYWIN0080  ; cMsg := "Ajuda (Shift-F1)"
   CASE nMsg == MSG1_DDKEYWIN0090  ; cMsg := "Crit�rio de sele��o"
   CASE nMsg == MSG1_DDKEYWIN0100  ; cMsg := "Registros"
   CASE nMsg == MSG1_DDKEYWIN0110  ; cMsg := "Selecione registro"
   CASE nMsg == MSG1_DDKEYWIN0120  ; cMsg := "P�gina anterior"
   CASE nMsg == MSG1_DDKEYWIN0130  ; cMsg := "Pr�xima p�gina"
   CASE nMsg == MSG1_DDKEYWIN0140  ; cMsg := "P~esquisa"
   CASE nMsg == MSG1_DDKEYWIN0150  ; cMsg := "~Ordem:"
   CASE nMsg == MSG1_DDKEYWIN0160  ; cMsg := "Remove ^Filtro"
   CASE nMsg == MSG1_DDKEYWIN0170  ; cMsg := "Set ^Filtro"
   CASE nMsg == MSG1_DDKEYWIN0180  ; cMsg := "Nenhum registro corresponde � sele��o"
   CASE nMsg == MSG1_DDKEYWIN0190  ; cMsg := "(Conjunto de filtros gen�ricos, pressione 'Remover Filtro' para permitir a busca)"
   CASE nMsg == MSG1_DDKEYWIN0200  ; cMsg := "Edit express�o n�o � v�lido//"
   // �������������������������������������������������������������������������
   // �������������������������������������������������������������������������
   CASE nMsg == MSG1_DFUSEREVENTWAIT1; cMsg := "Aten��o!//Por %count% varr� terminou o processo corrente!"
   // �������������������������������������������������������������������������
    CASE nMsg == MSG1_DFMAKEIND000  ; cMsg := "Erro criando index %file%//Por favor, verifique os direitos de acesso para a pasta."
   // �������������������������������������������������������������������������
   // �������������������������������������������������������������������������
   CASE nMsg == MSG1_DDFILESTA000  ; cMsg := "Erro criando arquivo temporario//Por favor, verifique os direitos de acesso para a pasta %file%."
   // �������������������������������������������������������������������������
   // �������������������������������������������������������������������������
   CASE nMsg == MSG1_DFGRAPH30000  ; cMsg := "Imprimir"
   CASE nMsg == MSG1_DFGRAPH30010  ; cMsg := "Imprimir mapa"
   CASE nMsg == MSG1_DFGRAPH30020  ; cMsg := "� poss�vel imprimir o gr�fico apenas em impressoras Windows"
   // �������������������������������������������������������������������������
   // �������������������������������������������������������������������������
ENDCASE
RETURN cMsg
