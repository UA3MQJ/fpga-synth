object Form1: TForm1
  Left = 192
  Top = 124
  Width = 706
  Height = 675
  Caption = 'RAW2MIF'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 42
    Height = 13
    Caption = 'RAW file'
  end
  object Edit1: TEdit
    Left = 8
    Top = 24
    Width = 497
    Height = 21
    TabOrder = 0
    Text = 
      'D:\FPGA_Projects\fpga-synth(git)\Samples\Drums\TR606KIT\606SNAR.' +
      'raw'
  end
  object Memo1: TMemo
    Left = 8
    Top = 56
    Width = 497
    Height = 497
    TabOrder = 1
  end
  object Button1: TButton
    Left = 512
    Top = 24
    Width = 75
    Height = 25
    Caption = 'Open'
    TabOrder = 2
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 592
    Top = 24
    Width = 75
    Height = 25
    Caption = 'Read'
    TabOrder = 3
    OnClick = Button2Click
  end
  object OpenDialog1: TOpenDialog
    Left = 536
    Top = 40
  end
end
