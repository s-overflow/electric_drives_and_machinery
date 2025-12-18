% 9.12.2025 R. Seebacher
%


fname={'lr_30Hz.txt', ...
        'lr_40Hz.txt', ...
        'lr_50Hz.txt'};

wahl = 3;

mw=load(fname{wahl});

% config: config_IM_lockedrotor_235_211210.txt
%     FUNC "VOLT2:HAR","VOLT3:HAR","VOLT6:HAR","CURR2:HAR","CURR3:HAR","CURR6:HAR","POW2:HAR","POW3:HAR","POW6:HAR","FREQ"
% hh mm ss    Ua         Ub            Uc
%  1  2  3    4           5            6           7           8           9            10        11         12       13  %

Us=mean(mw(:,[4 5 6]),2);
Is=mean(mw(:,[7 8 9]),2);

Ps=sum(mw(:,[10 11 12]),2);

fs=mw(:,13);

cphi=Ps./(3*Us.*Is);
Zs=Us./Is.*exp(1j*acos(cphi));

Lk=imag(Zs)./(2*pi*fs);
Rk=real(Zs);

Lkm=mean(Lk);
Rkm=mean(Rk);

%plots fig 300
result=fun_grouping([Us Is Ps Lk Rk fs],1,0.01,5,1,300)

%result=fun_grouping([Us Is Ps],1,0.01,5,1,300)
% 
% asdf

Usm=result.avg(:,1);
Ism=result.avg(:,2);
Psm=result.avg(:,3);
Lkm=result.avg(:,4);
Rkm=result.avg(:,5);
fsm=result.avg(:,6);


Lkm_average = mean(Lkm(2:end))
Rkm_average = mean(Rkm(2:end))

tau = Lkm_average/Rkm_average

figure(200);
%plot(res.avg(:,2),res.avg(:,1),'-bo');
plot(Is,Us,'o');
grid on; zoom on;
xlabel('Strom, Grundschwingungseffektivwert in A');
ylabel('Spannung, Grundschwingungseffektivwert in V');


figure(201);
%plot(res.avg(:,2),res.avg(:,1),'-bo');
plot(Is,Rk,'o');
grid on; zoom on;
xlabel('Strom, Grundschwingungseffektivwert in A');
ylabel('Rk in Ohm');

figure(202);
plot(Is,Lk,'o');
grid on;
xlabel('Strom, Grundschwingungseffektivwert in A');
ylabel('Lk in H');

figure(203);
plot(Us, "o")
grid on;
xlabel("sample nr")
ylabel("Us in V")

%% averaged
figure(301);
%plot(res.avg(:,2),res.avg(:,1),'-bo');
plot(Ism,Usm,'o');
grid on; zoom on;
xlabel('Strom, Grundschwingungseffektivwert in A');
ylabel('Spannung, Grundschwingungseffektivwert in V');


figure(302);
%plot(res.avg(:,2),res.avg(:,1),'-bo');
plot(Ism,Rkm,'o');
grid on; zoom on;
xlabel('Strom, Grundschwingungseffektivwert in A');
ylabel('Rk in Ohm');



figure(303);
%plot(res.avg(:,2),res.avg(:,1),'-bo');
plot(Ism,Lkm,'o');
grid on; zoom on;
xlabel('Strom, Grundschwingungseffektivwert in A');
ylabel('Lk in H');


%% grouped plots
