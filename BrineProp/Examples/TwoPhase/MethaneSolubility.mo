within BrineProp.Examples.TwoPhase;
model MethaneSolubility
  "Comparing solubility direct with VLE result for one gas"
  //needs "Advanced.PedanticModelica:=false" to run
  //if solubility is calculated with X instead of X_l, a difference shows. It is due to the concentration increase by evaporation
  import S = BrineProp.SaltData;
  import G = BrineProp.GasData;
//SPECIFY MEDIUM and COMPOSITION
  package Medium = BrineProp.Brine3salts3gas(AssertLevel=0);

  Medium.BaseProperties props;

  Real c = Medium.solubility_CH4_pTX_Duan2006(props.p,props.T,props.X_l,
  Medium.MM_vec,
  props.p,
  false);
equation
  //SPECIFY THERMODYNAMIC STATE
  //degassing by decompression starting at reservoir conditions
  props.p = time*1e5;
  props.T = 32+273.15;

  //specify brine composition (NaCl, KCl, CaCl2, CO2, N2, CH4)
  props.Xi = {0.0839077010751,0.00253365118988,0.122786737978,0,0,0.1}
    "GrSk brine (Feldbusch 2-2013 1.1775g/ml V2)";
  annotation (__Dymola_Commands(file(autoRun=true) = "Resources/Scripts/MethaneSolubility.mos"
        "Plot dissolved methane"),
      experiment(
      StartTime=1.5,
      StopTime=199,
      __Dymola_NumberOfIntervals=100,
      __Dymola_Algorithm="Dassl"));
end MethaneSolubility;
