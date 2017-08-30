function sd = siftdescriptor(smoothedScale,frame,sigmaT0,sigmaD0,St,Sd,minSt,minSd, magnif,NBP_Time,NBP_Depd, NBO) 
% smoothedScale: smoothed scale of the specific image in the octave(downsampled) in the specific scale time and dependency
% frame:  Frame(1,1)= Dependency variate the feature in the octave representation
%         Frame(2,1)= Time index of the feature in the octave representation
%         Frame(3,1)= Scale Dependency of the feature
%         Frame(4,1)= Scale Time of the feature
%         Frame(5,1)= eventual orientation otherwise 0
% sigmaT0: the original sigma used to smooth over Time
% sigmaD0: the original sigma used to smooth over Dependency
% St: maximum scale over Time
% Sd: maximum scale over Dependency
% minSt: minimum scale over Time 
% minSd: minimum scale over Dependency 
% magnif: Spatial bin extension factor. usually 3.0 from Lowe
% NBP_Time: number of bin for Time To build a grid
% NBP_Depd: number of bin for Dependency to build a grid
% NBO: Number of Bin for orientation (8 is used in Lowe) 


  magnif = 3.0;  %/* Spatial bin extension factor. */
  NBP_Time = 4 ;      %/* Number of bins for one spatial direction (even). */
  NBP_Depd = 4;
  NBO = 8 ;      %/* Number of bins for the ortientation. */
  mode = 'NOSCALESPACE' ; % We pass just thte specific scale space of the feature
  loweCompatible =0; % loweCompatible=0 then no Lowe compatible
                     % loweCompatible=1 then Lowe compatible 
  M = size(smoothedScale,1);
  N= size(smoothedScale,2);
  num_levels=1;
  featureInfo= size(frame,1); %K in the original code++
  
 %%    Compute the gradient 
%DERIVATE  ACROSS X DIMENTION 
Dx = 0.5 *(smoothedScale(2:end,:)-smoothedScale(1:end-1,:));
%DERIVATE  ACROSS Y DIMENTION 
Dy =0.5 * (smoothedScale(:,2:end)-smoothedScale(:,1:end-1));
% Dx1=[];
% Dy1=[];
%       for x = 2 : N-1 % // FOR  EACH ROW 
%         for y = 1: M  % // FOR EACH COLUMN
%           %DERIVATE  ACROSS X DIMENTION 
%            Dx(x,y) = 0.5 * ( smoothedScale(x+1,y) - smoothedScale(x-1,y) ) ; %//DERIVATE  ACROSS X DIMENTION 
%            Dy(x,y) = 0.5 * ( smoothedScale(x,y+1) - smoothedScale(x,y-1) ) ; %// DERIVATE ACROSS Y DIMENTION
%         end
%       end
 
 %% /* Compute angles and modules of all the points in the scale*/ 
Gradient_Scale=  sqrt(Dx*Dx + Dy*Dy) ;% //GRADIENT OF THE POINT
Angles= atan2(Dy, Dx) ; %// ANGLE OF THE 1ST DERIVATE ACROSS x AND y

%% Create descriptor forthe feature i
%         The SIFT descriptor is a  three dimensional histogram of the position
%         and orientation of the gradient.  There are NBP bins for each spatial
%         dimesions and NBO  bins for the orientation dimesion,  for a total of
%         NBP x NBP x NBO bins.
%        
%         The support  of each  spatial bin  has an extension  of SBP  = 3sigma
%         pixels, where sigma is the scale  of the keypoint.  Thus all the bins
%         together have a  support SBP x NBP pixels wide  . Since weighting and
%         interpolation of  pixel is used, another  half bin is  needed at both
%         ends of  the extension. Therefore, we  need a square window  of SBP x
%         (NBP + 1) pixels. Finally, since the patch can be arbitrarly rotated,
%         we need to consider  a window 2W += sqrt(2) x SBP  x (NBP + 1) pixels
%         wide.
%        
       
%     const int binto = 1 ;
%     const int binyo = NBO * NBP ; 
%     const int binxo = NBO ;
%     const int bino  = NBO * NBP * NBP ;
     binto = 1 ;
     binyo = NBO * NBP_Time ; 
     binxo = NBO ;
     bino  = NBP_Depd * NBP_Time * NBP ;

%      for(p = 0 ; p < K ; ++p, descr_pt += bino) {
%      for p=1:K % this should be the numebr of features hen in our case K=1 

      %const float x = (float) *P_pt++ ; % x is the variate (oframe(1,1))
      %const float y = (float) *P_pt++ ; % y is the time (oframe(2,1))
      % if mode == scalespace then read the  3rd element  else  S=0 in our
      % case we pass just the interested scale then it is (0 in C => 1 in matlab)
      %const float s = (float) (mode == SCALESPACE) ? (*P_pt++) : 0.0 ;
       x = frame(1,1);
       y = frame(2,1);
       st = frame(3,1);
       sd = frame(4,1);
%        If we compute the feature orientation  then  read the orientation
%        else  give 0 to the orientation this have to be performed in the
%        input to pass to the function
%        const float theta0 = (float) *P_pt++ ; // BEGINNING ORIENTATION
%        const float st0 = sinf(theta0) ; 
%        const float ct0 = cosf(theta0) ;
       theta0=frame(5,1);
       st0 = sin(theta0); 
       ct0 = cos(theta0);
       %% roundoff of the point to center it in variate time and scale
%        const int xi = (int) floor(x+0.5) ; /* Round-off */
%        const int yi = (int) floor(y+0.5) ;
%        const int si = (int) floor(s+0.5) - smin ;
       xi= floor(0.5+x);
       yi= floor(0.5+y);
       si=s; % wepass just one scale because we pass just one feature
       % comute the sigma for the scale where we identified the feature       
       %const float sigma = sigma0 * powf(2, s / S) ;
       sigma_Time = sigmaT0 * (2^ st0 /St) ;
       sigma_Depd = sigmad0 * (2^ sd0 /Sd) ;
       
       %const float SBP = magnif * sigma ; // IN GENERAL 3*SIGMA
       SBP_Time = magnif * sigma_Time;
       SBP_Depd = magnif * sigma_Depd;
       % window to compute each  gradient
       %const int W = (int) floor( sqrt(2.0) * SBP * (NBP + 1) / 2.0 + 0.5) ;    // SQUARE WINDOW  
       W_Time = floor(0.5 + ((sqrt(2)*SBP_Time*(NBP_Time))/2));
       W_Depd = floor(0.5 + ((sqrt(2)*SBP_Depd*(NBP_Depd))/2));

       %        /* Check that keypoints are within bounds . */
%        if(xi < 0   |  xi > N-1 |...
%          yi < 0    |  yi > M-1 |...
%          ((mode==SCALESPACE) & 
%           (si < 0  | si > dimensions[2]-1) ) )
%         continue ;

%       /* Center the scale space and the descriptor on the current keypoint. 
%        * Note that dpt is pointing to the bin of center (SBP/2,SBP/2,0).
%        */
%       pt  = buffer_pt + xi*xo + yi*yo + si*so ;
%       dpt = descr_pt + (NBP/2) * binyo + (NBP/2) * binxo ;
%%
%       /*
%        * Process each pixel in the window and in the (1,1)-(M-1,N-1)
%        * rectangle.
%        */

%  for(dxi = max(-W, 1-xi) ; dxi <= min(+W, N-2-xi) ; ++dxi) {
%         for(dyi = max(-W, 1-yi) ; dyi <= min(+W, M-2-yi) ; ++dyi) {
%           /* Compute the gradient. */
%           float mod   = *(pt + dxi*xo + dyi*yo + 0           ) ; //MODULO  DEL PUNTO NELLA SCALA
%           float angle = *(pt + dxi*xo + dyi*yo + buffer_size ) ; // ANGOLO DEL PUNTO NELLA SCALA
% 2 is because  in matlab westart from 1 
        for dxi = max(-W_Depd,1-xi): min(+W_Depd, N-2-xi) % VARIATE to do the preincrement we can start  with a +1
            for dyi = max(-W_Time,1-yi): min(+W_Time, M-2-yi) %TIME
                mod = Gradient_Scale(yi+dyi,xi+dxi);
                angle=Angles(yi+dyi,xi+dxi);
                
                theta = normalizeTheta(angle - theta0);
                if(loweCompatible==1)
%                     float theta = fast_mod(-angle + theta0) ;// FUNCTION FASTMOD MOVE THE ANGLE IN THE INTERVAL 0-2PI GRECO
                     theta = normalizeTheta(-angle + theta0);
                end
%                 /* Get the fractional displacement. */
%           float dx = ((float)(xi+dxi)) - x;
%           float dy = ((float)(yi+dyi)) - y;
                dx= xi+dxi - x;
                dy= yi+dyi - y;
%           /* Get the displacement normalized w.r.t. the keypoint orientation  and extension. */
%           float nx = ( ct0 * dx + st0 * dy) / SBP ;
%           float ny = (-st0 * dx + ct0 * dy) / SBP ; 
%           float nt = NBO * theta / (2*M_PI) ;  
            nx = ( ct0 * dx + st0 * dy) / SBP_Depd; % modul against dependency
            ny = (-st0 * dx + ct0 * dy) / SBP_Time ; %modul against  time  
            nt = NBO * theta / (2*pi) ; % angle in radiant
%           /* Get the gaussian weight of the sample. The gaussian window
%            * has a standard deviation of NBP/2. Note that dx and dy are in
%            * the normalized frame, so that -NBP/2 <= dx <= NBP/2. */
%           const float wsigma = NBP/2 ;
%           float win =  expf(-(nx*nx + ny*ny)/(2.0 * wsigma * wsigma)) ;
            wsigma_Time = NBP_Time /2;  
            wsigma_Depd = NBP_Depd /2;
%             win =  expf(-(nx*nx + ny*ny)/(2.0 * wsigma_Time * wsigma_Depd)) ;
%            win =  expf(-(nx*nx + ny*ny)/(2.0 * wsigma_Time * wsigma_Time)) * expf(-(nx*nx + ny*ny)/(2.0 * wsigma_Depd * wsigma_Depd)) ;
            win_Time = exp( - (nx*nx + ny*ny) / (2*wsigma_Time * wsigma_Time));
            win_Depd = exp( - (nx*nx + ny*ny) / (2*wsigma_Depd * wsigma_Depd));
            
            %win = sqrt(win_Time^2 + win_Depd^2)/sqrt(2);
            win = sqrt(win_Time*win_Depd);
            
%             /* The sample will be distributed in 8 adijacient bins. 
%            * Now we get the ``lower-left'' bin. */
%           int binx = fast_floor( nx - 0.5 ) ;
%           int biny = fast_floor( ny - 0.5 ) ;      
%           int bint = fast_floor( nt ) ;
%           float rbinx = nx - (binx+0.5) ;
%           float rbiny = ny - (biny+0.5) ;
%           float rbint = nt - bint ;
              binx = floor( nx - 0.5 );
              biny = floor( ny - 0.5 );
              bint = floor(nt);
              rbinx = nx - (binx+0.5) ;
              rbiny = ny - (biny+0.5) ;
              rbint = nt - bint ;
              
%%               /* Distribute the current sample into the 8 adijacient bins. */
%             for(dbinx = 0 ; dbinx < 2 ; ++dbinx) {
%                 for(dbiny = 0 ; dbiny < 2 ; ++dbiny) {
%                     for(dbint = 0 ; dbint < 2 ; ++dbint) {
                for dbinx =1:2
                    for dbiny =1:2
                        for dbint =1:2
                           if( binx+dbinx >= -(NBP/2) &...
                              binx+dbinx  <   (NBP/2) &...
                              biny+dbiny  >= -(NBP/2) &...
                              biny+dbiny  <   (NBP/2) )
%                           float weight = win 
%                                         * mod 
%                                         * fabsf(1 - dbinx - rbinx)
%                                         * fabsf(1 - dbiny - rbiny)
%                                         * fabsf(1 - dbint - rbint) ;
                            float weight = win... 
                                           * mod... 
                                           * abs(1 - dbinx - rbinx)...
                                           * abs(1 - dbiny - rbiny)...
                                           * abs(1 - dbint - rbint) ;
                           end
                        end
                    end
                end
            end
        end
            
end