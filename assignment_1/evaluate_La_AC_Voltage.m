% 23.10.2025
% CoEDaM
% DC-machine parametrisation
% Evaluation of AC - test 
% sinusoidal armature voltage
% v_aref=Va*cos(2*pi*f*t)
%
% Measurement device: 
%       Fluke NORMA 5000 power analyser (abbrev. N5000)
%


%  To allow for simple identification of reference frequency 
%  the reference frequency has to be included in the filename enclosed in "_" and "Hz"
%  e.g.  n0_ie02A_13V_200Hz 
%
fnames={'La_200Hz'				% 1, 820=0 rpm, Ie=0.6 A, Va=10 V, f=80 Hz, Vdc=22.75, rotor is not locked
        'La_AC_Ie02'			% 2, 820=0 rpm, Ie=0.2 A, Va=10 V, f=80 Hz, Vdc=12.75, rotor is not locked
};

wahl=1;

fname=fnames{wahl};

mw=mwgeigl(pwd,fname);

% N5000 configuration file: config_La_alternating_ws2526.txt
% recording of sampled values
%        SWE1:FUNC "VOLT3","CURR3","CURR6","VOLT2"
% Messgrößen: t      v_a     i_a    i_e    phi_el
%             s       V       A     A        V
% Nr.:        1      2        3      4       5     

t=mw(:,1);              % s, time
v_a=mw(:,2);            % V, armature voltage
i_a=mw(:,3);            % A, armature current
i_e=mw(:,4);            % A, excitation current
phi_el=mw(:,5)*pi/10;   % rad, electrical rotor position (VOLT2 is output voltage of DAC with 10V...pi rad  

figure(3); 
plot(t,v_a,t,i_a); 
grid on; zoom on
 
plot(t,i_e); 
grid on; zoom on


Tsw=200e-6;         % s, switching period of converter
Ts=mean(diff(t));   % s, sampling period

% filter coefficients for moving average 
nn=round(Tsw/Ts);  % width of window for moving average
b=ones(nn,1);      % filter coefficients: numerator
a=zeros(nn,1);
a(1)=nn;           % filter coefficients: denominator

i_af=filtfilt(b,a,i_a); % acausal filtering (also called zero phase filter) of armature current
v_af=filtfilt(b,a,v_a); % acausal filtering (also called zero phase filter) of armature voltage

figure(10);
plot(t,v_af,t,i_af);
grid on;
xlabel('time in s');
legend('filtered voltage','filtered current','Location','best');

%% evaluation interval

% pick out reference frequency from filename
aux=findstr(fname,'Hz');
index=findstr(fname(1:aux),'_');
f1=str2num(fname(index(end)+1:aux-1));




T1=1/f1;  % s, known period of filename
% assume steady state operation over the full recording interval
start_index=1;
nop=floor((t(end)-t(start_index))/T1);  % number of periods

delta_t=nop*T1; % it should be an integer multiple of the AC-period

[aux end_index]=min(abs(t-(t(start_index)+nop*T1-Ts)));
tt=t(start_index:end_index)-t(start_index);
vva=v_a(start_index:end_index);
iia=i_a(start_index:end_index);

% matlab fft algorithm does not apply the amplitude correction  
% (division by the number of sampling points and for the AC components multiplication by 2)
v_a_dft=fft(vva);
i_a_dft=fft(iia);



Z=v_a_dft(nop+1)/(i_a_dft(nop+1));  % Ohm, impedance at fundamental frequency
f1=1/T1;
L=imag(Z)/(2*pi*f1);
I_em=mean(i_e(start_index:end_index));
disp(['Experiment: ' fname]);
disp(['La = ' num2str(L) ' H at Ie = ' num2str(I_em) ' A']);

% matlab fft algorithm does not apply the amplitude correction  
% (division by the number of sampling points and
% for the AC components multiplication by 2)
% Since Z is the result of a division, the amplitude correction is not
% mandatory
% However, here it is
v_a_dft=v_a_dft*2/length(vva);
v_a_dft(1)=v_a_dft(1)/2;

i_a_dft=i_a_dft*2/length(iia);
i_a_dft(1)=i_a_dft(1)/2;

disp(['Frequency: f_1=' num2str(f1) ' Hz']);
disp(['Amplitudes: ia_1 = ' num2str(abs(i_a_dft(nop+1))) ' A, va_1 = ' num2str(abs(v_a_dft(nop+1))) ' V']);
disp([' ']);



figure(11);
plot(t,i_a,tt+t(start_index),iia);
grid on;
xlabel('time in s');
ylabel('armature current in A');
legend({'recorded','selected'},'Location','best');

% reconstruction
i_a_re=real(i_a_dft(1)+i_a_dft(nop+1)*exp(j*2*pi/(T1)*tt)); % DC and fundamental
v_a_re=real(v_a_dft(1)+v_a_dft(nop+1)*exp(j*2*pi/(T1)*tt)); % DC and fundamental


figure(12);
plot(tt+t(start_index),iia,tt+t(start_index),i_a_re);
grid on;
xlabel('time in s');
ylabel('armature current in A');
legend({'selected','reconstructed'},'Location','best');


figure(13);
plot(tt+t(start_index),v_a_re-real(v_a_dft(1)),tt+t(start_index),i_a_re-real(i_a_dft(1)));
grid on;
xlabel('time in s');
legend('reconstructed voltage fundamental','reconstructed current fundamental','Location','best');


































