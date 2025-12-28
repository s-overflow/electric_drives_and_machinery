%14.12.2023 Gr. 14h
%

fname='statorR.txt';


mw=load(fname);

% config: config_IM_lockedrotor_235_211210.txt
%     FUNC "VOLT2:MEAN","VOLT3:MEAN","VOLT6:MEAN","CURR2:MEAN","CURR3:MEAN","CURR6:MEAN"
% hh mm ss    Ua         Ub            Uc
%  1  2  3    4           5            6           7           8           9 

U123=mw(:,[4 5 6]);
I123=mw(:,[7 8 9]);



res=fun_grouping(U123(:,1),1,0.03,3,0,99);


U123_ = U123(res.ids, :);
I123_ = I123(res.ids, :);
indsNaN=find(abs(I123_)<1);
R123=U123_./I123_;
R123(indsNaN)=NaN;
close all;

styles = ["r", "b", "g"];

fig = figure(101);
fig.Position = [100 100 800 600]; 
hold on;
for i = 1:3
    plot(U123(:,i),  styles(i),  'DisplayName', compose("u_%i", i));
    plot(res.ids, U123(res.ids,i), compose("%so", styles(i)), 'DisplayName', compose("u_{%i, filtered}", i))
end

xlabel("index")
ylabel("phase voltages (V)")

hold off;
legend();
exportgraphics(fig, 'figures/Rs_voltage.png', 'Resolution', 300);


fig = figure(102);
fig.Position = [100 100 800 600]; 
hold on;
for i = 1:3
    plot(I123(:,i),  styles(i),  'DisplayName', compose("i_%i", i));
    plot(res.ids, I123(res.ids,i), compose("%so", styles(i)), 'DisplayName', compose("i_{%i, filtered}", i))
end

xlabel("index")
ylabel("phase currents (A)")

hold off;
legend();
exportgraphics(fig, 'figures/Rs_current.png', 'Resolution', 300);


Rphase = zeros(1, 3);

fig = figure(103);
fig.Position = [100 100 800 600]; 
hold on;
for i = 1:3
    R123_=R123(:, i);

    plot(R123_, compose("%so", styles(i)),  'DisplayName', compose("R_%i", i));

 	R123_ = R123_(~isnan(R123_));
    Rphase(i) = mean(R123_);

    plot(Rphase(i)*ones(1, numel(R123(:, i))), styles(i), 'DisplayName', compose("R_{%i, mean}", i));
end

Rphase
mean(Rphase)

plot(mean(Rphase)*ones(1, numel(R123(:, i))), "c", 'DisplayName', "R_{mean}");

xlabel("index")
ylabel("phase resistance (Ohm)")

hold off;
legend();


exportgraphics(fig, 'figures/Rs_resistance.png', 'Resolution', 300);




