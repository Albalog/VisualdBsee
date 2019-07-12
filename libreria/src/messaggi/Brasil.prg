// *****************************************************************************
// Copyright (C) ISA - Italian Software Agency
//                   - Tradução Diác.C.J.Moretti
// Descrição: Biblioteca de Mensagens
// *****************************************************************************
#include "dfMsg.ch"
#include "dfState.ch"

// Attenzione: questo file usa il character set ANSI
//             deve essere modificato con un editor WINDOWS
//             (notepad, editpad ecc.)
// #pragma necessario per gestire caratteri 
// brasiliani tipo "a" con il "~" sopra
#pragma Ansi2Oem(ON)


* =============================================================================
FUNCTION dfStdMsg( nMsg )
* =============================================================================
LOCAL cMsg := ""
DO CASE
   // .........................................................................
   CASE nMsg == MSG_LANGUAGE       ; cMsg := "BRASIL"
   // .........................................................................
   // .........................................................................
   CASE nMsg == MSG_INITERROR      ; cMsg := "Impossível abrir arquivo init"
   // .........................................................................
   // .........................................................................
   CASE nMsg == MSG_STD_YES        ; cMsg := "^Sim"
   CASE nMsg == MSG_STD_NO         ; cMsg := "^Não"
   // .........................................................................
   // .........................................................................
   CASE nMsg == MSG_TABGET01       ; cMsg := "Sem referência em dbDD//campo"
   CASE nMsg == MSG_TABGET02       ; cMsg := " não encontrado "
   CASE nMsg == MSG_TABGET03       ; cMsg := "Erro abrindo DBDD.DBF"
   CASE nMsg == MSG_TABGET04       ; cMsg := "Erro abrindo DBTABD.DBF"
   // .........................................................................
   // .........................................................................
   CASE nMsg == MSG_TABCHK01       ; cMsg := "Janela em "
   CASE nMsg == MSG_TABCHK02       ; cMsg := " não disponivel!//"
   CASE nMsg == MSG_TABCHK03       ; cMsg := "Arquivo: "
   CASE nMsg == MSG_TABCHK04       ; cMsg := " está  vazio !"
   CASE nMsg == MSG_TABCHK05       ; cMsg := "Impossível deixar o campo vazio//("
   CASE nMsg == MSG_TABCHK06       ; cMsg := "Campo//("
   CASE nMsg == MSG_TABCHK07       ; cMsg := ")//valor://"
   CASE nMsg == MSG_TABCHK08       ; cMsg := "não no arquivo: "
   CASE nMsg == MSG_TABCHK09       ; cMsg := "//insere"
   CASE nMsg == MSG_TABCHK10       ; cMsg := "Campo//("
   CASE nMsg == MSG_TABCHK11       ; cMsg := ")//valor://"
   CASE nMsg == MSG_TABCHK12       ; cMsg := "não na tabela"
   CASE nMsg == MSG_TABCHK13       ; cMsg := "Campo chave da tabela"
   CASE nMsg == MSG_TABCHK14       ; cMsg := "Não encontrado"
   // .........................................................................
   // .........................................................................
   CASE nMsg == MSG_ERRSYS01       ; cMsg := "Número inválido de função"
   CASE nMsg == MSG_ERRSYS02       ; cMsg := "Arquivo não encontrado"
   CASE nMsg == MSG_ERRSYS03       ; cMsg := "Caminho não encontrado"
   CASE nMsg == MSG_ERRSYS04       ; cMsg := "Muitos arquivos abertos"
   CASE nMsg == MSG_ERRSYS05       ; cMsg := "Acesso negado"
   CASE nMsg == MSG_ERRSYS06       ; cMsg := "Memória insuficiente"
   CASE nMsg == MSG_ERRSYS07       ; cMsg := "Reservado"
   CASE nMsg == MSG_ERRSYS08       ; cMsg := "Disco esta protegido contra gravação"
   CASE nMsg == MSG_ERRSYS09       ; cMsg := "Comando desconhecido"
   CASE nMsg == MSG_ERRSYS10       ; cMsg := "Erro de gravação"
   CASE nMsg == MSG_ERRSYS11       ; cMsg := "Erro de leitura"
   CASE nMsg == MSG_ERRSYS12       ; cMsg := "Falha geral"
   //   nMsg == MSG_ERRSYS13       ; cMsg := "Acesso negado"
   CASE nMsg == MSG_ERRSYS14       ; cMsg := "Arquivo já existe"
   CASE nMsg == MSG_ERRSYS15       ; cMsg := "Este erro foi salvo no arquivo :"
   CASE nMsg == MSG_ERRSYS16       ; cMsg := "Pressione uma tecla para continuar..."
   CASE nMsg == MSG_ERRSYS17       ; cMsg := "Handle inválido"
   CASE nMsg == MSG_ERRSYS18       ; cMsg := "Blocos de controle de memória destruidos"
   CASE nMsg == MSG_ERRSYS19       ; cMsg := "Endereço de bloco de memória inválido"
   CASE nMsg == MSG_ERRSYS20       ; cMsg := "Ambiente inválido"
   CASE nMsg == MSG_ERRSYS21       ; cMsg := "Formato inválido"
   CASE nMsg == MSG_ERRSYS22       ; cMsg := "Código de acesso inválido"
   CASE nMsg == MSG_ERRSYS23       ; cMsg := "Dado inválido"
   CASE nMsg == MSG_ERRSYS24       ; cMsg := "Driver especificado inválido"
   CASE nMsg == MSG_ERRSYS25       ; cMsg := "Atenção para remover o diretório corrente"
   CASE nMsg == MSG_ERRSYS26       ; cMsg := "Não é o mesmo dispositivo"
   CASE nMsg == MSG_ERRSYS27       ; cMsg := "Não há mais arquivos"
   CASE nMsg == MSG_ERRSYS28       ; cMsg := "Unidade desconhecida"
   CASE nMsg == MSG_ERRSYS29       ; cMsg := "Drive não pronto"
   CASE nMsg == MSG_ERRSYS30       ; cMsg := "Dados errados (CRC)"
   CASE nMsg == MSG_ERRSYS31       ; cMsg := "Comprimento de estrutura ruim"
   CASE nMsg == MSG_ERRSYS32       ; cMsg := "Erro de procura"
   CASE nMsg == MSG_ERRSYS33       ; cMsg := "Tipo de midia desconhecida"
   CASE nMsg == MSG_ERRSYS34       ; cMsg := "Setor não encontrado"
   CASE nMsg == MSG_ERRSYS35       ; cMsg := "Impressora sem papel"
   CASE nMsg == MSG_ERRSYS36       ; cMsg := "Violação de compartilhamento"
   CASE nMsg == MSG_ERRSYS37       ; cMsg := "Violação de bloqueio"
   CASE nMsg == MSG_ERRSYS38       ; cMsg := "Troca inválida de disco"
   CASE nMsg == MSG_ERRSYS39       ; cMsg := "FCB indisponível"
   CASE nMsg == MSG_ERRSYS40       ; cMsg := "Compartilhamento de buffer sobre carregado"
   CASE nMsg == MSG_ERRSYS41       ; cMsg := "Solicitação de rede não suportado"
   CASE nMsg == MSG_ERRSYS42       ; cMsg := "Computador remoto não responde"
   CASE nMsg == MSG_ERRSYS43       ; cMsg := "Nome duplicado na rede"
   CASE nMsg == MSG_ERRSYS44       ; cMsg := "Nome da rede não encontrado"
   CASE nMsg == MSG_ERRSYS45       ; cMsg := "Rede ocupada"
   CASE nMsg == MSG_ERRSYS46       ; cMsg := "Dispositivo de rede não existe mais"
   CASE nMsg == MSG_ERRSYS47       ; cMsg := "Excedido o limite de comandos para o NETBIOS"
   CASE nMsg == MSG_ERRSYS48       ; cMsg := "Erro de hardware no adaptador da rede"
   CASE nMsg == MSG_ERRSYS49       ; cMsg := "Resposta incorreta da rede"
   CASE nMsg == MSG_ERRSYS50       ; cMsg := "Erro inesperado de rede"
   CASE nMsg == MSG_ERRSYS51       ; cMsg := "Adaptador de rede incompátivel"
   CASE nMsg == MSG_ERRSYS52       ; cMsg := "Fila de impressão cheia"
   CASE nMsg == MSG_ERRSYS53       ; cMsg := "Sem espaço suficiente para fila de impressão"
   CASE nMsg == MSG_ERRSYS54       ; cMsg := "Fila de impressão eliminada (sem espaço)"
   CASE nMsg == MSG_ERRSYS55       ; cMsg := "Nome da rede eliminado"
   CASE nMsg == MSG_ERRSYS56       ; cMsg := "Tipo de dispositivo de rede incorreto"
   //   nMsg == MSG_ERRSYS57       ; cMsg := "Nome de rede não encontrado"
   CASE nMsg == MSG_ERRSYS58       ; cMsg := "Limite de nome de rede excedido"
   CASE nMsg == MSG_ERRSYS59       ; cMsg := "Limite de BIOS session de rede excedido"
   CASE nMsg == MSG_ERRSYS60       ; cMsg := "temporariamente em pausa"
   CASE nMsg == MSG_ERRSYS61       ; cMsg := "Solicitação da rede não aceito"
   CASE nMsg == MSG_ERRSYS62       ; cMsg := "Impressão ou redirecionamento de disco em Pausa"
   CASE nMsg == MSG_ERRSYS63       ; cMsg := "Impossível criar diretório"
   CASE nMsg == MSG_ERRSYS64       ; cMsg := "Falha no INT 24h"
   CASE nMsg == MSG_ERRSYS65       ; cMsg := "Muitos redirecionamentos"
   CASE nMsg == MSG_ERRSYS66       ; cMsg := "Redirecionamento duplicado"
   CASE nMsg == MSG_ERRSYS67       ; cMsg := "Senha invalida"
   CASE nMsg == MSG_ERRSYS68       ; cMsg := "Parametro inválido"
   CASE nMsg == MSG_ERRSYS69       ; cMsg := "Falha em dispositivo de rede"
   CASE nMsg == MSG_ERRSYS70       ; cMsg := "Termina"
   CASE nMsg == MSG_ERRSYS71       ; cMsg := "Tenta Novamente"
   CASE nMsg == MSG_ERRSYS72       ; cMsg := "Default"
   CASE nMsg == MSG_ERRSYS73       ; cMsg := "Erro do DOS :="
   CASE nMsg == MSG_ERRSYS74       ; cMsg := "Break"
   CASE nMsg == MSG_ERRSYS75       ; cMsg := "Chamado de"
   CASE nMsg == MSG_ERRSYS76       ; cMsg := "Erro "
   CASE nMsg == MSG_ERRSYS77       ; cMsg := "Cuidado "
   CASE nMsg == MSG_ERRSYS78       ; cMsg := "DESCONHECIDO"
   // .........................................................................
   // .........................................................................
   CASE nMsg == MSG_DBPATH01       ; cMsg := "Caminho de leitura : @"
   CASE nMsg == MSG_DBPATH02       ; cMsg := "Nome de variável não existe"
   // .........................................................................
   // .........................................................................
   CASE nMsg == MSG_DDUSE01        ; cMsg := "Arquivo não existe:"
   CASE nMsg == MSG_DDUSE02        ; cMsg := "Abrindo arquivo :"
   CASE nMsg == MSG_DDUSE03        ; cMsg := "Erro no nome da variável: "
   CASE nMsg == MSG_DDUSE04        ; cMsg := "Modo desconhecido!"
   CASE nMsg == MSG_DDUSE05        ; cMsg := "Arquivo índice :"
   //   nMsg == MSG_DDUSE06        ; cMsg := "Erro em nome de vari vel: "
   CASE nMsg == MSG_DDUSE07        ; cMsg := "Erro abrindo arquivo"
   CASE nMsg == MSG_DDUSE08        ; cMsg := "Impossível abrir arquivo"
   CASE nMsg == MSG_DDUSE09        ; cMsg := "tempo de espera :"
   CASE nMsg == MSG_DDUSE10        ; cMsg := "Indice não encontrado"
   CASE nMsg == MSG_DDUSE11        ; cMsg := "Unable to open file %file%. The file is used by other users.//Please try again later."
   // .........................................................................
   // .........................................................................
   CASE nMsg == MSG_DBMSGERR       ; cMsg := "OK"
   // .........................................................................
   // .........................................................................
   CASE nMsg == MSG_DE_STATE_INK   ; cMsg := "|Ver|"
   CASE nMsg == MSG_DE_STATE_ADD   ; cMsg := "|Inserir|"
   CASE nMsg == MSG_DE_STATE_MOD   ; cMsg := "|Modificar|"
   CASE nMsg == MSG_DE_STATE_DEL   ; cMsg := "|Apagar|"
   CASE nMsg == MSG_DE_STATE_COPY  ; cMsg := "|Copiar|"
   CASE nMsg == MSG_DE_STATE_QRY   ; cMsg := "|Perguntar|"
   // .........................................................................
   // .........................................................................
   CASE nMsg == MSG_TBSKIP01       ; cMsg := " está vazio !!"
   CASE nMsg == MSG_TBSKIP02       ; cMsg := "Início de : "
   CASE nMsg == MSG_TBSKIP03       ; cMsg := "Fim de : "
   // .........................................................................
   // .........................................................................
   CASE nMsg == MSG_DE_DEL         ; cMsg := "Confirme a eliminação do REGISTRO !"
   CASE nMsg == MSG_DE_NOTMOD      ; cMsg := "Sem registros para modificar !"
   CASE nMsg == MSG_DE_NOTDEL      ; cMsg := "Sem registros para eliminar !"
   CASE nMsg == MSG_DE_NOTADD      ; cMsg := "It is not possible to add Record if the head table is empty: "
   // .........................................................................
   // .........................................................................
   CASE nMsg == MSG_NUM2WORD01     ; cMsg := "um "
   CASE nMsg == MSG_NUM2WORD02     ; cMsg := "dois "
   CASE nMsg == MSG_NUM2WORD03     ; cMsg := "três "
   CASE nMsg == MSG_NUM2WORD04     ; cMsg := "quatro "
   CASE nMsg == MSG_NUM2WORD05     ; cMsg := "cinco "
   CASE nMsg == MSG_NUM2WORD06     ; cMsg := "seis "
   CASE nMsg == MSG_NUM2WORD07     ; cMsg := "sete "
   CASE nMsg == MSG_NUM2WORD08     ; cMsg := "oito "
   CASE nMsg == MSG_NUM2WORD09     ; cMsg := "nove "
   CASE nMsg == MSG_NUM2WORD10     ; cMsg := "dez "
   CASE nMsg == MSG_NUM2WORD11     ; cMsg := "onze "
   CASE nMsg == MSG_NUM2WORD12     ; cMsg := "doze "
   CASE nMsg == MSG_NUM2WORD13     ; cMsg := "treze "
   CASE nMsg == MSG_NUM2WORD14     ; cMsg := "quatorze "
   CASE nMsg == MSG_NUM2WORD15     ; cMsg := "quinze "
   CASE nMsg == MSG_NUM2WORD16     ; cMsg := "dezesseis "
   CASE nMsg == MSG_NUM2WORD17     ; cMsg := "dezessete "
   CASE nMsg == MSG_NUM2WORD18     ; cMsg := "dezoito "
   CASE nMsg == MSG_NUM2WORD19     ; cMsg := "dezenove "
   CASE nMsg == MSG_NUM2WORD20     ; cMsg := "dez "
   CASE nMsg == MSG_NUM2WORD21     ; cMsg := "vinte "
   CASE nMsg == MSG_NUM2WORD22     ; cMsg := "trinta "
   CASE nMsg == MSG_NUM2WORD23     ; cMsg := "quarenta "
   CASE nMsg == MSG_NUM2WORD24     ; cMsg := "cinqüenta "
   CASE nMsg == MSG_NUM2WORD25     ; cMsg := "sessenta "
   CASE nMsg == MSG_NUM2WORD26     ; cMsg := "setenta "
   CASE nMsg == MSG_NUM2WORD27     ; cMsg := "oitenta "
   CASE nMsg == MSG_NUM2WORD28     ; cMsg := "noventa "
   CASE nMsg == MSG_NUM2WORD29     ; cMsg := "bilhão"
   CASE nMsg == MSG_NUM2WORD30     ; cMsg := "milhão"
   CASE nMsg == MSG_NUM2WORD31     ; cMsg := "mil"
   CASE nMsg == MSG_NUM2WORD32     ; cMsg := "zero"
   CASE nMsg == MSG_NUM2WORD33     ; cMsg := "um mil"
   CASE nMsg == MSG_NUM2WORD34     ; cMsg := "um milhão"
   CASE nMsg == MSG_NUM2WORD35     ; cMsg := "um bilhão"
   CASE nMsg == MSG_NUM2WORD36     ; cMsg := "cem "
   CASE nMsg == MSG_NUM2WORD39     ; cMsg := "cento e "
   CASE nMsg == MSG_NUM2WORD40     ; cMsg := "duzentos e "
   CASE nMsg == MSG_NUM2WORD41     ; cMsg := "trezentos e "
   CASE nMsg == MSG_NUM2WORD42     ; cMsg := "quatrocentos e "
   CASE nMsg == MSG_NUM2WORD43     ; cMsg := "qüinhentos e "
   CASE nMsg == MSG_NUM2WORD44     ; cMsg := "seiscentos e "
   CASE nMsg == MSG_NUM2WORD45     ; cMsg := "setecentos e "
   CASE nMsg == MSG_NUM2WORD46     ; cMsg := "oitocentos e "
   CASE nMsg == MSG_NUM2WORD47     ; cMsg := "novecentos e "
   // .........................................................................
   // .........................................................................
   CASE nMsg == MSG_NTXSYS01       ; cMsg := "Reconstruindo índices do sistema"
   //   nMsg == MSG_NTXSYS02       ; cMsg := "Removendo arquivos de índices do disco"
   CASE nMsg == MSG_NTXSYS03       ; cMsg := "Reconstruindo índice para o arquivo dbDD"
   CASE nMsg == MSG_NTXSYS04       ; cMsg := "Reconstruindo índice para o arquivo Help"
   CASE nMsg == MSG_NTXSYS05       ; cMsg := "Reconstruindo os índices p/ os arquivos de tabela"
   // .........................................................................
   // .........................................................................
   CASE nMsg == MSG_PGLIST01       ; cMsg := "Lista de paginas"
   // .........................................................................
   // .........................................................................
   CASE nMsg == MSG_DBCFGOPE01     ; cMsg := "Reindexando"
   CASE nMsg == MSG_DBCFGOPE02     ; cMsg := "Impossível abrir arquivos do sistema"
   // .........................................................................
   // .........................................................................
   CASE nMsg == MSG_HLP01          ; cMsg := "^Próximo"
   CASE nMsg == MSG_HLP02          ; cMsg := "^Anterior"
   CASE nMsg == MSG_HLP03          ; cMsg := "^Menu"
   CASE nMsg == MSG_HLP04          ; cMsg := "^Arquivo"
   CASE nMsg == MSG_HLP05          ; cMsg := "^Info"
   CASE nMsg == MSG_HLP06          ; cMsg := "^Sistema"
   CASE nMsg == MSG_HLP07          ; cMsg := "S^umário"
   CASE nMsg == MSG_HLP08          ; cMsg := "An^terior"
   CASE nMsg == MSG_HLP09          ; cMsg := "^Encontrar"
   CASE nMsg == MSG_HLP10          ; cMsg := "^Arquivo"
   CASE nMsg == MSG_HLP11          ; cMsg := "Imprime ^Tópico"
   CASE nMsg == MSG_HLP12          ; cMsg := "^Sai"
   CASE nMsg == MSG_HLP13          ; cMsg := "^Usando o guia"
   CASE nMsg == MSG_HLP14          ; cMsg := "Sequência a localizar"
   CASE nMsg == MSG_HLP15          ; cMsg := "Sequência não encontrada"
   CASE nMsg == MSG_HLP16          ; cMsg := "Ajuda"
   // .........................................................................
   // .........................................................................
   CASE nMsg == MSG_DBRID01        ; cMsg := "Integridade restringida. Impossível deletar o REGISTRO"
   // .........................................................................
   // .........................................................................
   CASE nMsg == MSG_USRHELP01      ; cMsg := "Ajuda de contexto não disponível//"
   CASE nMsg == MSG_USRHELP02      ; cMsg := "neste ambiente !"
   CASE nMsg == MSG_USRHELP03      ; cMsg := " Teclas disponíveis "
   CASE nMsg == MSG_USRHELP04      ; cMsg := "Volta máscara anterior"
   CASE nMsg == MSG_USRHELP05      ; cMsg := "Calculadora"
   CASE nMsg == MSG_USRHELP06      ; cMsg := "Saída ao sistema operacional"
   // .........................................................................
   // .........................................................................
   CASE nMsg == MSG_DDINDEX01      ; cMsg := "Reindexa arquivos"
   CASE nMsg == MSG_DDINDEX02      ; cMsg := "^Global"
   CASE nMsg == MSG_DDINDEX03      ; cMsg := "^Parcial"
   CASE nMsg == MSG_DDINDEX04      ; cMsg := "Arquivos do ^Sistema"
   CASE nMsg == MSG_DDINDEX05      ; cMsg := "  Indice   | Reg. |Expressão "
   CASE nMsg == MSG_DDINDEX06      ; cMsg := "Reindexando arquivos"
   CASE nMsg == MSG_DDINDEX07      ; cMsg := " com PACK"
   CASE nMsg == MSG_DDINDEX08      ; cMsg := "Selecionando arquivo índice para refazer. Enter=Aceita ! "
   CASE nMsg == MSG_DDINDEX09      ; cMsg := "PAUSA - Pressione uma tecla para retomar - PAUSA"
   CASE nMsg == MSG_DDINDEX10      ; cMsg := "Espaço=Pausa | Reindexando arquivos !"
   CASE nMsg == MSG_DDINDEX11      ; cMsg := "...Pack do arquivo ("
   CASE nMsg == MSG_DDINDEX12      ; cMsg := ") em andamento !..."
   CASE nMsg == MSG_DDINDEX13      ; cMsg := "Indice de arquivo :"
   CASE nMsg == MSG_DDINDEX14      ; cMsg := "Erro em nome de variável :"
   CASE nMsg == MSG_DDINDEX15      ; cMsg := "^Conferir"
   // .........................................................................
   // .........................................................................
   CASE nMsg == MSG_DDINDEXFL01    ; cMsg := "Arquivo índice :"
   CASE nMsg == MSG_DDINDEXFL02    ; cMsg := "Erro no nome da vari vel :"
   CASE nMsg == MSG_DDINDEXFL03    ; cMsg := "PACK p/ Arquivo :"
   CASE nMsg == MSG_DDINDEXFL04    ; cMsg := " em progresso "
   // .........................................................................
   // .........................................................................
   CASE nMsg == MSG_DDWIN01        ; cMsg := "Janela "
   CASE nMsg == MSG_DDWIN02        ; cMsg := "//Não Disponivel !"
   CASE nMsg == MSG_DDWIN03        ; cMsg := "Nada a excluir !"
   CASE nMsg == MSG_DDWIN04        ; cMsg := "Apaga o elemento corrente"
   CASE nMsg == MSG_DDWIN05        ; cMsg := "Nada para Alterar !"
   // .........................................................................
   // .........................................................................
   CASE nMsg == MSG_DFAUTOFORM01   ; cMsg := "^Aceita"
   CASE nMsg == MSG_DFAUTOFORM02   ; cMsg := "^Cancela"
   // .........................................................................
   // .........................................................................
   CASE nMsg == MSG_DFCOLOR01      ; cMsg := "Cor etiqueta"
   CASE nMsg == MSG_DFCOLOR02      ; cMsg := "Não encontrado"
   // .........................................................................
   // .........................................................................
   CASE nMsg == MSG_DFALERT01      ; cMsg := "Pressione uma tecla p/ continuar ..."
   CASE nMsg == MSG_DFALERT02      ; cMsg := "Pressione uma das teclas indicadas.."
   // .........................................................................
   // .........................................................................
   CASE nMsg == MSG_DFMEMO01       ; cMsg := "Aceita o texto"
   CASE nMsg == MSG_DFMEMO02       ; cMsg := "Ler a partir do disco"
   CASE nMsg == MSG_DFMEMO03       ; cMsg := "Grava para o disco"
   CASE nMsg == MSG_DFMEMO05       ; cMsg := "Zera o total"
   CASE nMsg == MSG_DFMEMO06       ; cMsg := "Adiciona ao total"
   CASE nMsg == MSG_DFMEMO07       ; cMsg := "Exibe o total"
   CASE nMsg == MSG_DFMEMO08       ; cMsg := "Copia o total p/ o texto"
   CASE nMsg == MSG_DFMEMO09       ; cMsg := "Resolver a expressão e diminuir do resultado"
   CASE nMsg == MSG_DFMEMO10       ; cMsg := "Resolver a expressão e alterar o resultado"
   CASE nMsg == MSG_DFMEMO11       ; cMsg := "Arquivo a ler"
   CASE nMsg == MSG_DFMEMO12       ; cMsg := "Lendo memo a partir do disco"
   CASE nMsg == MSG_DFMEMO13       ; cMsg := "Total calculado automaticamente. Valores totalizados :"
   CASE nMsg == MSG_DFMEMO14       ; cMsg := "Total obtido pela calculadora//"
   //   nMsg == MSG_DFMEMO15       ; cMsg := "Total Calculado Automaticamente. Valores Totalizados :"
   CASE nMsg == MSG_DFMEMO16       ; cMsg := "Impossível encontrar o inicio da expressão !"
   CASE nMsg == MSG_DFMEMO17       ; cMsg := "OK para perder as Alteraçoes"
   // .........................................................................
   // .........................................................................
   CASE nMsg == MSG_DFQRY01        ; cMsg := "Menor que"
   CASE nMsg == MSG_DFQRY02        ; cMsg := "Maior que"
   CASE nMsg == MSG_DFQRY03        ; cMsg := "Menor que ou igual a"
   CASE nMsg == MSG_DFQRY04        ; cMsg := "Maior que ou igual a"
   CASE nMsg == MSG_DFQRY05        ; cMsg := "Igual a"
   CASE nMsg == MSG_DFQRY06        ; cMsg := "Diferente de"
   CASE nMsg == MSG_DFQRY07        ; cMsg := "Contem"
   CASE nMsg == MSG_DFQRY08        ; cMsg := "Está contido em"
   CASE nMsg == MSG_DFQRY09        ; cMsg := "Exatamente igual a"
   CASE nMsg == MSG_DFQRY10        ; cMsg := "Verdadeiro"
   CASE nMsg == MSG_DFQRY11        ; cMsg := "Falso"
   CASE nMsg == MSG_DFQRY12        ; cMsg := " e "
   CASE nMsg == MSG_DFQRY13        ; cMsg := " ou "
   // .........................................................................
   // .........................................................................
   CASE nMsg == MSG_VALID01        ; cMsg := "Impossível deixar o campo vazio"
   // .........................................................................
   // .........................................................................
   CASE nMsg == MSG_DFINI01        ; cMsg := "Aponta uma versão diferente"
   CASE nMsg == MSG_DFINI02        ; cMsg := "Regerar o DBSTART.INI através do Visual dBsee"
   CASE nMsg == MSG_DFINI03        ; cMsg := "Carregando as ações"
   // .........................................................................
   // .........................................................................
   CASE nMsg == MSG_DFFILE2PRN01   ; cMsg := "Impressora não está pronta//tente de novo"
   CASE nMsg == MSG_DFFILE2PRN02   ; cMsg := "Imprimindo..."
   CASE nMsg == MSG_DFFILE2PRN03   ; cMsg := "Impressão paralizada"
   // .........................................................................
   // .........................................................................
   CASE nMsg == MSG_DFNET01        ; cMsg := "Impossível bloquear arquivo :"
   CASE nMsg == MSG_DFNET02        ; cMsg := "Impossível bloquear registro nbr. %2%"
   CASE nMsg == MSG_DFNET03        ; cMsg := "Impossível adicionar registro"
   //   nMsg == MSG_DFNET04        ; cMsg := "FUNÇAO DESCONHECIDA !!"
   //   nMsg == MSG_DFNET05        ; cMsg := "Time out: "
   CASE nMsg == MSG_DFNET06        ; cMsg := "Tentativas de bloqueios"
   CASE nMsg == MSG_DFNET07        ; cMsg := "Segundos"
   CASE nMsg == MSG_DFNET08        ; cMsg := "Arquivo bloqueado :"
   CASE nMsg == MSG_DFNET09        ; cMsg := "Usando sem foro"
   CASE nMsg == MSG_DFNET10        ; cMsg := "Impossível encontrar"
   // .........................................................................
   // .........................................................................
   CASE nMsg == MSG_DFMEMOWRI01    ; cMsg := "Gravar para: "
   CASE nMsg == MSG_DFMEMOWRI02    ; cMsg := "Entre com o nome do arquivo.|F10=Aceita|Esc=Abandona"
   CASE nMsg == MSG_DFMEMOWRI03    ; cMsg := "Gravando memo no disco"
   CASE nMsg == MSG_DFMEMOWRI04    ; cMsg := "Arquivo já existe. Sobrepor ?"
   //   nMsg == MSG_DFMEMOWRI05    ; cMsg := "Arquivo "
   //   nMsg == MSG_DFMEMOWRI06    ; cMsg := " foi gravado !"
   // .........................................................................
   // .........................................................................
   CASE nMsg == MSG_DFINIPATH01    ; cMsg := "Carregando caminhos da aplicação"
   // .........................................................................
   // .........................................................................
   CASE nMsg == MSG_DFINIFONT01    ; cMsg := "Carregando fontes"
   // .........................................................................
   // .........................................................................
   CASE nMsg == MSG_DFINIPRN01     ; cMsg := "Carregando impressoras"
   // .........................................................................
   // .........................................................................
   CASE nMsg == MSG_DFPROGIND01    ; cMsg := "Abandona"
   CASE nMsg == MSG_DFPROGIND02    ; cMsg := "Tem certeza de interromper"
   // .........................................................................
   // .........................................................................
   CASE nMsg == MSG_DBLOOK01       ; cMsg := "Impossível deixar o campo//"
   CASE nMsg == MSG_DBLOOK02       ; cMsg := "vazio"
   CASE nMsg == MSG_DBLOOK03       ; cMsg := "Cuidado: //"
   CASE nMsg == MSG_DBLOOK04       ; cMsg := "//não existe !!"
   CASE nMsg == MSG_DBLOOK05       ; cMsg := "Cuidado: //"
   CASE nMsg == MSG_DBLOOK06       ; cMsg := "//não está no arquivo"
   CASE nMsg == MSG_DBLOOK07       ; cMsg := "//Inserir agora?"
   // .........................................................................
   // .........................................................................
   CASE nMsg == MSG_DFTABDE01      ; cMsg := "Arquivos tabelas"
   CASE nMsg == MSG_DFTABDE02      ; cMsg := "Tabelas"
   CASE nMsg == MSG_DFTABDE03      ; cMsg := "Altera"
   CASE nMsg == MSG_DFTABDE04      ; cMsg := "Nenhum arquivo de tabela na aplicação"
   // .........................................................................
   // .........................................................................
   CASE nMsg == MSG_DBINK01        ; cMsg := "Tempo de espera do teclado"
   CASE nMsg == MSG_DBINK02        ; cMsg := "Segundos"
   // .........................................................................
   // .........................................................................
   //   nMsg == MSG_DFINIPP01      ; cMsg := "Carregando portas de Impressoras"
   // .........................................................................
   // .........................................................................
   CASE nMsg == MSG_DFINIPOR01     ; cMsg := "Carregando portas"
   // .........................................................................
   // .........................................................................
   CASE nMsg == MSG_DFGET01        ; cMsg := "Deixa a máscara"
   CASE nMsg == MSG_DFGET02        ; cMsg := "Salva a máscara"
   // .........................................................................
   // .........................................................................
   CASE nMsg == MSG_TBBRWNEW01     ; cMsg := "Restaurar o tamanho original da janela"
   CASE nMsg == MSG_TBBRWNEW02     ; cMsg := "Mover a janela"
   CASE nMsg == MSG_TBBRWNEW03     ; cMsg := "Redefinir o tamanho da janela"
   CASE nMsg == MSG_TBBRWNEW04     ; cMsg := "Reduzir a janela ao minimo permitido"
   CASE nMsg == MSG_TBBRWNEW05     ; cMsg := "Aumentar a janela ao maximo permitido"
   CASE nMsg == MSG_TBBRWNEW06     ; cMsg := "Remover a janela corrente e associadas da tela"
   CASE nMsg == MSG_TBBRWNEW07     ; cMsg := "Exibe lista de paginas ativas"
   CASE nMsg == MSG_TBBRWNEW08     ; cMsg := "Próximo"
   CASE nMsg == MSG_TBBRWNEW09     ; cMsg := "Anterior"
   CASE nMsg == MSG_TBBRWNEW10     ; cMsg := "Primeiro"
   CASE nMsg == MSG_TBBRWNEW11     ; cMsg := "Ultimo"
   CASE nMsg == MSG_TBBRWNEW12     ; cMsg := "Esquerda"
   CASE nMsg == MSG_TBBRWNEW13     ; cMsg := "Direita"
   CASE nMsg == MSG_TBBRWNEW14     ; cMsg := "Pagina para cima"
   CASE nMsg == MSG_TBBRWNEW15     ; cMsg := "Pagina para baixo"
   CASE nMsg == MSG_TBBRWNEW16     ; cMsg := "Congela/Libera colunas a esquerda"
   CASE nMsg == MSG_TBBRWNEW17     ; cMsg := "Aumentar coluna"
   CASE nMsg == MSG_TBBRWNEW18     ; cMsg := "Reduzir coluna"
   CASE nMsg == MSG_TBBRWNEW19     ; cMsg := "Deseleciona tudo"
   CASE nMsg == MSG_TBBRWNEW20     ; cMsg := "Seleciona elemento"
   CASE nMsg == MSG_TBBRWNEW21     ; cMsg := "Seleciona tudo"
   CASE nMsg == MSG_TBBRWNEW22     ; cMsg := "Alterar elemento corrente"
   CASE nMsg == MSG_TBBRWNEW23     ; cMsg := "Próxima pagina"
   CASE nMsg == MSG_TBBRWNEW24     ; cMsg := "^Restaurar"
   CASE nMsg == MSG_TBBRWNEW25     ; cMsg := "^Mover"
   CASE nMsg == MSG_TBBRWNEW26     ; cMsg := "Re^size"
   CASE nMsg == MSG_TBBRWNEW27     ; cMsg := "^Iconizar"
   CASE nMsg == MSG_TBBRWNEW28     ; cMsg := "M^aximizar"
   CASE nMsg == MSG_TBBRWNEW29     ; cMsg := "F^echar"
   CASE nMsg == MSG_TBBRWNEW30     ; cMsg := "^Alternar para..."
   CASE nMsg == MSG_TBBRWNEW31     ; cMsg := "Chave"
   CASE nMsg == MSG_TBBRWNEW32     ; cMsg := "Pagina anterior"
   CASE nMsg == MSG_TBBRWNEW33     ; cMsg := "Imprime registros"
   CASE nMsg == MSG_TBBRWNEW34     ; cMsg := "Imprime etiqueta"
   CASE nMsg == MSG_TBBRWNEW35     ; cMsg := "Estatístico"
   CASE nMsg == MSG_TBBRWNEW36     ; cMsg := "Select/Unselect row"
   CASE nMsg == MSG_TBBRWNEW37     ; cMsg := "Unselect all"
   CASE nMsg == MSG_TBBRWNEW38     ; cMsg := "Select all"
   // .........................................................................
   // .........................................................................
   CASE nMsg == MSG_DDGENDBF01     ; cMsg := "Arquivo"
   CASE nMsg == MSG_DDGENDBF02     ; cMsg := "sem campos"
   CASE nMsg == MSG_DDGENDBF03     ; cMsg := "Criando arquivo"
   CASE nMsg == MSG_DDGENDBF04     ; cMsg := "Attention!!! The Directory not exist:// "
   CASE nMsg == MSG_DDGENDBF05     ; cMsg := "//Create the Directory now?"
   CASE nMsg == MSG_DDGENDBF06     ; cMsg := "Unable to Create the Directory://"
   CASE nMsg == MSG_DDGENDBF07     ; cMsg := "Serious error in Table creation!!!//Operation aborted ...//Table: "
   // .........................................................................
   // .........................................................................
   CASE nMsg == MSG_DFTABPRINT01   ; cMsg := "Nenhuma tabela a imprimir"
   CASE nMsg == MSG_DFTABPRINT02   ; cMsg := "| Tabelas |"
   CASE nMsg == MSG_DFTABPRINT03   ; cMsg := "Imprime tabelas"
   //   nMsg == MSG_DFTABPRINT04   ; cMsg := "Imprime Tabelas"
   // .........................................................................
   // .........................................................................
   CASE nMsg == MSG_DFPRNSTART01   ; cMsg := "Erro abrindo arquivo"
   CASE nMsg == MSG_DFPRNSTART02   ; cMsg := "Pressione ENTER para imprimir"
   CASE nMsg == MSG_DFPRNSTART03   ; cMsg := "Arquivo mestre"
   CASE nMsg == MSG_DFPRNSTART04   ; cMsg := "Imprimir :"
   CASE nMsg == MSG_DFPRNSTART05   ; cMsg := "Impressora atual"
   CASE nMsg == MSG_DFPRNSTART06   ; cMsg := "Porta p/ impressão"
   CASE nMsg == MSG_DFPRNSTART07   ; cMsg := "Qualidade"
   CASE nMsg == MSG_DFPRNSTART08   ; cMsg := "Normal"
   CASE nMsg == MSG_DFPRNSTART09   ; cMsg := "Alta"
   CASE nMsg == MSG_DFPRNSTART10   ; cMsg := "Caracter"
   CASE nMsg == MSG_DFPRNSTART11   ; cMsg := "Normal"
   CASE nMsg == MSG_DFPRNSTART12   ; cMsg := "Comprimido"
   CASE nMsg == MSG_DFPRNSTART13   ; cMsg := "^Troca porta"
   CASE nMsg == MSG_DFPRNSTART14   ; cMsg := "^Margens"
   CASE nMsg == MSG_DFPRNSTART15   ; cMsg := "Imp^ressora"
   CASE nMsg == MSG_DFPRNSTART16   ; cMsg := "^Fila ativa"
   CASE nMsg == MSG_DFPRNSTART17   ; cMsg := "Co^pias :"
   CASE nMsg == MSG_DFPRNSTART18   ; cMsg := "^Número de copias"
   CASE nMsg == MSG_DFPRNSTART19   ; cMsg := "^Arq. :"
   CASE nMsg == MSG_DFPRNSTART20   ; cMsg := "^Visualizar"
   CASE nMsg == MSG_DFPRNSTART21   ; cMsg := "^Imprimir"
   CASE nMsg == MSG_DFPRNSTART22   ; cMsg := "^Sair"
   CASE nMsg == MSG_DFPRNSTART23   ; cMsg := "Linhas por pagina"
   CASE nMsg == MSG_DFPRNSTART24   ; cMsg := "Margem superior"
   CASE nMsg == MSG_DFPRNSTART25   ; cMsg := "Margem inferior"
   CASE nMsg == MSG_DFPRNSTART26   ; cMsg := "Margem esquerda"
   CASE nMsg == MSG_DFPRNSTART27   ; cMsg := "Margens"
   CASE nMsg == MSG_DFPRNSTART28   ; cMsg := "| Portas |"
   CASE nMsg == MSG_DFPRNSTART29   ; cMsg := "| Portas das impressoras |"
   CASE nMsg == MSG_DFPRNSTART30   ; cMsg := "Relatório sem quebra de paginas"
   CASE nMsg == MSG_DFPRNSTART31   ; cMsg := "Nada para imprimir"
   CASE nMsg == MSG_DFPRNSTART32   ; cMsg := "Nome do relatório"
   CASE nMsg == MSG_DFPRNSTART33   ; cMsg := "Descrição do filtro"
   CASE nMsg == MSG_DFPRNSTART34   ; cMsg := "Expressão do filtro"
   CASE nMsg == MSG_DFPRNSTART35   ; cMsg := "I^nformação"
   CASE nMsg == MSG_DFPRNSTART36   ; cMsg := "Configurar"
   CASE nMsg == MSG_DFPRNSTART37   ; cMsg := "Use config. ^1"
   CASE nMsg == MSG_DFPRNSTART38   ; cMsg := "Use config. ^2"
   CASE nMsg == MSG_DFPRNSTART39   ; cMsg := "Use config. ^3"
   CASE nMsg == MSG_DFPRNSTART40   ; cMsg := "Pa^ginas"
   CASE nMsg == MSG_DFPRNSTART41   ; cMsg := "Imprime TODAS paginas"
   //   nMsg == MSG_DFPRNSTART42   ; cMsg := "Imprime TODAS paginas"
   CASE nMsg == MSG_DFPRNSTART43   ; cMsg := "Da pagina"
   CASE nMsg == MSG_DFPRNSTART44   ; cMsg := "Imprimir da pagina"
   CASE nMsg == MSG_DFPRNSTART45   ; cMsg := "até a pagina"
   CASE nMsg == MSG_DFPRNSTART46   ; cMsg := "Imprimir até a pagina"
   CASE nMsg == MSG_DFPRNSTART47   ; cMsg := "Paginas"
   CASE nMsg == MSG_DFPRNSTART48   ; cMsg := "^Filtro"
   CASE nMsg == MSG_DFPRNSTART49   ; cMsg := "Substitui o filtro atual"
   // .........................................................................
   // .........................................................................
   CASE nMsg == MSG_DDDE01         ; cMsg := "Forma autom tica//"
   CASE nMsg == MSG_DDDE02         ; cMsg := "//não definido !"
   CASE nMsg == MSG_DDDE03         ; cMsg := "Forma autom tica//"
   CASE nMsg == MSG_DDDE04         ; cMsg := "//Chave prim ria não definida !"
   CASE nMsg == MSG_DDDE05         ; cMsg := "Forma "
   CASE nMsg == MSG_DDDE06         ; cMsg := "CHAVE PRIMARIA//"
   CASE nMsg == MSG_DDDE07         ; cMsg := "//Duplicada !"
   CASE nMsg == MSG_DDDE08         ; cMsg := "Campo obrigatório"
   // .........................................................................
   // .........................................................................
   CASE nMsg == MSG_TBINK01        ; cMsg := "Registro corrente foi apagado"
   // .........................................................................
   // .........................................................................
   CASE nMsg == MSG_TBGETKEY01     ; cMsg := "Janela de pesquisa"
   CASE nMsg == MSG_TBGETKEY02     ; cMsg := "Chave de pesquisa"
   //   nMsg == MSG_TBGETKEY03     ; cMsg := "Janela de pesquisa"
   CASE nMsg == MSG_TBGETKEY04     ; cMsg := "Edita memo"
   CASE nMsg == MSG_TBGETKEY05     ; cMsg := "Seleciona/Deseleciona o valor"
   CASE nMsg == MSG_TBGETKEY06     ; cMsg := "Selecione o valor"
   CASE nMsg == MSG_TBGETKEY07     ; cMsg := "Pressione o botão"
   CASE nMsg == MSG_TBGETKEY08     ; cMsg := "Aumenta o valor"
   CASE nMsg == MSG_TBGETKEY09     ; cMsg := "Decrementa o Valor"
   CASE nMsg == MSG_TBGETKEY10     ; cMsg := "Aumenta em 10 vezes o valor"
   CASE nMsg == MSG_TBGETKEY11     ; cMsg := "Decrementa em 10 vezes o valor"
   CASE nMsg == MSG_TBGETKEY14     ; cMsg := "Copia"
   CASE nMsg == MSG_TBGETKEY15     ; cMsg := "Cola"
   CASE nMsg == MSG_TBGETKEY16     ; cMsg := "Registro anterior"
   CASE nMsg == MSG_TBGETKEY17     ; cMsg := "Proximo registro"
   CASE nMsg == MSG_TBGETKEY18     ; cMsg := "Primeiro registro"
   CASE nMsg == MSG_TBGETKEY19     ; cMsg := "Ultimo registro"
   CASE nMsg == MSG_TBGETKEY20     ; cMsg := "Calendário"
   CASE nMsg == MSG_TBGETKEY21     ; cMsg := "Próxima data"
   CASE nMsg == MSG_TBGETKEY22     ; cMsg := "Data anterior"
   // .........................................................................
   // .........................................................................
   CASE nMsg == MSG_DFSVILLEV01    ; cMsg := "Impressão paralizada"
   // .........................................................................
   // .........................................................................
   CASE nMsg == MSG_DFLOGIN01      ; cMsg := "Impossível abrir o arquivo de senhas"
   CASE nMsg == MSG_DFLOGIN02      ; cMsg := "Entre com a senha"
   CASE nMsg == MSG_DFLOGIN03      ; cMsg := "*       CODIGO DE ACESSO     *//"
   CASE nMsg == MSG_DFLOGIN04      ; cMsg := " Já está em uso no sistema  //"
   CASE nMsg == MSG_DFLOGIN05      ; cMsg := "..............................//"
   CASE nMsg == MSG_DFLOGIN06      ; cMsg := "Senha"
   CASE nMsg == MSG_DFLOGIN07      ; cMsg := "//não foi encontrada//"
   CASE nMsg == MSG_DFLOGIN08      ; cMsg := "Entre com a senha novamente"
   CASE nMsg == MSG_DFLOGIN09      ; cMsg := "*      ACCESSO NEGADO     *//"
   CASE nMsg == MSG_DFLOGIN10      ; cMsg := "  Usuário não autorizado ! //"
   CASE nMsg == MSG_DFLOGIN11      ; cMsg := "..........................."
   CASE nMsg == MSG_DFLOGIN12      ; cMsg := "  Erro entrando com a senha //"
   CASE nMsg == MSG_DFLOGIN13      ; cMsg := ".............................."
   CASE nMsg == MSG_DFLOGIN14      ; cMsg := "SENHA"
   CASE nMsg == MSG_DFLOGIN15      ; cMsg := "Entre com a nova senha"
   CASE nMsg == MSG_DFLOGIN16      ; cMsg := "Re-entre com a senha"
   CASE nMsg == MSG_DFLOGIN17      ; cMsg := "Nome do usuário"
   CASE nMsg == MSG_DFLOGIN18      ; cMsg := "Entre com a nova SENHA"
   CASE nMsg == MSG_DFLOGIN19      ; cMsg := "For the new laws on the Privacy //the Password must at least be of 8 characters!"

   // .........................................................................
   // .........................................................................
   CASE nMsg == MSG_DDWIT01        ; cMsg := "Adiciona elemento"
   CASE nMsg == MSG_DDWIT02        ; cMsg := "Altera elemento corrente"
   CASE nMsg == MSG_DDWIT03        ; cMsg := "Exclui elemento corrente"
   CASE nMsg == MSG_DDWIT04        ; cMsg := "Pesquisa"
   CASE nMsg == MSG_DDWIT05        ; cMsg := "Código "
   CASE nMsg == MSG_DDWIT06        ; cMsg := " não existe"
   CASE nMsg == MSG_DDWIT07        ; cMsg := "Exclui o item corrente"
   CASE nMsg == MSG_DDWIT08        ; cMsg := "Pesquisa "
   // .........................................................................
   // .........................................................................
   CASE nMsg == MSG_DDKEY01        ; cMsg := "não há chaves pesquisas disponiveis//- Arquivo "
   CASE nMsg == MSG_DDKEY02        ; cMsg := " não possui índices ! -"
   CASE nMsg == MSG_DDKEY03        ; cMsg := "Impossível determinar a chave de pesquisa//"
   CASE nMsg == MSG_DDKEY04        ; cMsg := "Pequisa Sequêncial apenas em campos caracter !"
   CASE nMsg == MSG_DDKEY05        ; cMsg := "Janela de pesquisa"
   CASE nMsg == MSG_DDKEY06        ; cMsg := "Combinando chave de pesquisa"
   CASE nMsg == MSG_DDKEY07        ; cMsg := "Janela do arquivo de LookUp"
   CASE nMsg == MSG_DDKEY08        ; cMsg := "Criação de chave de procura"
   CASE nMsg == MSG_DDKEY09        ; cMsg := "Chave: "
   CASE nMsg == MSG_DDKEY10        ; cMsg := "//não encontrada!"
   CASE nMsg == MSG_DDKEY11        ; cMsg := " Qualquer tecla para parar"
   CASE nMsg == MSG_DDKEY12        ; cMsg := "//Espere por favor...//"
   // .........................................................................
   // .........................................................................
   CASE nMsg == MSG_DDUPDDBF01     ; cMsg := "Atualizando"
   // .........................................................................
   // .........................................................................
   CASE nMsg == MSG_DFTABFRM03     ; cMsg := "Segundo controle. Código duplicado !//Inserção cancelada !!"
   CASE nMsg == MSG_DFTABFRM04     ; cMsg := "Erro: código duplicado em "
   CASE nMsg == MSG_DFTABFRM05     ; cMsg := "Cuidado!"
   CASE nMsg == MSG_DFTABFRM06     ; cMsg := "^Usado em"
   // .........................................................................
   // .........................................................................
   CASE nMsg == MSG_DFPK01         ; cMsg := "primária"
   CASE nMsg == MSG_DFPK02         ; cMsg := "unica"
   CASE nMsg == MSG_DFPK03         ; cMsg := "Chave "
   CASE nMsg == MSG_DFPK04         ; cMsg := " duplicada !//"
   CASE nMsg == MSG_DFPK05         ; cMsg := " vazia !//"
   CASE nMsg == MSG_DFPK06         ; cMsg := "...............................//"
   CASE nMsg == MSG_DFPK07         ; cMsg := "       Entre nova chave !      "
   // .........................................................................
   // .........................................................................
   CASE nMsg == MSG_DDQRY01        ; cMsg := "e         | .AND.|"
   CASE nMsg == MSG_DDQRY02        ; cMsg := "ou        | .OR. |"
   CASE nMsg == MSG_DDQRY17        ; cMsg := "Parêntese |  )   |"
   CASE nMsg == MSG_DDQRY03        ; cMsg := "Fim       |      |"
   CASE nMsg == MSG_DDQRY04        ; cMsg := " <   Menor que............... "
   CASE nMsg == MSG_DDQRY05        ; cMsg := " >   Maior que............... "
   CASE nMsg == MSG_DDQRY06        ; cMsg := " <=  Menor que ou igual a.... "
   CASE nMsg == MSG_DDQRY07        ; cMsg := " >=  Maior que ou igual a.... "
   CASE nMsg == MSG_DDQRY08        ; cMsg := " =   Igual a................. "
   CASE nMsg == MSG_DDQRY09        ; cMsg := " #   Diferente de............ "
   CASE nMsg == MSG_DDQRY10        ; cMsg := " $   Está contido em......... "
   CASE nMsg == MSG_DDQRY11        ; cMsg := " œ   Contém.................. "
   CASE nMsg == MSG_DDQRY12        ; cMsg := "Campos do arquivo"
   CASE nMsg == MSG_DDQRY13        ; cMsg := "Condições"
   CASE nMsg == MSG_DDQRY14        ; cMsg := "União lógicas"
   CASE nMsg == MSG_DDQRY15        ; cMsg := "|Filtro BOM|"
   CASE nMsg == MSG_DDQRY16        ; cMsg := "|Filtro RUIM|"
   // .........................................................................
   // .........................................................................
   CASE nMsg == MSG_TBGET01        ; cMsg := "Espaço=Modifica| "
   CASE nMsg == MSG_TBGET02        ; cMsg := "F10=Salva | "
   CASE nMsg == MSG_TBGET03        ; cMsg := "O valor entrado esta errado"
   CASE nMsg == MSG_TBGET04        ; cMsg := "Impossível editar o CONTROLE"
   CASE nMsg == MSG_TBGET05        ; cMsg := "Os gets foram modificados"
   CASE nMsg == MSG_TBGET06        ; cMsg := "^Salvar"
   CASE nMsg == MSG_TBGET07        ; cMsg := "^Sair"
   CASE nMsg == MSG_TBGET08        ; cMsg := "^Continue"
   // .........................................................................
   // .........................................................................
   CASE nMsg == MSG_DFSTA01        ; cMsg := "Tempo gasto"
   CASE nMsg == MSG_DFSTA02        ; cMsg := "Tempo estimado"
   // .........................................................................
   // .........................................................................
   CASE nMsg == MSG_DFINIREP01     ; cMsg := "Carregando a definição do relatório"
   // .........................................................................
   // .........................................................................
   CASE nMsg == MSG_DFCALC01       ; cMsg := "Soma"
   CASE nMsg == MSG_DFCALC02       ; cMsg := "Multiplica"
   CASE nMsg == MSG_DFCALC03       ; cMsg := "Subtrai"
   CASE nMsg == MSG_DFCALC04       ; cMsg := "Divide"
   CASE nMsg == MSG_DFCALC06       ; cMsg := "Adiciona"
   CASE nMsg == MSG_DFCALC07       ; cMsg := "Liga"
   CASE nMsg == MSG_DFCALC08       ; cMsg := "Desliga"
   CASE nMsg == MSG_DFCALC09       ; cMsg := "Sai e cola"
   CASE nMsg == MSG_DFCALC10       ; cMsg := "Conversão de LIRA para EURO"
   CASE nMsg == MSG_DFCALC11       ; cMsg := "Conversão de EURO para LIRA"
   // .........................................................................
   // .........................................................................
   CASE nMsg == MSG_INTCOL01       ; cMsg := "Preto"
   CASE nMsg == MSG_INTCOL02       ; cMsg := "Cinza Escuro"
   CASE nMsg == MSG_INTCOL03       ; cMsg := "Cinza Claro"
   CASE nMsg == MSG_INTCOL04       ; cMsg := "Azul Escuro"
   CASE nMsg == MSG_INTCOL05       ; cMsg := "Azul"
   CASE nMsg == MSG_INTCOL06       ; cMsg := "Azul Claro"
   CASE nMsg == MSG_INTCOL07       ; cMsg := "Verde Escuro"
   CASE nMsg == MSG_INTCOL08       ; cMsg := "Verde"
   CASE nMsg == MSG_INTCOL09       ; cMsg := "Verde Claro"
   CASE nMsg == MSG_INTCOL10       ; cMsg := "Vermelho Escuro"
   CASE nMsg == MSG_INTCOL11       ; cMsg := "Vermelho"
   CASE nMsg == MSG_INTCOL12       ; cMsg := "Vermelho Escuro"
   CASE nMsg == MSG_INTCOL13       ; cMsg := "Amarelo Escuro"
   CASE nMsg == MSG_INTCOL14       ; cMsg := "Amarelo"
   CASE nMsg == MSG_INTCOL15       ; cMsg := "Amarelo Claro"
   CASE nMsg == MSG_INTCOL16       ; cMsg := "Branco"
   // .........................................................................
   // .........................................................................
   CASE nMsg == MSG_INTPRN01       ; cMsg := "Texto generico (sem sequencias de ESCapes)"
   //   nMsg == MSG_INTPRN02       ; cMsg := "EPSON FX-80"
   //   nMsg == MSG_INTPRN03       ; cMsg := "HP LASERJET PLUS"
   // .........................................................................
   // .........................................................................
   CASE nMsg == MSG_ACTINT001      ; cMsg := "Home"
   CASE nMsg == MSG_ACTINT002      ; cMsg := "Ctrl-RightArrow"
   CASE nMsg == MSG_ACTINT003      ; cMsg := "PageDn"
   CASE nMsg == MSG_ACTINT004      ; cMsg := "RightArrow"
   CASE nMsg == MSG_ACTINT005      ; cMsg := "UpArrow"
   CASE nMsg == MSG_ACTINT006      ; cMsg := "End"
   CASE nMsg == MSG_ACTINT007      ; cMsg := "Del"
   CASE nMsg == MSG_ACTINT008      ; cMsg := "BackSpace"
   CASE nMsg == MSG_ACTINT009      ; cMsg := "Tab"
   //   nMsg == MSG_ACTINT010      ; cMsg := "F2"
   //   nMsg == MSG_ACTINT011      ; cMsg := "F3"
   //   nMsg == MSG_ACTINT012      ; cMsg := "F4"
   //   nMsg == MSG_ACTINT013      ; cMsg := "F5"
   //   nMsg == MSG_ACTINT014      ; cMsg := "F6"
   //   nMsg == MSG_ACTINT015      ; cMsg := "F7"
   //   nMsg == MSG_ACTINT016      ; cMsg := "F8"
   //   nMsg == MSG_ACTINT017      ; cMsg := "F9"
   //   nMsg == MSG_ACTINT018      ; cMsg := "F10"
   CASE nMsg == MSG_ACTINT019      ; cMsg := "Ctrl-Enter"
   CASE nMsg == MSG_ACTINT020      ; cMsg := "Enter"
   CASE nMsg == MSG_ACTINT021      ; cMsg := "PageUp"
   CASE nMsg == MSG_ACTINT022      ; cMsg := "LeftArrow"
   CASE nMsg == MSG_ACTINT023      ; cMsg := "Ins"
   CASE nMsg == MSG_ACTINT024      ; cMsg := "Ctrl-End"
   CASE nMsg == MSG_ACTINT025      ; cMsg := "DownArrow"
   CASE nMsg == MSG_ACTINT026      ; cMsg := "Ctrl-LeftArrow"
   CASE nMsg == MSG_ACTINT027      ; cMsg := "Esc"
   CASE nMsg == MSG_ACTINT028      ; cMsg := "F1"
   CASE nMsg == MSG_ACTINT029      ; cMsg := "Ctrl-Home"
   CASE nMsg == MSG_ACTINT030      ; cMsg := "Ctrl-PageUp"
   CASE nMsg == MSG_ACTINT031      ; cMsg := "Ctrl-PageDn"
   CASE nMsg == MSG_ACTINT032      ; cMsg := "Espaço"
   //   nMsg == MSG_ACTINT033      ; cMsg := "+"
   //   nMsg == MSG_ACTINT034      ; cMsg := "-"
   //   nMsg == MSG_ACTINT035      ; cMsg := "<"
   //   nMsg == MSG_ACTINT036      ; cMsg := ">"
   //   nMsg == MSG_ACTINT037      ; cMsg := "Shft-F1"
   //   nMsg == MSG_ACTINT038      ; cMsg := "Shft-F2"
   //   nMsg == MSG_ACTINT039      ; cMsg := "Shft-F3"
   //   nMsg == MSG_ACTINT040      ; cMsg := "Shft-F4"
   //   nMsg == MSG_ACTINT041      ; cMsg := "Shft-F5"
   //   nMsg == MSG_ACTINT042      ; cMsg := "Shft-F6"
   //   nMsg == MSG_ACTINT043      ; cMsg := "Shft-F7"
   //   nMsg == MSG_ACTINT044      ; cMsg := "Shft-F8"
   //   nMsg == MSG_ACTINT045      ; cMsg := "Shft-F9"
   //   nMsg == MSG_ACTINT046      ; cMsg := "Shft-F10"
   //   nMsg == MSG_ACTINT047      ; cMsg := "Ctrl-F1"
   //   nMsg == MSG_ACTINT048      ; cMsg := "Ctrl-F2"
   //   nMsg == MSG_ACTINT049      ; cMsg := "Ctrl-F3"
   //   nMsg == MSG_ACTINT050      ; cMsg := "Ctrl-F4"
   //   nMsg == MSG_ACTINT051      ; cMsg := "Ctrl-F5"
   //   nMsg == MSG_ACTINT052      ; cMsg := "Ctrl-F6"
   //   nMsg == MSG_ACTINT053      ; cMsg := "Ctrl-F7"
   //   nMsg == MSG_ACTINT054      ; cMsg := "Ctrl-F8"
   //   nMsg == MSG_ACTINT055      ; cMsg := "Ctrl-F9"
   //   nMsg == MSG_ACTINT056      ; cMsg := "Ctrl-F10"
   //   nMsg == MSG_ACTINT057      ; cMsg := "Alt-F1"
   //   nMsg == MSG_ACTINT058      ; cMsg := "Alt-F2"
   //   nMsg == MSG_ACTINT059      ; cMsg := "Alt-F3"
   //   nMsg == MSG_ACTINT060      ; cMsg := "Alt-F4"
   //   nMsg == MSG_ACTINT061      ; cMsg := "Alt-F5"
   //   nMsg == MSG_ACTINT062      ; cMsg := "Alt-F6"
   //   nMsg == MSG_ACTINT063      ; cMsg := "Alt-F7"
   //   nMsg == MSG_ACTINT064      ; cMsg := "Alt-F8"
   //   nMsg == MSG_ACTINT065      ; cMsg := "Alt-F9"
   //   nMsg == MSG_ACTINT066      ; cMsg := "Alt-F10"
   CASE nMsg == MSG_ACTINT067      ; cMsg := "Ctrl-BackSpace"
   CASE nMsg == MSG_ACTINT068      ; cMsg := "Alt-Esc"
   CASE nMsg == MSG_ACTINT069      ; cMsg := "Alt-BackSpace"
   CASE nMsg == MSG_ACTINT070      ; cMsg := "Shift-Tab"
   CASE nMsg == MSG_ACTINT071      ; cMsg := "Alt-Q"
   CASE nMsg == MSG_ACTINT072      ; cMsg := "Alt-W"
   CASE nMsg == MSG_ACTINT073      ; cMsg := "Alt-E"
   CASE nMsg == MSG_ACTINT074      ; cMsg := "Alt-R"
   CASE nMsg == MSG_ACTINT075      ; cMsg := "Alt-T"
   CASE nMsg == MSG_ACTINT076      ; cMsg := "Alt-Y"
   CASE nMsg == MSG_ACTINT077      ; cMsg := "Alt-U"
   CASE nMsg == MSG_ACTINT078      ; cMsg := "Alt-I"
   CASE nMsg == MSG_ACTINT079      ; cMsg := "Alt-O"
   CASE nMsg == MSG_ACTINT080      ; cMsg := "Alt-P"
   CASE nMsg == MSG_ACTINT081      ; cMsg := "Alt-Š"
   CASE nMsg == MSG_ACTINT082      ; cMsg := "Alt +"
   CASE nMsg == MSG_ACTINT083      ; cMsg := "Alt-Enter"
   CASE nMsg == MSG_ACTINT084      ; cMsg := "Alt-A"
   CASE nMsg == MSG_ACTINT085      ; cMsg := "Alt-S"
   CASE nMsg == MSG_ACTINT086      ; cMsg := "Alt-D"
   CASE nMsg == MSG_ACTINT087      ; cMsg := "Alt-F"
   CASE nMsg == MSG_ACTINT088      ; cMsg := "Alt-G"
   CASE nMsg == MSG_ACTINT089      ; cMsg := "Alt-H"
   CASE nMsg == MSG_ACTINT090      ; cMsg := "Alt-J"
   CASE nMsg == MSG_ACTINT091      ; cMsg := "Alt-K"
   CASE nMsg == MSG_ACTINT092      ; cMsg := "Alt-L"
   CASE nMsg == MSG_ACTINT093      ; cMsg := "Alt-•"
   CASE nMsg == MSG_ACTINT094      ; cMsg := "Alt-…"
   CASE nMsg == MSG_ACTINT095      ; cMsg := "Alt-Backslash"
   CASE nMsg == MSG_ACTINT096      ; cMsg := "Alt-—"
   CASE nMsg == MSG_ACTINT097      ; cMsg := "Alt-Z"
   CASE nMsg == MSG_ACTINT098      ; cMsg := "Alt-X"
   CASE nMsg == MSG_ACTINT099      ; cMsg := "Alt-C"
   CASE nMsg == MSG_ACTINT100      ; cMsg := "Alt-V"
   CASE nMsg == MSG_ACTINT101      ; cMsg := "Alt-B"
   CASE nMsg == MSG_ACTINT102      ; cMsg := "Alt-N"
   CASE nMsg == MSG_ACTINT103      ; cMsg := "Alt-M"
   CASE nMsg == MSG_ACTINT104      ; cMsg := "Alt-,"
   CASE nMsg == MSG_ACTINT105      ; cMsg := "Alt-."
   CASE nMsg == MSG_ACTINT106      ; cMsg := "Alt-"
   CASE nMsg == MSG_ACTINT107      ; cMsg := "Alt-1"
   CASE nMsg == MSG_ACTINT108      ; cMsg := "Alt-2"
   CASE nMsg == MSG_ACTINT109      ; cMsg := "Alt-3"
   CASE nMsg == MSG_ACTINT110      ; cMsg := "Alt-4"
   CASE nMsg == MSG_ACTINT111      ; cMsg := "Alt-5"
   CASE nMsg == MSG_ACTINT112      ; cMsg := "Alt-6"
   CASE nMsg == MSG_ACTINT113      ; cMsg := "Alt-7"
   CASE nMsg == MSG_ACTINT114      ; cMsg := "Alt-8"
   CASE nMsg == MSG_ACTINT115      ; cMsg := "Alt-9"
   CASE nMsg == MSG_ACTINT116      ; cMsg := "Alt-0"
   CASE nMsg == MSG_ACTINT117      ; cMsg := "Alt-'"
   CASE nMsg == MSG_ACTINT118      ; cMsg := "Alt-"
   CASE nMsg == MSG_ACTINT119      ; cMsg := "F11"
   CASE nMsg == MSG_ACTINT120      ; cMsg := "F12"
   //   nMsg == MSG_ACTINT121      ; cMsg := "Shft-F11"
   //   nMsg == MSG_ACTINT122      ; cMsg := "Shft-F12"
   //   nMsg == MSG_ACTINT123      ; cMsg := "Ctrl-F11"
   //   nMsg == MSG_ACTINT124      ; cMsg := "Ctrl-F12"
   //   nMsg == MSG_ACTINT125      ; cMsg := "Alt-F11"
   //   nMsg == MSG_ACTINT126      ; cMsg := "Alt-F12"
   CASE nMsg == MSG_ACTINT127      ; cMsg := "Ctrl-UpArrow"
   CASE nMsg == MSG_ACTINT128      ; cMsg := "Ctrl-DownArrow"
   CASE nMsg == MSG_ACTINT129      ; cMsg := "Ctrl-Ins"
   CASE nMsg == MSG_ACTINT130      ; cMsg := "Ctrl-Del"
   CASE nMsg == MSG_ACTINT131      ; cMsg := "Ctrl-Tab"
   CASE nMsg == MSG_ACTINT132      ; cMsg := "Ctrl-Slash"
   CASE nMsg == MSG_ACTINT133      ; cMsg := "Alt-Home"
   CASE nMsg == MSG_ACTINT134      ; cMsg := "Alt-UpArrow"
   CASE nMsg == MSG_ACTINT135      ; cMsg := "Alt-PageUp"
   CASE nMsg == MSG_ACTINT136      ; cMsg := "Alt-LeftArrow"
   CASE nMsg == MSG_ACTINT137      ; cMsg := "Alt-RightArrow"
   CASE nMsg == MSG_ACTINT138      ; cMsg := "Alt-End"
   CASE nMsg == MSG_ACTINT139      ; cMsg := "Alt-DownArrow"
   CASE nMsg == MSG_ACTINT140      ; cMsg := "Alt-PageDn"
   CASE nMsg == MSG_ACTINT141      ; cMsg := "Alt-Ins"
   CASE nMsg == MSG_ACTINT142      ; cMsg := "Alt-Del"
   CASE nMsg == MSG_ACTINT143      ; cMsg := "Alt-Tab"
   //   nMsg == MSG_ACTINT144      ; cMsg := "Ctrl-F"
   CASE nMsg == MSG_ACTINT145      ; cMsg := "Ctrl-Backslash"
   CASE nMsg == MSG_ACTINT146      ; cMsg := "Ctrl-Espaço"
   CASE nMsg == MSG_ACTINT147      ; cMsg := "Alt-Espaço"
   CASE nMsg == MSG_ACTINT148      ; cMsg := "Shft-Del"
   CASE nMsg == MSG_ACTINT149      ; cMsg := "Shft-Ins"
   CASE nMsg == MSG_ACTINT150      ; cMsg := "Alt-?"
   CASE nMsg == MSG_ACTINT151      ; cMsg := "Alt-Shift-Tab"
   //   nMsg == MSG_ACTINT152      ; cMsg := "Ctrl-P"
   CASE nMsg == MSG_ACTINT153      ; cMsg := "Ctrl"
   CASE nMsg == MSG_ACTINT154      ; cMsg := "Alt"
   CASE nMsg == MSG_ACTINT155      ; cMsg := "Shft"
   // .........................................................................
   // .........................................................................
   CASE nMsg == MSG_ADDMENUUND     ; cMsg := "Açao Indefinida !"
   CASE nMsg == MSG_ATTBUTUND      ; cMsg := "Funçao Indefinida !"
   CASE nMsg == MSG_FORMESC        ; cMsg := "Sair"
   CASE nMsg == MSG_FORMWRI        ; cMsg := "Salvar"
   // .........................................................................
   // .........................................................................
   CASE nMsg == MSG_INFO01         ; cMsg := "Sintaxe"
   CASE nMsg == MSG_INFO02         ; cMsg := "[opções] [ArqIni.ext]"
   CASE nMsg == MSG_INFO03         ; cMsg := "Opções:    /?|/h = Estas informaçoes."
   CASE nMsg == MSG_INFO04         ; cMsg := "           /UPD  = Verifica as BASES de Dados da Aplicaçao"
   CASE nMsg == MSG_INFO05         ; cMsg := "ArqIni.ext:    Nome do arquivo INI"
   CASE nMsg == MSG_INFO06         ; cMsg := "               O nome default e' DBSTART.INI"
   CASE nMsg == MSG_INFO07         ; cMsg := "           /FAST = Reconfiguracao rapida do mouse"
   CASE nMsg == MSG_INFO08         ; cMsg := "Programa gerado com Visual dBsee %VER% o STANDARD CASE para Xbase++"
   // .........................................................................
   // .........................................................................
   CASE nMsg == MSG_DFISPIRATE01   ; cMsg := "Programa atualmente livre//Faça a proteção"
   CASE nMsg == MSG_DFISPIRATE02   ; cMsg := "Problemas durante a proteção"
   CASE nMsg == MSG_DFISPIRATE03   ; cMsg := "Programa atualmente livre//Voçe deve proteger o programa"
   CASE nMsg == MSG_DFISPIRATE04   ; cMsg := "Copia ilegal do programa//contate o suporte técnico"
   // .........................................................................
   // .........................................................................
   CASE nMsg == MSG_DFCFGPAL01     ; cMsg := "As cores foram trocadas //Voçe quer Salvar"
   CASE nMsg == MSG_DFCFGPAL02     ; cMsg := "Esperando..."
   // .........................................................................
   // .........................................................................
   CASE nMsg == MSG_AS40001        ; cMsg := "Nome do servidor : "
   CASE nMsg == MSG_AS40002        ; cMsg := "AS/400 Conexão"
   CASE nMsg == MSG_AS40003        ; cMsg := "Erro de conexão//Verifique o W400ENV set de ambiente"
   CASE nMsg == MSG_AS40004        ; cMsg := "Verifique arquivo (%FILE%)"
   CASE nMsg == MSG_AS40005        ; cMsg := "Nome da biblioteca de configuração : "
   // .........................................................................
   // .........................................................................
   CASE nMsg == MSG_DFDATEFT01     ; cMsg := "Da data :"
   CASE nMsg == MSG_DFDATEFT02     ; cMsg := "At‚ a data :"
   // .........................................................................
   // .........................................................................
   CASE nMsg == MSG_DFPRNLAB01     ; cMsg := "Colunas por etiqueta"
   CASE nMsg == MSG_DFPRNLAB02     ; cMsg := "Espaço por etiqueta"
   CASE nMsg == MSG_DFPRNLAB03     ; cMsg := "Comprimento da etiqueta"
   CASE nMsg == MSG_DFPRNLAB04     ; cMsg := "Etiqueta"
   CASE nMsg == MSG_DFPRNLAB05     ; cMsg := "Função para aplicar"
   // .........................................................................
   // .........................................................................
   CASE nMsg == MSG_DFCOL2PRN01    ; cMsg := "Imprimir coluna"
   // .........................................................................
   // .........................................................................
   CASE nMsg == MSG_DFCHKDBF01     ; cMsg := "O Cabeçalho do arquivo//"
   CASE nMsg == MSG_DFCHKDBF02     ; cMsg := "//está com número incorreto registro"
   CASE nMsg == MSG_DFCHKDBF03     ; cMsg := "//Header setting   : "
   CASE nMsg == MSG_DFCHKDBF04     ; cMsg := "//Real setting     : "
   CASE nMsg == MSG_DFCHKDBF05     ; cMsg := "//Corrigir o erro?"
   CASE nMsg == MSG_DFCHKDBF06     ; cMsg := "////Se não, atualize o índice "
   CASE nMsg == MSG_DFCHKDBF07     ; cMsg := "//voçe pode destruir alguns dados,quando for reconstruir os índices"
   CASE nMsg == MSG_DFCHKDBF08     ; cMsg := "//LEMBRE-SE : Faça um BACKUP antes de atualizar os dados"
   // .........................................................................
   // .........................................................................
   CASE nMsg == MSG_DDFILEST01     ; cMsg := "Escolha campo estatístico"
   CASE nMsg == MSG_DDFILEST02     ; cMsg := "Outro"
   // .........................................................................
   // .........................................................................
   CASE nMsg == MSG_DFFILEDLG01    ; cMsg := "^Caminho"
   CASE nMsg == MSG_DFFILEDLG02    ; cMsg := "^Arvore"
   CASE nMsg == MSG_DFFILEDLG03    ; cMsg := "^Unidade"
   CASE nMsg == MSG_DFFILEDLG04    ; cMsg := "^WildCard"
   CASE nMsg == MSG_DFFILEDLG05    ; cMsg := "^Arquivos"
   CASE nMsg == MSG_DFFILEDLG06    ; cMsg := "Nome"
   CASE nMsg == MSG_DFFILEDLG07    ; cMsg := "Dim"
   CASE nMsg == MSG_DFFILEDLG08    ; cMsg := "Data"
   CASE nMsg == MSG_DFFILEDLG09    ; cMsg := "Tempo"
   CASE nMsg == MSG_DFFILEDLG10    ; cMsg := "Arquivo de diálogo"
   // .........................................................................
   // .........................................................................
ENDCASE

#ifdef __XPP__
cMsg := STRTRAN( cMsg, "|", "" )
#endif

RETURN cMsg

* =============================================================================
FUNCTION dbDeState( nDeState )
* =============================================================================
LOCAL cRet := ""

DO CASE
   CASE nDeState == DE_STATE_INK  ; cRet := dfStdMsg( MSG_DE_STATE_INK  )
   CASE nDeState == DE_STATE_ADD  ; cRet := dfStdMsg( MSG_DE_STATE_ADD  )
   CASE nDeState == DE_STATE_MOD  ; cRet := dfStdMsg( MSG_DE_STATE_MOD  )
   CASE nDeState == DE_STATE_DEL  ; cRet := dfStdMsg( MSG_DE_STATE_DEL  )
   CASE nDeState == DE_STATE_COPY ; cRet := dfStdMsg( MSG_DE_STATE_COPY )
   CASE nDeState == DE_STATE_QRY  ; cRet := dfStdMsg( MSG_DE_STATE_QRY  )
ENDCASE

//#ifdef __XPP__
   //IF LEN(cRet)>2
      //cRet := SUBSTR( cRet, 2, LEN(cRet)-2 )
   //ENDIF
//#endif

RETURN cRet
