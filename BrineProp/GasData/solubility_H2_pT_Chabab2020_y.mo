within BrineProp.GasData;
function solubility_H2_pT_Chabab2020_y
                                       // returns salt-free mole fraction
    input Real p;
    input Real T;
    output Real y_H2;
protected
    Real p_bar = p / 1e5;
    constant Real b[4] = {0.0000003338844,
                          0.0363161,
                         -0.00020734,
                         -2.1301815E-09};
algorithm
    assert(p > 0, "#p_gas negative! (GasData.solubility_H2_pT_Chabab2020_molality)");

    if not p > 0 then // = 0
       y_H2 :=0;
    else
       y_H2 :=b[1]*p_bar*T + b[2]*p_bar/T + b[3]*p_bar + b[4]*p_bar^2;               //equ. 13
    end if;
end solubility_H2_pT_Chabab2020_y;
