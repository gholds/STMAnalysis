% function combine_spec2(s1,s2,v1,v2)
% 2x averages together original specs rather than the normalized specs

function combine_spec2(s1,s2,v1,v2,v3,v4)
p=strrep(cd,'\','\\');
na1=strcat('m',num2str(s1),'_ori.cs0');
na2=strcat('m',num2str(s1),'_ori.cs1');
na3=strcat('m',num2str(s2),'_ori.cs0');
na4=strcat('m',num2str(s2),'_ori.cs1');

[x,y,z0a,xz]=scala_read(na1,0);
[x,y,z1a,xz]=scala_read(na2,0);
[x,y,z0b,xz]=scala_read(na3,0);
[x,y,z1b,xz]=scala_read(na4,0);
cs0=[z0a([v1 v2],:) ; z0b([v3 v4],:)];
cs1=[z1a([v1 v2],:) ; z1b([v3 v4],:)];
[nnn ttt]=size(z0a([v1 v2],:));
[qqq www]=size(cs0);
for i=1:qqq,
    cs0(i,:)=smooth(cs0(i,:));
end

m=norm_spec(cs1,cs0);

[n1,n2]=size(m);

figure
hold on
le='aa';
        plot(xz,m(1:nnn,:),'b','linewidth',1.5)
        plot(xz,m(nnn+1:qqq,:),'r','linewidth',1.5)
hold off
set(gca,'fontsize',18)
grid
axis tight
ht=title(strcat(p,'\\m',num2str(s1),'+',num2str(s2),' Normalized spec'));
set(ht,'fontsize',12);
%legend(le)

figure
hold on
le='aa';
xxx1=length(v1);
xxx2=length([v1 v2]);
xxx3=length([v1 v2 v3]);
xxx4=length([v1 v2 v3 v4]);
        plot(xz,mean(cs1(1:xxx1,:)),'b',xz,mean(cs1((xxx1+1):xxx2,:)),'r','linewidth',1.5)
        plot(xz,mean(cs1(xxx2+1:xxx3,:)),'b:',xz,mean(cs1((xxx3+1):xxx4,:)),'r:','linewidth',1.5)
hold off
set(gca,'fontsize',18)
grid
axis tight
ht=title(strcat(p,'\\m',num2str(s1),'+',num2str(s2),'average original spec'));
set(ht,'fontsize',12);

figure
hold on
        plot(xz,cs1(1:nnn,:),'b','linewidth',1.5)
        plot(xz,cs1(nnn+1:qqq,:),'r','linewidth',1.5)
hold off
set(gca,'fontsize',18)
grid
axis tight
ht=title(strcat(p,'\\m',num2str(s1),'+',num2str(s2),' Original spec'));
set(ht,'fontsize',12);
%legend(le)

