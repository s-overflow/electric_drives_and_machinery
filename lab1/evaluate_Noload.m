% 23.10.2025
% CoEDaM
% DC-machine parametrisation
% Evaluation of mot. noload test 
% n const  (about 2000 rpm)
%
cla;
R_a=0.7103;  % Ohm, armature resistance (to be replaced by measured value of armature resistance)

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


% figure(100)
% plot(-I_e,'-*'); ylabel('I_e in A');
% figure(101)
% plot(I_a,'-*'); ylabel('I_a in A');
% figure(102)
% plot(V_a,'-*'); ylabel('V_a in A');
% figure(103)
% plot(t,n/1000,'-*',t,-I_e,'-bo');
% xlabel('time in s'); 
% ylabel('n in krpm, I_e in A');
% 
% figure(1);
% plot(I_e,V_a,'.-'); grid on; zoom on;
% xlabel('I_e in A'); 
% ylabel('V_a in V');
% 
% 
% figure(2);
% plot(I_e,n); grid on; zoom on;
% xlabel('I_e in A'); 
% ylabel('n in rpm');

% figure(3);

Nrep = 5;
Npts = 9;

kPhi = (V_a-R_a*I_a)./w;
I_e_fwd  = I_e(1 : Nrep*Npts);
Phi_fwd  = kPhi(1 : Nrep*Npts);

I_e_rev = I_e(end - Nrep*Npts + 1 : end);
Phi_rev = kPhi(end - Nrep*Npts + 1 : end);



% ----- Reshape to [Nrep x Npts] -----
I_e_fwd  = reshape(I_e_fwd,  Nrep, Npts);
Phi_fwd  = reshape(Phi_fwd,  Nrep, Npts);

I_e_rev  = reshape(I_e_rev,  Nrep, Npts);
Phi_rev  = reshape(Phi_rev,  Nrep, Npts);

% ----- Mean of repeated measurements -----
I_e_fwd_mean  = mean(I_e_fwd, 1);
Phi_fwd_mean  = mean(Phi_fwd, 1);

I_e_rev_mean  = mean(I_e_rev, 1);
Phi_rev_mean  = mean(Phi_rev, 1);

I_mean  = (I_e_fwd_mean + flip(I_e_rev_mean))/2;
Phi_mean = (Phi_fwd_mean + flip(Phi_rev_mean))/2;



figure(3);
plot(-I_mean, Phi_mean,'-*'); grid on; zoom on;
xlabel('I_e in A'); 
ylabel('k\Phi in Vs');


% 
% figure(4);
% plot(n,I_a,'-*'); grid on; zoom on;
% xlabel('n in rpm'); 
% ylabel('I_a in A');
% 
% 
% figure(5);
% plot(n,abs(I_a),'-*'); grid on; zoom on;
% xlabel('n in rpm'); 
% ylabel('|I_a| in A');

% T_frict = I_a.*(V_a-R_a*I_a)./w;
% 
% mean(T_frict, 1)
% 
% figure(6);
% plot(-I_e,T_frict,'-*'); grid on; zoom on;
% xlabel('I_e in A'); 
% ylabel('T_{frict} in Nm');



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






