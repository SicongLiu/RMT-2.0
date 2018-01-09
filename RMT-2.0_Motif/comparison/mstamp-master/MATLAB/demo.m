%%
% Chin-Chia Michael Yeh
%
% C.-C. M. Yeh, N. Kavantzas, and E. Keogh, "Matrix Profile VI: Meaningful
% Multidimensional Motif Discovery," IEEE ICDM 2017.
% https://sites.google.com/view/mstamp/
% http://www.cs.ucr.edu/~eamonn/MatrixProfile.html
%

clear
clc

load('toy_data.mat');

%% compute the multidimensional matrix profile
% here we provided three variation of the mSTAMP algorithm
% The script will only run when only one of the alternatives is uncomment

%% alternative 1.a: the basic version
% 
data=csvread('D:\Motif_Results\Datasets\SynteticDataset\data\Mocap_test1.csv');
data=data';
sub_len=58;
% data = (data - mean(data)) ...
%                         / std(data, 1);
must_dim = [];
exc_dim = [];
[pro_mul, pro_idx] = ...
    mstamp(data, sub_len, must_dim, exc_dim);

%% alternative 1.b: the inclusion
% in the toy data, the first dimension only consist of random walk.
% Forcing the algorithm to consider the first dimension worsen the result.

% must_dim = [1];
% exc_dim = [];
% [pro_mul, pro_idx] = ...
%     mstamp(data, sub_len, must_dim, exc_dim);

%% alternative 1.c: the exclusion
% We can also do exclusion. By blacklist one of the dimension that contains
% meaningful motif, we no longer can find a meaningful 2-dimensional motif.
% However, the MDL-based unconstrained search method will correctly provide
% us the 1-dimensional motif

% must_dim = [];
% exc_dim = [3];
% [pro_mul, pro_idx] = ...
%     mstamp(data, sub_len, must_dim, exc_dim);
% pro_mul = pro_mul(:, 1:2);
% pro_idx = pro_idx(:, 1:2);
% data = data(:, 1:2);

%% alternative 2: using Parallel Computing Toolbox

% n_work = 4;
% [pro_mul, pro_idx] = ...
%     mstamp_par(data, sub_len, n_work);

%% alternative 3: using the anytime version stop at 10%
% the guided search is able to find the motif mostly
% however, the MDL-based method's output is less stable due to both method
% are approximated method

% pct_stop = 0.1;
% [pro_mul, pro_idx] = mstamp_any(data, sub_len, pct_stop);


%% guided search for 2-dimensional motif
% n_dim = 2; % we want the top 2-dimensional motif
% [motif_idx, motif_dim] = guide_serach(...
%     data, sub_len, pro_mul, pro_idx, n_dim);
% plot_motif_on_data(data, sub_len, motif_idx, motif_dim);


%% extract motif using the MDL-based unconstrained search method
n_bit = 4; % number of bit for discretization
k = inf;%2; % number of motif to retrieve
[motif_idx, motif_dim] = unconstrain_search(...
    data, sub_len, pro_mul, pro_idx, n_bit, k);
plot_motif_on_data(data, sub_len, motif_idx, motif_dim);


%% bag of motifs using MDL unconstrained search
MotifBag = search_Instances(data,motif_idx,motif_dim,sub_len,n_bit, k,pro_idx);
for i=1:size(MotifBag,2)
    plot_motif_on_data(data, sub_len, MotifBag{i}.idx, MotifBag{i}.depd);
end

for i=1:size(MotifBag,2)
    % apply matrix profile for the motif found
    [pro_mul, pro_idx] = ...
    mstamp(data, sub_len, must_dim, exc_dim);
    % scan in all the matrtix profile for the motif to find all the minimum till the end of the  timeseries 
end