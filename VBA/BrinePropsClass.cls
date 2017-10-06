VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "BrinePropsClass"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
    Public p As Double 'Absolute pressure of medium
    Public T As Double  'Temperature of medium
    'h   As Double 'Specific enthalpy
    'h_g As Double 'Specific enthalpy gas phase
    'h_l As Double 'Specific enthalpy liquid phase
    Public x As Double 'gas mass fraction
    'cp_l As Double 'Specific heat capacity liquid phase
    Private pX_l() As Double '(nX) composition of liquid phase (set and returned via property functions)
    Private pX_g() As Double '(nX_gas + 1)  composition of gas phase (set and returned via property functions)
    'Private Xi_l() As Double '(nX_salt) 'salt mass fractions in liquid phase
    'Private Xi_g() As Double '(nX_gas) gas mass fractions in gas phase
    'p_H2O  As Double
    Private pp_gas() As Double '(nX_gas + 1) As Double
    Public p_degas As Double
    Public phase As Integer '0 - unknown, 1 - one phase, 2 - two phases
    'nu_l As Double
    'nu_g As Double
    Public error As Variant 'String

Public Property Get X_l() As Variant
    X_l = pX_l 'autocast to Variant
End Property
Public Property Let X_l(Value As Variant)
    pX_l = ToDouble(Value)
End Property

Public Property Get X_g() As Variant
    X_g = pX_g 'autocast to Variant
End Property
Public Property Let X_g(Value As Variant)
    pX_g = ToDouble(Value)
End Property

Public Property Get p_gas() As Variant
    p_gas = pp_gas 'autocast to Variant
End Property
Public Property Let p_gas(Value As Variant)
    pp_gas = ToDouble(Value)
End Property
