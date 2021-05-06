within BrineProp.GasData;
function solubility_H2_pTX_Chabab2020
  // ' Chabab, S., Théveneau, P., Coquelet, C., Corvisier, J. & Paricaud, P. Measurements and predictive models of high-pressure H2 solubility in brine (H2O+NaCl) for underground hydrogen storage application. Int. J. Hydrogen Energy 45, 32206–32220 (2020).
  // For H2 solubility in pure water (Eq. (13)): 273.15 < T (K) < 373.15; 1 < P (bar) < 203
  // For H2 solubility in NaCl-brine (Eq. (12)): 323.15 < T (K) < 373.15; 10 < P (bar) < 230; 0 < molality (mol/kgw) < 5

  extends partial_solubility_pTX;
protected
  Types.Molality molalities[size(X, 1)]= Utilities.massFractionsToMolalities(X,MM_vec);
//  Real c = X[1]/Salt_Data.M_NaCl/X[end];
  SI.Temp_C T_min = if molalities[iNaCl] > 0 then 273.15 else 323.15;
algorithm
// print("mola_N2("+String(p_gas)+","+String(T-273.16)+") (solubility_N2_pTX_Duan2006)");
  if AssertLevel>0 then
     assert(ignoreTlimit or ignoreLimitH2_T or (T_min<T and T<373.15), "Temperature out of validity range["+String(T_min-273.15)+"...100°C]: T=" + String(T - 273.15) + ".\nTo ignore set ignoreLimitH2_T=true",aLevel);
     assert(ignoreLimitH2_p or ((if molalities[iNaCl] > 0 then 10e5 else 1e5)<p and p<203e5),"Pressure out of validity range. p=" + String(p/1e5) + " bar.\nTo ignore set ignoreLimitN2_p=true",aLevel);
     assert(ignoreLimitH2_b or molalities[iNaCl]<5,"Molality out of validity range: mola[NaCl]=" + String(molalities[iNaCl]) + " mol/kg.\nTo ignore set ignoreLimitH2_b=true",aLevel);
  end if;

  solu :=solubility_H2_pTX_Chabab2020_molality(p,T,X, MM_vec,p_gas);     // mol/kg_H2O
// print("solu:"+String(solu));
  X_gas := solu * M_H2 * X[end]; //molality->mass fraction
//  print("X_H2("+String(p_gas)+"Pa,"+String(T-273.16)+"degC,"+String(molalities[1])+")="+String(X_gas)+" (solubility_H2_pTX_Chabab2020)");
end solubility_H2_pTX_Chabab2020;
