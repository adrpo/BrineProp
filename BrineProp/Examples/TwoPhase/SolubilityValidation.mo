within BrineProp.Examples.TwoPhase;
model SolubilityValidation
  "Minimal degassing example for 2-phase brine property model"
  //needs "Advanced.PedanticModelica:=false" to run

//SPECIFY MEDIUM and COMPOSITION
  package Medium = Brine3salts3gas (AssertLevel=2);
//DEFINE BRINE COMPOSITION (NaCl, KCl, CaCl2, CO2, N2, CH4)
//  Real[Medium.nXi] Xi = 0*{0.0839077010751,0.00253365118988,0.122786737978,7.2426359111e-05,0.000689505657647,6.14906384726e-05}    "GrSk brine (Feldbusch 2-2013 1.1775g/ml V2)";

/*
//   package Medium = BrineProp.Brine5salts3gas(ignoreLimitN2_T=true);
   package Medium = BrineProp.Brine5salts3gas(AssertLevel=2);
//DEFINE BRINE COMPOSITION (NaCl, KCl, CaCl2, MgCl2, SrCl2, CO2, N2, CH4)
  Real[Medium.nXi] Xi = {0.0839077010751,0.00253365118988,0.122786737978,0,0,7.2426359111e-05,0.000689505657647,6.14906384726e-05} 
    "GrSk brine (Feldbusch 2-2013 1.1775g/ml V2)";
*/
//  Medium.BaseProperties props;
  Modelica.SIunits.Pressure p = 1.01325e7;
  Modelica.SIunits.Temperature T = 573.15;
  Real solu = Medium.solubility_N2_pTX_Mao2006(p,T,cat(1,fill(0,6),{1}),Medium.MM_vec,p, false)/Medium.M_N2;
equation
  //SPECIFY THERMODYNAMIC STATE
  //degassing by heating starting at STP
//  props.p = 1.01325e5;
//  props.T = 0+273.15;

  //specify brine composition
//  props.Xi = Xi;
  annotation (__Dymola_Commands(file=
          "Resources/Scripts/SolubiltyValidation.mos"));
end SolubilityValidation;
