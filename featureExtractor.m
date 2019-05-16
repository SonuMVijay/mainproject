function [F,labels] = featureExtractor(my_dir,name)
fprintf('\n\n\n\t\t%s\n\n',upper(name));
Bt = 20;
Nc = 9;
folderInfo =dir(my_dir);
folderInfo(1:2) = [];
num_images = length(folderInfo);
labels = repmat(name, num_images, 1);
labels = mat2cell(labels, ones(size(labels, 1), 1), size(labels, 2));
disp(['Total: ',num2str(num_images),' images.'])
F = [];
for i = 1:num_images
    %     pause(delayTime)
    if mod(i,50) == 0
        disp(['Processing image',num2str(i),' ...'])
    end
    myfile = folderInfo(i).name;
    myfile_abs = fullfile(my_dir,myfile);
    
    img = imread(myfile_abs);
    a=imresize(img,[512,384]);
    img = rgb2gray(img);
    I = im2double(img);
    
    
    T = dctmtx(8);
    dct = @(block_struct) T * block_struct.data * T';
%     disp(block_struct)
    B = blockproc(I,[8 8],dct);
    size(B)
%     BB = imquantize(B,.05);
    q_mtx = floor([9,6,6,9,14,23,30,35;7,7,8,11,15,34,35,32;
        8,8,9,14,23,33,40,32;8,10,13,17,30,50,46,36;
        10,13,21,32,39,63,60,45;14,20,32,37,47,60,66,53;28,37,45,50,60,70,70,59;
        42,53,55,57,65,58,60,57]*.2);
    % q_mtx =  [16 11 10 16 24 40 51 61;
    %             12 12 14 19 26 58 60 55;
    %             14 13 16 24 40 57 69 56;
    %             14 17 22 29 51 87 80 62;
    %             18 22 37 56 68 109 103 77;
    %             24 35 55 64 81 104 113 92;
    %             49 64 78 87 103 121 120 101;
    %             72 92 95 98 112 100 103 99];
    c = @(block_struct)(block_struct.data) ./ q_mtx;
    %imshow(img);
    B2 = blockproc(B,[8 8],c);
    
    B2 = round(B2);
    
    B3 = blockproc(B2,[8 8],@(block_struct) q_mtx .* block_struct.data);
    
    invdct = @(block_struct) round(T' * block_struct.data * T);
    
    I2 = blockproc(B3,[8 8],invdct);
    Y = I2;
    modeLocations = [1,2;1,3;1,4;2,1;2,2; 2,3;3,1;3,2;4,1];  % location of DCT coefficients
    
    for modeIndex = 1:Nc%size(modeLocations, 1)
        
        modeLocation = modeLocations(modeIndex, :); % loading first location
        
        %             
        %             Yq = I.coef_arrays{1};
        %             Mq = I.quant_tables{1}
        % %             size(Yq)
        % %             size(Mq)
        % %             pause
        %             Y = dequantize( Yq, Mq );
        
        [height, width] = size(Y);
        mask = zeros(8);
        mask(modeLocation(1), modeLocation(2)) = 1;
        mask = repmat(mask, height / 8, width / 8);
        coeffs = Y(logical(mask));
        
        Histogram = hist(coeffs, -Bt:1:Bt);
        
        Histograms(modeIndex, :) = Histogram / sum(Histogram);
        
    end
    
    features = reshape(Histograms', 1, []);
    F = cat(1,F,features);
    %     montage({img,I2});
end
end