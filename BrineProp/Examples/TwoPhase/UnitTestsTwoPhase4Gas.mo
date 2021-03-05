within BrineProp.Examples.TwoPhase;
model UnitTestsTwoPhase4Gas
  //Compares calculation result with hardcoded values.
  //no assert should be triggered
  //To be filled...

//SPECIFY MEDIUM and COMPOSITION

  package Medium = BrineProp.Brine3salts4gas(ignoreLimitN2_T=true,ignoreLimitSalt_T=fill(true,3));
  Real[Medium.nXi] Xi = {0.0839077010751,0.00253365118988,0.122786737978,0.00016883,0.00073459,0.000065652,0.00001};

//DEFINE BRINE COMPOSITION (NaCl, KCl, CaCl2, MgCl2, SrCl2, CO2, N2, CH4)
/*   package Medium = BrineProp.Brine5salts3gas;
  Real[Medium.nXi] Xi = {0.0839077010751,0.00253365118988,0.122786737978,0,0,7.2426359111e-05,0.000689505657647,6.14906384726e-05} ;
*/

/*  package Medium = BrineProp.Water_MixtureTwoPhase_pT;
    Real[Medium.nXi] Xi= fill(0,0);*/

  Medium.BaseProperties props;
equation
  props.p = 20e5;
  props.T = 330;
  props.Xi = Xi;

  //Unit Test
  assert(abs(props.GVF-0.0497710432105261)<1e6,"GVF differs!");
  assert(abs(props.h-288702.455)<1e6,"h differs!");

  //direct Chabab
  assert(abs(GasData.solubility_H2_pT_Chabab2020_y(1e7, 323.15) - 0.001272328226268451)< 1e-8, "Nope");
  assert(abs(GasData.solubility_H2_pTb_Chabab2020_y(1e7,323.15,1) - 0.000958406222692535) < 1e-8, "Nope");
  assert(abs(GasData.solubility_H2_pTb_Chabab2020_molality(1e7,323.15,1) - 0.0532507008145311) < 1e-8, "Nope");
  assert(abs(0.00396636796628623-Medium.solubility_H2_pTX_Chabab2020_molality(50e5, 323.15,{0.0839077010751,0.00253365118988,0.122786737978,0.00016883,0.00073459,0.000065652,0.00001,0.789792838},Medium.MM_vec,15e5))<1e-8, "Nope");
  assert(abs(6.31433733266665E-06-Medium.solubility_H2_pTX_Chabab2020(50e5, 323.15,{0.0839077010751,0.00253365118988,0.122786737978,0.00016883,0.00073459,0.000065652,0.00001,0.789792838},Medium.MM_vec, 15e5,false))<1e-8, "Nope");

  annotation (experiment(StopTime=1, __Dymola_NumberOfIntervals=1),
      __Dymola_experimentSetupOutput);
end UnitTestsTwoPhase4Gas;
