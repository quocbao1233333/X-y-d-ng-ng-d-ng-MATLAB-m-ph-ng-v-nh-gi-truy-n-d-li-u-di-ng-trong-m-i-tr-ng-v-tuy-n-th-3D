classdef MobileData3DWirelessApp_Pro < handle
    % MobileData3DWirelessApp
    % ------------------------------------------------------------
    % Programmatic MATLAB UI app for simulating a mobile digital-data
    % wireless link through a simplified 3D urban channel.
    %
    % Main design goals:
    %   1) Default-first: app opens with runnable default parameters.
    %   2) Each block has its own plots and evaluation table.
    %   3) The transmitter/receiver settings remain consistent:
    %      Block 2 <-> Block 9, Block 3 <-> Block 8.
    %
    % Run in MATLAB:
    %   app = MobileData3DWirelessApp;
    %
    % Notes:
    %   - This is an educational engineering MVP. It is designed to run
    %     without specialized toolboxes. Some advanced blocks such as
    %     ray tracing, LDPC, and Reed-Solomon are provided as simplified
    %     educational fallbacks. If you later want 3GPP/5G-grade models,
    %     replace MH6 with raytrace/siteviewer and coding blocks with
    %     Communications Toolbox objects.

    properties
        UIFigure
        MainGrid
        ControlPanel
        ControlTabGroup
        ControlTabs = struct()
        ControlGrid = struct()
        TabGroup
        Tabs = struct()
        Axes = struct()
        Tables = struct()
        Controls = struct()
        Last = struct()
    end

    methods
        function app = MobileData3DWirelessApp_Pro()
            app.buildUI();
            app.setDefaults();
            app.updateOrderOptions();
            app.runSimulation();
        end
    end

    methods (Access = private)
        %% ============================================================
        %  UI BUILDING
        % =============================================================
        function buildUI(app)
            app.UIFigure = uifigure('Name','MATLAB Mobile Data 3D Wireless Simulation App', ...
                'Position',[60 40 1600 900]);

            app.MainGrid = uigridlayout(app.UIFigure,[1 2]);
            app.MainGrid.ColumnWidth = {430,'1x'};
            app.MainGrid.RowHeight = {'1x'};
            app.MainGrid.Padding = [8 8 8 8];
            app.MainGrid.ColumnSpacing = 10;

            app.ControlPanel = uipanel(app.MainGrid,'Title','Simulation Controls');
            app.ControlPanel.Layout.Row = 1;
            app.ControlPanel.Layout.Column = 1;

            leftGrid = uigridlayout(app.ControlPanel,[2 1]);
            leftGrid.RowHeight = {40,'1x'};
            leftGrid.ColumnWidth = {'1x'};
            leftGrid.Padding = [8 8 8 8];
            leftGrid.RowSpacing = 8;

            hdr = uilabel(leftGrid, ...
                'Text','Default-first design: parameters are grouped by tabs. Press Run Simulation to execute immediately, then tune settings as needed.', ...
                'WordWrap','on', ...
                'FontSize',12, ...
                'FontColor',[0.25 0.25 0.25]);
            hdr.Layout.Row = 1; hdr.Layout.Column = 1;

            app.ControlTabGroup = uitabgroup(leftGrid);
            app.ControlTabGroup.Layout.Row = 2;
            app.ControlTabGroup.Layout.Column = 1;

            app.TabGroup = uitabgroup(app.MainGrid);
            app.TabGroup.Layout.Row = 1;
            app.TabGroup.Layout.Column = 2;

            app.buildControls();
            app.makeBlockTab('B1','Khối 1 - Input Data');
            app.makeBlockTab('B2','Khối 2 - Channel Coding');
            app.makeBlockTab('B3','Khối 3 - Digital Modulation');
            app.makeBlockTab('B4','Khối 4 - AM/FM/PM Demo');
            app.makeBlockTab('B5','Khối 5 - Baseband to RF');
            app.makeBlockTab('B6','Khối 6 - MH6 3D Wireless');
            app.makeBlockTab('B7','Khối 7 - Receiver Front-End');
            app.makeBlockTab('B8','Khối 8 - Digital Demodulation');
            app.makeBlockTab('B9','Khối 9 - Channel Decoding');
            app.makeBlockTab('B10','Khối 10 - Final Results');
        end

        function buildControls(app)
            % -------- Tab 1: General --------
            g = app.makeControlTab('General',8);
            r = 1;
            app.addSection(g,r,'GENERAL'); r = r + 1;
            app.addControlLabel(g,r,'Number of Bits');
            app.Controls.numBits = uieditfield(g,'numeric','Limits',[16 200000],'RoundFractionalValues','on');
            app.Controls.numBits.Layout.Row = r; app.Controls.numBits.Layout.Column = 2; r = r + 1;

            app.addControlLabel(g,r,'Bit Rate (Mbps)');
            app.Controls.bitRateMbps = uieditfield(g,'numeric','Limits',[0.001 1000]);
            app.Controls.bitRateMbps.Layout.Row = r; app.Controls.bitRateMbps.Layout.Column = 2; r = r + 1;

            tip = uilabel(g,'Text','The app opens with working defaults. Use this tab for the main simulation size and rate.', ...
                'WordWrap','on','FontAngle','italic','FontColor',[0.35 0.35 0.35]);
            tip.Layout.Row = [r r+1]; tip.Layout.Column = [1 2];

            % -------- Tab 2: Coding + Modulation --------
            g = app.makeControlTab('Coding + Mod',12);
            r = 1;
            app.addSection(g,r,'BLOCK 2 - CHANNEL CODING'); r = r + 1;
            app.addControlLabel(g,r,'Coding Type');
            app.Controls.coding = uidropdown(g,'Items',{'None','Hamming (7,4)','CRC-8','Convolutional (1/2)','Reed-Solomon (educational)','LDPC (educational)'});
            app.Controls.coding.Layout.Row = r; app.Controls.coding.Layout.Column = 2; r = r + 2;

            app.addSection(g,r,'BLOCK 3 - DIGITAL MODULATION'); r = r + 1;
            app.addControlLabel(g,r,'Modulation Type');
            app.Controls.modType = uidropdown(g,'Items',{'PSK','QAM','FSK','ASK','OFDM'});
            app.Controls.modType.Layout.Row = r; app.Controls.modType.Layout.Column = 2;
            app.Controls.modType.ValueChangedFcn = @(~,~)app.updateOrderOptions();
            r = r + 1;

            app.addControlLabel(g,r,'Modulation Order');
            app.Controls.modOrder = uidropdown(g,'Items',{'2','4','8','16','64','256'});
            app.Controls.modOrder.Layout.Row = r; app.Controls.modOrder.Layout.Column = 2; r = r + 1;

            tip = uilabel(g,'Text','Block 8 demodulation is linked automatically to this modulation choice.', ...
                'WordWrap','on','FontAngle','italic','FontColor',[0.35 0.35 0.35]);
            tip.Layout.Row = [r r+2]; tip.Layout.Column = [1 2];

            % -------- Tab 3: Analog Demo --------
            g = app.makeControlTab('Analog Demo',14);
            r = 1;
            app.addSection(g,r,'BLOCK 4 - ANALOG DEMO'); r = r + 1;
            app.addControlLabel(g,r,'Analog Type');
            app.Controls.analogType = uidropdown(g,'Items',{'AM','FM','PM'});
            app.Controls.analogType.Layout.Row = r; app.Controls.analogType.Layout.Column = 2; r = r + 1;

            app.addControlLabel(g,r,'fc Analog (kHz)');
            app.Controls.analogFcKHz = uieditfield(g,'numeric','Limits',[0.1 10000]);
            app.Controls.analogFcKHz.Layout.Row = r; app.Controls.analogFcKHz.Layout.Column = 2; r = r + 1;

            app.addControlLabel(g,r,'fm Analog (Hz)');
            app.Controls.analogFmHz = uieditfield(g,'numeric','Limits',[0.1 100000]);
            app.Controls.analogFmHz.Layout.Row = r; app.Controls.analogFmHz.Layout.Column = 2; r = r + 1;

            app.addControlLabel(g,r,'AM index μ');
            app.Controls.amIndex = uieditfield(g,'numeric','Limits',[0 2]);
            app.Controls.amIndex.Layout.Row = r; app.Controls.amIndex.Layout.Column = 2; r = r + 1;

            app.addControlLabel(g,r,'FM index β');
            app.Controls.fmIndex = uieditfield(g,'numeric','Limits',[0 20]);
            app.Controls.fmIndex.Layout.Row = r; app.Controls.fmIndex.Layout.Column = 2; r = r + 1;

            app.addControlLabel(g,r,'PM kp (rad)');
            app.Controls.pmKp = uieditfield(g,'numeric','Limits',[0 2*pi]);
            app.Controls.pmKp.Layout.Row = r; app.Controls.pmKp.Layout.Column = 2; r = r + 1;

            % -------- Tab 4: RF + 3D Channel --------
            g = app.makeControlTab('RF + 3D',34);
            r = 1;
            app.addSection(g,r,'BLOCK 5/6 - RF + 3D CHANNEL'); r = r + 1;
            app.addControlLabel(g,r,'Carrier fc (GHz)');
            app.Controls.fcGHz = uieditfield(g,'numeric','Limits',[0.1 100]);
            app.Controls.fcGHz.Layout.Row = r; app.Controls.fcGHz.Layout.Column = 2; r = r + 1;

            app.addControlLabel(g,r,'Bandwidth B (MHz)');
            app.Controls.bwMHz = uieditfield(g,'numeric','Limits',[0.001 1000]);
            app.Controls.bwMHz.Layout.Row = r; app.Controls.bwMHz.Layout.Column = 2; r = r + 1;

            app.addControlLabel(g,r,'Tx Power (dBm)');
            app.Controls.txPower = uieditfield(g,'numeric','Limits',[-40 60]);
            app.Controls.txPower.Layout.Row = r; app.Controls.txPower.Layout.Column = 2; r = r + 1;

            app.addControlLabel(g,r,'Tx Gain (dBi)');
            app.Controls.txGain = uieditfield(g,'numeric','Limits',[-20 40]);
            app.Controls.txGain.Layout.Row = r; app.Controls.txGain.Layout.Column = 2; r = r + 1;

            app.addControlLabel(g,r,'Rx Gain (dBi)');
            app.Controls.rxGain = uieditfield(g,'numeric','Limits',[-20 40]);
            app.Controls.rxGain.Layout.Row = r; app.Controls.rxGain.Layout.Column = 2; r = r + 1;

            app.addControlLabel(g,r,'Interference On');
            app.Controls.interferenceOn = uicheckbox(g,'Text','Enable');
            app.Controls.interferenceOn.Layout.Row = r; app.Controls.interferenceOn.Layout.Column = 2; r = r + 1;

            app.addControlLabel(g,r,'Interference (dBm)');
            app.Controls.interferencePower = uieditfield(g,'numeric','Limits',[-140 0]);
            app.Controls.interferencePower.Layout.Row = r; app.Controls.interferencePower.Layout.Column = 2; r = r + 1;

            app.addControlLabel(g,r,'Wireless Mode');
            app.Controls.envMode = uidropdown(g,'Items',{'SISO','MIMO','MIMO + Beamforming'});
            app.Controls.envMode.Layout.Row = r; app.Controls.envMode.Layout.Column = 2; r = r + 1;

            app.addControlLabel(g,r,'Nt / Nr');
            app.Controls.ntnr = uidropdown(g,'Items',{'1x1','2x2','4x2','4x4','8x4'});
            app.Controls.ntnr.Layout.Row = r; app.Controls.ntnr.Layout.Column = 2; r = r + 1;

            app.addControlLabel(g,r,'Beam azimuth (deg)');
            app.Controls.beamAngle = uieditfield(g,'numeric','Limits',[-180 180]);
            app.Controls.beamAngle.Layout.Row = r; app.Controls.beamAngle.Layout.Column = 2; r = r + 1;

            app.addControlLabel(g,r,'Beam elevation (deg)');
            app.Controls.beamElevation = uieditfield(g,'numeric','Limits',[-45 90]);
            app.Controls.beamElevation.Layout.Row = r; app.Controls.beamElevation.Layout.Column = 2; r = r + 1;

            app.addControlLabel(g,r,'Scene Preset');
            app.Controls.scenePreset = uidropdown(g,'Items',{'Small','Medium','Large','Custom'});
            app.Controls.scenePreset.Layout.Row = r; app.Controls.scenePreset.Layout.Column = 2; r = r + 1;

            app.addControlLabel(g,r,'Space X (m)');
            app.Controls.sceneX = uieditfield(g,'numeric','Limits',[100 5000]);
            app.Controls.sceneX.Layout.Row = r; app.Controls.sceneX.Layout.Column = 2; r = r + 1;

            app.addControlLabel(g,r,'Space Y (m)');
            app.Controls.sceneY = uieditfield(g,'numeric','Limits',[100 5000]);
            app.Controls.sceneY.Layout.Row = r; app.Controls.sceneY.Layout.Column = 2; r = r + 1;

            app.addControlLabel(g,r,'Space Z (m)');
            app.Controls.sceneZ = uieditfield(g,'numeric','Limits',[30 1000]);
            app.Controls.sceneZ.Layout.Row = r; app.Controls.sceneZ.Layout.Column = 2; r = r + 1;

            app.addControlLabel(g,r,'Building Density');
            app.Controls.buildingDensity = uidropdown(g,'Items',{'Sparse','Medium','Dense'});
            app.Controls.buildingDensity.Layout.Row = r; app.Controls.buildingDensity.Layout.Column = 2; r = r + 1;

            app.addControlLabel(g,r,'Number of Buildings');
            app.Controls.buildingCount = uieditfield(g,'numeric','Limits',[1 30],'RoundFractionalValues','on');
            app.Controls.buildingCount.Layout.Row = r; app.Controls.buildingCount.Layout.Column = 2; r = r + 1;

            app.addControlLabel(g,r,'Randomize Buildings');
            app.Controls.randomizeBuildings = uicheckbox(g,'Text','Each Run');
            app.Controls.randomizeBuildings.Layout.Row = r; app.Controls.randomizeBuildings.Layout.Column = 2; r = r + 1;

            app.addControlLabel(g,r,'Layout Seed');
            app.Controls.layoutSeed = uieditfield(g,'numeric','Limits',[1 2147483647], ...
                'RoundFractionalValues','on');
            app.Controls.layoutSeed.Layout.Row = r; app.Controls.layoutSeed.Layout.Column = 2; r = r + 1;

            app.addControlLabel(g,r,'MH6 View');
            app.Controls.mh6View = uidropdown(g,'Items',{'Coverage Map','Beam Pattern 3D','Multipath PDP'});
            app.Controls.mh6View.Layout.Row = r; app.Controls.mh6View.Layout.Column = 2; r = r + 1;

            app.addControlLabel(g,r,'Show Ray Paths');
            app.Controls.showRayPaths = uicheckbox(g,'Text','On');
            app.Controls.showRayPaths.Layout.Row = r; app.Controls.showRayPaths.Layout.Column = 2; r = r + 1;

            app.addControlLabel(g,r,'Show Beam Pattern');
            app.Controls.showBeamPattern = uicheckbox(g,'Text','On');
            app.Controls.showBeamPattern.Layout.Row = r; app.Controls.showBeamPattern.Layout.Column = 2; r = r + 1;

            % -------- Tab 5: Receiver + Run --------
            g = app.makeControlTab('Receiver + Run',14);
            r = 1;
            app.addSection(g,r,'BLOCK 7 - RECEIVER FRONT-END'); r = r + 1;
            app.addControlLabel(g,r,'Noise Figure (dB)');
            app.Controls.noiseFigure = uieditfield(g,'numeric','Limits',[0 30]);
            app.Controls.noiseFigure.Layout.Row = r; app.Controls.noiseFigure.Layout.Column = 2; r = r + 1;

            app.addControlLabel(g,r,'LNA Gain (dB)');
            app.Controls.lnaGain = uieditfield(g,'numeric','Limits',[0 60]);
            app.Controls.lnaGain.Layout.Row = r; app.Controls.lnaGain.Layout.Column = 2; r = r + 1;

            app.addControlLabel(g,r,'AGC');
            app.Controls.agcOn = uicheckbox(g,'Text','On');
            app.Controls.agcOn.Layout.Row = r; app.Controls.agcOn.Layout.Column = 2; r = r + 1;

            app.addControlLabel(g,r,'ADC Bits');
            app.Controls.adcBits = uidropdown(g,'Items',{'8','10','12','14','16'});
            app.Controls.adcBits.Layout.Row = r; app.Controls.adcBits.Layout.Column = 2; r = r + 2;

            app.addSection(g,r,'RUN'); r = r + 1;
            app.Controls.runButton = uibutton(g,'push','Text','Run Simulation', ...
                'ButtonPushedFcn',@(~,~)app.runSimulation());
            app.Controls.runButton.Layout.Row = r; app.Controls.runButton.Layout.Column = [1 2]; r = r + 1;

            app.Controls.resetButton = uibutton(g,'push','Text','Reset Defaults', ...
                'ButtonPushedFcn',@(~,~)app.resetAndRun());
            app.Controls.resetButton.Layout.Row = r; app.Controls.resetButton.Layout.Column = [1 2]; r = r + 1;

            infoLbl = uilabel(g,'Text','Layout improved: controls are separated into tabs so nothing is cut off.', ...
                'WordWrap','on','FontAngle','italic','FontColor',[0.35 0.35 0.35]);
            infoLbl.Layout.Row = [r r+2]; infoLbl.Layout.Column = [1 2];
        end

        function addSection(app,parent,row,text)
            lab = uilabel(parent,'Text',text,'FontWeight','bold','FontColor',[0.1 0.25 0.55], ...
                'FontSize',14);
            lab.Layout.Row = row; lab.Layout.Column = [1 2];
        end

        function addControlLabel(app,parent,row,text)
            lab = uilabel(parent,'Text',text);
            lab.Layout.Row = row; lab.Layout.Column = 1;
        end

        function grid = makeControlTab(app,titleText,nRows)
            % Create a scrollable control tab. This fixes the RF + 3D issue
            % where additional controls were clipped at the bottom of the
            % left Simulation Controls panel.
            tab = uitab(app.ControlTabGroup,'Title',titleText);
            grid = uigridlayout(tab,[nRows 2]);
            grid.RowHeight = repmat({30},1,nRows);
            grid.ColumnWidth = {160,'1x'};
            grid.Padding = [12 12 12 12];
            grid.RowSpacing = 8;
            grid.ColumnSpacing = 10;

            % Newer MATLAB versions support scrollable grid layouts.
            % The try/catch keeps the app compatible with older releases.
            try
                grid.Scrollable = 'on';
            catch
                % Fallback: tab still works; use a larger window if the MATLAB
                % release does not support scrollable grid layouts.
            end

            app.ControlTabs.(matlab.lang.makeValidName(titleText)) = tab;
            app.ControlGrid.(matlab.lang.makeValidName(titleText)) = grid;
        end

        function makeBlockTab(app,key,titleText)
            tab = uitab(app.TabGroup,'Title',titleText);

            if strcmp(key,'B6')
                % Block 6 is the core 3D wireless environment, so it uses
                % one large 3D viewer instead of two side-by-side plots.
                gl = uigridlayout(tab,[2 1]);
                gl.RowHeight = {'1x',210};
                gl.ColumnWidth = {'1x'};
                gl.Padding = [8 8 8 8];

                ax1 = uiaxes(gl); ax1.Layout.Row = 1; ax1.Layout.Column = 1;
                tbl = uitable(gl); tbl.Layout.Row = 2; tbl.Layout.Column = 1;
                tbl.ColumnName = {'Parameter','Value','Meaning / Note'};
                tbl.ColumnWidth = {220,180,'auto'};

                app.Tabs.(key) = tab;
                app.Axes.(key) = struct('a1',ax1,'a2',[]);
                app.Tables.(key) = tbl;
                return;
            end

            gl = uigridlayout(tab,[2 2]);
            gl.RowHeight = {'1x',190};
            gl.ColumnWidth = {'1x','1x'};
            gl.Padding = [8 8 8 8];

            ax1 = uiaxes(gl); ax1.Layout.Row = 1; ax1.Layout.Column = 1;
            ax2 = uiaxes(gl); ax2.Layout.Row = 1; ax2.Layout.Column = 2;
            tbl = uitable(gl); tbl.Layout.Row = 2; tbl.Layout.Column = [1 2];
            tbl.ColumnName = {'Parameter','Value','Meaning / Note'};
            tbl.ColumnWidth = {220,180,'auto'};

            app.Tabs.(key) = tab;
            app.Axes.(key) = struct('a1',ax1,'a2',ax2);
            app.Tables.(key) = tbl;
        end

        function setDefaults(app)
            app.Controls.numBits.Value = 1000;
            app.Controls.bitRateMbps.Value = 1;
            app.Controls.coding.Value = 'Hamming (7,4)';

            app.Controls.modType.Value = 'PSK';
            app.Controls.modOrder.Value = '4';

            app.Controls.analogType.Value = 'AM';
            app.Controls.analogFcKHz.Value = 10;
            app.Controls.analogFmHz.Value = 100;
            app.Controls.amIndex.Value = 0.5;
            app.Controls.fmIndex.Value = 5;
            app.Controls.pmKp.Value = pi/2;

            app.Controls.fcGHz.Value = 3.5;
            app.Controls.bwMHz.Value = 20;
            app.Controls.txPower.Value = 30;
            app.Controls.txGain.Value = 3;
            app.Controls.rxGain.Value = 0;
            app.Controls.interferenceOn.Value = true;
            app.Controls.interferencePower.Value = -105;
            app.Controls.envMode.Value = 'MIMO + Beamforming';
            app.Controls.ntnr.Value = '4x4';
            app.Controls.beamAngle.Value = 25;
            app.Controls.beamElevation.Value = 8;
            app.Controls.scenePreset.Value = 'Medium';
            app.Controls.sceneX.Value = 600;
            app.Controls.sceneY.Value = 600;
            app.Controls.sceneZ.Value = 140;
            app.Controls.buildingDensity.Value = 'Medium';
            app.Controls.buildingCount.Value = 8;
            app.Controls.randomizeBuildings.Value = true;
            app.Controls.layoutSeed.Value = 2026;
            app.Controls.mh6View.Value = 'Coverage Map';
            app.Controls.showRayPaths.Value = true;
            app.Controls.showBeamPattern.Value = true;

            app.Controls.noiseFigure.Value = 7;
            app.Controls.lnaGain.Value = 20;
            app.Controls.agcOn.Value = true;
            app.Controls.adcBits.Value = '12';
        end

        function resetAndRun(app)
            app.setDefaults();
            app.updateOrderOptions();
            app.runSimulation();
        end

        function updateOrderOptions(app)
            type = string(app.Controls.modType.Value);
            switch type
                case "PSK"
                    items = {'2','4','8'};
                    if ~ismember(app.Controls.modOrder.Value,items), app.Controls.modOrder.Value = '4'; end
                case "QAM"
                    items = {'4','16','64','256'};
                    if ~ismember(app.Controls.modOrder.Value,items), app.Controls.modOrder.Value = '16'; end
                case "FSK"
                    items = {'2','4','8'};
                    if ~ismember(app.Controls.modOrder.Value,items), app.Controls.modOrder.Value = '2'; end
                case "ASK"
                    items = {'2','4'};
                    if ~ismember(app.Controls.modOrder.Value,items), app.Controls.modOrder.Value = '2'; end
                case "OFDM"
                    items = {'4','16','64','256'};
                    if ~ismember(app.Controls.modOrder.Value,items), app.Controls.modOrder.Value = '16'; end
                otherwise
                    items = {'2','4','8','16','64','256'};
            end
            app.Controls.modOrder.Items = items;
        end

        %% ============================================================
        %  MAIN SIMULATION
        % =============================================================
        function runSimulation(app)
            try
                cfg = app.readConfig();
                rng(12);

                % Block 1
                bits = randi([0 1],cfg.numBits,1);

                % Block 2
                [codedBits,codingInfo] = app.channelEncode(bits,cfg);

                % Block 3
                [tx,modInfo] = app.digitalModulate(codedBits,cfg);

                % Block 5
                [rf,rfInfo] = app.basebandToRF(tx,cfg,modInfo);

                % Block 6
                [channelOut,channelInfo] = app.apply3DWirelessChannel(rf.baseband,cfg);

                % Block 7
                [rx,rxInfo] = app.receiverFrontend(channelOut,cfg,channelInfo);

                % Block 8
                [demodBits,demodInfo] = app.digitalDemodulate(rx.samples,cfg,modInfo,numel(codedBits),channelInfo);

                % Block 9
                [recoveredBits,decInfo] = app.channelDecode(demodBits,cfg,codingInfo,numel(bits));

                % Block 10
                resultInfo = app.evaluateResults(bits,recoveredBits,cfg,codingInfo,modInfo,channelInfo,rxInfo,demodInfo,decInfo);

                % Analog demo block
                analogInfo = app.analogDemo(cfg);

                % Store
                app.Last = struct('cfg',cfg,'bits',bits,'codedBits',codedBits,'tx',tx,'modInfo',modInfo, ...
                    'rf',rf,'rfInfo',rfInfo,'channelOut',channelOut,'channelInfo',channelInfo, ...
                    'rx',rx,'rxInfo',rxInfo,'demodBits',demodBits,'demodInfo',demodInfo, ...
                    'recoveredBits',recoveredBits,'decInfo',decInfo,'resultInfo',resultInfo, ...
                    'analogInfo',analogInfo);

                % Visualize all blocks
                app.plotBlock1(bits,cfg);
                app.plotBlock2(bits,codedBits,codingInfo);
                app.plotBlock3(tx,modInfo);
                app.plotBlock4(analogInfo);
                app.plotBlock5(rf,rfInfo,cfg);
                app.plotBlock6(channelInfo,cfg);
                app.plotBlock7(rx,rxInfo,cfg);
                app.plotBlock8(rx,demodInfo,modInfo);
                app.plotBlock9(demodBits,recoveredBits,decInfo);
                app.plotBlock10(bits,recoveredBits,resultInfo);

            catch ME
                uialert(app.UIFigure,ME.message,'Simulation Error');
                rethrow(ME);
            end
        end

        function cfg = readConfig(app)
            cfg.numBits = round(app.Controls.numBits.Value);
            cfg.bitRate = app.Controls.bitRateMbps.Value * 1e6;
            cfg.codingType = string(app.Controls.coding.Value);

            cfg.modType = string(app.Controls.modType.Value);
            cfg.modOrder = str2double(string(app.Controls.modOrder.Value));

            cfg.analogType = string(app.Controls.analogType.Value);
            cfg.analogFc = app.Controls.analogFcKHz.Value * 1e3;
            cfg.analogFm = app.Controls.analogFmHz.Value;
            cfg.amIndex = app.Controls.amIndex.Value;
            cfg.fmIndex = app.Controls.fmIndex.Value;
            cfg.pmKp = app.Controls.pmKp.Value;

            cfg.fc = app.Controls.fcGHz.Value * 1e9;
            cfg.bw = app.Controls.bwMHz.Value * 1e6;
            cfg.txPowerdBm = app.Controls.txPower.Value;
            cfg.txGaindBi = app.Controls.txGain.Value;
            cfg.rxGaindBi = app.Controls.rxGain.Value;
            cfg.interferenceOn = app.Controls.interferenceOn.Value;
            cfg.interferencePowerdBm = app.Controls.interferencePower.Value;
            cfg.envMode = string(app.Controls.envMode.Value);
            cfg.ntnr = string(app.Controls.ntnr.Value);
            cfg.beamAngleDeg = app.Controls.beamAngle.Value;
            cfg.beamElevationDeg = app.Controls.beamElevation.Value;
            cfg.scenePreset = string(app.Controls.scenePreset.Value);
            cfg.sceneX = app.Controls.sceneX.Value;
            cfg.sceneY = app.Controls.sceneY.Value;
            cfg.sceneZ = app.Controls.sceneZ.Value;
            cfg.buildingDensity = string(app.Controls.buildingDensity.Value);
            cfg.buildingCount = round(app.Controls.buildingCount.Value);
            cfg.randomizeBuildings = app.Controls.randomizeBuildings.Value;
            cfg.layoutSeed = round(app.Controls.layoutSeed.Value);
            if cfg.randomizeBuildings
                % Use wall-clock time so every Run Simulation generates a
                % new urban layout while keeping all other app features intact.
                cfg.layoutSeed = mod(round(now*86400*1000),2147483646) + 1;
            end
            cfg.mh6View = string(app.Controls.mh6View.Value);
            cfg.showRayPaths = app.Controls.showRayPaths.Value;
            cfg.showBeamPattern = app.Controls.showBeamPattern.Value;

            cfg.noiseFigure = app.Controls.noiseFigure.Value;
            cfg.lnaGain = app.Controls.lnaGain.Value;
            cfg.agcOn = app.Controls.agcOn.Value;
            cfg.adcBits = str2double(string(app.Controls.adcBits.Value));

            cfg.samplesPerSymbol = 8;
            cfg.fs = max(4*cfg.bw, cfg.samplesPerSymbol*cfg.bitRate);
            cfg.c = 3e8;
            cfg.lambda = cfg.c / cfg.fc;

            cfg.txPos = [0.08*cfg.sceneX 0.10*cfg.sceneY 25];
            cfg.rxPos = [0.78*cfg.sceneX 0.56*cfg.sceneY 1.5];
            cfg.defaultBuildings = app.defaultBuildings(cfg);
        end

        %% ============================================================
        %  BLOCK 2: CHANNEL CODING
        % =============================================================
        function [coded,info] = channelEncode(app,bits,cfg)
            type = cfg.codingType;
            info = struct('type',type,'pad',0,'note',"",'status',"OK",'codeRate',1,'blockLength',NaN);

            switch type
                case "None"
                    coded = bits(:);
                    info.note = "No channel coding; bits pass through.";

                case "Hamming (7,4)"
                    [coded,pad] = app.hamming74Encode(bits(:));
                    info.pad = pad;
                    info.codeRate = 4/7;
                    info.blockLength = 7;
                    info.note = "Hamming(7,4): 4 data bits -> 7 coded bits; corrects 1 bit/block.";

                case "CRC-8"
                    poly = [1 0 0 0 0 0 1 1 1]; % x^8 + x^2 + x + 1
                    crc = app.crcRemainder(bits(:),poly);
                    coded = [bits(:); crc(:)];
                    info.poly = poly;
                    info.codeRate = numel(bits)/numel(coded);
                    info.blockLength = numel(coded);
                    info.note = "CRC-8: error detection only, not correction.";

                case "Convolutional (1/2)"
                    [coded,pad] = app.convEncode12(bits(:));
                    info.pad = pad;
                    info.codeRate = 1/2;
                    info.blockLength = 2;
                    info.note = "Rate-1/2 convolutional code, K=3, generators [111,101].";

                case "Reed-Solomon (educational)"
                    [coded,meta] = app.educationalRSEncode(bits(:));
                    info.meta = meta;
                    info.codeRate = meta.k/meta.n;
                    info.blockLength = meta.n;
                    info.note = "Educational RS-like block parity fallback for app demonstration.";

                case "LDPC (educational)"
                    [coded,meta] = app.educationalLDPCEncode(bits(:));
                    info.meta = meta;
                    info.codeRate = meta.k/meta.n;
                    info.blockLength = meta.n;
                    info.note = "Educational LDPC-like parity-check fallback for app demonstration.";

                otherwise
                    coded = bits(:);
                    info.note = "Unknown coding type; pass-through.";
            end
        end

        function [decoded,info] = channelDecode(app,demodBits,cfg,codingInfo,originalLen)
            type = codingInfo.type;
            info = struct('type',type,'detectedErrors',0,'correctedErrors',0,'status',"OK",'note',"");

            switch type
                case "None"
                    decoded = demodBits(:);
                    info.note = "No decoder applied.";

                case "Hamming (7,4)"
                    [decoded,corrCnt,uncorrCnt] = app.hamming74Decode(demodBits(:));
                    decoded = decoded(1:min(originalLen,numel(decoded)));
                    info.detectedErrors = corrCnt + uncorrCnt;
                    info.correctedErrors = corrCnt;
                    if uncorrCnt > 0
                        info.status = "Partial Success";
                    else
                        info.status = "Success";
                    end
                    info.note = "Syndrome decoding, single-bit correction per 7-bit block.";

                case "CRC-8"
                    poly = codingInfo.poly;
                    if numel(demodBits) < 8
                        decoded = demodBits(:);
                        info.status = "Failed";
                        info.note = "Not enough bits for CRC.";
                    else
                        data = demodBits(1:end-8);
                        remainder = app.crcRemainder(demodBits(:),poly);
                        decoded = data(:);
                        info.crcRemainder = remainder;
                        if any(remainder)
                            info.detectedErrors = 1;
                            info.status = "CRC Fail";
                            info.note = "Packet error detected. CRC does not correct errors.";
                        else
                            info.status = "CRC Pass";
                            info.note = "CRC check passed.";
                        end
                    end
                    decoded = decoded(1:min(originalLen,numel(decoded)));

                case "Convolutional (1/2)"
                    decoded = app.viterbiDecode12(demodBits(:));
                    decoded = decoded(1:min(originalLen,numel(decoded)));
                    info.status = "Success";
                    info.note = "Hard-decision Viterbi decoding.";

                case "Reed-Solomon (educational)"
                    [decoded,meta] = app.educationalRSDecode(demodBits(:),codingInfo.meta);
                    decoded = decoded(1:min(originalLen,numel(decoded)));
                    info.detectedErrors = meta.detectedBlocks;
                    info.correctedErrors = meta.correctedBlocks;
                    info.status = meta.status;
                    info.note = "Educational RS-like fallback decoder.";

                case "LDPC (educational)"
                    [decoded,meta] = app.educationalLDPCDecode(demodBits(:),codingInfo.meta);
                    decoded = decoded(1:min(originalLen,numel(decoded)));
                    info.detectedErrors = meta.unsatisfiedChecks;
                    info.correctedErrors = meta.correctedBits;
                    info.status = meta.status;
                    info.note = "Educational LDPC-like fallback decoder.";

                otherwise
                    decoded = demodBits(:);
                    info.note = "Unknown decoder; pass-through.";
            end
        end

        %% ============================================================
        %  BLOCK 3/8: DIGITAL MODULATION + DEMODULATION
        % =============================================================
        function [tx,info] = digitalModulate(app,bits,cfg)
            type = cfg.modType;
            M = cfg.modOrder;
            k = log2(M);
            info = struct('type',type,'M',M,'bitsPerSymbol',k,'pad',0,'scheme',"",'constellation',[],'symbolIndices',[]);
            tx = struct('bitsIn',bits(:),'symbols',[],'waveformBB',[],'isWaveform',false);

            switch type
                case "PSK"
                    if M == 2
                        info.scheme = "BPSK";
                        const = [1; -1];
                    else
                        info.scheme = sprintf("%d-PSK",M);
                        const = exp(1j*(2*pi*(0:M-1)'/M + pi/M));
                    end
                    [idx,pad] = app.bitsToIntegers(bits(:),k);
                    info.pad = pad; info.constellation = const; info.symbolIndices = idx;
                    tx.symbols = const(idx+1);

                case "QAM"
                    info.scheme = sprintf("%d-QAM",M);
                    const = app.qamConstellation(M);
                    [idx,pad] = app.bitsToIntegers(bits(:),k);
                    info.pad = pad; info.constellation = const; info.symbolIndices = idx;
                    tx.symbols = const(idx+1);

                case "ASK"
                    info.scheme = sprintf("%d-ASK / OOK",M);
                    levels = (0:M-1)';
                    levels = levels - mean(levels);
                    if max(abs(levels)) > 0, levels = levels / rms(levels); end
                    const = complex(levels,0);
                    [idx,pad] = app.bitsToIntegers(bits(:),k);
                    info.pad = pad; info.constellation = const; info.symbolIndices = idx;
                    tx.symbols = const(idx+1);

                case "FSK"
                    info.scheme = sprintf("%d-FSK",M);
                    [idx,pad] = app.bitsToIntegers(bits(:),k);
                    info.pad = pad; info.symbolIndices = idx;
                    info.tones = 0:M-1;
                    tx.symbols = exp(1j*2*pi*idx/M);
                    tx.waveformBB = app.fskWaveform(idx,M,cfg.samplesPerSymbol);
                    tx.isWaveform = true;

                case "OFDM"
                    info.scheme = sprintf("OFDM-%dQAM",M);
                    if M == 4
                        subConst = app.qpskConstellation();
                    else
                        subConst = app.qamConstellation(M);
                    end
                    [idx,pad] = app.bitsToIntegers(bits(:),k);
                    info.pad = pad; info.constellation = subConst; info.symbolIndices = idx;
                    subSymbols = subConst(idx+1);
                    info.nfft = 64;
                    info.cpLen = 16;
                    [tx.waveformBB,info.ofdmFrames] = app.ofdmModulate(subSymbols,info.nfft,info.cpLen);
                    tx.symbols = subSymbols;
                    tx.isWaveform = true;

                otherwise
                    error('Unsupported modulation type.');
            end
        end

        function [bitsOut,info] = digitalDemodulate(app,rxSamples,cfg,modInfo,codedLen,channelInfo)
            type = modInfo.type;
            M = modInfo.M;
            k = modInfo.bitsPerSymbol;
            info = struct('type',type,'scheme',modInfo.scheme,'decisionMode',"Hard",'evm',NaN, ...
                'rxSymbols',[],'decidedSymbols',[],'symbolErrorsEst',NaN,'note',"");

            switch type
                case {"PSK","QAM","ASK"}
                    sps = cfg.samplesPerSymbol;
                    startIdx = max(1,round(sps/2));
                    y = rxSamples(startIdx:sps:end);
                    nSym = numel(modInfo.symbolIndices);
                    y = y(1:min(nSym,numel(y)));

                    % Ideal educational one-tap channel equalization.
                    % The MH6 channel can rotate/scale the constellation even
                    % when SNR is high. Without this compensation, BER can be
                    % close to 0.5 although the physical link is excellent.
                    if exist('channelInfo','var') && isfield(channelInfo,'discreteChannel')
                        hEff = sum(channelInfo.discreteChannel(:));
                        if abs(hEff) > 1e-9
                            y = y ./ hEff;
                        end
                    end

                    % Normalize average power before decision.
                    if mean(abs(y).^2) > 0
                        yNorm = y / sqrt(mean(abs(y).^2));
                    else
                        yNorm = y;
                    end

                    const = modInfo.constellation(:);
                    [idxHat,decided] = app.nearestConstellation(yNorm,const);
                    bitsOut = app.integersToBits(idxHat,k);
                    bitsOut = bitsOut(1:min(codedLen,numel(bitsOut)));
                    info.rxSymbols = yNorm;
                    info.decidedSymbols = decided;
                    info.evm = app.computeEVM(yNorm,decided);
                    info.note = "Nearest-constellation hard decision.";

                case "FSK"
                    sps = cfg.samplesPerSymbol;
                    nSym = floor(numel(rxSamples)/sps);
                    y = reshape(rxSamples(1:nSym*sps),sps,nSym).';
                    idxHat = app.fskDemod(y,M,sps);
                    bitsOut = app.integersToBits(idxHat,k);
                    bitsOut = bitsOut(1:min(codedLen,numel(bitsOut)));
                    info.rxSymbols = exp(1j*2*pi*idxHat/M);
                    info.decidedSymbols = info.rxSymbols;
                    info.note = "FSK energy/correlation detector.";

                case "OFDM"
                    [subRx] = app.ofdmDemodulate(rxSamples,modInfo.nfft,modInfo.cpLen);
                    const = modInfo.constellation(:);
                    subRx = subRx(1:min(numel(modInfo.symbolIndices),numel(subRx)));

                    % OFDM frequency-domain equalization.
                    % For a multipath channel, each subcarrier observes
                    % Y[k] = H[k]X[k] + N[k]. Therefore the receiver must use
                    % Xhat[k] = Y[k]/H[k] before QAM/PSK decision.
                    if exist('channelInfo','var') && isfield(channelInfo,'discreteChannel') && ~isempty(subRx)
                        H = fft(channelInfo.discreteChannel(:),modInfo.nfft);
                        nFrames = ceil(numel(subRx)/modInfo.nfft);
                        Hseq = repmat(H(:),nFrames,1);
                        Hseq = Hseq(1:numel(subRx));
                        good = abs(Hseq) > 1e-9;
                        subEq = subRx;
                        subEq(good) = subRx(good)./Hseq(good);
                        subRx = subEq;
                    end

                    if mean(abs(subRx).^2) > 0
                        subRx = subRx / sqrt(mean(abs(subRx).^2));
                    end
                    [idxHat,decided] = app.nearestConstellation(subRx,const);
                    bitsOut = app.integersToBits(idxHat,k);
                    bitsOut = bitsOut(1:min(codedLen,numel(bitsOut)));
                    info.rxSymbols = subRx;
                    info.decidedSymbols = decided;
                    info.evm = app.computeEVM(subRx,decided);
                    info.note = "OFDM receiver: CP removal -> FFT -> frequency-domain channel equalization -> subcarrier demodulation.";

                otherwise
                    error('Unsupported demodulation type.');
            end
        end

        %% ============================================================
        %  BLOCK 5: BASEBAND TO RF
        % =============================================================
        function [rf,info] = basebandToRF(app,tx,cfg,modInfo)
            if tx.isWaveform
                bb = tx.waveformBB(:);
                pulseName = "native waveform";
            else
                bb = repelem(tx.symbols(:),cfg.samplesPerSymbol);
                pulseName = "rectangular pulse shaping";
            end

            bbPower = mean(abs(bb).^2);
            if bbPower > 0, bb = bb/sqrt(bbPower); end

            % RF waveform for visualization only. Physical RF fc may be GHz,
            % so a scaled display carrier is used to make the waveform visible.
            fsDisplay = 400e3;
            fcDisplay = 30e3;
            nDisplay = min(numel(bb),2000);
            t = (0:nDisplay-1)'/fsDisplay;
            bbVis = interp1(linspace(0,1,nDisplay),bb(1:nDisplay),linspace(0,1,nDisplay),'linear','extrap').';
            rfVis = real(bbVis .* exp(1j*2*pi*fcDisplay*t));

            rf = struct('baseband',bb,'rfDisplay',rfVis,'tDisplay',t);
            info = struct('pulseShaping',pulseName,'fcPhysicalHz',cfg.fc,'fcDisplayHz',fcDisplay, ...
                'bandwidthHz',cfg.bw,'samplesPerSymbol',cfg.samplesPerSymbol, ...
                'scheme',modInfo.scheme,'basebandPower',mean(abs(bb).^2));
        end

        %% ============================================================
        %  BLOCK 6: 3D WIRELESS CHANNEL
        % =============================================================
        function [out,info] = apply3DWirelessChannel(app,bb,cfg)
            % MH6: 3D urban wireless channel with educational multipath.
            % The channel now builds explicit multipath components from the
            % 3D geometry: LoS when clear, and NLoS reflection/diffraction
            % candidates when blocked by buildings. Each path has distance,
            % delay, path loss, and relative power.

            tx = cfg.txPos; rx = cfg.rxPos;
            d = norm(rx-tx);
            dKm = d/1000;
            fMHz = cfg.fc/1e6;
            fspl = 20*log10(max(dKm,1e-6)) + 20*log10(fMHz) + 32.44;

            [isBlocked,blockedBy] = app.isLinkBlocked(tx,rx,cfg.defaultBuildings);
            if isBlocked
                linkType = "NLoS";
                fadingModel = "Rayleigh";
            else
                linkType = "LoS";
                fadingModel = "Rician";
            end

            % Build physically-labelled multipath paths from the geometry.
            paths = app.buildMultipathComponents(tx,rx,cfg.defaultBuildings,cfg,isBlocked,blockedBy);
            if isempty(paths)
                % Safety fallback: a high-loss penetration component. This is
                % explicitly labelled and should not be interpreted as a free-space ray.
                paths = struct('type',"Penetration",'points',[tx;rx], ...
                    'distanceM',d,'delayS',d/cfg.c, ...
                    'pathLossdB',fspl+35,'relativePowerdB',0, ...
                    'note',"High-loss penetration fallback");
            end

            pathLosses = [paths.pathLossdB];
            [totalLoss,mainIdx] = min(pathLosses);
            relPow = -(pathLosses - totalLoss);
            for ii = 1:numel(paths)
                paths(ii).relativePowerdB = relPow(ii);
            end

            selectedType = paths(mainIdx).type;
            shadowLoss = double(linkType=="NLoS")*8 + double(linkType=="LoS")*2;
            buildingLoss = double(linkType=="NLoS")*12;
            reflectionLoss = double(contains(selectedType,"Reflection"))*10;
            diffractionLoss = double(contains(selectedType,"Diffraction"))*16;

            % Advanced-mode approximate gains.
            [Nt,Nr] = app.parseNtNr(cfg.ntnr);
            mimoGain = 0;
            beamGain = 0;
            capacityGain = 1;
            if cfg.envMode == "MIMO" || cfg.envMode == "MIMO + Beamforming"
                mimoGain = 10*log10(max(1,min(Nt,Nr)));       % educational diversity/capacity proxy
                capacityGain = max(1,min(Nt,Nr));
            end
            if cfg.envMode == "MIMO + Beamforming"
                beamGain = 10*log10(max(1,Nt));              % idealized array gain
            end

            pr = cfg.txPowerdBm + cfg.txGaindBi + cfg.rxGaindBi + mimoGain + beamGain - totalLoss;
            noise = -174 + 10*log10(cfg.bw) + cfg.noiseFigure;
            if cfg.interferenceOn
                interf = cfg.interferencePowerdBm;
            else
                interf = -Inf;
            end

            snr = pr - noise;
            totalNoiseInterf = app.dbmSum([noise,interf]);
            sinr = pr - totalNoiseInterf;

            % Convert multipath components into a baseband-equivalent FIR channel.
            tauAbs = [paths.delayS].';
            tau0 = min(tauAbs);
            tauRel = tauAbs - tau0;

            % Convert physical relative delays to a bounded discrete-time
            % educational channel. The PDP still reports physical delays,
            % but the waveform channel is kept inside the receiver's
            % equalization/CP capability so that a high-SNR link does not
            % fail simply because of unrealistic sample-rate scaling.
            if max(tauRel) > 0
                if cfg.modType == "OFDM"
                    maxDiscreteDelay = 8;      % safely below default CP length 16
                else
                    maxDiscreteDelay = min(2,max(0,cfg.samplesPerSymbol-1));
                end
                delays = round(tauRel./max(tauRel) * maxDiscreteDelay).';
            else
                delays = zeros(size(tauRel)).';
            end
            delays = max(delays,0);

            amp = sqrt(10.^([paths.relativePowerdB].'/10));
            phase = 2*pi*mod([paths.distanceM].'/cfg.lambda,1);
            taps = amp .* exp(1j*phase);
            if norm(taps) == 0
                taps = 1;
                delays = 0;
            end

            % If multiple paths fall on the same delay sample, add them coherently.
            h = zeros(max(delays)+1,1);
            for ii=1:numel(taps)
                h(delays(ii)+1) = h(delays(ii)+1) + taps(ii);
            end
            h = h / max(norm(h),eps);
            faded = filter(h,1,bb);

            sigPower = mean(abs(faded).^2);
            if sigPower <= 0, sigPower = 1; end
            faded = faded / sqrt(sigPower);

            pnRel = 10^((noise-pr)/10);
            piRel = 0;
            if isfinite(interf), piRel = 10^((interf-pr)/10); end

            n = sqrt(pnRel/2)*(randn(size(faded))+1j*randn(size(faded)));
            k = (0:numel(faded)-1).';
            interfSig = sqrt(piRel)*exp(1j*2*pi*0.07*k);
            rxBB = faded + n + interfSig;

            out = rxBB;

            pow = abs(taps(:)).^2; pow = pow/sum(pow);
            tauMean = sum(pow.*tauRel(:));
            delaySpread = sqrt(sum(pow.*(tauRel(:)-tauMean).^2));
            lambda = cfg.lambda;
            vRx = 0; % static default
            doppler = vRx/lambda;

            info = struct();
            info.distanceM = d;
            info.fspldB = fspl;
            info.shadowLossdB = shadowLoss;
            info.buildingLossdB = buildingLoss;
            info.reflectionLossdB = reflectionLoss;
            info.diffractionLossdB = diffractionLoss;
            info.totalLossdB = totalLoss;
            info.linkType = linkType;
            info.blockedBy = blockedBy;
            info.fadingModel = fadingModel;
            info.prdBm = pr;
            info.noisePowerdBm = noise;
            info.interferencePowerdBm = interf;
            info.snrDB = snr;
            info.sinrDB = sinr;
            info.delaySpreadS = delaySpread;
            info.dopplerHz = doppler;
            info.taps = taps;
            info.delays = delays;
            info.discreteChannel = h;
            info.physicalRelativeDelaysS = tauRel;
            info.paths = paths;
            info.mainPathIndex = mainIdx;
            info.Nt = Nt; info.Nr = Nr;
            info.mimoGaindB = mimoGain;
            info.beamGaindB = beamGain;
            info.capacityGain = capacityGain;
            info.beamAngleDeg = cfg.beamAngleDeg;
            info.beamElevationDeg = cfg.beamElevationDeg;
            if linkType == "LoS"
                info.directPathStatus = "Clear";
                info.displayedPath = "Direct LoS plus weaker reflected multipath components";
            else
                info.directPathStatus = sprintf('Blocked by Building #%d',blockedBy);
                info.displayedPath = "NLoS multipath: reflected/diffracted components; no free-space ray through buildings";
            end
        end

        %% ============================================================
        %  BLOCK 7: RECEIVER FRONT-END
        % =============================================================
        function [rx,info] = receiverFrontend(app,channelOut,cfg,channelInfo)
            % In this educational baseband simulation, the channel output is
            % already complex baseband-equivalent. The receiver front-end
            % emulates RF filtering, LNA gain, AGC, and ADC quantization.

            y = channelOut(:);
            lnaLinear = 10^(cfg.lnaGain/20);
            yLNA = y * lnaLinear;

            if cfg.agcOn
                targetRMS = 0.7;
                currentRMS = rms(abs(yLNA));
                if currentRMS > 0
                    agcGainLinear = targetRMS/currentRMS;
                else
                    agcGainLinear = 1;
                end
            else
                agcGainLinear = 1;
            end
            yAGC = yLNA * agcGainLinear;

            % ADC quantization on I and Q.
            adcMax = 1;
            levels = 2^cfg.adcBits;
            step = 2*adcMax/(levels-1);
            yClip = min(max(real(yAGC),-adcMax),adcMax) + 1j*min(max(imag(yAGC),-adcMax),adcMax);
            yADC = round((real(yClip)+adcMax)/step)*step - adcMax + ...
                   1j*(round((imag(yClip)+adcMax)/step)*step - adcMax);

            rx = struct('samples',yADC,'preADC',yAGC,'preAGC',yLNA);
            info = struct();
            info.prdBm = channelInfo.prdBm;
            info.noisePowerdBm = channelInfo.noisePowerdBm;
            info.interferencePowerdBm = channelInfo.interferencePowerdBm;
            info.snrDB = channelInfo.snrDB;
            info.sinrDB = channelInfo.sinrDB;
            info.lnaGainDB = cfg.lnaGain;
            info.agcGainDB = 20*log10(max(agcGainLinear,eps));
            info.samplingRateHz = cfg.fs;
            info.adcBits = cfg.adcBits;
            if channelInfo.sinrDB > 20
                info.status = "Good";
            elseif channelInfo.sinrDB > 8
                info.status = "Medium";
            else
                info.status = "Weak";
            end
        end

        %% ============================================================
        %  BLOCK 10: FINAL RESULTS
        % =============================================================
        function result = evaluateResults(app,bits,recoveredBits,cfg,codingInfo,modInfo,channelInfo,rxInfo,demodInfo,decInfo)
            N = min(numel(bits),numel(recoveredBits));
            if N == 0
                bitErrors = NaN; ber = NaN;
            else
                bitErrors = sum(bits(1:N) ~= recoveredBits(1:N));
                ber = bitErrors / N;
            end

            frameLen = 100;
            nFrames = floor(N/frameLen);
            if nFrames > 0
                e = bits(1:nFrames*frameLen) ~= recoveredBits(1:nFrames*frameLen);
                eMat = reshape(e,frameLen,nFrames);
                frameErr = sum(any(eMat,1));
                fer = frameErr/nFrames;
            else
                frameErr = NaN; fer = NaN;
            end

            if isnan(fer)
                packetSuccess = NaN;
                throughput = cfg.bitRate * max(0,1 - min(1,ber));
            else
                packetSuccess = 1 - min(1,max(0,fer));
                throughput = cfg.bitRate * max(0,packetSuccess);
            end

            if channelInfo.sinrDB > 25
                physicalQuality = "Excellent";
            elseif channelInfo.sinrDB > 15
                physicalQuality = "Good";
            elseif channelInfo.sinrDB > 8
                physicalQuality = "Medium";
            elseif channelInfo.sinrDB > 0
                physicalQuality = "Poor";
            else
                physicalQuality = "Very Poor";
            end

            if ber < 1e-5
                dataQuality = "Excellent";
            elseif ber < 1e-3
                dataQuality = "Good";
            elseif ber < 1e-2
                dataQuality = "Medium";
            elseif ber < 1e-1
                dataQuality = "Poor";
            else
                dataQuality = "Very Poor";
            end
            quality = dataQuality;

            result = struct();
            result.totalComparedBits = N;
            result.bitErrors = bitErrors;
            result.ber = ber;
            result.frameErrors = frameErr;
            result.fer = fer;
            result.packetSuccessRate = packetSuccess;
            result.throughputBps = throughput;
            result.physicalLinkQuality = physicalQuality;
            result.endToEndDataQuality = dataQuality;
            result.linkQuality = quality;
            result.coding = codingInfo.type;
            result.modulation = modInfo.scheme;
            result.receivedPowerdBm = rxInfo.prdBm;
            result.snrDB = rxInfo.snrDB;
            result.sinrDB = rxInfo.sinrDB;
            result.decoderStatus = decInfo.status;
            result.demodEVM = demodInfo.evm;
        end

        %% ============================================================
        %  BLOCK 4: ANALOG AM/FM/PM DEMO
        % =============================================================
        function info = analogDemo(app,cfg)
            Fs = 200e3;
            T = 0.05;
            t = (0:1/Fs:T-1/Fs).';
            Ac = 1; Am = 1;
            m = Am*cos(2*pi*cfg.analogFm*t);
            c = Ac*cos(2*pi*cfg.analogFc*t);

            switch cfg.analogType
                case "AM"
                    s = Ac*(1 + cfg.amIndex*m).*cos(2*pi*cfg.analogFc*t);
                    indexName = "\mu"; indexValue = cfg.amIndex;
                    equation = "s_AM(t)=Ac[1+\mu m(t)]cos(2\pi f_ct)";
                case "FM"
                    s = Ac*cos(2*pi*cfg.analogFc*t + cfg.fmIndex*sin(2*pi*cfg.analogFm*t));
                    indexName = "\beta"; indexValue = cfg.fmIndex;
                    equation = "s_FM(t)=Ac cos(2\pi f_ct+\beta sin(2\pi f_mt))";
                otherwise
                    s = Ac*cos(2*pi*cfg.analogFc*t + cfg.pmKp*m);
                    indexName = "kp"; indexValue = cfg.pmKp;
                    equation = "s_PM(t)=Ac cos(2\pi f_ct+k_p m(t))";
            end

            info = struct('t',t,'message',m,'carrier',c,'modulated',s,'Fs',Fs, ...
                'type',cfg.analogType,'fc',cfg.analogFc,'fm',cfg.analogFm, ...
                'indexName',indexName,'indexValue',indexValue,'equation',equation);
        end

        %% ============================================================
        %  VISUALIZATION
        % =============================================================
        function plotBlock1(app,bits,cfg)
            ax = app.Axes.B1.a1; cla(ax);
            n = min(80,numel(bits));
            stairs(ax,0:n-1,bits(1:n),'LineWidth',1.5); ylim(ax,[-0.2 1.2]); grid(ax,'on');
            title(ax,'Input Digital Bit Stream / NRZ'); xlabel(ax,'Bit Index'); ylabel(ax,'Bit Value');

            ax2 = app.Axes.B1.a2; cla(ax2);
            bar(ax2,[sum(bits==0),sum(bits==1)]); grid(ax2,'on');
            title(ax2,'Bit Distribution'); xticks(ax2,[1 2]); xticklabels(ax2,{'0','1'}); ylabel(ax2,'Count');

            app.setTable('B1',{
                'Input Type','Random Bits','Default-first random source';
                'Total Bits',num2str(numel(bits)),'Original information bits';
                'Bit Rate',sprintf('%.3f Mbps',cfg.bitRate/1e6),'Used for throughput estimate';
                'Visualization','NRZ waveform','Shows raw 0/1 data before coding'
            });
        end

        function plotBlock2(app,bits,coded,codingInfo)
            ax = app.Axes.B2.a1; cla(ax);
            n = min(80,numel(bits));
            stairs(ax,0:n-1,bits(1:n),'LineWidth',1.3); grid(ax,'on'); ylim(ax,[-0.2 1.2]);
            title(ax,'Before Channel Coding'); xlabel(ax,'Bit Index'); ylabel(ax,'Bit');

            ax2 = app.Axes.B2.a2; cla(ax2);
            n2 = min(120,numel(coded));
            stairs(ax2,0:n2-1,coded(1:n2),'LineWidth',1.3); grid(ax2,'on'); ylim(ax2,[-0.2 1.2]);
            title(ax2,'After Channel Coding'); xlabel(ax2,'Coded Bit Index'); ylabel(ax2,'Coded Bit');

            app.setTable('B2',{
                'Selected Coding',char(codingInfo.type),'Automatically matched with Khối 9 decoder';
                'Input Bits',num2str(numel(bits)),'Information bits';
                'Output Coded Bits',num2str(numel(coded)),'Bits sent to digital modulation';
                'Code Rate',sprintf('%.3f',codingInfo.codeRate),'Input bits / coded bits';
                'Block Length',num2str(codingInfo.blockLength),'NaN means variable/whole packet';
                'Note',char(codingInfo.note),'Coding theory summary'
            });
        end

        function plotBlock3(app,tx,modInfo)
            ax = app.Axes.B3.a1; cla(ax); hold(ax,'on');
            if ~isempty(modInfo.constellation)
                scatter(ax,real(modInfo.constellation),imag(modInfo.constellation),80,'filled');
            end
            if ~isempty(tx.symbols)
                sampleN = min(300,numel(tx.symbols));
                scatter(ax,real(tx.symbols(1:sampleN)),imag(tx.symbols(1:sampleN)),15);
            end
            axis(ax,'equal'); grid(ax,'on'); hold(ax,'off');
            title(ax,['Constellation / Selected Scheme: ',char(modInfo.scheme)]);
            xlabel(ax,'In-phase I'); ylabel(ax,'Quadrature Q');

            ax2 = app.Axes.B3.a2; cla(ax2);
            if tx.isWaveform
                n = min(400,numel(tx.waveformBB));
                plot(ax2,real(tx.waveformBB(1:n)),'LineWidth',1.1); hold(ax2,'on');
                plot(ax2,imag(tx.waveformBB(1:n)),'LineWidth',1.1); hold(ax2,'off');
            else
                n = min(80,numel(tx.symbols));
                stem(ax2,real(tx.symbols(1:n)),'filled'); hold(ax2,'on');
                stem(ax2,imag(tx.symbols(1:n)),'filled'); hold(ax2,'off');
            end
            grid(ax2,'on'); title(ax2,'Modulated Symbol / Baseband Samples'); legend(ax2,{'I','Q'});

            app.setTable('B3',{
                'Modulation Type',char(modInfo.type),'From two-level selector';
                'Modulation Order',num2str(modInfo.M),'M';
                'Selected Scheme',char(modInfo.scheme),'Automatically inferred';
                'Bits per Symbol',num2str(modInfo.bitsPerSymbol),'k = log2(M)';
                'Padded Bits',num2str(modInfo.pad),'Used to complete symbol grouping'
            });
        end

        function plotBlock4(app,analogInfo)
            ax = app.Axes.B4.a1; cla(ax);
            n = min(1500,numel(analogInfo.t));
            plot(ax,analogInfo.t(1:n)*1000,analogInfo.message(1:n),'LineWidth',1.3); hold(ax,'on');
            plot(ax,analogInfo.t(1:n)*1000,analogInfo.carrier(1:n),'LineWidth',1.0); hold(ax,'off');
            grid(ax,'on'); title(ax,'Message Signal and Carrier'); xlabel(ax,'Time (ms)');
            legend(ax,{'m(t)','c(t)'});

            ax2 = app.Axes.B4.a2; cla(ax2);
            plot(ax2,analogInfo.t(1:n)*1000,analogInfo.modulated(1:n),'LineWidth',1.2);
            grid(ax2,'on'); title(ax2,['Analog Modulated Waveform - ',char(analogInfo.type)]); xlabel(ax2,'Time (ms)');

            app.setTable('B4',{
                'Analog Type',char(analogInfo.type),'AM/FM/PM educational demo';
                'Carrier fc',sprintf('%.3f kHz',analogInfo.fc/1e3),'Display-friendly carrier frequency';
                'Message fm',sprintf('%.3f Hz',analogInfo.fm),'Message signal frequency';
                'Modulation Index',sprintf('%s = %.3f',analogInfo.indexName,analogInfo.indexValue),'AM: mu, FM: beta, PM: kp';
                'Equation',char(analogInfo.equation),'Theory shown as waveform'
            });
        end

        function plotBlock5(app,rf,rfInfo,cfg)
            ax = app.Axes.B5.a1; cla(ax);
            n = min(600,numel(rf.baseband));
            plot(ax,real(rf.baseband(1:n)),'LineWidth',1.1); hold(ax,'on');
            plot(ax,imag(rf.baseband(1:n)),'LineWidth',1.1); hold(ax,'off');
            grid(ax,'on'); title(ax,'Baseband I/Q Signal'); xlabel(ax,'Sample'); legend(ax,{'I','Q'});

            ax2 = app.Axes.B5.a2; cla(ax2);
            plot(ax2,rf.tDisplay*1000,rf.rfDisplay,'LineWidth',1.1);
            grid(ax2,'on'); title(ax2,'RF Waveform for Visualization'); xlabel(ax2,'Time (ms)');

            app.setTable('B5',{
                'Physical Carrier fc',sprintf('%.3f GHz',rfInfo.fcPhysicalHz/1e9),'Used in link budget/channel';
                'Display Carrier',sprintf('%.1f kHz',rfInfo.fcDisplayHz/1e3),'Scaled carrier for visible RF waveform';
                'Bandwidth',sprintf('%.3f MHz',rfInfo.bandwidthHz/1e6),'Signal bandwidth';
                'Pulse Shaping',char(rfInfo.pulseShaping),'Educational implementation';
                'Baseband Power',sprintf('%.3f',rfInfo.basebandPower),'Normalized before channel'
            });
        end

        function plotBlock6(app,ch,cfg)
            ax = app.Axes.B6.a1; cla(ax); hold(ax,'on'); grid(ax,'on');
            view(ax,3); title(ax,'MH6 - 3D Urban Wireless Environment'); xlabel(ax,'x (m)'); ylabel(ax,'y (m)'); zlabel(ax,'z (m)');
            app.drawBuildings(ax,cfg.defaultBuildings);
            plot3(ax,cfg.txPos(1),cfg.txPos(2),cfg.txPos(3),'^','MarkerSize',10,'MarkerFaceColor','k');
            text(ax,cfg.txPos(1),cfg.txPos(2),cfg.txPos(3)+5,'Tx');
            plot3(ax,cfg.rxPos(1),cfg.rxPos(2),cfg.rxPos(3),'o','MarkerSize',9,'MarkerFaceColor','k');
            text(ax,cfg.rxPos(1),cfg.rxPos(2),cfg.rxPos(3)+5,'Rx');

            if cfg.showRayPaths && isfield(ch,'paths')
                maxShow = min(numel(ch.paths),6);
                for pIdx = 1:maxShow
                    pts = ch.paths(pIdx).points;
                    switch string(ch.paths(pIdx).type)
                        case "LoS Direct"
                            style = '-'; col = [0.0 0.45 0.9]; lw = 2.6;
                        case "Reflection"
                            style = '--'; col = [0.90 0.55 0.05]; lw = 2.0;
                        case "Diffraction"
                            style = ':'; col = [0.55 0.15 0.85]; lw = 2.2;
                        otherwise
                            style = '-.'; col = [0.45 0.45 0.45]; lw = 1.6;
                    end
                    plot3(ax,pts(:,1),pts(:,2),pts(:,3),style,'LineWidth',lw,'Color',col);
                    if size(pts,1) > 2
                        scatter3(ax,pts(2:end-1,1),pts(2:end-1,2),pts(2:end-1,3),42,col,'filled');
                    end
                    if pIdx == ch.mainPathIndex
                        midpt = pts(ceil(size(pts,1)/2),:);
                        text(ax,midpt(1),midpt(2),midpt(3)+6,sprintf('Main %s path',char(ch.paths(pIdx).type)));
                    end
                end
            end

            if cfg.envMode == "MIMO" || cfg.envMode == "MIMO + Beamforming"
                app.drawAntennaArray(ax,cfg.txPos,ch.Nt,cfg.lambda);
                app.drawAntennaArray(ax,cfg.rxPos,ch.Nr,cfg.lambda);
            end
            if cfg.showBeamPattern && cfg.envMode == "MIMO + Beamforming"
                app.drawBeamCone(ax,cfg.txPos,cfg.beamAngleDeg,cfg.beamElevationDeg,0.22*max(cfg.sceneX,cfg.sceneY),ch.Nt);
            end
            xlim(ax,[0 cfg.sceneX]); ylim(ax,[0 cfg.sceneY]); zlim(ax,[0 cfg.sceneZ]);
            axis(ax,'vis3d'); hold(ax,'off');

            % Block 6 now intentionally displays only the main 3D environment.
            % Multipath PDP / coverage / beam-pattern plots are kept as optional
            % analysis functions, but they no longer occupy the MH6 main tab.

            app.setTable('B6',{
                'Scene Size',sprintf('%.0f x %.0f x %.0f m',cfg.sceneX,cfg.sceneY,cfg.sceneZ),'User-configurable 3D space size';
                'Number of Buildings',sprintf('%d',size(cfg.defaultBuildings,1)),'User-adjustable urban obstacle count';
                'Building Layout Mode',char(app.boolChoice(cfg.randomizeBuildings,'Random each run','Fixed seed')),'Controls whether buildings move after each Run';
                'Layout Seed',sprintf('%d',cfg.layoutSeed),'Random seed used for the current 3D urban scene';
                'Building Density',char(cfg.buildingDensity),'Controls building footprint distribution';
                'MH6 Main Display','3D Environment Only','PDP/coverage kept as optional analysis, not shown beside 3D view';
                'Link Type',char(ch.linkType),'LoS/NLoS from 3D blocking check';
                'Direct Path',char(ch.directPathStatus),'Direct Tx-Rx path condition';
                'Displayed Path',char(ch.displayedPath),'Propagation visualization rule';
                'Multipath Components',sprintf('%d',numel(ch.paths)),'LoS/reflection/diffraction components';
                'Main Path Type',char(ch.paths(ch.mainPathIndex).type),'Strongest component by path loss';
                'Main Path Loss',sprintf('%.2f dB',ch.paths(ch.mainPathIndex).pathLossdB),'Selected component loss';
                'Distance',sprintf('%.2f m',ch.distanceM),'3D Tx-Rx distance';
                'FSPL Direct',sprintf('%.2f dB',ch.fspldB),'Free-space path loss for direct distance';
                'Total Path Loss',sprintf('%.2f dB',ch.totalLossdB),'Strongest valid multipath path loss';
                'Received Power',sprintf('%.2f dBm',ch.prdBm),'Link budget result';
                'Noise Power',sprintf('%.2f dBm',ch.noisePowerdBm),'Thermal noise + NF';
                'Interference Power',sprintf('%.2f dBm',ch.interferencePowerdBm),'External device power';
                'SNR',sprintf('%.2f dB',ch.snrDB),'Signal-to-noise ratio';
                'SINR',sprintf('%.2f dB',ch.sinrDB),'Signal-to-interference-plus-noise ratio';
                'RMS Delay Spread',sprintf('%.3g us',ch.delaySpreadS*1e6),'Multipath time dispersion';
                'Fading Model',char(ch.fadingModel),'Rayleigh/Rician suggestion';
                'Nt / Nr',sprintf('%d / %d',ch.Nt,ch.Nr),'MIMO antenna numbers';
                'Beam Az / El',sprintf('%.1f° / %.1f°',ch.beamAngleDeg,ch.beamElevationDeg),'Beam steering direction';
                'MIMO Gain',sprintf('%.2f dB',ch.mimoGaindB),'Educational advanced-mode gain';
                'Beam Gain',sprintf('%.2f dB',ch.beamGaindB),'Idealized beamforming gain'
            });
        end

        function plotBlock7(app,rx,rxInfo,cfg)
            ax = app.Axes.B7.a1; cla(ax);
            n = min(600,numel(rx.preADC));
            plot(ax,real(rx.preADC(1:n)),'LineWidth',1.1); hold(ax,'on');
            plot(ax,imag(rx.preADC(1:n)),'LineWidth',1.1); hold(ax,'off');
            grid(ax,'on'); title(ax,'Receiver I/Q Before ADC'); xlabel(ax,'Sample'); legend(ax,{'I','Q'});

            ax2 = app.Axes.B7.a2; cla(ax2);
            x = rx.samples(:);
            nfft = 2048;
            X = fftshift(abs(fft(x(1:min(numel(x),nfft)),nfft)));
            f = linspace(-cfg.fs/2,cfg.fs/2,nfft)/1e6;
            plot(ax2,f,20*log10(X/max(X)+eps),'LineWidth',1.1);
            grid(ax2,'on'); title(ax2,'Received Baseband Spectrum'); xlabel(ax2,'Frequency (MHz)'); ylabel(ax2,'Normalized dB');

            app.setTable('B7',{
                'Received Power',sprintf('%.2f dBm',rxInfo.prdBm),'At receiver antenna';
                'Noise Power',sprintf('%.2f dBm',rxInfo.noisePowerdBm),'Thermal noise + NF';
                'Interference Power',sprintf('%.2f dBm',rxInfo.interferencePowerdBm),'Interference seen by receiver';
                'SNR',sprintf('%.2f dB',rxInfo.snrDB),'Before demodulation';
                'SINR',sprintf('%.2f dB',rxInfo.sinrDB),'With interference';
                'LNA Gain',sprintf('%.2f dB',rxInfo.lnaGainDB),'Low-noise amplifier gain';
                'AGC Gain',sprintf('%.2f dB',rxInfo.agcGainDB),'Automatic gain control';
                'Sampling Rate',sprintf('%.3f MHz',rxInfo.samplingRateHz/1e6),'ADC sampling frequency';
                'ADC Resolution',sprintf('%d bits',rxInfo.adcBits),'I/Q quantization';
                'Receiver Status',char(rxInfo.status),'Weak/Medium/Good'
            });
        end

        function plotBlock8(app,rx,demodInfo,modInfo)
            ax = app.Axes.B8.a1; cla(ax); hold(ax,'on');
            if ~isempty(modInfo.constellation)
                scatter(ax,real(modInfo.constellation),imag(modInfo.constellation),90,'filled');
            end
            y = demodInfo.rxSymbols;
            if ~isempty(y)
                n = min(700,numel(y));
                scatter(ax,real(y(1:n)),imag(y(1:n)),12);
            end
            axis(ax,'equal'); grid(ax,'on'); hold(ax,'off');
            title(ax,['Received Constellation After Channel - ',char(demodInfo.scheme)]);
            xlabel(ax,'I'); ylabel(ax,'Q');

            ax2 = app.Axes.B8.a2; cla(ax2);
            if ~isempty(demodInfo.rxSymbols) && ~isempty(demodInfo.decidedSymbols)
                n = min(80,numel(demodInfo.rxSymbols));
                errVec = abs(demodInfo.rxSymbols(1:n)-demodInfo.decidedSymbols(1:n));
                stem(ax2,errVec,'filled');
                title(ax2,'Symbol Decision Error Vector Magnitude');
                ylabel(ax2,'|y - x_hat|');
            else
                plot(ax2,real(rx.samples(1:min(300,numel(rx.samples)))));
                title(ax2,'Demodulated Signal View');
            end
            grid(ax2,'on'); xlabel(ax2,'Symbol Index');

            evmText = 'N/A';
            if ~isnan(demodInfo.evm), evmText = sprintf('%.2f %%',100*demodInfo.evm); end
            app.setTable('B8',{
                'Selected Demodulator',char(demodInfo.scheme),'Automatically matched with Khối 3';
                'Decision Mode',char(demodInfo.decisionMode),'Default hard decision';
                'Bits per Symbol',num2str(modInfo.bitsPerSymbol),'k = log2(M)';
                'Received Symbols',num2str(numel(demodInfo.rxSymbols)),'Symbols used for decision';
                'Average EVM',evmText,'Signal dispersion around ideal points';
                'Output','Demodulated coded bits','Input for Khối 9';
                'Note',char(demodInfo.note),'Demodulation mechanism'
            });
        end

        function plotBlock9(app,demodBits,recoveredBits,decInfo)
            ax = app.Axes.B9.a1; cla(ax);
            n = min(100,numel(demodBits));
            stairs(ax,0:n-1,demodBits(1:n),'LineWidth',1.2);
            ylim(ax,[-0.2 1.2]); grid(ax,'on'); title(ax,'Input to Channel Decoder'); xlabel(ax,'Bit Index'); ylabel(ax,'Bit');

            ax2 = app.Axes.B9.a2; cla(ax2);
            n2 = min(100,numel(recoveredBits));
            stairs(ax2,0:n2-1,recoveredBits(1:n2),'LineWidth',1.2);
            ylim(ax2,[-0.2 1.2]); grid(ax2,'on'); title(ax2,'Recovered Information Bits'); xlabel(ax2,'Bit Index'); ylabel(ax2,'Bit');

            app.setTable('B9',{
                'Selected Decoder',char(decInfo.type),'Automatically matched with Khối 2';
                'Input Bits',num2str(numel(demodBits)),'Demodulated coded bits from Khối 8';
                'Output Bits',num2str(numel(recoveredBits)),'Recovered information bits to Khối 10';
                'Detected Errors',num2str(decInfo.detectedErrors),'Decoder-level detection';
                'Corrected Errors',num2str(decInfo.correctedErrors),'Decoder-level correction';
                'Decoder Status',char(decInfo.status),'Success/Partial/Fail';
                'Note',char(decInfo.note),'Decoding mechanism'
            });
        end

        function plotBlock10(app,bits,recoveredBits,result)
            ax = app.Axes.B10.a1; cla(ax);
            N = min([80,numel(bits),numel(recoveredBits)]);
            if N > 0
                plot(ax,0:N-1,bits(1:N),'o-','LineWidth',1.1); hold(ax,'on');
                plot(ax,0:N-1,recoveredBits(1:N),'x-','LineWidth',1.1); hold(ax,'off');
                ylim(ax,[-0.2 1.2]); grid(ax,'on');
                legend(ax,{'Original','Recovered'});
            end
            title(ax,'Original Bits vs Recovered Bits'); xlabel(ax,'Bit Index'); ylabel(ax,'Bit');

            ax2 = app.Axes.B10.a2; cla(ax2);
            N2 = min(numel(bits),numel(recoveredBits));
            if N2 > 0
                err = bits(1:N2) ~= recoveredBits(1:N2);
                nPlot = min(300,N2);
                stem(ax2,0:nPlot-1,err(1:nPlot),'filled');
                ylim(ax2,[-0.1 1.2]); grid(ax2,'on');
            end
            title(ax2,'Bit Error Map'); xlabel(ax2,'Bit Index'); ylabel(ax2,'Error');

            app.setTable('B10',{
                'Coding',char(result.coding),'Selected coding method';
                'Modulation',char(result.modulation),'Selected modulation scheme';
                'Compared Bits',num2str(result.totalComparedBits),'Original vs recovered information bits';
                'Bit Errors',num2str(result.bitErrors),'Number of different bits';
                'BER',sprintf('%.4g',result.ber),'Bit Error Rate';
                'FER',sprintf('%.4g',result.fer),'Frame Error Rate, frame length = 100 bits';
                'Packet Success Rate',sprintf('%.2f %%',100*result.packetSuccessRate),'1 - FER';
                'Throughput',sprintf('%.3f Mbps',result.throughputBps/1e6),'Rb*(1-FER) when FER is available';
                'Received Power',sprintf('%.2f dBm',result.receivedPowerdBm),'From MH6/Receiver';
                'SNR',sprintf('%.2f dB',result.snrDB),'Signal/noise';
                'SINR',sprintf('%.2f dB',result.sinrDB),'Signal/(noise+interference)';
                'Decoder Status',char(result.decoderStatus),'Execution status from Khối 9';
                'Physical Link Quality',char(result.physicalLinkQuality),'Based on received power/SINR';
                'End-to-End Data Quality',char(result.endToEndDataQuality),'Based on BER/FER after decoding'
            });
        end

        function setTable(app,key,data)
            app.Tables.(key).Data = data;
        end

        %% ============================================================
        %  CODING HELPERS
        % =============================================================
        function [coded,pad] = hamming74Encode(app,bits)
            pad = mod(-numel(bits),4);
            bits = [bits(:); zeros(pad,1)];
            d = reshape(bits,4,[]).';
            d1=d(:,1); d2=d(:,2); d3=d(:,3); d4=d(:,4);
            p1 = mod(d1+d2+d4,2);
            p2 = mod(d1+d3+d4,2);
            p3 = mod(d2+d3+d4,2);
            c = [p1 p2 d1 p3 d2 d3 d4];
            coded = reshape(c.',[],1);
        end

        function [decoded,corrected,uncorrectable] = hamming74Decode(app,rx)
            nBlocks = floor(numel(rx)/7);
            rx = rx(1:nBlocks*7);
            R = reshape(rx,7,[]).';
            corrected = 0; uncorrectable = 0;
            data = zeros(nBlocks,4);
            for i=1:nBlocks
                r = R(i,:);
                s1 = mod(r(1)+r(3)+r(5)+r(7),2);
                s2 = mod(r(2)+r(3)+r(6)+r(7),2);
                s3 = mod(r(4)+r(5)+r(6)+r(7),2);
                pos = s1 + 2*s2 + 4*s3;
                if pos >= 1 && pos <= 7
                    r(pos) = 1-r(pos);
                    corrected = corrected + 1;
                elseif pos > 7
                    uncorrectable = uncorrectable + 1;
                end
                data(i,:) = [r(3) r(5) r(6) r(7)];
            end
            decoded = reshape(data.',[],1);
        end

        function crc = crcRemainder(app,bits,poly)
            bits = bits(:).';
            poly = poly(:).';
            m = numel(poly)-1;
            work = [bits zeros(1,m)];
            if numel(bits) >= numel(poly) && all(bits(end-m+1:end) == 0)
                % do nothing; this branch is not used in normal checks
            end
            % If bits already include CRC, compute remainder directly over full vector.
            if numel(bits) > m && ~all(work(end-m+1:end)==0)
                work = bits;
            end
            for i=1:(numel(work)-m)
                if work(i) == 1
                    work(i:i+m) = xor(work(i:i+m),poly);
                end
            end
            crc = work(end-m+1:end).';
        end

        function [coded,pad] = convEncode12(app,bits)
            K = 3;
            tail = zeros(K-1,1);
            u = [bits(:); tail];
            pad = numel(tail);
            state = [0 0];
            coded = zeros(2*numel(u),1);
            p = 1;
            for i=1:numel(u)
                reg = [u(i) state];
                coded(p) = mod(sum(reg([1 2 3])),2); p=p+1; % 111
                coded(p) = mod(sum(reg([1 3])),2); p=p+1;   % 101
                state = reg(1:2);
            end
        end

        function decoded = viterbiDecode12(app,coded)
            coded = coded(:);
            if mod(numel(coded),2) ~= 0
                coded = coded(1:end-1);
            end
            y = reshape(coded,2,[]).';
            nSteps = size(y,1);
            nStates = 4; % K=3 -> 2 memory bits
            infVal = 1e9;
            metric = infVal*ones(nStates,1); metric(1)=0;
            prevState = zeros(nSteps,nStates);
            prevBit = zeros(nSteps,nStates);

            for t=1:nSteps
                newMetric = infVal*ones(nStates,1);
                newPrevState = zeros(1,nStates);
                newPrevBit = zeros(1,nStates);
                for st=0:nStates-1
                    if metric(st+1) >= infVal, continue; end
                    mem = [bitget(st,2), bitget(st,1)];
                    for b=0:1
                        reg = [b mem];
                        out = [mod(sum(reg([1 2 3])),2), mod(sum(reg([1 3])),2)];
                        nextMem = reg(1:2);
                        nextSt = nextMem(1)*2 + nextMem(2);
                        dist = sum(out ~= y(t,:));
                        cand = metric(st+1) + dist;
                        if cand < newMetric(nextSt+1)
                            newMetric(nextSt+1) = cand;
                            newPrevState(nextSt+1) = st;
                            newPrevBit(nextSt+1) = b;
                        end
                    end
                end
                metric = newMetric;
                prevState(t,:) = newPrevState;
                prevBit(t,:) = newPrevBit;
            end

            % Encoder appends K-1 zero tail bits, so the valid final
            % trellis state is the all-zero state. Using this known terminal
            % state avoids unnecessary bit ambiguity at high SNR.
            st = 0;
            bits = zeros(nSteps,1);
            for t=nSteps:-1:1
                bits(t) = prevBit(t,st+1);
                st = prevState(t,st+1);
            end
            % remove two zero-tail bits if present
            if numel(bits) > 2
                decoded = bits(1:end-2);
            else
                decoded = bits;
            end
        end

        function [coded,meta] = educationalRSEncode(app,bits)
            k = 11*8; parity = 4*8; n = k+parity;
            pad = mod(-numel(bits),k);
            bitsP = [bits(:); zeros(pad,1)];
            blocks = reshape(bitsP,k,[]).';
            codedBlocks = zeros(size(blocks,1),n);
            for i=1:size(blocks,1)
                b = blocks(i,:);
                p = repmat(mod(sum(b),2),1,parity);
                codedBlocks(i,:) = [b p];
            end
            coded = reshape(codedBlocks.',[],1);
            meta = struct('k',k,'n',n,'pad',pad,'parity',parity);
        end

        function [decoded,meta] = educationalRSDecode(app,coded,encMeta)
            nBlocks = floor(numel(coded)/encMeta.n);
            C = reshape(coded(1:nBlocks*encMeta.n),encMeta.n,[]).';
            data = C(:,1:encMeta.k);
            detected = 0; corrected = 0;
            for i=1:nBlocks
                pExpected = mod(sum(data(i,:)),2);
                pRecv = round(mean(C(i,encMeta.k+1:end)));
                if pExpected ~= pRecv
                    detected = detected + 1;
                end
            end
            decoded = reshape(data.',[],1);
            if encMeta.pad > 0 && numel(decoded) > encMeta.pad
                decoded = decoded(1:end-encMeta.pad);
            end
            meta = struct('detectedBlocks',detected,'correctedBlocks',corrected,'status',"Detection Only");
        end

        function [coded,meta] = educationalLDPCEncode(app,bits)
            k = 6; n = 9;
            pad = mod(-numel(bits),k);
            bitsP = [bits(:); zeros(pad,1)];
            B = reshape(bitsP,k,[]).';
            C = zeros(size(B,1),n);
            for i=1:size(B,1)
                d = B(i,:);
                p1 = mod(d(1)+d(2)+d(4),2);
                p2 = mod(d(2)+d(3)+d(5),2);
                p3 = mod(d(1)+d(3)+d(6),2);
                C(i,:) = [d p1 p2 p3];
            end
            coded = reshape(C.',[],1);
            meta = struct('k',k,'n',n,'pad',pad);
        end

        function [decoded,meta] = educationalLDPCDecode(app,coded,encMeta)
            nBlocks = floor(numel(coded)/encMeta.n);
            C = reshape(coded(1:nBlocks*encMeta.n),encMeta.n,[]).';
            correctedBits = 0; unsat = 0;
            for i=1:nBlocks
                c = C(i,:);
                s = [mod(c(1)+c(2)+c(4)+c(7),2), ...
                     mod(c(2)+c(3)+c(5)+c(8),2), ...
                     mod(c(1)+c(3)+c(6)+c(9),2)];
                if any(s)
                    unsat = unsat + sum(s);
                    % simple bit-flip heuristic: try flipping data bits to satisfy checks
                    best = c; bestScore = sum(s);
                    for b=1:encMeta.k
                        test = c; test(b)=1-test(b);
                        st = [mod(test(1)+test(2)+test(4)+test(7),2), ...
                              mod(test(2)+test(3)+test(5)+test(8),2), ...
                              mod(test(1)+test(3)+test(6)+test(9),2)];
                        if sum(st) < bestScore
                            best = test; bestScore = sum(st);
                        end
                    end
                    if bestScore < sum(s)
                        C(i,:) = best;
                        correctedBits = correctedBits + 1;
                    end
                end
            end
            data = C(:,1:encMeta.k);
            decoded = reshape(data.',[],1);
            if encMeta.pad > 0 && numel(decoded) > encMeta.pad
                decoded = decoded(1:end-encMeta.pad);
            end
            if unsat == 0
                status = "Success";
            else
                status = "Partial Success";
            end
            meta = struct('unsatisfiedChecks',unsat,'correctedBits',correctedBits,'status',status);
        end

        %% ============================================================
        %  MODULATION HELPERS
        % =============================================================
        function [idx,pad] = bitsToIntegers(app,bits,k)
            pad = mod(-numel(bits),k);
            bits = [bits(:); zeros(pad,1)];
            mat = reshape(bits,k,[]).';
            weights = 2.^(k-1:-1:0);
            idx = mat*weights.';
        end

        function bits = integersToBits(app,idx,k)
            idx = idx(:);
            mat = zeros(numel(idx),k);
            for col=1:k
                mat(:,col) = bitget(uint32(idx),k-col+1);
            end
            bits = reshape(mat.',[],1);
        end

        function const = qamConstellation(app,M)
            m = sqrt(M);
            if abs(m-round(m)) > 0
                error('QAM order must be square: 4, 16, 64, 256.');
            end
            m = round(m);
            levels = -(m-1):2:(m-1);
            [I,Q] = meshgrid(levels,levels);
            const = I(:) + 1j*Q(:);
            const = const / sqrt(mean(abs(const).^2));
        end

        function const = qpskConstellation(app)
            const = exp(1j*(2*pi*(0:3)'/4 + pi/4));
        end

        function [idxHat,decided] = nearestConstellation(app,y,const)
            D = abs(y(:) - reshape(const,1,[])).^2;
            [~,idx] = min(D,[],2);
            idxHat = idx - 1;
            decided = const(idx);
        end

        function evm = computeEVM(app,y,decided)
            if isempty(y) || isempty(decided)
                evm = NaN;
            else
                evm = rms(abs(y(:)-decided(:))) / max(rms(abs(decided(:))),eps);
            end
        end

        function waveform = fskWaveform(app,idx,M,sps)
            n = (0:sps-1);
            waveform = zeros(numel(idx)*sps,1);
            for k=1:numel(idx)
                tone = idx(k);
                segment = exp(1j*2*pi*(tone+1)*n/sps);
                waveform((k-1)*sps+1:k*sps) = segment(:);
            end
            waveform = waveform / sqrt(mean(abs(waveform).^2));
        end

        function idxHat = fskDemod(app,blocks,M,sps)
            n = (0:sps-1);
            tones = zeros(M,sps);
            for m=0:M-1
                tones(m+1,:) = exp(1j*2*pi*(m+1)*n/sps);
            end
            idxHat = zeros(size(blocks,1),1);
            for i=1:size(blocks,1)
                e = abs(tones*conj(blocks(i,:).')).^2;
                [~,id] = max(e);
                idxHat(i)=id-1;
            end
        end

        function [waveform,frames] = ofdmModulate(app,subSymbols,nfft,cpLen)
            pad = mod(-numel(subSymbols),nfft);
            s = [subSymbols(:); zeros(pad,1)];
            X = reshape(s,nfft,[]).';
            xTime = ifft(X,nfft,2)*sqrt(nfft);
            withCP = [xTime(:,end-cpLen+1:end) xTime];
            waveform = reshape(withCP.',[],1);
            frames = size(X,1);
        end

        function subRx = ofdmDemodulate(app,rxSamples,nfft,cpLen)
            frameLen = nfft + cpLen;
            nFrames = floor(numel(rxSamples)/frameLen);
            if nFrames < 1
                subRx = [];
                return;
            end
            R = reshape(rxSamples(1:nFrames*frameLen),frameLen,[]).';
            R = R(:,cpLen+1:end);
            Y = fft(R,nfft,2)/sqrt(nfft);
            subRx = reshape(Y.',[],1);
        end

        %% ============================================================
        %  CHANNEL / 3D HELPERS
        % =============================================================
        function buildings = defaultBuildings(app,cfg)
            % [x y width depth height]
            % Randomized configurable urban layout.
            %
            % Design goal:
            %   - Every Run Simulation can generate a new building layout.
            %   - Number of Buildings remains user-adjustable.
            %   - Tx/Rx safety zones are preserved.
            %   - Other blocks and signal-processing features are untouched.
            %
            % If Randomize Buildings is OFF, the user-provided Layout Seed
            % reproduces the same environment for debugging and reports.

            sx = cfg.sceneX; sy = cfg.sceneY; sz = cfg.sceneZ;
            N = max(1,min(30,round(cfg.buildingCount)));

            switch cfg.buildingDensity
                case "Sparse"
                    wRange = [0.055 0.095];
                    dRange = [0.055 0.095];
                    hRange = [0.18 0.42];
                    minGapFactor = 0.035;
                case "Dense"
                    wRange = [0.085 0.145];
                    dRange = [0.085 0.145];
                    hRange = [0.25 0.62];
                    minGapFactor = 0.010;
                otherwise
                    wRange = [0.070 0.120];
                    dRange = [0.070 0.120];
                    hRange = [0.20 0.52];
                    minGapFactor = 0.020;
            end

            % Preserve and restore MATLAB global RNG so the building-layout
            % generator does not unexpectedly disturb the other blocks.
            oldRng = rng;
            cleanupObj = onCleanup(@()rng(oldRng)); %#ok<NASGU>
            rng(double(cfg.layoutSeed),'twister');

            tx2 = cfg.txPos(1:2);
            rx2 = cfg.rxPos(1:2);
            safeR = 0.095*max(sx,sy);
            minGap = minGapFactor*max(sx,sy);

            buildings = zeros(0,5);
            maxAttempts = max(600,N*180);

            for attempt = 1:maxAttempts
                if size(buildings,1) >= N
                    break;
                end

                w = sx*(wRange(1) + diff(wRange)*rand());
                d = sy*(dRange(1) + diff(dRange)*rand());
                h = sz*(hRange(1) + diff(hRange)*rand());
                h = max(12,min(0.90*sz,h));

                x = 0.04*sx + (0.92*sx - w)*rand();
                y = 0.04*sy + (0.92*sy - d)*rand();
                candidate = [x y w d h];
                center = [x+w/2, y+d/2];

                % Keep Tx/Rx visible and avoid placing buildings directly
                % on top of terminals.
                if norm(center-tx2) < safeR || norm(center-rx2) < safeR
                    continue;
                end

                % Avoid excessive overlap. Dense scenes permit closer
                % buildings, sparse scenes keep wider street gaps.
                if app.buildingOverlaps(candidate,buildings,minGap)
                    continue;
                end

                buildings(end+1,:) = candidate; %#ok<AGROW>
            end

            % Robust fallback if the random sampler cannot place enough
            % buildings due to a small scene or large safety zones.
            fallbackIter = 0;
            while size(buildings,1) < N && fallbackIter < 200
                fallbackIter = fallbackIter + 1;
                angle = 2*pi*rand();
                radius = (0.20 + 0.38*rand())*min(sx,sy);
                cx = 0.5*sx + radius*cos(angle);
                cy = 0.5*sy + radius*sin(angle);
                w = sx*mean(wRange)*0.85;
                d = sy*mean(dRange)*0.85;
                h = max(12,sz*(hRange(1) + diff(hRange)*rand()));
                x = min(max(cx-w/2,0.03*sx),0.94*sx-w);
                y = min(max(cy-d/2,0.03*sy),0.94*sy-d);
                candidate = [x y w d h];
                center = [x+w/2, y+d/2];
                if norm(center-tx2) >= 0.75*safeR && norm(center-rx2) >= 0.75*safeR
                    if ~app.buildingOverlaps(candidate,buildings,0.25*minGap)
                        buildings(end+1,:) = candidate; %#ok<AGROW>
                    end
                end
            end
        end

        function yes = buildingOverlaps(app,candidate,buildings,gap)
            yes = false;
            if isempty(buildings)
                return;
            end
            c = [candidate(1)-gap, candidate(2)-gap, candidate(1)+candidate(3)+gap, candidate(2)+candidate(4)+gap];
            for i=1:size(buildings,1)
                b = buildings(i,:);
                r = [b(1), b(2), b(1)+b(3), b(2)+b(4)];
                overlap = ~(c(3) < r(1) || c(1) > r(3) || c(4) < r(2) || c(2) > r(4));
                if overlap
                    yes = true;
                    return;
                end
            end
        end

        function paths = buildMultipathComponents(app,tx,rx,buildings,cfg,isBlocked,blockedBy)
            paths = struct('type',{},'points',{},'distanceM',{},'delayS',{},'pathLossdB',{},'relativePowerdB',{},'note',{});
            c = cfg.c;

            % Direct component only if geometrically clear.
            if ~isBlocked
                dist = norm(rx-tx);
                loss = app.pathLossForDistance(dist,cfg.fc) + 2; % light urban shadow margin
                paths(end+1) = app.makePath("LoS Direct",[tx;rx],loss,c,"Clear direct line-of-sight"); %#ok<AGROW>
            end

            % Diffraction candidates from the blocking building top/edge.
            if isBlocked && blockedBy > 0
                b = buildings(blockedBy,:);
                corners = app.rectCorners3D(b,true);
                mid2 = 0.5*(tx(1:2)+rx(1:2));
                [~,ci] = min(sum((corners(:,1:2)-mid2).^2,2));
                p = corners(ci,:);
                pts = [tx; p; rx];
                if ~app.pathBlockedByAny(pts,buildings,blockedBy)
                    dist = app.pathDistance(pts);
                    loss = app.pathLossForDistance(dist,cfg.fc) + 8 + 16;
                    paths(end+1) = app.makePath("Diffraction",pts,loss,c,"NLoS path bending around top/edge of blocking building"); %#ok<AGROW>
                end
            end

            % Single-bounce reflection candidates from building walls.
            for i=1:size(buildings,1)
                b = buildings(i,:);
                p = app.reflectionPointOnBuilding(tx,rx,b,cfg);
                pts = [tx; p; rx];
                if app.pathBlockedByAny(pts,buildings,i)
                    continue;
                end
                dist = app.pathDistance(pts);
                loss = app.pathLossForDistance(dist,cfg.fc) + 6 + 10;
                paths(end+1) = app.makePath("Reflection",pts,loss,c,sprintf('Single-bounce reflection from Building #%d wall',i)); %#ok<AGROW>
            end

            % Sort by path loss and keep the strongest few components.
            if ~isempty(paths)
                [~,ord] = sort([paths.pathLossdB],'ascend');
                paths = paths(ord);
                maxPaths = min(numel(paths),6);
                paths = paths(1:maxPaths);
            end
        end

        function path = makePath(app,type,pts,loss,c,note)
            dist = app.pathDistance(pts);
            path = struct('type',string(type),'points',pts,'distanceM',dist, ...
                'delayS',dist/c,'pathLossdB',loss,'relativePowerdB',0,'note',string(note));
        end

        function loss = pathLossForDistance(app,distM,fcHz)
            loss = 20*log10(max(distM/1000,1e-6)) + 20*log10(fcHz/1e6) + 32.44;
        end

        function d = pathDistance(app,pts)
            d = sum(sqrt(sum(diff(pts,1,1).^2,2)));
        end

        function p = reflectionPointOnBuilding(app,tx,rx,b,cfg)
            rect = [b(1), b(2), b(1)+b(3), b(2)+b(4)];
            mid = 0.5*(tx(1:2)+rx(1:2));
            x = min(max(mid(1),rect(1)),rect(3));
            y = min(max(mid(2),rect(2)),rect(4));
            % If projected point falls inside the rectangle, snap to nearest wall.
            if x > rect(1) && x < rect(3) && y > rect(2) && y < rect(4)
                distances = [abs(x-rect(1)), abs(x-rect(3)), abs(y-rect(2)), abs(y-rect(4))];
                [~,id] = min(distances);
                switch id
                    case 1, x = rect(1);
                    case 2, x = rect(3);
                    case 3, y = rect(2);
                    case 4, y = rect(4);
                end
            end
            z = min(max(tx(3),rx(3))+18, max(6,0.62*b(5)));
            z = min(max(z,rx(3)+5),cfg.sceneZ*0.95);
            p = [x y z];
        end

        function corners = rectCorners3D(app,b,top)
            z = 0;
            if top, z = b(5)+2; end
            corners = [b(1) b(2) z;
                       b(1)+b(3) b(2) z;
                       b(1)+b(3) b(2)+b(4) z;
                       b(1) b(2)+b(4) z];
        end

        function blocked = pathBlockedByAny(app,pts,buildings,ignoreIdx)
            blocked = false;
            for s=1:size(pts,1)-1
                p1 = pts(s,:); p2 = pts(s+1,:);
                for i=1:size(buildings,1)
                    if i == ignoreIdx, continue; end
                    b = buildings(i,:);
                    rect = [b(1) b(2) b(1)+b(3) b(2)+b(4)];
                    if app.segmentIntersectsRect(p1(1:2),p2(1:2),rect) && b(5) > min(p1(3),p2(3))
                        blocked = true;
                        return;
                    end
                end
            end
        end

        function plotMultipathPDP(app,ax,ch)
            cla(ax); hold(ax,'on'); grid(ax,'on');
            if ~isfield(ch,'paths') || isempty(ch.paths)
                title(ax,'Multipath Power Delay Profile');
                text(ax,0.1,0.5,'No multipath components available');
                hold(ax,'off'); return;
            end
            delaysUs = ([ch.paths.delayS] - min([ch.paths.delayS]))*1e6;
            relP = [ch.paths.relativePowerdB];
            stem(ax,delaysUs,relP,'filled','LineWidth',1.6);
            for i=1:numel(ch.paths)
                text(ax,delaysUs(i),relP(i),sprintf('  %s',char(ch.paths(i).type)),'FontSize',9);
            end
            xlabel(ax,'Relative delay (µs)'); ylabel(ax,'Relative power (dB)');
            title(ax,'Multipath Power Delay Profile');
            ylim(ax,[min(relP)-6, 3]);
            hold(ax,'off');
        end

        function [blocked,idx] = isLinkBlocked(app,tx,rx,buildings)
            blocked = false; idx = 0;
            for i=1:size(buildings,1)
                b = buildings(i,:);
                rect = [b(1) b(2) b(1)+b(3) b(2)+b(4)];
                if app.segmentIntersectsRect(tx(1:2),rx(1:2),rect) && b(5) > min(tx(3),rx(3))
                    blocked = true; idx = i; return;
                end
            end
        end

        function yes = segmentIntersectsRect(app,p1,p2,rect)
            x1=rect(1); y1=rect(2); x2=rect(3); y2=rect(4);
            corners = [x1 y1; x2 y1; x2 y2; x1 y2];
            edges = [1 2; 2 3; 3 4; 4 1];
            yes = app.pointInRect(p1,rect) || app.pointInRect(p2,rect);
            for e=1:4
                if app.segmentsIntersect(p1,p2,corners(edges(e,1),:),corners(edges(e,2),:))
                    yes = true; return;
                end
            end
        end

        function yes = pointInRect(app,p,rect)
            yes = p(1)>=rect(1) && p(1)<=rect(3) && p(2)>=rect(2) && p(2)<=rect(4);
        end

        function yes = segmentsIntersect(app,a,b,c,d)
            yes = app.ccw(a,c,d) ~= app.ccw(b,c,d) && app.ccw(a,b,c) ~= app.ccw(a,b,d);
        end

        function v = ccw(app,a,b,c)
            v = (c(2)-a(2))*(b(1)-a(1)) > (b(2)-a(2))*(c(1)-a(1));
        end

        function out = boolChoice(app,cond,a,b)
            if cond
                out = string(a);
            else
                out = string(b);
            end
        end

        function s = dbmSum(app,vals)
            finiteVals = vals(isfinite(vals));
            if isempty(finiteVals)
                s = -Inf;
            else
                s = 10*log10(sum(10.^(finiteVals/10)));
            end
        end

        function [Nt,Nr] = parseNtNr(app,s)
            parts = split(string(s),'x');
            Nt = str2double(parts(1));
            Nr = str2double(parts(2));
        end

        %% ============================================================
        %  3D DRAWING HELPERS
        % =============================================================
        function drawBuildings(app,ax,buildings)
            for i=1:size(buildings,1)
                b = buildings(i,:);
                app.drawCuboid(ax,b(1),b(2),0,b(3),b(4),b(5));
            end
        end

        function drawCuboid(app,ax,x,y,z,w,d,h)
            X = [x x+w x+w x x x+w x+w x];
            Y = [y y y+d y+d y y y+d y+d];
            Z = [z z z z z+h z+h z+h z+h];
            faces = [1 2 3 4; 5 6 7 8; 1 2 6 5; 2 3 7 6; 3 4 8 7; 4 1 5 8];
            patch(ax,'Vertices',[X(:) Y(:) Z(:)],'Faces',faces, ...
                'FaceAlpha',0.25,'EdgeColor',[0.3 0.3 0.3]);
        end

        function drawAntennaArray(app,ax,pos,N,lambda)
            spacing = max(lambda/2,1.0); % visual spacing minimum
            for k=1:N
                offset = (k-(N+1)/2)*spacing*8;
                plot3(ax,pos(1)+offset,pos(2),pos(3),'s','MarkerSize',5,'MarkerFaceColor','k');
            end
        end

        function drawBeam(app,ax,pos,angleDeg,len)
            % Backward-compatible simple beam direction line.
            app.drawBeamCone(ax,pos,angleDeg,0,len,4);
        end

        function drawBeamCone(app,ax,pos,azDeg,elDeg,len,N)
            az = deg2rad(azDeg); el = deg2rad(elDeg);
            dir = [cos(el)*cos(az), cos(el)*sin(az), sin(el)];
            up = [0 0 1];
            if abs(dot(dir,up)) > 0.95, up = [0 1 0]; end
            v1 = cross(dir,up); v1 = v1/norm(v1);
            v2 = cross(dir,v1); v2 = v2/norm(v2);
            theta = linspace(0,2*pi,28);
            s = linspace(0,1,20);
            [TH,S] = meshgrid(theta,s);
            beamWidth = max(0.12,0.38/sqrt(max(N,1)));
            radius = len*beamWidth*S.*(0.35+0.65*S);
            center = pos + len*S(:).*dir;
            X = reshape(center(:,1),size(S)) + radius.*cos(TH)*v1(1) + radius.*sin(TH)*v2(1);
            Y = reshape(center(:,2),size(S)) + radius.*cos(TH)*v1(2) + radius.*sin(TH)*v2(2);
            Z = reshape(center(:,3),size(S)) + radius.*cos(TH)*v1(3) + radius.*sin(TH)*v2(3);
            C = S;
            surf(ax,X,Y,Z,C,'FaceAlpha',0.35,'EdgeAlpha',0.08);
            tip = pos + len*dir;
            plot3(ax,[pos(1) tip(1)],[pos(2) tip(2)],[pos(3) tip(3)],'LineWidth',2.4,'Color',[0.0 0.35 1]);
            text(ax,tip(1),tip(2),tip(3)+4,'Beam main lobe');
        end

        function mid = nlosReflectionPoint(app,tx,rx,cfg)
            base = 0.5*(tx+rx);
            dir = rx(1:2)-tx(1:2);
            if norm(dir) < eps
                normal = [0 1];
            else
                normal = [-dir(2) dir(1)]/norm(dir);
            end
            mid = [base(1:2) + 0.18*max(cfg.sceneX,cfg.sceneY)*normal, min(cfg.sceneZ*0.45, max(tx(3),rx(3))+25)];
            mid(1) = min(max(mid(1),0.05*cfg.sceneX),0.95*cfg.sceneX);
            mid(2) = min(max(mid(2),0.05*cfg.sceneY),0.95*cfg.sceneY);
        end

        function plotBeamPattern3D(app,ax,cfg,ch)
            cla(ax); hold(ax,'on'); grid(ax,'on'); view(ax,3);
            title(ax,'3D Beam Pattern / Radiation Direction');
            xlabel(ax,'x'); ylabel(ax,'y'); zlabel(ax,'z');
            az0 = deg2rad(cfg.beamAngleDeg); el0 = deg2rad(cfg.beamElevationDeg);
            [AZ,EL] = meshgrid(linspace(-pi,pi,120),linspace(-pi/2,pi/2,60));
            ux = cos(EL).*cos(AZ); uy = cos(EL).*sin(AZ); uz = sin(EL);
            u0 = [cos(el0)*cos(az0), cos(el0)*sin(az0), sin(el0)];
            cosang = max(-1,min(1,ux*u0(1)+uy*u0(2)+uz*u0(3)));
            ang = acos(cosang);
            mainWidth = max(0.12,0.42/sqrt(max(ch.Nt,1)));
            Rmain = exp(-(ang/mainWidth).^2);
            Rside = 0.15*(cos(max(ch.Nt,2)*ang).^2).*exp(-(ang/(2.8*mainWidth)).^2);
            R = Rmain + Rside;
            R = R/max(R(:));
            X = R.*ux; Y = R.*uy; Z = R.*uz;
            surf(ax,X,Y,Z,R,'EdgeAlpha',0.05,'FaceAlpha',0.88);
            plot3(ax,[0 u0(1)*1.25],[0 u0(2)*1.25],[0 u0(3)*1.25],'k-','LineWidth',2);
            text(ax,u0(1)*1.32,u0(2)*1.32,u0(3)*1.32,'Steering direction');
            axis(ax,'equal'); colormap(ax,'turbo'); colorbar(ax);
            hold(ax,'off');
        end

        function plotCoverageMap(app,ax,cfg,ch)
            x = linspace(0,cfg.sceneX,80);
            y = linspace(0,cfg.sceneY,70);
            [X,Y] = meshgrid(x,y);
            Pr = zeros(size(X));
            beamAz = deg2rad(cfg.beamAngleDeg);
            beamDir = [cos(beamAz) sin(beamAz)];
            for i=1:numel(X)
                p = [X(i) Y(i) 1.5];
                d = norm(p - cfg.txPos);
                fspl = 20*log10(max(d/1000,1e-6)) + 20*log10(cfg.fc/1e6) + 32.44;
                extraBeam = 0;
                if cfg.envMode == "MIMO + Beamforming"
                    v = [X(i)-cfg.txPos(1), Y(i)-cfg.txPos(2)];
                    if norm(v) > eps
                        angGain = max(0,dot(v/norm(v),beamDir));
                        extraBeam = ch.beamGaindB*(angGain^6);
                    end
                end
                Pr(i) = cfg.txPowerdBm + cfg.txGaindBi + cfg.rxGaindBi + extraBeam - fspl - 5;
            end
            imagesc(ax,x,y,Pr); axis(ax,'xy'); colorbar(ax);
            hold(ax,'on');
            plot(ax,cfg.txPos(1),cfg.txPos(2),'^','MarkerSize',8,'MarkerFaceColor','k');
            plot(ax,cfg.rxPos(1),cfg.rxPos(2),'o','MarkerSize',8,'MarkerFaceColor','k');
            hold(ax,'off');
            title(ax,'Received Power Map (dBm)'); xlabel(ax,'x (m)'); ylabel(ax,'y (m)');
        end
    end
end
