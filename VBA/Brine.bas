Attribute VB_Name = "Brine"
' Calculation of two-phase properties of a brine containing multiple salts and multiple gases
' parametrized for NaCl,CaCl,KCl,N2,C2,N2
' developed for PhD project: http://nbn-resolving.de/urn:nbn:de:kobv:83-opus4-47126

' All inputs in SI units, unless otherwise specified
' mass composition (X) input from worksheet can be either full mass vector (X) or without water (Xi)

' by Henning Francke francke@gfz-potsdam.de
' 2020 GFZ Potsdam

Option Explicit
Option Base 1

Public Const outOfRangeMode = 2 'on out of range: 0-ignore, 1-print warning, 2 - throw error
Public Const DebugMode = False 'prints status messages
Const ignoreLimitN2_T = False
Const ignoreLimitN2_p = False
Public Const ignoreResistivity_X = True


Public Const nX = nX_salt + nX_gas + 1

Public Const i_NaCl = 1 'reference number
Public Const i_KCl = 2 'reference number
Public Const i_CaCl2 = 3 'reference number
'Public Const i_MgCl2 = 4 'reference number
'Public Const i_SrCl2 = 5 'reference number
Public Const i_CO2 = 4 'reference number
Public Const i_N2 = 5 'reference number
Public Const i_CH4 = 6 'reference number

Function saturationPressure_H2O(p As Double, T As Double, Xin, Optional ByRef p_H2O) 'brine water vapour pressure
    Dim ionMoleFractions '(nX) As Double
    Dim X_: X_ = CheckMassVector(Xin, nX)
    If VarType(X_) = vbString Then
        saturationPressure_H2O = X_ & " (Brine.saturationPressure_H2O)"
        Exit Function
    End If
    
    If DebugMode Then
        Debug.Print ("Running saturationPressure_H2O(" & p / 100000# & " bar," & T - 273.15 & " °C, X=" & Vector2String(X_) + ")")
    End If
    
    If Application.Max(X_) - 1 > 10 ^ -8 Then
        saturationPressure_H2O = "#X =" & Application.Max(X_) & " out of range (0...1) = saturationPressure_H2O()"
        Exit Function
    End If
    If Application.Min(X_) < -10 ^ -8 Then
        saturationPressure_H2O = "#X =" & Application.Min(X_) & " out of range (0...1) = saturationPressure_H2O()"
        Exit Function
    End If
  If X_(nX) > 0 Then
    ionMoleFractions = VecProd(massFractionsToMoleFractions(X_, MM_vec), nM_vec)
    If VarType(ionMoleFractions) = vbString Then ' error
        saturationPressure_H2O = ionMoleFractions
        Exit Function
    End If
    ionMoleFractions = VecDiv(ionMoleFractions, Application.Sum(ionMoleFractions)) 'normalize
    p_H2O = IAPWS.Waterpsat_T(T)
    If VarType(p_H2O) = vbString Then
        saturationPressure_H2O = p_H2O & "(Brine.saturationPressure_H2O)"
        Exit Function
    End If
    saturationPressure_H2O = p_H2O * ionMoleFractions(nX)
  Else
    saturationPressure_H2O = 10 * p
  End If
' Debug.print("p_H2O="+String(p_H2O))
End Function

Private Function saturationPressures(p As Double, T As Double, X_l_in, Xin)
    
    Dim X_: X_ = CheckMassVector(Xin, nX)
    If VarType(X_) = vbString Then
        saturationPressures = X_ & " (Brine.saturationPressures)"
        Exit Function
    End If
    
    Dim X_l: X_l = CheckMassVector(X_l_in, nX)
    If VarType(X_l) = vbString Then
        saturationPressures = X_l & " (Brine.saturationPressures)"
        Exit Function
    End If
    
    Dim k '() As Double 'nX Henry coefficients
    Dim i As Integer
    Dim p_H2O As Double: p_H2O = saturationPressure_H2O(p, T, X_) 'partial pressure of water vapour pressure
    Dim p_sat(1 To nX_gas + 1) As Double 'vector of degassing pressures
    Dim p_gas() As Double  'partial pressures of gases

    If (p_H2O > p) Then
        saturationPressures = "#p is below water vapour pressure p_H2O(" & p / 10 ^ 5 & "bar," & T - 273.15 & "°C, X) = " & p_H2O / 100000# & " bar (VLE)"
        Exit Function
    End If
    
    p_gas = fill(p / (nX_gas + 1), nX_gas + 1)
    
    Dim solu: solu = solubilities_pTX(p, T, X_l, X_, SubArray(p_gas, 1, nX_gas))
    If VarType(solu) = vbString Then
        saturationPressures = solu
        Exit Function
    End If
    k = VecDiv(solu, SubArray(p_gas, 1, nX_gas))
    
    For i = 1 To nX_gas
        p_sat(i) = X_l(nX_salt + i) / IIf(k(i) > 0, k(i), 1 ^ 10) 'Degassing pressure
    Next i
    p_sat(nX_gas + 1) = p_H2O


    If DebugMode Then
        Debug.Print "saturationPressures(" & p & "," & T & ")={" & Join(p_sat) & "}"
    End If
    saturationPressures = p_sat
End Function

'Function psat_T(p As Double, T As Double, X_)
'    Dim p_sat: p_sat = saturationPressures(p, T, X_, X_) 'vector of degassing pressures
'    If VarType(p_sat) = vbString Then
'        psat_T = p_sat
'        Exit Function
'    End If
'    psat_T = Application.Sum(saturationPressures(p, T, X_, X_))
'End Function

Function pressure(pOrVLEstate, Optional T As Double = -1, Optional Xi = -1, Optional phase As Integer = 0)
    pressure = getValueFromVLE(pOrVLEstate, T, Xi, phase, "p")
End Function

Function temperature(pOrVLEstate, Optional T As Double = -1, Optional Xi = -1, Optional phase As Integer = 0)
    temperature = getValueFromVLE(pOrVLEstate, T, Xi, phase, "T")
End Function

Function gasMassFraction(pOrVLEstate, Optional T As Double = -1, Optional Xi = -1, Optional phase As Integer = 0)
'    Dim VLEstate As Dictionary: Set VLEstate = getVLEstate(pOrVLEstate, T, Xi, phase)
'    If Len(VLEstate("error")) > 0 Then
'        gasMassFraction = VLEstate("error")
'    Else
'        gasMassFraction = VLEstate("x")
'    End If
    gasMassFraction = getValueFromVLE(pOrVLEstate, T, Xi, phase, "x")
End Function

Function MassComposition_liq(pOrVLEstate, Optional T As Double = -1, Optional Xi = -1, Optional phase As Integer = 0)
    MassComposition_liq = Vector2String(getValueFromVLE(pOrVLEstate, T, Xi, phase, "X_l"))
End Function

Function MassComposition_gas(pOrVLEstate, Optional T As Double = -1, Optional Xi = -1, Optional phase As Integer = 0)
    MassComposition_gas = Vector2String(getValueFromVLE(pOrVLEstate, T, Xi, phase, "X_g"))
End Function

Function degassingPressure(pOrVLEstate, Optional T As Double = -1, Optional Xi = -1, Optional phase As Integer = 0)
    degassingPressure = getValueFromVLE(pOrVLEstate, T, Xi, phase, "p_degas")
End Function

Function p_gas(pOrVLEstate, Optional T As Double = -1, Optional Xi = -1, Optional phase As Integer = 0) 'partial pressures of gases
    p_gas = getValueFromVLE(pOrVLEstate, T, Xi, phase, "p_gas")
End Function

Function phase(pOrVLEstate, Optional T As Double = -1, Optional Xi = -1)
    phase = getValueFromVLE(pOrVLEstate, T, Xi, 0, "phase")
End Function

Private Function solubilities_pTX(p As Double, T As Double, X_l, X_, p_gas)
    'solubility calculation of CO2 in seawater Duan, Sun(2003), returns gas concentration in kg/kg H2O
    If Length(p_gas) <> 3 Then
      solubilities_pTX = "#Wrong number of degassing pressures"
      Exit Function
    End If
    Dim solu() As Double
    ReDim solu(1 To nX_gas)
    If X(i_CO2) > 0 Then
        solubilities_pTX = solubility_CO2_pTX_Duan2006(p, T, X_l, p_gas(1)) 'aus Partial_Gas_Data, mol/kg_H2O -> kg_CO2/kg_H2O
        If VarType(solubilities_pTX) = vbString Then
            Exit Function
        Else
            solu(1) = solubilities_pTX
        End If
    Else
        solu(1) = 0
    End If
    
    If X(i_N2) > 0 Then
        solubilities_pTX = solubility_N2_pTX_Mao2006(p, T, X_l, p_gas(2)) 'aus Partial_Gas_Data, mol/kg_H2O -> kg_N2/kg_H2O
        If VarType(solubilities_pTX) = vbString Then
            Exit Function
        Else
            solu(2) = solubilities_pTX
        End If
    Else
        solu(2) = 0
    End If
    
         solubilities_pTX = solubility_CH4_pTX_Duan2006(p, T, X_l, p_gas(3)) 'aus Partial_Gas_Data, mol/kg_H2O -> kg_CH4/kg_H2O
         If VarType(solubilities_pTX) = vbString Then
            Exit Function
        Else
            solu(3) = solubilities_pTX
        End If
   Else
        solu(3) = 0
    End If
    solubilities_pTX = solu
End Function


' BELOW GENERIC (for variable nX)

Function MM_vec()
    MM_vec = cat(SubArray(Brine_liq.MM_vec, 1, 3), Brine_gas.MM_vec)
End Function

Private Function nM_vec()
    nM_vec = cat(SubArray(Brine_liq.nM_vec, 1, 3), Brine_gas.nM_vec)
End Function


Function specificEnthalpy(pOrVLEstate, Optional T As Double = -1, Optional Xi = -1, Optional phase As Integer = 0)
    Dim VLEstate As Dictionary: Set VLEstate = getVLEstate(pOrVLEstate, T, Xi, phase)
    If Len(VLEstate("error")) > 0 Then
        specificEnthalpy = VLEstate("error")
        Exit Function
    End If

    Dim h_l: h_l = Brine_liq.specificEnthalpy(VLEstate("p"), VLEstate("T"), ToDouble(SubArray(VLEstate("X_l"), 1, nX_salt)))  'liquid specific enthalpy
    If VarType(h_l) = vbString Then
        specificEnthalpy = h_l
        Exit Function
    End If
    
    Dim h_g
    If VLEstate("x") > 0 Then
            h_g = Brine_gas.specificEnthalpy(VLEstate("p"), VLEstate("T"), ToDouble(SubArray(VLEstate("X_g"), 1, nX_gas)))     'gas specific enthalpy
        'Else
        '    specificEnthalpy_gas = 0 'no gas phase
    End If
    If VarType(h_g) = vbString Then
        specificEnthalpy = h_g
        Exit Function
    End If
    specificEnthalpy = VLEstate("x") * h_g + (1 - VLEstate("x")) * h_l
End Function
Function specificEnthalpy_liq(pOrVLEstate, Optional T As Double = -1, Optional Xi = -1, Optional phase As Integer = 0)
    Dim VLEstate As Dictionary: Set VLEstate = getVLEstate(pOrVLEstate, T, Xi, phase)
    If Len(VLEstate("error")) > 0 Then
        specificEnthalpy_liq = VLEstate("error")
    Else
        Dim h_l: h_l = Brine_liq.specificEnthalpy(VLEstate("p"), VLEstate("T"), ToDouble(SubArray(VLEstate("X_l"), 1, nX_salt)))  'liquid specific enthalpy
        specificEnthalpy_liq = h_l
    End If
End Function
Function specificEnthalpy_gas(pOrVLEstate, Optional T As Double = -1, Optional Xi = -1, Optional phase As Integer = 0)
    Dim VLEstate As Dictionary: Set VLEstate = getVLEstate(pOrVLEstate, T, Xi, phase)
    If Len(VLEstate("error")) > 0 Then
        specificEnthalpy_gas = VLEstate("error")
    ElseIf VLEstate("x") = 0 Then
        specificEnthalpy_gas = "#no gas phase"
    Else
        Dim h_g: h_g = Brine_gas.specificEnthalpy(VLEstate("p"), VLEstate("T"), ToDouble(SubArray(VLEstate("X_g"), 1, nX_gas)))  'gas specific enthalpy
        specificEnthalpy_gas = h_g
    End If
End Function

Function gasLiquidRatio(pOrVLEstate, Optional T As Double = -1, Optional Xi = -1, Optional phase As Integer = 0)
    Dim GVF: GVF = gasVolumeFraction(pOrVLEstate, T, Xi, phase)
    gasLiquidRatio = GVF / (1 - GVF)
End Function

Function gasVolumeFraction(pOrVLEstate, Optional T As Double = -1, Optional Xi = -1, Optional phase As Integer = 0)
    Dim VLEstate As Dictionary: Set VLEstate = getVLEstate(pOrVLEstate, T, Xi, phase) 'calculate VLE or parse JSON string
    If Len(VLEstate("error")) > 0 Then
        gasVolumeFraction = VLEstate("error")
    ElseIf VLEstate.Exists("GVF") Then
        gasVolumeFraction = VLEstate("GVF") ' just extract
    Else
        Dim d, d_g As Double
'        d = density(pOrVLEstate)
        d = density(VLEstate, T, Xi, phase, d_g)
        If VarType(d) = vbString Then 'if error
            gasVolumeFraction = d
            Exit Function
        End If
        gasVolumeFraction = IIf(VLEstate("x") > 0, VLEstate("x") * d / d_g, 0)
    End If
End Function

Function gasLiquidRatio_fullDegassing(p As Double, T As Double, Xi)
    Dim X_: X_ = CheckMassVector(Xi, nX)
    If VarType(X_) = vbString Then
        gasLiquidRatio_fullDegassing = X_ & " (gasLiquidRatio_fullDegassing)"
        Exit Function
    End If
    
    Dim i As Integer
    Dim gasVolume As Double
    For i = nX_salt + 1 To nX_salt + nX_gas
        gasVolume = gasVolume + X_(i) / MM_vec(i) * Constants.R * T / p
    Next i
    Dim y_H2O: y_H2O = saturationPressure_H2O(p, T, X_) / p
'    gasVolume = gasVolume + gasVolume / (1 - y_H2O) * y_H2O ' Add water vapour volume
    gasVolume = gasVolume / (1 - y_H2O)  ' Add water vapour volume
    Dim liquidVolume: liquidVolume = 1 / density_liq(p, T, X_) * (1 - Application.Sum(SubArray(X_, nX_salt + 1, nX - 1)))
    
    gasLiquidRatio_fullDegassing = gasVolume / liquidVolume
End Function

Function density(pOrVLEstate, Optional T As Double = -1, Optional Xi = -1, Optional phase As Integer = 0, Optional ByRef d_g As Double)
    Dim VLEstate As Dictionary: Set VLEstate = getVLEstate(pOrVLEstate, T, Xi, phase)
    If Len(VLEstate("error")) > 0 Then
        density = VLEstate("error")
    Else

        'Dim d_l: d_l = IIf(VLEstate.x_ < 1, Brine_liq.density(VLEstate.p, VLEstate.T, VLEstate.Xi_l), -1) 'liquid density
        Dim d_l: d_l = IIf(VLEstate("x") < 1, Brine_liq.density(VLEstate("p"), VLEstate("T"), ToDouble(SubArray(VLEstate("X_l"), 1, nX_salt))), -1) 'liquid density
        If VarType(d_l) = vbString Then 'if error
            density = d_l
            Exit Function
        End If
        If VLEstate("x") > 0 Then
 '           d_g = Brine_gas.density(VLEstate.p, T, VLEstate.X_g) 'gas density
            Dim d_g_tmp: d_g_tmp = Brine_gas.density(VLEstate("p"), VLEstate("T"), VLEstate("X_g")) 'gas density in temporary Variant, because d_g declared as double
            If VarType(d_g_tmp) = vbString Then 'if error
                density = d_g_tmp
                Exit Function
            Else
                d_g = d_g_tmp
            End If
        Else
            d_g = -1 'no gas phase
        End If
        
        density = 1 / (VLEstate("x") / d_g + (1 - VLEstate("x")) / d_l)       'fluid density
    End If
End Function


Function density_liq(pOrVLEstate, Optional T As Double = -1, Optional Xi = -1, Optional phase As Integer = 0)
    Dim VLEstate As Dictionary: Set VLEstate = getVLEstate(pOrVLEstate, T, Xi, phase)
    If Len(VLEstate("error")) > 0 Then
        density_liq = VLEstate("error")
    Else
'        Dim d_l: d_l = IIf(VLEstate.x_ < 1, Brine_liq.density(p, T, VLEstate.Xi_l), -1) 'liquid density
        Dim d_l: d_l = IIf(VLEstate("x") < 1, Brine_liq.density(VLEstate("p"), VLEstate("T"), ToDouble(SubArray(VLEstate("X_l"), 1, nX_salt))), -1) 'liquid density
        density_liq = d_l
    End If
End Function

Function density_gas(pOrVLEstate, Optional T As Double = -1, Optional Xi = -1, Optional phase As Integer = 0)
    Dim VLEstate As Dictionary: Set VLEstate = getVLEstate(pOrVLEstate, T, Xi, phase)
    If Len(VLEstate("error")) > 0 Then
        density_gas = VLEstate("error")
    ElseIf VLEstate("x") = 0 Then
        density_gas = "#no gas phase"
    Else
        density_gas = Brine_gas.density(VLEstate("p"), VLEstate("T"), VLEstate("X_g")) 'gas density
    End If
End Function

Function specificHeatCapacityCp(pOrVLEstate, Optional T As Double = -1, Optional Xi = -1, Optional phase As Integer = 0)
    Dim VLEstate As Dictionary: Set VLEstate = getVLEstate(pOrVLEstate, T, Xi, phase)
    If Len(VLEstate("error")) > 0 Then
        specificHeatCapacityCp = VLEstate("error")
    Else
        Dim cp_l: cp_l = Brine_liq.specificHeatCapacityCp(VLEstate("p"), VLEstate("T"), ToDouble(SubArray(VLEstate("X_l"), 1, nX_salt))) 'liquid specific enthalpy
        If VarType(cp_l) = vbString Then
            specificHeatCapacityCp = cp_l
            Exit Function
        End If
        
        Dim cp_g:
        If VLEstate("x") > 0 Then
            cp_g = Brine_gas.specificHeatCapacityCp(VLEstate("p"), VLEstate("T"), ToDouble(SubArray(VLEstate("X_g"), 1, nX_gas))) 'gas specific enthalpy
        'Else
        '    specificEnthalpy_gas = 0 'no gas phase
        End If
        If VarType(cp_g) = vbString Then
            specificHeatCapacityCp = cp_g
            Exit Function
        End If

        specificHeatCapacityCp = VLEstate("x") * cp_g + (1 - VLEstate("x")) * cp_l
    End If
End Function
Function specificHeatCapacityCp_liq(pOrVLEstate, Optional T As Double = -1, Optional Xi = -1, Optional phase As Integer = 0)
    Dim VLEstate As Dictionary: Set VLEstate = getVLEstate(pOrVLEstate, T, Xi, phase)
    If Len(VLEstate("error")) > 0 Then
        specificHeatCapacityCp_liq = VLEstate("error")
    Else
        Dim cp_l: cp_l = Brine_liq.specificHeatCapacityCp(VLEstate("p"), VLEstate("T"), ToDouble(SubArray(VLEstate("X_l"), 1, nX_salt)))  'liquid specific enthalpy
        specificHeatCapacityCp_liq = cp_l
    End If
End Function
Function specificHeatCapacityCp_gas(pOrVLEstate, Optional T As Double = -1, Optional Xi = -1, Optional phase As Integer = 0)
    Dim VLEstate As Dictionary: Set VLEstate = getVLEstate(pOrVLEstate, T, Xi, phase)
    If Len(VLEstate("error")) > 0 Then
        specificHeatCapacityCp_gas = VLEstate("error")
    ElseIf VLEstate("x") = 0 Then
        specificHeatCapacityCp_gas = "#no gas phase"
    Else
        Dim cp_g: cp_g = Brine_gas.specificHeatCapacityCp(VLEstate("p"), VLEstate("T"), ToDouble(SubArray(VLEstate("X_g"), 1, nX_gas)))  'gas specific enthalpy
        specificHeatCapacityCp_gas = cp_g
    End If
End Function



'X is not in VLE JSON!
'Function MassComposition(VLEstate_string) ' just extract X from VLE JSON string
'    Dim VLEstate As BrineProps_Type: VLEstate = JSON2VLEstate2(CStr(VLEstate_string))
'    If Len(VLEstate.error) > 0 Then
'        MassComposition = VLEstate.error
'    Else
'        MassComposition = VLEstate.x 'Vector2String(VLEstate.X)
'    End If
'End Function

Function dynamicViscosity_liq(pOrVLEstate, Optional T As Double = -1, Optional Xi = -1, Optional phase As Integer = 0)
    Dim VLEstate As Dictionary: Set VLEstate = getVLEstate(pOrVLEstate, T, Xi, phase)
    If Len(VLEstate("error")) > 0 Then
        dynamicViscosity_liq = VLEstate("error")
    Else
        dynamicViscosity_liq = Brine_liq.dynamicViscosity(VLEstate("p"), VLEstate("T"), SubArray(VLEstate("X_l"), 1, nX_salt))
    End If
End Function

Function dynamicViscosity_gas(pOrVLEstate, Optional T As Double = -1, Optional Xi = -1, Optional phase As Integer = 0)
    Dim VLEstate As Dictionary: Set VLEstate = getVLEstate(pOrVLEstate, T, Xi, phase)
    If Len(VLEstate("error")) > 0 Then
        dynamicViscosity_gas = VLEstate("error")
    ElseIf VLEstate("x") = 0 Then
        dynamicViscosity_gas = "#no gas phase"
    Else
        dynamicViscosity_gas = Brine_gas.dynamicViscosity(VLEstate("p"), VLEstate("T"), SubArray(VLEstate("X_g"), 1, nX_gas))
    End If
End Function

Private Function VLE(p As Double, T As Double, Xi, Optional phase As Integer = 0) As Object
    ' VLE algorithm
    ' finds the VLE iteratively by varying the normalized quantity of gas in the gasphase, calculates the densities"
    ' Input: p,T,Xi
    ' Output: x, X_l, X_g
    Dim VLE_JSON As Object
    Set VLE_JSON = New Dictionary
    
    Const zmax = 1000 'maximum number of iterations
    Dim nX_ As Integer ' () As Double
    'If VarType(Xi) = vbString Then
    '    X = FullMassVector(String2Vector(Xi), nX_) 'make sure first index is 1
    'Else
    '    X = FullMassVector(Xi, nX_) 'make sure first index is 1 //TODO: das kann weg, oder?
    'End If
    'If VarType(X) = vbString Or VarType(X) = vbError Then
    '    VLE.error = X
    '    Exit Function
    'End If
    'If nX_ <> nX Then
    '    VLE.error = "#Wrong number of components in composition vector (" & nX_ & " instead of " & nX & ")."
    '    Exit Function
    'End If
    
    Dim X: X = CheckMassVector(Xi, nX)
    If VarType(X) = vbString Then
        VLE_JSON("error") = X & " (VLE)"
        GoTo EndFunction
    End If

    Dim n_g_norm_start(1 To nX_gas + 1) As Double 'start value, all gas in gas phase, all water liquid, set in BaseProps"
    Dim i As Integer, gamma As Integer, alpha As Integer
    For i = 1 To nX_gas + 1
        n_g_norm_start(i) = 0.5
    Next i
    Dim p_gas() As Double  'partial pressures of gases
    Dim X_l() As Double: X_l = X 'MassFraction start value
    Dim X_ As Double 'gas mass fraction
    Dim p_H2O As Double 'partial pressure of water vapour pressure
    Dim p_H2O_0 As Double 'pure water vapour pressure
    Dim p_sat(1 To nX_gas + 1) As Double 'vector of degassing pressures
    Dim f() As Double 'nX_gas + 1componentwise pressure disbalance (to become zero)
    Dim Delta_n_g_norm() As Double
    Delta_n_g_norm = fill(1000#, nX_gas + 1)
    Dim k '() As Double 'nX Henry coefficients
    Dim n '(nX_gas + 1) As Double 'Total mol numbers
    Dim n_l() As Double 'mols in liquid phase per kg fluid
    Dim n_g() As Double 'mols in gas  phase per kg fluid
    Dim n_g_norm '(nX_gas + 1) As Double
    Dim dp_gas_dng_norm  As Double
    Dim dcdng_norm  As Double
    Dim dp_degas_dng_norm As Double
    Dim dfdn_g_norm(nX_gas + 1) As Double
    Dim sum_n_ion As Double
    
    If T < 273.15 Then
        VLE_JSON("error") = "T=" & T & " too low (<0°C) (VLE())"
    End If
    If p < 0 Then
        VLE_JSON("error") = "Negative pressure: p=" & p & " ( VLE() )"
        GoTo EndFunction
    End If
    
        ' DEGASSING PRESSURE
    Dim tmp
    tmp = saturationPressure_H2O(p, T, X)
    If VarType(tmp) = vbString Then
        VLE_JSON("error") = tmp & "(VLE)"
        GoTo EndFunction
    End If
    p_H2O = tmp
    If (p_H2O > p) Then
'        VLE("error") = "#p is below water vapour pressure p_H2O(" & p / 10 ^ 5 & "bar," & T - 273.15 & "°C, X) = " & p_H2O / 100000# & " bar (VLE)"
'        Exit Function
        Debug.Print "#p is below water vapour pressure p_H2O(" & p / 10 ^ 5 & "bar," & T - 273.15 & "°C, X) = " & p_H2O / 100000# & " bar (VLE)"
    End If
    
    p_gas = fill(p / (nX_gas + 1), nX_gas + 1)
    
    Dim solu: solu = solubilities_pTX(p, T, X_l, X, SubArray(p_gas, 1, nX_gas))
    If VarType(solu) = vbString Then
        VLE_JSON("error") = solu
        GoTo EndFunction
    End If
    k = VecDiv(solu, SubArray(p_gas, 1, nX_gas))
    
    For i = 1 To nX_gas
        p_sat(i) = X_l(nX_salt + i) / IIf(k(i) > 0, k(i), 1 ^ 10) 'Degassing pressure
    Next i
    p_sat(nX_gas + 1) = p_H2O
    
    Dim p_degas As Double: p_degas = Application.Sum(p_sat) ' stored later in VLEstate
    If phase = 1 Or p_degas < p Then
        If DebugMode Then
            Debug.Print ("1Phase-Liquid (VLE(" & p & "," & T & "))")
        End If
    ElseIf Not Application.Max(SubArray(X, 1, nX - 1)) > 0 Then
        Debug.Print "2-phase water"
        X_ = 1
    Else
        If Not Application.Max(SubArray(X, nX_salt + 1, nX - 1)) > 0 Then
            VLE_JSON("error") = "#Phase equilibrium cannot be calculated without dissolved gas" ' at "+String(p/1e5)+" bar, "+String(T-273.15)+"°C with p_degas="+String(sum(p_degas)/1e5)+" bar.")
            GoTo EndFunction
        End If
        n = VecDiv(SubArray(X, nX_salt + 1, nX), Brine_gas.MM_vec) 'total mole numbers per kg brine
        n_g_norm = VecProd(n_g_norm_start, VecSgn(SubArray(X, nX_salt + 1, nX))) 'switch off unused salts
        
        Dim Z As Integer
        Do While Z < 1 Or Application.Max(VecAbs(Delta_n_g_norm)) > 0.001
            ' stop iteration when p-equlibrium is found or gas fraction is very low
            Z = Z + 1 'count iterations
            If Z >= zmax Then
            VLE_JSON("error") = "#Reached maximum number of iterations (" & Z & "/" & zmax & ") for solution equilibrium calculation. (VLE)" '("+String(p/1e5)+"bar,"+String(T-273.16)+"°C))\nDeltaP="+String(max(abs(p_sat-p_gas))))
            GoTo EndFunction
            End If
            
            n_g = VecProd(n_g_norm, n)
            n_l = VecDiff(n, n_g)
            X_ = ScalProd(n_g, Brine_gas.MM_vec)
            X_l = VecDiv(cat(SubArray(X, 1, nX_salt), VecProd(n_l, Brine_gas.MM_vec)), (1 - X_))
            ' PARTIAL PRESSURE
            p_gas = VecProd(p / Application.Sum(n_g), n_g)
            
            ' DEGASSING PRESSURE
            p_H2O = saturationPressure_H2O(p, T, X_l, p_H2O_0) 'X_l ändert sich
            If (p_H2O > p) Then
                Debug.Print ("p_H2O(" & p / 10 ^ 5 & "bar," & T - 273.15 & "°C, " & Vector2String(X)) & ") = " & p_H2O / 100000# & "bar>p ! (VLE)"
                X_ = 1
                GoTo Break
            End If
            
            solu = solubilities_pTX(p, T, X_l, X, SubArray(p_gas, 1, nX_gas))
            If VarType(solu) = vbString Then
              VLE_JSON("error") = solu
              GoTo EndFunction
            End If
            
            For i = 1 To nX_gas
                If p_gas(i) > 0 Then
                    k(i) = solu(i) / p_gas(i)
                Else
                    k(i) = 10 ^ 10
                End If
                p_sat(i) = X_l(nX_salt + i) / k(i) 'Degassing pressure
            Next i
            p_sat(nX_gas + 1) = p_H2O
            
            
            f = VecDiff(p_gas, p_sat)
            
            sum_n_ion = ScalProd(cat(VecDiv(SubArray(X, 1, nX_salt), SubArray(MM_vec, 1, nX_salt)), n_l), nM_vec)
            
' GRADIENT analytisch df(gamma)/dc(gamma)
            
            For gamma = 1 To nX_gas + 1
                dp_gas_dng_norm = p * n(gamma) * (Application.Sum(n_g) - n_g(gamma)) / (Application.Sum(n_g)) ^ 2 'partial pressure
                If gamma = nX_gas + 1 Then
                  dp_degas_dng_norm = p_H2O_0 * n(nX_gas + 1) * (IIf(gamma = nX_gas + 1, -sum_n_ion, 0) + (1 - n_g_norm(nX_gas + 1)) * n(gamma)) / sum_n_ion ^ 2
                Else
                    dcdng_norm = n(gamma) * MM_vec(nX_salt + gamma) * ((X_ - 1) + (1 - n_g_norm(gamma)) * n(gamma) * MM_vec(nX_salt + gamma)) / (1 - X_) ^ 2
                    dp_degas_dng_norm = dcdng_norm / IIf(k(gamma) > 0, k(gamma), 10 ^ -10)  'degassing pressure
                End If
                dfdn_g_norm(gamma) = dp_gas_dng_norm - dp_degas_dng_norm
            Next gamma
            
            
            For alpha = 1 To nX_gas + 1
            If X(nX_salt + alpha) > 0 Then
              Delta_n_g_norm(alpha) = -f(alpha) / dfdn_g_norm(alpha)
            Else
              Delta_n_g_norm(alpha) = 0
            End If
            n_g_norm(alpha) = Application.Max(10 ^ -9, Application.Min(1, n_g_norm(alpha) + Delta_n_g_norm(alpha))) 'new concentration limited by all dissolved/none dissolved, 1e-9 to avoid k=NaN
            Next alpha
        Loop 'End iterative solver
        If DebugMode Then
            Debug.Print Z & " iterations in VLE algorithm"
        End If
Break:
    
    End If 'p_degas< p
    
    ' Gas composition
    Dim X_g() As Double
    If X_ > 0 Then
        X_g = VecDiv( _
                VecDiff( _
                    SubArray(X, nX_salt + 1, nX), _
                    VecProd( _
                        SubArray(X_l, nX_salt + 1, nX), _
                        (1 - X_)) _
                ), _
                X_)
        If X_ = 1 Then
            X_g = VecProd(X_g, 1 / Application.Sum(X_g)) 'Normalize
        End If
    Else
        X_g = fill(0, nX_gas + 1) 'as initialized
    End If
    
'    Dim Xi_l() As Double: Xi_l = ToDouble(SubArray(X_l, 1, nX_salt))
'    Dim Xi_g() As Double: Xi_g = ToDouble(SubArray(X_g, 1, nX_gas))
    
    VLE_JSON("p") = p
    VLE_JSON("T") = T
    VLE_JSON("x") = X_ 'mass fraction
    VLE_JSON("X_l") = X_l
    VLE_JSON("X_g") = X_g
    VLE_JSON("p_degas") = p_degas
    VLE_JSON("p_gas") = p_gas
    VLE_JSON("phase") = IIf(X_ > 0 And X_ < 1, 2, 1)
    
'    Dim VLEstate As Collection
'    With VLEstate
'        .Add x_, "X"
'        .Add X_l, "X_l"
'        .Add X_g, "X_g"
'        .Add Xi_l, "Xi_l"
'        .Add Xi_g, "Xi_g"
'        .Add p_degas, "p_degas"
'        .Add IIf(x_ > 0 And x_ < 1, 2, 1), "phase"
'    End With
    'VLE = VLEstate
EndFunction:
    Set VLE = VLE_JSON
End Function


Function VLEasJSON(p As Double, T As Double, Xi, Optional phase As Integer = 0) As String 'assemble VLE state variables as JSON String
    Dim VLE_object As Object: Set VLE_object = VLE(p, T, Xi, phase)
    If Len(VLE_object("error")) > 0 Then  ' if error
        VLEasJSON = VLE_object("error")  'return error message
    Else
        VLEasJSON = JsonConverter.ConvertToJson(VLE_object)
    End If
End Function

Private Function getVLEstate(ByRef pOrVLEstate, Optional T As Double = -1, Optional Xi = -1, Optional phase As Integer = 0) As Object 'make VLE struct from String or calculate
    If VarType(pOrVLEstate) = vbString Then ' if JSON string was passed
'        Set getVLEstate = JSON2VLEstate2(CStr(pOrVLEstate))
        Set getVLEstate = JsonConverter.ParseJson(CStr(pOrVLEstate))
    ElseIf VarType(pOrVLEstate) = vbObject Then ' If JSON object was passed
        Set getVLEstate = pOrVLEstate
    Else ' if p, T and Xi were passed
'        If T < 0 Then ' Or (VarType(Xi) = vbDouble And Xi < 0) Then
'            Dim VLEstate As BrineProps
'            VLEstate.error = "#not enough arguments"
'            getVLEstate = VLEstate
'        Else
            Set getVLEstate = VLE(CDbl(pOrVLEstate), T, Xi, phase)
'        End If
    End If
End Function

Private Function getValueFromVLE(ByRef pOrVLEstate, T As Double, Xi, phase As Integer, Optional varname As String = "") 'get single var or calculate'make VLE struct from String or calculate
    Dim InputIsObjectContainingDesiredVariable As Boolean
    Dim VLE_object As Object
    If VarType(pOrVLEstate) = vbObject Then ' VLEstate as Object with or without the desired variable
        Set VLE_object = pOrVLEstate
        ' InputIsObjectContainingDesiredVariable = VLE_object.Exists(varname)
        If Not VLE_object.Exists(varname) Then
            Set VLE_object = VLE(CDbl(VLE_object("p")), CDbl(VLE_object("T")), ToDouble(VLE_object("Xi")), CDbl(VLE_object("phase")))
        End If
    ElseIf VarType(pOrVLEstate) = vbString Then ' VLEstate as String or without the desired variable
        Dim n As Integer
'        Dim val: val = String2Vector(GetValueFromJSON(CStr(pOrVLEstate), varname), n)       'extract desired value from JSON string
'         getValueFromVLE = IIf(n = 1, val(1), Vector2String(val))
'         getValueFromVLE = GetValueFromJSON(CStr(pOrVLEstate), varname)       'extract desired value from JSON string
        Set VLE_object = JsonConverter.ParseJson(pOrVLEstate)
'        InputIsObjectContainingDesiredVariable = VLE_object.Exists(varname)
        If Not VLE_object.Exists(varname) Then
            Set VLE_object = VLE(CDbl(VLE_object("p")), CDbl(VLE_object("T")), ToDouble(VLE_object("Xi")), CDbl(VLE_object("phase")))
        End If
    Else 'p,T,X
        Set VLE_object = VLE(CDbl(pOrVLEstate), T, Xi, phase)
    End If
    If Len(VLE_object("error")) > 0 Then ' if error
        getValueFromVLE = VLE_object("error") 'return error message
    ElseIf varname = "X_g" And Not CDbl(VLE_object("x")) > 0 Then
        getValueFromVLE = "#no gas phase"
    Else
        getValueFromVLE = ToDouble(VLE_object(varname))
'        If IsArray(getValueFromVLE) Then
'            getValueFromVLE = Vector2String(getValueFromVLE)
'        End If
    End If
End Function

Private Function massFractionsToMoleFractions(X_, MM) 'Return mole_i/sum(mole_i) from mass fractions X
    Dim nX As Integer, nM As Integer, i As Integer
    X_ = ToDouble(X_, nX)
    Dim molefractions() As Double 'Molalities moles/m_H2O
    Dim molalities() As Double 'Molalities moles/m_H2O
    ReDim molefractions(1 To nX)
    ReDim molalities(1 To nX)
    Dim n_total
    If nX <> nM Then
        massFractionsToMoleFractions = "#Inconsistent vectors for mass fraction(" & nX & ") and molar masses(" & Length(MM_vec) & ")"
    End If
    X_ = ToDouble(X_)
    For i = 1 To nX
      molalities(i) = IIf(X_(nX) > 0, X_(i) / (MM(i) * X_(nX)), -1)
    Next i
    n_total = Application.Sum(molalities)
    For i = 1 To nX
      molefractions(i) = molalities(i) / n_total
    Next i
    massFractionsToMoleFractions = molefractions
End Function
