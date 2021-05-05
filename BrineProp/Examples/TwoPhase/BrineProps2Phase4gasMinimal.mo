within BrineProp.Examples.TwoPhase;
model BrineProps2Phase4gasMinimal
  "Minimal degassing example for 2-phase brine property model"
  //needs "Advanced.PedanticModelica:=false" to run

//SPECIFY MEDIUM and COMPOSITION
  package Medium = BrineProp.Brine3salts4gas (AssertLevel=2);
//DEFINE BRINE COMPOSITION (NaCl, KCl, CaCl2, CO2, N2, CH4)
  Real[Medium.nXi] Xi = {0.1,0.1,0.1,1e-05,1e-5,1e-5, 1e-6};

  Medium.BaseProperties props;
//  Medium.BaseProperties props2;
equation
  //SPECIFY THERMODYNAMIC STATE
  //degassing by heating starting at STP
  props.p = 61e5;
  props.T = 60+273.15;
  //specify brine composition
  props.Xi = Xi;

/*  props2.p=(60-time*50)*1e5;
  props2.T = props.T;
  props2.Xi = props.Xi_l;*/
end BrineProps2Phase4gasMinimal;
