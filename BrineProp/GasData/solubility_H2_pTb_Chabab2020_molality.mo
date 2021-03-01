within BrineProp.GasData;
function solubility_H2_pTb_Chabab2020_molality
                                               // conversion mole fraction to molality
    input Real p;
    input Real T;
    input Types.Molality b_NaCl;
    output Types.Molality b_H2;
protected
    Real y_H2 = solubility_H2_pTb_Chabab2020_y(p, T, b_NaCl) "mole fraction b_H2 / b/H2O";
algorithm
    b_H2 :=y_H2/(1 - y_H2)/M_H2O;      // mol/kg_H2O
end solubility_H2_pTb_Chabab2020_molality;
