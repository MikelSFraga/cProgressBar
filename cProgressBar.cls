VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "cProgressBar"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
'-----------------------------------------------------------------------------------------
' Classe          : cProgressBar Class
' Version         : 1.2.1
' Data            : 21/09/2018
' Developer       : Mikel S Fraga
' Contato/GitHub  : https://github.com/MikelSFraga/CustomProgressBar
' Descri��o       : Cria��o de um Progress Bar Personalizada, atrav�s da cria��o de um Userform
'                   dinamicamente exibindo a evolu��o de um processo executado simultaneamente.
'-----------------------------------------------------------------------------------------
Option Explicit
'=========================================================================================
' DECLARA��O DE VARI�VEIS PERSONALIZADAS DA CLASSE.
Private Type SystemAbout
  ClassName                             As String
  Contributor                           As String
  Created                               As Date
  Description                           As String
  Developer                             As String
  GitHubPage                            As String
  Modified                              As Date
  References                            As String
  Version                               As String
End Type
Public Enum BarType
  Progress = 0
  DisplayText = 1
End Enum
Public Enum CountType
  Percentage = 0
  Quantity = 1
End Enum
'=========================================================================================

'=========================================================================================
' DECLARA��O DE VARI�VEIS CONSTANTES DA CLASSE.
  Private Const aTagForm                As String = "frmCPBar"
  Private Const aNameFrame              As String = "fraCPBar"
  Private Const aNameBar                As String = "ctlCPBar"
  Private Const aMaxWidthBar            As Integer = 300
  Private Const aClass                  As String = "ApiFunction"
  Private Const aOpEx                   As String = "Option Explicit"
  Private Const aHtmlClass              As String = "select-menu-item-text css-truncate-target"
'=========================================================================================

'=========================================================================================
' DECLARA��O DE VARI�VEIS/PROPRIEDADES PRIVADAS DA CLASSE.
'Declare Controls
  #If DevelopMode Then
    Private aControl                    As VBIDE.VBComponent
    Private aFrame                      As MSForms.Frame
    Private aProgressBar                As MSForms.control
    Private aXmlHttp                    As MSXML2.XMLHTTP60
    Private aHtmlDoc                    As MSHTML.HTMLDocument
  #Else
    Private aControl                    As Object 'VBIDE.VBComponent
    Private aFrame                      As Object 'MSForms.Frame
    Private aProgressBar                As Object 'MSForms.Control
    Private aXmlHttp                    As Object 'MSXML2.XMLHTTP60
    Private aHtmlDoc                    As Object 'MSHTML.HTMLDocument
  #End If
  Private aFormPB                       As Object 'MSForms.UserForm
  Private aFormOrigin                   As Object 'MSForms.UserForm
  Private aHtmlElem                     As Object 'MSHTML.HTMLElementCollection
'Declare UDV (User Definition Variable)
  Private aASystem                      As SystemAbout
  Private aTBar                         As BarType
  Private aTCount                       As CountType
'Declare Validate
  Private aAbout                        As String
  Private aApiClass                     As Boolean
  Private aNameForm                     As String
  Private aRecordMax                    As Long
  Private aRecordNow                    As Long
  Private aPercentil                    As Double
  Private aTitle                        As String
  Private aVisible                      As Boolean
  Private aRetMsg                       As VBA.VbMsgBoxResult
'=========================================================================================

'=========================================================================================
' DECLARA��O DE VARI�VEIS/PROPRIEDADES PUBLICAS DA CLASSE.
'Propriedade para o Tipo de Barra do ProgressBar.
Public Property Get BarType() As BarType: BarType = aTBar: End Property
Public Property Let BarType(pTBar As BarType): aTBar = pTBar: End Property
'Propriedade para o Tipo de Contador do ProgressBar.
Public Property Get CountType() As CountType: CountType = aTCount: End Property
Public Property Let CountType(pTCount As CountType): aTCount = pTCount: End Property
Public Property Set FormStart(ByVal pForm As Object)
  'Inicia o objeto aFormPB e captura o seu Caption.
  Set aFormOrigin = pForm: aNameForm = aFormOrigin.Name
End Property
'Propriedade para definir o m�ximo de registros para o ProgressBar.
Public Property Get RecordMax() As Long: RecordMax = aRecordMax: End Property
Public Property Let RecordMax(pRecordMax As Long): aRecordMax = pRecordMax: End Property
'Propriedade para definir o t�tulo do Userform do ProgressBar.
Public Property Get TitleToForm() As String: TitleToForm = aTitle: End Property
Public Property Let TitleToForm(pTitle As String): aTitle = pTitle
  'Verifica se o Userform foi inicializado.
  If Not aFormPB Is Nothing Then aFormPB.Caption = aTitle
End Property
'Propriedade para definir o se o Userform do ProgressBar esta exibido ou n�o.
Public Property Get VisibleForm() As Boolean: VisibleForm = aVisible: End Property
Public Property Let VisibleForm(pVisible As Boolean)
  'Verifica se o Userform foi inicializado.
  If Not aFormPB Is Nothing Then aVisible = pVisible Else Exit Property
  'Define a propriedade
  Select Case pVisible
    Case False: aFormPB.Hide
    Case True: aFormPB.Show vbModeless
  End Select
End Property
'=========================================================================================

'=========================================================================================
' DECLARA��O DOS M�TODOS PUBLICOS DA CLASSE.
Public Sub About()
  'Limpa o valor da atributo aAbout.
  aAbout = ""
  'Inicia um bloco With
  With aASystem
    'Constroi o texto a ser exibido.
    aAbout = aAbout & "Classe: " & .ClassName & VBA.vbNewLine
    aAbout = aAbout & "Vers�o: " & .Version & VBA.vbNewLine
    aAbout = aAbout & "Criado em: " & .Created & VBA.vbNewLine
    aAbout = aAbout & "Modificado em: " & .Modified & VBA.vbNewLine
    aAbout = aAbout & "Desenvolvido por: " & .Developer & VBA.vbNewLine
    aAbout = aAbout & VBA.vbNewLine
    aAbout = aAbout & "Endere�o GitHub:" & VBA.vbNewLine & .GitHubPage
    aAbout = aAbout & VBA.vbNewLine & VBA.vbNewLine
    aAbout = aAbout & "Descri��o:" & VBA.vbNewLine & .Description
    aAbout = aAbout & VBA.vbNewLine & VBA.vbNewLine
    aAbout = aAbout & "Colaboradores:" & VBA.vbNewLine & .Contributor
  End With
  'Exibe todas as configura��es da classe.
  MsgBox aAbout, vbInformation, "Sobre a classe"
End Sub
Public Sub Alter(Optional ByVal pBarType As BarType = Progress, _
                 Optional ByVal pCountType As CountType = Percentage, _
                 Optional ByVal pVisibleForm As Boolean = False)
  'Altera tipo de ProgressBar a ser utilizado.
  aTBar = pBarType: aTCount = pCountType
  'Realiza altera��o das informa��es.
  Call CreateCPBar(pVisibleForm)
End Sub
Public Sub Initialize(Optional ByVal pVisibleForm As Boolean = True)
  'Verifica se existe algum formul�rio
  'residual de alguma falha anterior da rotina.
  Call DeleteCPBar(aNameForm)
  'Chama rotina para cria��o dos controles do ProgressBar.
  Call CreateCPBar(pVisibleForm)
End Sub
Public Sub Update(ByVal pRecordNow As Long, Optional ByVal pRecordMax As Long, _
                  Optional ByVal pTextBar As String = "Carregando Registros...")
  'Confronto entre atributo e par�metro RecordMax.
  If pRecordMax > 0 Then aRecordMax = pRecordMax
  'Define o percentual de pRecordNow sobre aRecordMax.
  aPercentil = pRecordNow / aRecordMax
  'Define valor retorno contador do ProgressBar.
  aFrame.Caption = VBA.IIf(aTCount = Percentage, _
          VBA.Format(aPercentil * 100, "0.00") & "% Conclu�do.", _
          pRecordNow & " de " & aRecordMax & " Conclu�do.")
  'Define valor retorno para a barra do ProgressBa.
  If aTBar = Progress Then
    aProgressBar.Width = aMaxWidthBar * aPercentil
  Else
    aProgressBar.Text = pTextBar
  End If
  'Atualiza a barra em tempo de execu��o.
  VBA.DoEvents
  'Oculta Userform se for o �ltimo registro.
  If pRecordNow = aRecordMax Then aFormPB.Hide
End Sub
'=========================================================================================

'=========================================================================================
' DECLARA��O DOS M�TODOS PRIVADOS DA CLASSE.
Private Function IsClassPresent(ByVal pClass As String) As Boolean
  'Cria um objeto local do tipo VBComponent.
  Dim aVbComp                           As VBComponent
  'Define um valor padr�o para retorno da classe.
  IsClassPresent = False
  'Realiza um lan�o entre todos os componentes do projeto.
  For Each aVbComp In ThisWorkbook.VBProject.VBComponents
    'Testa todos os componentes, verificando se o ApiFunction esta presente.
    If aVbComp.Name = pClass Then IsClassPresent = True: Exit Function
  Next aVbComp
End Function
Private Sub ClassUpdate()
  'Instancia os objetos que ser�o utilizados.
  #If DevelopMode Then
    Set aXmlHttp = New MSXML2.XMLHTTP60
    Set aHtmlDoc = New MSHTML.HTMLDocument
  #Else
    Set aXmlHttp = CreateObject("MSXML2.XMLHTTP60")
    Set aHtmlDoc = CreateObject("MSHTML.HTMLDocument")
  #End If
  'Realiza uma requisi��o ao reposit�rio do GitHub.
  With aXmlHttp: .Open "GET", aASystem.GitHubPage, False
    .send: aHtmlDoc.body.innerHTML = .responseText: End With
  'Verifica se existe nova vers�o da classe no GitHub.
  If aHtmlDoc.getElementsByClassName(aHtmlClass)(1).innerText > aASystem.Version Then
    'Exibe mensagem/alerta, sobre a disponibilidade de nova vers�o da classe.
    aRetMsg = MsgBox("J� existe dispon�vel no Reposit�rio do GitHub, uma nova vers�o desta classe." & _
          VBA.vbNewLine & VBA.vbNewLine & "Gostaria de acessar o endere�o abaixo para baix�-la:" & _
          VBA.vbNewLine & aASystem.GitHubPage, vbInformation Or vbYesNo, "Nova vers�o dispon�vel")
    'Se o desenvolvedor optar por baixar, ele ser� redirecionado ao reposit�rio do GitHub.
    If aRetMsg = vbYes Then ThisWorkbook.FollowHyperlink Address:=aASystem.GitHubPage, NewWindow:=True
  End If
End Sub
Private Sub ClassAbout()
  'Define os valores que ser�o exibidos sobre a classe.
  With aASystem
    .ClassName = "cProgressBar"
    .Version = "v1.2.1"
    .Created = "19/06/2017"
    .Modified = "24/09/2018"
    .Developer = "Mikel S Fraga"
    .GitHubPage = "https://github.com/MikelSFraga/CustomProgressBar"
    .Description = "Cria��o de uma Barra de Progresso Personalizada, atrav�s da constru��o " & _
                   "de um Userform, que � dinamicamente exibido em tempo de execu��o, e que mostra " & _
                   "a evolu��o de um determinado processo em andamento."
    .Contributor = "Tom�s V�squez (http://www.tomasvasquez.com.br)" & VBA.vbNewLine & _
                   "M�rcio Ribeiro (https://www.youtube.com/c/mastermrbrasil)" & VBA.vbNewLine & _
                   "Rafael Rabaquim (https://www.youtube.com/c/cafecomvba)" & VBA.vbNewLine & _
                   "Dinis Fernandes (https://www.youtube.com/user/0nadadenada)" & VBA.vbNewLine & _
                   "Giovani Franco (https://www.youtube.com/user/giovani6666)"
  End With
End Sub
'=========================================================================================

'=========================================================================================
' DECLARA��O DOS EVENTOS DA CLASSE.
Private Sub Class_Initialize()
  'Preenche a propriedade do objeto SystemAbout.
  Call ClassAbout
  'Verifica atualiza��o da biblioteca.
  #If DevelopMode Then
    Call ClassUpdate
  #End If
  'Define alguns atributos padr�es.
  aTBar = Progress: aTCount = Percentage: aTitle = "": aVisible = False
End Sub
Private Sub Class_Terminate()
  'Deleta o formul�rio criado.
  Call DeleteCPBar(aNameForm)
  'Clear the variables.
  Set aProgressBar = Nothing
  Set aFrame = Nothing
  Set aFormOrigin = Nothing
  Set aFormPB = Nothing
  Set aControl = Nothing
End Sub
'=========================================================================================

'=========================================================================================
' DECLARA��O DOS EVENTOS DA CLASSE.
Private Sub DeleteCPBar(Optional ByVal pName As String = "")
  'Realiza um la�o entre os componentes do VBE.
  For Each aControl In ThisWorkbook.VBProject.VBComponents
    'Verifica aqueles do tipo Forms.
    If aControl.Type = 3 And aControl.Name <> pName Then
      'Inicia uma tratativa de erro.
      On Error Resume Next
      'Identifica o formul�rio com o Valor da Tag.
      If aControl.Properties.Item("Tag") = aTagForm Then
        'Apaga o Userform com as caracter�sticas acima.
        ThisWorkbook.VBProject.VBComponents.Remove aControl
      End If
      'Desabilita o tratamento de erro.
      On Error GoTo -1
    End If
  Next aControl
  'Prepara objeto, para execu��o em pr�ximas rotinas.
  Set aControl = Nothing
End Sub
Private Sub CreateCPBar(Optional ByVal pVisibleForm As Boolean = False)
  'This is to stop screen flashing while creating form
  'Application.VBE.MainWindow.Visible = False
  'Cria novo formul�rio.
  Call CreateNewForm
  'Cria caixa de grupo.
  Call CreateNewFrame
  'Cria barra com r�tulo.
  Call CreateNewBar
  'Abre o formul�rio que foi criado.,
  Set aFormPB = UserForms(UserForms.Count - 1)
  If pVisibleForm Then aFormPB.Show vbModeless: aVisible = True
End Sub
Private Sub CreateNewForm()
  'Verifica se j� existe um userform aberto.
  If aFormPB Is Nothing Then
    'Atribui o novo VbComponent ao atributo aForm.
    Set aControl = ThisWorkbook.VBProject.VBComponents.Add(3)
    'Adiciona o Userform criado a lista de Userforms.
    VBA.UserForms.Add aControl.Name
    'Atribui o novo Userform ao atributo aForm.
    Set aFormPB = VBA.UserForms(UserForms.Count - 1)
  End If
  'Chama rotina para configura��o do Userform.
  Call FormatNewForm
End Sub
Private Sub FormatNewForm()
  'Configura a estrutura do novo Userform.
  With aFormPB
    '.Properties("Name") = "frmPBar"
    .Tag = aTagForm
    .Caption = VBA.IIf(aTitle = "", "Custom Progress Bar", aTitle)
    .Width = 344
    .Height = VBA.IIf(aTBar = Progress, 75, 85)
  End With
End Sub

Private Sub CreateNewFrame()
  'Atribui o novo Frame ao atributo aFrame.
  If aFrame Is Nothing Then _
    Set aFrame = aFormPB.Controls.Add("Forms.frame.1", aNameFrame, True)
  'Chama rotina para configura��o do Frame.
  Call FormatNewFrame
End Sub
Private Sub FormatNewFrame()
  'Configura a estrutra do novo Frame.
  With aFrame
    .Height = VBA.IIf(aTBar = Progress, 34, 43)
    .Left = 6
    .Top = 6
    .Width = 320
    .Caption = ""
    .SpecialEffect = fmSpecialEffectSunken
  End With
End Sub
Private Sub CreateNewBar()
  'Verifica se o objeto aProgressBar esta instanciado.
  If Not aProgressBar Is Nothing Then
    'Remove o controle atual do Userform.
    aFrame.Controls.Remove aProgressBar.Name
    'Limpa objeto para nova instancia.
    Set aProgressBar = Nothing
  End If
  'Atribui a no Control ao atributo aProgressBar.
  Set aProgressBar = aFrame.Controls.Add(VBA.IIf( _
                     aTBar = Progress, "Forms.Label.1", "Forms.TextBox.1"), _
                     aNameBar, True)
  'Chama rotina para configura��o da Barra.
  Call FormatNewBar
End Sub
Private Sub FormatNewBar()
  'Configura a estrutura do novo Control.
  With aProgressBar
    .Height = VBA.IIf(aTBar = Progress, 12, 18)
    .Left = VBA.IIf(aTBar = Progress, 9, 12)
    .Top = VBA.IIf(aTBar = Progress, 8, 12)
    .Width = VBA.IIf(aTBar = Progress, 0, aMaxWidthBar)
    .BackColor = VBA.IIf(aTBar = Progress, vbBlue, &H8000000F)
    If aTBar <> Progress Then .Locked = True
  End With
End Sub
'=========================================================================================
