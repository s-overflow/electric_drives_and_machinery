close all
clc

G_iT_s = kPhi /(I*La*s^2 + Ra*I*s + (kPhi)^2);


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



%% inner loop - current controller

selection_current = [1 2 4];



for i = 1:numel(selection_current)
    selection = selection_current(i);

    fname=fnames{selection};
    mv=load(fname);
    aux=fieldnames(mv);
    mv=getfield(mv,aux{1});
    
    t_data=mv.X.Data';              % s, time
    
    varef=mv.Y(1).Data';       % V, armature reference voltage
    ia=mv.Y(7).Data';          % A, armature current
    iaref=mv.Y(3).Data';       % A, armature reference current
    ie=mv.Y(8).Data';          % A, field current    
    isd=mv.Y(4).Data';         % A, flux building current component of IM
    isq=mv.Y(5).Data';         % A, torque building current component of IM
    phiel=mv.Y(6).Data';       % rad, electrical rotor position (= mech. Rotorlage*2)
    torq=mv.Y(9).Data';        % Nm, shaft torque
    vdc=mv.Y(10).Data';         % V, filtered DC-link voltage
    w=mv.Y(12).Data';          % rad/s, speed unfiltered
    wfilt=mv.Y(11).Data';      % rad/s, speed filtered
    wref=mv.Y(13).Data';       % rad/s, reference speed


    Tload = 0;
    i_start = iaref(1);
    i_stop = iaref(end);
    
    idx = find(diff(sign(iaref)) > 1, 1, 'first');

    bypass_inverter = 1;
    
    t = t_data(1) : Ts : t_data(end);

    

    t_step = 0.5;
    t_stop = t_data(end);

    t_sim = t_step - 0.05 : Ts : t_step + 0.05;

    [yTi, tTi] = step(Ti_z, t);
    inLinSim = sim("sim/Inner_Loop_Linear_DCM.slx", ReturnWorkspaceOutputs="on");
    % inLinArmCircSim = sim("sim/Inner_Loop_Linear_ArmatureCircuit.slx", ReturnWorkspaceOutputs="on");
    % inNonlinSim = sim("sim/Inner_Loop_NonLinear_DCM_PWM.slx", ReturnWorkspaceOutputs="on");
    

    figure(i);
    hold on;

    plot(t_data,ia, 'DisplayName', compose("ia_%d", selection_current(i)));
    plot(t_data,iaref, 'DisplayName', 'ia_{ref}');
    


    plot(t_sim, inLinSim.ia.Data, 'DisplayName', compose("ia_{%d, sim}", selection_current(i)))
    % plot(t_sim, inLinArmCircSim.ia.Data,'-.', 'DisplayName', "RL circuit slx out")
    % plot(t_sim, inNonlinSim.ia.Data, 'DisplayName', "nonlinear slx out")

    grid on;
    xlabel('time in s');
    ylabel('armatur current in A');
    legend('Location','SouthEast');
    xlim([0.48 0.56]);
    % ylim([-0.2 1.2]);

    % title("current controller step response")

    hold off;
end



%% outer loop - speed controller

selection_speed = [6 7 11];

stop_times = [0.5 0.5 2];

for i = 1:numel(selection_speed)
    selection = selection_speed(i);

    fname=fnames{selection};
    mv=load(fname);
    aux=fieldnames(mv);
    mv=getfield(mv,aux{1});
    
    t_data=mv.X.Data';              % s, time
    
    varef=mv.Y(1).Data';       % V, armature reference voltage
    ia=mv.Y(7).Data';          % A, armature current
    iaref=mv.Y(3).Data';       % A, armature reference current
    ie=mv.Y(8).Data';          % A, field current    
    isd=mv.Y(4).Data';         % A, flux building current component of IM
    isq=mv.Y(5).Data';         % A, torque building current component of IM
    phiel=mv.Y(6).Data';       % rad, electrical rotor position (= mech. Rotorlage*2)
    torq=mv.Y(9).Data';        % Nm, shaft torque
    vdc=mv.Y(10).Data';         % V, filtered DC-link voltage
    w=mv.Y(12).Data';          % rad/s, speed unfiltered
    wfilt=mv.Y(11).Data';      % rad/s, speed filtered
    wref=mv.Y(13).Data';       % rad/s, reference speed


    Tload = 0;
    w_start = wref(1);
    w_stop = wref(end);

    stop_time = stop_times(i);
    
    idx = find(diff(sign(iaref)) > 1, 1, 'first');

    bypass_inverter = 1;
    bypass_wFilter = 0;
    
    t = t_data(1) : Ts : t_data(end);
    
    % G_wv_s = setx0(G_wv_s, [w_start; 0]);

    t_step = 0.1;
    t_stop = t_data(end);

    t_sim = t_step + 0.3 : Ts : t_step + stop_time + 0.3;

    % [yTw, tTw] = step(Tw_z, t);
    outLinSim = sim("sim/Outer_Loop_Linear_DCM.slx", ReturnWorkspaceOutputs="on");
    % outLinArmCircSim = sim("sim/Outer_Loop_Linear_ArmatureCircuit.slx", ReturnWorkspaceOutputs="on");
    % outNonlinSim = sim("sim/Outer_Loop_NonLinear_DCM_PWM.slx", ReturnWorkspaceOutputs="on");
    

    figure(numel(selection_current)+i);
    hold on;

    plot(t_data,wfilt*30/pi, 'DisplayName', compose("w_{%d}", selection_speed(i)));
    plot(t_data,wref*30/pi, 'DisplayName', 'w_{ref}');
    
    if (i < 3)
        xlim([0.4 0.9]);
    else
        xlim([0.2 2.4]);
    end

    plot(t_sim, outLinSim.omega_m.Data*30/pi, 'DisplayName', compose("w_{%d, sim}", selection_speed(i)))
    % plot(t_sim, outLinArmCircSim.ia.Data, '-.', 'DisplayName', "RL circuit slx out")
    % plot(t_sim, outNonlinSim.omega_m.Data, 'DisplayName', "nonlinear slx out")


    grid on;
    xlabel('time in s');
    ylabel('rotational speed in rpm');
    legend('Location','SouthEast');

    
    ylim([w_start-0.1*max(wfilt) 1.1*max(wfilt)]*30/pi);

    % title("current controller step response")

    hold off;
end




% figure(2)
% plot(yTi-ia.Data)

% w_ref_step = 1;


% figure(4)
% plot(yTw-omega_m.Data)
