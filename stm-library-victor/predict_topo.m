% [xz,tp]=predict_topo(n1,n2,v1,v2)

function [xz,tp]=predict_topo(n1,n2,v1,v2)
fn1=strcat('m',num2str(n1),'_ori.tf0');
fn2=strcat('m',num2str(n2),'_ori.tf0');
[x1,y1,z1]=scala_read(fn1,1);
[x2,y2,z2]=scala_read(fn2,1);
nn1=length(v1);
nn2=length(v2);
figure
pcolor(z1)
shading interp
axis image
z1b=level(z1);
pcolor(x1,y1,z1b)
shading interp
axis image
hold on
for i=1:nn1,
qq1(i,:)=ginput(1);
plot(qq1(i,1),qq1(i,2),'*b')
end
hold off
zz1=interp2(x1,y1,z1b,qq1(:,1),qq1(:,2));

figure
pcolor(z2)
shading interp
axis image
z2b=level(z2);
pcolor(x2,y2,z2b)
shading interp
axis image
hold on
for i=1:nn2,
qq2(i,:)=ginput(1);
plot(qq2(i,1),qq2(i,2),'*b')
end
hold off
zz2=interp2(x2,y2,z2b,qq2(:,1),qq2(:,2));


fn1b=strcat('m',num2str(n1),'_ori.cs0')
[x1,y1,z1,xz]=scala_read(fn1b,0);
z1=abs(z1);
nnn=zz1(1)*log(z1(1,:));
for i=1:nn1
    tp(i,:)=zz1(i)*log(z1(i,:))./nnn;
end

fn2b=strcat('m',num2str(n2),'_ori.cs0')
[x2,y2,z2,xz]=scala_read(fn2b,0);
z2=abs(z2);
for i=1:nn2
    tp(i+nn1,:)=zz2(i)*log(z2(i,:))./nnn;
end


figure
%tp=real(tp);
plot(xz,tp,'linewidth',2)
q1=max(max(tp)); q2=min(min(tp));
dq=q1-q2;
set(gca,'ylim',[q2-.1*dq q1+.1*dq])
