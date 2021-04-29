Attribute VB_Name = "a_FluidDefinition"
Option Explicit
Option Base 1

' Define fluid components here
' set i_XX = 0 to ignore the component

Public Const i_NaCl = 1 'reference number
Public Const i_KCl = 2 'reference number
Public Const i_CaCl2 = 3 'reference number
'Public Const i_MgCl2 = 4 'reference number
'Public Const i_SrCl2 = 5 'reference number
Public Const i_CO2 = 4 'reference number
Public Const i_N2 = 5 'reference number
Public Const i_CH4 = 6 'reference number
Public Const i_H2 = 7 'reference number

Public Const nX_gas = 4
Public Const nX_salt = 3

Public Gases(nX_gas + 1) As New GasDataRecord

Sub DefineGases()
    'Set Gases = Array(CO2, N2, CH4, H2O)
    If i_CO2 > 0 Then
        Set Gases(i_CO2 - nX_salt) = CO2
    End If
    
    If i_N2 > 0 Then
        Set Gases(i_N2 - nX_salt) = N2
    End If
    
    If i_CH4 > 0 Then
        Set Gases(i_CH4 - nX_salt) = CH4
    End If
    
    If i_H2 > 0 Then
        Set Gases(i_H2 - nX_salt) = H2
    End If
    
    Set Gases(nX_gas + 1) = H2O
    
End Sub

Sub DefineSalts()
    'DefineSalts
    Salts(1) = NaCl
    Salts(2) = KCl
    Salts(3) = CaCl2
    Brine_liq.DefineLimits
End Sub
