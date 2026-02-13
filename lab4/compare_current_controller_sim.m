%% Compare measurement vs simulation for IM current controller (experiments 1,2,3,5)
close all
clc

fnames = { ...
    'exp001'
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
    'exp013' ...
    };

% Simulate experiments: 1, 2, 3, 5
selection = [1 2 3 5];

selection = [2];

modelNames = ["sim/IM_Control_Sim_Current.slx", "sim/IM_Control_Sim_Flux.slx"];

for i = 1:numel(selection)
    sel = selection(i);

    %% Load measurement
    fname = "measurements/" + fnames{sel};
    disp("Loading: " + fname);

    if sel == 1 
        modelName = modelNames(1);
    else
        modelName = modelNames(2);
    end

    t_start = (0:Ts:0)';

    mv = load(fname);
    aux = fieldnames(mv);
    mv  = mv.(aux{1});

    % Time
    t_data = t_start(end) + mv.X.Data(:);                 % s

    % Currents (measurement)
    isd      = mv.Y(11).Data(:);           % A, d-current actual
    isq      = mv.Y(12).Data(:);           % A, q-current actual
    isd_ref  = mv.Y(14).Data(:);           % A, d-current reference
    isq_ref  = mv.Y(15).Data(:);           % A, q-current reference

    % Angle / speed (measurement)
    phi_el   = mv.Y(18).Data(:);           % rad, electrical position
    wfilt    = mv.Y(22).Data(:);           % rad/s, filtered speed

    % Voltages (measurement)
    v_sd_ref = mv.Y(4).Data(:);            % V, d-voltage controller output (ref)
    v_sq_ref = mv.Y(5).Data(:);            % V, q-voltage controller output (ref)

    v_sd_sat = mv.Y(6).Data(:);            % V, d-voltage limited/saturated (sum)
    v_sq_sat = mv.Y(7).Data(:);            % V, q-voltage limited/saturated (sum)

    % Compensation voltages might or might not be present in measurement data.
    % If present, adapt indices here (UNKNOWN from your snippet).
    v_sd_comp_meas = [];
    v_sq_comp_meas = [];
    % Example if you later find correct indices:
    % v_sd_comp_meas = mv.Y(XX).Data(:);
    % v_sq_comp_meas = mv.Y(YY).Data(:);

    % Flux reference (measurement)
    lambda_ref = mv.Y(16).Data(:);

    %% Build external inputs as Dataset (root inports by port order)
    % Port 1: lambda_ref
    % Port 2: isq_ref
    % Port 3: omega_mech
    % Port 4: phi_el

 
    t_input = [t_start; t_data];

    isd_ref = [isd_ref(1) * ones(numel(t_start), 1); isd_ref];
    ts_isdref = timeseries(isd_ref, t_input); ts_isdref.Name = "isd_ref";
    
    lambda_ref = [lambda_ref(1) * ones(numel(t_start), 1); lambda_ref];
    ts_lambda = timeseries(lambda_ref, t_input); ts_lambda.Name = "lambda_ref";
    
    isq_ref = [isq_ref(1) * ones(numel(t_start), 1); isq_ref];
    ts_isqref = timeseries(isq_ref,    t_input); ts_isqref.Name = "isq_ref";
    
    wfilt = [wfilt(1) * ones(numel(t_start), 1); wfilt];
    ts_omega  = timeseries(wfilt,      t_input); ts_omega.Name  = "omega_mech";
    
    phi_el = [phi_el(1) * ones(numel(t_start), 1); phi_el];
    ts_phi    = timeseries(phi_el,     t_input); ts_phi.Name    = "phi_el";

    ds = Simulink.SimulationData.Dataset;
    if sel == 1 
        ds = ds.addElement(ts_isdref);
    else
        ds = ds.addElement(ts_lambda);
    end
    
    ds = ds.addElement(ts_isqref);
    ds = ds.addElement(ts_omega);
    ds = ds.addElement(ts_phi);

    %% Run simulation with ExternalInput
    in = Simulink.SimulationInput(modelName);

    

    in = in.setModelParameter( ...
        'SolverType', 'Fixed-step', ...
        'FixedStep',  num2str(Ts), ...
        'StopTime',   num2str(t_input(end)), ...
        'LoadExternalInput', 'on', ...
        'ExternalInput', 'ds');

    % Put dataset into base workspace for the model to read
    in = in.setVariable('ds', ds);

    out = sim(in);

    %% Extract simulation outputs (as in your original indexing)
    % NOTE: This assumes yout{1..8} order is stable in the model.
    isd_ref_sim     = out.yout{1}.Values.Data;   % d-current ref (sim)
    is_sat_sim      = out.yout{2}.Values.Data;   % currents desired [isd;isq]
    vd_ref_sim      = out.yout{3}.Values.Data;   % d-voltage controller output
    vq_ref_sim      = out.yout{4}.Values.Data;   % q-voltage controller output
    vd_sat_sim      = out.yout{5}.Values.Data;   % d-voltage limited/sum
    vq_sat_sim      = out.yout{6}.Values.Data;   % q-voltage limited/sum
    v_sd_comp_sim   = out.yout{7}.Values.Data;   % d-compensation voltage
    v_sq_comp_sim   = out.yout{8}.Values.Data;   % q-compensation voltage
    is_sim          = out.yout{9}.Values.Data;   % currents actual [isd;isq]
     
    isd_sim = is_sim(:, 1);
    isq_sim = is_sim(:, 2);

    time = out.tout;


    
    figure(3*i);

    hold on; grid on;

    plot(t_input, isd_ref, 'DisplayName','i_{sd,ref} meas');
    plot(t_data, isd,     'DisplayName','i_{sd} meas');

    plot(time, isd_ref_sim, 'DisplayName','i_{sd, ref} sim');
    plot(time, isd_sim,     'DisplayName','i_{sd} sim');



    legend('Location','best');
    xlim([t_start(end), t_data(end)]);

    % 
    % %% ========== FIGURE 1: Currents (d and q) ==========
    % figure('Name', sprintf('%s - Currents', fnames{sel}), 'NumberTitle','off');
    % tiledlayout(2,1, 'Padding','compact', 'TileSpacing','compact');
    % 
    % % d-current
    % nexttile; hold on; grid on;
    % plot(t_data, isd_ref, 'DisplayName','i_{sd,ref} meas');
    % plot(t_data, isd,     'DisplayName','i_{sd} meas');
    % plot(getT(isd_ref_sim), getD(isd_ref_sim), 'DisplayName','i_{sd,ref} sim');
    % if ~isempty(isd_sim)
    %     plot(is_sim_time, isd_sim, 'DisplayName','i_{sd} sim');
    % end
    % xlabel('time (s)'); ylabel('current (A)');
    % title(sprintf('%s: d-current', fnames{sel}));
    % legend('Location','best');
    % 
    % % q-current
    % nexttile; hold on; grid on;
    % plot(t_input, isq_ref, 'DisplayName','i_{sq,ref} meas');
    % plot(t_data, isq,     'DisplayName','i_{sq} meas');
    % % if you also have a q-ref sim signal separately, add it here
    % if ~isempty(isq_sim)
    %     plot(is_sim_time, isq_sim, 'DisplayName','i_{sq} sim');
    % end
    % xlabel('time (s)'); ylabel('current (A)');
    % title(sprintf('%s: q-current', fnames{sel}));
    % legend('Location','best');
    % xlim([t_start(end), t_data(end)])
    % 
    % %% ========== FIGURE 2: d-Voltage components ==========
    % figure('Name', sprintf('%s - d-Voltages', fnames{sel}), 'NumberTitle','off');
    % hold on; grid on;
    % 
    % % Controller output (ref)
    % plot(t_data, v_sd_ref, 'DisplayName','v_{sd,ctrl} meas');
    % plot(getT(vd_ref_sim), getD(vd_ref_sim), 'DisplayName','v_{sd,ctrl} sim');
    % 
    % % Compensation
    % if ~isempty(v_sd_comp_meas)
    %     plot(t_data, v_sd_comp_meas, 'DisplayName','v_{sd,comp} meas');
    % end
    % plot(getT(v_sd_comp_sim), getD(v_sd_comp_sim), 'DisplayName','v_{sd,comp} sim');
    % 
    % % Limited/saturated sum
    % plot(t_data, v_sd_sat, 'DisplayName','v_{sd,sat} meas');
    % plot(getT(vd_sat_sim), getD(vd_sat_sim), 'DisplayName','v_{sd,sat} sim');
    % 
    % xlabel('time (s)'); ylabel('voltage (V)');
    % title(sprintf('%s: d-voltage components', fnames{sel}));
    % legend('Location','best');
    % xlim([t_start(end), t_data(end)])
    % 
    % %% ========== FIGURE 3: q-Voltage components ==========
    % figure('Name', sprintf('%s - q-Voltages', fnames{sel}), 'NumberTitle','off');
    % hold on; grid on;
    % 
    % % Controller output (ref)
    % plot(t_data, v_sq_ref, 'DisplayName','v_{sq,ctrl} meas');
    % plot(getT(vq_ref_sim), getD(vq_ref_sim), 'DisplayName','v_{sq,ctrl} sim');
    % 
    % % Compensation
    % if ~isempty(v_sq_comp_meas)
    %     plot(t_data, v_sq_comp_meas, 'DisplayName','v_{sq,comp} meas');
    % end
    % plot(getT(v_sq_comp_sim), getD(v_sq_comp_sim), 'DisplayName','v_{sq,comp} sim');
    % 
    % % Limited/saturated sum
    % plot(t_data, v_sq_sat, 'DisplayName','v_{sq,sat} meas');
    % plot(getT(vq_sat_sim), getD(vq_sat_sim), 'DisplayName','v_{sq,sat} sim');
    % 
    % xlabel('time (s)'); ylabel('voltage (V)');
    % title(sprintf('%s: q-voltage components', fnames{sel}));
    % legend('Location','best');
    % xlim([t_start(end), t_data(end)])

end
