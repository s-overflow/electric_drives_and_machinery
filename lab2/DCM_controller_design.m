clc
close all

% dummy values from the lecture
Ra = 0.702;
La = 0.0014;
kPhi = 0.252;
I = 0.0168;
Ts = 200*1e-9;

%% load our parmeters
% overrides dummy values from the lecture
load dcm_meas_params

Ra  = dcm.Ra;
La = dcm.La;
kPhi = interp1(dcm.if_tab, dcm.KPhi_tab, 0.6);
I = shaft.Itotal;

s=tf('s');
z = tf('z',Ts);

% transfer function matrix - not needed in actual design process
G = [(s*La + Ra), kPhi; kPhi, -(s*I)]^-1;


%% design current controller
% Ia-Va TF, setting TExt as disturbance, neglecting kfric
G_iv_s = I*s /(I*La*s^2 + Ra*I*s + (kPhi)^2);
G_iv_z = c2d(G_iv_s, Ts);

% unit delay due to current sampling
G_conv_z = tf(1,[1,0], Ts);

G_iz = G_conv_z * G_iv_z;   %G_iv with unit delay

% use continuous time rule of thumb for starting
Ci.kP = 5*Ra;
Ci.Tn = La/Ra;
Ci.Gs = Ci.kP*(1 + 1/(Ci.Tn*s));    % very stable, maybe slow
Ci.Gz = c2d(Ci.Gs, Ts);

%sisotool(G_iv_z, Ci.Gz, 1, 1);
load("tuned_controllers/current_controller.mat")
%save('current_controller.mat', "Ciii")
%Ciii = Ci.Gz;


Li_z = G_iz*Ciii;  % neglect time delay
%Li_z = G_iz*Ciii;     % considers time delay
Ti_z = Li_z/(1+Li_z); %feedback(Li_z, 1);

figure(1),clf;
hold on
bode(G_iv_z)
bode(Ciii);
bode(Li_z)
hold off
grid minor
xlim([1, 1e5])
title("current controller")
legend(["G(z)", "C(z)", "L(z)"])

figure(2)
bode(Ti_z)
xlim([1, 1e5])
title("inner loop overall TF")
grid minor

%step(Ti_z)

% time-discrete kP and Tn for controller in correct struct for lab
[bi, ~] = tfdata(Ciii, 'v');
ctrl.i.k = bi(1);
ctrl.i.T = Ts*bi(1)/(bi(1)+bi(2));
ctrl.i.kb = Ts/ctrl.i.T;

% saturation for va
ctrl.i.satP = 40;
ctrl.i.satN = -40;
%% Design speed controller
% Omega-Va TF, setting TLoad as disturbance, neglecting kfric
G_wv_s = ss(kPhi /(I*La*s^2 + Ra*I*s + (kPhi)^2));
% G_wv_s = ss(G_wv_s);
G_wv_z = c2d(G_wv_s, Ts);
G_wv_z = minreal(G_wv_z);   % minimalrealisierung
[mu, nu] = tfdata(G_wv_z, 'v');

G_w_z = feedback(Ciii*G_conv_z, G_iv_z)*G_wv_z;
% feedback speed filter in sisotool

% rule of thumb estimates
Cw.kP = 1*Ra;
Cw.Tn = 1/nu(2);
Cw.Gs = Cw.kP*(1 + 1/(Cw.Tn*s));    
Cw.Gz = c2d(Cw.Gs, Ts);

F_wq_s = ss(tf(1, [1/(2*pi*20), 1]));
F_wq_z = c2d(F_wq_s, Ts, 'tustin');


%sisotool(G_w_z, 1,1, 1)
%save('speed controller.mat', "Cwww");
load("tuned_controllers/speed controller.mat")

Lw_z = G_w_z*Cwww;
Tw_z = feedback(Lw_z,F_wq_z);

figure(3),clf;
hold on
bode(G_wv_z)
bode(Cwww);
bode(Lw_z)
hold off
xlim([1, 1e5])
grid minor
title("speed controller")
legend(["G(z)", "C(z)", "L(z)"])

figure(4)
bode(Tw_z)
xlim([1, 1e5])
title("outer loop overall TF")
grid minor

%step(Tw_z)

% time-discrete kP and Tn for controller in correct struct for lab
[bw, ~] = tfdata(Cwww, 'v');
ctrl.w.k = bw(1);
ctrl.w.T = Ts*bw(1)/(bw(1) + bw(2));
ctrl.w.kb = Ts/ctrl.w.T * 500;
% saturation for ia
ctrl.w.satP = 30;
ctrl.w.satN = -30;

% for simulation
use_nonlin_model = 0;

%%
close all







