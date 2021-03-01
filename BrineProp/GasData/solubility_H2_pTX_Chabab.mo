within BrineProp.GasData;
function solubility_H2_pTX_Chabab
  // ' Chabab, S., Théveneau, P., Coquelet, C., Corvisier, J. & Paricaud, P. Measurements and predictive models of high-pressure H2 solubility in brine (H2O+NaCl) for underground hydrogen storage application. Int. J. Hydrogen Energy 45, 32206–32220 (2020).
  // For H2 solubility in pure water (Eq. (13)): 273.15 < T (K) < 373.15; 1 < P (bar) < 203
  // For H2 solubility in NaCl-brine (Eq. (12)): 323.15 < T (K) < 373.15; 10 < P (bar) < 230; 0 < molality (mol/kgw) < 5

  extends partial_solubility_pTX;

/*  Types.Molality molalities[size(X, 1)]= Utilities.massFractionsToMolalities(X,MM_vec);
  SI.Temp_C T_C = SI.Conversions.to_degC(T);
  Real L_0=0.252 "N2 solubility in H2O at 25 atm, 75degC";
  Real L_rel_p "pressure influence";
  Real L_rel_c "salinity influence";
  Real L_rel_T "Temperature influence";
  Real c = sum(molalities[1:2])+sum(molalities[3:5])*1.8
    "TODO: remove absolute indices";
  Real p_atm = p_gas/101325;
  */
//  Real c = X[1]/Salt_Data.M_NaCl/X[end];
algorithm
// print("mola_N2("+String(p_gas)+","+String(T-273.16)+") (solubility_N2_pTX_Duan2006)");
  if AssertLevel>0 then
     assert(ignoreTlimit or ignoreLimitH2_T or ((if molalities[iNaCl] > 0 then 273.15 else 323.15)<T and T<373.15), "Temperature out of validity range: T=" + String(T - 273.15) + ".\nTo ignore set ignoreLimitN2_T=true",aLevel);
     assert(ignoreLimitH2_p or ((if molalities[iNaCl] > 0 then 10e5 else 1e5)<p and p<203e5),"Pressure out of validity rangep=" + String(p/1e5) + " bar.\nTo ignore set ignoreLimitN2_p=true",aLevel);
     assert(ignoreLimitH2_b or molalities[iNaCl]<5,"Molality out of validity range: mola[NaCl]=" + String(molalities[iNaCl]) + " mol/kg.\nTo ignore set ignoreLimitH2_b=true",aLevel);
  end if;

  solu :=solubility_H2_pTX_Chabab2020_molality(
      p,
      T,
      X,
      p_gas);                                                   // mol/kg_H2O
  X_gas := solu * M_H2 * X[end]; //molality->mass fraction

//      print("mola_N2("+String(p_gas)+"Pa,"+String(T-273.16)+"degC,"+String(molalities[1])+")="+String(solu)+" (solubility_N2_pTX_Harting)");
//    print("mola_N2("+String(p_gas)+","+String(T-273.16)+")="+String(c_gas)+"->k="+String(c_gas/max(1,p_gas))+" (solubility_N2_pTX_Duan2006)");
end solubility_H2_pTX_Chabab;
