function R = code_for_CSVT2019(I,m)
r = size(I,1);
c = size(I,2);
N = size(I,4);

W = ones(r,c,N);

%compute the measures and combines them into a weight map
contrast_parm = m(1);
sat_parm = m(2);
wexp_parm = m(3);

if (contrast_parm > 0)
    W = W.*contrast(I).^contrast_parm;
end
if (sat_parm > 0)
    W = W.*saturation(I).^sat_parm;
end
if (wexp_parm > 0)
    W = W.*well_exposedness(I).^wexp_parm;
end

%normalize weights: make sure that weights sum to one for each pixel
W = W + 1e-12; %avoids division by zero
W = W./repmat(sum(W,3),[1 1 N]);

for i = 1:N
    tmp =  I(:,:,1,i);
    W(:,:,i) = W(:,:,i)*(mean(tmp(:))^2);
end

W = W./repmat(sum(W,3),[1 1 N]);
% create empty pyramid  Y
pyr1 = gaussian_pyramid(zeros(r,c,1));%9
nlev = length(pyr1);  %10
pyr = gaussian_pyramid(zeros(r,c,1), nlev-2);%9

%multiresolution blending
for i = 1:N
    % construct pyramid from each input image
	pyrW = gaussian_pyramid(W(:,:,i),nlev-2);
	pyrI = laplacian_pyramid(I(:,:,1,i),nlev-2);
    % blend level 1:n-3
    for l = 1:nlev-3
        pyr{l} = pyr{l} + pyrW{l}.*pyrI{l};
    end
    %blend level level n-2
    sigma=1;
    window=double(uint8(1*1)*2+1);
    H=fspecial('gaussian', window, sigma);%fspecial('gaussian', hsize, sigma)
    w_low=imfilter(pyrW{nlev-2},H,'replicate'); 
    
    I2=laplacian_pyramid(pyrI{nlev-2},2);
    abs_abs = abs(I2{1});
    limit = abs_abs;
    
    if i<=ceil(N/2)-1
       % for under-exposed images
       limit(limit>0)=1;
       w_high = limit.*imfilter(abs_abs,H,'replicate');  
       final_W_nlev_2 = w_low + 1.5*w_high;
       pyr{nlev-2}=pyr{nlev-2}+(final_W_nlev_2).*pyrI{nlev-2};
    else
       % for over-exposed images
       final_W_nlev_2 = w_low;
       pyr{nlev-2}=pyr{nlev-2}+(final_W_nlev_2).*pyrI{nlev-2};   
    end
    
    if i == 1
        wsum_nlev_2 = final_W_nlev_2 +1e-12;
    else
        wsum_nlev_2 = wsum_nlev_2 + final_W_nlev_2 + 1e-12;
    end
end
pyr{nlev-2} = pyr{nlev-2}./wsum_nlev_2;
R(:,:,1) = reconstruct_laplacian_pyramid(pyr);


% blending for u/v channel
temp = nlev-2;
pyr = gaussian_pyramid(zeros(r,c,1),temp);
% multiresolution blending
for i = 1:N
    % construct pyramid from each input image
	pyrW = gaussian_pyramid(W(:,:,i),temp);
	pyrI = laplacian_pyramid(I(:,:,2,i),temp);
    % blend
    for l = 1:temp
        pyr{l} = pyr{l} + pyrW{l}.*pyrI{l};
    end
end

R(:,:,2) = reconstruct_laplacian_pyramid(pyr);

pyr = gaussian_pyramid(zeros(r,c,1),temp);
% nlev = length(pyr);

% multiresolution blending
for i = 1:N
    % construct pyramid from each input image
	pyrW = gaussian_pyramid(W(:,:,i),temp);
	pyrI = laplacian_pyramid(I(:,:,3,i),temp);
    % blend
    for l = 1:temp
        pyr{l} = pyr{l} + pyrW{l}.*pyrI{l};
    end
end

R(:,:,3) = reconstruct_laplacian_pyramid(pyr);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% contrast measure
function C = contrast(I)
h = [0 1 0; 1 -4 1; 0 1 0]; % laplacian filter
N = size(I,4);
C = zeros(size(I,1),size(I,2),N);
for i = 1:N
    C(:,:,i) = abs(imfilter(I(:,:,1,i),h,'replicate'));
end


% saturation measure
function C = saturation(I)
N = size(I,4);
C = zeros(size(I,1),size(I,2),N);
for i = 1:N
    % saturation is computed as the standard deviation of the color channels
    C(:,:,i) =abs(I(:,:,2,i))+abs(I(:,:,3,i))+1;
 
end

% well-exposedness measure
function C = well_exposedness(I)
sig = .2;
N = size(I,4);
C = zeros(size(I,1),size(I,2),N);
for i = 1:N
    C(:,:,i) = exp(-.5*(I(:,:,1,i)-0.5).^2/sig.^2);
end


