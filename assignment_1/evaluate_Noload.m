% 23.10.2025
% CoEDaM
% DC-machine parametrisation
% Evaluation of mot. noload test 
% n const  (about 2000 rpm)
%
R_a=0.8;  % Ohm, armature resistance (to be replaced by measured value of armature resistance)

fnames={'noload_test_2000rpm.txt'   % 1, noload test varying excitation current
        'noload_test_if06amp.txt'  % 2, noload test varying speed with ie=0.6 A const.
        };

fnum = 1;

mw=load(fnames{fnum});
% config_noload_mean_f_u3_100V_ws2425.txt
%                  FUNC "VOLT3:MEAN","CURR3:MEAN","CURR6:MEAN","FREQ","VOLT1:MEAN"
% Messgrößen: hh mm ss    v_a          i_a           i_e         f      v_dc  
% Nr.:         1  2  3     4            5             6          7       8
% averaging interval about 1 s (averaging interval is synchronised to period of signal f)
V_dc=mw(:,8);       % V, DC-link voltage, mean value 
V_a=mw(:,4);        % V, armature voltage, mean value
I_a=mw(:,5);        % A, armature current, mean value
I_e=mw(:,6);        % A, excitation current, mean value
f=mw(:,7)/2;        % 1/s, mechanical rotor speed, 1/2 because of number of pole pairs, mean value
w=2*pi*f.*sign(I_a);% rad/s, angular mechanical rotor speed, mean value
n=f*60.*sign(I_a);  % rpm, mechanical rotor speed, mean value
t=mw(:,1)*3600+mw(:,2)*60+mw(:,3);  % s, time
t=t-t(1);       


figure(100)
plot(I_e,'-*'); ylabel('I_e in A');
figure(101)
plot(I_a,'-*'); ylabel('I_a in A');
figure(102)
plot(V_a,'-*'); ylabel('V_a in A');
figure(103)
plot(t,n/1000,'-*',t,I_e,'-bo');
xlabel('time in s'); 
ylabel('n in krpm, I_e in A');

figure(1);
plot(I_e,V_a,'.-'); grid on; zoom on;
xlabel('I_e in A'); 
ylabel('V_a in V');


figure(2);
plot(I_e,n); grid on; zoom on;
xlabel('I_e in A'); 
ylabel('n in rpm');

figure(3);
plot(I_e,(V_a-R_a*I_a)./w,'-*'); grid on; zoom on;
xlabel('I_e in A'); 
ylabel('k\Phi in Vs');

figure(4);
plot(n,I_a,'-*'); grid on; zoom on;
xlabel('n in rpm'); 
ylabel('I_a in A');


figure(5);
plot(n,abs(I_a),'-*'); grid on; zoom on;
xlabel('n in rpm'); 
ylabel('|I_a| in A');



%% Averaging for the individual operating points

% Vam=mean(reshape(Va,N,length(Va)/N))';
% Iam=mean(reshape(Ia,N,length(Ia)/N))';
% Iem=mean(reshape(Ie,N,length(Ie)/N))';
% nm=mean(reshape(n,N,length(n)/N))';
% 
% 
% 
% figure(200);
% plot(Iem,(Vam-Ra*Iam)./(nm*pi/30),'-bo'); grid on; zoom on;
% title('averaged results');
% xlabel('I_e in A'); ylabel('\Psi in Vs');
% 
% figure(201);
% plot(nm,Iam,'-*'); grid on; zoom on;
% title('averaged results');
% xlabel('n in rpm'); ylabel('Ia in A');






