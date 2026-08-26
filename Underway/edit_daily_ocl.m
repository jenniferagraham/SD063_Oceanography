function edit_daily_ocl(daynumber, yy)
% EDIT_DAILY_OCL(daynumber, yy)
%
% clean through the oceanographic data removing low flow rate values and
% any weird values
%
% mmm, CD160, August 2004
% mmm, jr139, December 2005
% script passed on to Kat Turner from Hugh Venables, and was edited for the
% SD046 cruise in February 2025 to work with scripts provided by Povl
% Abrahamsen
%
% SD046, March 2025, Kat Turner

    close all
    
    % check for a date and if not prompt user for day and assume year to
    % be the current year

    if nargin < 2
        dt_now = datetime('now'); 
        yy = year(dt_now);
        jday_now = day(dt_now, 'dayofyear');

        if nargin < 1
            fprintf('Today''s jday number is %d.\n', jday_now);
            daynumber = input('Input jday number = ');
        end
    end

    % load up parameter names 
    set_underway_params;

    % Load OCL data
    load(fullfile('..', ['rtables_', cruisename, '.mat']));
    ocl_data = load_ocl_data(ocl_tables, yy, daynumber);
    if isempty(ocl_data), return; end

    % Extract key variables
    flow = extract_variable(ocl_data, ocl_sensors.ocl_flow{1});

    % plot up the flow rate to get initial guage on data quality
    figure;
    plot(datetime(flow.time, "ConvertFrom", "datenum"), flow.flowrate,'k.')
    title("Flow Rate (L/min)")

    disp('Hit any key')
    pause

    % read in the data
    thermosal = extract_variable(ocl_data, ocl_sensors.ocl_water_cond{1}); % thermosalinograph
    sst_1 = extract_variable(ocl_data, ocl_sensors.ocl_water_temp{2});     % UCSW temperature 1
    sst_2 = extract_variable(ocl_data, ocl_sensors.ocl_water_temp{3});     % UCSW temperature 2
    fluor = extract_variable(ocl_data, ocl_sensors.ocl_water_fluor{1});    % fluorometer
    trans = extract_variable(ocl_data, ocl_sensors.ocl_water_trans{1});    % transmissometer

    % Plot and edit variables
    % Plot the thermosalinograph first
    cleaned_data_thermosal = clean_thermosalinograph(thermosal, flow);

    thermosalinograph_seabird_sbe45_ucsw1_psbtsg1 = cleaned_data_thermosal;
    save(fullfile('..','ocl',ocl_sensors.ocl_water_sal{1}{1},...
        strcat(ocl_sensors.ocl_water_sal{1}{1},'_',sprintf('%.2d%.3d',mod(yy,100),daynumber),'_clean','.mat')), ...
        'thermosalinograph_seabird_sbe45_ucsw1_psbtsg1')

    % Plot up remaining variables
    data = {sst_1, sst_2, fluor, trans};
    labels = {'temperature', 'temperature', 'chlorophyll_conc', 'transmittance'};
    var_names = {'UCSW temp 1', 'UCSW temp 2', 'Fluoressence', 'Transmittance'};
    structnames = {'thermometer_seabird_sbe38_ucsw1_psbsst1', ...
                 'thermometer_seabird_sbe38_ucsw2_psbsst1', ...
                 'fluorometer_wetlabs_wschl_ucsw1_pwlfluor1', ...
                 'transmissometer_wetlabs_cstar_ucsw1_pwltran1'};
    
    stored_cleaning_output = check_plots(data, labels, var_names, flow);

    % Clean data based on the input
    for i = 1:length(stored_cleaning_output)
        if stored_cleaning_output(i)==1
            cleaned_data.(structnames{i}) = clean_data(data{i}, labels{i}, var_names{i}, flow);
        else
            cleaned_data.(structnames{i}) = data{i};
        end
        
        fprintf('Saving file %s.\n', structnames{i});
        save(fullfile('..','ocl',structnames{i},...
        strcat(structnames{i},'_',sprintf('%.2d%.3d',mod(yy,100),daynumber),'_clean','.mat')), ...
        '-struct',"cleaned_data",structnames{i})
    end

end

%% Functions for the script <3

% load up the oceanography data
function ocl_data = load_ocl_data(ocl_tables, yy, daynumber)
    ocl_data = struct();
    for n = 1:length(ocl_tables)
        filename_orig = fullfile('..', 'ocl', ocl_tables{n}, ...
            [ocl_tables{n}, '_', sprintf('%.2d%.3d', mod(yy, 100), daynumber), '.mat']);
        filename_clean = strrep(filename_orig, '.mat', '_clean.mat');

        if exist(filename_clean, "file")
            restart = input(['Cleaned file for ', ocl_tables{n}, ...
                ' already exists. Type "discard" to discard edits, otherwise press Enter: '], 's');
            if isempty(restart) || ~strcmp(restart, 'discard')
                ocl_data.(ocl_tables{n}) = load(filename_clean);
            else
                ocl_data.(ocl_tables{n}) = load(filename_orig);
            end
        elseif exist(filename_orig, 'file')
            ocl_data.(ocl_tables{n}) = load(filename_orig);
        else
            fprintf('No data for %s on day %.2d%.3d\n', ocl_tables{n}, mod(yy, 100), daynumber);
        end
    end
end

% Extract Specific Variable
function var = extract_variable(ocl_data, sensor)
    var = ocl_data.(sensor{1}).(sensor{1});
end

% Clean the Thermosalinograph data
function cleaned_data = clean_thermosalinograph(thermosal, flow)

    flow_interp = interp1(flow.time_jday, flow.flowrate, thermosal.time_jday);
    
    % plot up initial data
    figure;
    sgtitle("Thermosalinograph Variables")

    fields = {'conductivity', 'temperature', 'salinity'};
    for i = 1:length(fields)
        subplot(3,1,i)
        plot_ocl_var(thermosal, fields(i), flow_interp)
    end

    for i = 1:length(fields)
        
        if i == 1
            % clean the conductivity first and apply this to remaining
            % measurements from the thermosalinograph
            
            cleaning_output = say_what(input('Does the thermosalinograph conductivity data need cleaning? (yes or no): ', 's'));
        
            if cleaning_output == 1
                thermosal.conductivity = interactive_edit_poly(thermosal.time_jday, thermosal.conductivity, flow_interp, "Conductivity");
                iic=isnan(thermosal.conductivity); 
                thermosal.salinity(iic)=NaN;
                thermosal.temperature(iic)=NaN;
            end
            
        else
            % check temperature and salinity 
            figure;
            plot_ocl_var(thermosal, fields(i), flow_interp)

            cleaning_output = say_what(input(['Needs cleaning? ', fields{i}, ' (yes or no): '], 's'));  

            if cleaning_output == 1
                thermosal.(fields{i}) = interactive_edit_poly(thermosal.time_jday, thermosal.(fields{i}), flow_interp, fields{i});
            end
        end
    end
    
    cleaned_data = thermosal;

    close all

    figure;
    plot(datetime(flow.time, "ConvertFrom", "datenum"), flow.flowrate,'k.')
    title("Flow Rate (L/min)")

end

% check remaining data needs cleaning
function stored_cleaning_output = check_plots(variables, labels, var_name, flow)
    stored_cleaning_output = zeros(1, length(variables));

    for i = 1:length(variables)
        figure;
        flow_interp = interp1(flow.time_jday, flow.flowrate, variables{1, i}.time_jday);        
        plot_ocl_var(variables{i}, labels(i), flow_interp);
        stored_cleaning_output(i) = say_what(input(['Needs cleaning? ', var_name{i}, ' (yes or no): '], 's'));
    end

end

% plot data

function plot_ocl_var(thetable, var, flow_interp)

    x=datetime(thetable.time,"ConvertFrom","datenum");
    y=thetable.(var{1});
    
    plot(x,y, 'k.');
    hold on;
    plot(x(flow_interp < 700), y(flow_interp < 700), 'r.', 'MarkerSize', 6);
    
    title(strcat(var, " highlighted low flow (< 0.7L/min)"))

end

% Clean Data
function cleaned_data = clean_data(variables, field, var_names, flow)
    flow_interp = interp1(flow.time_jday, flow.flowrate, variables.time_jday);
    disp(['Cleaning ', var_names]);
    variables.(field) = interactive_edit_poly(...
        variables.time_jday, ...
        variables.(field), ...
        flow_interp);
    cleaned_data = variables;

end
