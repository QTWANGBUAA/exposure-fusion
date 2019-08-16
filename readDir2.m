% Creates a list of all pictures and their exposure values in a certain directory.
%
% Note that the directory must only contain images which are named according to the
% naming conventions, otherwise this function fails.
% 
% Filename naming conventions:
% The filename of a picture must contain two numbers specifying the
% exposure time of that picture. The first number specifies the numerator,
% the second one the denominator. E.g. "image_1_15.jpg" specifies that this
% image has been taken with an exposure of 1/15 second.
function [filenames, numExposures] = readDir2(dirName)

    filelist = dir(dirName);
    for i = 3:size(filelist,1)
        filenames{i-2} = strcat(dirName,filelist(i).name);
    end

    numExposures = size(filenames,2);
    
    fprintf('numExposures = %d\n', numExposures);
    
    intensity_array = zeros(numExposures,1);
    for k =1:numExposures
        
        img_temp = double(imread(filenames{k}));
        
        intensity_sum = sum(sum(sum(img_temp)));
        intensity_array(k) = intensity_sum;
        
    end

    % sort ascending by exposure
    [intensity_array indices] = sort(intensity_array);
    filenames = filenames(indices);






