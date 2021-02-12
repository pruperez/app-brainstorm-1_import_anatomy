% brainlife.io App for Brainstorm MEEG data analysis
%
% Author: Guiomar Niso
%
% Copyright (c) 2020 brainlife.io 
%
% Indiana University

%% Add submodules
% Submodules: libraries necessary to run the code
% Added to this App GitHub repository and automatically downloaded with the App 
% Need to add them MatLab path:
addpath(genpath(pwd))

%% Load config.json
% Load inputs from config.json
% Inputs are stored in config.input1, config.input2, etc
config = loadjson('config.json','ParseStringArray',1); % requires submodule to read JSON files in MatLab

%% Parameters
% Subject name
SubjectName = 'Subject01';
AnatDir = fullfile(config.output);

%% CREATE PROTOCOL 
disp([10 '> Step #1: Create protocol' 10]);
% The protocol name has to be a valid folder name (no spaces, no weird characters...)
ProtocolName = 'Protocol01';
% Start brainstorm without the GUI
if ~brainstorm('status')
    brainstorm nogui
end
% Delete existing protocol
gui_brainstorm('DeleteProtocol', ProtocolName);
% Create new protocol
gui_brainstorm('CreateProtocol', ProtocolName, 0, 0);
% Start a new report
bst_report('Start');
% Reset colormaps
bst_colormaps('RestoreDefaults', 'meg');

%% IMPORT ANATOMY 
disp([10 '> Step #2: Import anatomy' 10]);
% Process: Import FreeSurfer folder
bst_process('CallProcess', 'process_import_anatomy', [], [], ...
    'subjectname', SubjectName, ...
    'mrifile',     {AnatDir, 'FreeSurfer'}, ...
    'nvertices',   15000, ...
    'nas', [0, 0, 0], ...
    'lpa', [0, 0, 0], ...
    'rpa', [0, 0, 0], ...
    'ac',  [0, 0, 0], ...
    'pc',  [0, 0, 0], ...
    'ih',  [0, 0, 0]);
% This automatically calls the SPM registration procedure because the AC/PC/IH points are not defined
%   'nas', [127, 213, 139], ...
%     'lpa', [ 52, 113,  96], ...
%     'rpa', [202, 113,  91], ...
% //// FUTURE: load fiducial points from file if available: nas, lpa, rpa

%% ===== TUTORIAL #3: EXPLORE ANATOMY ================================================
%  ===================================================================================
disp([10 '> Step #3: Explore anatomy' 10]);
% Get subject definition
sSubject = bst_get('Subject', SubjectName);
% Get MRI file and surface files
MriFile    = sSubject.Anatomy(sSubject.iAnatomy).FileName;
CortexFile = sSubject.Surface(sSubject.iCortex).FileName;
HeadFile   = sSubject.Surface(sSubject.iScalp).FileName;
% Display MRI
hFigMri1 = view_mri(MriFile);
hFigMri3 = view_mri_3d(MriFile, [], [], 'NewFigure');
hFigMri2 = view_mri_slices(MriFile, 'x', 20); 
pause(0.5);
% Close figures
close([hFigMri1 hFigMri2 hFigMri3]);
% Display scalp and cortex
hFigSurf = view_surface(HeadFile);
hFigSurf = view_surface(CortexFile, [], [], hFigSurf);
hFigMriSurf = view_mri(MriFile, CortexFile);
% Figure configuration
iTess = 2;
panel_surface('SetShowSulci',     hFigSurf, iTess, 1);
panel_surface('SetSurfaceColor',  hFigSurf, iTess, [1 0 0]);
panel_surface('SetSurfaceSmooth', hFigSurf, iTess, 0.5, 0);
panel_surface('SetSurfaceTransparency', hFigSurf, iTess, 0.8);
figure_3d('SetStandardView', hFigSurf, 'left');
pause(0.5);
% Close figures
close([hFigSurf hFigMriSurf]);

%% SAVE REPORT
% Save and display report
ReportFile = bst_report('Save', []);
reports_dir = [];
if ~isempty(reports_dir) && ~isempty(ReportFile)
    bst_report('Export', ReportFile, reports_dir);
else
    bst_report('Open', ReportFile);
end

disp([10 '> Done.' 10]);