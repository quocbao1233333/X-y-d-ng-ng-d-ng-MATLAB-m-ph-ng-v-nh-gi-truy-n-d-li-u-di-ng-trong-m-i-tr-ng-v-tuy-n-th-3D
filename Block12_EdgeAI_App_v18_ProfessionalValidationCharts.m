
function Block12_EdgeAI_App_v18_ProfessionalValidationCharts()
% BLOCK12_EDGEAI_APP_V18_PROFESSIONALVALIDATIONCHARTS_REDOWNLOAD_V3
% -------------------------------------------------------------------------
% Khối 12 - AI / Edge Intelligence / Application Layer
%
% Version v18:
% - Adds Device Type.
% - Adds Input Data Type.
% - Adds Auto Recommend AI Model.
% - Adds model compatibility warning.
% - AI Model now affects model complexity, feature dimension, inference
%   delay, memory footprint, operations, confidence behavior and route cost.
% - Keeps the older educational simulation features:
%   3D architecture, Run Simulation, Random Payload, Reset Scene,
%   Focus 3D / Balanced Layout / Wide Info Panels,
%   spatial view controls, detailed metrics and theory review.
%
% How to run:
% >> Block12_EdgeAI_App_v18_ProfessionalValidationCharts_Redownload_v3
% -------------------------------------------------------------------------

clc;

%% ===================== APP STATE =====================
app = struct();

% Colors
app.C.device    = [0.10 0.45 0.95];
app.C.ran       = [0.10 0.65 0.85];
app.C.core      = [0.20 0.70 0.55];
app.C.edge      = [0.95 0.65 0.15];
app.C.ai        = [0.85 0.25 0.55];
app.C.decision  = [0.55 0.35 0.85];
app.C.dashboard = [0.25 0.75 0.35];
app.C.cloud     = [0.62 0.62 0.78];
app.C.link      = [0.10 0.25 0.75];
app.C.ok        = [0.10 0.65 0.20];
app.C.bad       = [0.90 0.20 0.15];
app.C.warn      = [0.95 0.55 0.10];

% UI sizes
app.ui.leftWidth = 300;
app.ui.rightWidth = 260;

% Base coordinates
app.baseP.iot       = [-13.0  0.0 1.0];
app.baseP.gnb       = [ -8.3  0.0 2.0];
app.baseP.upf       = [ -3.8  0.0 1.6];
app.baseP.mec       = [  0.8  0.0 1.6];
app.baseP.receiver  = [  5.2  2.6 1.8];
app.baseP.pre       = [  9.5  2.6 1.8];
app.baseP.feature   = [ 13.8  2.6 1.8];
app.baseP.ai        = [ 18.2  2.6 2.0];
app.baseP.decision  = [ 22.6  2.6 1.8];
app.baseP.response  = [ 27.0  2.6 1.8];
app.baseP.dashboard = [ 27.0 -3.6 1.5];
app.baseP.cloud     = [ 18.2 -7.2 2.6];

app.layout.xScale = 1.00;
app.layout.yScale = 1.20;
app.layout.zScale = 1.25;
app.view.az = 28;
app.view.el = 20;
app.view.zoom = 1.00;

app.P = struct();
app.packetHandle = [];
app.lastResult = [];
app.lastBatchTable = [];
app.lastRouteTable = [];
app.lastValidationMetrics = [];

%% ===================== FIGURE / LAYOUT =====================
fig = uifigure( ...
    'Name', 'Khối 12 - AI / Edge Intelligence / Application Layer - v16 Fix Validation Summary Panel - Redownload v3', ...
    'Position', [10 20 1820 980], ...
    'Color', [0.97 0.98 1.00]);

app.rootGrid = uigridlayout(fig, [2 1]);
app.rootGrid.RowHeight = {96, '1x'};
app.rootGrid.ColumnWidth = {'1x'};
app.rootGrid.Padding = [8 8 8 8];
app.rootGrid.RowSpacing = 8;

%% Top toolbar
toolbarPanel = uipanel(app.rootGrid, ...
    'Title', 'Thanh công cụ bố cục - TRUE 3D FULLSCREEN có thể ẩn panel trái/phải về 0 px', ...
    'FontWeight', 'bold', 'FontSize', 13);
toolbarPanel.Layout.Row = 1;

toolbarGrid = uigridlayout(toolbarPanel, [2 6]);
toolbarGrid.RowHeight = {26, 28};
toolbarGrid.ColumnWidth = {110, '1x', 60, 110, '1x', 60};
toolbarGrid.Padding = [10 8 10 8];
toolbarGrid.RowSpacing = 6;
toolbarGrid.ColumnSpacing = 8;

uilabel(toolbarGrid, 'Text', 'Left panel width', 'FontWeight', 'bold');
app.slLeftWidth = uislider(toolbarGrid, 'Limits', [0 620], 'Value', app.ui.leftWidth, ...
    'MajorTicks', [0 120 240 360 480 620], 'ValueChangedFcn', @updateMainLayout);
app.slLeftWidth.Layout.Column = 2;
app.lbLeftWidth = uilabel(toolbarGrid, 'Text', sprintf('%d px', app.ui.leftWidth), ...
    'HorizontalAlignment', 'center');
app.lbLeftWidth.Layout.Column = 3;

uilabel(toolbarGrid, 'Text', 'Right panel width', 'FontWeight', 'bold');
app.slRightWidth = uislider(toolbarGrid, 'Limits', [0 520], 'Value', app.ui.rightWidth, ...
    'MajorTicks', [0 100 200 300 400 520], 'ValueChangedFcn', @updateMainLayout);
app.slRightWidth.Layout.Column = 5;
app.lbRightWidth = uilabel(toolbarGrid, 'Text', sprintf('%d px', app.ui.rightWidth), ...
    'HorizontalAlignment', 'center');
app.lbRightWidth.Layout.Column = 6;

app.btnFocus3D = uibutton(toolbarGrid, 'push', 'Text', 'TRUE 3D FULLSCREEN', ...
    'ButtonPushedFcn', @presetFocus3D, 'FontWeight', 'bold');
app.btnFocus3D.Layout.Row = 2;
app.btnFocus3D.Layout.Column = [1 2];

app.btnBalanced = uibutton(toolbarGrid, 'push', 'Text', 'Balanced Layout', ...
    'ButtonPushedFcn', @presetBalanced);
app.btnBalanced.Layout.Row = 2;
app.btnBalanced.Layout.Column = [3 4];

app.btnInfoWide = uibutton(toolbarGrid, 'push', 'Text', 'Wide Info Panels', ...
    'ButtonPushedFcn', @presetWideInfo);
app.btnInfoWide.Layout.Row = 2;
app.btnInfoWide.Layout.Column = [5 6];

%% Content
app.contentGrid = uigridlayout(app.rootGrid, [1 3]);
app.contentGrid.Layout.Row = 2;
app.contentGrid.ColumnWidth = {app.ui.leftWidth, '1x', app.ui.rightWidth};
app.contentGrid.RowHeight = {'1x'};
app.contentGrid.Padding = [0 0 0 0];
app.contentGrid.ColumnSpacing = 10;

%% ===================== LEFT PANEL =====================
leftPanel = uipanel(app.contentGrid, ...
    'Title', 'Điều khiển mô phỏng Khối 12', ...
    'FontWeight', 'bold', 'FontSize', 14);
leftPanel.Layout.Column = 1;
app.leftPanel = leftPanel;

% v11 FIX:
% The parameter list is now separated into tabs.
% This avoids the old problem where the long input list was clipped or hidden
% even when scrollbars were enabled. Action buttons stay fixed at the top.
leftOuter = uigridlayout(leftPanel, [2 1]);
leftOuter.RowHeight = {170, '1x'};
leftOuter.ColumnWidth = {'1x'};
leftOuter.Padding = [8 8 8 8];
leftOuter.RowSpacing = 8;

actionPanel = uipanel(leftOuter, ...
    'Title', 'Simulation Actions - luôn nhìn thấy', ...
    'FontWeight', 'bold');
actionPanel.Layout.Row = 1;

actionGrid = uigridlayout(actionPanel, [2 2]);
actionGrid.RowHeight = {50, 50};
actionGrid.ColumnWidth = {'1x', '1x'};
actionGrid.Padding = [10 10 10 10];
actionGrid.RowSpacing = 10;
actionGrid.ColumnSpacing = 10;

app.btnRun = uibutton(actionGrid, 'push', ...
    'Text', '▶ Run Simulation', ...
    'FontWeight', 'bold', ...
    'FontSize', 13, ...
    'ButtonPushedFcn', @runSimulation);
app.btnRun.Layout.Row = 1;
app.btnRun.Layout.Column = 1;

app.btnRandom = uibutton(actionGrid, 'push', ...
    'Text', 'Random Payload', ...
    'ButtonPushedFcn', @randomPayload);
app.btnRandom.Layout.Row = 1;
app.btnRandom.Layout.Column = 2;

app.btnReset = uibutton(actionGrid, 'push', ...
    'Text', 'Reset Scene', ...
    'ButtonPushedFcn', @resetScene);
app.btnReset.Layout.Row = 2;
app.btnReset.Layout.Column = 1;

app.btnTheory = uibutton(actionGrid, 'push', ...
    'Text', 'Theory Review - Block 12', ...
    'ButtonPushedFcn', @showFullTheory);
app.btnTheory.Layout.Row = 2;
app.btnTheory.Layout.Column = 2;

inputTabGroup = uitabgroup(leftOuter);
inputTabGroup.Layout.Row = 2;

tabBasic = uitab(inputTabGroup, 'Title', '1. Basic / AI');
tabTiming = uitab(inputTabGroup, 'Title', '2. Network / Timing');
tabGuide = uitab(inputTabGroup, 'Title', '3. Guide');
tabValidation = uitab(inputTabGroup, 'Title', '4. Validation');

% --------------------- TAB 1: BASIC / AI ---------------------
basicGrid = uigridlayout(tabBasic, [12 2]);
basicGrid.RowHeight = {30,30,30,30,30,58,30,30,30,30,30,'1x'};
basicGrid.ColumnWidth = {145, '1x'};
basicGrid.Padding = [12 10 12 10];
basicGrid.RowSpacing = 7;
basicGrid.ColumnSpacing = 10;

uilabel(basicGrid, 'Text', 'Application Type:', 'FontWeight', 'bold');
app.ddAppType = uidropdown(basicGrid, ...
    'Items', {'Smart Factory - Anomaly Detection', ...
              'Healthcare IoT - Health Alert', ...
              'Smart City - Camera AI', ...
              'Agriculture IoT - Irrigation', ...
              'Logistics - Route Monitoring'}, ...
    'Value', 'Smart Factory - Anomaly Detection', ...
    'ValueChangedFcn', @appTypeChanged);

uilabel(basicGrid, 'Text', 'Device Type:', 'FontWeight', 'bold');
app.ddDeviceType = uidropdown(basicGrid, ...
    'Items', {'Industrial Machine Sensor', ...
              'Healthcare Wearable', ...
              'Traffic Camera', ...
              'Agriculture Sensor', ...
              'GPS Logistics Tracker'}, ...
    'Value', 'Industrial Machine Sensor', ...
    'ValueChangedFcn', @deviceOrDataTypeChanged);

uilabel(basicGrid, 'Text', 'Input Data Type:', 'FontWeight', 'bold');
app.ddDataType = uidropdown(basicGrid, ...
    'Items', {'Sensor Vector', ...
              'Image / Video Frame', ...
              'Time-Series Signal', ...
              'GPS Trajectory', ...
              'Event Log'}, ...
    'Value', 'Sensor Vector', ...
    'ValueChangedFcn', @deviceOrDataTypeChanged);

app.cbAutoRecommend = uicheckbox(basicGrid, ...
    'Text', 'Auto Recommend AI Model', ...
    'Value', true, ...
    'FontWeight', 'bold', ...
    'ValueChangedFcn', @autoRecommendChanged);
app.cbAutoRecommend.Layout.Column = [1 2];

uilabel(basicGrid, 'Text', 'AI Model:', 'FontWeight', 'bold');
app.ddModel = uidropdown(basicGrid, ...
    'Items', {'MLP Sensor Classifier', 'CNN Camera AI', 'LSTM Time-Series', 'Anomaly Detector'}, ...
    'Value', 'Anomaly Detector', ...
    'ValueChangedFcn', @manualModelChanged);

app.lbModelHint = uilabel(basicGrid, ...
    'Text', 'Recommended: Anomaly Detector for fault/anomaly event.', ...
    'WordWrap', 'on', ...
    'FontAngle', 'italic', ...
    'FontColor', [0.20 0.25 0.65]);
app.lbModelHint.Layout.Column = [1 2];

uilabel(basicGrid, 'Text', 'Inference Route:', 'FontWeight', 'bold');
app.ddRoute = uidropdown(basicGrid, ...
    'Items', {'MEC Only', 'Edge-Cloud Cooperation', 'Cloud Only'}, ...
    'Value', 'MEC Only', ...
    'ValueChangedFcn', @syncPreviewFromControls);

uilabel(basicGrid, 'Text', 'Packet ID:', 'FontWeight', 'bold');
app.edPacketID = uieditfield(basicGrid, 'text', 'Value', 'PKT-0001', 'ValueChangedFcn', @syncPreviewFromControls);

uilabel(basicGrid, 'Text', 'Device ID:', 'FontWeight', 'bold');
app.edDeviceID = uieditfield(basicGrid, 'text', 'Value', 'IoT-2268', 'ValueChangedFcn', @syncPreviewFromControls);

uilabel(basicGrid, 'Text', 'Sensor Value 1:', 'FontWeight', 'bold');
app.edTemp = uieditfield(basicGrid, 'numeric', 'Value', 78, 'Limits', [0 200], ...
    'RoundFractionalValues', 'off', 'ValueChangedFcn', @syncPreviewFromControls);

uilabel(basicGrid, 'Text', 'Sensor State:', 'FontWeight', 'bold');
app.ddVibration = uidropdown(basicGrid, 'Items', {'Low', 'Medium', 'High'}, ...
    'Value', 'High', 'ValueChangedFcn', @syncPreviewFromControls);

% --------------------- TAB 2: NETWORK / TIMING ---------------------
timingGrid = uigridlayout(tabTiming, [13 2]);
timingGrid.RowHeight = {30,30,30,30,30,30,30,30,30,30,30,30,'1x'};
timingGrid.ColumnWidth = {145, '1x'};
timingGrid.Padding = [12 10 12 10];
timingGrid.RowSpacing = 7;
timingGrid.ColumnSpacing = 10;

uilabel(timingGrid, 'Text', 'Packet Size (kB):', 'FontWeight', 'bold');
app.edPacketSize = uieditfield(timingGrid, 'numeric', 'Value', 32, 'Limits', [1 10000], ...
    'RoundFractionalValues', 'off', 'ValueChangedFcn', @syncPreviewFromControls);

uilabel(timingGrid, 'Text', 'Data Rate (Mbps):', 'FontWeight', 'bold');
app.edDataRate = uieditfield(timingGrid, 'numeric', 'Value', 10, 'Limits', [0.1 10000], ...
    'RoundFractionalValues', 'off', 'ValueChangedFcn', @syncPreviewFromControls);

uilabel(timingGrid, 'Text', 'PDR_E2E:', 'FontWeight', 'bold');
app.edPDR = uieditfield(timingGrid, 'numeric', 'Value', 0.936, 'Limits', [0 1], ...
    'RoundFractionalValues', 'off', 'ValueChangedFcn', @syncPreviewFromControls);

uilabel(timingGrid, 'Text', 'T_network (ms):', 'FontWeight', 'bold');
app.edTnetwork = uieditfield(timingGrid, 'numeric', 'Value', 63, 'Limits', [0 2000], ...
    'ValueChangedFcn', @syncPreviewFromControls);

uilabel(timingGrid, 'Text', 'T_pre (ms):', 'FontWeight', 'bold');
app.edTpre = uieditfield(timingGrid, 'numeric', 'Value', 3, 'Limits', [0 1000], ...
    'ValueChangedFcn', @syncPreviewFromControls);

uilabel(timingGrid, 'Text', 'T_infer base (ms):', 'FontWeight', 'bold');
app.edTinfer = uieditfield(timingGrid, 'numeric', 'Value', 7, 'Limits', [0 1000], ...
    'ValueChangedFcn', @syncPreviewFromControls);

uilabel(timingGrid, 'Text', 'T_post (ms):', 'FontWeight', 'bold');
app.edTpost = uieditfield(timingGrid, 'numeric', 'Value', 2, 'Limits', [0 1000], ...
    'ValueChangedFcn', @syncPreviewFromControls);

uilabel(timingGrid, 'Text', 'T_response (ms):', 'FontWeight', 'bold');
app.edTresponse = uieditfield(timingGrid, 'numeric', 'Value', 5, 'Limits', [0 1000], ...
    'ValueChangedFcn', @syncPreviewFromControls);

uilabel(timingGrid, 'Text', 'SLA Delay (ms):', 'FontWeight', 'bold');
app.edSLA = uieditfield(timingGrid, 'numeric', 'Value', 100, 'Limits', [1 5000], ...
    'ValueChangedFcn', @syncPreviewFromControls);

uilabel(timingGrid, 'Text', 'AI Threshold (%):', 'FontWeight', 'bold');
app.edThreshold = uieditfield(timingGrid, 'numeric', 'Value', 80, 'Limits', [1 99], ...
    'ValueChangedFcn', @syncPreviewFromControls);

uilabel(timingGrid, 'Text', 'Energy Base (J):', 'FontWeight', 'bold');
app.edEnergy = uieditfield(timingGrid, 'numeric', 'Value', 0.42, 'Limits', [0 1000], ...
    'ValueChangedFcn', @syncPreviewFromControls);

app.cbAutoInput = uicheckbox(timingGrid, ...
    'Text', 'Run giữ thông số hiện tại', ...
    'Value', true, ...
    'FontWeight', 'bold');
app.cbAutoInput.Layout.Column = [1 2];

% --------------------- TAB 3: GUIDE ---------------------
guideGrid = uigridlayout(tabGuide, [1 1]);
guideGrid.Padding = [10 10 10 10];

app.leftGuide = uitextarea(guideGrid, ...
    'Editable', 'off', ...
    'FontName', 'Consolas', ...
    'FontSize', 12, ...
    'Value', { ...
        'HƯỚNG DẪN PANEL TRÁI v18'; ...
        '================================'; ...
        ''; ...
        'Tab 1. Basic / AI:'; ...
        '- Chọn Application Type.'; ...
        '- Chọn Device Type.'; ...
        '- Chọn Input Data Type.'; ...
        '- Bật Auto Recommend để app tự chọn AI Model phù hợp.'; ...
        '- Nếu chọn sai model, app sẽ cảnh báo compatibility.'; ...
        ''; ...
        'Tab 2. Network / Timing:'; ...
        '- Chỉnh Packet Size, Data Rate, PDR_E2E.'; ...
        '- Chỉnh T_network, T_pre, T_infer, T_post, T_response.'; ...
        '- Chỉnh SLA Delay, AI Threshold, Energy Base.'; ...
        '- Run Simulation sẽ dùng đúng thông số hiện tại người dùng đang gán.'; ...
        ''; ...
        'Tab 4. Validation:'; ...
        '- Random Payload là nút duy nhất dùng để sinh input ngẫu nhiên.'; ...
        '- Route Comparison: so sánh MEC / Edge-Cloud / Cloud.'; ...
        '- Export CSV: xuất kết quả batch hoặc route comparison.'; ...
        ''; ...
        'TRUE 3D FULLSCREEN giúp vùng 3D làm trung tâm. Balanced Layout sẽ hiện lại panel.'});

% --------------------- TAB 4: VALIDATION ---------------------
validationGrid = uigridlayout(tabValidation, [9 2]);
validationGrid.RowHeight = {32,32,32,42,42,42,42,42,'1x'};
validationGrid.ColumnWidth = {165, '1x'};
validationGrid.Padding = [12 10 12 10];
validationGrid.RowSpacing = 8;
validationGrid.ColumnSpacing = 10;

uilabel(validationGrid, 'Text', 'Batch packets:', 'FontWeight', 'bold');
app.edBatchN = uieditfield(validationGrid, 'numeric', ...
    'Value', 200, ...
    'Limits', [10 5000], ...
    'RoundFractionalValues', 'on');

uilabel(validationGrid, 'Text', 'Validation mode:', 'FontWeight', 'bold');
app.ddValidationMode = uidropdown(validationGrid, ...
    'Items', {'Random mixed applications', 'Current application only'}, ...
    'Value', 'Random mixed applications');

uilabel(validationGrid, 'Text', 'Metric focus:', 'FontWeight', 'bold');
app.ddMetricFocus = uidropdown(validationGrid, ...
    'Items', {'Latency / SLA', 'AI Quality', 'Energy / Route Cost'}, ...
    'Value', 'Latency / SLA');

app.btnBatchSim = uibutton(validationGrid, 'push', ...
    'Text', 'Run Batch Simulation', ...
    'FontWeight', 'bold', ...
    'ButtonPushedFcn', @runBatchSimulation);
app.btnBatchSim.Layout.Column = [1 2];

app.btnCompareRoutes = uibutton(validationGrid, 'push', ...
    'Text', 'Compare Routes', ...
    'ButtonPushedFcn', @compareRoutes);
app.btnCompareRoutes.Layout.Column = [1 2];

app.btnExportCSV = uibutton(validationGrid, 'push', ...
    'Text', 'Export CSV', ...
    'ButtonPushedFcn', @exportLastResults);
app.btnExportCSV.Layout.Column = [1 2];

app.btnReportSummary = uibutton(validationGrid, 'push', ...
    'Text', 'Export Report Summary', ...
    'ButtonPushedFcn', @exportReportSummary);
app.btnReportSummary.Layout.Column = [1 2];

app.btnValidationHelp = uibutton(validationGrid, 'push', ...
    'Text', 'Validation Theory', ...
    'ButtonPushedFcn', @showValidationTheory);
app.btnValidationHelp.Layout.Column = [1 2];

app.validationHint = uitextarea(validationGrid, ...
    'Editable', 'off', ...
    'FontName', 'Consolas', ...
    'FontSize', 12, ...
    'Value', { ...
        'MỤC TIÊU VALIDATION v18'; ...
        '================================'; ...
        ''; ...
        '1) Không chỉ chạy 1 packet'; ...
        '   Một packet chỉ chứng minh pipeline hoạt động.'; ...
        '   Kỹ sư cần nhiều packet để xem hệ thống ổn định không.'; ...
        ''; ...
        '2) Batch Simulation'; ...
        '   Chạy N packet để lấy mean delay, P95 delay,'; ...
        '   SLA pass-rate, mean energy, mean confidence.'; ...
        ''; ...
        '3) Route Comparison'; ...
        '   So sánh MEC Only, Edge-Cloud Cooperation, Cloud Only.'; ...
        '   Mục tiêu là thấy trade-off giữa latency, energy,'; ...
        '   privacy score và route cost.'; ...
        ''; ...
        '4) AI Validation Metrics'; ...
        '   Accuracy, Precision, Recall, F1-score và confusion matrix'; ...
        '   giúp đánh giá kết quả event/anomaly detection.'; ...
        ''; ...
        '5) Export CSV / Report Summary'; ...
        '   Xuất bảng kết quả và tự sinh tóm tắt báo cáo kỹ thuật.'; ...
        ''; ...
        'Ghi chú:'; ...
        'Ô này đã được mở rộng và có thanh cuộn dọc.'; ...
        'Nếu nội dung dài, kéo thanh cuộn trong ô này để đọc hết.'});
app.validationHint.Layout.Row = 9;
app.validationHint.Layout.Column = [1 2];


%% ===================== CENTER PANEL =====================
centerPanel = uipanel(app.contentGrid, ...
    'Title', 'Kiến trúc 3D Khối 12 - MEC-based Edge AI Application', ...
    'FontWeight', 'bold', 'FontSize', 14);
centerPanel.Layout.Column = 2;

centerGrid = uigridlayout(centerPanel, [2 1]);
centerGrid.RowHeight = {92, '1x'};
centerGrid.ColumnWidth = {'1x'};
centerGrid.Padding = [8 8 8 8];
centerGrid.RowSpacing = 8;

viewPanel = uipanel(centerGrid, 'Title', 'Điều chỉnh không gian 3D và góc nhìn', 'FontWeight', 'bold');
viewPanel.Layout.Row = 1;

viewGrid = uigridlayout(viewPanel, [2 6]);
viewGrid.RowHeight = {18, 28};
viewGrid.ColumnWidth = {'1x', '1x', '1x', '1x', '1x', '1x'};
viewGrid.Padding = [10 8 10 8];
viewGrid.RowSpacing = 6;
viewGrid.ColumnSpacing = 12;

labels = {'X spacing', 'Y spread', 'Height', 'Azimuth', 'Elevation', 'Zoom'};
for ii = 1:6
    uilabel(viewGrid, 'Text', labels{ii}, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
end

app.edXScale = uieditfield(viewGrid, 'numeric', 'Value', app.layout.xScale, ...
    'Limits', [0.75 1.80], 'RoundFractionalValues', 'off', 'ValueChangedFcn', @applyViewLayoutControls);
app.edYScale = uieditfield(viewGrid, 'numeric', 'Value', app.layout.yScale, ...
    'Limits', [0.80 2.20], 'RoundFractionalValues', 'off', 'ValueChangedFcn', @applyViewLayoutControls);
app.edZScale = uieditfield(viewGrid, 'numeric', 'Value', app.layout.zScale, ...
    'Limits', [0.80 2.40], 'RoundFractionalValues', 'off', 'ValueChangedFcn', @applyViewLayoutControls);
app.edAzimuth = uieditfield(viewGrid, 'numeric', 'Value', app.view.az, ...
    'Limits', [-180 180], 'RoundFractionalValues', 'off', 'ValueChangedFcn', @applyViewLayoutControls);
app.edElevation = uieditfield(viewGrid, 'numeric', 'Value', app.view.el, ...
    'Limits', [-20 85], 'RoundFractionalValues', 'off', 'ValueChangedFcn', @applyViewLayoutControls);
app.edZoom = uieditfield(viewGrid, 'numeric', 'Value', app.view.zoom, ...
    'Limits', [0.60 1.80], 'RoundFractionalValues', 'off', 'ValueChangedFcn', @applyViewLayoutControls);

app.ax = uiaxes(centerGrid);
app.ax.Layout.Row = 2;

%% ===================== RIGHT PANEL =====================
rightPanel = uipanel(app.contentGrid, ...
    'Title', 'Thông tin / Công thức / Kết quả', ...
    'FontWeight', 'bold', 'FontSize', 14);
rightPanel.Layout.Column = 3;
app.rightPanel = rightPanel;

rightGrid = uigridlayout(rightPanel, [3 1]);
rightGrid.RowHeight = {310, 300, '1x'};
rightGrid.Padding = [8 8 8 8];
rightGrid.RowSpacing = 8;

app.statusTable = uitable(rightGrid);
app.statusTable.ColumnName = {'Thông số', 'Giá trị'};
app.statusTable.ColumnWidth = {155, 'auto'};
app.statusTable.Data = defaultTable();

app.infoArea = uitextarea(rightGrid, 'Editable', 'off', 'FontName', 'Consolas', 'FontSize', 11);
app.logArea = uitextarea(rightGrid, 'Editable', 'off', 'FontName', 'Consolas', 'FontSize', 11, ...
    'Value', {'Log mô phỏng sẽ hiển thị tại đây.'});

%% ===================== INITIALIZATION =====================
updateLayoutPositions();
applyRecommendation(false);
drawScene();
syncPreviewFromControls();
showNodeInfo('Overview');

%% ===================== CALLBACKS =====================
    function updateMainLayout(~, ~)
        % v13: Collapsible side panels.
        % If slider value is near 0, the corresponding panel is hidden and
        % its grid column is set to 0 px. This gives the 3D axes the maximum
        % possible width without destroying any old feature.
        app.ui.leftWidth = round(app.slLeftWidth.Value);
        app.ui.rightWidth = round(app.slRightWidth.Value);

        leftCol = app.ui.leftWidth;
        rightCol = app.ui.rightWidth;

        if app.ui.leftWidth <= 5
            leftCol = 0;
            if isfield(app, 'leftPanel') && isvalid(app.leftPanel)
                app.leftPanel.Visible = 'off';
            end
            app.lbLeftWidth.Text = 'hidden';
        else
            if isfield(app, 'leftPanel') && isvalid(app.leftPanel)
                app.leftPanel.Visible = 'on';
            end
            app.lbLeftWidth.Text = sprintf('%d px', app.ui.leftWidth);
        end

        if app.ui.rightWidth <= 5
            rightCol = 0;
            if isfield(app, 'rightPanel') && isvalid(app.rightPanel)
                app.rightPanel.Visible = 'off';
            end
            app.lbRightWidth.Text = 'hidden';
        else
            if isfield(app, 'rightPanel') && isvalid(app.rightPanel)
                app.rightPanel.Visible = 'on';
            end
            app.lbRightWidth.Text = sprintf('%d px', app.ui.rightWidth);
        end

        app.contentGrid.ColumnWidth = {leftCol, '1x', rightCol};
        drawnow limitrate;
    end

    function presetFocus3D(~, ~)
        % TRUE 3D FULLSCREEN mode:
        % Hide both side panels and set their widths to 0.
        % Balanced Layout restores the panels.
        app.slLeftWidth.Value = 0;
        app.slRightWidth.Value = 0;
        updateMainLayout();

        % Give the 3D view a better default center-stage camera.
        app.view.az = 26;
        app.view.el = 18;
        app.view.zoom = 1.12;
        app.edAzimuth.Value = app.view.az;
        app.edElevation.Value = app.view.el;
        app.edZoom.Value = app.view.zoom;
        drawScene();

        setLog('TRUE 3D FULLSCREEN: đã ẩn hoàn toàn panel trái/phải và đặt width = 0 px. Bấm Balanced Layout để hiện lại.');
    end

    function presetBalanced(~, ~)
        % Restore compact side panels.
        app.slLeftWidth.Value = 300;
        app.slRightWidth.Value = 260;
        updateMainLayout();
        setLog('Balanced Layout: hiện lại panel trái/phải ở kích thước gọn để vùng 3D rộng hơn.');
    end

    function presetWideInfo(~, ~)
        % Restore both panels with more room for reading information.
        app.slLeftWidth.Value = 420;
        app.slRightWidth.Value = 420;
        updateMainLayout();
        setLog('Wide Info Panels: mở rộng panel thông tin để đọc bảng metric/lý thuyết.');
    end

    function appTypeChanged(~, ~)
        % App type defines a default device and input data type.
        switch string(app.ddAppType.Value)
            case "Smart Factory - Anomaly Detection"
                app.ddDeviceType.Value = 'Industrial Machine Sensor';
                app.ddDataType.Value = 'Event Log';
            case "Healthcare IoT - Health Alert"
                app.ddDeviceType.Value = 'Healthcare Wearable';
                app.ddDataType.Value = 'Time-Series Signal';
            case "Smart City - Camera AI"
                app.ddDeviceType.Value = 'Traffic Camera';
                app.ddDataType.Value = 'Image / Video Frame';
            case "Agriculture IoT - Irrigation"
                app.ddDeviceType.Value = 'Agriculture Sensor';
                app.ddDataType.Value = 'Sensor Vector';
            case "Logistics - Route Monitoring"
                app.ddDeviceType.Value = 'GPS Logistics Tracker';
                app.ddDataType.Value = 'GPS Trajectory';
        end
        applyRecommendation(true);
        syncPreviewFromControls();
    end

    function deviceOrDataTypeChanged(~, ~)
        applyRecommendation(true);
        syncPreviewFromControls();
    end

    function autoRecommendChanged(~, ~)
        applyRecommendation(true);
        syncPreviewFromControls();
    end

    function manualModelChanged(~, ~)
        compatibility = checkModelCompatibility();
        app.lbModelHint.Text = compatibility.message;
        if compatibility.ok
            app.lbModelHint.FontColor = [0.20 0.45 0.20];
        else
            app.lbModelHint.FontColor = [0.85 0.20 0.10];
        end
        syncPreviewFromControls();
    end

    function applyRecommendation(showMsg)
        rec = getRecommendedModel();
        if app.cbAutoRecommend.Value
            app.ddModel.Value = rec.model;
        end

        compatibility = checkModelCompatibility();
        app.lbModelHint.Text = compatibility.message;

        if compatibility.ok
            app.lbModelHint.FontColor = [0.20 0.45 0.20];
        else
            app.lbModelHint.FontColor = [0.85 0.20 0.10];
        end

        if nargin > 0 && showMsg
            if app.cbAutoRecommend.Value
                setLog(sprintf('Auto Recommend AI Model: %s\nReason: %s', rec.model, rec.reason));
            else
                setLog(sprintf('Auto Recommend OFF.\nRecommended model would be: %s\nReason: %s', rec.model, rec.reason));
            end
        end
    end

    function applyViewLayoutControls(~, ~)
        app.layout.xScale = app.edXScale.Value;
        app.layout.yScale = app.edYScale.Value;
        app.layout.zScale = app.edZScale.Value;
        app.view.az = app.edAzimuth.Value;
        app.view.el = app.edElevation.Value;
        app.view.zoom = app.edZoom.Value;
        drawScene();
        syncPreviewFromControls();
    end

    function runSimulation(~, ~)
        % v17 FIX:
        % Run Simulation MUST use the exact parameters currently shown in the UI.
        % It must NOT call generateNewInput(), because that changes user-assigned
        % Packet ID, Device ID, route, timing, SLA, model, etc.
        % Use the Random Payload button when random input is desired.
        if app.cbAutoRecommend.Value
            % Only update the recommended model/compatibility text.
            % This does not randomize any user input.
            applyRecommendation(false);
        end

        result = computeResult();
        app.lastResult = result;
        updateStatusTable(result);
        showResultInfo(result);
        drawScene();

        if ~result.compatibilityOK
            setLog(sprintf(['RUN USING CURRENT USER INPUT.\n' ...
                'WARNING: %s\n' ...
                'Simulation still runs, but the model is not ideal.'], ...
                result.compatibilityMessage));
        else
            setLog('RUN USING CURRENT USER INPUT. Bắt đầu mô phỏng packet qua Khối 12...');
        end

        route = string(app.ddRoute.Value);
        path = getRoutePath(route);
        animatePacket(path, result);

        updateStatusTable(result);
        showResultInfo(result);
        if result.slaPass
            setLog(sprintf(['Hoàn tất mô phỏng với thông số người dùng đã gán.\n' ...
                'AI Result  : %s\n' ...
                'Decision   : %s\n' ...
                'SLA Status : PASS\n' ...
                'Total Delay: %.2f ms'], ...
                result.aiResult, result.decision, result.Ttotal));
        else
            setLog(sprintf(['Hoàn tất mô phỏng với thông số người dùng đã gán.\n' ...
                'AI Result  : %s\n' ...
                'Decision   : %s\n' ...
                'SLA Status : FAIL\n' ...
                'Total Delay: %.2f ms > SLA %.2f ms'], ...
                result.aiResult, result.decision, result.Ttotal, result.SLA));
        end
    end

    function randomPayload(~, ~)

        generateNewInput();
        if app.cbAutoRecommend.Value
            applyRecommendation(false);
        end
        syncPreviewFromControls();
        setLog('Đã tạo payload ngẫu nhiên. Bấm Run Simulation để chạy.');
    end

    function resetScene(~, ~)
        setDefaultInputFields();
        app.statusTable.Data = defaultTable();
        app.logArea.Value = {'Đã reset scene.'};
        app.lastResult = [];

        app.layout.xScale = 1.00;
        app.layout.yScale = 1.20;
        app.layout.zScale = 1.25;
        app.view.az = 28;
        app.view.el = 20;
        app.view.zoom = 1.00;
        app.ui.leftWidth = 300;
        app.ui.rightWidth = 260;

        app.edXScale.Value = app.layout.xScale;
        app.edYScale.Value = app.layout.yScale;
        app.edZScale.Value = app.layout.zScale;
        app.edAzimuth.Value = app.view.az;
        app.edElevation.Value = app.view.el;
        app.edZoom.Value = app.view.zoom;
        app.slLeftWidth.Value = app.ui.leftWidth;
        app.slRightWidth.Value = app.ui.rightWidth;

        if isfield(app, 'leftPanel') && isvalid(app.leftPanel)
            app.leftPanel.Visible = 'on';
        end
        if isfield(app, 'rightPanel') && isvalid(app.rightPanel)
            app.rightPanel.Visible = 'on';
        end

        updateMainLayout();
        applyRecommendation(false);
        drawScene();
        syncPreviewFromControls();
        showNodeInfo('Overview');
    end

%% ===================== DEFAULTS / INPUT GENERATION =====================
    function setDefaultInputFields()
        app.ddAppType.Value = 'Smart Factory - Anomaly Detection';
        app.ddDeviceType.Value = 'Industrial Machine Sensor';
        app.ddDataType.Value = 'Event Log';
        app.cbAutoRecommend.Value = true;
        app.ddModel.Value = 'Anomaly Detector';
        app.ddRoute.Value = 'MEC Only';
        app.edPacketID.Value = 'PKT-0001';
        app.edDeviceID.Value = 'IoT-2268';
        app.edTemp.Value = 78;
        app.ddVibration.Value = 'High';
        app.edPacketSize.Value = 32;
        app.edDataRate.Value = 10;
        app.edPDR.Value = 0.936;
        app.edTnetwork.Value = 63;
        app.edTpre.Value = 3;
        app.edTinfer.Value = 7;
        app.edTpost.Value = 2;
        app.edTresponse.Value = 5;
        app.edSLA.Value = 100;
        app.edThreshold.Value = 80;
        app.edEnergy.Value = 0.42;
        app.cbAutoInput.Value = true;
    end

    function generateNewInput()
        apps = app.ddAppType.Items;
        app.ddAppType.Value = apps{randi(numel(apps))};
        appTypeChanged();

        app.edPacketID.Value = sprintf('PKT-%04d', randi([1 9999]));
        app.edDeviceID.Value = sprintf('IoT-%04d', randi([1000 9999]));
        app.edTemp.Value = randi([20 110]);

        states = {'Low', 'Medium', 'High'};
        app.ddVibration.Value = states{randi(numel(states))};

        routeOptions = app.ddRoute.Items;
        app.ddRoute.Value = routeOptions{randi(numel(routeOptions))};

        app.edPacketSize.Value = randi([8 512]);
        app.edDataRate.Value = round(2 + rand()*48, 2);
        app.edPDR.Value = round(0.82 + rand()*0.17, 3);
        app.edTnetwork.Value = randi([20 140]);
        app.edTpre.Value = randi([1 8]);
        app.edTinfer.Value = randi([4 18]);
        app.edTpost.Value = randi([1 6]);
        app.edTresponse.Value = randi([3 15]);
        app.edSLA.Value = randi([80 250]);
        app.edThreshold.Value = randi([65 90]);
        app.edEnergy.Value = round(0.10 + rand()*1.40, 3);
    end

%% ===================== RECOMMENDATION / COMPATIBILITY =====================
    function rec = getRecommendedModel()
        dataType = string(app.ddDataType.Value);
        appType = string(app.ddAppType.Value);

        rec = struct();
        switch dataType
            case "Sensor Vector"
                rec.model = 'MLP Sensor Classifier';
                rec.reason = 'Sensor vector/tabular numeric data is naturally handled by an MLP classifier.';
            case "Image / Video Frame"
                rec.model = 'CNN Camera AI';
                rec.reason = 'Image/video data requires spatial feature extraction, which is the strength of CNNs.';
            case "Time-Series Signal"
                rec.model = 'LSTM Time-Series';
                rec.reason = 'Time-series signals need temporal dependency modeling, which LSTM is designed for.';
            case "GPS Trajectory"
                rec.model = 'LSTM Time-Series';
                rec.reason = 'GPS trajectory is sequential path data, so LSTM is a strong default; anomaly detection is also valid for route deviation.';
            otherwise % Event Log
                rec.model = 'Anomaly Detector';
                rec.reason = 'Fault/event-log monitoring is commonly formulated as anomaly detection.';
        end

        % Application-level override for clear anomaly task.
        if appType == "Smart Factory - Anomaly Detection"
            rec.model = 'Anomaly Detector';
            rec.reason = 'The application objective is fault/anomaly detection in a smart factory.';
        elseif appType == "Smart City - Camera AI"
            rec.model = 'CNN Camera AI';
            rec.reason = 'Traffic camera/image input should use CNN-based inference.';
        elseif appType == "Agriculture IoT - Irrigation"
            rec.model = 'MLP Sensor Classifier';
            rec.reason = 'Irrigation decisions usually use numeric sensor vectors such as soil moisture, humidity and temperature.';
        elseif appType == "Healthcare IoT - Health Alert" && dataType == "Time-Series Signal"
            rec.model = 'LSTM Time-Series';
            rec.reason = 'Wearable healthcare streams are time-series vital signals.';
        elseif appType == "Logistics - Route Monitoring" && dataType == "GPS Trajectory"
            rec.model = 'LSTM Time-Series';
            rec.reason = 'Route monitoring uses GPS trajectory/time sequence; anomaly detection is also acceptable for deviation warning.';
        end
    end

    function comp = checkModelCompatibility()
        rec = getRecommendedModel();
        selected = string(app.ddModel.Value);
        dataType = string(app.ddDataType.Value);
        appType = string(app.ddAppType.Value);

        comp = struct();
        comp.recommendedModel = string(rec.model);
        comp.reason = rec.reason;
        comp.ok = true;
        comp.message = sprintf('Recommended: %s. %s', rec.model, rec.reason);

        % Valid alternatives
        if dataType == "GPS Trajectory" && selected == "Anomaly Detector"
            comp.ok = true;
            comp.message = 'Compatible: GPS trajectory can use LSTM for sequence prediction or Anomaly Detector for route deviation.';
            return;
        end
        if appType == "Healthcare IoT - Health Alert" && selected == "MLP Sensor Classifier"
            comp.ok = true;
            comp.message = 'Compatible: Healthcare one-shot vital-sign vector can use MLP; time-series monitoring should use LSTM.';
            return;
        end
        if appType == "Smart Factory - Anomaly Detection" && selected == "MLP Sensor Classifier"
            comp.ok = true;
            comp.message = 'Compatible: MLP can classify machine states; Anomaly Detector is preferred for fault detection.';
            return;
        end

        if selected ~= string(rec.model)
            comp.ok = false;
            switch dataType
                case "Image / Video Frame"
                    comp.message = sprintf('Warning: Camera/image data is better processed by CNN Camera AI. Current model: %s.', selected);
                case "Sensor Vector"
                    comp.message = sprintf('Warning: Sensor vector data is usually better processed by MLP Sensor Classifier. Current model: %s.', selected);
                case "Time-Series Signal"
                    comp.message = sprintf('Warning: Time-series data is better processed by LSTM Time-Series. Current model: %s.', selected);
                case "GPS Trajectory"
                    comp.message = sprintf('Warning: GPS trajectory is usually better processed by LSTM or Anomaly Detector. Current model: %s.', selected);
                otherwise
                    comp.message = sprintf('Warning: Fault/event-log data is better processed by Anomaly Detector. Current model: %s.', selected);
            end
        end
    end

    function m = getModelProfile(modelName)
        modelName = string(modelName);
        m = struct();

        switch modelName
            case "MLP Sensor Classifier"
                m.featureDim = 8;
                m.memoryMB = 2;
                m.opsM = 0.8;
                m.inferMultiplier = 1.00;
                m.confidenceBoost = 0.00;
                m.modelType = 'Vector classifier';
            case "CNN Camera AI"
                m.featureDim = 256;
                m.memoryMB = 45;
                m.opsM = 180;
                m.inferMultiplier = 2.40;
                m.confidenceBoost = 0.05;
                m.modelType = 'Image/video spatial model';
            case "LSTM Time-Series"
                m.featureDim = 32;
                m.memoryMB = 12;
                m.opsM = 30;
                m.inferMultiplier = 1.70;
                m.confidenceBoost = 0.03;
                m.modelType = 'Temporal sequence model';
            otherwise % Anomaly Detector
                m.featureDim = 12;
                m.memoryMB = 6;
                m.opsM = 6;
                m.inferMultiplier = 1.25;
                m.confidenceBoost = 0.02;
                m.modelType = 'Fault/anomaly scoring model';
        end
    end

%% ===================== COMPUTATION =====================
    function result = computeResult()
        appType = string(app.ddAppType.Value);
        deviceType = string(app.ddDeviceType.Value);
        dataType = string(app.ddDataType.Value);
        route = string(app.ddRoute.Value);
        selectedModel = string(app.ddModel.Value);

        compatibility = checkModelCompatibility();
        modelProfile = getModelProfile(selectedModel);
        appProfile = getAppProfile(appType, dataType);

        sensorValue = app.edTemp.Value;
        sensorState = string(app.ddVibration.Value);

        packetSizeKB = app.edPacketSize.Value;
        dataRateMbps = app.edDataRate.Value;
        pdr = app.edPDR.Value;

        Tnetwork = app.edTnetwork.Value;
        Tpre = app.edTpre.Value;
        TinferBase = app.edTinfer.Value;
        Tpost = app.edTpost.Value;
        Tresponse = app.edTresponse.Value;
        SLA = app.edSLA.Value;
        threshold = app.edThreshold.Value / 100;
        energyBase = app.edEnergy.Value;

        % Transmission delay: packet kB / Mbps
        % kB -> kb = 8*kB, Mbps = 1000 kb/ms approximately
        Ttx = (packetSizeKB * 8) / dataRateMbps; % ms because kb/Mbps = ms
        Trecv = 0.15 * Ttx + 1.2;
        Tvalid = 0.8 + 0.01 * modelProfile.featureDim;
        Tfeat = 1.2 + 0.025 * modelProfile.featureDim;
        Tqueue = getRouteQueueDelay(route, modelProfile);

        % Model affects inference delay
        Tinfer = max(1, TinferBase * modelProfile.inferMultiplier);
        Tdecision = 0.9 + 0.02 * modelProfile.featureDim;

        routeExtraDelay = getRouteExtraDelay(route);
        TnetworkEff = Tnetwork + routeExtraDelay + Ttx;
        TAIbasic = Tpre + Tinfer + Tpost;
        TAIdetailed = Trecv + Tvalid + Tpre + Tfeat + Tqueue + Tinfer + Tpost + Tdecision;
        Ttotal = TnetworkEff + TAIdetailed + Tresponse;

        % Data-dependent risk score
        stateScore = getStateScore(sensorState);
        normalizedValue = min(max(sensorValue / 100, 0), 1.5);
        pdrPenalty = 1 - pdr;

        rawScore = appProfile.baseBias + appProfile.valueWeight * normalizedValue + appProfile.stateWeight * stateScore + 0.8*pdrPenalty;
        rawScore = rawScore + modelProfile.confidenceBoost;
        anomalyProb = 1 / (1 + exp(-rawScore));
        normalProb = 1 - anomalyProb;

        % If incompatible model, confidence is penalized
        compatibilityPenalty = 0;
        if ~compatibility.ok
            compatibilityPenalty = 0.14;
            anomalyProb = min(max(anomalyProb - 0.07, 0.01), 0.99);
            normalProb = 1 - anomalyProb;
        end

        if anomalyProb >= threshold
            isEvent = true;
            confidence = max(anomalyProb - compatibilityPenalty, 0.01);
        else
            isEvent = false;
            confidence = max(normalProb - compatibilityPenalty, 0.01);
        end

        confidence = min(confidence, 0.99);
        confidenceMargin = abs(anomalyProb - normalProb);

        [normalLabel, eventLabel, eventDecision, normalDecision] = getAppLabels(appType);

        if isEvent
            aiResult = eventLabel;
            decision = eventDecision;
        else
            aiResult = normalLabel;
            decision = normalDecision;
        end

        slaPass = Ttotal <= SLA;
        slaMargin = SLA - Ttotal;

        packetLoss = 1 - pdr;

        % Energy estimation
        Ptx = 0.45;       % W
        Prx = 0.25;       % W
        Pcompute = 1.0 + 0.015 * modelProfile.opsM;
        Pidle = 0.05;

        Etx = Ptx * (Ttx/1000);
        Erx = Prx * (Trecv/1000);
        Ecompute = Pcompute * (TAIdetailed/1000);
        Eidle = Pidle * ((TnetworkEff + Tresponse)/1000);
        Etotal = energyBase + Etx + Erx + Ecompute + Eidle;

        % Overhead and privacy
        overheadKB = packetSizeKB + 0.12*packetSizeKB + 0.01*modelProfile.featureDim;
        privacyScore = getPrivacyScore(route);
        routeCost = computeRouteCost(Ttotal, Etotal, overheadKB, privacyScore, route, modelProfile);

        severityScore = 0.55*anomalyProb + 0.25*min(Ttotal/SLA, 1.5) + 0.20*packetLoss;
        severityScore = min(max(severityScore, 0), 1.5);

        result = struct();
        result.packetID = string(app.edPacketID.Value);
        result.deviceID = string(app.edDeviceID.Value);
        result.appType = appType;
        result.deviceType = deviceType;
        result.dataType = dataType;
        result.model = selectedModel;
        result.modelType = string(modelProfile.modelType);
        result.recommendedModel = compatibility.recommendedModel;
        result.compatibilityOK = compatibility.ok;
        result.compatibilityMessage = compatibility.message;
        result.route = route;
        result.sensorValue = sensorValue;
        result.sensorState = sensorState;

        result.packetSizeKB = packetSizeKB;
        result.dataRateMbps = dataRateMbps;
        result.PDR = pdr;
        result.packetLoss = packetLoss;

        result.Ttx = Ttx;
        result.Trecv = Trecv;
        result.Tvalid = Tvalid;
        result.Tpre = Tpre;
        result.Tfeat = Tfeat;
        result.Tqueue = Tqueue;
        result.Tinfer = Tinfer;
        result.Tpost = Tpost;
        result.Tdecision = Tdecision;
        result.Tresponse = Tresponse;
        result.Tnetwork = TnetworkEff;
        result.TAIbasic = TAIbasic;
        result.TAIdetailed = TAIdetailed;
        result.Ttotal = Ttotal;
        result.SLA = SLA;
        result.slaPass = slaPass;
        result.slaMargin = slaMargin;

        result.normalProb = normalProb;
        result.anomalyProb = anomalyProb;
        result.confidence = confidence;
        result.confidenceMargin = confidenceMargin;
        result.threshold = threshold;
        result.aiResult = aiResult;
        result.decision = decision;
        result.severityScore = severityScore;

        result.energyBase = energyBase;
        result.Etx = Etx;
        result.Erx = Erx;
        result.Ecompute = Ecompute;
        result.Eidle = Eidle;
        result.Etotal = Etotal;

        result.overheadKB = overheadKB;
        result.privacyScore = privacyScore;
        result.routeCost = routeCost;
        result.modelMemoryMB = modelProfile.memoryMB;
        result.modelOpsM = modelProfile.opsM;
        result.featureDim = modelProfile.featureDim;
    end

    function appProfile = getAppProfile(appType, dataType)
        appProfile = struct();
        appProfile.baseBias = -1.2;
        appProfile.valueWeight = 2.2;
        appProfile.stateWeight = 1.0;

        switch string(appType)
            case "Smart Factory - Anomaly Detection"
                appProfile.baseBias = -1.0;
                appProfile.valueWeight = 2.5;
                appProfile.stateWeight = 1.5;
            case "Healthcare IoT - Health Alert"
                appProfile.baseBias = -0.9;
                appProfile.valueWeight = 2.3;
                appProfile.stateWeight = 1.2;
            case "Smart City - Camera AI"
                appProfile.baseBias = -0.7;
                appProfile.valueWeight = 2.0;
                appProfile.stateWeight = 0.9;
            case "Agriculture IoT - Irrigation"
                appProfile.baseBias = -1.3;
                appProfile.valueWeight = 2.1;
                appProfile.stateWeight = 0.8;
            case "Logistics - Route Monitoring"
                appProfile.baseBias = -1.1;
                appProfile.valueWeight = 2.4;
                appProfile.stateWeight = 1.2;
        end

        if string(dataType) == "Image / Video Frame"
            appProfile.valueWeight = appProfile.valueWeight + 0.2;
        elseif string(dataType) == "GPS Trajectory"
            appProfile.stateWeight = appProfile.stateWeight + 0.2;
        elseif string(dataType) == "Event Log"
            appProfile.stateWeight = appProfile.stateWeight + 0.3;
        end
    end

    function s = getStateScore(sensorState)
        switch string(sensorState)
            case "Low"
                s = -0.6;
            case "Medium"
                s = 0.35;
            otherwise
                s = 1.25;
        end
    end

    function d = getRouteExtraDelay(route)
        switch string(route)
            case "MEC Only"
                d = 0;
            case "Edge-Cloud Cooperation"
                d = 25;
            otherwise
                d = 60;
        end
    end

    function q = getRouteQueueDelay(route, modelProfile)
        switch string(route)
            case "MEC Only"
                q = 2.0 + 0.01*modelProfile.opsM;
            case "Edge-Cloud Cooperation"
                q = 4.0 + 0.008*modelProfile.opsM;
            otherwise
                q = 6.0 + 0.004*modelProfile.opsM;
        end
    end

    function p = getPrivacyScore(route)
        switch string(route)
            case "MEC Only"
                p = 0.80;
            case "Edge-Cloud Cooperation"
                p = 0.55;
            otherwise
                p = 0.35;
        end
    end

    function J = computeRouteCost(Ttotal, Etotal, overheadKB, privacyScore, route, modelProfile)
        alpha = 0.45; beta = 0.20; lambda = 0.15; eta = 0.10; delta = 0.10;
        cloudPenalty = 0;
        if string(route) == "Cloud Only"
            cloudPenalty = 8;
        elseif string(route) == "Edge-Cloud Cooperation"
            cloudPenalty = 4;
        end
        J = alpha*Ttotal + beta*(100*Etotal) + lambda*overheadKB + eta*modelProfile.memoryMB - delta*(100*privacyScore) + cloudPenalty;
    end

    function [normalLabel, eventLabel, eventDecision, normalDecision] = getAppLabels(appType)
        switch string(appType)
            case "Smart Factory - Anomaly Detection"
                normalLabel = "Machine normal";
                eventLabel = "Motor anomaly detected";
                eventDecision = "Send urgent maintenance alert";
                normalDecision = "Continue monitoring machine";
            case "Healthcare IoT - Health Alert"
                normalLabel = "Patient condition normal";
                eventLabel = "Health risk detected";
                eventDecision = "Send emergency health alert";
                normalDecision = "Store record and continue monitoring";
            case "Smart City - Camera AI"
                normalLabel = "Traffic condition normal";
                eventLabel = "Congestion / incident detected";
                eventDecision = "Notify traffic control center";
                normalDecision = "Update smart city dashboard";
            case "Agriculture IoT - Irrigation"
                normalLabel = "Soil condition acceptable";
                eventLabel = "Irrigation required";
                eventDecision = "Activate irrigation control";
                normalDecision = "Keep irrigation off";
            otherwise
                normalLabel = "Logistics status normal";
                eventLabel = "Route / cargo anomaly detected";
                eventDecision = "Send logistics warning";
                normalDecision = "Continue cargo tracking";
        end
    end

%% ===================== 3D SCENE =====================
    function updateLayoutPositions()
        names = fieldnames(app.baseP);
        for k = 1:numel(names)
            p = app.baseP.(names{k});
            p(1) = p(1) * app.layout.xScale;
            p(2) = p(2) * app.layout.yScale;
            p(3) = p(3) * app.layout.zScale;
            app.P.(names{k}) = p;
        end
    end

    function drawScene()
        updateLayoutPositions();

        ax = app.ax;
        cla(ax);
        hold(ax, 'on');
        grid(ax, 'on');
        box(ax, 'on');
        axis(ax, 'vis3d');
        daspect(ax, [1 1 0.70]);

        setAxesRange();

        ax.XLabel.String = 'Network / Application Flow';
        ax.YLabel.String = 'Edge - Cloud Direction';
        ax.ZLabel.String = 'Layer Height';
        ax.FontSize = 11;
        ax.Toolbar.Visible = 'on';

        view(ax, app.view.az, app.view.el);
        camzoom(ax, app.view.zoom);
        title(ax, 'Block 12: AI / Edge Intelligence / Application Layer');

        drawGround();
        drawMainLinks();
        drawNodes();

        app.packetHandle = scatter3(ax, app.P.iot(1), app.P.iot(2), app.P.iot(3)+0.78, ...
            130, 'filled', 'MarkerFaceColor', [1.0 0.25 0.20], 'MarkerEdgeColor', [0.2 0.2 0.2]);

        text(ax, app.P.iot(1)-0.65, app.P.iot(2)+0.90, app.P.iot(3)+1.55, 'Packet', ...
            'FontWeight', 'bold', 'FontSize', 12, 'Color', [0.85 0.10 0.05]);
    end

    function setAxesRange()
        names = fieldnames(app.P);
        pts = zeros(numel(names), 3);
        for i = 1:numel(names)
            pts(i,:) = app.P.(names{i});
        end
        app.ax.XLim = [min(pts(:,1)) - 4.0, max(pts(:,1)) + 4.5];
        app.ax.YLim = [min(pts(:,2)) - 4.5, max(pts(:,2)) + 4.5];
        app.ax.ZLim = [0, max(pts(:,3)) + 3.8];
    end

    function drawGround()
        ax = app.ax;
        xg = linspace(ax.XLim(1), ax.XLim(2), 28);
        yg = linspace(ax.YLim(1), ax.YLim(2), 18);
        [X, Y] = meshgrid(xg, yg);
        Z = zeros(size(X));
        surf(ax, X, Y, Z, 'FaceAlpha', 0.03, 'EdgeAlpha', 0.10, ...
            'FaceColor', [0.4 0.6 0.9], 'EdgeColor', [0.3 0.3 0.3], 'HitTest', 'off');
    end

    function drawMainLinks()
        drawLink(app.P.iot, app.P.gnb, 'Uplink packet');
        drawLink(app.P.gnb, app.P.upf, '5G RAN');
        drawLink(app.P.upf, app.P.mec, 'Local breakout');
        drawLink(app.P.mec, app.P.receiver, 'MEC intake');
        drawLink(app.P.receiver, app.P.pre, '');
        drawLink(app.P.pre, app.P.feature, '');
        drawLink(app.P.feature, app.P.ai, '');
        drawLink(app.P.ai, app.P.decision, '');
        drawLink(app.P.decision, app.P.response, '');
        drawLink(app.P.response, app.P.dashboard, 'App result');

        ax = app.ax;
        p1 = app.P.ai;
        p2 = app.P.cloud;
        plot3(ax, [p1(1) p2(1)], [p1(2) p2(2)], [p1(3) p2(3)], '--', ...
            'LineWidth', 2.1, 'Color', [0.45 0.45 0.65], 'HitTest', 'off');

        dir = p2 - p1;
        qStart = p1 + 0.62 * dir;
        quiver3(ax, qStart(1), qStart(2), qStart(3), 0.16*dir(1), 0.16*dir(2), 0.16*dir(3), 0, ...
            'Color', [0.45 0.45 0.65], 'LineWidth', 1.9, 'MaxHeadSize', 1.4, 'HitTest', 'off');

        text(ax, mean([p1(1) p2(1)]), mean([p1(2) p2(2)])-0.45, mean([p1(3) p2(3)])+0.65, ...
            'Cloud offload', 'FontSize', 10, 'Color', [0.35 0.35 0.55], 'HorizontalAlignment', 'center');
    end

    function drawLink(p1, p2, labelText)
        ax = app.ax;
        plot3(ax, [p1(1) p2(1)], [p1(2) p2(2)], [p1(3) p2(3)], '-', ...
            'LineWidth', 2.4, 'Color', app.C.link, 'HitTest', 'off');

        dir = p2 - p1;
        qStart = p1 + 0.56 * dir;
        quiver3(ax, qStart(1), qStart(2), qStart(3), 0.15*dir(1), 0.15*dir(2), 0.15*dir(3), 0, ...
            'Color', app.C.link, 'LineWidth', 1.8, 'MaxHeadSize', 1.3, 'HitTest', 'off');

        if strlength(string(labelText)) > 0
            mid = (p1 + p2) / 2;
            text(ax, mid(1), mid(2), mid(3)+0.45, labelText, 'FontSize', 9, ...
                'Color', [0.05 0.15 0.55], 'HorizontalAlignment', 'center');
        end
    end

    function drawNodes()
        ax = app.ax;

        dx = [-0.70 -0.32 0.20 0.62 -0.18];
        dy = [-0.42 0.38 -0.20 0.52 0.12] * app.layout.yScale;
        dz = [0.22 0.52 0.30 0.42 0.82] * app.layout.zScale;
        hIoT = scatter3(ax, app.P.iot(1)+dx, app.P.iot(2)+dy, app.P.iot(3)+dz, 115, 'filled', ...
            'MarkerFaceColor', app.C.device, 'MarkerEdgeColor', [0 0 0], ...
            'ButtonDownFcn', {@nodeClicked, 'IoT'}, 'PickableParts', 'all');
        hIoT.HitTest = 'on';

        text(ax, app.P.iot(1), app.P.iot(2), app.P.iot(3)+1.75, 'IoT / mMTC Devices', ...
            'HorizontalAlignment', 'center', 'FontWeight', 'bold', 'FontSize', 12, ...
            'ButtonDownFcn', {@nodeClicked, 'IoT'});

        drawBox(app.P.gnb, [1.10 1.10 2.10], app.C.ran, 0.75, '5G gNB', 'gNB');
        drawBox(app.P.upf, [1.60 1.10 1.25], app.C.core, 0.80, '5G Core / UPF', 'UPF');

        mecZoneCenter = [(app.P.mec(1)+app.P.response(1))/2, app.P.receiver(2), 0.60*app.layout.zScale];
        mecZoneDim = [app.P.response(1)-app.P.mec(1)+3.8, 4.8*app.layout.yScale, 0.10*app.layout.zScale];
        drawBox(mecZoneCenter, mecZoneDim, [0.93 0.96 1.00], 0.16, '', '');
        text(ax, app.P.mec(1)+8.5*app.layout.xScale, app.P.receiver(2)-1.45*app.layout.yScale, 0.30*app.layout.zScale, ...
            'Edge Intelligence Zone', 'FontSize', 10, 'Color', [0.35 0.35 0.55], 'HorizontalAlignment', 'center');

        drawBox(app.P.mec, [1.70 1.15 1.30], app.C.edge, 0.82, 'MEC Host', 'MEC');
        drawBox(app.P.receiver, [1.65 1.00 0.95], [0.75 0.85 1.00], 0.88, 'Data Receiver', 'Receiver');
        drawBox(app.P.pre, [1.65 1.00 0.95], [0.70 0.90 1.00], 0.88, 'Preprocess', 'Preprocess');
        drawBox(app.P.feature, [1.65 1.00 0.95], [0.75 1.00 0.75], 0.88, 'Feature Extract', 'Feature');
        drawBox(app.P.ai, [1.65 1.00 0.95], app.C.ai, 0.88, 'AI Inference', 'AI');
        drawBox(app.P.decision, [1.65 1.00 0.95], app.C.decision, 0.88, 'Decision', 'Decision');
        drawBox(app.P.response, [1.65 1.00 0.95], app.C.dashboard, 0.88, 'Response', 'Response');
        drawBox(app.P.dashboard, [2.00 1.25 1.15], [0.20 0.80 0.40], 0.85, 'Dashboard', 'Dashboard');
        drawBox(app.P.cloud, [2.10 1.30 1.30], app.C.cloud, 0.80, 'Cloud Server', 'Cloud');
        drawMiniNeuralNetwork(app.P.ai + [0 0 1.10*app.layout.zScale]);
    end

    function drawBox(center, dim, color, alphaVal, labelText, nodeKey)
        ax = app.ax;
        x = center(1); y = center(2); z = center(3);
        lx = dim(1); ly = dim(2); lz = dim(3);

        V = [x-lx/2 y-ly/2 z-lz/2;
             x+lx/2 y-ly/2 z-lz/2;
             x+lx/2 y+ly/2 z-lz/2;
             x-lx/2 y+ly/2 z-lz/2;
             x-lx/2 y-ly/2 z+lz/2;
             x+lx/2 y-ly/2 z+lz/2;
             x+lx/2 y+ly/2 z+lz/2;
             x-lx/2 y+ly/2 z+lz/2];

        F = [1 2 3 4; 5 6 7 8; 1 2 6 5; 2 3 7 6; 3 4 8 7; 4 1 5 8];

        if strlength(string(nodeKey)) > 0
            patch(ax, 'Vertices', V, 'Faces', F, 'FaceColor', color, 'FaceAlpha', alphaVal, ...
                'EdgeColor', [0.15 0.15 0.15], 'LineWidth', 0.9, ...
                'ButtonDownFcn', {@nodeClicked, nodeKey}, 'PickableParts', 'all', 'HitTest', 'on');
        else
            patch(ax, 'Vertices', V, 'Faces', F, 'FaceColor', color, 'FaceAlpha', alphaVal, ...
                'EdgeColor', [0.35 0.35 0.55], 'LineWidth', 0.7, 'PickableParts', 'none', 'HitTest', 'off');
        end

        if strlength(string(labelText)) > 0
            t = text(ax, x, y, z+lz/2+0.22, labelText, 'HorizontalAlignment', 'center', ...
                'FontSize', 10, 'FontWeight', 'bold', 'Color', [0.05 0.05 0.05]);
            if strlength(string(nodeKey)) > 0
                t.ButtonDownFcn = {@nodeClicked, nodeKey};
                t.PickableParts = 'all';
                t.HitTest = 'on';
            else
                t.HitTest = 'off';
            end
        end
    end

    function drawMiniNeuralNetwork(base)
        ax = app.ax;
        x0 = base(1) - 0.55;
        y0 = base(2) + 0.78;
        z0 = base(3);
        layerX = [x0, x0+0.45, x0+0.90];
        layerCounts = [3, 4, 2];
        pts = cell(1, 3);

        for li = 1:3
            n = layerCounts(li);
            zz = linspace(z0-0.40, z0+0.40, n);
            xx = layerX(li) * ones(1, n);
            yy = y0 * ones(1, n);
            pts{li} = [xx(:), yy(:), zz(:)];
            scatter3(ax, xx, yy, zz, 34, 'filled', 'MarkerFaceColor', [1 1 1], ...
                'MarkerEdgeColor', [0.15 0.15 0.15], 'HitTest', 'off');
        end

        for li = 1:2
            A = pts{li}; B = pts{li+1};
            for i = 1:size(A,1)
                for j = 1:size(B,1)
                    plot3(ax, [A(i,1), B(j,1)], [A(i,2), B(j,2)], [A(i,3), B(j,3)], '-', ...
                        'Color', [0.25 0.25 0.25], 'LineWidth', 0.5, 'HitTest', 'off');
                end
            end
        end
    end

%% ===================== ANIMATION =====================
    function path = getRoutePath(route)
        switch route
            case "MEC Only"
                path = [app.P.iot + [0 0 0.78];
                        app.P.gnb + [0 0 1.00];
                        app.P.upf + [0 0 0.72];
                        app.P.mec + [0 0 0.68];
                        app.P.receiver + [0 0 0.68];
                        app.P.pre + [0 0 0.68];
                        app.P.feature + [0 0 0.68];
                        app.P.ai + [0 0 0.68];
                        app.P.decision + [0 0 0.68];
                        app.P.response + [0 0 0.68];
                        app.P.dashboard + [0 0 0.72]];
            case "Edge-Cloud Cooperation"
                path = [app.P.iot + [0 0 0.78];
                        app.P.gnb + [0 0 1.00];
                        app.P.upf + [0 0 0.72];
                        app.P.mec + [0 0 0.68];
                        app.P.receiver + [0 0 0.68];
                        app.P.pre + [0 0 0.68];
                        app.P.feature + [0 0 0.68];
                        app.P.ai + [0 0 0.68];
                        app.P.cloud + [0 0 0.82];
                        app.P.ai + [0 0 0.68];
                        app.P.decision + [0 0 0.68];
                        app.P.response + [0 0 0.68];
                        app.P.dashboard + [0 0 0.72]];
            otherwise
                path = [app.P.iot + [0 0 0.78];
                        app.P.gnb + [0 0 1.00];
                        app.P.upf + [0 0 0.72];
                        app.P.cloud + [0 0 0.82];
                        app.P.dashboard + [0 0 0.72]];
        end
    end

    function animatePacket(path, result)
        if isempty(app.packetHandle) || ~isvalid(app.packetHandle)
            return;
        end

        route = string(result.route);
        if route == "MEC Only"
            stepNames = {'IoT device tạo packet', 'Packet tới gNB', 'Qua 5G Core / UPF', ...
                'Local breakout tới MEC', 'Data Receiver nhận packet', 'Tiền xử lý dữ liệu', ...
                'Trích đặc trưng', 'AI inference tại MEC', 'Decision Engine ra quyết định', ...
                'Tạo application response', 'Dashboard hiển thị kết quả'};
        elseif route == "Edge-Cloud Cooperation"
            stepNames = {'IoT device tạo packet', 'Packet tới gNB', 'Qua 5G Core / UPF', ...
                'Packet tới MEC', 'Data Receiver nhận packet', 'Tiền xử lý dữ liệu', ...
                'Trích đặc trưng', 'AI inference tại MEC', 'Offload/verify với Cloud', ...
                'Kết quả Cloud trả về MEC', 'Decision Engine ra quyết định', ...
                'Tạo application response', 'Dashboard hiển thị kết quả'};
        else
            stepNames = {'IoT device tạo packet', 'Packet tới gNB', 'Qua 5G Core / UPF', ...
                'Gửi lên Cloud Server', 'Dashboard nhận kết quả'};
        end

        nSeg = size(path,1) - 1;
        for i = 1:nSeg
            if i <= numel(stepNames)
                setLog(sprintf('Step %d/%d: %s', i, nSeg, stepNames{i}));
            end
            p0 = path(i,:); p1 = path(i+1,:);
            for s = linspace(0, 1, 38)
                p = (1-s) * p0 + s * p1;
                app.packetHandle.XData = p(1);
                app.packetHandle.YData = p(2);
                app.packetHandle.ZData = p(3);
                drawnow limitrate;
                pause(0.008);
            end
        end

        if result.slaPass
            app.packetHandle.MarkerFaceColor = app.C.ok;
        else
            app.packetHandle.MarkerFaceColor = app.C.bad;
        end
        drawnow;
    end

%% ===================== TABLES / TEXT =====================
    function syncPreviewFromControls(~, ~)
        try
            result = computeResult();
            updateStatusTable(result);
        catch ME
            app.logArea.Value = {['Preview sync warning: ' ME.message]};
        end
    end

    function updateStatusTable(result)
        slaStr = "PASS";
        if ~result.slaPass, slaStr = "FAIL"; end
        compStr = "OK";
        if ~result.compatibilityOK, compStr = "WARNING"; end

        app.statusTable.Data = {
            'Packet ID', char(result.packetID);
            'Device ID', char(result.deviceID);
            'Application', char(result.appType);
            'Device Type', char(result.deviceType);
            'Input Data Type', char(result.dataType);
            'AI Model', char(result.model);
            'Recommended Model', char(result.recommendedModel);
            'Model Compatibility', char(compStr);
            'Route', char(result.route);
            'Payload', sprintf('Value=%.2f, State=%s', result.sensorValue, result.sensorState);
            'Packet Size', sprintf('%.2f kB', result.packetSizeKB);
            'Data Rate', sprintf('%.2f Mbps', result.dataRateMbps);
            'PDR_E2E', sprintf('%.3f', result.PDR);
            'Packet Loss', sprintf('%.2f %%', 100*result.packetLoss);
            'T_tx', sprintf('%.2f ms', result.Ttx);
            'T_network', sprintf('%.2f ms', result.Tnetwork);
            'T_AI detailed', sprintf('%.2f ms', result.TAIdetailed);
            'T_app,total', sprintf('%.2f ms', result.Ttotal);
            'SLA Threshold', sprintf('%.2f ms', result.SLA);
            'SLA Margin', sprintf('%.2f ms', result.slaMargin);
            'SLA Status', char(slaStr);
            'AI Result', char(result.aiResult);
            'Confidence', sprintf('%.2f %%', 100*result.confidence);
            'Confidence Margin', sprintf('%.3f', result.confidenceMargin);
            'Severity Score', sprintf('%.3f', result.severityScore);
            'Decision', char(result.decision);
            'Energy Total', sprintf('%.4f J', result.Etotal);
            'E_tx/E_rx/E_compute', sprintf('%.4f / %.4f / %.4f J', result.Etx, result.Erx, result.Ecompute);
            'Overhead', sprintf('%.2f kB', result.overheadKB);
            'Privacy Score', sprintf('%.2f', result.privacyScore);
            'Route Cost', sprintf('%.2f', result.routeCost);
            'Model Memory', sprintf('%.2f MB', result.modelMemoryMB);
            'Model Ops', sprintf('%.2f M ops', result.modelOpsM);
            'Feature Dimension', sprintf('%d', result.featureDim)};
    end

    function showResultInfo(result)
        thresholdStatus = thresholdStatusText(result);
        confidenceLevel = confidenceLevelText(result.confidence);
        txt = sprintf([ ...
            'KẾT QUẢ KHỐI 12 - AI / EDGE INTELLIGENCE v18\n' ...
            '================================================\n\n' ...
            '1) Input và model\n' ...
            'Packet ID         : %s\n' ...
            'Device ID         : %s\n' ...
            'Application       : %s\n' ...
            'Device Type       : %s\n' ...
            'Input Data Type   : %s\n' ...
            'Selected AI Model : %s\n' ...
            'Recommended Model : %s\n' ...
            'Compatibility     : %s\n\n' ...
            '2) Vì sao chọn model\n%s\n\n' ...
            '3) Công thức thời gian chi tiết\n' ...
            'T_AI,total = T_recv + T_valid + T_pre + T_feat + T_queue + T_infer + T_post + T_decision\n' ...
            'T_AI,total = %.2f + %.2f + %.2f + %.2f + %.2f + %.2f + %.2f + %.2f = %.2f ms\n\n' ...
            'T_app,total = T_network + T_AI,total + T_response = %.2f + %.2f + %.2f = %.2f ms\n\n' ...
            '4) Kết quả AI / Threshold rõ ràng hơn\n' ...
            'P(normal | x)       = %.4f\n' ...
            'P(event  | x)       = %.4f\n' ...
            'AI Threshold        = %.2f %%\n' ...
            'Threshold Status    = %s\n' ...
            'Decision Confidence = %.2f %% (%s)\n' ...
            'Result              = %s\n' ...
            'Decision            = %s\n\n' ...
            '5) Metric hệ thống\n' ...
            'PDR_E2E        = %.3f\n' ...
            'Energy Total   = %.4f J\n' ...
            'Privacy Score  = %.2f\n' ...
            'Route Cost     = %.2f\n' ...
            'SLA Status     = %s\n'], ...
            result.packetID, result.deviceID, result.appType, result.deviceType, result.dataType, ...
            result.model, result.recommendedModel, boolText(result.compatibilityOK), result.compatibilityMessage, ...
            result.Trecv, result.Tvalid, result.Tpre, result.Tfeat, result.Tqueue, result.Tinfer, result.Tpost, result.Tdecision, result.TAIdetailed, ...
            result.Tnetwork, result.TAIdetailed, result.Tresponse, result.Ttotal, ...
            result.normalProb, result.anomalyProb, 100*result.threshold, thresholdStatus, 100*result.confidence, confidenceLevel, result.aiResult, result.decision, ...
            result.PDR, result.Etotal, result.privacyScore, result.routeCost, passFailText(result.slaPass));

        app.infoArea.Value = regexp(txt, newline, 'split');
    end

    function showFullTheory(~, ~)
        txt = [ ...
            "THEORY REVIEW - BLOCK 12 v18", ...
            "========================================", ...
            "", ...
            "1. Why Device Type and Input Data Type matter", ...
            "Khối 12 nhận packet ứng dụng từ Khối 11. Model AI không nên chọn ngẫu nhiên.", ...
            "Thiết bị khác nhau tạo ra kiểu dữ liệu khác nhau: cảm biến số, ảnh/video, chuỗi thời gian, GPS trajectory hoặc event log.", ...
            "", ...
            "2. Recommended AI Model mapping", ...
            "Sensor Vector       -> MLP Sensor Classifier", ...
            "Image / Video Frame -> CNN Camera AI", ...
            "Time-Series Signal  -> LSTM Time-Series", ...
            "Event Log/Fault     -> Anomaly Detector", ...
            "GPS Trajectory      -> LSTM Time-Series hoặc Anomaly Detector", ...
            "", ...
            "3. Core formulas", ...
            "Input packet:", ...
            "I12 = {PacketID, DeviceID, Application, DeviceType, DataType, Payload, Route, Delay, PDR, Energy, SLA}", ...
            "", ...
            "Preprocessing:", ...
            "x_norm = (x_raw - mu) / sigma", ...
            "or x_norm = (x - x_min)/(x_max - x_min)", ...
            "", ...
            "Feature extraction:", ...
            "x = phi(x_raw)", ...
            "", ...
            "Classification:", ...
            "z = W*x + b", ...
            "P(y=k|x) = exp(z_k) / sum_j exp(z_j)", ...
            "y_hat = argmax_k P(y=k|x)", ...
            "", ...
            "Anomaly detection:", ...
            "S_anom = f_theta(x)", ...
            "Decision = Anomaly if S_anom >= gamma, otherwise Normal", ...
            "", ...
            "Detailed AI delay:", ...
            "T_AI,total = T_recv + T_valid + T_pre + T_feat + T_queue + T_infer + T_post + T_decision", ...
            "", ...
            "Total application delay:", ...
            "T_app,total = T_network + T_AI,total + T_response", ...
            "", ...
            "SLA:", ...
            "PASS if T_app,total <= T_SLA, otherwise FAIL", ...
            "", ...
            "4. Model effect in v7", ...
            "MLP: suitable for vector sensor/tabular data, lower memory and lower operation count.", ...
            "CNN: suitable for image/video, higher memory and operation count, longer inference delay.", ...
            "LSTM: suitable for time-series and GPS trajectory, medium memory and temporal modeling.", ...
            "Anomaly Detector: suitable for fault/event monitoring and abnormal-state scoring.", ...
            "", ...
            "5. Compatibility warning", ...
            "If Application = Smart City - Camera AI but AI Model = MLP, the app warns that camera/image data is better processed by CNN Camera AI.", ...
            "The simulation still runs, but confidence is penalized to show model mismatch.", ...
            "", ...
            "6. Edge intelligence meaning", ...
            "MEC processing reduces latency and bandwidth pressure compared with Cloud-only processing, while Cloud-only may provide stronger compute but higher network delay." ...
        ];
        app.infoArea.Value = cellstr(txt(:));
    end

    function showNodeInfo(nodeKey)
        switch string(nodeKey)
            case "Overview"
                txt = sprintf([ ...
                    'TỔNG QUAN KHỐI 12 v18\n' ...
                    '==============================\n\n' ...
                    'Bản v11 giữ Device Type, Input Data Type, Auto Recommend AI Model.\n\n' ...
                    'Quy tắc chính:\n' ...
                    'Sensor Vector       -> MLP\n' ...
                    'Image / Video Frame -> CNN\n' ...
                    'Time-Series Signal  -> LSTM\n' ...
                    'GPS Trajectory      -> LSTM hoặc Anomaly Detector\n' ...
                    'Fault/Event Log     -> Anomaly Detector\n\n' ...
                    'AI Model bây giờ ảnh hưởng thật tới T_infer, memory, model ops, feature dimension,\n' ...
                    'confidence behavior, compatibility warning và route cost.\n']);
            case "IoT"
                txt = sprintf('IoT / mMTC DEVICES\n==============================\nTạo payload theo Device Type: sensor, camera, wearable, GPS tracker hoặc event log.');
            case "gNB"
                txt = sprintf('5G gNB\n==============================\nNhận uplink packet từ IoT/UE và chuyển vào 5G Core.');
            case "UPF"
                txt = sprintf('5G CORE / UPF\n==============================\nĐịnh tuyến packet tới MEC hoặc Cloud qua user plane và local breakout.');
            case "MEC"
                txt = sprintf('MEC HOST\n==============================\nChạy AI Application gần nguồn dữ liệu để giảm latency và giảm tải cloud.');
            case "Receiver"
                txt = sprintf('DATA RECEIVER\n==============================\nTách Packet ID, Device ID, Application, Device Type, Data Type và Payload.');
            case "Preprocess"
                txt = sprintf('PREPROCESSING\n==============================\nChuẩn hóa dữ liệu: x_norm = (x_raw - mu)/sigma hoặc min-max scaling.');
            case "Feature"
                txt = sprintf('FEATURE EXTRACTION\n==============================\nChuyển payload thành feature vector x = phi(x_raw).');
            case "AI"
                txt = sprintf('AI INFERENCE ENGINE\n==============================\nChạy MLP/CNN/LSTM/Anomaly Detector. Model được chọn theo loại dữ liệu.');
            case "Decision"
                txt = sprintf('DECISION ENGINE\n==============================\nKết hợp AI result, confidence, SLA và severity để tạo quyết định.');
            case "Response"
                txt = sprintf('APPLICATION RESPONSE\n==============================\nTạo kết quả gửi dashboard hoặc lệnh điều khiển phản hồi.');
            case "Dashboard"
                txt = sprintf('DASHBOARD\n==============================\nHiển thị AI result, decision, SLA, route cost, energy, privacy, confidence.');
            case "Cloud"
                txt = sprintf('OPTIONAL CLOUD SERVER\n==============================\nDùng khi tác vụ nặng, cần lưu trữ hoặc edge-cloud cooperation.');
            otherwise
                txt = 'No information.';
        end
        app.infoArea.Value = regexp(txt, newline, 'split');
    end

    function nodeClicked(~, ~, nodeKey)
        showNodeInfo(nodeKey);
    end

    function setLog(txt)
        app.logArea.Value = regexp(txt, newline, 'split');
        drawnow limitrate;
    end

    function t = passFailText(flag)
        if flag, t = 'PASS'; else, t = 'FAIL'; end
    end

    function t = boolText(flag)
        if flag, t = 'OK'; else, t = 'WARNING'; end
    end

    function data = defaultTable()
        data = {
            'Packet ID', 'PKT-0001';
            'Device ID', 'IoT-2268';
            'Application', 'Smart Factory - Anomaly Detection';
            'Device Type', 'Industrial Machine Sensor';
            'Input Data Type', 'Event Log';
            'AI Model', 'Anomaly Detector';
            'Recommended Model', 'Anomaly Detector';
            'Model Compatibility', 'OK';
            'Route', 'MEC Only';
            'Payload', 'Value=78, State=High';
            'PDR_E2E', '0.936';
            'T_app,total', 'Preview...';
            'SLA Status', 'Preview...';
            'AI Result', 'Waiting...';
            'Decision', 'Waiting...'};
    end


%% ===================== v14 VALIDATION DASHBOARD =====================
    function runBatchSimulation(~, ~)
        N = max(10, round(app.edBatchN.Value));
        mode = string(app.ddValidationMode.Value);

        snap = snapshotControls();
        rng('shuffle');

        PacketID = strings(N,1);
        DeviceID = strings(N,1);
        Application = strings(N,1);
        DeviceType = strings(N,1);
        DataType = strings(N,1);
        Model = strings(N,1);
        Route = strings(N,1);
        CompatibilityOK = false(N,1);

        Delay_ms = zeros(N,1);
        AI_Delay_ms = zeros(N,1);
        Network_ms = zeros(N,1);
        Response_ms = zeros(N,1);
        SLA_ms = zeros(N,1);
        SLAPass = false(N,1);
        Confidence = zeros(N,1);
        EventProb = zeros(N,1);
        PredictedEvent = false(N,1);
        GroundTruthEvent = false(N,1);
        PDR = zeros(N,1);
        Energy_J = zeros(N,1);
        PrivacyScore = zeros(N,1);
        RouteCost = zeros(N,1);
        FeatureDim = zeros(N,1);
        ModelOps_M = zeros(N,1);

        setLog(sprintf('Đang chạy Batch Simulation với %d packet...', N));
        drawnow;

        for i = 1:N
            if mode == "Random mixed applications"
                generateNewInput();
            else
                % Keep current app/model family, but randomize packet-level values.
                app.edPacketID.Value = sprintf('PKT-%04d', randi([1 9999]));
                app.edDeviceID.Value = sprintf('IoT-%04d', randi([1000 9999]));
                app.edTemp.Value = randi([20 110]);
                states = {'Low', 'Medium', 'High'};
                app.ddVibration.Value = states{randi(numel(states))};
                app.edPacketSize.Value = randi([8 512]);
                app.edDataRate.Value = round(2 + rand()*48, 2);
                app.edPDR.Value = round(0.82 + rand()*0.17, 3);
                app.edTnetwork.Value = randi([20 140]);
                app.edTpre.Value = randi([1 8]);
                app.edTinfer.Value = randi([4 18]);
                app.edTpost.Value = randi([1 6]);
                app.edTresponse.Value = randi([3 15]);
                app.edSLA.Value = randi([80 250]);
                app.edThreshold.Value = randi([65 90]);
                app.edEnergy.Value = round(0.10 + rand()*1.40, 3);
                routes = app.ddRoute.Items;
                app.ddRoute.Value = routes{randi(numel(routes))};
            end

            if app.cbAutoRecommend.Value
                applyRecommendation(false);
            end

            r = computeResult();

            PacketID(i) = r.packetID;
            DeviceID(i) = r.deviceID;
            Application(i) = r.appType;
            DeviceType(i) = r.deviceType;
            DataType(i) = r.dataType;
            Model(i) = r.model;
            Route(i) = r.route;
            CompatibilityOK(i) = r.compatibilityOK;

            Delay_ms(i) = r.Ttotal;
            AI_Delay_ms(i) = r.TAIdetailed;
            Network_ms(i) = r.Tnetwork;
            Response_ms(i) = r.Tresponse;
            SLA_ms(i) = r.SLA;
            SLAPass(i) = r.slaPass;
            Confidence(i) = r.confidence;
            EventProb(i) = r.anomalyProb;
            PredictedEvent(i) = r.anomalyProb >= r.threshold;

            % Synthetic ground truth for educational validation:
            % Event is sampled according to the latent event probability.
            GroundTruthEvent(i) = rand() < r.anomalyProb;

            PDR(i) = r.PDR;
            Energy_J(i) = r.Etotal;
            PrivacyScore(i) = r.privacyScore;
            RouteCost(i) = r.routeCost;
            FeatureDim(i) = r.featureDim;
            ModelOps_M(i) = r.modelOpsM;
        end

        T = table(PacketID, DeviceID, Application, DeviceType, DataType, Model, Route, ...
            CompatibilityOK, Delay_ms, AI_Delay_ms, Network_ms, Response_ms, SLA_ms, SLAPass, Confidence, ...
            EventProb, PredictedEvent, GroundTruthEvent, PDR, Energy_J, PrivacyScore, ...
            RouteCost, FeatureDim, ModelOps_M);

        app.lastBatchTable = T;
        metrics = computeValidationMetrics(T);
        app.lastValidationMetrics = metrics;

        restoreControls(snap);
        syncPreviewFromControls();

        showBatchDashboard(T, metrics);
        showBatchSummary(metrics, N);
        setLog(sprintf('Batch Simulation hoàn tất: N=%d | SLA pass-rate=%.2f %% | F1=%.3f', ...
            N, 100*metrics.slaPassRate, metrics.f1));
    end

    function compareRoutes(~, ~)
        snap = snapshotControls();

        routes = ["MEC Only"; "Edge-Cloud Cooperation"; "Cloud Only"];
        n = numel(routes);

        Route = strings(n,1);
        Delay_ms = zeros(n,1);
        AI_Delay_ms = zeros(n,1);
        Network_ms = zeros(n,1);
        SLA_ms = zeros(n,1);
        SLAPass = false(n,1);
        Confidence = zeros(n,1);
        Energy_J = zeros(n,1);
        PrivacyScore = zeros(n,1);
        RouteCost = zeros(n,1);
        Overhead_kB = zeros(n,1);

        for i = 1:n
            app.ddRoute.Value = char(routes(i));
            r = computeResult();

            Route(i) = routes(i);
            Delay_ms(i) = r.Ttotal;
            AI_Delay_ms(i) = r.TAIdetailed;
            Network_ms(i) = r.Tnetwork;
            SLA_ms(i) = r.SLA;
            SLAPass(i) = r.slaPass;
            Confidence(i) = r.confidence;
            Energy_J(i) = r.Etotal;
            PrivacyScore(i) = r.privacyScore;
            RouteCost(i) = r.routeCost;
            Overhead_kB(i) = r.overheadKB;
        end

        T = table(Route, Delay_ms, AI_Delay_ms, Network_ms, SLA_ms, SLAPass, ...
            Confidence, Energy_J, PrivacyScore, RouteCost, Overhead_kB);

        app.lastRouteTable = T;
        restoreControls(snap);
        syncPreviewFromControls();

        showRouteComparisonDashboard(T);
        showRouteSummary(T);
        setLog('Route Comparison hoàn tất: đã so sánh MEC Only / Edge-Cloud / Cloud Only.');
    end

    function metrics = computeValidationMetrics(T)
        N = height(T);
        delays = T.Delay_ms;
        delaysSorted = sort(delays);
        p90idx = max(1, ceil(0.90*N));
        p95idx = max(1, ceil(0.95*N));

        pred = T.PredictedEvent;
        gt = T.GroundTruthEvent;

        TP = sum(pred & gt);
        TN = sum(~pred & ~gt);
        FP = sum(pred & ~gt);
        FN = sum(~pred & gt);

        accuracy = (TP + TN) / max(N,1);
        precision = TP / max(TP + FP, 1);
        recall = TP / max(TP + FN, 1);
        f1 = 2 * precision * recall / max(precision + recall, eps);

        metrics = struct();
        metrics.N = N;
        metrics.meanDelay = mean(delays);
        metrics.medianDelay = median(delays);
        metrics.stdDelay = std(delays);
        metrics.p90Delay = delaysSorted(p90idx);
        metrics.p95Delay = delaysSorted(p95idx);
        metrics.maxDelay = max(delays);
        metrics.minDelay = min(delays);
        metrics.meanAIDelay = mean(T.AI_Delay_ms);
        if any(strcmp(T.Properties.VariableNames,'Network_ms'))
            metrics.meanNetworkDelay = mean(T.Network_ms);
        else
            metrics.meanNetworkDelay = mean(T.Delay_ms - T.AI_Delay_ms);
        end
        metrics.slaPassRate = mean(T.SLAPass);
        metrics.slaFailRate = 1 - metrics.slaPassRate;
        metrics.meanConfidence = mean(T.Confidence);
        metrics.meanPDR = mean(T.PDR);
        metrics.meanPacketLoss = mean(1 - T.PDR);
        metrics.meanEnergy = mean(T.Energy_J);
        metrics.meanPrivacy = mean(T.PrivacyScore);
        metrics.meanRouteCost = mean(T.RouteCost);
        metrics.compatibilityRate = mean(T.CompatibilityOK);
        metrics.accuracy = accuracy;
        metrics.precision = precision;
        metrics.recall = recall;
        metrics.f1 = f1;
        metrics.TP = TP; metrics.TN = TN; metrics.FP = FP; metrics.FN = FN;
    end

    function showBatchDashboard(T, metrics)
        figB = uifigure('Name', 'Block 12 v18 - Professional Validation Dashboard', ...
            'Position', [50 40 1450 850]);

        g = uigridlayout(figB, [3 3]);
        g.RowHeight = {260, 260, '1x'};
        g.ColumnWidth = {390, '1x', '1x'};
        g.Padding = [10 10 10 10];
        g.RowSpacing = 10;
        g.ColumnSpacing = 10;

        panelMetrics = uipanel(g, 'Title', '1. Batch Statistics Summary', 'FontWeight', 'bold');
        panelMetrics.Layout.Row = 1;
        panelMetrics.Layout.Column = 1;

        metricsGrid = uigridlayout(panelMetrics, [1 1]);
        metricsGrid.Padding = [8 8 8 8];
        metricText = uitextarea(metricsGrid, ...
            'Editable', 'off', ...
            'FontName', 'Consolas', ...
            'FontSize', 12, ...
            'Value', { ...
            sprintf('N packets              : %d', metrics.N); ...
            sprintf('Mean / Median delay    : %.2f / %.2f ms', metrics.meanDelay, metrics.medianDelay); ...
            sprintf('P90 / P95 delay        : %.2f / %.2f ms', metrics.p90Delay, metrics.p95Delay); ...
            sprintf('Min / Max delay        : %.2f / %.2f ms', metrics.minDelay, metrics.maxDelay); ...
            sprintf('Mean network delay     : %.2f ms', metrics.meanNetworkDelay); ...
            sprintf('Mean AI delay          : %.2f ms', metrics.meanAIDelay); ...
            sprintf('SLA pass / fail rate   : %.2f %% / %.2f %%', 100*metrics.slaPassRate, 100*metrics.slaFailRate); ...
            sprintf('Mean confidence        : %.2f %%', 100*metrics.meanConfidence); ...
            sprintf('Mean PDR / loss        : %.3f / %.3f', metrics.meanPDR, metrics.meanPacketLoss); ...
            sprintf('Mean energy            : %.4f J', metrics.meanEnergy); ...
            sprintf('Mean privacy / cost    : %.2f / %.2f', metrics.meanPrivacy, metrics.meanRouteCost); ...
            sprintf('Compatibility rate     : %.2f %%', 100*metrics.compatibilityRate); ...
            sprintf('Accuracy / Precision   : %.3f / %.3f', metrics.accuracy, metrics.precision); ...
            sprintf('Recall / F1            : %.3f / %.3f', metrics.recall, metrics.f1); ...
            sprintf('TP/TN/FP/FN            : %d / %d / %d / %d', metrics.TP, metrics.TN, metrics.FP, metrics.FN) ...
            });

        axSLA = uiaxes(g);
        axSLA.Layout.Row = 1;
        axSLA.Layout.Column = 2;
        bar(axSLA, categorical({'PASS','FAIL'}), [100*metrics.slaPassRate, 100*metrics.slaFailRate]);
        title(axSLA, '2. SLA Pass-rate Chart');
        ylabel(axSLA, 'Percent (%)');
        ylim(axSLA, [0 100]);

        axDist = uiaxes(g);
        axDist.Layout.Row = 1;
        axDist.Layout.Column = 3;
        histogram(axDist, T.Delay_ms, max(6, round(sqrt(height(T)))));
        hold(axDist, 'on');
        xline(axDist, metrics.p95Delay, '--', sprintf('P95 %.1f ms', metrics.p95Delay), 'LineWidth', 1.5);
        xline(axDist, metrics.meanDelay, '-', sprintf('Mean %.1f ms', metrics.meanDelay), 'LineWidth', 1.2);
        hold(axDist, 'off');
        title(axDist, '3. Delay Distribution / P95');
        xlabel(axDist, 'Total delay (ms)');
        ylabel(axDist, 'Packet count');

        axAI = uiaxes(g);
        axAI.Layout.Row = 2;
        axAI.Layout.Column = 1;
        bar(axAI, categorical({'Acc','Prec','Recall','F1'}), ...
            [metrics.accuracy, metrics.precision, metrics.recall, metrics.f1]);
        title(axAI, '4. AI Metrics');
        ylim(axAI, [0 1]);

        axCM = uiaxes(g);
        axCM.Layout.Row = 2;
        axCM.Layout.Column = 2;
        cm = [metrics.TP metrics.FP; metrics.FN metrics.TN];
        imagesc(axCM, cm);
        title(axCM, '5. Confusion Matrix');
        xticks(axCM, [1 2]); yticks(axCM, [1 2]);
        xticklabels(axCM, {'Pred Event','Pred Normal'});
        yticklabels(axCM, {'True Event','True Normal'});
        colorbar(axCM);
        text(axCM, 1, 1, sprintf('TP=%d', metrics.TP), 'HorizontalAlignment','center', 'FontWeight','bold');
        text(axCM, 2, 1, sprintf('FP=%d', metrics.FP), 'HorizontalAlignment','center', 'FontWeight','bold');
        text(axCM, 1, 2, sprintf('FN=%d', metrics.FN), 'HorizontalAlignment','center', 'FontWeight','bold');
        text(axCM, 2, 2, sprintf('TN=%d', metrics.TN), 'HorizontalAlignment','center', 'FontWeight','bold');

        axSys = uiaxes(g);
        axSys.Layout.Row = 2;
        axSys.Layout.Column = 3;
        bar(axSys, categorical({'Energy','Privacy','RouteCost'}), ...
            [metrics.meanEnergy, metrics.meanPrivacy, metrics.meanRouteCost/100]);
        title(axSys, '6. Energy / Privacy / Route Cost');
        ylabel(axSys, 'Normalized / raw mixed scale');

        panelTable = uipanel(g, 'Title', '7. Batch Result Table', 'FontWeight', 'bold');
        panelTable.Layout.Row = 3;
        panelTable.Layout.Column = [1 3];

        uitable(panelTable, 'Data', T, 'Units', 'normalized', 'Position', [0 0 1 1]);
    end

    function showRouteComparisonDashboard(T)
        figR = uifigure('Name', 'Block 12 v18 - Professional Route Comparison Dashboard', ...
            'Position', [120 90 1180 760]);

        g = uigridlayout(figR, [3 2]);
        g.RowHeight = {250, 250, '1x'};
        g.ColumnWidth = {'1x', '1x'};
        g.Padding = [10 10 10 10];
        g.RowSpacing = 10;
        g.ColumnSpacing = 10;

        ax1 = uiaxes(g);
        ax1.Layout.Row = 1;
        ax1.Layout.Column = 1;
        bar(ax1, categorical(T.Route), T.Delay_ms);
        title(ax1, '1. Total Delay by Route');
        ylabel(ax1, 'ms');

        ax2 = uiaxes(g);
        ax2.Layout.Row = 1;
        ax2.Layout.Column = 2;
        bar(ax2, categorical(T.Route), [T.Network_ms, T.AI_Delay_ms], 'stacked');
        title(ax2, '2. Network + AI Delay Breakdown');
        ylabel(ax2, 'ms');
        legend(ax2, {'Network','AI'}, 'Location', 'best');

        ax3 = uiaxes(g);
        ax3.Layout.Row = 2;
        ax3.Layout.Column = 1;
        bar(ax3, categorical(T.Route), [T.Energy_J, T.PrivacyScore, T.RouteCost/100]);
        title(ax3, '3. Energy / Privacy / Route Cost');
        legend(ax3, {'Energy J','Privacy','Cost/100'}, 'Location', 'best');

        ax4 = uiaxes(g);
        ax4.Layout.Row = 2;
        ax4.Layout.Column = 2;
        bar(ax4, categorical(T.Route), double(T.SLAPass)*100);
        title(ax4, '4. SLA Status by Route');
        ylabel(ax4, 'PASS = 100, FAIL = 0');
        ylim(ax4, [0 110]);

        panelTable = uipanel(g, 'Title', '5. Route Comparison Table', 'FontWeight', 'bold');
        panelTable.Layout.Row = 3;
        panelTable.Layout.Column = [1 2];
        uitable(panelTable, 'Data', T, 'Units', 'normalized', 'Position', [0 0 1 1]);
    end

    function showBatchSummary(metrics, N)
        txt = sprintf([ ...
            'EXPERIMENT VALIDATION SUMMARY - BATCH SIMULATION\n' ...
            '================================================\n\n' ...
            'Số packet mô phỏng       : %d\n' ...
            'Mean delay               : %.2f ms\n' ...
            'Median delay             : %.2f ms\n' ...
            'P95 delay                : %.2f ms\n' ...
            'SLA pass rate            : %.2f %%\n' ...
            'Mean AI delay            : %.2f ms\n' ...
            'Mean confidence          : %.2f %%\n' ...
            'Mean PDR                 : %.3f\n' ...
            'Mean energy              : %.4f J\n' ...
            'Mean privacy score       : %.2f\n' ...
            'Compatibility rate       : %.2f %%\n\n' ...
            'AI evaluation metrics dựa trên ground-truth mô phỏng:\n' ...
            'Accuracy                 : %.3f\n' ...
            'Precision                : %.3f\n' ...
            'Recall                   : %.3f\n' ...
            'F1-score                 : %.3f\n' ...
            'Confusion TP/TN/FP/FN    : %d / %d / %d / %d\n\n' ...
            'Ý nghĩa kỹ thuật:\n' ...
            '- Mean delay cho thấy độ trễ trung bình.\n' ...
            '- P95 delay cho thấy tình huống xấu nhưng thường gặp trong 95%% mẫu.\n' ...
            '- SLA pass rate cho biết tỷ lệ packet đạt yêu cầu dịch vụ.\n' ...
            '- F1-score cân bằng giữa precision và recall cho bài toán event/anomaly.\n'], ...
            N, metrics.meanDelay, metrics.medianDelay, metrics.p95Delay, 100*metrics.slaPassRate, ...
            metrics.meanAIDelay, 100*metrics.meanConfidence, metrics.meanPDR, ...
            metrics.meanEnergy, metrics.meanPrivacy, 100*metrics.compatibilityRate, ...
            metrics.accuracy, metrics.precision, metrics.recall, metrics.f1, ...
            metrics.TP, metrics.TN, metrics.FP, metrics.FN);

        app.infoArea.Value = regexp(txt, newline, 'split');
    end

    function showRouteSummary(T)
        [bestDelay, idxDelay] = min(T.Delay_ms);
        [bestCost, idxCost] = min(T.RouteCost);
        [bestPrivacy, idxPrivacy] = max(T.PrivacyScore);

        txt = sprintf([ ...
            'ROUTE COMPARISON SUMMARY\n' ...
            '========================\n\n' ...
            'Best latency route      : %s (%.2f ms)\n' ...
            'Best route cost         : %s (%.2f)\n' ...
            'Best privacy route      : %s (%.2f)\n\n' ...
            'Bảng so sánh:\n' ...
            '%s: Delay %.2f ms | Energy %.4f J | Privacy %.2f | Cost %.2f | SLA %s\n' ...
            '%s: Delay %.2f ms | Energy %.4f J | Privacy %.2f | Cost %.2f | SLA %s\n' ...
            '%s: Delay %.2f ms | Energy %.4f J | Privacy %.2f | Cost %.2f | SLA %s\n\n' ...
            'Ý nghĩa kỹ thuật:\n' ...
            '- MEC thường tốt cho latency và privacy hơn Cloud Only.\n' ...
            '- Cloud Only có thể xử lý model nặng nhưng thường tăng network delay.\n' ...
            '- Edge-Cloud là phương án trung gian khi MEC cần hỗ trợ thêm từ cloud.\n'], ...
            T.Route(idxDelay), bestDelay, ...
            T.Route(idxCost), bestCost, ...
            T.Route(idxPrivacy), bestPrivacy, ...
            T.Route(1), T.Delay_ms(1), T.Energy_J(1), T.PrivacyScore(1), T.RouteCost(1), boolPass(T.SLAPass(1)), ...
            T.Route(2), T.Delay_ms(2), T.Energy_J(2), T.PrivacyScore(2), T.RouteCost(2), boolPass(T.SLAPass(2)), ...
            T.Route(3), T.Delay_ms(3), T.Energy_J(3), T.PrivacyScore(3), T.RouteCost(3), boolPass(T.SLAPass(3)));

        app.infoArea.Value = regexp(txt, newline, 'split');
    end

    function exportLastResults(~, ~)
        if ~isempty(app.lastBatchTable)
            T = app.lastBatchTable;
            defaultName = 'Block12_v14_BatchResults.csv';
        elseif ~isempty(app.lastRouteTable)
            T = app.lastRouteTable;
            defaultName = 'Block12_v14_RouteComparison.csv';
        else
            setLog('Chưa có batch/route results để export. Hãy bấm Run Batch Simulation hoặc Compare Routes trước.');
            return;
        end

        [file, path] = uiputfile('*.csv', 'Save Block 12 Results', defaultName);
        if isequal(file,0)
            setLog('Đã hủy export CSV.');
            return;
        end

        outFile = fullfile(path, file);
        writetable(T, outFile);
        setLog(sprintf('Đã export CSV:\n%s', outFile));
    end

    function exportReportSummary(~, ~)
        if isempty(app.lastValidationMetrics) && isempty(app.lastRouteTable)
            setLog('Chưa có validation results để xuất report. Hãy chạy Batch Simulation hoặc Compare Routes trước.');
            return;
        end

        [file, path] = uiputfile('*.txt', 'Save Block 12 Report Summary', 'Block12_v18_ReportSummary.txt');
        if isequal(file,0)
            setLog('Đã hủy export report summary.');
            return;
        end

        outFile = fullfile(path, file);
        fid = fopen(outFile, 'w');
        if fid < 0
            setLog('Không thể tạo file report summary.');
            return;
        end

        fprintf(fid, 'BLOCK 12 - AI / EDGE INTELLIGENCE - REPORT SUMMARY v18\n');
        fprintf(fid, '======================================================\n\n');

        if ~isempty(app.lastValidationMetrics)
            m = app.lastValidationMetrics;
            fprintf(fid, '1. Batch Validation Summary\n');
            fprintf(fid, 'N packets              : %d\n', m.N);
            fprintf(fid, 'Mean / Median delay    : %.2f / %.2f ms\n', m.meanDelay, m.medianDelay);
            fprintf(fid, 'P90 / P95 delay        : %.2f / %.2f ms\n', m.p90Delay, m.p95Delay);
            fprintf(fid, 'SLA pass-rate          : %.2f %%\n', 100*m.slaPassRate);
            fprintf(fid, 'Mean AI delay          : %.2f ms\n', m.meanAIDelay);
            fprintf(fid, 'Mean network delay     : %.2f ms\n', m.meanNetworkDelay);
            fprintf(fid, 'Mean confidence        : %.2f %%\n', 100*m.meanConfidence);
            fprintf(fid, 'Mean PDR               : %.3f\n', m.meanPDR);
            fprintf(fid, 'Mean energy            : %.4f J\n', m.meanEnergy);
            fprintf(fid, 'Mean privacy score     : %.2f\n', m.meanPrivacy);
            fprintf(fid, 'Mean route cost        : %.2f\n', m.meanRouteCost);
            fprintf(fid, 'Accuracy / Precision   : %.3f / %.3f\n', m.accuracy, m.precision);
            fprintf(fid, 'Recall / F1            : %.3f / %.3f\n', m.recall, m.f1);
            fprintf(fid, 'TP/TN/FP/FN            : %d / %d / %d / %d\n\n', m.TP, m.TN, m.FP, m.FN);

            fprintf(fid, 'Technical interpretation:\n');
            if m.slaPassRate < 0.8
                fprintf(fid, '- SLA pass-rate is below 80%%, so route/network delay should be optimized.\n');
            else
                fprintf(fid, '- SLA pass-rate is acceptable for the current simulation setting.\n');
            end
            if m.recall < 0.7
                fprintf(fid, '- Recall is low; reduce false negatives by tuning AI threshold or model sensitivity.\n');
            else
                fprintf(fid, '- Recall is acceptable; event miss rate is controlled.\n');
            end
            fprintf(fid, '- P95 delay should be used as an engineering stability indicator.\n\n');
        end

        if ~isempty(app.lastRouteTable)
            T = app.lastRouteTable;
            [~, iDelay] = min(T.Delay_ms);
            [~, iCost] = min(T.RouteCost);
            [~, iPrivacy] = max(T.PrivacyScore);
            fprintf(fid, '2. Route Comparison Summary\n');
            fprintf(fid, 'Best latency route      : %s\n', T.Route(iDelay));
            fprintf(fid, 'Best route cost         : %s\n', T.Route(iCost));
            fprintf(fid, 'Best privacy route      : %s\n\n', T.Route(iPrivacy));
        end

        fclose(fid);
        setLog(sprintf('Đã export report summary:\\n%s', outFile));
    end

    function showValidationTheory(~, ~)
        txt = [ ...
            "VALIDATION THEORY - ENGINEERING CHECKLIST"; ...
            "=========================================="; ...
            ""; ...
            "1. Vì sao cần batch simulation?"; ...
            "Một packet đơn lẻ chỉ chứng minh pipeline hoạt động. Kỹ sư thực nghiệm cần nhiều packet để đánh giá mean delay, P95 delay, SLA pass-rate và độ ổn định."; ...
            ""; ...
            "2. Các metric nên có:"; ...
            "- Mean delay: độ trễ trung bình."; ...
            "- P95 delay: 95% packet có delay nhỏ hơn giá trị này."; ...
            "- SLA pass-rate: tỷ lệ packet đạt SLA."; ...
            "- Accuracy, Precision, Recall, F1-score: đánh giá chất lượng AI/event detection."; ...
            "- Energy: năng lượng tiêu thụ."; ...
            "- Route cost: cost tổng hợp từ delay, energy, bandwidth, memory, privacy."; ...
            ""; ...
            "3. Vì sao cần Route Comparison?"; ...
            "MEC Only, Edge-Cloud Cooperation và Cloud Only có trade-off khác nhau. MEC thường giảm latency và tăng privacy, Cloud có thể mạnh hơn về compute nhưng network delay cao hơn."; ...
            ""; ...
            "4. Ground truth trong app này là gì?"; ...
            "Đây là ground-truth mô phỏng dựa trên xác suất event tiềm ẩn của packet. Nó dùng cho giáo dục/validation pipeline, chưa thay thế dataset thực tế."; ...
            ""; ...
            "5. Để tiến tới thực nghiệm thật:"; ...
            "- Cần dataset thật."; ...
            "- Cần model thật đã train."; ...
            "- Cần ground-truth label."; ...
            "- Cần đo CPU/GPU/RAM/FPS nếu chạy camera AI."; ...
            "- Cần export CSV/Excel để phân tích và đưa vào báo cáo." ...
            ];
        app.infoArea.Value = cellstr(txt);
    end

    function s = snapshotControls()
        s = struct();
        s.appType = app.ddAppType.Value;
        s.deviceType = app.ddDeviceType.Value;
        s.dataType = app.ddDataType.Value;
        s.autoRecommend = app.cbAutoRecommend.Value;
        s.model = app.ddModel.Value;
        s.route = app.ddRoute.Value;
        s.packetID = app.edPacketID.Value;
        s.deviceID = app.edDeviceID.Value;
        s.sensorValue = app.edTemp.Value;
        s.sensorState = app.ddVibration.Value;
        s.packetSize = app.edPacketSize.Value;
        s.dataRate = app.edDataRate.Value;
        s.pdr = app.edPDR.Value;
        s.Tnetwork = app.edTnetwork.Value;
        s.Tpre = app.edTpre.Value;
        s.Tinfer = app.edTinfer.Value;
        s.Tpost = app.edTpost.Value;
        s.Tresponse = app.edTresponse.Value;
        s.SLA = app.edSLA.Value;
        s.threshold = app.edThreshold.Value;
        s.energy = app.edEnergy.Value;
        s.autoInput = app.cbAutoInput.Value;
    end

    function restoreControls(s)
        app.ddAppType.Value = s.appType;
        app.ddDeviceType.Value = s.deviceType;
        app.ddDataType.Value = s.dataType;
        app.cbAutoRecommend.Value = s.autoRecommend;
        app.ddModel.Value = s.model;
        app.ddRoute.Value = s.route;
        app.edPacketID.Value = s.packetID;
        app.edDeviceID.Value = s.deviceID;
        app.edTemp.Value = s.sensorValue;
        app.ddVibration.Value = s.sensorState;
        app.edPacketSize.Value = s.packetSize;
        app.edDataRate.Value = s.dataRate;
        app.edPDR.Value = s.pdr;
        app.edTnetwork.Value = s.Tnetwork;
        app.edTpre.Value = s.Tpre;
        app.edTinfer.Value = s.Tinfer;
        app.edTpost.Value = s.Tpost;
        app.edTresponse.Value = s.Tresponse;
        app.edSLA.Value = s.SLA;
        app.edThreshold.Value = s.threshold;
        app.edEnergy.Value = s.energy;
        app.cbAutoInput.Value = s.autoInput;
        applyRecommendation(false);
    end

    function s = thresholdStatusText(result)
        if result.anomalyProb >= result.threshold
            s = sprintf('Event probability reached threshold (%.2f%% >= %.2f%%)', ...
                100*result.anomalyProb, 100*result.threshold);
        else
            s = sprintf('Below threshold / continue monitoring (%.2f%% < %.2f%%)', ...
                100*result.anomalyProb, 100*result.threshold);
        end
    end

    function s = confidenceLevelText(conf)
        if conf >= 0.80
            s = 'High';
        elseif conf >= 0.60
            s = 'Medium';
        else
            s = 'Low';
        end
    end

    function t = boolPass(flag)
        if flag
            t = 'PASS';
        else
            t = 'FAIL';
        end
    end


end
