close all
clc

%% measurements
fnames={'exp001'
        'exp002' 
        'exp003'        
        'exp004' 
        'exp005'
        'exp006'        
        'exp007'
        'exp008'
        'exp009'
        'exp010'
        'exp011'
        'exp012'  
        'exp013'  
        };    

selections = [11];

inverted = [1 1];
offset = [0 0];
additional_text = ["" ""];


selection = selections;

fname="measurements/" + fnames{selection};
mv=load(fname);
aux=fieldnames(mv);
mv=getfield(mv,aux{1});

t=mv.X.Data';              % s, time

t_data = mv.X.Data(:);                 % s

%Currents (measurement)
isd      = mv.Y(11).Data(:);           % A, d-current actual
isq      = mv.Y(12).Data(:);           % A, q-current actual
isd_ref  = mv.Y(14).Data(:);           % A, d-current reference
isq_ref  = mv.Y(15).Data(:);           % A, q-current reference

%Angle / speed (measurement)
phi_el   = mv.Y(18).Data(:);           % rad, electrical position
wfilt    = mv.Y(22).Data(:);           % rad/s, filtered speed

nfilt = wfilt/pi *30;

%Voltages (measurement)
v_sd_ref = mv.Y(4).Data(:);            % V, d-voltage controller output (ref)
v_sq_ref = mv.Y(5).Data(:);            % V, q-voltage controller output (ref)

v_sd_sat = mv.Y(6).Data(:);            % V, d-voltage limited/saturated (sum)
v_sq_sat = mv.Y(7).Data(:);            % V, q-voltage limited/saturated (sum)

torq=mv.Y(20).Data(:);        % Nm, shaft torque

Delta_tm = 1; % time delta to 0 

 
figure(1),clf;
hold on 
plot(t-Delta_tm, isd, 'DisplayName', compose("measurement: i_{Sd %d}%s", selections(1), additional_text(1)));
plot(t-Delta_tm, isd_ref, 'DisplayName', compose("measurement: i_{Sd,%d,ref}%s", selections(1), additional_text(1)),'LineStyle','-.');
hold off

figure(2),clf;
hold on
plot(t-Delta_tm, isq, 'DisplayName', compose("measurement: i_{Sq %d}%s", selections(1), additional_text(1)));
plot(t-Delta_tm, isq_ref, 'DisplayName', compose("measurement: i_{Sq,%d,ref}%s", selections(1), additional_text(1)), 'LineStyle','-.');
hold off

figure(3),clf;
hold on
plot(t-Delta_tm, v_sd_sat, 'DisplayName', compose("measurement: v_{Sd %d}%s", selections(1), additional_text(1)));
plot(t-Delta_tm, v_sd_ref, 'DisplayName', compose("measurement: v_{Sd,%d,ref}%s", selections(1), additional_text(1)), 'LineStyle','-.');
hold off

figure(4),clf;
hold on
plot(t-Delta_tm, v_sq_sat, 'DisplayName', compose("measurement: v_{Sq %d}%s", selections(1), additional_text(1)))
plot(t-Delta_tm, v_sq_ref, 'DisplayName', compose("measurement: v_{Sq,%d,ref}%s", selections(1), additional_text(1)),'LineStyle','-.');
hold off

figure(5),clf;
hold on
plot(t-Delta_tm, nfilt, 'DisplayName', compose("measurement: n_{filt %d}%s", selections(1), additional_text(1)))
hold off

% figure(6)
% plot(t-Delta_tm, torq)
% grid on
% ylabel("shaft torque in Nm")
% xlabel("t in s")


%%

% simulation
Delta_ts = 2; % time of jump in omega
Tl_ts = timeseries(torq, t-Delta_tm+Delta_ts); % load torque as sim input
sim("sim\IM_Control_Sim.slx");

ti = out.iS.Time;
iSd = out.iS.Data(:,1);
iSq = out.iS.Data(:,2);
iSd_ref = out.iSref.Data(:,1); 
iSq_ref = out.iSref.Data(:,2);

tv = out.vS.Time;
vSd = out.vS.Data(:,1);
vSq = out.vS.Data(:,2);

tv_ref = out.vSref.Time;
vSd_ref = out.vSref.Data(:,1);
vSq_ref = out.vSref.Data(:,2);

tw = out.wm_ref.Time;
wm_ref = out.wm_ref.Data;
wm_filt = out.wm_filt.Data;
nref = wm_ref/pi * 30;
nfilt = wm_filt/pi * 30;

% for plots
tmin = 0;
tmax = 2.7;

figure(1)
hold on
plot(ti-Delta_ts, iSd, 'DisplayName', "simulation: i_{Sd}");
plot(ti-Delta_ts, iSd_ref, 'DisplayName', "simulation: i_{Sd,ref}",'LineStyle','-.');
hold off
grid on;
xlabel('time in s');
ylabel('flux building current i_{Sd} in A');
legend show
xlim([tmin tmax]);
hold off;

figure(2)
hold on
hold on
plot(ti-Delta_ts, iSq, 'DisplayName', "simulation: i_{Sd}");
plot(ti-Delta_ts, iSq_ref, 'DisplayName', "simulation: i_{Sd,ref}",'LineStyle','-.');
hold off
grid on;
xlabel('time in s');
ylabel('torque building current i_{Sq} in A');
legend show
xlim([tmin tmax]);
hold off;


figure(3)
hold on
hold on
plot(tv-Delta_ts, vSd, 'DisplayName', "simulation: v_{Sd}");
plot(tv_ref-Delta_ts, vSd_ref, 'DisplayName', "simulation: v_{Sd,ref}",'LineStyle','-.');
hold off
grid on;
xlabel('time in s');
ylabel('D axis stator voltage v_{Sd} in V');
legend show
xlim([tmin tmax]);
hold off;


figure(4)
hold on
hold on
plot(tv-Delta_ts, vSq, 'DisplayName', "simulation: v_{Sq}");
plot(tv_ref-Delta_ts, vSq_ref, 'DisplayName', "simulation: v_{Sq,ref}",'LineStyle','-.');
hold off
grid on;
xlabel('time in s');
ylabel('Q axis stator voltage v_{Sq} in V');
legend show
xlim([tmin tmax]);
hold off;


figure(5)
hold on
hold on
plot(tw-Delta_ts, nfilt, 'DisplayName', "simulation: n_{filt}");
plot(tw-Delta_ts, nref, 'DisplayName', "simulation: n_{ref}",'LineStyle','-.');
hold off
grid on;
xlabel('time in s');
ylabel('(mechanical) angular speed n in rpm');
legend show
xlim([tmin tmax]);
hold off;