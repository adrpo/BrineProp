within BrineProp.GasData;
function solubility_H2_pTX_Chabab2020_molality
    // passes on p_gas + p_H2O as absolute pressure to correlation function
    // returns mass fraction
    input Real p;
    input Real T;
    input Real[:] X;
    input SI.Pressure p_gas;
    output Types.Molality b_H2;
protected
    Types.Molality molalities[size(X, 1)]= Utilities.massFractionsToMolalities(X, MM_vec);
    Real m_Cl = molalities(i_NaCl) + molalities(i_KCl) + 2 * molalities(i_CaCl2); //' + 2 * molalities(i_MgCl2);
    Real m_Na = molalities(i_NaCl);
    Real m_K = molalities(i_KCl);
    Real m_Ca = molalities(i_CaCl2);
//    Real m_Mg = 0 ' molalities(i_MgCl2);
//    Real m_SO4 = 0 ' molalities(i_MgCl2);

    Real b_NaCl = m_Na + m_K + 2 * m_Ca + 2 * m_Mg;
    // Debug.Print "b_NaCl: "; b_NaCl

    SI.Pressure p_H2O = Modelica.Media.Water.WaterIF97_pT.saturationPressure(T);
algorithm
    b_H2 :=solubility_H2_pTb_Chabab2020_molality(
      p_gas + p_H2O,
      T,
      b_NaCl);                                                              // mole fraction b_H2 / b/H2O
end solubility_H2_pTX_Chabab2020_molality;
