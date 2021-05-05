within BrineProp;
package BrineGas4Gas "\"Gas mixture of CO2+N2+CH4+H2+H2O\""
  extends BrineGas3Gas(
    final substanceNames={"carbondioxide","nitrogen","methane","hydrogen", "water"},
    iH2=4,
    final MM_vec = {M_CO2,M_N2,M_CH4,M_H2,M_H2O},
    final nM_vec = {nM_CO2,nM_N2,nM_CH4,nM_H2,nM_H2O});

  redeclare function specificHeatCapacityCp_pTX
    "calculation of specific heat capacities of gas mixture"
    input SI.Pressure p;
    input SI.Temp_K T;
    input SI.MassFraction X[nX]=reference_X "Mass fractions";
    output SI.SpecificHeatCapacity cp
    "Specific heat capacity at constant pressure";
    import SG = Modelica.Media.IdealGases.SingleGases;
    import IF97=Modelica.Media.Water.IF97_Utilities;
protected
      SG.H2O.ThermodynamicState state=SG.H2O.ThermodynamicState(p=0,T=T);
      SI.SpecificHeatCapacity cp_CO2=SG.CO2.specificHeatCapacityCp(state);
      SI.SpecificHeatCapacity cp_N2=SG.N2.specificHeatCapacityCp(state);
      SI.SpecificHeatCapacity cp_CH4=SG.CH4.specificHeatCapacityCp(state);
      SI.SpecificHeatCapacity cp_H2=SG.H2.specificHeatCapacityCp(state);
      SI.SpecificHeatCapacity cp_H2O=IF97.cp_pT(min(p,IF97.BaseIF97.Basic.psat(T)-1),T=T)
      "below psat -> gaseous";

      SI.SpecificHeatCapacity cp_vec[nX]; //={cp_CO2,cp_N2,cp_CH4,cp_H2,cp_H2O};

  algorithm
    cp_vec[iCO2]:=cp_CO2;
    cp_vec[iN2]:=cp_N2;
    cp_vec[iCH4]:=cp_CH4;
    cp_vec[iH2]:=cp_H2;
    cp_vec[iCO2]:=cp_H2O; //the two-phase models rely on this order!

    if debugmode then
      print("Running specificHeatCapacityCp_pTX("+String(p/1e5)+" bar,"+String(T-273.15)+" degC, X="+Modelica.Math.Matrices.toString(transpose([X]))+")");
    end if;

    if not ignoreNoCompositionInBrineGas and not min(X)>0 then
      print("No gas composition, assuming water vapour.(BrineProp.BrineGas_3Gas.specificHeatCapacityCp_pTX)");
    end if;

  /*  if waterSaturated then
    cp := cp_vec * waterSaturatedComposition_pTX(p,T,X[end - nX+1:end]);
  else */
  //    cp := cp_vec * X[end - nX+1:end];
    cp := cp_vec * cat(1,X[1:end-1],{if min(X)>0 then X[end] else 1});
      //  end if;

  /*  print("cp_CO2: "+String(cp_vec[1])+" J/kg");
  print("cp_N2: "+String(cp_vec[2])+" J/kg");
  print("cp_CH4: "+String(cp_vec[3])+" J/kg");
  print("cp_H2O: "+String(cp_vec[4])+" J/kg"); */

  end specificHeatCapacityCp_pTX;

  redeclare function specificEnthalpy_pTX
    "calculation of specific enthalpy of gas mixture"
  //  import Modelica.Media.IdealGases.Common.SingleGasNasa;
    import Modelica.Media.IdealGases.SingleGases;
    extends Modelica.Icons.Function;
    input AbsolutePressure p "Pressure";
    input Temperature T "Temperature";
    input MassFraction X[:]=reference_X "Mass fractions";
    output SpecificEnthalpy h "Specific enthalpy";
protected
    SI.SpecificEnthalpy h_H2O_sat=Modelica.Media.Water.IF97_Utilities.BaseIF97.Regions.hv_p(p);
    SI.SpecificEnthalpy h_H2O=max(h_H2O_sat, Modelica.Media.Water.WaterIF97_pT.specificEnthalpy_pT(p,T))
    "to make sure it is gaseous";

    SingleGases.H2O.ThermodynamicState state=SingleGases.H2O.ThermodynamicState(p=0,T=T);
    SI.SpecificEnthalpy h_CO2=SingleGases.CO2.specificEnthalpy(state);
    SI.SpecificEnthalpy h_N2=SingleGases.N2.specificEnthalpy(state);
    SI.SpecificEnthalpy h_CH4=SingleGases.CH4.specificEnthalpy(state);
    SI.SpecificEnthalpy h_H2=SingleGases.H2.specificEnthalpy(state);

  //  SI.SpecificEnthalpy[:] h_vec={h_CO2,h_N2,h_CH4,h_H2,h_H2O}; //the two-phase models rely on this order!
    SI.SpecificEnthalpy[nX] h_vec;
    SI.MassFraction X_[size(X,1)] "OM workaround for cat";
  algorithm
    h_vec[iCO2]:=h_CO2;
    h_vec[iN2]:=h_N2;
    h_vec[iCH4]:=h_CH4;
    h_vec[iH2]:=h_H2;
    h_vec[end]:=h_H2O;

    X_[1:end-1]:=X[1:end-1] "OM workaround for cat";
    X_[end]:=if min(X)>0 then X[end] else 1 "OM workaround for cat";

    if debugmode then
      print("Running specificEnthalpy_pTX("+String(p/1e5)+" bar,"+String(T-273.15)+" degC, X="+Modelica.Math.Matrices.toString(transpose([X]))+")");
    end if;

    if not min(X)>0 and not ignoreNoCompositionInBrineGas then
      print("No gas composition, assuming water vapour.(BrineProp.BrineGas_3Gas.specificEnthalpy_pTX)");
    end if;

    h := h_vec*X_ "mass weighted average, OM workaround for cat";
  //h := h_vec * cat(1,X[1:end-1], {if min(X)>0 then X[end] else 1}) "Doesn't work in function in OM";

  /*  print("h_CO2: "+String(h_CO2)+" J/kg");
  print("h_N2: "+String(h_N2)+" J/kg");
  print("h_CH4: "+String(h_CH4)+" J/kg");
  print("h_H2O: "+String(h_H2O)+" J/kg");
  print("T: "+String(state.T)+" K");
  */
  end specificEnthalpy_pTX;
end BrineGas4Gas;
