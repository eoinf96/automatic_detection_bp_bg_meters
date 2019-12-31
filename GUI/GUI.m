function varargout = GUI(varargin)
% GUI MATLAB code for GUI.fig
%      GUI, by itself, creates a new GUI or raises the existing
%      singleton*.
%
%      H = GUI returns the handle to a new GUI or the handle to
%      the existing singleton*.
%
%      GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI.M with the given input arguments.
%
%      GUI('Property','Value',...) creates a new GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GUI

% Last Modified by GUIDE v2.5 30-Dec-2019 23:04:36

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @GUI_OutputFcn, ...
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


% --- Executes just before GUI is made visible.
function GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GUI (see VARARGIN)

% Choose default command line output for GUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes GUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = GUI_OutputFcn(hObject, eventdata, handles) 
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



function PathText_Callback(hObject, eventdata, handles)
% hObject    handle to PathText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of PathText as text
%        str2double(get(hObject,'String')) returns contents of PathText as a double


% --- Executes during object creation, after setting all properties.
function PathText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PathText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in GoButton.
function GoButton_Callback(hObject, eventdata, handles)
% hObject    handle to GoButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

File = get(handles.fullfile, 'String');


axes(handles.UploadedImage)
imshow(File)

%%%% Get parameters %%%%%%%


%%%%% Binarisation path
params.blob_extraction.Sauv.sigma_s         = str2double(get(handles.sigmabs,'String'));
params.blob_extraction.Sauv.sigma_r         = str2double(get(handles.sigmabr,'String'));
params.blob_extraction.Sauv.gamma           = str2double(get(handles.gammab,'String'));
params.blob_extraction.Sauv.k               = str2double(get(handles.k,'String'));
params.blob_extraction.Sauv.alpha           = str2double(get(handles.alpha,'String'));

%%%%% MSER path
params.blob_extraction.MSER.sigma_s         = str2double(get(handles.sigmams,'String'));
params.blob_extraction.MSER.sigma_r         = str2double(get(handles.sigmamr,'String'));
params.blob_extraction.MSER.gamma           = str2double(get(handles.gammam,'String'));
params.blob_extraction.MSER.T               = str2double(get(handles.t,'String'));
params.blob_extraction.MSER.Delta           = str2double(get(handles.delta,'String'));

%%%%% Blob clustering
params.blob_clustering.major_axis           = str2double(get(handles.fma_blob,'String'));
params.blob_clustering.minor_axis           = str2double(get(handles.fmi_blob,'String'));

params.blob_clustering.thresholds.Hue       = str2double(get(handles.th,'String'));
params.blob_clustering.thresholds.SW        = str2double(get(handles.tsw,'String'));
params.blob_clustering.thresholds.D         = str2double(get(handles.td,'String'));

%%%%% Digit combining
params.digit_clustering.minor_axis          = str2double(get(handles.fmi_digit,'String'));
params.digit_clustering.minor_axis_one      = str2double(get(handles.fmi_digit_one,'String'));
params.digit_clustering.major_axis          = str2double(get(handles.fma_digit,'String'));

params.digit_clustering.thresholds.Hue      = str2double(get(handles.tH_digit,'String'));
params.digit_clustering.thresholds.h        = str2double(get(handles.th_digit,'String'));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
params.device_type = get(handles.listboxmeter,'String');

Reading = get_reading_GUI(img,params);

if strcmp(params.device_type, 'Blood Glucose')
    Str = sprintf('Estimated Reading Value: %.1f \n', Reading);
else  
    Str = sprintf('Estimated Reading Value: \n Systolic Blood Pressure:  %.0f, \n Diastolic Blood Pressure:  %.0f, \n Heart Rate:  %.0f \n', Reading(end-2:end));
end

set(handles.text2, 'String', Str);



function th_Callback(hObject, eventdata, handles)
% hObject    handle to th (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of th as text
%        str2double(get(hObject,'String')) returns contents of th as a double


% --- Executes during object creation, after setting all properties.
function th_CreateFcn(hObject, eventdata, handles)
% hObject    handle to th (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function tsw_Callback(hObject, eventdata, handles)
% hObject    handle to tsw (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tsw as text
%        str2double(get(hObject,'String')) returns contents of tsw as a double


% --- Executes during object creation, after setting all properties.
function tsw_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tsw (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function td_Callback(hObject, eventdata, handles)
% hObject    handle to td (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of td as text
%        str2double(get(hObject,'String')) returns contents of td as a double


% --- Executes during object creation, after setting all properties.
function td_CreateFcn(hObject, eventdata, handles)
% hObject    handle to td (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function fma_blob_Callback(hObject, eventdata, handles)
% hObject    handle to fma_blob (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fma_blob as text
%        str2double(get(hObject,'String')) returns contents of fma_blob as a double


% --- Executes during object creation, after setting all properties.
function fma_blob_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fma_blob (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function fmi_blob_Callback(hObject, eventdata, handles)
% hObject    handle to fmi_blob (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fmi_blob as text
%        str2double(get(hObject,'String')) returns contents of fmi_blob as a double


% --- Executes during object creation, after setting all properties.
function fmi_blob_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fmi_blob (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function sigmams_Callback(hObject, eventdata, handles)
% hObject    handle to sigmams (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of sigmams as text
%        str2double(get(hObject,'String')) returns contents of sigmams as a double


% --- Executes during object creation, after setting all properties.
function sigmams_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sigmams (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function sigmamr_Callback(hObject, eventdata, handles)
% hObject    handle to sigmamr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of sigmamr as text
%        str2double(get(hObject,'String')) returns contents of sigmamr as a double


% --- Executes during object creation, after setting all properties.
function sigmamr_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sigmamr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function gammam_Callback(hObject, eventdata, handles)
% hObject    handle to gammam (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of gammam as text
%        str2double(get(hObject,'String')) returns contents of gammam as a double


% --- Executes during object creation, after setting all properties.
function gammam_CreateFcn(hObject, eventdata, handles)
% hObject    handle to gammam (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function t_Callback(hObject, eventdata, handles)
% hObject    handle to t (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of t as text
%        str2double(get(hObject,'String')) returns contents of t as a double


% --- Executes during object creation, after setting all properties.
function t_CreateFcn(hObject, eventdata, handles)
% hObject    handle to t (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function delta_Callback(hObject, eventdata, handles)
% hObject    handle to delta (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of delta as text
%        str2double(get(hObject,'String')) returns contents of delta as a double


% --- Executes during object creation, after setting all properties.
function delta_CreateFcn(hObject, eventdata, handles)
% hObject    handle to delta (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function sigmabs_Callback(hObject, eventdata, handles)
% hObject    handle to sigmabs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of sigmabs as text
%        str2double(get(hObject,'String')) returns contents of sigmabs as a double


% --- Executes during object creation, after setting all properties.
function sigmabs_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sigmabs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function sigmabr_Callback(hObject, eventdata, handles)
% hObject    handle to sigmabr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of sigmabr as text
%        str2double(get(hObject,'String')) returns contents of sigmabr as a double


% --- Executes during object creation, after setting all properties.
function sigmabr_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sigmabr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function gammab_Callback(hObject, eventdata, handles)
% hObject    handle to gammab (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of gammab as text
%        str2double(get(hObject,'String')) returns contents of gammab as a double


% --- Executes during object creation, after setting all properties.
function gammab_CreateFcn(hObject, eventdata, handles)
% hObject    handle to gammab (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function k_Callback(hObject, eventdata, handles)
% hObject    handle to k (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of k as text
%        str2double(get(hObject,'String')) returns contents of k as a double


% --- Executes during object creation, after setting all properties.
function k_CreateFcn(hObject, eventdata, handles)
% hObject    handle to k (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function alpha_Callback(hObject, eventdata, handles)
% hObject    handle to alpha (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of alpha as text
%        str2double(get(hObject,'String')) returns contents of alpha as a double


% --- Executes during object creation, after setting all properties.
function alpha_CreateFcn(hObject, eventdata, handles)
% hObject    handle to alpha (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in listboxmeter.
function listboxmeter_Callback(hObject, eventdata, handles)
% hObject    handle to listboxmeter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listboxmeter contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listboxmeter


% --- Executes during object creation, after setting all properties.
function listboxmeter_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listboxmeter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function fullfile_Callback(hObject, eventdata, handles)
% hObject    handle to fullfile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fullfile as text
%        str2double(get(hObject,'String')) returns contents of fullfile as a double


% --- Executes during object creation, after setting all properties.
function fullfile_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fullfile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in findimagebutton.
function findimagebutton_Callback(hObject, eventdata, handles)
% hObject    handle to findimagebutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


PicLoc = get(handles.PathText, 'String');

[File_Name, Path_Name] = uigetfile('*.*',PicLoc);

File = fullfile(Path_Name,File_Name);

set(handles.fullfile, 'String', File);



function fma_digit_Callback(hObject, eventdata, handles)
% hObject    handle to fma_digit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fma_digit as text
%        str2double(get(hObject,'String')) returns contents of fma_digit as a double


% --- Executes during object creation, after setting all properties.
function fma_digit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fma_digit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function fmi_digit_Callback(hObject, eventdata, handles)
% hObject    handle to fmi_digit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fmi_digit as text
%        str2double(get(hObject,'String')) returns contents of fmi_digit as a double


% --- Executes during object creation, after setting all properties.
function fmi_digit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fmi_digit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function f_mi_one_digit_Callback(hObject, eventdata, handles)
% hObject    handle to f_mi_one_digit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of f_mi_one_digit as text
%        str2double(get(hObject,'String')) returns contents of f_mi_one_digit as a double


% --- Executes during object creation, after setting all properties.
function f_mi_one_digit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to f_mi_one_digit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function tH_digit_Callback(hObject, eventdata, handles)
% hObject    handle to tH_digit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tH_digit as text
%        str2double(get(hObject,'String')) returns contents of tH_digit as a double


% --- Executes during object creation, after setting all properties.
function tH_digit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tH_digit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function th_digit_Callback(hObject, eventdata, handles)
% hObject    handle to th_digit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of th_digit as text
%        str2double(get(hObject,'String')) returns contents of th_digit as a double


% --- Executes during object creation, after setting all properties.
function th_digit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to th_digit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
