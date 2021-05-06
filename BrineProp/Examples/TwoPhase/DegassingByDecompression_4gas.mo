within BrineProp.Examples.TwoPhase;
model DegassingByDecompression_4gas
  "Degassing example for 2-phase brine property model"
  //needs "Advanced.PedanticModelica:=false" to run
  //should be run with 500 steps on equidistant time grid

//SPECIFY MEDIUM and COMPOSITION
  package Medium = BrineProp.Brine3salts4gas(AssertLevel=1);

  Medium.BaseProperties props;

  Real GVF = props.GVF "<- PLOT ME!";
  Real p_bar = props.p/1e5 "pressure in bar (For Plotting)";
  SI.Pressure p_degas = sum(props.p_degas);
  SI.Temp_C T_C = SI.Conversions.to_degC(props.T);
equation
  //SPECIFY THERMODYNAMIC STATE
  //degassing by decompression starting at reservoir conditions
  props.p = (100-98.5*time)*1e5;
  props.T = 125+273.15;

  //specify brine composition (NaCl, KCl, CaCl2, CO2, N2, CH4, H2)
//  props.Xi = {0.0839077010751,0.00253365118988,0.122786737978,7.2426359111e-05,0.000689505657647,6.14906384726e-05, 1e-4} "GrSk brine (Feldbusch 2-2013 1.1775g/ml V2)";
  props.Xi = {0,0,0, 1e-01,0e-04,0e-04, 0e-4};
  annotation (__Dymola_Commands(file="Resources/Scripts/DegassingByDecompression_4gas.mos"
        "Plot degassing"), experiment(__Dymola_NumberOfIntervals=100));
end DegassingByDecompression_4gas;
