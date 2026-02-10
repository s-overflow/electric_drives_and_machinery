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
    mv=getfield(mv,aux{1});
    
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


    
    % idx = find(diff(sign(iaref)) > 1, 1, 'first');


    inLinSim = sim("sim/IM_Control_Sim_Current_Flux.slx", ReturnWorkspaceOutputs="on");
    

    figure(i);
    hold on;

    % plot(t_data,ia, 'DisplayName', compose("ia_%d", selection_current(i)));
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
    xlim([0.48 0.56]);
    % ylim([-0.2 1.2]);

    % title("current controller step response")

    hold off;
end