function [ SS,depd, IDMall] = gaussianss_Silv_fromorg(I,LocM,Ot,Od,St,Sd,ominT,ominD,sminT,sminD,smaxD,smaxT,sigmaT0,sigmaD0,DepThreshold,dsigmaT0,dsigmaD0)%

%I : timeseries column are variate rows are timedata,
%LocM: location matrix
% sigmaNT :  Nominal smoothing of the input timeseries across time
% sigmaND :  Nominal smoothing of the input timeseries Dependency
% Ot      :  Numeber of desired octave Time
% Od      :  Numeber of desired octave Dependency
% St      :  Number of maximum scale over Time
% Sd      :  Number of maximum scale over Dependency
% ominT   :  usually setted to 0 is the minimum octave of time
% ominD   :  usually fixed to 0 is the minimum octave for the dependency
% sminT   :  minimum  scale over time (it require to compute an offset is <0)
% sminD   :  minimum  scale over dependency (it require to compute an offset is <0)
% smaxD   :  minimum  scale over time usually >=3
% smaxT   :  minimum  scale over time usually >=3
% sigmaT0 : Smoothing of the level 0 of octave 0 of the scale space. (Note that Lowe's 1.6 value refers to the level -1 of octave 0.)
% sigmaD0 : Smoothing of the level 0 of the dependency
% dsigmaT0: step between the scale time if ==1 then the scale
% dsigmaD0: step between the scale dependency
% defineStepFactor: it is a flag to define a diferent step factor between different scales.

% Scale multiplicative step
ktime = 2^(1/St) ;
kdepd = 2^(1/Sd) ;

if sigmaT0 <0.5
    sigmaT0 = 1.6 * ktime ;
end

if sigmaD0 <=0
    sigmaD0 = 0.6 ;
end

if dsigmaT0 < 0
    dsigmaT0 = sigmaT0 * sqrt(1 - 1/ktime^2) ; % Scale step factor Time between each scale
end
if dsigmaD0 < 0
    dsigmaD0 = sigmaD0 * sqrt(1 - 1/kdepd^2) ; % Scale step factor Dependency between each scale
    %   dsigmaD0 = sigmaD0;
end

sigmaND =0.5;
sigmaNT =0.5;

% Scale space construction
% Save parameters
SS.Od          = Od;
SS.Ot          = Ot;
SS.St         = St;
SS.Sd         = Sd;

SS.sigmat     = sigmaT0;
SS.sigmad     = sigmaD0;
SS.odmin       = 0;
SS.otmin       = 0;
SS.sminT       = sminT ;
SS.smaxT       = smaxT ;
SS.sminD       = sminD ;
SS.smaxD       = smaxD ;
%% Starting from negative octave
% if otmin < 0
% 	for o=1:-omin
% 		I = doubleSize(I) ;
% 	end
% elseif otmin > 0
% 	for o=1:omin
% 		I = halveSize(I) ;
% 	end
% end

% starting octave
otcur = 1;
odcur = 1;

% Data size
[M, N] = size(I);

% Index offset
soT = -sminT+1 ;
soD = -sminD+1 ;

% For dependency matrix
IDM = (1:N)';
IDMall{odcur} = IDM;

DistM = computeDist(LocM, IDM, odcur);         %DistM: distance matrixLocM;%
%% Silv Normalization
maxim = max(DistM(:));
minim = min(DistM(:));
DistM= (DistM - minim) /abs(maxim-minim);

H = dependencyALL(DistM , DepThreshold, IDM, odcur);
depd{odcur} = H;
SS.ds{otcur, odcur} = [1, 1];

SS.octave{otcur, odcur} = zeros(M, N,smaxD,smaxT) ;
SS.smoothmatrix{otcur, odcur} = zeros(N, N, smaxD);

% From first octave
SDepdsigmafor_OT1_OD1 =sigmaD0; %sqrt((sigmaD0*kdepd^sminD)^2  - (sigmaND/2^ominD)^2);
Smatrix = ComputeDependencyScale(depd{odcur}, SDepdsigmafor_OT1_OD1); %% can be chaged to
%supposing that the  data are presmoothed with a sigmaNT over time we can
%do a smoothing as:
STimegsigmafor_OT1_OD1 = sqrt((sigmaT0*ktime^sminT)^2  - (sigmaNT/2^ominT)^2);

[SS.octave{otcur,odcur}(:,:,1,1),SS.smoothmatrix{otcur,odcur}(:,:,1,1)] = smooth(I, Smatrix, STimegsigmafor_OT1_OD1);

%% this will be more clear if  splitted in 2 with a smoothboth and a saving of the Smatrix we will save 1 function.
for otact=1: Ot
    if (otact-1)~=0
        SS.ds{otact, odact} = [SS.ds{otact-1, odact}(1)+1, SS.ds{otact-1, odact}(2)];
    end
    LocMTemp = LocM;
    for odact=1: Od
        fprintf('otact: %d, odact: %d\n', otact, odact);
        if((otact==1)&&(odact==1))
            SS = Smooth_Asyn_Xiaolan(SS, otact, odact, ktime, kdepd, sminT, sminD,smaxT, smaxD ,dsigmaT0,dsigmaD0,depd, Smatrix,soT,soD);
        elseif(otact == odact) %other octave combinations
            %determine the scale to pass for time octave.
            sbest_time = min(sminT + St, smaxT) ;
            sbest_Dep = min(sminD + Sd, smaxD) ;
            TMP=halveSizeTime(squeeze(SS.octave{otact-1,odact-1}(:,:,sbest_Dep+soD,sbest_time+soT)));
            target_sigmaT = sigmaT0 * ktime^sminT ;
            prev_sigmaT = sigmaT0 * ktime^(sbest_time - St) ;
            target_sigmaD = sigmaD0 * kdepd^sminD ;
            prev_sigmaD = sigmaD0 * kdepd^(sbest_Dep - Sd) ;
            if(target_sigmaD > prev_sigmaD)
                Smatrix=ComputeDependencyScale(depd{odcur},sqrt(target_sigmaD^2 - prev_sigmaD^2));
                TMP = smoothJustDependencySilv(TMP, sqrt(target_sigmaT^2 - prev_sigmaT^2),Smatrix ) ;
            end
            if(target_sigmaT > prev_sigmaT)
                TMP = smoothJustTimeSilv(TMP, sqrt(target_sigmaT^2 - prev_sigmaT^2),Smatrix ) ;
            end
            [SS.octave{otact,odact}(:,:,1,1), LocMTemp, IDM] = HalfDependencyMote(LocMTemp, squeeze(TMP));
            DistM = computeDist(LocMTemp, IDM, odcur);
            %% Silv Normalization
            maxim = max(DistM(:));
            minim = min(DistM(:));
            DistM= (DistM - minim) /abs(maxim-minim);
            %% Silv Normalization
            DepThreshold = DepThreshold*1.1;
            H = dependencyALL(DistM , DepThreshold, IDM, odcur);
        end
        if(odact~=1 && size(depd,2)<odact)
            IDMall{odact} = IDM;
            depd{odact} = H;
        end
        SS.smoothmatrix{otact, odact} = zeros(size(SS.octave{otact, odact},2),size(SS.octave{otact, odact},2),size(SS.octave{otact, odact},3));
        SS = Smooth_Asyn_Xiaolan(SS, otact, odact, ktime, kdepd, sminT, sminD,smaxT, smaxD ,dsigmaT0,      dsigmaD0,        depd, Smatrix,soT,soD);
        %SS = Smooth_Asyn(SS, otact, odact, ktime, kdepd, stmax, sdmax,dsigmaT0,dsigmaD0,depd, Smatrix,soT,soD);
        
    end
    if odact ~= 1
        SS.ds{otact, odact} = [SS.ds{otact, odact-1}(1), SS.ds{otact, odact-1}(2)+1];
    end
    odact=1;
end

    function [SS] = Smooth_Asyn_Xiaolan(SS, CurrentTimeOct, CurrentDepdOct, ktime, kdepd,stmin,sdmin, stmax, sdmax,sigmaTscaleStep,sigmaDscaleStep,depd, Smatrix,soT,soD)
        for sd = sdmin : sdmax
            st = sd;
            dsigmaD = kdepd^(sd) * sigmaDscaleStep ;%kdepd^(sd+1) * sigmaDscaleStep ;
            dsigmaT =  ktime^(st) * sigmaTscaleStep ;%ktime^(st+1) * sigmaTscaleStep ;
            
            Smatrix = ComputeDependencyScale(depd{CurrentDepdOct}, dsigmaD);
            [SS.octave{CurrentTimeOct,CurrentDepdOct}(:,:,sd+soD,st+soT)] = smoothBothSilv(squeeze(SS.octave{CurrentTimeOct,CurrentDepdOct}(:,:,sd+soD-1, st+soT-1)),dsigmaT,Smatrix);
        end
    end

% Sicong Function
    function H = dependencyALL(Mat, t, IDM, odcur)
        % function of generating dependency matrix.
        %  -M is the distance matrix of 53 sensors
        %  -t is the threshold for the selected scale
        %  -H will be a 0-1 sparse matrix containning neighborhood information
        Numberof = size(Mat,1);
        H = zeros([Numberof Numberof]);
        for i = 1:Numberof
            for j = 1:Numberof
                if(Mat(i,j)<=t)
                    H(i,j) = 1;
                end
            end
        end
        H = H - eye([Numberof Numberof]);
    end

    function DistM = computeDist(LocM, IDM, odcur)
        Num = size(LocM,1);
        DistM = zeros(Num, Num);
        for i=1:Num
            for j=1:Num
                DistM(i,j) = norm(LocM(i,:)-LocM(j,:),2);
            end
        end
    end

    function J = doubleSizeTime(I)
        [M,N]=size(I) ;
        J = zeros(2*M,N) ;
        J(1:2:end,:) = I ;
        J(2:2:end-1,:) = ...
            0.25*I(1:end-1,:) + ...
            0.25*I(2:end,:) + ...
            0.25*I(1:end-1,:) + ...
            0.25*I(2:end,:) ;
        J(2:2:end-1,:) = ...
            0.5*I(1:end-1,:) + ...
            0.5*I(2:end,:) ;
        J(1:2:end,:) = ...
            0.5*I(:,1:end-1) + ...
            0.5*I(:,2:end) ;
    end
end
