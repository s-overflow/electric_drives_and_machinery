Ts=0.1993e-3; % s, switching period and sampling period of controller

T_Load = 0;

p = 1;

J = 0.1;


R_S = 0.1995;
R_R = 85e-03;

l_sigma_S = 0.4024e-03;
L_sigma_R = 0.4024e-03;

L_m = 5.685e-03;


lamda_Rd_ref = 1;

w_mech_ref = 20;



R_sigma = R_S + R_R;
L_sigma = l_sigma_S + L_sigma_R;
tau_sigma = L_sigma / R_sigma;

PT1_stator = (1/R_sigma) * tf(1,[tau_sigma 1]);


L_R = L_sigma_R + L_m;
tau_R = L_R / R_R;

PT1_rotor = tf(L_m, [tau_R 1]);


PT1_flux = tf(L_m, [tau_R 1]);


Speed_Filter = ss(tf(1, [1/(2*pi*20), 1]));

s = tf('s');

fc = 500;
wc = 2*pi*fc;

% use continuous time rule of thumb for starting
Ci.kP = L_sigma * wc;
Ci.Tn = tau_sigma;
Ci.Gs = Ci.kP*(1 + 1/(Ci.Tn*s));    % very stable, maybe slow
Ci.Gz = c2d(Ci.Gs, Ts);

G_stator = c2d(PT1_stator, Ts);

sisotool(G_stator, Ci.Gz, 1, 1);


% ctrl.i.k = Cz_tuned.Kp;
% Ki       = Cz_tuned.Ki;
% ctrl.i.T = ctrl.i.k / Ki;
% ctrl.i.kb = Ts/ctrl.i.T;

% %% design current controller
% % Ia-Va TF, setting TExt as disturbance, neglecting kfric
% G_iv_s = I*s /(I*La*s^2 + Ra*I*s + (kPhi)^2);
% G_iv_z = c2d(G_iv_s, Ts);
% 
% % unit delay due to current sampling
% G_conv_z = tf(1,[1,0], Ts);
% 
% G_iz = G_conv_z * G_iv_z;   %G_iv with unit delay
% 
% % use continuous time rule of thumb for starting
% Ci.kP = 5*Ra;
% Ci.Tn = La/Ra;
% Ci.Gs = Ci.kP*(1 + 1/(Ci.Tn*s));    % very stable, maybe slow
% Ci.Gz = c2d(Ci.Gs, Ts);
% 
% sisotool(G_iv_z, Ci.Gz, 1, 1);