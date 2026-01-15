clc
close all

if(~exist('G_iv_s', 'var'))
    run("init/IM_parameters_init.m")
    disp("Loaded init file first")
end

z = tf('z',Ts);

% discrete time TF
G_iv_z = c2d(G_iv_s, Ts);           % voltage to current
F_lambdai_z = c2d(F_lambdai_s, Ts); % current to flux linkage model
G_h_z = c2d(G_h_s, Ts);             % actual flux relation        

%% current controller
% place zero of controller at pole of plant, cancel gain, add safety margin
% for satbility by adjusting controller gain, which then determines pole of
% overall transfer function Ti(z)

[zGiv, pGiv,kGiv] = zpkdata(G_iv_z, 'v');
% remaining controller must be within unit sphere, faster when near border,
% but phase margin must be sufficient
zCi = pGiv;
pCi = 1;                % pole: discrete PI has pole always at one
% w1Ci = 2*pi*1;
% kCi = w1Ci/abs(freqresp(G_iv_s, w1Ci));  % gain: rule of thumb
kCi = 0.001/kGiv;       % limit : 1/kGiv
Ci_z = zpk(zCi, pCi, kCi, Ts);

% neglect time delay
Li_z = G_iv_z*Ci_z;  
Ti_z = minreal(Li_z/(1+Li_z)); %feedback(Li_z, 1);

% considers time delay due to converter
Li_zz = Li_z * tf(1,[1, 0], Ts);   
Ti_zz = minreal(Li_zz/(1+Li_zz));

figure(1),clf;
hold on
bode(G_iv_z)
bode(Ci_z);
bode(Li_z)
hold off
grid minor
xlim([1, 1e5])
title("current controller")
legend(["G(z)", "C(z)", "L(z)"])

figure(2),clf
hold on
step(Ti_zz)
step(Ti_z)
hold off
grid minor
legend(["with delay", "without delay"])
title("inner loop overall step response")

ctrl.Ts = Ts;       % controller sampling time

% time-discrete kP and Tn for controller in correct struct for lab
ctrl.i = GetCtrlForm4Lab(Ci_z, Ts);

% save('tuned_controllers/std_controllers.mat', "ctrl")

% cancel plant pole in continuous time to get starting point for tuning in
% discrete time
% Ci gains in continuous time
% kIi = R_sigma;              % integral gain
% kPi = R_sigma*Tau_sigma;    % proportional
% Ci_s = kIi*1/s + kPi;
% sisotool(G_iv_z, Ci_z, 1, 1);

clear("bi")

%% flux controller
% use continuous time rule of thumb for starting
C_lambda = GetPI4Tuning(Tau_R, Lm, Ts);
G_lambda_z = F_lambdai_z*Ti_z;

% fine tune controller
%sisotool(G_lambda_z, C_lambda.Gz, 1, 1);
C_lambda_z = C_lambda.Gz;

% neglect time delay
L_lambda_z = G_lambda_z*C_lambda_z;  
T_lambda_z = minreal(L_lambda_z/(1+L_lambda_z)); %feedback();

% considers time delay due to converter
L_lambda_zz = L_lambda_z * 1/z;
T_lambda_zz = minreal(L_lambda_z/(1+L_lambda_z)); %feedback();

figure(1),clf;
hold on
bode(G_lambda_z)
bode(C_lambda_z);
bode(L_lambda_z)
hold off
grid minor
xlim([1, 1e5])
title("flux controller")
legend(["G(z)", "C(z)", "L(z)"])

figure(2),clf
hold on
step(T_lambda_zz)
step(T_lambda_z)
hold off
grid minor
legend(["with delay", "without delay"])
title("flux loop overall step response")

% time-discrete kP and Tn for controller in correct struct for lab
ctrl.lambda = GetCtrlForm4Lab(C_lambda_z, Ts);

% save('tuned_controllers/std_controllers.mat', "ctrl")

%% speed controller

% approximate flux controller effects on iSd with model mismatch
% consideration 
F_h_z = feedback(C_lambda_z*Ti_z, F_lambdai_z);
H_h_z = minreal(F_h_z * G_h_z);
k_Hlambda = dcgain(H_h_z);

if(round(k_Hlambda, 5) ~= 1)
    warning("DC Gain of flux control loop != 1 - is flux model mismatch desired?")
end

% steady state flux linkage, with possible model mismatch
lambda_Rd_ss = lambda_Rd_ref*k_Hlambda;

% torque constant (useful as compact gain term)
kT = (3/2) * p * (Lm/Lr) * lambda_Rd_ss;

% continous time omega plant part, with Tload = 0
H_omega_s = kT/J * 1/s^2;
H_omega_z = c2d(H_omega_s, Ts);

% speed sensor filter - highpass characteristic
F_speed_z = 1/Ts*(z-1)/z;
F_wq_s = ss(tf(1, [1/(2*pi*20), 1])); % consider LPF dynamic
F_wq_z = c2d(F_wq_s, Ts, 'tustin');

% plant visible to speed controller
G_omega_z = Ti_z * H_omega_z * F_speed_z;
G_omega_z = minreal(G_omega_z);

% get starting point of tuning by guessing (+ bode)
%C_omega = GetPI4Tuning(2e-4, 1, Ts);
C_omega.Gz = zpk(1-2.065e-05,1, 56.416, Ts); % seemed nice, PM ~ 57deg, tr ~ 30ms

%sisotool(G_omega_z, C_omega.Gz, 1, 1);
%sisotool(G_omega_z, C_omega.Gz, F_wq_z, 1); % consider dynamic of speed sensor
C_omega_z = C_omega.Gz;


% neglect time delay
L_omega_z = G_omega_z*C_omega_z;  
T_omega_z = minreal(L_omega_z/(1+L_omega_z)); %feedback();

% considers time delay due to converter
L_omega_zz = L_omega_z * 1/z;
T_omega_zz = minreal(L_omega_z/(1+L_omega_z)); %feedback();


figure(1),clf;
hold on
bode(G_omega_z)
bode(C_omega_z);
bode(L_omega_z)
hold off
grid minor
xlim([1, 1e5])
title("speed controller")
legend(["G(z)", "C(z)", "L(z)"])

figure(2),clf
hold on
step(T_omega_zz)
step(T_omega_z)
hold off
grid minor
legend(["with delay", "without delay"])
title("speed loop overall step response")

% time-discrete kP and Tn for controller in correct struct for lab
ctrl.omega = GetCtrlForm4Lab(C_omega_z, Ts);

%save('tuned_controllers/std_controllers.mat', "ctrl")


function C = GetPI4Tuning(Tau, k, Ts)
% roughly tunes PI controller for a PT1 plant with gain k and 
% time constant Tau. Use it as starting point for fine tuning

    s=tf('s');
    
    C.kP = 5/k;
    C.Tn = Tau;
    C.Gs = C.kP*(1 + 1/(C.Tn*s));    % maybe slow
    C.Gz = c2d(C.Gs, Ts);
end

function ctrl_s = GetCtrlForm4Lab(C_z, Ts)
    [b, ~] = tfdata(C_z, 'v');
    ctrl_s.k = b(1);                 % proportional gain
    ctrl_s.T = Ts*b(1)/(b(1)+b(2));  % integral time (TN)
    ctrl_s.kb = Ts/ctrl_s.T;         % TODO: adjust that backcalc gain when model is ready
end