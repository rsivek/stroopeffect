function varargout = stroopeffect(varargin)
% COLORS MATLAB code for stroopeffect.fig
%      COLORS, by itself, creates a new COLORS or raises the existing
%      singleton*.
%
%      H = COLORS returns the handle to a new COLORS or the handle to
%      the existing singleton*.
%
%      COLORS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in COLORS.M with the given input arguments.
%
%      COLORS('Property','Value',...) creates a new COLORS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before stroopeffect_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to stroopeffect_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help stroopeffect

% Last Modified by GUIDE v2.5 26-Aug-2015 08:44:17

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @stroopeffect_OpeningFcn, ...
                   'gui_OutputFcn',  @stroopeffect_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before stroopeffect is made visible.
function stroopeffect_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to stroopeffect (see VARARGIN)

% Choose default command line output for stroopeffect
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes stroopeffect wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = stroopeffect_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% Add the getkey function so we can grab key presses
addpath('getkey');

%Define our colors
colorStrings = {'RED', 'GREEN', 'BLUE'};
colors = [1,0,0; 0,1,0; 0,0,1];
numColors = 3;

%Number of tests to perform on the user
numDataPoints = 20;
try
    load(savFilename)
catch
    %Initialize variables if the file doesn't exist
    matchedWordData = [];
    jumbledWordData = [];
end

handles.text1.String = 'Press any key to start test.';
handles.text1.ForegroundColor = [0,0,0];

pause;
matchedTimes = zeros(numDataPoints,6);
matchedErrors = [];

handles.text1.String = '';

pause(1);

%Run the matched color test
for i = 1:numDataPoints
    selectedIndex = randi(numColors);
    handles.text1.String = colorStrings(selectedIndex);
    handles.text1.ForegroundColor = colors(selectedIndex,:);
    tic;
    matchedTimes(i,:) = clock;
    key = getkey;
    tElapsed = toc;
    matchedWordData = [matchedWordData, tElapsed];
    if key-48 ~= selectedIndex
        matchedErrors = [matchedErrors i];
    end
    handles.text1.String = '';
    pause(0.3);
end

jumbledTimes = zeros(numDataPoints,6);
jumbledErrors = [];

%Run the jumbled color test
for i = 1:numDataPoints
    selectedIndex = randi(numColors);
    handles.text1.ForegroundColor = colors(selectedIndex,:);
    stringIndex = selectedIndex;
    while stringIndex == selectedIndex
        stringIndex = randi(numColors);
    end
    handles.text1.String = colorStrings(stringIndex);
    tic;
    jumbledTimes(i,:) = clock;
    key = getkey;
    tElapsed = toc;
    jumbledWordData = [jumbledWordData, tElapsed];
    if key-48 ~= selectedIndex
        jumbledErrors = [jumbledErrors i];
    end
    handles.text1.String = '';
    pause(0.3);
end

%Get the maximum for the x axis
maxDataPoints = length(matchedWordData) + length(jumbledWordData);

%Calculate the means
mwd = matchedWordData;
mwd(matchedErrors) = [];
jwd = jumbledWordData;
jwd(jumbledErrors) = [];
matchedWordMean = mean(mwd);
jumbledWordMean = mean(jwd);

figure
plot(1:length(matchedWordData), matchedWordData, 'or')
hold on
plot(length(matchedWordData)+1:length(matchedWordData)+ ...
    length(jumbledWordData), jumbledWordData, 'ob')
plot([0,maxDataPoints],[matchedWordMean,matchedWordMean])
plot([0,maxDataPoints],[jumbledWordMean,jumbledWordMean])
plot(matchedErrors,matchedWordData(matchedErrors),'xr')
plot(length(matchedWordData)+jumbledErrors,jumbledWordData(jumbledErrors),'xb')
hold off

ylabel('Reaction Time')
xlabel('Test Index');
if(isempty(matchedErrors) && isempty(jumbledErrors))
    legend('Matched Words', 'Jumbled Words', 'Matched Mean', 'Jumbled Mean')
else
    if(isempty(matchedErrors))
        legend('Matched Words', 'Jumbled Words', 'Matched Mean', 'Jumbled Mean', ...
    'Jumbled Errors')
    else
        legend('Matched Words', 'Jumbled Words', 'Matched Mean', 'Jumbled Mean', ...
        'Matched Errors','Jumbled Errors')
    end
end
title('Reaction Time for Matched & Jumbled Color Indications')

fprintf('Matched Word Mean Reaction Time: %d\n', matchedWordMean);
fprintf('Matched Word Errors: %d\n', length(matchedErrors));
fprintf('Jumbled Word Mean Reaction Time: %d\n', jumbledWordMean);
fprintf('Jumbled Word Errors: %d\n', length(jumbledErrors));

varargout{2} = {matchedTimes jumbledTimes matchedWordData' jumbledWordData' matchedErrors jumbledErrors};