% show_DiracMap(fn)
% fn = filename
% This function calculates the Dirac point energy 
% for each point on a spectra grid, and outputs a
% Dirac point map

function show_DiracMap(fn)
[xx,yy,xs,s]=read_grid(fn);  % Read the dI/dV spectra grid data

% plot the topographical image
[a,b]=strread(fn,'%[^.].%s');
a=char(a);
b=char(b);
p=findstr(a,'_');
fnumber=str2num(a(2:p-1));
[x,y,z]=scala_read(strcat(a,'.tf0'),1);
% figure
% pcolor(x,y,z);
% axis image
% shading interp
% colormap pink

[xxIV,yyIV,xsIV,sIV]=read_grid(strcat(a,'.sf0'));  % Read the I-V grid data

% Get the normalized (dI/dV)/(I/V) spectrum at each point
nx=length(xx); 
ny=length(yy);
nxs=length(xs);
Ed_Map=zeros(nx,ny);

xs = xsIV;
%xs = linspace(-0.275, -0.075);

% Procedure to get the Dirac point energy
% 1. smooth the spectrum
% 2. substract the linear back ground
%    the start and end of the linear spectrum is defined as Lstart and Lend
% 3. get the part of spectrum (defined by Sstart and Send) that contains the Dirac point
%    the minimun position of the spectrum is the Dirac point

Lstart = 1;
Lend = 31;

Sstart = 20;
Send = 60;

for i=1:nx,
   for j=1:ny,
        spec = reshape(s(i,j,:),1,nxs); % get the spectrum
        specIV = reshape(sIV(i,j,:),1,nxs);

        spec_s = spec;

        spec_s = spec_s./(specIV./xsIV);

        %spec_s = smooth(spec_s,3)'; %smooth the spectrum
        
%         [val_min, ind_min] = min(spec_s(Sstart:Send));
%         Ed_Map(i,j) = xs(ind_min+Sstart);
        
        
%          [p g] = polyfit(xs,spec,1); %fit the linear part of the spectrum w/ line, and substract it out
%          slop = p(1);
%          intcp = p(2);
%          spec_s = spec_s - slop * xs;
%                 
        pspec = spec_s(Sstart:Send);  % cut out the partial spectrum that contains Dirac point
        [p g] = polyfit(xs(Sstart:Send),pspec,2); %fit the spectrum w/ parabola
        a = p(1);
        b = p(2);
        Ed_Map(i,j)=-b/(2*a);

        if (i==15)&&(j==25)
            figure;
            plot(xs,spec_s,'r');
            hold on
            plot(xs, a*xs.^2+b*xs+p(3),'b');
        end

   end
end

% convert the Dirac point map to density map:

% Den_Map = abs(Ed_Map) - 0.063;  % substract the energy of the phonon.
% Den_Map = -Den_Map.^2/(pi*6.58^2); % units: E in eV, density in 10E16 cm^-2
% 
% % figure
% % plot(xs,spec);
% % hold on;
% % plot(xs,spec_s);
vmin = -0.32;
vmax = -0.28;
figure
pcolor(xx, yy, Ed_Map');
caxis([vmin vmax])
axis image
shading interp
%colorbar
% % 
% figure
% pcolor(Den_Map);
% axis image
% shading interp
% colorbar

% write images files for the Dirac point Map
% Ed_Map_inv = Ed_Map';
% Out_Map = uint8((Ed_Map' + 0.2)*6250);
% imwrite(Out_Map,strcat('m',num2str(fnumber),'_DircMap.tif'),'TIFF');
% save Dirac_Map.dat Ed_Map_inv;