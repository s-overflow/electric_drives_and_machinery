clc
close all

if(~exist('G_iv_s', 'var'))
    run("init/IM_parameters_init.m")
    disp("Loaded init file first")
end

z = tf('z',Ts);

% discrete time TF
G_iv_z = c2d(G_iv_s, Ts);           % voltage to current
G_lambdai_z = c2d(G_lambdai_s, Ts); % current to flux linkage 

%% current controller
% cancel plant pole in continuous time to get starting point for tuning in
% discrete time

% place zero of controller at pole of plant, cancel gain, add safety margin
% for satbility by placing controller zero more within the unit sphere 
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
Ti_z = Li_z/(1+Li_z); %feedback(Li_z, 1);

% considers time delay due to converter
Li_zz = Li_z * tf(1,[1, 0], Ts);   
Ti_zz = Li_zz/(1+Li_zz);

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
[bi, ~] = tfdata(Ci_z, 'v');
ctrl.i.k = bi(1);                   % proportional gain
ctrl.i.T = Ts*bi(1)/(bi(1)+bi(2));  % integral time (TN)
ctrl.i.kb = Ts/ctrl.i.T;    % TODO: adjust that backcalc gain when model is ready

% save('tuned_controllers/std_controllers.mat', "ctrl")

% Ci gains in continuous time
% kIi = R_sigma;              % integral gain
% kPi = R_sigma*Tau_sigma;    % proportional
% Ci_s = kIi*1/s + kPi;
% sisotool(G_iv_z, Ci_z, 1, 1);

%% speed controller
