Attribute VB_Name = "Constants"
' Public Const R = 8.314472
Public Const R = 8.31446261815324 ' Modelica.Constants.R

Sub DefineWater()
    With H2O
        .name = "H2O"
        .MM = 0.018015268 '[kg/mol] from Modelica.Media.Water.waterConstants
        .Hf = -13423382.8172529
        .h0 = 549760.647628014
        .Tlimit = 1000
        .alow = Array(-39479.6083, 575.573102, 0.931782653, 0.00722271286, -0.00000734255737, 4.95504349E-09, -1.336933246E-12)
        .blow = Array(-33039.7431, 17.24205775)
        .ahigh = Array(1034972.096, -2412.698562, 4.64611078, 0.002291998307, -0.000000683683048, 9.42646893E-11, -4.82238053E-15)
        .bhigh = Array(-13842.86509, -7.97814851)
        .R_s = R / .MM '461.523329085088
        .nM = 1
    End With
End Sub
