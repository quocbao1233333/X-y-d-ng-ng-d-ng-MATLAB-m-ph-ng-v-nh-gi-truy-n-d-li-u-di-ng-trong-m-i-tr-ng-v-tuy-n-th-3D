classdef FiveGmMTCBlock10App_WakeSleepBalanced_v8_ProfessionalMetrics < handle
    % FiveGmMTCBlock10App
    % ---------------------------------------------------------------------
    % BLOCK 10 — 5G mMTC/mIoT Massive Connectivity Simulation
    %
    % Topic:
    % Modeling and Simulation of the 5G mMTC/mIoT Block for Massive Sensor
    % Connectivity Based on Random Access, Device Energy, and Connection Density.
    %
    % How to run:
    %   1. Save this file as: FiveGmMTCBlock10App_WakeSleepBalanced_v7_DynamicRAOAnimation.m
    %   2. In MATLAB Command Window, run:
    %        app = FiveGmMTCBlock10App_WakeSleepBalanced_v8_ProfessionalMetrics;
    %
    % Main features:
    %   - Default-first app: opens with valid parameters and runs immediately.
    %   - 3D visualization: gNB, oval coverage, mMTC/eMBB/URLLC devices,
    %     MEC server, 5G Core/Cloud, wireless links, packet pulses,
    %     handover arcs, and offloading paths.
    %   - mMTC formulas: connection density, traffic activation, random access,
    %     collision, path loss, received power, SNR, PDR, delay, energy,
    %     and battery level.
    %   - Click/select any visible IoT device to show formula-based data.
    %   - Dynamic RAO animation: each frame refreshes wake/sleep/TX state,
    %     deletes old RF rays, redraws current TX rays, and moves packet pulses.
    %   - Theory Review tab: detailed theory, formulas, variables, and link to
    %     the 3D simulation.
    %
    % Important:
    %   The app simulates a large logical population N but renders only a
    %   selected visible subset. Metrics are computed from the logical
    %   population; the 3D scene is an interactive sampled visualization.

    properties
        UIFigure
        MainGrid
        LeftGrid
        RightTabs

        ParamTab
        DeviceTab
        TheoryTab
        ChartsTab

        Ax3D
        AxPDR
        AxCollision
        AxEnergy
        AxDelay
        DashboardPanel
        DashboardText
        StatusLabel
        BatchStatsText

        NField
        AreaField
        PaField
        ActivityModeDropDown
        ActiveRatioField
        TxGivenAwakeField
        SignalDisplayModeDropDown
        MaxTxRaysField
        TrafficModelDropDown
        PeriodicPeriodField
        PoissonLambdaField
        EventProbField
        MobilityModelDropDown
        VehicleSpeedField
        AccessBarringField
        BackoffWindowField
        PowerRampingField
        BatchRunsField
        PayloadField
        OverheadField
        RField
        PtField
        PathLossExpField
        IndoorLossField
        SNRThresholdField
        RetryField
        BatteryField
        VisibleField

        RunButton
        ResetButton
        AnimateButton
        BatchButton

        DeviceInfoText
        ExplainDeviceButton
        TheoryList
        TheoryText

        Params
        Devices
        VisibleIdx
        SelectedDeviceID = NaN
        IsAnimating = false
        SimResults
        History

        MmTCScatter
        EMBBScatter
        URLLCScatter
        LinkHandles = gobjects(0)
        PulseHandles = gobjects(0)
        HandoverHandles = gobjects(0)
    end

    methods
        function app = FiveGmMTCBlock10App_WakeSleepBalanced_v8_ProfessionalMetrics()
            app.createDefaultParams();
            app.createComponents();
            app.runSimulation();
        end

        function delete(app)
            try
                if ~isempty(app.UIFigure) && isvalid(app.UIFigure)
                    delete(app.UIFigure);
                end
            catch
            end
        end
    end

    methods (Access = private)
        %% DEFAULT PARAMETERS
        function createDefaultParams(app)
            app.Params = struct();

            % Main mMTC population parameters
            app.Params.N = 1000;
            app.Params.AreaKm2 = 1.0;
            app.Params.ActivationProbability = 0.001;
            % Wake/Sleep control for visual demonstration.
            % "Probabilistic p_a" preserves the classic mMTC model.
            % "Balanced 50/50 random" makes half of devices awake and half sleep.
            % "Custom active ratio" allows the user to choose the wake-up ratio.
            app.Params.ActivityMode = "Balanced 50/50 random";
            app.Params.TargetActiveRatio = 0.50;
            % Conditional transmission probability among awake devices.
            % Awake but not transmitting stays visible as an idle device and has no RF ray.
            app.Params.TxProbabilityGivenAwake = 0.35;

            % Signal-ray display control.
            % These parameters affect visualization only, not the network metrics.
            % Sleep and awake-idle devices never draw RF rays.
            app.Params.SignalDisplayMode = "Limited TX rays";
            app.Params.MaxVisibleTxRays = 6;

            % Advanced traffic model.
            % Bernoulli p_tx|awake keeps the old behavior.
            app.Params.TrafficModel = "Bernoulli p_tx|awake";
            app.Params.PeriodicPeriodSlots = 5;
            app.Params.PoissonLambda_per_s = 35;
            app.Params.EventTriggerProbability = 0.12;

            % URLLC mobility model for vehicle context devices.
            app.Params.MobilityModel = "URLLC linear mobility";
            app.Params.URLLCVehicleSpeed_kmh = 45;

            % Advanced RACH controls.
            app.Params.AccessBarringProbability = 0.05;
            app.Params.BackoffWindowSlots = 8;
            app.Params.PowerRampingStep_dB = 2;

            % Batch-statistics and chart history.
            app.Params.BatchRuns = 30;
            app.Params.VisibleDevices = 500;
            app.History = table();

            % Packet and random access parameters
            app.Params.PayloadBytes = 20;
            app.Params.OverheadBytes = 40;
            app.Params.AccessResources = 54;
            app.Params.MaxRetry = 3;

            % Radio link parameters
            app.Params.TransmitPowerdBm = 23;
            app.Params.Gt_dBi = 0;
            app.Params.Gr_dBi = 8;
            app.Params.PL0_dB = 32.4;
            app.Params.d0_m = 1;
            app.Params.PathLossExponent = 3.5;
            app.Params.ShadowSigma_dB = 4;
            app.Params.IndoorLoss_dB = 15;
            app.Params.BandwidthHz = 180e3;
            app.Params.NoiseFigure_dB = 5;
            app.Params.SNRThreshold_dB = -5;

            % Energy model parameters
            app.Params.Battery_J = 3600;
            app.Params.TxTime_s = 0.010;
            app.Params.RxTime_s = 0.002;
            app.Params.IdleTime_s = 0.020;
            app.Params.SleepTime_s = 0.968;
            app.Params.Ptx_W = 0.2;
            app.Params.Prx_W = 0.06;
            app.Params.Pidle_W = 0.01;
            app.Params.Psleep_W = 1e-5;

            % 3D scene positions
            app.Params.MacroPosition = [0, 0, 0.35];
            app.Params.MECPosition = [0.36, -0.42, 0.08];
            app.Params.CloudPosition = [-0.42, 0.42, 0.18];

            % Random seed for repeatable default run
            app.Params.RandomSeed = 10;

            % Experimental-observation parameters
            app.Params.CurrentSlot = 1;
            app.Params.SlotDuration_s = 0.010;
            app.Params.AccessMode = "Random Access";
        end

        %% UI CREATION
        function createComponents(app)
            app.UIFigure = uifigure( ...
                'Name', 'Block 10 — 5G mMTC/mIoT Massive Connectivity Simulation', ...
                'Position', [70 45 1520 870], ...
                'Color', [0.94 0.96 0.98]);

            app.MainGrid = uigridlayout(app.UIFigure, [1 2]);
            app.MainGrid.ColumnWidth = {'2.25x', '1x'};
            app.MainGrid.RowHeight = {'1x'};
            app.MainGrid.Padding = [10 10 10 10];
            app.MainGrid.ColumnSpacing = 10;

            app.LeftGrid = uigridlayout(app.MainGrid, [2 1]);
            app.LeftGrid.RowHeight = {'1x', 155};
            app.LeftGrid.ColumnWidth = {'1x'};
            app.LeftGrid.Padding = [0 0 0 0];
            app.LeftGrid.RowSpacing = 10;

            app.Ax3D = uiaxes(app.LeftGrid);
            app.Ax3D.Layout.Row = 1;
            app.Ax3D.Layout.Column = 1;
            title(app.Ax3D, '3D 5G mMTC/mIoT Scene');
            xlabel(app.Ax3D, 'X position (km)');
            ylabel(app.Ax3D, 'Y position (km)');
            zlabel(app.Ax3D, 'Network layer / height');
            grid(app.Ax3D, 'on');
            view(app.Ax3D, 42, 28);
            axis(app.Ax3D, 'equal');
            app.Ax3D.Box = 'on';
            app.Ax3D.ButtonDownFcn = @(src, evt) app.onAxesClicked();

            app.DashboardPanel = uipanel(app.LeftGrid, ...
                'Title', 'Live Dashboard — Core mMTC Metrics');
            app.DashboardPanel.Layout.Row = 2;
            dashGrid = uigridlayout(app.DashboardPanel, [1 1]);
            dashGrid.Padding = [8 8 8 8];
            app.DashboardText = uitextarea(dashGrid, ...
                'Editable', 'off', ...
                'FontName', 'Consolas', ...
                'FontSize', 12);

            app.RightTabs = uitabgroup(app.MainGrid);
            app.RightTabs.Layout.Row = 1;
            app.RightTabs.Layout.Column = 2;

            app.createParameterTab();
            app.createDeviceTab();
            app.createTheoryTab();
            app.createChartsTab();
        end

        function createParameterTab(app)
            app.ParamTab = uitab(app.RightTabs, 'Title', 'Parameters');
            grid = uigridlayout(app.ParamTab, [38 2]);
            grid.RowHeight = repmat({28}, 1, 38);
            grid.Scrollable = 'on';
            grid.ColumnWidth = {'1.35x', '1x'};
            grid.Padding = [12 12 12 12];
            grid.RowSpacing = 7;

            row = 1;
            app.addParamLabel(grid, row, 'Total IoT devices N (2–1000)');
            app.NField = app.addNumericField(grid, row, app.Params.N, [2 1000], true);
            row = row + 1;

            app.addParamLabel(grid, row, 'Area A (km²)');
            app.AreaField = app.addNumericField(grid, row, app.Params.AreaKm2, [0.01 100], false);
            row = row + 1;

            app.addParamLabel(grid, row, 'Activation probability p_a');
            app.PaField = app.addNumericField(grid, row, app.Params.ActivationProbability, [0 1], false);
            row = row + 1;

            app.addParamLabel(grid, row, 'Wake/Sleep activity mode');
            app.ActivityModeDropDown = uidropdown(grid, ...
                'Items', {'Probabilistic p_a','Balanced 50/50 random','Custom active ratio'}, ...
                'Value', char(app.Params.ActivityMode), ...
                'Tooltip', ['Probabilistic p_a: mô hình mMTC gốc. ', ...
                            'Balanced 50/50 random: chọn ngẫu nhiên đúng khoảng 50% thiết bị active. ', ...
                            'Custom active ratio: chọn tỷ lệ thiết bị thức tùy ý.']);
            app.ActivityModeDropDown.Layout.Row = row;
            app.ActivityModeDropDown.Layout.Column = 2;
            row = row + 1;

            app.addParamLabel(grid, row, 'Target awake ratio rho_awake');
            app.ActiveRatioField = app.addNumericField(grid, row, app.Params.TargetActiveRatio, [0 1], false);
            row = row + 1;

            app.addParamLabel(grid, row, 'Tx probability given awake p_tx|awake');
            app.TxGivenAwakeField = app.addNumericField(grid, row, app.Params.TxProbabilityGivenAwake, [0 1], false);
            row = row + 1;

            app.addParamLabel(grid, row, 'Signal display mode');
            app.SignalDisplayModeDropDown = uidropdown(grid, ...
                'Items', {'Off','Selected TX device only','Limited TX rays','All TX rays'}, ...
                'Value', char(app.Params.SignalDisplayMode), ...
                'ValueChangedFcn', @(src, evt) app.onSignalDisplayModeChanged(), ...
                'Tooltip', ['Off: không vẽ tia. ', ...
                            'Selected TX device only: chỉ vẽ tia của thiết bị đang truyền được chọn. ', ...
                            'Limited TX rays: vẽ tối đa K tia TX để tránh rối hình. ', ...
                            'All TX rays: vẽ toàn bộ thiết bị đang truyền.']);
            app.SignalDisplayModeDropDown.Layout.Row = row;
            app.SignalDisplayModeDropDown.Layout.Column = 2;
            row = row + 1;

            app.addParamLabel(grid, row, 'Maximum visible TX rays');
            app.MaxTxRaysField = app.addNumericField(grid, row, app.Params.MaxVisibleTxRays, [0 1000], true);
            row = row + 1;

            app.addParamLabel(grid, row, 'Traffic model');
            app.TrafficModelDropDown = uidropdown(grid, ...
                'Items', {'Bernoulli p_tx|awake','Periodic reporting','Poisson arrival','Event-triggered'}, ...
                'Value', char(app.Params.TrafficModel), ...
                'Tooltip', ['Bernoulli: dùng p_tx|awake. Periodic: báo cáo theo chu kỳ slot. ', ...
                            'Poisson: packet arrival theo quá trình Poisson. Event-triggered: chỉ phát khi có sự kiện.']);
            app.TrafficModelDropDown.Layout.Row = row;
            app.TrafficModelDropDown.Layout.Column = 2;
            row = row + 1;

            app.addParamLabel(grid, row, 'Periodic reporting period (slots)');
            app.PeriodicPeriodField = app.addNumericField(grid, row, app.Params.PeriodicPeriodSlots, [1 1000], true);
            row = row + 1;

            app.addParamLabel(grid, row, 'Poisson arrival lambda (pkt/s/device)');
            app.PoissonLambdaField = app.addNumericField(grid, row, app.Params.PoissonLambda_per_s, [0 1e5], false);
            row = row + 1;

            app.addParamLabel(grid, row, 'Event-trigger probability');
            app.EventProbField = app.addNumericField(grid, row, app.Params.EventTriggerProbability, [0 1], false);
            row = row + 1;

            app.addParamLabel(grid, row, 'URLLC mobility model');
            app.MobilityModelDropDown = uidropdown(grid, ...
                'Items', {'Static','URLLC linear mobility'}, ...
                'Value', char(app.Params.MobilityModel), ...
                'Tooltip', 'Static: không dịch chuyển xe URLLC. URLLC linear mobility: xe dịch chuyển theo vận tốc và thời gian mô phỏng.');
            app.MobilityModelDropDown.Layout.Row = row;
            app.MobilityModelDropDown.Layout.Column = 2;
            row = row + 1;

            app.addParamLabel(grid, row, 'URLLC vehicle speed (km/h)');
            app.VehicleSpeedField = app.addNumericField(grid, row, app.Params.URLLCVehicleSpeed_kmh, [0 250], false);
            row = row + 1;

            app.addParamLabel(grid, row, 'Access barring probability');
            app.AccessBarringField = app.addNumericField(grid, row, app.Params.AccessBarringProbability, [0 1], false);
            row = row + 1;

            app.addParamLabel(grid, row, 'Backoff window (slots)');
            app.BackoffWindowField = app.addNumericField(grid, row, app.Params.BackoffWindowSlots, [0 1000], true);
            row = row + 1;

            app.addParamLabel(grid, row, 'Power ramping step (dB/retry)');
            app.PowerRampingField = app.addNumericField(grid, row, app.Params.PowerRampingStep_dB, [0 10], false);
            row = row + 1;

            app.addParamLabel(grid, row, 'Batch runs for statistics');
            app.BatchRunsField = app.addNumericField(grid, row, app.Params.BatchRuns, [1 500], true);
            row = row + 1;

            app.addParamLabel(grid, row, 'Payload L_p (bytes)');
            app.PayloadField = app.addNumericField(grid, row, app.Params.PayloadBytes, [1 10000], true);
            row = row + 1;

            app.addParamLabel(grid, row, 'Overhead L_h (bytes)');
            app.OverheadField = app.addNumericField(grid, row, app.Params.OverheadBytes, [0 10000], true);
            row = row + 1;

            app.addParamLabel(grid, row, 'Access resources / preambles R');
            app.RField = app.addNumericField(grid, row, app.Params.AccessResources, [1 1000], true);
            row = row + 1;

            app.addParamLabel(grid, row, 'Transmit power P_t (dBm)');
            app.PtField = app.addNumericField(grid, row, app.Params.TransmitPowerdBm, [-40 40], false);
            row = row + 1;

            app.addParamLabel(grid, row, 'Path loss exponent n');
            app.PathLossExpField = app.addNumericField(grid, row, app.Params.PathLossExponent, [1.5 6], false);
            row = row + 1;

            app.addParamLabel(grid, row, 'Indoor loss L_indoor (dB)');
            app.IndoorLossField = app.addNumericField(grid, row, app.Params.IndoorLoss_dB, [0 50], false);
            row = row + 1;

            app.addParamLabel(grid, row, 'SNR threshold gamma_th (dB)');
            app.SNRThresholdField = app.addNumericField(grid, row, app.Params.SNRThreshold_dB, [-30 30], false);
            row = row + 1;

            app.addParamLabel(grid, row, 'Max retry count');
            app.RetryField = app.addNumericField(grid, row, app.Params.MaxRetry, [0 20], true);
            row = row + 1;

            app.addParamLabel(grid, row, 'Battery energy (J)');
            app.BatteryField = app.addNumericField(grid, row, app.Params.Battery_J, [1 1e8], false);
            row = row + 1;

            app.addParamLabel(grid, row, 'Visible 3D devices (2–1000)');
            app.VisibleField = app.addNumericField(grid, row, app.Params.VisibleDevices, [2 1000], true);
            row = row + 1;

            app.RunButton = uibutton(grid, 'push', ...
                'Text', 'Run / Update Simulation', ...
                'FontWeight', 'bold', ...
                'ButtonPushedFcn', @(src, evt) app.runSimulation());
            app.RunButton.Layout.Row = row;
            app.RunButton.Layout.Column = [1 2];
            row = row + 1;

            app.AnimateButton = uibutton(grid, 'push', ...
                'Text', 'Animate Packet Pulses', ...
                'ButtonPushedFcn', @(src, evt) app.animatePackets());
            app.AnimateButton.Layout.Row = row;
            app.AnimateButton.Layout.Column = [1 2];
            row = row + 1;

            app.BatchButton = uibutton(grid, 'push', ...
                'Text', 'Run Batch Statistics + Update Charts', ...
                'FontWeight', 'bold', ...
                'ButtonPushedFcn', @(src, evt) app.runBatchStatistics());
            app.BatchButton.Layout.Row = row;
            app.BatchButton.Layout.Column = [1 2];
            row = row + 1;

            app.ResetButton = uibutton(grid, 'push', ...
                'Text', 'Reset Defaults', ...
                'ButtonPushedFcn', @(src, evt) app.resetDefaults());
            app.ResetButton.Layout.Row = row;
            app.ResetButton.Layout.Column = [1 2];
            row = row + 1;

            app.StatusLabel = uilabel(grid, ...
                'Text', 'Ready. Defaults are loaded.', ...
                'FontColor', [0.1 0.25 0.55], ...
                'FontWeight', 'bold');
            app.StatusLabel.Layout.Row = row;
            app.StatusLabel.Layout.Column = [1 2];
        end

        function addParamLabel(~, grid, row, textValue)
            label = uilabel(grid, 'Text', textValue);
            label.Layout.Row = row;
            label.Layout.Column = 1;
        end

        function field = addNumericField(~, grid, row, value, limits, roundFlag)
            field = uieditfield(grid, 'numeric', ...
                'Value', value, ...
                'Limits', limits);
            if roundFlag
                field.RoundFractionalValues = 'on';
            else
                field.RoundFractionalValues = 'off';
            end
            field.Layout.Row = row;
            field.Layout.Column = 2;
        end

        function createDeviceTab(app)
            app.DeviceTab = uitab(app.RightTabs, 'Title', 'Selected Device Info');
            grid = uigridlayout(app.DeviceTab, [2 1]);
            grid.RowHeight = {'1x', 36};
            grid.Padding = [12 12 12 12];
            grid.RowSpacing = 8;

            app.DeviceInfoText = uitextarea(grid, ...
                'Editable', 'off', ...
                'FontName', 'Consolas', ...
                'FontSize', 12, ...
                'Value', {'Click/select a visible IoT device in the 3D scene.'});

            app.ExplainDeviceButton = uibutton(grid, 'push', ...
                'Text', 'Giải thích công thức của thiết bị này', ...
                'ButtonPushedFcn', @(src, evt) app.explainSelectedDevice());
        end

        function createTheoryTab(app)
            app.TheoryTab = uitab(app.RightTabs, 'Title', 'Ôn kiến thức');
            grid = uigridlayout(app.TheoryTab, [2 1]);
            grid.RowHeight = {122, '1x'};
            grid.Padding = [12 12 12 12];
            grid.RowSpacing = 8;

            topics = { ...
                '1. Tổng quan mMTC/mIoT', ...
                '2. Connection Density', ...
                '3. mMTC Traffic Model', ...
                '4. Random Access & Collision', ...
                '5. Path Loss Model', ...
                '6. Received Power & SNR', ...
                '7. Packet Delivery Ratio', ...
                '8. Energy & Battery Model', ...
                '9. MEC / Edge Offloading', ...
                '10. Handover & Service Types', ...
                '11. Vì sao 5G mạnh hơn 4G ở mMTC?'};

            app.TheoryList = uilistbox(grid, ...
                'Items', topics, ...
                'Value', topics{1}, ...
                'ValueChangedFcn', @(src, evt) app.updateTheoryText());

            app.TheoryText = uitextarea(grid, ...
                'Editable', 'off', ...
                'FontName', 'Consolas', ...
                'FontSize', 12);
            app.updateTheoryText();
        end


        function createChartsTab(app)
            app.ChartsTab = uitab(app.RightTabs, 'Title', 'Charts / Batch Stats');
            grid = uigridlayout(app.ChartsTab, [3 2]);
            grid.RowHeight = {'1x', '1x', 130};
            grid.ColumnWidth = {'1x', '1x'};
            grid.Padding = [10 10 10 10];
            grid.RowSpacing = 8;
            grid.ColumnSpacing = 8;

            app.AxPDR = uiaxes(grid);
            app.AxPDR.Layout.Row = 1;
            app.AxPDR.Layout.Column = 1;
            title(app.AxPDR, 'PDR over RAO');
            xlabel(app.AxPDR, 'Slot / RAO');
            ylabel(app.AxPDR, 'PDR');

            app.AxCollision = uiaxes(grid);
            app.AxCollision.Layout.Row = 1;
            app.AxCollision.Layout.Column = 2;
            title(app.AxCollision, 'Collision rate over RAO');
            xlabel(app.AxCollision, 'Slot / RAO');
            ylabel(app.AxCollision, 'Collision rate');

            app.AxEnergy = uiaxes(grid);
            app.AxEnergy.Layout.Row = 2;
            app.AxEnergy.Layout.Column = 1;
            title(app.AxEnergy, 'Mean energy over RAO');
            xlabel(app.AxEnergy, 'Slot / RAO');
            ylabel(app.AxEnergy, 'J / TX device');

            app.AxDelay = uiaxes(grid);
            app.AxDelay.Layout.Row = 2;
            app.AxDelay.Layout.Column = 2;
            title(app.AxDelay, 'Mean delay over RAO');
            xlabel(app.AxDelay, 'Slot / RAO');
            ylabel(app.AxDelay, 's / TX device');

            app.BatchStatsText = uitextarea(grid, ...
                'Editable', 'off', ...
                'FontName', 'Consolas', ...
                'FontSize', 11, ...
                'Value', {'Batch statistics will appear here after running multiple RAOs.'});
            app.BatchStatsText.Layout.Row = 3;
            app.BatchStatsText.Layout.Column = [1 2];
        end

        %% PARAMETER SYNC
        function resetDefaults(app)
            app.createDefaultParams();
            app.syncParamsToUI();
            app.runSimulation();
        end

        function syncParamsToUI(app)
            app.NField.Value = app.Params.N;
            app.AreaField.Value = app.Params.AreaKm2;
            app.PaField.Value = app.Params.ActivationProbability;
            app.ActivityModeDropDown.Value = char(app.Params.ActivityMode);
            app.ActiveRatioField.Value = app.Params.TargetActiveRatio;
            app.TxGivenAwakeField.Value = app.Params.TxProbabilityGivenAwake;
            app.SignalDisplayModeDropDown.Value = char(app.Params.SignalDisplayMode);
            app.MaxTxRaysField.Value = app.Params.MaxVisibleTxRays;
            app.TrafficModelDropDown.Value = char(app.Params.TrafficModel);
            app.PeriodicPeriodField.Value = app.Params.PeriodicPeriodSlots;
            app.PoissonLambdaField.Value = app.Params.PoissonLambda_per_s;
            app.EventProbField.Value = app.Params.EventTriggerProbability;
            app.MobilityModelDropDown.Value = char(app.Params.MobilityModel);
            app.VehicleSpeedField.Value = app.Params.URLLCVehicleSpeed_kmh;
            app.AccessBarringField.Value = app.Params.AccessBarringProbability;
            app.BackoffWindowField.Value = app.Params.BackoffWindowSlots;
            app.PowerRampingField.Value = app.Params.PowerRampingStep_dB;
            app.BatchRunsField.Value = app.Params.BatchRuns;
            app.PayloadField.Value = app.Params.PayloadBytes;
            app.OverheadField.Value = app.Params.OverheadBytes;
            app.RField.Value = app.Params.AccessResources;
            app.PtField.Value = app.Params.TransmitPowerdBm;
            app.PathLossExpField.Value = app.Params.PathLossExponent;
            app.IndoorLossField.Value = app.Params.IndoorLoss_dB;
            app.SNRThresholdField.Value = app.Params.SNRThreshold_dB;
            app.RetryField.Value = app.Params.MaxRetry;
            app.BatteryField.Value = app.Params.Battery_J;
            app.VisibleField.Value = app.Params.VisibleDevices;
        end

        function readParamsFromUI(app)
            app.Params.N = min(1000, max(2, round(app.NField.Value)));
            app.Params.AreaKm2 = app.AreaField.Value;
            app.Params.ActivationProbability = app.PaField.Value;
            app.Params.ActivityMode = string(app.ActivityModeDropDown.Value);
            app.Params.TargetActiveRatio = app.ActiveRatioField.Value;
            app.Params.TxProbabilityGivenAwake = app.TxGivenAwakeField.Value;
            app.Params.SignalDisplayMode = string(app.SignalDisplayModeDropDown.Value);
            app.Params.MaxVisibleTxRays = min(1000, max(0, round(app.MaxTxRaysField.Value)));
            app.Params.TrafficModel = string(app.TrafficModelDropDown.Value);
            app.Params.PeriodicPeriodSlots = max(1, round(app.PeriodicPeriodField.Value));
            app.Params.PoissonLambda_per_s = max(0, app.PoissonLambdaField.Value);
            app.Params.EventTriggerProbability = min(1, max(0, app.EventProbField.Value));
            app.Params.MobilityModel = string(app.MobilityModelDropDown.Value);
            app.Params.URLLCVehicleSpeed_kmh = max(0, app.VehicleSpeedField.Value);
            app.Params.AccessBarringProbability = min(1, max(0, app.AccessBarringField.Value));
            app.Params.BackoffWindowSlots = max(0, round(app.BackoffWindowField.Value));
            app.Params.PowerRampingStep_dB = max(0, app.PowerRampingField.Value);
            app.Params.BatchRuns = min(500, max(1, round(app.BatchRunsField.Value)));
            app.Params.PayloadBytes = round(app.PayloadField.Value);
            app.Params.OverheadBytes = round(app.OverheadField.Value);
            app.Params.AccessResources = round(app.RField.Value);
            app.Params.TransmitPowerdBm = app.PtField.Value;
            app.Params.PathLossExponent = app.PathLossExpField.Value;
            app.Params.IndoorLoss_dB = app.IndoorLossField.Value;
            app.Params.SNRThreshold_dB = app.SNRThresholdField.Value;
            app.Params.MaxRetry = round(app.RetryField.Value);
            app.Params.Battery_J = app.BatteryField.Value;
            app.Params.VisibleDevices = min(app.Params.N, min(1000, max(2, round(app.VisibleField.Value))));
        end

        function G = expectedActiveLoad(~, p, N)
            switch string(p.ActivityMode)
                case "Balanced 50/50 random"
                    G = round(0.50 * N);
                case "Custom active ratio"
                    G = round(min(1, max(0, p.TargetActiveRatio)) * N);
                otherwise
                    G = N * p.ActivationProbability;
            end
        end

        %% SIMULATION CORE
        function runSimulation(app)
            app.readParamsFromUI();
            app.StatusLabel.Text = 'Running simulation...';
            drawnow;

            rng(app.Params.RandomSeed);
            p = app.Params;
            N = p.N;
            A = p.AreaKm2;
            sideKm = sqrt(A);

            currentSlot = p.CurrentSlot;
            simulationTime_s = (currentSlot - 1) * p.SlotDuration_s;
            accessOpportunity = sprintf('RAO-%04d', currentSlot);

            % 1. Spatial device population
            x = (rand(N, 1) - 0.5) * sideKm;
            y = (rand(N, 1) - 0.5) * sideKm;
            z = zeros(N, 1);

            % 2. Service-type context: mMTC dominant, eMBB and URLLC visible
            deviceRand = rand(N, 1);
            type = strings(N, 1);
            type(deviceRand <= 0.88) = "mMTC Sensor";
            type(deviceRand > 0.88 & deviceRand <= 0.95) = "eMBB Phone";
            type(deviceRand > 0.95) = "URLLC Vehicle";

            % 2b. Mobility model for URLLC vehicle context devices.
            mobilityDisplacement_m = zeros(N, 1);
            if string(p.MobilityModel) == "URLLC linear mobility"
                vehicleMask = type == "URLLC Vehicle";
                if any(vehicleMask)
                    heading = 2*pi*rand(N, 1);
                    v_kmps = p.URLLCVehicleSpeed_kmh / 3600;
                    mobilityDisplacement_km = v_kmps * simulationTime_s;
                    mobilityDisplacement_m(vehicleMask) = mobilityDisplacement_km * 1000;
                    x(vehicleMask) = x(vehicleMask) + mobilityDisplacement_km .* cos(heading(vehicleMask));
                    y(vehicleMask) = y(vehicleMask) + mobilityDisplacement_km .* sin(heading(vehicleMask));

                    % Wrap around the square service area to keep vehicles visible.
                    x(vehicleMask) = mod(x(vehicleMask) + sideKm/2, sideKm) - sideKm/2;
                    y(vehicleMask) = mod(y(vehicleMask) + sideKm/2, sideKm) - sideKm/2;
                end
            end

            % 3. Wake / sleep and transmission model
            % Important visualization rule:
            %   Sleep                -> no RF ray
            %   Awake but idle        -> marker only, no RF ray
            %   Awake + transmitting  -> draw uplink RF ray to gNB
            switch string(p.ActivityMode)
                case "Balanced 50/50 random"
                    awake = false(N, 1);
                    Ktarget = round(0.50 * N);
                    if Ktarget > 0
                        awake(randperm(N, Ktarget)) = true;
                    end
                case "Custom active ratio"
                    awake = false(N, 1);
                    rhoAwake = min(1, max(0, p.TargetActiveRatio));
                    Ktarget = round(rhoAwake * N);
                    if Ktarget > 0
                        awake(randperm(N, Ktarget)) = true;
                    end
                otherwise
                    awake = rand(N, 1) < p.ActivationProbability;
                    eMask = type == "eMBB Phone";
                    uMask = type == "URLLC Vehicle";
                    awake(eMask) = rand(sum(eMask), 1) < min(0.020, max(p.ActivationProbability * 4, 0.002));
                    awake(uMask) = rand(sum(uMask), 1) < min(0.030, max(p.ActivationProbability * 5, 0.002));
            end

            % Among awake devices, the traffic model decides which devices
            % actually generate packets in the current RAO/slot.
            pTxGivenAwake = min(1, max(0, p.TxProbabilityGivenAwake));
            trafficModel = string(p.TrafficModel);
            switch trafficModel
                case "Periodic reporting"
                    periodSlots = max(1, round(p.PeriodicPeriodSlots));
                    devicePhase = mod((1:N).' + currentSlot - 2, periodSlots) == 0;
                    active = awake & devicePhase;

                case "Poisson arrival"
                    pArrival = 1 - exp(-p.PoissonLambda_per_s * p.SlotDuration_s);
                    pArrival = min(1, max(0, pArrival));
                    active = awake & (rand(N, 1) < pArrival);

                case "Event-triggered"
                    pEvent = p.EventTriggerProbability .* ones(N, 1);
                    pEvent(type == "URLLC Vehicle") = min(1, 1.8 * p.EventTriggerProbability);
                    pEvent(type == "eMBB Phone") = min(1, 1.2 * p.EventTriggerProbability);
                    active = awake & (rand(N, 1) < pEvent);

                otherwise
                    active = awake & (rand(N, 1) < pTxGivenAwake);
            end

            % Access Class Barring (ACB): a generated packet can be blocked
            % before Msg1/preamble transmission. Barred devices do not draw RF rays.
            accessBarred = active & (rand(N, 1) < p.AccessBarringProbability);
            active(accessBarred) = false;

            % For teaching/demo: if devices are awake and traffic model allows
            % transmissions, keep at least one transmitting device so the scene is alive.
            if any(awake) && ~any(active) && pTxGivenAwake > 0 && p.AccessBarringProbability < 1
                awakeIdxTmp = find(awake & ~accessBarred);
                if ~isempty(awakeIdxTmp)
                    active(awakeIdxTmp(randi(numel(awakeIdxTmp)))) = true;
                end
            end

            generatedPackets = sum(active) + sum(accessBarred);

            % 4. Random access resource selection
            preamble = zeros(N, 1);
            activeIdx = find(active);
            K = numel(activeIdx);
            if K > 0
                preamble(activeIdx) = randi(p.AccessResources, K, 1);
            end

            % 5. Collision detection
            collision = false(N, 1);
            if K > 0
                counts = accumarray(preamble(activeIdx), 1, [p.AccessResources 1]);
                collidedResources = find(counts > 1);
                collision(activeIdx) = ismember(preamble(activeIdx), collidedResources);
            end

            % 6. Radio link budget
            gNBxy = p.MacroPosition(1:2);
            d_km = sqrt((x - gNBxy(1)).^2 + (y - gNBxy(2)).^2);
            d_m = max(d_km * 1000, p.d0_m);

            shadowing = p.ShadowSigma_dB .* randn(N, 1);
            indoorFlag = rand(N, 1) < 0.35;
            indoorLoss = p.IndoorLoss_dB .* indoorFlag;

            PL_dB = p.PL0_dB + ...
                10 * p.PathLossExponent .* log10(d_m ./ p.d0_m) + ...
                shadowing + indoorLoss;

            Pr_dBm = p.TransmitPowerdBm + p.Gt_dBi + p.Gr_dBi - PL_dB;
            N_dBm = -174 + 10 * log10(p.BandwidthHz) + p.NoiseFigure_dB;
            SNR_dB = Pr_dBm - N_dBm;

            % Interference/SINR model:
            % Active devices that select the same access resource create
            % same-resource interference. Sleep devices keep a potential
            % SNR/SINR value for analysis, but they do not actually transmit.
            Pr_mW = 10.^(Pr_dBm ./ 10);
            noise_mW = 10.^(N_dBm ./ 10);
            interference_mW = zeros(N, 1);

            if K > 0
                resourcePower_mW = accumarray( ...
                    preamble(activeIdx), ...
                    Pr_mW(activeIdx), ...
                    [p.AccessResources 1], ...
                    @sum, ...
                    0);
                interference_mW(activeIdx) = max( ...
                    resourcePower_mW(preamble(activeIdx)) - Pr_mW(activeIdx), ...
                    0);
            end

            InterferencePower_dBm = 10 .* log10(max(interference_mW, 1e-15));
            SINR_dB = 10 .* log10(Pr_mW ./ (noise_mW + interference_mW));

            potentialLinkOK = SNR_dB >= p.SNRThreshold_dB;
            actualRadioOK = SINR_dB >= p.SNRThreshold_dB;
            linkOK = actualRadioOK;

            % 7. Final success condition
            success = active & ~collision & linkOK;
            failed = active & ~success;
            retryCount = zeros(N, 1);
            if any(failed)
                retryCount(failed) = randi([1, max(1, p.MaxRetry)], sum(failed), 1);
            end

            backoffSlots = zeros(N, 1);
            if any(failed) && p.BackoffWindowSlots > 0
                backoffSlots(failed) = randi([0, p.BackoffWindowSlots], sum(failed), 1);
            end
            backoffDelay_s = backoffSlots .* p.SlotDuration_s;
            effectiveTxPower_dBm = p.TransmitPowerdBm + retryCount .* p.PowerRampingStep_dB;

            % 8. Delay model
            T_access = 0.010 + retryCount .* 0.020 + backoffDelay_s;
            T_tx = p.TxTime_s * ones(N, 1);
            T_queue = 0.005 + 0.0005 .* K .* ones(N, 1);
            T_core = 0.010 + 0.020 .* rand(N, 1);
            T_processing = 0.005 + 0.015 .* rand(N, 1);
            delay_s = T_access + T_tx + T_queue + T_core + T_processing;
            delay_s(~active) = 0;

            % 9. Energy model
            TtxEff = p.TxTime_s .* (1 + retryCount);
            PtxEff_W = p.Ptx_W .* 10.^(retryCount .* p.PowerRampingStep_dB ./ 10);
            E_J = PtxEff_W .* TtxEff + ...
                p.Prx_W .* p.RxTime_s + ...
                p.Pidle_W .* p.IdleTime_s + ...
                p.Psleep_W .* p.SleepTime_s;
            idleAwake = awake & ~active;
            E_J(idleAwake) = p.Prx_W .* p.RxTime_s + ...
                p.Pidle_W .* (p.TxTime_s + p.IdleTime_s) + ...
                p.Psleep_W .* p.SleepTime_s;
            E_J(accessBarred) = p.Prx_W .* p.RxTime_s + ...
                p.Pidle_W .* (p.TxTime_s + p.IdleTime_s) + ...
                p.Psleep_W .* p.SleepTime_s;
            E_J(~awake) = p.Psleep_W .* ...
                (p.TxTime_s + p.RxTime_s + p.IdleTime_s + p.SleepTime_s);
            cumulativeEnergy_J = E_J .* max(currentSlot, 1);
            batteryRemainingPct = max(0, 100 .* (1 - cumulativeEnergy_J ./ p.Battery_J));
            energyPerDay_J = (E_J ./ p.SlotDuration_s) .* 86400;
            estimatedLifetimeDays = p.Battery_J ./ max(energyPerDay_J, eps);

            % Radio error estimate. This is a simple engineering model for
            % visualization, not a replacement for a full BLER curve from MCS.
            sinrMargin_dB = SINR_dB - p.SNRThreshold_dB;
            packetErrorRate = 0.5 .* exp(-0.25 .* max(sinrMargin_dB, -20));
            packetErrorRate = min(max(packetErrorRate, 1e-4), 1);
            blockErrorRate = packetErrorRate;
            actualPacketErrorRate = packetErrorRate;
            actualPacketErrorRate(active & collision) = 1;
            actualPacketErrorRate(~active) = NaN;

            % 10. MEC / Cloud offloading decision
            offload = strings(N, 1);
            offload(:) = "None/Sleep";
            offload(awake & ~active) = "None/Awake idle";
            offload(accessBarred) = "None/Access barred";
            offload(success & type == "URLLC Vehicle") = "MEC";
            offload(success & type == "mMTC Sensor") = "MEC";
            offload(success & type == "eMBB Phone") = "Cloud/Core";

            packetBits = 8 * p.PayloadBytes;
            overheadBits = 8 * p.OverheadBytes;
            etaPayload = packetBits / max(packetBits + overheadBits, 1);

            state = strings(N, 1);
            state(~awake) = "Sleep";
            state(awake & ~active) = "Awake Idle";
            state(accessBarred) = "Access Barred";
            state(active & collision) = "Collision";
            state(active & ~collision & ~linkOK) = "Link Failed";
            state(success) = "Success";

            failureReason = strings(N, 1);
            failureReason(~awake) = "Sleep - no access attempt";
            failureReason(awake & ~active) = "Awake idle - no packet generated";
            failureReason(accessBarred) = "Access barred before preamble transmission";
            failureReason(active & collision) = "Random-access collision";
            failureReason(active & ~collision & ~linkOK) = "SINR below threshold";
            failureReason(success) = "None - packet delivered";

            actualTransmissionStatus = strings(N, 1);
            actualTransmissionStatus(~awake) = "No transmission: sleep mode";
            actualTransmissionStatus(awake & ~active) = "No transmission: awake idle";
            actualTransmissionStatus(accessBarred) = "No transmission: access barred";
            actualTransmissionStatus(active & collision) = "Access failed: collision";
            actualTransmissionStatus(active & ~collision & ~linkOK) = "Access ok, radio failed";
            actualTransmissionStatus(success) = "Delivered successfully";

            servingCell = strings(N, 1);
            servingCell(:) = "Macro gNB";

            accessMode = strings(N, 1);
            accessMode(:) = string(p.AccessMode);

            slotIndex = currentSlot .* ones(N, 1);
            simTimeCol_s = simulationTime_s .* ones(N, 1);
            rao = strings(N, 1);
            rao(:) = string(accessOpportunity);

            ID = (1:N).';
            app.Devices = table(ID, type, x, y, z, d_m, mobilityDisplacement_m, awake, active, accessBarred, preamble, ...
                collision, PL_dB, Pr_dBm, SNR_dB, SINR_dB, ...
                InterferencePower_dBm, potentialLinkOK, actualRadioOK, ...
                linkOK, success, retryCount, backoffSlots, backoffDelay_s, effectiveTxPower_dBm, delay_s, E_J, cumulativeEnergy_J, ...
                batteryRemainingPct, estimatedLifetimeDays, packetErrorRate, ...
                blockErrorRate, actualPacketErrorRate, state, failureReason, ...
                actualTransmissionStatus, offload, servingCell, accessMode, ...
                indoorFlag, slotIndex, simTimeCol_s, rao, ...
                'VariableNames', {'ID','Type','X_km','Y_km','Z_km', ...
                'Distance_m','MobilityDisplacement_m','Awake','Active','AccessBarred','Preamble','Collision', ...
                'PathLoss_dB','ReceivedPower_dBm','SNR_dB','SINR_dB', ...
                'InterferencePower_dBm','PotentialLinkOK','ActualRadioOK', ...
                'LinkOK','Success','RetryCount','BackoffSlots','BackoffDelay_s','EffectiveTxPower_dBm','Delay_s','Energy_J', ...
                'CumulativeEnergy_J','Battery_pct','EstimatedLifetime_days', ...
                'PER','BLER','ActualPER','State','FailureReason', ...
                'ActualTransmissionStatus','Offload','ServingCell','AccessMode', ...
                'Indoor','SlotIndex','SimulationTime_s','AccessOpportunity'});

            % 11. Global metrics
            awakeCount = sum(awake);
            attempts = sum(active);
            delivered = sum(success);
            generated = generatedPackets;
            mmtcMask = type == "mMTC Sensor";

            app.SimResults = struct();
            app.SimResults.DeviceDensity = N / A;
            app.SimResults.AwakeDevices = awakeCount;
            app.SimResults.AwakeRatio = app.safeDivide(awakeCount, N);
            app.SimResults.ActiveDevices = attempts;
            app.SimResults.ActualActiveRatio = app.safeDivide(attempts, N);
            app.SimResults.TxProbabilityGivenAwake = pTxGivenAwake;
            app.SimResults.TrafficModel = trafficModel;
            app.SimResults.GeneratedPackets = generated;
            app.SimResults.AccessBarredCount = sum(accessBarred);
            app.SimResults.AccessBarringRate = app.safeDivide(sum(accessBarred), max(generated, 1));
            app.SimResults.MeanBackoff_s = app.meanIfAny(backoffDelay_s(failed));
            app.SimResults.MeanRetry = app.meanIfAny(retryCount(active | accessBarred));
            app.SimResults.MobilityModel = string(p.MobilityModel);
            app.SimResults.URLLCVehicleSpeed_kmh = p.URLLCVehicleSpeed_kmh;
            app.SimResults.SignalDisplayMode = string(p.SignalDisplayMode);
            app.SimResults.MaxVisibleTxRays = p.MaxVisibleTxRays;
            app.SimResults.DisplayedTxRayCount = 0;
            app.SimResults.ActivityMode = string(p.ActivityMode);
            app.SimResults.AverageActiveG = app.expectedActiveLoad(p, N);
            app.SimResults.CollisionCount = sum(collision & active);
            app.SimResults.CollisionRate = app.safeDivide(sum(collision & active), attempts);
            app.SimResults.PDR = app.safeDivide(delivered, generated);
            app.SimResults.AccessSuccessProbability = app.safeDivide(delivered, attempts);
            app.SimResults.MeanDelay_s = app.meanIfAny(delay_s(active));
            app.SimResults.MeanEnergy_J = app.meanIfAny(E_J(active));
            app.SimResults.MeanSNR_dB = app.meanIfAny(SNR_dB(active));
            app.SimResults.MeanSINR_dB = app.meanIfAny(SINR_dB(active));
            app.SimResults.MeanInterference_dBm = app.meanIfAny(InterferencePower_dBm(active));
            app.SimResults.MeanPER = app.meanIfAny(actualPacketErrorRate(active));
            app.SimResults.MeanBattery_pct = app.meanIfAny(batteryRemainingPct);
            app.SimResults.MeanLifetime_days = app.meanIfAny(estimatedLifetimeDays(active));
            app.SimResults.CurrentSlot = currentSlot;
            app.SimResults.SimulationTime_s = simulationTime_s;
            app.SimResults.AccessOpportunity = accessOpportunity;
            app.SimResults.PayloadEfficiency = etaPayload;
            app.SimResults.mMTCCount = sum(mmtcMask);
            app.SimResults.eMBBCount = sum(type == "eMBB Phone");
            app.SimResults.URLLCCount = sum(type == "URLLC Vehicle");
            app.SimResults.mMTCDelivered = sum(success & mmtcMask);

            app.VisibleIdx = app.selectVisibleDevices();

            % Pick a representative device BEFORE rendering. This is critical
            % for "Selected TX device only" mode: the selected TX ID must be
            % known before the RF-ray drawing stage.
            app.SelectedDeviceID = app.chooseRepresentativeDeviceID();

            app.renderScene();
            app.updateDashboard();
            app.appendHistory();
            app.updateCharts();
            app.autoSelectRepresentativeDevice();

            app.StatusLabel.Text = sprintf(['Simulation updated. Activity mode = %s, ', ...
                'awake devices = %d / %d (%.2f%%%%), transmitting devices = %d, displayed RF rays = %d. ', ...
                'Selected Device tab shows a representative transmitting device when available.'], ...
                char(app.SimResults.ActivityMode), app.SimResults.AwakeDevices, ...
                p.N, 100*app.SimResults.AwakeRatio, app.SimResults.ActiveDevices, ...
                app.SimResults.DisplayedTxRayCount);
            app.Params.CurrentSlot = currentSlot + 1;
        end

        function idx = selectVisibleDevices(app)
            p = app.Params;
            N = height(app.Devices);
            maxVisible = min(p.VisibleDevices, N);

            successIdx = find(app.Devices.Success);
            collIdx = find(app.Devices.Collision & app.Devices.Active);
            linkFailIdx = find(app.Devices.Active & ~app.Devices.Collision & ~app.Devices.Success);
            activeIdx = find(app.Devices.Active);
            awakeIdleIdx = find(app.Devices.Awake & ~app.Devices.Active);
            sleepIdx = find(~app.Devices.Awake);

            phoneIdx = find(app.Devices.Type == "eMBB Phone");
            vehicleIdx = find(app.Devices.Type == "URLLC Vehicle");

            % Priority rule:
            % 1) Always reserve a large portion of the visible scene for active
            %    devices, so Balanced/Custom wake-sleep modes are visible.
            % 2) Still keep some sleeping/background/context devices.
            % 3) Keep eMBB/URLLC markers visible for 5G service-type context.
            targetActiveVisible = min(numel(activeIdx), max(1, round(0.65 * maxVisible)));
            targetContextVisible = min(round(0.12 * maxVisible), numel(unique([phoneIdx; vehicleIdx])));
            targetSleepVisible = maxVisible - targetActiveVisible - targetContextVisible;
            if targetSleepVisible < 0
                targetSleepVisible = 0;
            end

            activeVisible = unique([ ...
                app.sampleVec(successIdx, min(round(0.30*targetActiveVisible), numel(successIdx))); ...
                app.sampleVec(collIdx, min(round(0.25*targetActiveVisible), numel(collIdx))); ...
                app.sampleVec(linkFailIdx, min(round(0.25*targetActiveVisible), numel(linkFailIdx))); ...
                app.sampleVec(activeIdx, targetActiveVisible); ...
                app.sampleVec(awakeIdleIdx, max(0, targetActiveVisible - numel(activeIdx))) ...
                ]);

            if numel(activeVisible) > targetActiveVisible
                activeVisible = app.sampleVec(activeVisible, targetActiveVisible);
            end

            contextVisible = unique([ ...
                app.sampleVec(phoneIdx, min(round(0.50*targetContextVisible), numel(phoneIdx))); ...
                app.sampleVec(vehicleIdx, min(round(0.50*targetContextVisible), numel(vehicleIdx))) ...
                ]);

            if numel(contextVisible) > targetContextVisible
                contextVisible = app.sampleVec(contextVisible, targetContextVisible);
            end

            selected = unique([activeVisible; contextVisible]);

            remainingSlots = maxVisible - numel(selected);
            if remainingSlots > 0
                sleepPool = setdiff(sleepIdx, selected);
                selected = [selected; app.sampleVec(sleepPool, min(remainingSlots, numel(sleepPool)))];
            end

            if numel(selected) < maxVisible
                remain = setdiff((1:N).', selected);
                selected = [selected; app.sampleVec(remain, min(maxVisible - numel(selected), numel(remain)))];
            end

            if numel(selected) > maxVisible
                % Keep active devices first, trim only after preserving the
                % priority group.
                activeKeep = selected(ismember(selected, activeIdx));
                otherKeep = setdiff(selected, activeKeep, 'stable');
                selected = [activeKeep; otherKeep];
                selected = selected(1:maxVisible);
            end

            idx = selected(:);
        end

        function selectedID = chooseRepresentativeDeviceID(app)
            selectedID = NaN;

            if isempty(app.Devices) || isempty(app.VisibleIdx)
                return;
            end

            visibleIDs = app.Devices.ID(app.VisibleIdx);
            visibleT = app.Devices(app.VisibleIdx, :);

            % Priority:
            % 1) successful transmitting device
            % 2) transmitting collision
            % 3) other transmitting device
            % 4) awake idle device
            % 5) any visible device
            priorityMasks = { ...
                visibleT.Success, ...
                visibleT.Active & visibleT.Collision, ...
                visibleT.Active, ...
                visibleT.Awake & ~visibleT.Active, ...
                true(height(visibleT), 1) ...
                };

            for k = 1:numel(priorityMasks)
                cand = find(priorityMasks{k});
                if ~isempty(cand)
                    [~, rel] = min(visibleT.Distance_m(cand));
                    selectedID = visibleIDs(cand(rel));
                    return;
                end
            end
        end

        function autoSelectRepresentativeDevice(app)
            selectedID = app.chooseRepresentativeDeviceID();

            if isnan(selectedID)
                app.SelectedDeviceID = NaN;
                app.DeviceInfoText.Value = {'No visible device available.'};
                return;
            end

            app.SelectedDeviceID = selectedID;
            app.updateSelectedDeviceInfo(app.SelectedDeviceID);
            app.highlightSelectedDevice(app.SelectedDeviceID);
        end

        %% 3D RENDERING
        function renderScene(app)
            ax = app.Ax3D;
            cla(ax);
            hold(ax, 'on');
            grid(ax, 'on');
            view(ax, 42, 28);
            axis(ax, 'equal');
            ax.Box = 'on';
            ax.Color = [0.985 0.99 1.0];
            xlabel(ax, 'X position (km)');
            ylabel(ax, 'Y position (km)');
            zlabel(ax, 'Network layer / height');

            p = app.Params;
            sideKm = sqrt(p.AreaKm2);
            xlim(ax, [-sideKm/2 - 0.18, sideKm/2 + 0.18]);
            ylim(ax, [-sideKm/2 - 0.18, sideKm/2 + 0.18]);
            zlim(ax, [0, 0.65]);

            app.deleteTaggedTxObjects(ax);
            app.drawGroundAndCoverage(ax, sideKm);
            app.drawBaseStation(ax, p.MacroPosition);
            app.drawMECAndCloud(ax);
            app.drawDevices(ax);
            app.drawActiveLinks(ax);
            app.drawHandoverArcs(ax);

            title(ax, sprintf(['Block 10 — 5G mMTC/mIoT | N=%s | ', ...
                'Density=%.0f devices/km^2 | Awake=%d | TX=%d | Displayed Rays=%d'], ...
                app.formatNumber(app.Params.N), ...
                app.SimResults.DeviceDensity, ...
                app.SimResults.AwakeDevices, ...
                app.SimResults.ActiveDevices, ...
                app.SimResults.DisplayedTxRayCount));

            legend(ax, 'Location', 'northeastoutside');
            hold(ax, 'off');
        end

        function drawGroundAndCoverage(~, ax, sideKm)
            [gx, gy] = meshgrid(linspace(-sideKm/2, sideKm/2, 16));
            gz = zeros(size(gx));
            surf(ax, gx, gy, gz, ...
                'FaceAlpha', 0.07, ...
                'EdgeAlpha', 0.14, ...
                'FaceColor', [0.55 0.75 0.55], ...
                'EdgeColor', [0.35 0.55 0.35], ...
                'DisplayName', 'Smart city / factory area');

            theta = linspace(0, 2*pi, 180);
            rx = sideKm * 0.56;
            ry = sideKm * 0.42;
            xCov = rx * cos(theta);
            yCov = ry * sin(theta);
            zCov = 0.01 * ones(size(theta));
            plot3(ax, xCov, yCov, zCov, ...
                'Color', [0.1 0.25 0.95], ...
                'LineWidth', 1.6, ...
                'DisplayName', 'gNB oval coverage');
            patch(ax, xCov, yCov, zCov, [0.2 0.45 1.0], ...
                'FaceAlpha', 0.045, ...
                'EdgeColor', 'none', ...
                'DisplayName', 'Coverage zone');
        end

        function drawBaseStation(~, ax, pos)
            x0 = pos(1);
            y0 = pos(2);
            h = pos(3);
            baseR = 0.055;
            topR = 0.012;
            basePts = [x0-baseR y0-baseR 0; x0+baseR y0-baseR 0; x0 y0+baseR 0];
            topPt = [x0 y0 h];

            for k = 1:3
                plot3(ax, [basePts(k,1), topPt(1)], ...
                    [basePts(k,2), topPt(2)], ...
                    [0, h], ...
                    'Color', [0.23 0.23 0.23], ...
                    'LineWidth', 2.2, ...
                    'HandleVisibility', 'off');
            end

            for zz = linspace(0.07, h-0.06, 4)
                r = interp1([0 h], [baseR topR], zz);
                pts = [x0-r y0-r zz; x0+r y0-r zz; x0 y0+r zz; x0-r y0-r zz];
                plot3(ax, pts(:,1), pts(:,2), pts(:,3), ...
                    'Color', [0.38 0.38 0.38], ...
                    'LineWidth', 1.1, ...
                    'HandleVisibility', 'off');
            end

            scatter3(ax, x0, y0, h+0.03, 130, '^', 'filled', ...
                'MarkerFaceColor', [0.05 0.05 0.05], ...
                'MarkerEdgeColor', [0 0 0], ...
                'DisplayName', 'gNB / Macro base station');
            text(ax, x0, y0, h+0.09, 'gNB', ...
                'FontWeight', 'bold', ...
                'HorizontalAlignment', 'center');

            for r = [0.035 0.055 0.075]
                theta = linspace(-pi/2, pi/2, 40);
                plot3(ax, x0 + r*cos(theta), ...
                    y0 + 0.02*sin(theta), ...
                    h + 0.055 + 0.04*sin(theta), ...
                    'Color', [0.1 0.1 0.1], ...
                    'LineWidth', 1.1, ...
                    'HandleVisibility', 'off');
            end
        end

        function drawMECAndCloud(app, ax)
            p = app.Params;
            mec = p.MECPosition;
            cloud = p.CloudPosition;

            scatter3(ax, mec(1), mec(2), mec(3), 180, 's', 'filled', ...
                'MarkerFaceColor', [0.15 0.35 0.75], ...
                'MarkerEdgeColor', [0.05 0.15 0.35], ...
                'DisplayName', 'MEC server');
            text(ax, mec(1), mec(2), mec(3)+0.05, 'MEC Server', ...
                'FontWeight', 'bold', ...
                'HorizontalAlignment', 'center');
            plot3(ax, [p.MacroPosition(1), mec(1)], ...
                [p.MacroPosition(2), mec(2)], ...
                [p.MacroPosition(3), mec(3)], ...
                '--', ...
                'Color', [0.15 0.35 0.75], ...
                'LineWidth', 1.8, ...
                'DisplayName', 'gNB-MEC backhaul');

            scatter3(ax, cloud(1), cloud(2), cloud(3), 210, 'p', 'filled', ...
                'MarkerFaceColor', [0.45 0.45 0.80], ...
                'MarkerEdgeColor', [0.15 0.15 0.45], ...
                'DisplayName', '5G Core / Cloud');
            text(ax, cloud(1), cloud(2), cloud(3)+0.055, '5G Core / Cloud', ...
                'FontWeight', 'bold', ...
                'HorizontalAlignment', 'center');
            plot3(ax, [mec(1), cloud(1)], ...
                [mec(2), cloud(2)], ...
                [mec(3), cloud(3)], ...
                ':', ...
                'Color', [0.35 0.25 0.8], ...
                'LineWidth', 1.8, ...
                'DisplayName', 'MEC-Cloud offload path');
        end

        function drawDevices(app, ax)
            T = app.Devices(app.VisibleIdx, :);
            mMask = T.Type == "mMTC Sensor";
            eMask = T.Type == "eMBB Phone";
            uMask = T.Type == "URLLC Vehicle";

            c = repmat([0.35 0.35 0.35], height(T), 1);
            c(T.State == "Awake Idle", :) = repmat([0.10 0.45 0.95], sum(T.State == "Awake Idle"), 1);
            c(T.State == "Access Barred", :) = repmat([0.55 0.20 0.85], sum(T.State == "Access Barred"), 1);
            c(T.State == "Success", :) = repmat([0.10 0.65 0.20], sum(T.State == "Success"), 1);
            c(T.State == "Collision", :) = repmat([0.95 0.25 0.10], sum(T.State == "Collision"), 1);
            c(T.State == "Link Failed", :) = repmat([0.95 0.70 0.10], sum(T.State == "Link Failed"), 1);

            if any(mMask)
                app.MmTCScatter = scatter3(ax, ...
                    T.X_km(mMask), T.Y_km(mMask), 0.025 + 0*T.X_km(mMask), ...
                    34, c(mMask,:), 'o', 'filled', ...
                    'MarkerEdgeColor', [0.08 0.08 0.08], ...
                    'DisplayName', 'mMTC devices / sensors');
                app.MmTCScatter.UserData = T.ID(mMask);
                app.MmTCScatter.ButtonDownFcn = @(src, evt) app.onScatterClicked(src, evt);
                app.MmTCScatter.PickableParts = 'all';
                app.MmTCScatter.HitTest = 'on';
            end

            if any(eMask)
                app.EMBBScatter = scatter3(ax, ...
                    T.X_km(eMask), T.Y_km(eMask), 0.045 + 0*T.X_km(eMask), ...
                    62, 's', 'filled', ...
                    'MarkerFaceColor', [0.05 0.45 0.90], ...
                    'MarkerEdgeColor', [0.02 0.12 0.25], ...
                    'DisplayName', 'eMBB phone context');
                app.EMBBScatter.UserData = T.ID(eMask);
                app.EMBBScatter.ButtonDownFcn = @(src, evt) app.onScatterClicked(src, evt);
                app.EMBBScatter.PickableParts = 'all';
                app.EMBBScatter.HitTest = 'on';
            end

            if any(uMask)
                app.URLLCScatter = scatter3(ax, ...
                    T.X_km(uMask), T.Y_km(uMask), 0.055 + 0*T.X_km(uMask), ...
                    76, 'd', 'filled', ...
                    'MarkerFaceColor', [0.0 0.75 0.85], ...
                    'MarkerEdgeColor', [0.02 0.18 0.20], ...
                    'DisplayName', 'URLLC vehicle context');
                app.URLLCScatter.UserData = T.ID(uMask);
                app.URLLCScatter.ButtonDownFcn = @(src, evt) app.onScatterClicked(src, evt);
                app.URLLCScatter.PickableParts = 'all';
                app.URLLCScatter.HitTest = 'on';
            end

            side = sqrt(app.Params.AreaKm2);
            text(ax, -0.55*side, -0.55*side, 0.05, 'mMTC: many low-power sensors', ...
                'FontSize', 10, ...
                'Color', [0.1 0.3 0.1], ...
                'FontWeight', 'bold');
            text(ax, -0.55*side, -0.50*side, 0.05, 'eMBB: phone context', ...
                'FontSize', 10, ...
                'Color', [0.05 0.25 0.65]);
            text(ax, -0.55*side, -0.45*side, 0.05, 'URLLC: vehicle context', ...
                'FontSize', 10, ...
                'Color', [0.0 0.50 0.55]);
        end

        function deleteTaggedTxObjects(app, ax)
            % Strong cleanup: remove all old RF-ray and pulse graphics before
            % every redraw/animation step. This prevents stale rays from
            % remaining when a device goes back to Sleep or Awake Idle.
            try
                delete(findall(ax, 'Tag', 'TxRay'));
                delete(findall(ax, 'Tag', 'TxPulse'));
                delete(findall(ax, 'Tag', 'AnimatedTxRay'));
                delete(findall(ax, 'Tag', 'AnimatedTxPulse'));
            catch
            end

            try
                if ~isempty(app.LinkHandles)
                    validLine = isgraphics(app.LinkHandles);
                    delete(app.LinkHandles(validLine));
                end
            catch
            end

            try
                if ~isempty(app.PulseHandles)
                    validPulse = isgraphics(app.PulseHandles);
                    delete(app.PulseHandles(validPulse));
                end
            catch
            end

            app.LinkHandles = gobjects(0);
            app.PulseHandles = gobjects(0);
        end

        function drawActiveLinks(app, ax)
            app.deleteTaggedTxObjects(ax);
            app.LinkHandles = gobjects(0);
            app.PulseHandles = gobjects(0);

            p = app.Params;
            T = app.Devices(app.VisibleIdx, :);

            % Strict visualization rule:
            %   Sleep              -> no RF ray
            %   Awake Idle         -> no RF ray
            %   Awake + TX packet  -> RF ray is eligible
            if ismember('Awake', T.Properties.VariableNames) && ...
                    ismember('Active', T.Properties.VariableNames)
                txMask = T.Awake & T.Active;
            else
                txMask = false(height(T), 1);
            end

            txTAll = T(txMask, :);
            app.SimResults.DisplayedTxRayCount = 0;

            if isempty(txTAll)
                return;
            end

            mode = string(p.SignalDisplayMode);
            if mode == "Off"
                app.SimResults.DisplayedTxRayCount = 0;
                app.deleteTaggedTxObjects(ax);
                return;
            end

            switch mode
                case "Off"
                    txT = txTAll([],:);

                case "Selected TX device only"
                    if ~isnan(app.SelectedDeviceID)
                        selMask = txTAll.ID == app.SelectedDeviceID;
                        if any(selMask)
                            txT = txTAll(selMask, :);
                        else
                            txT = txTAll([],:);
                        end
                    else
                        % If no device is selected yet, pick one representative
                        % transmitting device so the mode still demonstrates
                        % exactly one active RF ray after opening/running the app.
                        [~, kMin] = min(txTAll.Distance_m);
                        txT = txTAll(kMin, :);
                    end

                case "All TX rays"
                    txT = txTAll;

                otherwise
                    % Limited TX rays: show at most K transmitting links.
                    maxLinks = min(max(0, round(p.MaxVisibleTxRays)), height(txTAll));
                    ids = app.sampleVec((1:height(txTAll)).', maxLinks);
                    txT = txTAll(ids, :);
            end

            app.SimResults.DisplayedTxRayCount = height(txT);
            if isempty(txT)
                return;
            end

            g = p.MacroPosition;

            for k = 1:height(txT)
                d = txT(k, :);
                if d.Collision
                    lineColor = [0.95 0.20 0.05];
                    lineStyle = '-';
                elseif d.Success
                    lineColor = [0.05 0.55 0.15];
                    lineStyle = '-';
                else
                    lineColor = [0.95 0.65 0.10];
                    lineStyle = '--';
                end

                hh = plot3(ax, [d.X_km, g(1)], [d.Y_km, g(2)], [0.045, g(3)], ...
                    lineStyle, ...
                    'Color', lineColor, ...
                    'LineWidth', 0.85, ...
                    'HandleVisibility', 'off', ...
                    'Tag', 'TxRay');
                app.LinkHandles(end+1) = hh;

                pulseFrac = 0.35 + 0.35 * rand();
                xp = d.X_km + pulseFrac * (g(1) - d.X_km);
                yp = d.Y_km + pulseFrac * (g(2) - d.Y_km);
                zp = 0.045 + pulseFrac * (g(3) - 0.045);

                ph = scatter3(ax, xp, yp, zp, 30, 'filled', ...
                    'MarkerFaceColor', [1.0 0.95 0.05], ...
                    'MarkerEdgeColor', [0.8 0.5 0.0], ...
                    'HandleVisibility', 'off', ...
                    'Tag', 'TxPulse');
                app.PulseHandles(end+1) = ph;
            end
        end

        function drawHandoverArcs(app, ax)
            p = app.Params;
            side = sqrt(p.AreaKm2);
            centers = [-0.25*side 0.22*side; 0.25*side 0.22*side];
            app.HandoverHandles = gobjects(0);

            for i = 1:2
                theta = linspace(0.1*pi, 0.9*pi, 60);
                x = centers(i,1) + 0.18*side*cos(theta);
                y = centers(i,2) + 0.08*side*sin(theta);
                z = 0.35 + 0.05*sin(theta);
                h = plot3(ax, x, y, z, ...
                    'Color', [0.62 0.62 0.62], ...
                    'LineWidth', 1.2, ...
                    'LineStyle', '--', ...
                    'DisplayName', 'handover indication');
                if i > 1
                    h.HandleVisibility = 'off';
                end
                app.HandoverHandles(end+1) = h;
            end

            text(ax, 0, 0.37*side, 0.42, 'Handover / Mobility context', ...
                'FontSize', 9, ...
                'HorizontalAlignment', 'center', ...
                'Color', [0.35 0.35 0.35]);
        end

        %% ANIMATION
        function animatePackets(app)
            if app.IsAnimating
                app.IsAnimating = false;
                app.AnimateButton.Text = 'Animate Packet Pulses';
                return;
            end

            app.readParamsFromUI();

            app.IsAnimating = true;
            app.AnimateButton.Text = 'Stop Animation';
            drawnow;

            originalSeed = app.Params.RandomSeed;
            originalSlot = app.Params.CurrentSlot;
            nFrames = 12;
            nPulseSubSteps = 6;
            pulsePause_s = 0.055;

            if string(app.Params.SignalDisplayMode) == "Off"
                % Respect the user's mode absolutely. Off means no RF rays and
                % no packet pulses, even during animation.
                app.deleteTaggedTxObjects(app.Ax3D);
                app.renderScene();
                app.updateDashboard();
                app.StatusLabel.Text = ['Signal display mode is Off: animation keeps all RF rays hidden. ', ...
                    'Choose Limited TX rays or Selected TX device only to see dynamic RAO packet pulses.'];
                app.IsAnimating = false;
                app.AnimateButton.Text = 'Animate Packet Pulses';
                return;
            end

            for frame = 1:nFrames
                if ~app.IsAnimating || ~isvalid(app.UIFigure)
                    break;
                end

                % Each animation frame represents a new RAO/slot snapshot.
                % Therefore Wake/Sleep/TX states, selected TX devices, RF rays,
                % and packet pulses are regenerated from a new random seed.
                app.Params.RandomSeed = originalSeed + 97 * frame;
                app.Params.CurrentSlot = originalSlot + frame - 1;

                app.runSimulation();

                app.StatusLabel.Text = sprintf(['Dynamic RAO animation frame %02d/%02d | ', ...
                    'Awake=%d | TX=%d | Displayed RF rays=%d | Mode=%s'], ...
                    frame, nFrames, app.SimResults.AwakeDevices, ...
                    app.SimResults.ActiveDevices, app.SimResults.DisplayedTxRayCount, ...
                    char(app.Params.SignalDisplayMode));
                drawnow;

                app.animateCurrentPulseSweep(nPulseSubSteps, pulsePause_s);
            end

            app.Params.RandomSeed = originalSeed;
            app.IsAnimating = false;
            if isvalid(app.UIFigure)
                app.AnimateButton.Text = 'Animate Packet Pulses';
                app.StatusLabel.Text = sprintf(['Dynamic RAO animation completed. Last frame kept on screen. ', ...
                    'Final displayed RF rays = %d.'], app.SimResults.DisplayedTxRayCount);
            end
        end

        function animateCurrentPulseSweep(app, nSteps, pause_s)
            if isempty(app.LinkHandles) || isempty(app.PulseHandles)
                pause(pause_s);
                drawnow limitrate;
                return;
            end

            n = min(numel(app.LinkHandles), numel(app.PulseHandles));
            for step = 1:nSteps
                if ~app.IsAnimating || ~isvalid(app.UIFigure)
                    return;
                end

                frac = step / max(nSteps, 1);
                for k = 1:n
                    if isgraphics(app.LinkHandles(k)) && isgraphics(app.PulseHandles(k))
                        xd = app.LinkHandles(k).XData;
                        yd = app.LinkHandles(k).YData;
                        zd = app.LinkHandles(k).ZData;
                        if numel(xd) >= 2 && numel(yd) >= 2 && numel(zd) >= 2
                            xPulse = xd(1) + frac * (xd(end) - xd(1));
                            yPulse = yd(1) + frac * (yd(end) - yd(1));
                            zPulse = zd(1) + frac * (zd(end) - zd(1));
                            app.PulseHandles(k).XData = xPulse;
                            app.PulseHandles(k).YData = yPulse;
                            app.PulseHandles(k).ZData = zPulse;
                        end
                    end
                end

                pause(pause_s);
                drawnow limitrate;
            end
        end

        function onSignalDisplayModeChanged(app)
            if isempty(app.Devices) || isempty(app.SimResults)
                return;
            end

            app.readParamsFromUI();
            app.deleteTaggedTxObjects(app.Ax3D);

            % Re-render immediately so switching to Off actually removes all
            % current RF rays without needing the user to press Run.
            app.SelectedDeviceID = app.chooseRepresentativeDeviceID();
            app.renderScene();
            app.updateDashboard();
            app.appendHistory();
            app.updateCharts();
            app.autoSelectRepresentativeDevice();

            if string(app.Params.SignalDisplayMode) == "Off"
                app.StatusLabel.Text = 'Signal display mode changed to Off: all RF rays and packet pulses are hidden.';
            else
                app.StatusLabel.Text = sprintf('Signal display mode changed to %s. Displayed RF rays = %d.', ...
                    char(app.Params.SignalDisplayMode), app.SimResults.DisplayedTxRayCount);
            end
        end

        %% DEVICE SELECTION
        function onScatterClicked(app, src, evt)
            if isempty(src.UserData)
                return;
            end
            ids = src.UserData;

            try
                pt = evt.IntersectionPoint;
                xData = src.XData(:);
                yData = src.YData(:);
                zData = src.ZData(:);
                dist = (xData - pt(1)).^2 + ...
                       (yData - pt(2)).^2 + ...
                       0.3*(zData - pt(3)).^2;
                [~, localIdx] = min(dist);
            catch
                localIdx = 1;
            end

            selectedID = ids(localIdx);
            app.SelectedDeviceID = selectedID;
            app.updateSelectedDeviceInfo(selectedID);
            app.RightTabs.SelectedTab = app.DeviceTab;
            app.highlightSelectedDevice(selectedID);
        end

        function onAxesClicked(app)
            cp = app.Ax3D.CurrentPoint;
            pt = cp(1, 1:3);
            T = app.Devices(app.VisibleIdx, :);
            if isempty(T)
                return;
            end

            d2 = (T.X_km - pt(1)).^2 + (T.Y_km - pt(2)).^2;
            [minD, idx] = min(d2);
            side = sqrt(app.Params.AreaKm2);
            if minD < (0.04 * side)^2
                app.SelectedDeviceID = T.ID(idx);
                app.updateSelectedDeviceInfo(app.SelectedDeviceID);
                app.RightTabs.SelectedTab = app.DeviceTab;
                app.highlightSelectedDevice(app.SelectedDeviceID);
            end
        end

        function highlightSelectedDevice(app, selectedID)
            ax = app.Ax3D;
            T = app.Devices(app.Devices.ID == selectedID, :);
            if isempty(T)
                return;
            end

            hold(ax, 'on');
            scatter3(ax, T.X_km, T.Y_km, 0.09, 150, 'o', ...
                'LineWidth', 2.2, ...
                'MarkerEdgeColor', [1 0 0], ...
                'MarkerFaceColor', 'none', ...
                'HandleVisibility', 'off');
            text(ax, T.X_km, T.Y_km, 0.13, sprintf('IoT-%d', T.ID), ...
                'Color', [0.75 0 0], ...
                'FontWeight', 'bold', ...
                'HorizontalAlignment', 'center', ...
                'HandleVisibility', 'off');
            hold(ax, 'off');
        end

        function updateSelectedDeviceInfo(app, id)
            T = app.Devices(app.Devices.ID == id, :);
            if isempty(T)
                app.DeviceInfoText.Value = {'Selected device not found.'};
                return;
            end

            p = app.Params;
            payloadBits = 8 * p.PayloadBytes;
            overheadBits = 8 * p.OverheadBytes;
            etaPayload = payloadBits / max(payloadBits + overheadBits, 1);
            noisePower_dBm = -174 + 10*log10(p.BandwidthHz) + p.NoiseFigure_dB;

            lines = { ...
                'SELECTED IOT DEVICE — FORMULA-BASED STATUS'; ...
                '============================================================'; ...
                sprintf('Current slot / RAO      : %d / %s', T.SlotIndex, char(T.AccessOpportunity)); ...
                sprintf('Simulation time         : %.4f s', T.SimulationTime_s); ...
                sprintf('Device ID              : IoT-%d', T.ID); ...
                sprintf('Device type            : %s', char(T.Type)); ...
                sprintf('Mobility displacement  : %.2f m in this simulation time', T.MobilityDisplacement_m); ...
                sprintf('Serving cell            : %s', char(T.ServingCell)); ...
                sprintf('Access mode             : %s', char(T.AccessMode)); ...
                sprintf('Position (x,y,z)       : (%.4f km, %.4f km, %.4f km)', T.X_km, T.Y_km, T.Z_km); ...
                sprintf('Distance to gNB d_i    : %.2f m', T.Distance_m); ...
                sprintf('Indoor/deep-indoor     : %s', app.yesNo(T.Indoor)); ...
                sprintf('State                  : %s', char(T.State)); ...
                sprintf('Wake/Sleep             : %s', app.awakeText(T.Awake)); ...
                sprintf('Transmitting now?      : %s', app.activeText(T.Active)); ...
                sprintf('Visual RF ray visible? : %s', app.rfRayVisibilityText(T)); ...
                'Animation meaning       : if this device transmits in a new RAO, its ray is redrawn from its current position'; ...
                sprintf('Actual transmission    : %s', char(T.ActualTransmissionStatus)); ...
                sprintf('Failure reason         : %s', char(T.FailureReason)); ...
                ''; ...
                'TRAFFIC AND RANDOM ACCESS'; ...
                '------------------------------------------------------------'; ...
                sprintf('Payload L_p            : %d bytes = %d bits', p.PayloadBytes, payloadBits); ...
                sprintf('Overhead L_h           : %d bytes = %d bits', p.OverheadBytes, overheadBits); ...
                sprintf('Payload efficiency     : eta_payload = %.2f %%', 100*etaPayload); ...
                sprintf('Activation prob. p_a   : %.6f', p.ActivationProbability); ...
                sprintf('Wake/Sleep mode        : %s', char(p.ActivityMode)); ...
                sprintf('Target awake ratio     : %.2f %%', 100*p.TargetActiveRatio); ...
                sprintf('Tx prob. if awake      : %.2f %%', 100*p.TxProbabilityGivenAwake); ...
                sprintf('Signal display mode    : %s', char(p.SignalDisplayMode)); ...
                sprintf('Max visible TX rays    : %d', p.MaxVisibleTxRays); ...
                sprintf('Traffic model          : %s', char(p.TrafficModel)); ...
                sprintf('Access barring prob.   : %.2f %%', 100*p.AccessBarringProbability); ...
                sprintf('Selected resource R_i  : %s', app.resourceText(T)); ...
                sprintf('Total resources R      : %d', p.AccessResources); ...
                sprintf('Collision status       : %s', app.yesNo(T.Collision)); ...
                sprintf('Access barred?         : %s', app.yesNo(T.AccessBarred)); ...
                sprintf('Retry count            : %d', T.RetryCount); ...
                sprintf('Backoff slots          : %d', T.BackoffSlots); ...
                sprintf('Backoff delay          : %.4f s', T.BackoffDelay_s); ...
                ''; ...
                'RADIO LINK CALCULATION'; ...
                '------------------------------------------------------------'; ...
                sprintf('Path loss PL(d_i)      : %.2f dB', T.PathLoss_dB); ...
                sprintf('Transmit power P_t     : %.2f dBm', p.TransmitPowerdBm); ...
                sprintf('Effective TX power     : %.2f dBm after retry/ramping', T.EffectiveTxPower_dBm); ...
                sprintf('Antenna gain G_t       : %.2f dBi', p.Gt_dBi); ...
                sprintf('Antenna gain G_r       : %.2f dBi', p.Gr_dBi); ...
                sprintf('Received power P_r     : %.2f dBm', T.ReceivedPower_dBm); ...
                sprintf('Noise power N          : %.2f dBm', noisePower_dBm); ...
                sprintf('Interference power I   : %s', app.dBmText(T.InterferencePower_dBm, T.Active)); ...
                sprintf('Potential SNR          : %.2f dB', T.SNR_dB); ...
                sprintf('Actual SINR            : %s', app.sinrText(T)); ...
                sprintf('SNR/SINR threshold     : %.2f dB', p.SNRThreshold_dB); ...
                sprintf('Potential radio link   : %s', app.yesNo(T.PotentialLinkOK)); ...
                sprintf('Actual radio status    : %s', app.actualRadioStatusText(T)); ...
                sprintf('Radio PER estimate     : %.6f', T.PER); ...
                sprintf('Radio BLER estimate    : %.6f', T.BLER); ...
                sprintf('Actual packet error    : %s', app.actualPERText(T)); ...
                ''; ...
                'DELAY, ENERGY, BATTERY, AND DELIVERY'; ...
                '------------------------------------------------------------'; ...
                sprintf('Delay T_total          : %.4f s', T.Delay_s); ...
                sprintf('Energy this slot E_i   : %.6f J', T.Energy_J); ...
                sprintf('Cumulative energy      : %.6f J', T.CumulativeEnergy_J); ...
                sprintf('Battery remaining      : %.4f %%', T.Battery_pct); ...
                sprintf('Estimated lifetime     : %s', app.lifetimeText(T.EstimatedLifetime_days)); ...
                sprintf('Offloading decision    : %s', char(T.Offload)); ...
                sprintf('Packet delivered?      : %s', app.yesNo(T.Success)); ...
                ''; ...
                'DEVICE-LEVEL INTERPRETATION'; ...
                '------------------------------------------------------------'; ...
                sprintf('Access interpretation  : %s', app.accessInterpretation(T)); ...
                sprintf('Radio interpretation   : %s', app.radioInterpretation(T, p)); ...
                sprintf('Energy interpretation  : %s', app.energyInterpretation(T)); ...
                ''; ...
                'CORE FORMULA SUMMARY'; ...
                '------------------------------------------------------------'; ...
                'Connection density      : lambda_d = N / A'; ...
                'Average awake load      : Probabilistic G_wake = N p_a; Balanced/Custom G_wake = N rho_awake'; ...
                'Average TX load         : G_tx = G_wake p_tx|awake'; ...
                'Collision probability   : P_collision|K = 1 - (1 - 1/R)^(K-1)'; ...
                'Path loss               : PL(d_i) = PL0 + 10n log10(d_i/d0) + Xsigma + L_indoor'; ...
                'Received power          : P_r,i = P_t,i + G_t + G_r - PL(d_i)'; ...
                'Noise power             : N_dBm = -174 + 10log10(B) + NF'; ...
                'SINR                    : SINR = S / (I + N)'; ...
                'Success condition       : Success = Active AND No-Collision AND SINR >= gamma_th'; ...
                'Energy model            : E_i = P_txT_tx + P_rxT_rx + P_idleT_idle + P_sleepT_sleep'; ...
                'PER/BLER model          : PER = 0.5 exp[-0.25(SINR - gamma_th)] with clipping'; ...
                ''; ...
                'HOW THIS DEVICE CONTRIBUTES TO GLOBAL METRICS'; ...
                '------------------------------------------------------------'; ...
                sprintf('Contributes to attempt count?       : %s', app.yesNo(T.Active)); ...
                sprintf('Contributes to collision count?     : %s', app.yesNo(T.Active && T.Collision)); ...
                sprintf('Contributes to delivered packets?   : %s', app.yesNo(T.Success)); ...
                sprintf('Contributes to PDR numerator?       : %s', app.yesNo(T.Success)); ...
                sprintf('Contributes to PDR denominator?     : %s', app.yesNo(T.Active)); ...
                sprintf('Contributes to energy average?      : %s', app.yesNo(T.Active)); ...
                sprintf('Contributes to delay average?       : %s', app.yesNo(T.Active)); ...
                ''; ...
                'VISUAL MEANING IN 3D SCENE'; ...
                '------------------------------------------------------------'; ...
                'Gray marker       : sleeping device'; ...
                'Green marker      : successful packet delivery'; ...
                'Red marker        : random-access collision'; ...
                'Yellow marker     : radio link failed because SINR is below threshold'; ...
                'Blue marker       : awake idle device, no packet generated, no RF ray'; ...
                'Wireless line     : awake + transmitting uplink only'; ...
                'Yellow pulse      : short packet traveling from IoT device to gNB'};

            app.DeviceInfoText.Value = lines;
        end

        function explainSelectedDevice(app)
            if isnan(app.SelectedDeviceID)
                app.DeviceInfoText.Value = {'Please select a visible IoT device first.'};
                return;
            end

            T = app.Devices(app.Devices.ID == app.SelectedDeviceID, :);
            if isempty(T)
                return;
            end

            p = app.Params;
            N_dBm = -174 + 10*log10(p.BandwidthHz) + p.NoiseFigure_dB;

            lines = { ...
                sprintf('GIẢI THÍCH CÔNG THỨC CHO THIẾT BỊ IoT-%d', T.ID); ...
                '============================================================'; ...
                ''; ...
                '1) Khoảng cách đến gNB'; ...
                sprintf('Thiết bị có vị trí (%.4f, %.4f) km, gNB đặt tại (%.4f, %.4f) km.', ...
                    T.X_km, T.Y_km, p.MacroPosition(1), p.MacroPosition(2)); ...
                'Khoảng cách d_i được tính từ hình học Euclid.'; ...
                sprintf('d_i = %.2f m', T.Distance_m); ...
                ''; ...
                '2) Suy hao đường truyền'; ...
                'PL(d_i) = PL0 + 10n log10(d_i/d0) + Xsigma + L_indoor'; ...
                sprintf('n = %.2f, L_indoor = %.2f dB.', p.PathLossExponent, p.IndoorLoss_dB); ...
                sprintf('PL(d_i) = %.2f dB', T.PathLoss_dB); ...
                'Ý nghĩa: d_i càng xa hoặc indoor loss càng lớn thì PL càng tăng.'; ...
                ''; ...
                '3) Công suất thu'; ...
                'P_r,i = P_t,i + G_t + G_r - PL(d_i)'; ...
                sprintf('P_t = %.2f dBm, G_t = %.2f dBi, G_r = %.2f dBi.', ...
                    p.TransmitPowerdBm, p.Gt_dBi, p.Gr_dBi); ...
                sprintf('P_r,i = %.2f dBm', T.ReceivedPower_dBm); ...
                ''; ...
                '4) SNR/SINR'; ...
                'N_dBm = -174 + 10log10(B) + NF'; ...
                sprintf('B = %.0f Hz, NF = %.2f dB => N_dBm = %.2f dBm.', ...
                    p.BandwidthHz, p.NoiseFigure_dB, N_dBm); ...
                'SNR_dB = P_r,dBm - N_dBm'; ...
                'SINR = S / (I + N)'; ...
                sprintf('Potential SNR = %.2f dB', T.SNR_dB); ...
                sprintf('Actual SINR   = %.2f dB', T.SINR_dB); ...
                sprintf('Interference  = %.2f dBm', T.InterferencePower_dBm); ...
                sprintf('Ngưỡng yêu cầu gamma_th = %.2f dB.', p.SNRThreshold_dB); ...
                ''; ...
                '5) Điều kiện thành công'; ...
                'Success = Awake AND Transmitting AND No-Collision AND SINR >= gamma_th'; ...
                sprintf('Awake       : %s', app.yesNo(T.Awake)); ...
                sprintf('Transmitting: %s', app.yesNo(T.Active)); ...
                sprintf('Collision   : %s', app.yesNo(T.Collision)); ...
                sprintf('Potential SNR passed : %s', app.yesNo(T.PotentialLinkOK)); ...
                sprintf('Actual SINR passed   : %s', app.yesNo(T.ActualRadioOK)); ...
                sprintf('Failure reason       : %s', char(T.FailureReason)); ...
                sprintf('Final result         : %s', char(T.State)); ...
                ''; ...
                '6) Năng lượng'; ...
                'E_i = P_tx T_tx + P_rx T_rx + P_idle T_idle + P_sleep T_sleep'; ...
                sprintf('Retry count = %d nên thời gian phát hiệu dụng tăng khi retry tăng.', T.RetryCount); ...
                sprintf('Energy this slot = %.6f J.', T.Energy_J); ...
                sprintf('Cumulative energy = %.6f J.', T.CumulativeEnergy_J); ...
                sprintf('Battery còn lại xấp xỉ %.4f %%.', T.Battery_pct); ...
                sprintf('Estimated lifetime = %s.', app.lifetimeText(T.EstimatedLifetime_days)); ...
                ''; ...
                'Kết luận:'; ...
                'Thiết bị này minh họa trực tiếp quan hệ giữa vị trí 3D, truy nhập ngẫu nhiên,'; ...
                'va chạm, suy hao đường truyền, SNR, retry, năng lượng và khả năng giao gói.'};

            app.DeviceInfoText.Value = lines;
        end

        %% DASHBOARD AND THEORY

        function appendHistory(app)
            if isempty(app.SimResults)
                return;
            end
            r = app.SimResults;
            newRow = table( ...
                r.CurrentSlot, r.SimulationTime_s, r.PDR, r.CollisionRate, ...
                r.MeanEnergy_J, r.MeanDelay_s, r.ActiveDevices, r.DisplayedTxRayCount, ...
                r.AccessBarredCount, r.MeanBackoff_s, ...
                'VariableNames', {'Slot','Time_s','PDR','CollisionRate', ...
                'MeanEnergy_J','MeanDelay_s','TXDevices','DisplayedRays', ...
                'AccessBarred','MeanBackoff_s'});
            if isempty(app.History)
                app.History = newRow;
            else
                app.History = [app.History; newRow];
                if height(app.History) > 300
                    app.History = app.History(end-299:end, :);
                end
            end
        end

        function updateCharts(app)
            if isempty(app.History) || isempty(app.AxPDR) || ~isvalid(app.AxPDR)
                return;
            end
            H = app.History;
            app.plotMetric(app.AxPDR, H.Slot, H.PDR, ...
                'PDR over RAO', 'Slot / RAO', 'PDR');
            app.plotMetric(app.AxCollision, H.Slot, H.CollisionRate, ...
                'Collision rate over RAO', 'Slot / RAO', 'Collision rate');
            app.plotMetric(app.AxEnergy, H.Slot, H.MeanEnergy_J, ...
                'Mean energy over RAO', 'Slot / RAO', 'J / TX device');
            app.plotMetric(app.AxDelay, H.Slot, H.MeanDelay_s, ...
                'Mean delay over RAO', 'Slot / RAO', 's / TX device');
        end

        function plotMetric(~, ax, x, y, ttl, xl, yl)
            cla(ax);
            plot(ax, x, y, '-o', 'LineWidth', 1.2, 'MarkerSize', 4);
            grid(ax, 'on');
            title(ax, ttl);
            xlabel(ax, xl);
            ylabel(ax, yl);
            if ~isempty(y) && all(isfinite(y))
                ymin = min(y);
                ymax = max(y);
                if ymin == ymax
                    ylim(ax, [ymin-0.05*max(1,abs(ymin)), ymax+0.05*max(1,abs(ymax))]);
                end
            end
        end

        function runBatchStatistics(app)
            app.readParamsFromUI();
            M = app.Params.BatchRuns;
            originalSeed = app.Params.RandomSeed;
            originalSlot = app.Params.CurrentSlot;

            pdr = zeros(M, 1);
            col = zeros(M, 1);
            eng = zeros(M, 1);
            del = zeros(M, 1);
            tx = zeros(M, 1);
            barred = zeros(M, 1);

            oldButtonText = app.BatchButton.Text;
            app.BatchButton.Text = 'Running batch...';
            drawnow;

            for k = 1:M
                app.Params.RandomSeed = originalSeed + 7919*k;
                app.Params.CurrentSlot = originalSlot + k - 1;
                app.runSimulation();

                pdr(k) = app.SimResults.PDR;
                col(k) = app.SimResults.CollisionRate;
                eng(k) = app.SimResults.MeanEnergy_J;
                del(k) = app.SimResults.MeanDelay_s;
                tx(k) = app.SimResults.ActiveDevices;
                barred(k) = app.SimResults.AccessBarredCount;
                drawnow limitrate;
            end

            app.Params.RandomSeed = originalSeed;
            app.Params.CurrentSlot = originalSlot + M;
            app.BatchButton.Text = oldButtonText;

            app.BatchStatsText.Value = { ...
                'BATCH STATISTICS — MULTI-RAO MONTE CARLO SUMMARY'; ...
                '============================================================'; ...
                sprintf('Runs M                         : %d', M); ...
                sprintf('Traffic model                  : %s', char(app.Params.TrafficModel)); ...
                sprintf('Mobility model                 : %s', char(app.Params.MobilityModel)); ...
                sprintf('Access barring probability     : %.2f %%', 100*app.Params.AccessBarringProbability); ...
                sprintf('Backoff window                 : %d slots', app.Params.BackoffWindowSlots); ...
                ''; ...
                sprintf('Mean PDR                       : %.4f', app.meanFinite(pdr)); ...
                sprintf('Std PDR                        : %.4f', app.stdFinite(pdr)); ...
                sprintf('Mean collision rate            : %.4f', app.meanFinite(col)); ...
                sprintf('Mean delay                     : %.6f s', app.meanFinite(del)); ...
                sprintf('P95 delay                      : %.6f s', app.percentileLocal(del, 95)); ...
                sprintf('Mean energy per TX device      : %.6f J', app.meanFinite(eng)); ...
                sprintf('Mean TX devices per RAO        : %.2f', app.meanFinite(tx)); ...
                sprintf('Mean access-barred devices     : %.2f', app.meanFinite(barred)); ...
                ''; ...
                'Charts are updated from the latest RAO history.'};

            app.updateCharts();
            app.StatusLabel.Text = sprintf('Batch statistics completed: %d RAOs simulated and charts updated.', M);
        end

        function updateDashboard(app)
            r = app.SimResults;
            p = app.Params;

            if r.ActiveDevices <= 0
                approxCollisionTheory = 0;
            else
                approxCollisionTheory = 1 - (1 - 1/p.AccessResources)^(r.ActiveDevices - 1);
            end
            expectedSuccessPoisson = r.AverageActiveG * exp(-r.AverageActiveG / p.AccessResources);

            lines = { ...
                'CORE mMTC/mIoT METRICS'; ...
                '============================================================'; ...
                sprintf('Current slot / RAO                  : %d / %s', r.CurrentSlot, r.AccessOpportunity); ...
                sprintf('Simulation time                     : %.4f s', r.SimulationTime_s); ...
                sprintf('Logical total devices N             : %s', app.formatNumber(p.N)); ...
                'Allowed device range                 : 2 to 1,000 IoT devices'; ...
                sprintf('Rendered visible devices            : %s', app.formatNumber(numel(app.VisibleIdx))); ...
                sprintf('Area A                              : %.4f km^2', p.AreaKm2); ...
                sprintf('Connection density lambda_d = N/A   : %.2f devices/km^2', r.DeviceDensity); ...
                sprintf('IMT-2020 mMTC target reference      : 1,000,000 devices/km^2'); ...
                ''; ...
                'TRAFFIC AND RANDOM ACCESS'; ...
                '------------------------------------------------------------'; ...
                sprintf('Activity mode                       : %s', char(p.ActivityMode)); ...
                sprintf('Activation probability p_a          : %.6f', p.ActivationProbability); ...
                sprintf('Target awake ratio rho_awake        : %.2f %%', 100*p.TargetActiveRatio); ...
                sprintf('Tx prob. if awake p_tx|awake        : %.2f %%', 100*p.TxProbabilityGivenAwake); ...
                sprintf('Expected awake load G_wake          : %.3f devices/slot', r.AverageActiveG); ...
                sprintf('Actual awake devices in snapshot    : %d', r.AwakeDevices); ...
                sprintf('Actual awake ratio                  : %.2f %%', 100*r.AwakeRatio); ...
                sprintf('Actual transmitting devices         : %d', r.ActiveDevices); ...
                sprintf('Actual TX ratio                     : %.2f %%', 100*r.ActualActiveRatio); ...
                sprintf('Signal display mode                 : %s', char(r.SignalDisplayMode)); ...
                sprintf('Maximum visible TX rays             : %d', r.MaxVisibleTxRays); ...
                sprintf('Displayed RF rays in 3D scene       : %d', r.DisplayedTxRayCount); ...
                sprintf('Traffic model                       : %s', char(r.TrafficModel)); ...
                sprintf('Generated packets                   : %d', r.GeneratedPackets); ...
                sprintf('Access-barred packets               : %d', r.AccessBarredCount); ...
                sprintf('Access barring rate                 : %.2f %%', 100*r.AccessBarringRate); ...
                sprintf('Mean backoff delay                  : %.4f s', r.MeanBackoff_s); ...
                sprintf('Mean retry count                    : %.2f', r.MeanRetry); ...
                sprintf('Mobility model                      : %s', char(r.MobilityModel)); ...
                sprintf('URLLC vehicle speed                 : %.2f km/h', r.URLLCVehicleSpeed_kmh); ...
                'Animation rule                       : each RAO redraws TX rays from current transmitting IoT devices'; ...
                sprintf('Selected-info policy                : Auto-pick transmitting visible device if available'); ...
                sprintf('Access resources R                  : %d', p.AccessResources); ...
                sprintf('Collision count                     : %d', r.CollisionCount); ...
                sprintf('Measured collision rate             : %.2f %%', 100*r.CollisionRate); ...
                sprintf('Theory approx P_collision|K         : %.2f %%', 100*approxCollisionTheory); ...
                sprintf('Poisson expected success E[S]       : %.3f', expectedSuccessPoisson); ...
                ''; ...
                'DELIVERY, RADIO, ENERGY'; ...
                '------------------------------------------------------------'; ...
                sprintf('Access success probability          : %.2f %%', 100*r.AccessSuccessProbability); ...
                sprintf('Packet Delivery Ratio PDR           : %.2f %%', 100*r.PDR); ...
                sprintf('Mean SNR of active devices          : %.2f dB', r.MeanSNR_dB); ...
                sprintf('Mean SINR of active devices         : %.2f dB', r.MeanSINR_dB); ...
                sprintf('Mean interference of active devices : %.2f dBm', r.MeanInterference_dBm); ...
                sprintf('Mean packet error rate PER          : %.6f', r.MeanPER); ...
                sprintf('Mean delay                          : %.4f s', r.MeanDelay_s); ...
                sprintf('Mean energy per active device       : %.6f J', r.MeanEnergy_J); ...
                sprintf('Mean battery remaining              : %.4f %%', r.MeanBattery_pct); ...
                sprintf('Mean est. lifetime active devices   : %.2f days', r.MeanLifetime_days); ...
                sprintf('Payload efficiency eta_payload      : %.2f %%', 100*r.PayloadEfficiency); ...
                ''; ...
                'SERVICE-TYPE CONTEXT'; ...
                '------------------------------------------------------------'; ...
                sprintf('mMTC devices                         : %d', r.mMTCCount); ...
                sprintf('eMBB phone context devices           : %d', r.eMBBCount); ...
                sprintf('URLLC vehicle context devices        : %d', r.URLLCCount); ...
                sprintf('Delivered mMTC packets               : %d', r.mMTCDelivered); ...
                ''; ...
                'VISUAL LEGEND'; ...
                '------------------------------------------------------------'; ...
                'Gray: sleep | Blue: awake idle | Purple: access barred | Green: TX success | Red: TX collision | Yellow: TX link failed'; ...
                'RF ray rule: Sleep = no ray, Awake Idle = no ray, Transmitting = eligible RF ray'; ...
                'Displayed rays may be fewer than actual TX when Signal display mode = Limited TX rays'; ...
                'gNB -> MEC -> Cloud shows edge/core offloading path'};

            app.DashboardText.Value = lines;
        end

        function updateTheoryText(app)
            topic = app.TheoryList.Value;
            switch topic
                case '1. Tổng quan mMTC/mIoT'
                    lines = app.theoryOverview();
                case '2. Connection Density'
                    lines = app.theoryConnectionDensity();
                case '3. mMTC Traffic Model'
                    lines = app.theoryTraffic();
                case '4. Random Access & Collision'
                    lines = app.theoryRandomAccessCollision();
                case '5. Path Loss Model'
                    lines = app.theoryPathLoss();
                case '6. Received Power & SNR'
                    lines = app.theoryReceivedPowerSNR();
                case '7. Packet Delivery Ratio'
                    lines = app.theoryPDR();
                case '8. Energy & Battery Model'
                    lines = app.theoryEnergy();
                case '9. MEC / Edge Offloading'
                    lines = app.theoryMEC();
                case '10. Handover & Service Types'
                    lines = app.theoryHandover();
                otherwise
                    lines = app.theoryWhy5G();
            end
            app.TheoryText.Value = lines;
        end

        function lines = theoryOverview(~)
            lines = { ...
                'TỔNG QUAN mMTC/mIoT TRONG 5G'; ...
                '============================================================'; ...
                ''; ...
                'mMTC = massive Machine-Type Communications.'; ...
                'mIoT = massive Internet of Things.'; ...
                ''; ...
                'Bản chất:'; ...
                '- Không tập trung vào tốc độ rất cao như eMBB.'; ...
                '- Không tập trung cực mạnh vào độ trễ 1 ms như URLLC.'; ...
                '- Tập trung vào kết nối số lượng rất lớn thiết bị IoT công suất thấp.'; ...
                ''; ...
                'Đặc điểm kỹ thuật:'; ...
                '- Nhiều thiết bị cảm biến.'; ...
                '- Gói tin nhỏ.'; ...
                '- Truyền không liên tục.'; ...
                '- Chủ yếu uplink từ thiết bị lên gNB.'; ...
                '- Thiết bị cần tiết kiệm năng lượng.'; ...
                '- Random access dễ bị collision khi nhiều thiết bị active cùng lúc.'; ...
                ''; ...
                'Trong app 3D:'; ...
                '- mMTC là nhóm thiết bị nhiều nhất.'; ...
                '- eMBB phone và URLLC vehicle chỉ làm bối cảnh 5G.'; ...
                '- Công thức trọng tâm vẫn là density, random access, collision, PDR, energy.'};
        end

        function lines = theoryConnectionDensity(~)
            lines = { ...
                'CONNECTION DENSITY — MẬT ĐỘ KẾT NỐI'; ...
                '============================================================'; ...
                ''; ...
                'Khái niệm:'; ...
                'Connection density là số thiết bị được hỗ trợ trên một đơn vị diện tích.'; ...
                ''; ...
                'Công thức:'; ...
                'lambda_d = N / A'; ...
                ''; ...
                'Trong đó:'; ...
                'lambda_d : mật độ thiết bị, đơn vị devices/km^2'; ...
                'N        : tổng số thiết bị IoT'; ...
                'A        : diện tích vùng phủ, đơn vị km^2'; ...
                ''; ...
                'Mục tiêu tham chiếu của mMTC trong IMT-2020:'; ...
                'lambda_d = 1,000,000 devices/km^2'; ...
                ''; ...
                'Liên hệ mô phỏng:'; ...
                'Tăng N hoặc giảm A làm lambda_d tăng.'; ...
                'Khi lambda_d tăng, mạng có thể chịu tải truy nhập lớn hơn.'; ...
                'Nếu p_a không đổi, số thiết bị active trung bình cũng tăng theo N.'};
        end

        function lines = theoryTraffic(~)
            lines = { ...
                'mMTC TRAFFIC MODEL — MÔ HÌNH LƯU LƯỢNG'; ...
                '============================================================'; ...
                ''; ...
                'Thiết bị mMTC thường ngủ phần lớn thời gian để tiết kiệm năng lượng.'; ...
                'Khi có dữ liệu, thiết bị thức dậy và truy nhập mạng.'; ...
                ''; ...
                'Chu trình:'; ...
                'Sleep -> Wake-up -> Access Request -> Transmit Packet -> Sleep'; ...
                ''; ...
                'Mô hình số thiết bị active:'; ...
                'K(t) ~ Binomial(N, p_a) trong mode xác suất; K = round(N rho_active) trong mode Balanced/Custom'; ...
                ''; ...
                'Khi N lớn và p_a nhỏ:'; ...
                'K(t) ~ Poisson(G)'; ...
                'G = N p_a hoặc G = N rho_active tùy activity mode'; ...
                ''; ...
                'Trong đó:'; ...
                'K(t) : số thiết bị active tại khe thời gian t'; ...
                'N    : tổng số thiết bị'; ...
                'p_a  : xác suất thiết bị thức dậy để truyền'; ...
                'G    : tải truy nhập trung bình'; ...
                ''; ...
                'Liên hệ app:'; ...
                'Tăng N hoặc p_a sẽ tăng G.'; ...
                'G tăng quá lớn làm collision tăng.'};
        end

        function lines = theoryRandomAccessCollision(~)
            lines = { ...
                'RANDOM ACCESS & COLLISION'; ...
                '============================================================'; ...
                ''; ...
                'Vấn đề:'; ...
                'Nhiều thiết bị IoT có thể cùng chọn tài nguyên truy nhập giống nhau.'; ...
                'Khi đó xảy ra collision.'; ...
                ''; ...
                'Giả sử:'; ...
                'K : số thiết bị đang active'; ...
                'R : số tài nguyên truy nhập hoặc preamble'; ...
                ''; ...
                'Xác suất không va chạm của một thiết bị:'; ...
                'P_no-collision|K = (1 - 1/R)^(K-1)'; ...
                ''; ...
                'Xác suất va chạm:'; ...
                'P_collision|K = 1 - (1 - 1/R)^(K-1)'; ...
                ''; ...
                'Số truy nhập thành công kỳ vọng:'; ...
                'E[S|K] = K(1 - 1/R)^(K-1)'; ...
                ''; ...
                'Xấp xỉ Poisson:'; ...
                'E[S] = G exp(-G/R)'; ...
                ''; ...
                'Liên hệ 3D:'; ...
                'Thiết bị collision được đánh dấu đỏ.'; ...
                'Collision làm tăng retry, delay, và năng lượng.'};
        end

        function lines = theoryPathLoss(~)
            lines = { ...
                'PATH LOSS MODEL — SUY HAO ĐƯỜNG TRUYỀN'; ...
                '============================================================'; ...
                ''; ...
                'Path loss là suy giảm công suất tín hiệu theo khoảng cách và môi trường.'; ...
                ''; ...
                'Công thức:'; ...
                'PL(d_i) = PL0 + 10n log10(d_i/d0) + Xsigma + L_indoor'; ...
                ''; ...
                'Trong đó:'; ...
                'PL(d_i)   : suy hao từ thiết bị i đến gNB'; ...
                'PL0       : suy hao tại khoảng cách chuẩn d0'; ...
                'n         : hệ số suy hao môi trường'; ...
                'd_i       : khoảng cách thiết bị i đến gNB'; ...
                'd0        : khoảng cách chuẩn'; ...
                'Xsigma    : shadowing ngẫu nhiên'; ...
                'L_indoor  : suy hao trong nhà / xuyên tường'; ...
                ''; ...
                'Liên hệ 3D:'; ...
                'Thiết bị càng xa gNB thì d_i tăng, PL tăng.'; ...
                'PL tăng làm công suất thu và SNR giảm.'};
        end

        function lines = theoryReceivedPowerSNR(~)
            lines = { ...
                'RECEIVED POWER & SNR'; ...
                '============================================================'; ...
                ''; ...
                'Công suất thu:'; ...
                'P_r,i = P_t,i + G_t + G_r - PL(d_i)'; ...
                ''; ...
                'Trong đó:'; ...
                'P_r,i : công suất thu tại gNB từ thiết bị i'; ...
                'P_t,i : công suất phát của thiết bị i'; ...
                'G_t   : gain anten phát'; ...
                'G_r   : gain anten thu'; ...
                'PL    : suy hao đường truyền'; ...
                ''; ...
                'Nhiễu nhiệt ở dBm:'; ...
                'N_dBm = -174 + 10log10(B) + NF'; ...
                ''; ...
                'SNR ở dB:'; ...
                'SNR_dB = P_r,dBm - N_dBm'; ...
                ''; ...
                'Khi có nhiễu đồng tài nguyên, dùng SINR:'; ...
                'SINR = S / (I + N)'; ...
                ''; ...
                'Điều kiện link thành công trong bản nâng cấp:'; ...
                'SINR_dB >= gamma_th'; ...
                ''; ...
                'Liên hệ app:'; ...
                'Khi click thiết bị, app hiển thị PL, P_r, SNR, SINR, interference và trạng thái link.'};
        end

        function lines = theoryPDR(~)
            lines = { ...
                'PACKET DELIVERY RATIO — PDR'; ...
                '============================================================'; ...
                ''; ...
                'PDR đo tỉ lệ gói tin được giao thành công.'; ...
                ''; ...
                'Công thức:'; ...
                'PDR = N_delivered_packets / N_generated_packets'; ...
                ''; ...
                'Packet Outage Rate:'; ...
                'POR = 1 - PDR'; ...
                ''; ...
                'Điều kiện một packet thành công trong app:'; ...
                'Success = Active AND No-Collision AND SNR >= gamma_th'; ...
                ''; ...
                'Ý nghĩa:'; ...
                'Collision cao làm PDR giảm.'; ...
                'Path loss cao làm SNR giảm, PDR cũng giảm.'; ...
                'Retry có thể tăng xác suất thành công nhưng làm tăng delay và energy.'};
        end

        function lines = theoryEnergy(~)
            lines = { ...
                'ENERGY & BATTERY MODEL'; ...
                '============================================================'; ...
                ''; ...
                'Thiết bị mMTC thường dùng pin nhỏ nên năng lượng là tiêu chí quan trọng.'; ...
                ''; ...
                'Công thức năng lượng:'; ...
                'E_i = P_tx T_tx + P_rx T_rx + P_idle T_idle + P_sleep T_sleep'; ...
                ''; ...
                'Trong đó:'; ...
                'P_tx, P_rx, P_idle, P_sleep : công suất theo trạng thái'; ...
                'T_tx, T_rx, T_idle, T_sleep : thời gian ở từng trạng thái'; ...
                ''; ...
                'Năng lượng trên mỗi gói thành công:'; ...
                'E_packet = E_total / N_delivered_packets'; ...
                ''; ...
                'Tuổi thọ pin xấp xỉ:'; ...
                'T_battery = E_battery / E_day'; ...
                ''; ...
                'Liên hệ app:'; ...
                'Collision -> retry -> T_tx tăng -> energy tăng -> battery giảm nhanh.'};
        end

        function lines = theoryMEC(~)
            lines = { ...
                'MEC / EDGE OFFLOADING'; ...
                '============================================================'; ...
                ''; ...
                'MEC đưa máy chủ xử lý đến gần gNB để giảm đường truyền về Cloud xa.'; ...
                ''; ...
                'Luồng MEC:'; ...
                'IoT Device -> gNB -> MEC Server -> IoT Application'; ...
                ''; ...
                'Luồng Cloud:'; ...
                'IoT Device -> gNB -> 5G Core -> Cloud Server'; ...
                ''; ...
                'Tổng độ trễ:'; ...
                'T_total = T_access + T_tx + T_queue + T_core + T_processing'; ...
                ''; ...
                'Quyết định offloading trong app:'; ...
                'mMTC sensor thành công thường đưa về MEC.'; ...
                'eMBB phone context thường đưa lên Cloud/Core.'; ...
                'URLLC vehicle context ưu tiên MEC để giảm độ trễ.'};
        end

        function lines = theoryHandover(~)
            lines = { ...
                'HANDOVER & SERVICE TYPES'; ...
                '============================================================'; ...
                ''; ...
                '5G có ba nhóm dịch vụ lớn:'; ...
                '1. eMBB  : tốc độ cao, ví dụ smartphone, video, AR/VR.'; ...
                '2. URLLC : độ trễ thấp, tin cậy cao, ví dụ xe/robot.'; ...
                '3. mMTC  : số lượng thiết bị IoT cực lớn, gói nhỏ, pin yếu.'; ...
                ''; ...
                'Trong app:'; ...
                'mMTC là trọng tâm và là nhóm thiết bị nhiều nhất.'; ...
                'eMBB và URLLC chỉ xuất hiện để người học thấy bối cảnh 5G đầy đủ.'; ...
                ''; ...
                'Handover:'; ...
                'Handover là quá trình thiết bị chuyển kết nối giữa các cell/trạm.'; ...
                'Trong scene 3D, các đường cong biểu diễn bối cảnh mobility/handover.'};
        end

        function lines = theoryWhy5G(~)
            lines = { ...
                'VÌ SAO 5G MẠNH HƠN 4G Ở mMTC?'; ...
                '============================================================'; ...
                ''; ...
                '4G chủ yếu tối ưu cho smartphone và mobile broadband.'; ...
                '5G được thiết kế để phục vụ đồng thời eMBB, URLLC và mMTC.'; ...
                ''; ...
                'Ở mMTC, 5G mạnh hơn vì:'; ...
                '- Hỗ trợ mật độ kết nối rất lớn.'; ...
                '- Tối ưu cho thiết bị IoT gói nhỏ.'; ...
                '- Quan tâm đến truy nhập đồng thời và collision.'; ...
                '- Tối ưu năng lượng thiết bị.'; ...
                '- Hỗ trợ MEC/Edge để xử lý gần nguồn dữ liệu.'; ...
                '- Có thể kết hợp slicing/QoS cho dịch vụ IoT.'; ...
                ''; ...
                'Kết luận:'; ...
                'eMBB chứng minh 5G nhanh.'; ...
                'URLLC chứng minh 5G phản ứng nhanh và tin cậy.'; ...
                'mMTC chứng minh 5G mở rộng được tới mạng máy móc/cảm biến cực lớn.'};
        end

        %% DEVICE INTERPRETATION HELPERS
        function txt = accessInterpretation(~, T)
            if ~T.Awake
                txt = 'Device is sleeping, so it does not select any access resource and no RF ray is drawn.';
            elseif ismember('AccessBarred', T.Properties.VariableNames) && T.AccessBarred
                txt = 'Device generated access demand but was blocked by Access Class Barring, so it does not transmit Msg1/preamble and no RF ray is drawn.';
            elseif ~T.Active
                txt = 'Device is awake but idle: it is visible as a device marker, but it does not generate a packet or draw an RF ray in this slot.';
            elseif T.Collision
                txt = sprintf(['Device selected resource %d, but another transmitting device selected ', ...
                    'the same resource, so random-access collision occurs.'], T.Preamble);
            elseif T.Success
                txt = sprintf(['Device selected resource %d without collision and passed the SINR ', ...
                    'condition, so the packet is delivered.'], T.Preamble);
            else
                txt = sprintf(['Device selected resource %d without collision, but the packet is not ', ...
                    'delivered because the actual SINR condition failed.'], T.Preamble);
            end
        end

        function txt = radioInterpretation(~, T, p)
            if ~T.Awake
                txt = sprintf(['Device is sleeping. Potential SNR = %.2f dB and potential SINR = %.2f dB ', ...
                    'are calculated from position, but no packet is transmitted and no RF ray is drawn.'], T.SNR_dB, T.SINR_dB);
            elseif ismember('AccessBarred', T.Properties.VariableNames) && T.AccessBarred
                txt = sprintf(['Device is access-barred. Potential SNR = %.2f dB is available, ', ...
                    'but no preamble is transmitted, so actual SINR is not evaluated and no RF ray is drawn.'], T.SNR_dB);
            elseif ~T.Active
                txt = sprintf(['Device is awake but idle. Potential SNR = %.2f dB is available, ', ...
                    'but the device does not transmit in this slot, so no RF ray is drawn.'], T.SNR_dB);
            elseif T.SINR_dB >= p.SNRThreshold_dB
                txt = sprintf(['SINR = %.2f dB is greater than or equal to gamma_th = %.2f dB, ', ...
                    'therefore the active radio link is acceptable.'], T.SINR_dB, p.SNRThreshold_dB);
            else
                txt = sprintf(['SINR = %.2f dB is lower than gamma_th = %.2f dB, ', ...
                    'therefore the active radio link fails.'], T.SINR_dB, p.SNRThreshold_dB);
            end
        end

        function txt = energyInterpretation(~, T)
            if ~T.Awake
                txt = 'Device is sleeping, so only sleep-state energy is consumed.';
            elseif ismember('AccessBarred', T.Properties.VariableNames) && T.AccessBarred
                txt = 'Device is access-barred, so it consumes listening/control energy but no transmit energy.';
            elseif ~T.Active
                txt = 'Device is awake but idle, so it consumes idle/listening energy but no transmit energy.';
            elseif T.RetryCount > 0
                txt = sprintf(['Device requires %d retry attempt(s), so transmission time and ', ...
                    'energy consumption increase.'], T.RetryCount);
            else
                txt = 'Device transmits successfully without retry, so energy consumption is lower.';
            end
        end

        function txt = resourceText(~, T)
            if ~T.Awake
                txt = 'N/A, device is sleeping';
            elseif ismember('AccessBarred', T.Properties.VariableNames) && T.AccessBarred
                txt = 'N/A, access barred before preamble';
            elseif ~T.Active
                txt = 'N/A, awake idle - no packet generated';
            else
                txt = sprintf('%d', T.Preamble);
            end
        end

        function txt = dBmText(~, value_dBm, isActive)
            if ~isActive
                txt = 'N/A, no active uplink transmission';
            elseif value_dBm <= -149
                txt = 'approximately -Inf dBm';
            else
                txt = sprintf('%.2f dBm', value_dBm);
            end
        end

        function txt = sinrText(~, T)
            if ~T.Active
                txt = sprintf('N/A for actual TX; potential %.2f dB', T.SINR_dB);
            else
                txt = sprintf('%.2f dB', T.SINR_dB);
            end
        end

        function txt = actualRadioStatusText(app, T)
            if ~T.Awake
                txt = 'N/A, device is sleeping';
            elseif ~T.Active
                txt = 'N/A, awake idle - no packet generated';
            elseif T.ActualRadioOK
                txt = 'Pass';
            else
                txt = 'Fail';
            end
        end

        function txt = actualPERText(~, T)
            if ~T.Active
                txt = 'N/A, no packet generated';
            else
                txt = sprintf('%.6f', T.ActualPER);
            end
        end

        function txt = lifetimeText(~, days)
            if isinf(days) || days > 1e6
                txt = '> 1,000,000 days under current slot behavior';
            elseif days > 365
                txt = sprintf('%.2f days (%.2f years)', days, days/365);
            else
                txt = sprintf('%.2f days', days);
            end
        end

        %% UTILITY METHODS
        function value = safeDivide(~, a, b)
            if b == 0
                value = 0;
            else
                value = a / b;
            end
        end

        function value = meanIfAny(~, x)
            if isempty(x)
                value = 0;
            else
                value = mean(x, 'omitnan');
                if isnan(value)
                    value = 0;
                end
            end
        end

        function out = sampleVec(~, v, n)
            v = v(:);
            if isempty(v) || n <= 0
                out = zeros(0, 1);
                return;
            end
            n = min(n, numel(v));
            rp = randperm(numel(v), n);
            out = v(rp);
        end


        function m = meanFinite(~, x)
            x = x(isfinite(x));
            if isempty(x)
                m = 0;
            else
                m = mean(x);
            end
        end

        function s = stdFinite(~, x)
            x = x(isfinite(x));
            if numel(x) <= 1
                s = 0;
            else
                s = std(x);
            end
        end

        function q = percentileLocal(~, x, pct)
            x = x(isfinite(x));
            if isempty(x)
                q = NaN;
                return;
            end
            x = sort(x(:));
            idx = max(1, min(numel(x), ceil((pct/100) * numel(x))));
            q = x(idx);
        end

        function s = yesNo(~, flag)
            if logical(flag)
                s = 'Yes';
            else
                s = 'No';
            end
        end

        function txt = rfRayVisibilityText(app, T)
            mode = string(app.Params.SignalDisplayMode);
            if ~T.Awake
                txt = 'No - sleep state';
            elseif ~T.Active
                txt = 'No - awake idle, no packet generated';
            elseif mode == "Off"
                txt = 'No - signal display mode is Off';
            elseif mode == "Selected TX device only" && T.ID ~= app.SelectedDeviceID
                txt = 'No - only selected TX device is displayed';
            elseif mode == "Limited TX rays"
                txt = 'Eligible - shown if selected in displayed TX-ray subset';
            else
                txt = 'Yes - transmitting device is eligible for RF ray';
            end
        end

        function s = awakeText(~, flag)
            if logical(flag)
                s = 'Awake';
            else
                s = 'Sleep';
            end
        end

        function s = activeText(~, flag)
            if logical(flag)
                s = 'Transmitting';
            else
                s = 'No transmission';
            end
        end

        function s = formatNumber(~, n)
            s = regexprep(sprintf('%.0f', n), '(?<=\d)(?=(\d{3})+$)', ',');
        end
    end
end
