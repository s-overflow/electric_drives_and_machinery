% 20.11.2025 R. Seebacher
% CoEDaM WS25/26
% DCM-Control, show measurements
%
%

%% data pool

fnames={'exp01'
        'exp02' 
        'exp03'        
        'exp04' 
        'exp05'
        'exp06'        
        'exp07'
        'exp08'
        'exp09'
        'exp10'
        'exp11'        
        };    

%% load data
selection=11;           % pick out one of the experiments listed in fnames

fname=fnames{selection};
mv=load(fname);
aux=fieldnames(mv);
mv=getfield(mv,aux{1});

%% assign variables

% for z=1:length(mv.Y) disp([num2str(z) ' ' mv.Y(z).Path '/' mv.Y(z).Name]); end
% 
% available:
% Nr.   Quantity
% 1 Model Root/mr/DCM/ia_controller/va_ref
% 2 Model Root/mr/DCM/speed_controller/I/Out1
% 3 Model Root/mr/DCM/sw_ia_ref/Out1
% 4 Model Root/mr/IM/Observer/isd
% 5 Model Root/mr/IM/Observer/isq
% 6 Model Root/mr/IO/phielectrical1/phi
% 7 Model Root/mr/IO/scale1/dcm_ia
% 8 Model Root/mr/IO/scale1/dcm_ie
% 9 Model Root/mr/IO/scale1/torque
% 10 Model Root/mr/IO/vdc_filter1/Out1
% 11 Model Root/mr/IO/w_filter/Out1
% 12 Model Root/mr/IO/w/Out1
% 13 Model Root/mr/wref/wref

t=mv.X.Data';              % s, time

varef=mv.Y(1).Data';       % V, armature reference voltage
ia=mv.Y(7).Data';          % A, armature current
iaref=mv.Y(3).Data';       % A, armature reference current
ie=mv.Y(8).Data';          % A, field current    
isd=mv.Y(4).Data';         % A, flux building current component of IM
isq=mv.Y(5).Data';         % A, torque building current component of IM
phiel=mv.Y(6).Data';       % rad, electrical rotor position (= mech. Rotorlage*2)
torq=mv.Y(9).Data';        % Nm, shaft torque
vdc=mv.Y(10).Data';        % V, filtered DC-link voltage
w=mv.Y(12).Data';          % rad/s, speed unfiltered
wfilt=mv.Y(11).Data';      % rad/s, speed filtered
wref=mv.Y(13).Data';       % rad/s, reference speed

%% 
stop_time = 2;
w_ref_start = -2000/30*pi;
w_ref_stop = 2000/30*pi;

t_step = 0.5;

% IC
w0 = w(1)/10;
ia0 =0;%ia(1);


time_shift = 0.5;
torq_ts = timeseries(torq, t+time_shift);
torq_ts.Data(1) = 0;
torq_ts.Time(1) = 0;


%% presentation
% shift simulated time series to account for settling time
ia_sim_res = ia_sim.Data(ia_sim.time > time_shift);
va_sim_res = va_sim.Data(ia_sim.time > time_shift);
w_sim_res = w_sim.Data(ia_sim.time > time_shift);
t_sim_res = ia_sim.time(ia_sim.time > time_shift) - time_shift;

clc

fn=1;
figure(fn);clf;
hold on
plot(t,iaref,t,ia);
plot(t_sim_res, ia_sim_res)
hold off
grid on;
xlabel('time in s');
ylabel('armature current in A');
legend(["reference", "measured", "simulated"]);
xlim([0.4 stop_time]);
% ylim([-0.2 1.2]);



fn=fn+1;
figure(fn),clf;
hold on
plot(t,varef);
plot(t_sim_res,va_sim_res)
hold off
grid on;
xlabel('time in s');
ylabel('armature voltage in V');
legend(["measured", "simulated"]);
xlim([0.4 stop_time]);


fn=fn+1;
figure(fn);clf;
hold on
plot(t,wref);
plot(t, w);
plot(t_sim_res, w_sim_res)
hold off
grid on;
xlabel('time in s');
ylabel('rotational speed in s^{-1}');
legend(["reference", "measured", "simulated"]);
xlim([0.4 stop_time]);


wfilt_sim_res = w_filtered_sim.Data(ia_sim.time > time_shift);
twf_sim_res = w_filtered_sim.time(w_filtered_sim.time > time_shift)- time_shift;

fn=fn+1;
figure(fn);clf;
hold on
plot(t,wref);
plot(t, wfilt);
plot(twf_sim_res, wfilt_sim_res)
hold off
grid on;
xlabel('time in s');
ylabel('filtered rotational speed in s^{-1}');
legend(["reference", "measured", "simulated"]);
xlim([0.4 stop_time]);