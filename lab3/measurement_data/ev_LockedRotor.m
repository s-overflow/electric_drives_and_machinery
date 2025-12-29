% 9.12.2025 R. Seebacher
%


fname={'lr_30Hz.txt', ...
        'lr_40Hz.txt', ...
        'lr_50Hz.txt'};

wahl = 1;

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

%%
figure(302);clf;
%plot(res.avg(:,2),res.avg(:,1),'-bo');
plot(Ism,Rkm,'o');
grid on; zoom on;
xlabel('Strom, Grundschwingungseffektivwert in A');
ylabel('Rk in Ohm');



figure(303);clf;
%plot(res.avg(:,2),res.avg(:,1),'-bo');
plot(Ism,Lkm,'o');
grid on; zoom on;
xlabel('Strom, Grundschwingungseffektivwert in A');
ylabel('Lk in H');


close all
%% grouped plots
clc

res_files = ["lr_30Hz_LR.mat"; "lr_40Hz_LR.mat"; "lr_50Hz_LR.mat"];
colors = ["r", "g", "b"];

% Rk
figure(400), clf;
hold on
for i = 1:3
    clear("Ism", "Rkm", "Lkm")

    load(res_files(i))

    plot(Ism,Rkm,"o", 'Color',colors(i)) 
    Rkm_avgs(i) = mean(rmmissing(Rkm));
    yline(Rkm_avgs(i),"--", 'Color',colors(i))
end
hold off
grid on
xlabel('Current, RMS of fundamental wave in A');
ylabel('R_k in \Omega');
legend(["30 Hz", "30 Hz mean", "40 Hz", "40 Hz mean", "50 Hz", "50 Hz mean"])

disp("Rkm averages \\ avg of avgs")
disp(Rkm_avgs);
disp(mean(Rkm_avgs))

% Lk
figure(401), clf;
hold on
for i = 1:3
    clear("Ism", "Rkm", "Lkm")

    load(res_files(i))

    plot(Ism,Lkm,"o", 'Color',colors(i)) 
    Lkm_avgs(i) = mean(rmmissing(Lkm));
    yline(Lkm_avgs(i),"--", 'Color',colors(i))
end
hold off
grid on
xlabel('Current, RMS of fundamental wave in A');
ylabel('L_k in H');
legend(["30 Hz", "30 Hz mean", "40 Hz", "40 Hz mean", "50 Hz", "50 Hz mean"])

disp("Rkm averages \\ avg of avgs")
disp(Lkm_avgs);
disp(mean(Lkm_avgs))

f = [30, 40, 50];


%% extrapolate to 0

x_tl = -5:1:55;

% Rk
pR = polyfit(f, Rkm_avgs, 1);
Rk_tl = pR(1)*x_tl + pR(2);
Rk0 = Rk_tl(x_tl == 0)

figure(500),clf;
hold on
for i = 1:3
    plot(f(i),Rkm_avgs(i),"o", 'Color',colors(i)) 
end
plot(x_tl, Rk_tl, "--", 'Color', [0,0,0]);
plot(0, Rk0, "x", 'Color', [0,0,0]);
hold off
grid on
xlabel('Frequency in Hz');
ylabel('R_k in \Omega');
legend(["30 Hz", "40 Hz", "50 Hz", "trendline", "extrapolated 0 Hz"])

%  Lk
pL = polyfit(f, Lkm_avgs, 1);
Lk_tl = pL(1)*x_tl + pL(2);
Lk0 = Lk_tl(x_tl == 0)

figure(501),clf;
hold on
for i = 1:3
    plot(f(i),Lkm_avgs(i),"o", 'Color',colors(i)) 
end
plot(x_tl, Lk_tl, "--", 'Color', [0,0,0]);
plot(0, Lk0, "x", 'Color', [0,0,0]);
hold off
grid on
xlabel('Frequency in Hz');
ylabel('L_k in H');
legend(["30 Hz", "40 Hz", "50 Hz", "trendline", "extrapolated 0 Hz"])



T = table([f'; 0] , [Lkm_avgs'; Lk0], [Rkm_avgs'; Rk0])
table2latex(T)