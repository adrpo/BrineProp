within BrineProp;
package BrineGas4Gas "\"Gas mixture of CO2+N2+CH4+H2+H2O\""
  extends BrineGas3Gas(
    final substanceNames={"carbondioxide","nitrogen","methane","hydrogen", "water"},
    iH2=4,
    final MM_vec = {M_CO2,M_N2,M_CH4,M_H2,M_H2O},
    final nM_vec = {nM_CO2,nM_N2,nM_CH4,nM_H2,nM_H2O});

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

  //  SI.SpecificEnthalpy[:] h_vec={h_CO2,h_N2,h_CH4,h_H2,h_H2O};
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
