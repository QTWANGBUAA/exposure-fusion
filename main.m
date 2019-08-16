
%%%
%this code is for paper: Qiantong. Wang, Weihai. Chen, Xingming. Wu, and Zhengguo. Li, "Detail-enhanced Multi-scale Exposure Fusion in YUV Color Space," 
%IEEE Transactions on Circuits and Systems for Video Technology. doi: 10.1109/TCSVT.2019.2919310
%part of this code is based on this code
%https://github.com/Mericam/exposure-fusion which is Implementation of Exposure Fusion in Matlab, as described in:
%"Exposure Fusion", Tom Mertens, Jan Kautz and Frank Van Reeth In proceedings of Pacific Graphics 2007
%
%%%


%src_img data_dir;
%---test_image
%-------LDRset1
%-------LDRset2
%          .
%          .
%-------LDRsetn
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear;
path = 'your_data_root_dir/test_image/';
files = dir(path);

length_file = length(files);
a = files.name;
for i = 3:length_file
    fprintf('current set is %f\n',i/10*10);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
temp_path = [path,files(i).name];

II = load_images(temp_path);
%%%resort
[h,w,c,n]= size(II);
for ii = 1:n
    meann(ii) = mean(mean(mean(II(:,:,:,ii))));
end
[mean2, index] = sort(meann);

for jj=1:n
    I(:,:,:,jj) = II(:,:,:,index(jj));
end

dst(:,:,1,:) = 0.299*I(:,:,1,:) + 0.587*I(:,:,2,:) + 0.114*I(:,:,3,:);
dst(:,:,2,:) = -0.147*I(:,:,1,:) - 0.289*I(:,:,2,:) + 0.436*I(:,:,3,:);
dst(:,:,3,:) = 0.615*I(:,:,1,:) - 0.515*I(:,:,2,:)- 0.100*I(:,:,3,:);
[height,width,channel]=size(I(:,:,:,1));
clear temp;

tic
R=code_for_CSVT20191(dst,[1 1 1]);
runtime = toc;
FR(:,:,1)= R(:,:,1) + 1.14*R(:,:,3);  
FR(:,:,2)= R(:,:,1) - 0.39*R(:,:,2) - 0.58*R(:,:,3);   
FR(:,:,3)= R(:,:,1) + 2.03*R(:,:,2);

fprintf('the running time is %f\n', runtime);
imshow(FR);
% write_path_root = 'your_save_dir/code_test/';
% write_path = [write_path_root,files(i).name,'.png'];
% 
% imwrite(FR,write_path);
clear height;
clear width;
clear I;
clear dst;
clear FR;
clear R;
clear II;
clear n;
clear index;
clear meann;
end