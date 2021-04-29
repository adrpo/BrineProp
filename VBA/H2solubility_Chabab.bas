Attribute VB_Name = "H2solubility_Chabab"
' by Henning Francke francke@gfz-potsdam.de
' 2021 GFZ Potsdam
' Chabab, S., Théveneau, P., Coquelet, C., Corvisier, J. & Paricaud, P. Measurements and predictive models of high-pressure H2 solubility in brine (H2O+NaCl) for underground hydrogen storage application. Int. J. Hydrogen Energy 45, 32206–32220 (2020).
' For H2 solubility in pure water (Eq. (13)): 273.15 < T (K) < 373.15; 1 < P (bar) < 203
' For H2 solubility in NaCl-brine (Eq. (12)): 323.15 < T (K) < 373.15; 10 < P (bar) < 230; 0 < molality (mol/kgw) < 5

Option Explicit
Option Base 1

'Const ignoreLimitH2_T = False
'Const ignoreLimitH2_p = False
'Const ignoreLimitH2_b = False

'Public Const M_H2 = 1.008 * 2 / 1000 '[kg/mol]
'Function MM_H2() As Double
'    MM_H2 = M_H2
'End Function

Function solubility_H2_pTX_Chabab2020(p As Double, T As Double, Xin, p_gas)
    ' converts from molaltity to mass fraction
    Dim x: x = CheckMassVector(Xin, Brine.nX)
    If VarType(x) = vbString Then
       solubility_H2_pTX_Chabab2020 = x
       Exit Function
    End If

    Dim solu: solu = solubility_H2_pTX_Chabab2020_molality(p, T, x, p_gas) ' mol/kg_H2O
    If VarType(solu) = vbString Then
      solubility_H2_pTX_Chabab2020 = solu
      Exit Function
    End If
    Dim X_H2O As Double: X_H2O = x(Brine.nX) ' to be used in solubility_H2_pTX_Li2018
    solubility_H2_pTX_Chabab2020 = solu * H2.MM * X_H2O 'molality->mass fraction
End Function

Function solubility_H2_pTX_Chabab2020_molality(p As Double, T As Double, Xin, p_gas)
    ' passes on p_gas + p_H2O as absolute pressure to correlation function
    ' returns mass fraction
    
    Dim x: x = CheckMassVector(Xin, Brine.nX)
    If VarType(x) = vbString Then
       solubility_H2_pTX_Chabab2020_molality = x
       Exit Function
    End If
    
    Dim molalities
    molalities = ToDouble(massFractionsToMolalities(x, Brine.MM_vec))
    If VarType(molalities) = vbString Then
        solubility_H2_pTX_Chabab2020_molality = molalities
        Exit Function
    End If
    
    Dim m_Cl As Double, m_Na As Double, m_K As Double, m_Ca As Double, m_Mg As Double, m_SO4 As Double
    m_Cl = molalities(i_NaCl) + molalities(i_KCl) + 2 * molalities(i_CaCl2) ' + 2 * molalities(i_MgCl2)
    m_Na = molalities(i_NaCl)
    m_K = molalities(i_KCl)
    m_Ca = molalities(i_CaCl2)
    m_Mg = 0 ' molalities(i_MgCl2)
    m_SO4 = 0 ' molalities(i_MgCl2)

    Dim b_NaCl As Double: b_NaCl = m_Na + m_K + 2 * m_Ca + 2 * m_Mg
    ' Debug.Print "b_NaCl: "; b_NaCl
    
    Dim p_H2O: p_H2O = IAPWS.Waterpsat_T(T)
    Dim solu: solu = solubility_H2_pTb_Chabab2020_molality(p_gas + p_H2O, T, b_NaCl) ' mol/kg_H2O
    If VarType(solu) = vbString Then
      solubility_H2_pTX_Chabab2020_molality = solu
      Exit Function
    End If
    solubility_H2_pTX_Chabab2020_molality = solu
End Function

Function solubility_H2_pTb_Chabab2020_molality(p As Double, T As Double, b_NaCl As Double)  ' conversion mole fraction to molality
    Dim y_H2: y_H2 = solubility_H2_pTb_Chabab2020_y(p, T, b_NaCl) ' mole fraction b_H2 / b/H2O
    If VarType(y_H2) = vbString Then
        solubility_H2_pTb_Chabab2020_molality = y_H2
    Else
        solubility_H2_pTb_Chabab2020_molality = y_H2 / (1 - y_H2) / H2O.MM  ' mol/kg_H2O
    End If
End Function

' equations from article

Function solubility_H2_pTb_Chabab2020_y(p As Double, T As Double, b_NaCl As Double) ' mole fraction b_H2 / b/H2O
    ' p is absolute pressure, here p_H2 + p_H2O
    
    ' Debug.Print "p="; p / 100000#; " bar, b_NaCl="; b_NaCl
    Dim T_min As Double: T_min = IIf(b_NaCl > 0, 323.15, 273.15)
    Dim T_max As Double: T_max = 373.15
    Dim p_min As Double: p_min = IIf(b_NaCl > 0, 10 ^ 5, 10 ^ 6)
    Dim p_max As Double: p_max = 23000000#
    Dim b_max As Double: b_max = 5
    
    Dim msg As String
    msg = RangeCheck_pTb(p, T, b_NaCl, ignoreLimitH2_p, ignoreLimitH2_T, ignoreLimitH2_b, p_min, p_max, T_min, T_max, b_max, "solubility_H2_pTb_Chabab2020_molality")
    If Len(msg) > 0 Then
        solubility_H2_pTb_Chabab2020_y = msg
        Exit Function
    End If
    
'    If Not (ignoreLimitH2_T Or (T_min <= T And T <= T_max)) Then
'        solubility_H2_pTb_Chabab2020_molality = "# T=" & T - 273.15 & "°C out of range (GasData.VirialEquation)"
'        Exit Function
'    End If
'    If Not (ignoreLimitH2_p Or (p_min <= p And p <= p_max)) Then
'        solubility_H2_pTb_Chabab2020_molality = "# p=" & p / 100000# & " out of range {" & p_min / 100000# & "..." & p_max / 100000# & " bar} (solubility_H2_pTb_Chabab2020_molality)"
'        Exit Function
'    End If
    
    Dim x_H2_0 As Double: x_H2_0 = solubility_H2_pT_Chabab2020_y(p, T)
    Dim a1 As Double: a1 = 0.018519
    Dim a2 As Double: a2 = -0.30185103
    
    'Dim x_H2 As Double: x_H2
    solubility_H2_pTb_Chabab2020_y = x_H2_0 * Exp(a1 * b_NaCl ^ 2 + a2 * b_NaCl) 'equ. 12 (mol H2 per kg H2O)
 End Function

Private Function solubility_H2_pT_Chabab2020_y(p As Double, T As Double)
' returns salt-free mole fraction
    Dim p_bar As Double: p_bar = p / 100000#
    
    If Not p > 0 Then ' = 0
       solubility_H2_pT_Chabab2020_y = 0
       Exit Function
    ElseIf p < 0 Then
       solubility_H2_pT_Chabab2020_y = "#p_gas negative! (GasData.solubility_H2_pT_Chabab2020_molality)"
       Exit Function
    End If
    
    Dim b1 As Double: b1 = 0.0000003338844
    Dim b2 As Double: b2 = 0.0363161
    Dim b3 As Double: b3 = -0.00020734
    Dim b4 As Double: b4 = -2.1301815E-09
    
    
    solubility_H2_pT_Chabab2020_y = b1 * p_bar * T + b2 * p_bar / T + b3 * p_bar + b4 * p_bar ^ 2 'equ. 13
End Function
