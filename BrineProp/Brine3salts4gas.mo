within BrineProp;
package Brine3salts4gas
    "Two-phase aqueous solution of NaCl, KCl, CaCl2, N2, CO2, CH4, H2"
  extends Brine3salts3gas(
    iH2=7,
    final gasNames = {"carbondioxide","nitrogen","methane","hydrogen"},
    final MM_gas = {M_CO2,M_N2,M_CH4,M_H2},
    final nM_gas = {nM_CO2,nM_N2,nM_CH4,nM_H2}); //iGas not final, because reassigned in Brine5salts3gas


  redeclare function solubilities_pTX
    "solubility calculation"
    //  extends PartialBrineMultiSaltMultiGasTwoPhase.solubilities_pTX;
    // TODO: avoid repeating the declarations below (extending Brine3salts3gas doesn't work [multiple algorithms]
    input SI.Pressure p;
    input SI.Temp_K T;
    input SI.MassFraction X_l[nX] "mass fractions m_x/m_Sol";
    input SI.MassFraction X[nX] "mass fractions m_x/m_Sol";
    input SI.Pressure[nX_gas] p_gas;
    input Boolean ignoreTlimit=false "activated by temperature_phX";
  //  input SI.MolarMass MM[:] "=fill(0,nX)molar masses of components";
  //  output Molality[nX_gas] solu;
    output MassFraction solu[nX_gas] "gas concentration in kg_gas/kg_fluid";

  algorithm
    if debugmode then
        //print("\nRunning setState_pTX("+String(p/1e5)+" bar,"+String(min(1000,T)-273.15)+" degC, ignoreTlimit="+String(ignoreTlimit)+", X="+Modelica.Math.Matrices.toString(transpose([X]))+")");
        print("\nRunning setState_pTX(p_gas={"+String(p_gas[1])+", "+String(p_gas[2])+", "+String(p_gas[3])+"}) (solubilities_pTX)");
    end if;
    if debugmode then
        print("Running solubilities_pTX("+String(p/1e5)+" bar,"+String(T-273.15)+" C, ignoreTlimit="+String(ignoreTlimit)+", X="+Modelica.Math.Matrices.toString(transpose([X]))+")");
    end if;
      solu[iCO2-nX_salt] := if X[iCO2]>0 then solubility_CO2_pTX_Duan2006(p,T,X_l,MM_vec,p_gas[iCO2-nX_salt],ignoreTlimit) else -1
    "aus GasData, mol/kg_H2O -> kg_CO2/kg_H2O";
      solu[iN2-nX_salt] :=if X[iN2] > 0 then solubility_N2_pTX_Mao2006(p,T,X_l,MM_vec,p_gas[iN2-nX_salt],ignoreTlimit) else -1
    "aus GasData, mol/kg_H2O -> kg_N2/kg_H2O";
      solu[iCH4-nX_salt] := if X[iCH4]>0 then solubility_CH4_pTX_Duan2006(p,T,X_l,MM_vec,p_gas[iCH4-nX_salt],ignoreTlimit) else -1
    "aus GasData, mol/kg_H2O -> kg_CH4/kg_H2O";

      solu[iH2-nX_salt] := if X[iH2]>0 then solubility_H2_pTX_Chabab2020(p,T,X_l,MM_vec,p_gas[iH2-nX_salt],ignoreTlimit) else -1
    "aus GasData, mol/kg_H2O -> kg_CH4/kg_H2O";

  //  print("k={"+String(solu[1]/p_gas[1])+", "+String(solu[2]/p_gas[2])+", "+String(solu[3]/p_gas[3])+"}(solubilities_pTX)");
  //  print("solu={"+String(solu[1])+", "+String(solu[2])+", "+String(solu[3])+"}(solubilities_pTX)");
  //  print(Modelica.Math.Matrices.toString({MM_vec}));
  end solubilities_pTX;

 redeclare function extends dynamicViscosity_gas
 algorithm
   eta  :=BrineGas3Gas.dynamicViscosity(BrineGas3Gas.ThermodynamicState(
       state.p,
       state.T,
       state.X_g));
   assert(eta>0,"Error in gas viscosity calculation.");
 end dynamicViscosity_gas;

  redeclare function extends saturationPressures
  algorithm

  //  if gasname =="carbondioxide" then
      p_sat[iCO2-nX_salt] := if X[iCO2]>0 then degassingPressure_CO2_Duan2006(p,T,X,MM_vec) else 0
    "aus GasData TODO: use numeral";
  //  elseif gasname =="nitrogen" then
      p_sat[iN2-nX_salt] :=if X[iN2] > 0 then GasData.degassingPressure_N2_Mao2006(p,T,X,MM_vec) else 0
    "aus GasData";
  //  elseif gasname =="methane" then
      p_sat[iCH4-nX_salt] := if X[iCH4]>0 then degassingPressure_CH4_Duan2006(p,T,X,MM_vec) else 0
    "aus GasData";
  //  end if;
    if debugmode then
      print("saturationPressures("+String(p)+","+String(T)+")={"+Modelica.Math.Matrices.toString({p_sat})+"}");
    end if;
  end saturationPressures;

  redeclare function extends specificHeatCapacityCp_gas
    "calculation of gas specific heat capacity"
  import SG = Modelica.Media.IdealGases.SingleGases;
  algorithm
    if state.x>0 then

      cp :=BrineGas3Gas.specificHeatCapacityCp_pTX(
          p=state.p,
          T=state.T,
          X=X_g[end - nX_gas:end]);
    else
      cp:=-1;
    end if;

      annotation (Documentation(info="<html>
                                <p>In the two phase region this function returns the interpolated heat capacity between the
                                liquid and vapour state heat capacities.</p>
                                </html>"));
  end specificHeatCapacityCp_gas;
end Brine3salts4gas;
