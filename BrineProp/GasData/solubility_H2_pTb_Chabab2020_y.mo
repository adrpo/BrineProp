within BrineProp.GasData;
function solubility_H2_pTb_Chabab2020_y
                                          // mole fraction b_H2 / b/H2O
    // p is absolute pressure, here p_H2 + p_H2O
    // Debug.Print "p="; p / 100000#; "bar"
    input Real p;
    input Real T;
    input Types.Molality b_NaCl;
    output Real y_H2; //x_H2 in article
protected
    Real y_H2_0 = solubility_H2_pT_Chabab2020_y(p, T); //x_H2O_0 in article
    //print("x_H2_0: "+String(x_H2_0");
    Real[2] a = {0.018519,    -0.30185103};
algorithm
    //Debug.Print "ln(xH2/xH2°)"; a1 * b_NaCl ^ 2 + a2 * b_NaCl 'equ. 12
    y_H2 :=y_H2_0*exp(a[1]*b_NaCl^2 + a[2]*b_NaCl);         //x_H2 (equ. 12)
end solubility_H2_pTb_Chabab2020_y;
