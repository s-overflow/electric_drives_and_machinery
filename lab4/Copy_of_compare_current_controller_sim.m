close all
clc

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


%% inner loop - current controller

selection = [1 2 3 5];



for i = 1:numel(selection)
    sel = selection(i);

    fname="measurements/" + fnames{sel}
    mv=load(fname);
    aux=fieldnames(mv);
    mv = mv.(aux{1});
    
    t_data=mv.X.Data';              % s, time

    isd=mv.Y(11).Data';         % A, flux building current component of IM
    isq=mv.Y(12).Data';         % A, torque building current component of IM

    isd_ref=mv.Y(14).Data';     % A, flux building current component of IM
    isq_ref=mv.Y(15).Data';     % A, torque building current component of IM

    phi_el=mv.Y(18).Data';      % rad, electrical rotor position (= mech. Rotorlage*2)
    wfilt=mv.Y(22).Data';       % rad/s, speed filtered

    v_sd_ref=mv.Y(4).Data';         % V, flux 
    v_sq_ref=mv.Y(5).Data';         % V, torque 

    v_sd_sat=mv.Y(6).Data';         % V, flux 
    v_sq_sat=mv.Y(7).Data';         % V, torque 

    % v_sd_comp=mv.Y(11).Data';         % V, flux 
    % v_sq_comp=mv.Y(12).Data';         % V, torque  


    lambda_ref=mv.Y(16).Data';

    
    % idx = find(diff(sign(iaref)) > 1, 1, 'first');

    in = Simulink.SimulationInput("sim/IM_Control_Sim_Current_Flux.slx");
    
    in = in.setModelParameter( ...
        'SolverType', 'Fixed-step', ...
        'FixedStep', num2str(Ts), ...
        'StopTime',  num2str(t_data(end)));


    in = in.setVariable("lambda_ref", lambda_ref);
    in = in.setVariable("isq_ref", isq_ref);

    in = in.setVariable("omega_mech", wfilt);
    in = in.setVariable("phi_el", phi_el);
    
    out = sim(in);

    t = out.tout;

    isd_ref_sim = out.yout{1};
    is_sat_sim = out.yout{2};
    vd_ref_sim = out.yout{3};
    vq_ref_sim = out.yout{4};
    vd_sat_sim = out.yout{5};
    vq_sat_sim = out.yout{6};
    v_sd_comp_sim = out.yout{7};
    v_sq_comp_sim = out.yout{8};

    figure(i);
    hold on;

    plot(t, isd_ref_sim.Values.Data);
    plot(t_data, isd_ref);

    % plot(t_data,iaref, 'DisplayName', 'ia_{ref}');
    % 
    % 
    % 
    % plot(t_sim, inLinSim.ia.Data, 'DisplayName', compose("ia_{%d, sim}", selection_current(i)))
    % 
    % grid on;
    % xlabel('time in s');
    % ylabel('armatur current in A');
    % legend('Location','SouthEast');
    % xlim([0.9 1.1]);
    % ylim([-0.2 1.2]);

    % title("current controller step response")

    hold off;
end