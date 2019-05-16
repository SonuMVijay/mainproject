%%Initialisation
clc;
clearvars;
close all;

tic;

load('RF_model.mat')
load('labels.mat')
my_path = '/home/user/Desktop/Sonu_new/Testdata/realtime2';
Bt = 20;
Nc = 9;

[fn,pn] = uigetfile(my_path,...
    'Select the image');

fileName = fullfile(pn,fn);
img = imread(fileName);
img = rgb2gray(img);
I = im2double(img);
I=imresize(I,[384,512]);
T = dctmtx(8);
dct = @(block_struct) T * block_struct.data * T';
B = blockproc(I,[8 8],dct);
%     BB = imquantize(B,.05);
q_mtx = floor([
    9,6,6,9,14,23,30,35;
    7,7,8,11,15,34,35,32;
    8,8,9,14,23,33,40,32;
    8,10,13,17,30,50,46,36;
    10,13,21,32,39,63,60,45;
    14,20,32,37,47,60,66,53;
    28,37,45,50,60,70,70,59;
    42,53,55,57,65,58,60,57
    ]*.2);

c = @(block_struct)(block_struct.data) ./ q_mtx;
%imshow(img);
B2 = blockproc(B,[8 8],c);

B2 = round(B2);

B3 = blockproc(B2,[8 8],@(block_struct) q_mtx .* block_struct.data);

invdct = @(block_struct) round(T' * block_struct.data * T);

I2 = blockproc(B3,[8 8],invdct);
Y = I2;
modeLocations = [
    1,2;
    1,3;
    1,4;
    2,1;
    2,2;
    2,3;
    3,1;
    3,2;
    4,1 ];  % location of DCT coefficients

for modeIndex = 1:Nc%size(modeLocations, 1)
    
    modeLocation = modeLocations(modeIndex, :); % loading first location
    [height, width] = size(Y);
    mask = zeros(8);
    mask(modeLocation(1), modeLocation(2)) = 1;
    mask = repmat(mask, height / 8, width / 8);
    coeffs = Y(logical(mask));
    
    Histogram = hist(coeffs, -Bt:1:Bt);
    
    Histograms(modeIndex, :) = Histogram / sum(Histogram);
    
end

features = reshape(Histograms', 1, []);

% vals = find(features);
feat = features(:,vals);    % removing zeroes

lbl = predict(Mdl,feat);
disp(upper(lbl))
msgbox(upper(lbl),'Prediction:')
accuracyfb = sum(predict(Mdl,feat) == "facebook")/length(label_facebook)*1000;
disp('Accuracy:');
disp(accuracyfb);
