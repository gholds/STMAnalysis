% show_spec2diff(n,gs)
% show spectroscopy of file mn_ori when n is the function input.
% gs = group size is the number of spectra to average
% diff also shows the second derivative
% and it shows the average of cs0 (either i(v) or di/dv(v) if taking 
% 2nd harmonic data

function show_spec_i(n,gs)
p=strrep(cd,'\','\\');
fn1=strcat('m',num2str(n),'_ori.tf0');
fn2=strcat('m',num2str(n),'_ori.cs0');
fn3=strcat('m',num2str(n),'_ori.cs1');
[vf,vb]=get_scan_voltage(n);
[fi,bi]=get_scan_current(n);

[xx,yy,tf0]=scala_read(fn1,1);
%load z
%tf0=z;
[x,y,cs0,xz]=scala_read(fn2,0);
[x,y,cs1,xz]=scala_read(fn3,0);

[qqq www]=size(cs0);
%for i=1:qqq,
%    cs0(i,:)=smooth(cs0(i,:));
%end

m=norm_spec_vic(cs1,cs0,xz);

cc='rgbmykc';

[n1,n2]=size(m);
n1
n2
ng=floor(n1/gs);
difxz=xz(1:length(xz)-1)+abs(xz(1)-xz(2))/2;
figure
hold on
le='aa';
for i=1:ng,
    if gs>1,
        plot(xz,mean(m((i-1)*gs+1:(i-1)*gs+gs,:)),cc(mod(i,7)+1),'linewidth',1.5)        
    else
        plot(xz,m(i,:),cc(mod(i,7)+1),'linewidth',1.5)
    end
    if i<10,
        le(i,1:2)=strcat('0',num2str(i));
    else
        le(i,1:2)=strcat('',num2str(i));
    end
end
hold off
set(gca,'fontsize',18)
grid
axis tight
ht=title(strcat(p,'\\m',num2str(n),' Normalized spec, V=',num2str(vf),' V, I=',num2str(fi),' nA'));
set(ht,'fontsize',12);
legend(le)

% Output the Averaged spectra in cs1 to file ***_dIdV_NORM_AVE.dat
fileid=fopen(strcat('m',num2str(n),'_dIdV_NORM_AVE.dat'),'wt');
for i=1:www,
    fprintf(fileid, '%f\t', xz(i)); 
    for j=1:ng,
        if gs>1,
            fprintf(fileid, '%f\t',mean(m((j-1)*gs+1:(j-1)*gs+gs,i)));
        else
            fprintf(fileid, '%f\t',m(j,i));
        end
    end
    fprintf(fileid,'\n');
end
fclose(fileid);

%figure
%hold on
%for i=1:ng
%    if gs>1,
%        plot(xz,mean(cs0((i-1)*gs+1:(i-1)*gs+gs,:)),cc(mod(i,7)+1),'linewidth',1.5)
%    else
%        plot(xz,cs0(i,:),cc(mod(i,7)+1),'linewidth',1.5)
%    end
%        le(i,1)=num2str(i);
%end
%hold off  
%set(gca,'fontsize',18)
%grid
%axis tight
%ht=title(strcat(p,'\\m',num2str(n),' cs0 Original spec, V=',num2str(vf),' V, I=',num2str(fi),' nA'));
%set(ht,'fontsize',12);
%legend(le)

%figure
%hold on
%for i=1:ng,
%    if gs>1,
%        plot(difxz,abs(diff(mean(cs1((i-1)*gs+1:(i-1)*gs+gs,:)))),cc(mod(i,7)+1),'linewidth',1.5)
%    else
%        plot(difxz,abs(diff(cs1(i,:))),cc(mod(i,7)+1),'linewidth',1.5)
%    end
%        le(i,1)=num2str(i);
%end
%hold off

figure
hold on
for i=1:ng,
    if gs>1,
        plot(xz,mean(cs1((i-1)*gs+1:(i-1)*gs+gs,:)),cc(mod(i,7)+1),'linewidth',1.5)
    else
        plot(xz,cs1(i,:),cc(mod(i,7)+1),'linewidth',1.5)
    end
%        le(i,1)=num2str(i);
end
hold off
set(gca,'fontsize',18)
grid
axis tight
ht=title(strcat(p,'\\m',num2str(n),' cs1 Original spec, V=',num2str(vf),' V, I=',num2str(fi),' nA'));
set(ht,'fontsize',12);
legend(le)

% Output the Averaged spectra in cs1 to file ***_d2IdV2_SPEC_AVE.dat
fileid=fopen(strcat('m',num2str(n),'_dIdV_SPEC_AVE.dat'),'wt');
for i=1:www,
    fprintf(fileid, '%f\t', xz(i)); 
    for j=1:ng,
        if gs>1,
            fprintf(fileid, '%f\t',mean(cs1((j-1)*gs+1:(j-1)*gs+gs,i)));
        else
            fprintf(fileid, '%f\t',cs1(j,i));
        end
    end
    fprintf(fileid,'\n');
end
fclose(fileid);
zer=0
figure
pcolor(xx,yy,tf0)
shading interp
axis square
ht=title(strcat(p,'\\m',num2str(n),',  V=',num2str(vf),' V, I=',num2str(fi),' nA'));
set(ht,'fontsize',12);
hold on
for i=1:ng,
    %plot(x((i-1)*gs+1:(i-1)*gs+gs),y((i-1)*gs+1:(i-1)*gs+gs),strcat(cc(mod(i,7)+1),'*'),'markersize',14)
    mean(x((i-1)*gs+1:(i-1)*gs+gs))-3.36
    mean(y((i-1)*gs+1:(i-1)*gs+gs))+0.21
    0
    text(x((i-1)*gs+1:(i-1)*gs+gs),y((i-1)*gs+1:(i-1)*gs+gs),num2str(i),'color','b')
end
hold off
set(gca,'fontsize',18)
colormap pink
