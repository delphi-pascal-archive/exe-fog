object frmMain: TfrmMain
  Left = 219
  Top = 126
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  ClientHeight = 268
  ClientWidth = 522
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -14
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poScreenCenter
  ShowHint = True
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 120
  TextHeight = 16
  object pnlFilePath: TPanel
    Left = 9
    Top = 10
    Width = 504
    Height = 60
    BevelInner = bvRaised
    BevelOuter = bvLowered
    TabOrder = 0
    object lbFile: TLabel
      Left = 10
      Top = 21
      Width = 25
      Height = 16
      Caption = 'File:'
    end
    object edtFilePath: TEdit
      Left = 39
      Top = 17
      Width = 356
      Height = 24
      Color = clBtnFace
      ReadOnly = True
      TabOrder = 1
    end
    object btnBrowse: TButton
      Left = 401
      Top = 15
      Width = 93
      Height = 31
      Hint = 'Browse'
      Caption = '&Browse...'
      TabOrder = 0
      OnClick = btnBrowseClick
    end
  end
  object pnlSettings: TPanel
    Left = 9
    Top = 79
    Width = 504
    Height = 93
    BevelInner = bvRaised
    BevelOuter = bvLowered
    TabOrder = 1
    object line: TBevel
      Left = 10
      Top = 53
      Width = 484
      Height = 6
      Shape = bsTopLine
    end
    object brProgress: TProgressBar
      Left = 10
      Top = 63
      Width = 484
      Height = 19
      Hint = 'Progress'
      Smooth = True
      TabOrder = 2
    end
    object cbxBackup: TCheckBox
      Left = 10
      Top = 7
      Width = 138
      Height = 21
      Hint = 'Create backup file'
      Caption = 'Create &backup file'
      Checked = True
      State = cbChecked
      TabOrder = 0
    end
    object cbxSaveoverlay: TCheckBox
      Left = 10
      Top = 27
      Width = 138
      Height = 21
      Hint = 'Preverse extra data'
      Caption = 'Preverse &extra data'
      TabOrder = 1
    end
    object edtMutex: TEdit
      Left = 345
      Top = 20
      Width = 149
      Height = 24
      Hint = 'Mutex name (max: 31 symbols)'
      Enabled = False
      TabOrder = 4
      Text = 'MUTEX_ID_00000001'
    end
    object cbxMutex: TCheckBox
      Left = 226
      Top = 27
      Width = 110
      Height = 21
      Hint = 'Create mutex'
      Caption = 'Create mutex'
      TabOrder = 3
      OnClick = cbxMutexClick
    end
  end
  object pnlActions: TPanel
    Left = 9
    Top = 177
    Width = 504
    Height = 61
    BevelInner = bvRaised
    BevelOuter = bvLowered
    TabOrder = 2
    object btnQuit: TButton
      Left = 401
      Top = 15
      Width = 93
      Height = 31
      Hint = 'Quit'
      Caption = '&Quit'
      TabOrder = 2
      OnClick = btnQuitClick
    end
    object btnProtect: TButton
      Left = 185
      Top = 15
      Width = 92
      Height = 31
      Hint = 'Protect PE file'
      Caption = '&Protect'
      Enabled = False
      TabOrder = 0
      OnClick = btnProtectClick
    end
    object btnTest: TButton
      Left = 293
      Top = 15
      Width = 92
      Height = 31
      Hint = 'Test'
      Caption = '&Test'
      Enabled = False
      TabOrder = 1
      OnClick = btnTestClick
    end
  end
  object brStatus: TStatusBar
    Left = 0
    Top = 249
    Width = 522
    Height = 19
    Panels = <
      item
        Text = 'Ready...'
        Width = 100
      end>
  end
  object dlgOpen: TOpenDialog
    Filter = 'EXE Files (*.exe)|*.exe|All Files (*.*)|*.*'
    InitialDir = '.'
    Options = [ofHideReadOnly, ofExtensionDifferent, ofPathMustExist, ofFileMustExist]
    Title = 'Select of files...'
    Left = 15
    Top = 152
  end
end
