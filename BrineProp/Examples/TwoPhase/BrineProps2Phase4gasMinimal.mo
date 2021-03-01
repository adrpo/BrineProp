within BrineProp.Examples.TwoPhase;
model BrineProps2Phase4gasMinimal
  "Minimal degassing example for 2-phase brine property model"
  //needs "Advanced.PedanticModelica:=false" to run

//SPECIFY MEDIUM and COMPOSITION
  package Medium = BrineProp.Brine3salts4gas (
                                   AssertLevel=2);
//DEFINE BRINE COMPOSITION (NaCl, KCl, CaCl2, CO2, N2, CH4)
  Real[Medium.nXi] Xi = {0.1,0.1,0.1,1e-05,1e-5,1e-5, 1e-6}
    "GrSk brine (Feldbusch 2-2013 1.1775g/ml V2)";

  Medium.BaseProperties props;
equation
  //SPECIFY THERMODYNAMIC STATE
  //degassing by heating starting at STP
  props.p = 1.01325e5;
  props.T = 60+273.15;

  //specify brine composition
  props.Xi = Xi;
end BrineProps2Phase4gasMinimal;
