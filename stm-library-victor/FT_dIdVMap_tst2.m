% FT_dIdVMap_vic(n)
% Fourier Transform the dIdVMap for file mn_ori, 
% adds smooth and subtraction
% p=1 for forward and 0 for backward

function FT_dIdVMap_vic(n,p)

%ftopo=strcat('m',num2str(n),'_ori.tf0');
fdidv=strcat('m',num2str(n),'_ori.tf1');
%btopo=strcat('m',num2str(n),'_ori.tb0');
bdidv=strcat('m',num2str(n),'_ori.tb1');

if p==1
    [x, y, zs2] = scala_read(fdidv,1);
else 
    [x, y, zs2] = scala_read(bdidv,1);
end
% [x1, y1, zs1] = scala_read(fdidv,1);
% zs = zs1(70:139,70:139);
% x = x1(1:70);
% y = y1(1:70);

%Hijack data with wave thing
[XX,YY] = meshgrid(-74.5:74.5 , -74.5:74.5);
Zd=XX.^2+YY.^2;
Zd=sqrt(Zd);
ah=sqrt(2*(max(size(Zd)))^2)
ZZd=0.5*(1+cos((30*2*pi*Zd)./ah));

%[XX,YY] = meshgrid(-49.5:99.5 , -74.5:74.5);
%Zd=XX.^2+YY.^2;
%Zd=sqrt(Zd);
%ah=sqrt(2*(max(size(Zd)))^2)
%ZZZd=0.5*(1+cos((15*2*pi*Zd)./ah));

%[XX,YY] = meshgrid(-49.5:99.5 , 0:149);
%Zd=XX.^2+YY.^2;
%Zd=sqrt(Zd);
%ah=sqrt(2*(max(size(Zd)))^2)
%ZZZZd=0.5*(1+cos((15*2*pi*Zd)./ah));

%[XX,YY] = meshgrid(-5:144 , -84.5:64.5);
%Zd=XX.^2+YY.^2;
%Zd=sqrt(Zd);
%ah=sqrt(2*(max(size(Zd)))^2)
%aZZd=0.5*(1+cos((15*2*pi*Zd)./ah));

%[XX,YY] = meshgrid(-139:10 , -74.5:74.5);
%Zd=XX.^2+YY.^2;
%Zd=sqrt(Zd);
%ah=sqrt(2*(max(size(Zd)))^2)
%aZZZd=0.5*(1+cos((15*2*pi*Zd)./ah));

%[XX,YY] = meshgrid(-119:30 , -30:119);
%Zd=XX.^2+YY.^2;
%Zd=sqrt(Zd);
%ah=sqrt(2*(max(size(Zd)))^2)
%aZZZZd=0.5*(1+cos((15*2*pi*Zd)./ah));

%ZZZZZd=7*rand(150,150);

ack=zeros(150,150);
ack(30:32,62:69)=10;
ack(123:126,10:12)=-10;
ack(50:52,42:49)=10;
ack(113:117,21:27)=-10;
ack(60:62,62:69)=10;
ack(123:126,120:126)=-10;
ack(30:32,15:19)=10;
ack(83:91,51:58)=-10;
ack(35:37,102:106)=10;

%zs2=ZZd + ZZZd + ZZZZd + aZZd + aZZZd + aZZZZd + ack;

%zs2 = ZZd + ack;

[nxa, nya] = size(zs2);
sze=floor(nxa/10)

%subtract background
H = fspecial('gaussian', sze, sze);
zs3 = imfilter(zs2,H,'replicate');
zs4 = zs2 - zs3;
zs1 = zs4 - mean2(zs4);

%zs1 = zs2 - mean2(zs2);

%zs1=zeros(180,180)+1;

%Begin system for cutting out bad points, replacing with zeros, and
%smoothing

std_zs1 = std2(zs1);
big_zs1 = zs1 > (3*std_zs1);
little_zs1 = zs1 < (-3*std_zs1);
big_zs1 = big_zs1*(-1);
little_zs1 = little_zs1*(-1);

cut1 = zs1.*big_zs1;
cut2 = zs1.*little_zs1;
zs1 = zs1 + cut1;
zs1 = zs1 + cut2;

zs1=zs1-mean2(zs1);
%zs1 = smooth2(zs1,5,5);

%End system for cutting out

%figure
%pcolor(x,y,zs1);
%axis square
%shading interp

%figure
%pcolor(diff(diff(zs1,1,1),1,2));
%axis square
%shading interp

%original setting nxa/3
hszea=floor(nxa/3)

% number of windows
%original setting nxa/30

szen=round(nxa/30)

hsze=(hszea-1)/2
nhsze=hsze*(-1)

%"Hann" window for fft2
[X,Y] = meshgrid(nhsze:hsze , nhsze:hsze);
Z=X.^2+Y.^2;
Z=sqrt(Z);
ah=sqrt(2*(max(size(Z)))^2)
ZZ=0.5*(1+cos((2*pi*Z)./ah));

% zs1 = xcorr2(zs1);
% NOTE: using the cross-correlation doesn't seem to add much
% pcolor(x, y, zs);
% shading interp
% colormap pink
% colorbar

% pad zeros around the dI/dV map (a trick to make better ft)
np = 2;
[nx1, ny1] = size(zs1);
%I don't understand the point of padding zeros here when you pad them
%automatically in the fft2 command when you define fft_zs
%I'm not taking this out, but we don't use zs for the rest of the program
% -Victor
zs = zeros(nx1*(2*np+1), ny1*(2*np+1));
zs((np*nx1+1):((np+1)*nx1),(np*ny1+1):((np+1)*ny1)) = zs1;

% do the ft
[nx, ny] = size(zs); % size of signal
dx = max(x)/nx1;  % sampling length x
dy = max(y)/ny1;  % sampling length y
fx = 1/dx;       % sampling frequency x
fy = 1/dy;       % sampling frequency y

NFFT_x = 2^nextpow2(nx);
NFFT_y = 2^nextpow2(ny);

%Original
fft_zs = zeros(NFFT_x, NFFT_y);

%Revised
%fft_zs = zeros(150,150);

%[A,B]=meshgrid(1:50,0:50:100);
%GRD=A+B;
G=floor(linspace(0,nx1-hszea,szen))
for i=1:szen
    for j=1:szen
        %zstmp=zs1((1:150),(1:150));
        zstmp=zs1((1:hszea)+G(i),(1:hszea)+G(j));
        %aaa=size(zstmp,1);
        %zstmp=[diff([diff(zstmp,1,1);zeros(1,size(zstmp,2))],1,2),zeros(size(zstmp,1),1)];
        %zstmp = diff(diff(zstmp,1,1),1,2);
        zstmp=zstmp-mean2(zstmp);
        %zstmp= cumsum(cumsum(zstmp,1),2);
        
        zstmp=zstmp.*ZZ; %hann window function
        
        fft_zstmp = abs(fftshift(fft2(zstmp, NFFT_x, NFFT_y)))/(nx*ny) ; % fft of zs
        %fft_zstmp = abs(fftshift(fft2(zstmp)));
        fft_zs = fft_zs + fft_zstmp;
    end
end

%fft_zs = fft_zs;
fft_zs = fft_zs./(szen*szen);        

%fft_zs = abs(fftshift(fft2(zs1(1:50,1:50), NFFT_x, NFFT_y)))/(nx*ny) ; % fft of zs
%fft_zs = abs(fftshift(fft2(zs)))/(nx*ny) ; %try it without padding zeros
kx = fx*2*pi*linspace(0,1,NFFT_x);                         % this gives the real k  
ky = fy*2*pi*linspace(0,1,NFFT_y);                  % this gives the real k

%kx = fx*2*pi*linspace(0,1,150);                         %Revised 
%ky = fy*2*pi*linspace(0,1,150); 

% plot the 2D amplitude spectrum
%figure
%pcolor(kx, ky, fft_zs(1:NFFT_x, 1:NFFT_y));
%shading interp
%hold off

%figure
%pcolor(kx, ky, fft_zs(1:150, 1:150));
%shading interp
%hold off

% do the radio average (copied from function RadAveFT_yuanbo()
[nftx, nfty] = size(fft_zs);

% Setup the k axis
kn = 150;
kx_Max = max(kx); ky_Max = max(ky);
k_Max = sqrt(kx_Max^2 + ky_Max^2)/(2*np+1)
k_Step = k_Max/kn;
FT_P = zeros(kn,3);
for j=1:kn,
    FT_P(j,1) = k_Step*(j-0.5);
end


% Find total values of FT for each of the k
% kind of like making a histogram s
center_kx = (kx(nftx) + kx(1))/2;
center_ky = (ky(nfty) + ky(1))/2;
for i=1:nftx,
    for j=1:nfty,
        k = sqrt((kx(i)-center_kx)^2 + (ky(j)-center_ky)^2);
        ind = int32(k/k_Step);
        if ind <= kn
            if ind == 0
                FT_P(1,2) = FT_P(1,2) + fft_zs(i,j);
                FT_P(1,3) = FT_P(1,3) + 1;
            else
                FT_P(ind,2) = FT_P(ind,2) + fft_zs(i,j);
                FT_P(ind,3) = FT_P(ind,3) + 1;
            end
        end
    end
end

% Take the average of each 'bin' to get FT value
for j=1:kn,
    if FT_P(j,3) > 0
        FT_P(j,2) = FT_P(j,2)/FT_P(j,3);
    end
end

% % Output the matrxi as figure and data file
figure
plot(FT_P(:,1),FT_P(:,2));

FT_Out = FT_P(:,1:2);
save (strcat('cm',num2str(n),'_',num2str(p),'_FT_AVG.dat'), 'FT_Out', '-ASCII')