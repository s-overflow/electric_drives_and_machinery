% 21.11.2025 R. Seebacher
%
% CoEDaM
%   DC-machine control
%   Adaptation of provided controller parameters to laboratory structure
%
%
% -------------------Preconditions --------------------------------------------------
%
% Ts=200e-6;   s, sampling period
% fc=20;      Hz, cut off frequency of speed filter, first order low pass
% ia_max=30;   A, maximum armature current
% va_max=120;  V, maximum armature voltage
% ie=0.6;      A, excitation current
%
% PI controller
%  [b1*z+b0]/(z-1) = b1*[1+(b1+b0)/b1*1/(z-1)]= k*(1 + Ts/T*1/(z-1)]
%   => k=b1
%   => T=Ts*b1/(b1+b0)
%
%  Back calculation according to Hanus conditioning technique
%  u(k)...actuating signal at t=k*Ts, k=0,1,2....
%  u_sat(k)...saturated actuating signal
%  e(k)...control error
%  e_sat(k)...adapted control error that fits to u_sat(k)
%  i(k)...integrator output
%
%       u(k)=k*(e(k)+i(k))
%       u_sat(k)=k*(e_sat(k)+i(k))
%          =>   e_sat(k)=(u_sat(k)-u(k))/k+e(k)
%       i(k+1)=i(k)+Ts/T*e(k)-Ts/T*(u(k)-u_sat(k))/k  
%          =>   kb=Ts/(T*k)
%
% --------------------Required structure -------------------------------------------- 
%
% current controller
% ctrl.i.Ts     double, sampling period
% ctrl.i.k      double, gain
% ctrl.i.T      double, integrator time constant
% ctrl.i.kb     double, back calculation coefficient
% ctrl.i.name   string, identfification
%
% speed controller
% ctrl.w.Ts     double, sampling period
% ctrl.w.k      double, gain
% ctrl.w.T      double, integrator time constant
% ctrl.w.kb     double, back calculation coefficient
% ctrl.w.name   string, identfification
%

%% user settings
user.save=0;
user.filename='unintentionally'; 
%user.filename='Meinhart';


%% provided data
load("ctrl_params.mat");

% current controller
%num_i=aux.Ci_z_fast.num{1};  % activate for slow current controller, it's interchanged in Mr. Fritzenwallners mat-file 
ctrl.i.Ts=200e-6;  % activate for slow current controller

%num_i=aux.Ci_z_slow.num{1};  % activate for fast current controller
%ctrl.i.Ts=aux.Ci_z_slow.Ts;  % activate for fast current controller

% speed controller
%num_w=aux.Cw_z.num{1};
ctrl.w.Ts=ctrl.i.Ts;

%% adapt to predefined structure

%ctrl.i.k=num_i(1);
%ctrl.i.T=ctrl.i.Ts*ctrl.i.k/sum(num_i);
% following Hanus' conditioning technique
%ctrl.i.kb=ctrl.i.Ts/(ctrl.i.T*ctrl.i.k);
ctrl.i.name='Meinhart_2025_11_25';

% speed controller
%ctrl.w.k=num_w(1);
%ctrl.w.T=ctrl.w.Ts*ctrl.w.k/sum(num_w);
% Mr. Fritzenwallner did not provide kb, therefore kb is calculated
% following Hanus' conditioning technique
ctrl.w.kb=ctrl.w.kb*500; %Ts/(ctrl.w.T*ctrl.w.k)*2;  % for our case an increase of kb_Hanus by factor 2 is suitable
ctrl.w.name='Meinhart_2025_11_25';

%% save data
if user.save
    save(user.filename,'ctrl');
end    







