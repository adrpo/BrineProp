Attribute VB_Name = "H2solubility_Li"
' by Henning Francke francke@gfz-potsdam.de
' 2021 GFZ Potsdam
'Li, D., Beyer, C., & Bauer, S. (2018). A unified phase equilibrium model for hydrogen solubility and solution density. International Journal of Hydrogen Energy, 43(1), 512–529. https://doi.org/10.1016/j.ijhydene.2017.07.228
' NOT USED

Option Explicit
Option Base 1

Const ignoreLimitH2_T = False
Const ignoreLimitH2_p = False
Const ignoreLimitH2_b = False
'Const M_H2 = 1.00784 * 2 * 0.001

Public Type VirialCoeffs
    'Public name As String  'Name of ideal gas
    a As Double
    b As Double
    c As Double
    d As Double
    e As Double
    f As Double
    p_min As Double
    p_max As Double
    T_min As Double
    T_max As Double
End Type


' Public Const nX_salt = 3

' Public Const nX_gas = 3



Function solubility_H2_pTX_Li2018(p As Double, T As Double, Xin, p_gas)
    Dim solu ' mol/kg_H2O
    Dim X_H2O As Double
    solu = solubility_H2_pTX_Li2018_molality(p, T, Xin, p_gas, X_H2O)
    If VarType(solu) = vbString Then
      solubility_H2_pTX_Li2018 = solu
      Exit Function
    End If
    solubility_H2_pTX_Li2018 = solu * H2.MM * X_H2O 'molality->mass fraction
End Function

Function solubility_H2_pTX_Li2018_molality(p As Double, T As Double, Xin, p_gas, Optional ByRef X_H2O As Double)   'solubility calculation of N2 in seawater Mao&Duan(2006)
    'Li, D., Beyer, C., & Bauer, S. (2018). A unified phase equilibrium model for hydrogen solubility and solution density. International Journal of Hydrogen Energy, 43(1), 512–529. https://doi.org/10.1016/j.ijhydene.2017.07.228
    ' 273-373 K, 1-50 MPa and 0-5 mol/kg NaCl
    'Calculates solubility for y_H2 = p_gas/p
    Dim T_min As Double: T_min = 0 + 273.15
    Dim T_max As Double: T_max = 100 + 273.15
    Dim p_min As Double: p_min = 1 * 10 ^ 6
    Dim p_max As Double: p_max = 50 * 10 ^ 6
    Dim b_max As Double: b_max = 5
    
    If Not p_gas > 0 Then ' = 0
       solubility_H2_pTX_Li2018_molality = 0
       Exit Function
    ElseIf p_gas < 0 Then
       solubility_H2_pTX_Li2018_molality = "#p_gas negative! (GasData.solubility_H2_pTX_Li2018_molality)"
       Exit Function
    ElseIf p_gas > p Then
       solubility_H2_pTX_Li2018_molality = "#p_gas > p ! (GasData.solubility_H2_pTX_Li2018_molality)"
       Exit Function
    End If
    
    If p < 0 Then
       solubility_H2_pTX_Li2018_molality = "#p negative! (GasData.solubility_H2_pTX_Li2018_molality)"
       Exit Function
    End If
    
    ' p is not used other than in the checks! The total pressure for equation 16 is calculated as p = p_gas + p_H2O
    
    Dim x: x = CheckMassVector(Xin, Brine.nX)
    If VarType(x) = vbString Then
       solubility_H2_pTX_Li2018_molality = x
       Exit Function
    End If
    X_H2O = x(Brine.nX) ' to be used in solubility_H2_pTX_Li2018 avoiding double calculation
    
    Dim molalities
    molalities = ToDouble(massFractionsToMolalities(x, Brine.MM_vec))
    If VarType(molalities) = vbString Then
        solubility_H2_pTX_Li2018_molality = molalities
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

    Dim p_H2O As Double: p_H2O = IAPWS.Waterpsat_T(T)
    If VarType(p_H2O) = vbString Then 'if error
        solubility_H2_pTX_Li2018_molality = p_H2O & "(GasData.solubility_H2_pTX_Li2018_molality)"
        Exit Function
    End If
   
    Dim p_MPa As Double, T_C As Double
    p_MPa = (p_gas + p_H2O) / 10 ^ 6 'assumption made for multi-gas
    T_C = T - 273.15
    
    If p_gas + p_H2O > p Then
       solubility_H2_pTX_Li2018_molality = "#p_gas + p_H2O > p! (GasData.solubility_H2_pTX_Li2018_molality)"
       Exit Function
    End If
    

    If Not p_gas > 0 Then
        solubility_H2_pTX_Li2018_molality = 0
        Exit Function
    End If
    
    Dim msg As String
    msg = RangeCheck_pTb(p, T, b_NaCl, ignoreLimitH2_p, ignoreLimitH2_T, ignoreLimitH2_b, p_min, p_max, T_min, T_max, b_max, "solubility_H2_pTX_Li2018_molality")
    If Len(msg) > 0 Then
        solubility_H2_pTX_Li2018_molality = msg
        Exit Function
    End If
    
'        Dim msg As String
'     If outOfRangeMode > 0 Then
'        If Not ignoreLimitH2_T And (T_min > T Or T > T_max) Then
'           msg = "#T=" & T_C & " °C, H2 solubility only valid for " & T_min - 273.15 & "<T<" & T_max - 273.15 & " °C (GasData.solubility_H2_pTX_Li2018_molality)"
'        End If
'        If (p < p_min Or p > p_max) Then
'           msg = "#p=" & (p / 10 ^ 5) & " bar, H2 solubility only valid for " & p_min / 10 ^ 5 & "<p<" & p_max / 10 ^ 5 & " bar (GasData.solubility_H2_pTX_Li2018_molality)"
'        End If
'        If molalities(i_NaCl) > b_max Then
'          msg = "#mola(i_NaCl)=" & (molalities(i_NaCl)) & " mol/kg, but H2 solubility only valid up to " & b_max & " mol/kg (GasData.solubility_H2_pTX_Li2018_molality)"
'        End If
'        If Len(msg) > 0 Then
'           If outOfRangeMode = 1 Then
'               Debug.Print msg
'           ElseIf outOfRangeMode = 2 Then
'               solubility_H2_pTX_Li2018_molality = msg
'               Exit Function
'           End If
'        End If
'     End If

    Dim y_H2 As Double
    y_H2 = p_gas / p 'adapted by Francke
    ' Debug.Print "y_H2: "; y_H2
    solubility_H2_pTX_Li2018_molality = solubility_H2_pTby_Li2018_molality(p, T, b_NaCl, y_H2)
End Function

' equations from article

Function solubility_H2_pTby_Li2018_molality(p As Double, T As Double, b_NaCl As Double, y_H2 As Double)
    ' Debug.Print "p="; p / 100000#; " bar"
    Dim p_MPa As Double, T_C As Double
    p_MPa = p / 10 ^ 6 'assumption made for multi-gas
    T_C = T - 273.15
    
    Dim LNPhi_H2 ' As Double
    'LNPhi_H2 = LNfugacity_H2_Spycher1988(p, T)
    'Debug.Print "LNPhi_H2_Spycher: "; LNPhi_H2
    LNPhi_H2 = LNfugacity_H2_Pilz2015(p, T)
    'Debug.Print "LNPhi_H2_Pilz: "; LNPhi_H2
    
    If VarType(LNPhi_H2) = vbString Then 'if error
        solubility_H2_pTby_Li2018_molality = LNPhi_H2 & "(GasData.solubility_H2_pTX_Li2018_molality)"
        Exit Function
    End If
    
    ' Table 2 - Best fit parameters for the Henry's constant model, Eq. (13).
    Dim a: a = Array(0.0000268721, _
                    -0.05121, _
                    33.55196, _
                    -3411.0432, _
                    -31258.74683)
    Dim LNk_H As Double: LNk_H = a(1) * T ^ 2 + a(2) * T + a(3) + a(4) / T + a(5) * T ^ -2
    'Debug.Print "LNk_H: "; LNk_H
    
    ' Table 4 - Parameters for Eq. (16)
    Dim b: b = Array(6.156755, _
                    -0.02502396, _
                    0.00004140593, _
                    -0.001322988)
    Dim PF As Double: PF = b(1) / T * p_MPa + b(2) * p_MPa + b(3) * T * p_MPa + b(4) * p_MPa ^ 2 / T
    'Debug.Print "PF: "; PF

    
    ' Table 5 - Parameters for Eq. (17)
    Dim c: c = Array(0.64485, 0.00142)
    Dim LNgamma_H2: LNgamma_H2 = (c(1) - c(2) * T) * b_NaCl
    'Debug.Print "LNgamma_H2: "; LNgamma_H2
    'Debug.Print "LN(y_H2): "; Log(y_H2)
    'equ. 6
    solubility_H2_pTby_Li2018_molality = Exp(Log(y_H2) + Log(p_MPa) + LNPhi_H2 - LNk_H - PF - LNgamma_H2 + 4.0166)
    
 End Function

Function LNfugacity_H2_Spycher1988(ByVal p As Double, T As Double)
    ' Spycher, N. F., & Reed, M. H. (1988). Fugacity coefficients of hydrogen, carbon dioxide, methane, water and of water-carbon dioxide-methane mixtures: A virial equation treatment for moderate pressures and temperatures applicable to calculations of hydrothermal boiling. Geochimica et Cosmochimica Acta, 32.
    ' Dim A As Double, B As Double, C As Double, D As Double, E As Double, F As Double
   
    Dim coeffs As VirialCoeffs
    coeffs.T_min = 298
    coeffs.T_max = 873
    coeffs.p_min = 100000
    coeffs.p_max = 300000000
    coeffs.a = -12.5908
    coeffs.b = 0.259789
    coeffs.c = -0.000072473
    coeffs.d = 0.00471947
    coeffs.e = -0.0000269962
    coeffs.f = 0.0000000215622
    
'    'equ. 14
'    LNfugacity_H2_Spycher1988 = (A / T_C ^ 2 + B / T_C + C) * p_bar + (d / T_C ^ 2 + E / T_C + f) * p_bar ^ 2 / 2

    LNfugacity_H2_Spycher1988 = VirialEquation(p, T, coeffs)
End Function

Function LNfugacity_H2_Pilz2015(ByVal p As Double, T As Double)
    ' Spycher, N. F., & Reed, M. H. (1988). Fugacity coefficients of hydrogen, carbon dioxide, methane, water and of water-carbon dioxide-methane mixtures: A virial equation treatment for moderate pressures and temperatures applicable to calculations of hydrothermal boiling. Geochimica et Cosmochimica Acta, 32.
    ' Dim A As Double, B As Double, C As Double, D As Double, E As Double, F As Double
    Dim coeffs As VirialCoeffs
    coeffs.T_min = 298
    coeffs.T_max = 75 + 273.15
    coeffs.p_min = 100000 '?
    coeffs.p_max = 18000000#
    coeffs.a = -115.83
    coeffs.b = 0.723062
    coeffs.c = -0.000595111
    coeffs.d = 0.121998
    coeffs.e = -0.000560651
    coeffs.f = 0.000000631737
    
'    'equ. 14
'    LNfugacity_H2_Spycher1988 = (A / T_C ^ 2 + B / T_C + C) * p_bar + (d / T_C ^ 2 + E / T_C + f) * p_bar ^ 2 / 2

    LNfugacity_H2_Pilz2015 = VirialEquation(p, T, coeffs)
End Function

Function VirialEquation(ByVal p As Double, T As Double, coeffs As VirialCoeffs)
    
    Dim msg As String
    msg = RangeCheck_pTb(p, T, 0, ignoreLimitH2_p, ignoreLimitH2_T, ignoreLimitH2_b, coeffs.p_min, coeffs.p_max, coeffs.T_min, coeffs.T_max, -1, "VirialEquation")
    If Len(msg) > 0 Then
        VirialEquation = msg
        Exit Function
    End If
    
'    If Not (ignoreLimitH2_T Or (coeffs.T_min < T And T < coeffs.T_max)) Then
'        VirialEquation = "# T=" & T_C & "°C out of range(GasData.VirialEquation)"
'        Exit Function
'    End If
'    If Not (ignoreLimitH2_p Or (coeffs.p_min < p And p < coeffs.p_max)) Then
'        VirialEquation = "# p out of range (" & coeffs.p_min / 100000# & "..." & coeffs.p_max / 100000# & " bar), p=" & p_bar & " bar (GasData.VirialEquation)"
'        Exit Function
'    End If
        
    Dim a As Double, b As Double, c As Double, d As Double, e As Double, f As Double
    
    a = coeffs.a
    b = coeffs.b
    c = coeffs.c
    d = coeffs.d
    e = coeffs.e
    f = coeffs.f
    
    Dim p_bar As Double: p_bar = p / 10 ^ 5
    Dim T_C As Double: T_C = T - 273.15
    VirialEquation = (a / T ^ 2 + b / T + c) * p_bar + (d / T ^ 2 + e / T + f) * p_bar ^ 2 / 2 'equ. 14
End Function
