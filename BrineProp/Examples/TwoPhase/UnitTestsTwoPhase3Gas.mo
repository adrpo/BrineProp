within BrineProp.Examples.TwoPhase;
model UnitTestsTwoPhase3Gas
  //Compares calculation result with hardcoded values.
  //no assert should be triggered
  //To be filled...

//SPECIFY MEDIUM and COMPOSITION

  package Medium = BrineProp.Brine3salts3gas(ignoreLimitN2_T=true,ignoreLimitSalt_T=fill(true,3));
  Real[Medium.nXi] Xi = {0.0839077010751,0.00253365118988,0.122786737978,0.00016883,0.00073459,0.000065652};

//DEFINE BRINE COMPOSITION (NaCl, KCl, CaCl2, MgCl2, SrCl2, CO2, N2, CH4)
/*   package Medium = BrineProp.Brine5salts3gas;
  Real[Medium.nXi] Xi = {0.0839077010751,0.00253365118988,0.122786737978,0,0,7.2426359111e-05,0.000689505657647,6.14906384726e-05} ;
*/

/*  package Medium = BrineProp.Water_MixtureTwoPhase_pT;
    Real[Medium.nXi] Xi= fill(0,0);*/

  Medium.BaseProperties props;
equation
  props.p = 200000;
  props.T = 300;
  props.Xi = Xi;

  assert(abs(props.GVF-0.32448128)<1e6,"GVF differs!");
  assert(abs(props.h-188780.97)<1e6,"GVF differs!");
  annotation (experiment(StopTime=1, __Dymola_NumberOfIntervals=1),
      __Dymola_experimentSetupOutput);
end UnitTestsTwoPhase3Gas;
