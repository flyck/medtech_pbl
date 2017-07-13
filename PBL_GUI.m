function varargout = PBL_GUI(varargin)
% PBL_GUI MATLAB code for PBL_GUI.fig
%      PBL_GUI, by itself, creates a new PBL_GUI or raises the existing
%      singleton*.
%
%      H = PBL_GUI returns the handle to a new PBL_GUI or the handle to
%      the existing singleton*.
%
%      PBL_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PBL_GUI.M with the given input arguments.
%
%      PBL_GUI('Property','Value',...) creates a new PBL_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before PBL_GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to PBL_GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help PBL_GUI

% Last Modified by GUIDE v2.5 13-Jul-2017 12:40:22

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @PBL_GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @PBL_GUI_OutputFcn, ...
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


% --- Executes just before PBL_GUI is made visible.
function PBL_GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to PBL_GUI (see VARARGIN)

% Choose default command line output for PBL_GUI
handles.output = hObject;

% fill listbox1 with filenames
files = dir(fullfile(pwd,'*ascan*'));
set(handles.listbox1,'string',{files.name});
% select the third item
set(handles.listbox1,'value',3);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes PBL_GUI wait for user response (see UIRESUME)
% uiwait(handles.GUIHandle);


% --- Outputs from this function are returned to the command line.
function varargout = PBL_GUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
C = getappdata(handles.GUIHandle, 'C');
if not(isempty(C))
    rmappdata(handles.GUIHandle, 'C');
end
werte_MaxMax = getappdata(handles.GUIHandle, 'werte_MaxMax');
if not(isempty(werte_MaxMax))
    rmappdata(handles.GUIHandle, 'werte_MaxMax');
end
% reset the edit fields
set(handles.text3, 'string', "...");
set(handles.edit1, 'string', 1);
selected_index = get(handles.listbox1,'value');
filenames = get(handles.listbox1,'string');
filename = filenames{selected_index};
if isempty(filename)
    fprintf('Error: Enter Text first\n');
else
    % Write code for computation you want to do 
    axes(handles.axes1);
    [C,CMAX] = PBL_Main("init", filename);
    % assignin('base', 'C', C); %writes to user workspace
    setappdata(handles.GUIHandle, 'C', C);
    setappdata(handles.GUIHandle, 'CMAX', CMAX);
end

% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
C = getappdata(handles.GUIHandle , 'C');
CMAX = getappdata(handles.GUIHandle , 'CMAX');
if isempty(C) || isempty(CMAX)
    fprintf('Error: Load MScan first.\n');
else
    axes(handles.axes1);
    werte_MaxMax = MtoBscan(C, CMAX);
    setappdata(handles.GUIHandle, 'werte_MaxMax', werte_MaxMax);
    % adapt the slider
    set(handles.slider1,'value',1);
    set(handles.slider1,'min',1);
    set(handles.slider1,'max',numel(werte_MaxMax)-1);
end

% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
C = getappdata(handles.GUIHandle , 'C');
C_Artefacts = getappdata(handles.GUIHandle , 'C_Artefacts');
werte_MaxMax = getappdata(handles.GUIHandle , 'werte_MaxMax');
if isempty(C) || isempty(C_Artefacts) || isempty(werte_MaxMax)
    fprintf('Error: Filter Artefacts first.\n');
else
    value = str2double(get(handles.edit1,'string'));
    axes(handles.axes2);
    lbound = werte_MaxMax(value);
    ubound = werte_MaxMax(value+1);
    fprintf("cutting artefacts from lbound %d to ubound %d\n", lbound, ubound);
    C_Artefacts = C_Artefacts(:,lbound:ubound);
    C= C(:,lbound:ubound);
    [DiameterMin, DiameterMax,DiameterEverage] = PBL_Diameter(C_Artefacts, C);
    setappdata(handles.GUIHandle, 'DiameterMin', DiameterMin);
    setappdata(handles.GUIHandle, 'DiameterMax', DiameterMax);
    setappdata(handles.GUIHandle, 'DiameterEverage', DiameterEverage);
    message = '';
    message = sprintf('%sDiameterMin: %.2f\n', message, DiameterMin);
    message = sprintf('%sDiameterMax: %.2f\n', message, DiameterMax);
    message = sprintf('%sDiameterAverage: %.2f\n', message, DiameterEverage);
    set(handles.text5,'String', message);
end


function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double
value = str2double(get(hObject,'String'));
werte_MaxMax = getappdata(handles.GUIHandle , 'werte_MaxMax');
if isempty(werte_MaxMax)
    fprintf('Error: Detect BScans first.\n');
else
    if value >= 1 && value <= numel(werte_MaxMax)-1
       % set the slider value
       set(handles.slider1,'value',value);
       % display the image range
       lbound = werte_MaxMax(value);
       ubound = werte_MaxMax(value+1);
       set(handles.text3, 'string',strcat(num2str(lbound)," - ",num2str(ubound)));
       % display the image if the boundaries are ok
       C = getappdata(handles.GUIHandle , 'C');
       [m,n] = size(C);
       if lbound >= 1 && ubound <= n
           % mark overlay in axes1
           axes(handles.axes1);
           PBL_GUI_PlotOverlay(C, werte_MaxMax, lbound, ubound);
           % display image in axes2
           axes(handles.axes2);
           C = C(:,lbound:ubound);
           imagesc(C);
       end
    end
end

% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over pushbutton1.
function pushbutton1_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double


% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
C = getappdata(handles.GUIHandle , 'C');
if isempty(C)
    fprintf('Error: Load MScan first.\n');
else
    axes(handles.axes1);
    [C_Artefacts, C] = PBL_Filter_Artefacts(C);
    setappdata(handles.GUIHandle, 'C', C);
    setappdata(handles.GUIHandle, 'C_Artefacts', C_Artefacts);
end


% --- Executes on selection change in listbox1.
function listbox1_Callback(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox1


% --- Executes during object creation, after setting all properties.
function listbox1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
werte_MaxMax = getappdata(handles.GUIHandle , 'werte_MaxMax');
if isempty(werte_MaxMax)
    fprintf('Error: Detect Bscanfirst.\n');
else
    ubound = numel(werte_MaxMax)-1;
    set(hObject,'Max', ubound);
    value = round(get(hObject,'Value'));
    set(hObject, 'Value', value); 
    set(handles.edit1,'String',num2str(value));
    % do what he edit1 callback does, set text and display the images
    lbound = werte_MaxMax(value);
    ubound = werte_MaxMax(value+1);
    set(handles.text3, 'string',strcat(num2str(lbound)," - ",num2str(ubound)));
    % display the image if the boundaries are ok
    C = getappdata(handles.GUIHandle , 'C');
    [m,n] = size(C);
    if lbound >= 1 && ubound <= n
       % mark overlay in axes1
       axes(handles.axes1);
       PBL_GUI_PlotOverlay(C, werte_MaxMax, lbound, ubound);
       % display image in axes2
       axes(handles.axes2);
       C = C(:,lbound:ubound);
       imagesc(C);
    end
% attempt to make the slider fit the image position, the slider seems
% too rigid for this though
%     ubound = werte_MaxMax(numel(werte_MaxMax));
%     lbound = werte_MaxMax(1);
%     % load the structure
%     handles = guidata(hObject);
%     set(hObject, 'max', ubound);
%     % set the slider to the minimal boundary if it is in default state
%     if get(hObject,'Value') == 1
%         set(hObject, 'Value', lbound);
%         fprintf("Setting value to lbound %d\n", lbound);
%     end
%     % round the slider value to one of the possible values in werte_MaxMax
%     value = get(hObject,'Value');
%     for i = 1 : numel(werte_MaxMax)
%         if value < werte_MaxMax(i)
%             break
%         end
%     end
%     % round to nearest number
%     if i > 1 % respect werte_MaxMax boundaries
%         delta = werte_MaxMax(i) - value
%         percent = ( werte_MaxMax(i) - werte_MaxMax(i-1) ) / delta
%         if percent > 0.5
%             new_Value = werte_MaxMax(i);
%         else
%             new_Value = werte_MaxMax(i-1);
%         end
%     else
%         new_Value = 1;
%     end
%     fprintf("Setting value to i %d\n", new_Value);
%     set(hObject, 'Value', new_Value);
    % update the structure
    guidata(hObject,handles);
end
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
