Attribute VB_Name = "Brine_gas"
' Properties of gas mixture (density, viscosity, specific heat capacity, specific enthalpy)

' by Henning Francke francke@gfz-potsdam.de
' 2020 GFZ Potsdam

Option Explicit
Option Base 1
Const nX = nX_gas + 1
Public GasDataSet As Boolean

Function MM_vec()
 'generates double vector of molar masses
    Dim V(1 To nX_gas + 1) As Double
    If Not GasDataSet Then
        DefineGasData
    End If

    If i_CO2 > 0 Then
        V(i_CO2 - nX_salt) = CO2.MM
    End If
    
    If i_N2 > 0 Then
        V(i_N2 - nX_salt) = N2.MM
    End If
    
    If i_CH4 > 0 Then
        V(i_CH4 - nX_salt) = CH4.MM
    End If
    
    If i_H2 > 0 Then
        V(i_H2 - nX_salt) = H2.MM
    End If


    If H2O.MM = 0 Then
        DefineWater
    End If
    V(nX_gas + 1) = H2O.MM
    MM_vec = V
End Function

Function nM_vec() As Double()
 'generates double vector of molar numbers
    Dim V(1 To nX_gas + 1) As Double
    V(1) = CO2.nM
    V(2) = N2.nM
    V(3) = CH4.nM
'    V(4) = nM_H2

    If i_CO2 > 0 Then
        V(i_CO2 - nX_salt) = CO2.nM
    End If
    
    If i_N2 > 0 Then
        V(i_N2 - nX_salt) = N2.nM
    End If
    
    If i_CH4 > 0 Then
        V(i_CH4 - nX_salt) = CH4.nM
    End If
    
    If i_H2 > 0 Then
        V(i_H2 - nX_salt) = H2.nM
    End If
    
    V(nX_gas + 1) = H2O.nM
    nM_vec = V
End Function

' end of gas definition

Function specificEnthalpy(p As Double, T As Double, Xin)
    'calculation of specific enthalpy of gas mixture
    
    Dim X_: X_ = CheckMassVector(Xin, nX)
    If VarType(X_) = vbString Then
        specificEnthalpy = X_ & " (Brine_gas.specificEnthalpy)"
        Exit Function
    End If
    
'    Dim h_H2O_sat As Double, h_H2O As Double, h_CO2 As Double, h_N2 As Double, h_CH4 As Double
'    h_H2O_sat = Waterh_satv_p(p) 'Modelica.Media.Water.IF97_Utilities.BaseIF97.Regions.hv_p(p)
    Dim h_vec(nX_gas + 1), h_tmp As Double
'    h_vec() = Array( _
'    SingleGasNasa_h_T(CO2, T), _
'    SingleGasNasa_h_T(N2, T), _
'    SingleGasNasa_h_T(CH4, T), _
'    Application.Max(h_H2O_sat, SpecificEnthalpy_pT(p, T)) _
'    ) 'to make sure it is gaseous TODO:Take regions directly

    ' For i = 1 To nX_gas
    If i_CO2 > 0 Then
        h_tmp = SingleGasNasa_h_T(CO2, T)
        If Not VarType(h_tmp) = vbDouble Then
            specificEnthalpy = X_ & "Error in cp calculation for " & CO2.name & " (Brine_gas.specificEnthalpy)"
            Exit Function
        End If
        h_vec(i_CO2 - nX_salt) = h_tmp
    End If
    If i_N2 > 0 Then
        h_tmp = SingleGasNasa_h_T(N2, T)
        If Not VarType(h_tmp) = vbDouble Then
            specificEnthalpy = X_ & "Error in cp calculation for " & N2.name & " (Brine_gas.specificEnthalpy"
            Exit Function
        End If
        h_vec(i_N2 - nX_salt) = h_tmp
    End If
    If i_CH4 > 0 Then
        h_tmp = SingleGasNasa_h_T(CH4, T)
        If Not VarType(h_tmp) = vbDouble Then
            specificEnthalpy = X_ & "Error in cp calculation for " & CH4.name & " (Brine_gas.specificEnthalpy)"
            Exit Function
        End If
        h_vec(i_CH4 - nX_salt) = h_tmp
    End If
    If i_H2 > 0 Then
        h_tmp = SingleGasNasa_h_T(H2, T)
        If Not VarType(h_tmp) = vbDouble Then
        specificEnthalpy = X_ & "Error in cp calculation for " & H2.name & " (Brine_gas.specificEnthalpy)"
            Exit Function
        End If
        h_vec(i_H2 - nX_salt) = h_tmp
    End If
    
    h_tmp = Waterh_satv_p(p)
    If Not VarType(h_tmp) = vbDouble Then
        specificEnthalpy = X_ & "Error in cp calculation for " & H2.name & " (Brine_gas.specificEnthalpy)"
        Exit Function
    End If
    h_vec(nX_gas + 1) = Application.Max(h_tmp, SpecificEnthalpy_pT(p, T))
    
    If DebugMode Then
      Debug.Print "Running BrineGas.SpecificEnthalpy(" & p / 10 ^ 5 & " bar," & T - 273.15 & " °C, X=" & Vector2String(X_) & ")"
      ' Debug.Print "No gas composition, assuming water vapour.(Brine_gas.SpecificHeatCapacity_pTX)"
    End If

    specificEnthalpy = ScalProd(h_vec, X_) 'mass weighted average
End Function

Function specificHeatCapacityCp(p As Double, T As Double, Xin) 'calculation of specific enthalpy of gas mixture
    'Argument X is either X or XI (mass vector with or without water)
    If DebugMode Then
      Debug.Print "Running specificHeatCapacityCp_gas(" & p / 10 ^ 5 & " bar," & T - 273.15 & " °C)"
    End If
    
    Dim X_
    X_ = CheckMassVector(Xin, nX)
    If VarType(X_) = vbString Then
        specificHeatCapacityCp = X_ & " (Brine_gas.specificHeatCapacityCp)"
        Exit Function
    End If
    
    Dim cp_H2O_sat As Double ', cp_H2O As Double, cp_CO2 As Double, cp_N2 As Double, cp_CH4 As Double
    Dim cp_vec(nX_gas + 1) As Double, cp_tmp
    ' cp_vec() = Array(cp_CO2, cp_N2, cp_CH4, cp_H2O)
    
    If i_CO2 > 0 Then
        cp_tmp = SingleGasNasa_cp_T(CO2, T)
        If Not VarType(cp_tmp) = vbDouble Then
            specificHeatCapacityCp = cp_tmp & "Error in cp calculation for " & CO2.name & " (Brine_gas.specificHeatCapacityCp)"
            Exit Function
        End If
        cp_vec(i_CO2 - nX_salt) = cp_tmp
    End If
    
    If i_N2 > 0 Then
        'cp_N2 = SingleGasNasa_cp_T(N2, T)
        cp_tmp = SingleGasNasa_cp_T(N2, T)
        If Not VarType(cp_tmp) = vbDouble Then
            specificHeatCapacityCp = X_ & "Error in cp calculation for " & N2.name & " (Brine_gas.specificHeatCapacityCp)"
            Exit Function
        End If
        cp_vec(i_N2 - nX_salt) = cp_tmp
    End If
    
     If i_H2 > 0 Then
        If Not VarType(cp_tmp) = vbDouble Then
            specificHeatCapacityCp = X_ & "Error in cp calculation for " & H2.name & " (Brine_gas.specificHeatCapacityCp)"
            Exit Function
        End If
        cp_vec(i_H2 - nX_salt) = cp_tmp
    End If
   
    If i_CH4 > 0 Then
        ' cp_CH4 = SingleGasNasa_cp_T(CH4, T)
        cp_tmp = SingleGasNasa_cp_T(CH4, T)
        If Not VarType(cp_tmp) = vbDouble Then
            specificHeatCapacityCp = X_ & "Error in cp calculation for " & CH4.name & " (Brine_gas.specificHeatCapacityCp)"
            Exit Function
        End If
        cp_vec(i_CH4 - nX_salt) = cp_tmp
    End If
    
    'cp_H2O = SingleGasNasa_cp_T(H2O, T)
    cp_tmp = IAPWS.SpecificHeatCapacityCp_pT(Application.Min(p, IAPWS.Waterpsat_T(T) - 1), T)
    If Not VarType(cp_tmp) = vbDouble Then
        specificHeatCapacityCp = X_ & "Error in cp calculation for " & H2O.name & " (Brine_gas.specificHeatCapacityCp)"
        Exit Function
    End If
    cp_vec(nX_gas + 1) = cp_tmp

    If DebugMode Then
        Debug.Print String2Vector(cp_vec)
    End If

    specificHeatCapacityCp = ScalProd(cp_vec, X_) 'mass weighted average
End Function

'ABOVE SPECIFIC TO GAS COMPOSITION
'BELOW GENERIC PART

Function R_gas(Xi)
    Dim X_: X_ = CheckMassVector(Xi, nX)
    If VarType(X_) = vbString Then
        R_gas = X_
        Exit Function
   End If
'    R_gas = ScalProd(X_, Array(CO2.R_s, N2.R_s, CH4.R_s, H2O.R_s))
'    R_gas = ScalProd(X_, Array(CO2.R, R / M_H2, CH4.R, H2O.R))
    R_gas = ScalProd(X_, VecDiv(R, MM_vec))
End Function

Private Function MM_gas(X_) As Double
    MM_gas = CheckMassVector(X_)
    If VarType(MM_gas) <> vbBoolean Then
        Exit Function
    End If
    MM_gas = ScalProd(X_, MM_vec)
End Function

Function density(p As Double, T As Double, Xin)
    'Density of an ideal mixture of ideal gases
    If DebugMode Then
        Debug.Print "Running BrineGas.Density(" & p / 10 ^ 5 & " bar," & T - 273.15 & " °C"
    End If
    
    Dim X_
    X_ = CheckMassVector(Xin, nX)
    If VarType(X_) = vbString Then
        density = X_ & " (Brine_gas.density)"
        Exit Function
    End If
    
    density = p / (T * R_gas(X_))
    Debug.Assert density > 0
End Function

Private Function SingleGasNasa_h_T(data As GasDataRecord, T As Double, Optional exclEnthForm As Boolean = True, Optional ZeroAt0K As Boolean = True, Optional h_off As Double = 0) As Double
    With data
    SingleGasNasa_h_T = _
        IIf(T < .Tlimit, .R_s * ((-.alow(1) + T * (.blow(1) + .alow(2) * Math.Log(T) + T * (1# * .alow(3) + T * (0.5 * .alow(4) + T * (1 / 3 * .alow(5) + T * (0.25 * .alow(6) + 0.2 * .alow(7) * T)))))) / T) _
            , .R_s * ((-.ahigh(1) + T * (.bhigh(1) + .ahigh(2) * Math.Log(T) + T * (1# * .ahigh(3) + T * (0.5 * .ahigh(4) + T * (1 / 3 * .ahigh(5) + T * (0.25 * .ahigh(6) + 0.2 * .ahigh(7) * T)))))) / T)) _
        + IIf(exclEnthForm, -.Hf, 0#) + IIf(ZeroAt0K, .h0, 0#) + h_off
    End With
End Function

Private Function SingleGasNasa_cp_T(data As GasDataRecord, T As Double, Optional exclEnthForm As Boolean = True, Optional ZeroAt0K As Boolean = True, Optional h_off As Double = 0) As Double
    With data
        SingleGasNasa_cp_T = _
        IIf(T < .Tlimit, _
            .R_s * (1 / (T * T) * (.alow(1) + T * (.alow(2) + T * (1# * .alow(3) + T * (.alow(4) + T * (.alow(5) + T * (.alow(6) + .alow(7) * T))))))) _
            , .R_s * (1 / (T * T) * (.ahigh(1) + T * (.ahigh(2) + T * (1# * .ahigh(3) + T * (.ahigh(4) + T * (.ahigh(5) + T * (.ahigh(6) + .ahigh(7) * T))))))) _
        )
    End With
End Function

Function dynamicViscosity(p As Double, T As Double, Optional X_)
    dynamicViscosity = GasProps.MoistAirDynamicViscosity(T)
End Function
