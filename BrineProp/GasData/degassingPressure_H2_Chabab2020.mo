within BrineProp.GasData;
function degassingPressure_H2_Chabab2020
  "calculates degassing pressure from concentration of dissolved gas"
  extends partial_degassingPressure_pTX;
/*protected 
    SI.MassFraction solu_soll=X[end-3];*/

algorithm
//  print("p_sat_CH4("+String(X[end-1])+") (degassingPressure_H2_Chabab2020)");

  p_gas := Modelica.Math.Nonlinear.solveOneNonlinearEquation(
      function solubility_res(
        solufun=function solubility_H2_pTX_Chabab2020(),p=p,T=T,X=X,MM_vec=MM_vec,
        c_gas=X[iCH4]),
      0,
      2000e5,
      1e-8);

//  print("p_sat_CH4("+String(X[end-1])+")="+String(p_gas)+" (degassingPressure_H2_Chabab2020)");

end degassingPressure_H2_Chabab2020;
