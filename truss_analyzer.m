%Open and read the truss information data file.
fid=fopen('test1.dat');
code='';
c=1;
while feof(fid)==0
aline=fgetl(fid);
c=c+1;
if c>5 %Make sure the truss data in the file starts after line 5.
code=strcat(code,aline);
end
end
eval(code); %Create matlab variables based on the data file.
 
%Determine the number of joints and the number of members in the truss.
[numberOfJoints,numberOfMembers] = size(C);
 
%Make the first 1 in each column of C -1
for i = 1:numberOfMembers
    inversePosition = find (C(:,i),1,'first');
    C(inversePosition,i) = -1;
end
 
%Find the x-component and y-component differences between joints. 
xDif = repmat(X*C,numberOfJoints,1);
yDif = repmat(Y*C,numberOfJoints,1);
 
%Create the A matrix by dividing the difference in x or y by the distance
%between members and inserting them into the matrix.
C = C.*-1;
distance = (xDif.^2+yDif.^2).^(1/2);
xComponent = C.*xDif./distance;
yComponent = C.*yDif./distance;
A = [xComponent,Sx;yComponent,Sy];
L = L';
%Solve the matrix equation AT=-L
%T is a column vector that represents the force loads on each member. 
%The last 3 elements are the reaction forces at the supports.
%Positive values represent tension. Negative values, compression.
T = A\(-L); 
 
%Print group information, the total load on the truss, and the force on
%each member, stating whether each member is in tension or compression.
fprintf('% EK301, Section A4, Group , 13/11/12 \n % Lui Barroso IDU01839405 \n % Timothy Chong U43983878 \n % John Carega U46372594 \n');
fprintf('Load:%.2fN\n', abs(sum(L)));
disp('Member forces in Newtons:')
for i = 1:numberOfMembers
    if(T(i)>0)
        fprintf('m%d: %.3f (T)\n',i,abs(T(i)));
    elseif(T(i)<0)
        fprintf('m%d: %.3f (C)\n',i,abs(T(i)));
    else
       fprintf('m%d: 0\n',i);
    end
end
 
%Determine the cost of the truss.
cost = 10*numberOfJoints+sum(distance(1,:)); 
 
%Print the reaction forces on the support joints and the cost of the truss. 
disp('Reaction forces in Newtons:')
fprintf('Sx1: %.3f\n',T(numberOfMembers+1));
fprintf('Sy1: %.3f\n',T(numberOfMembers+2));
fprintf('Sy2: %.3f\n',T(numberOfMembers+3));
fprintf('Cost of truss: $%.f\n',cost);
 
%Create a vector representing the loads of the members in compression.
compressionOnly = T;
compressionOnly(compressionOnly>0) = 0;
compressionOnly = abs(compressionOnly)';
 
%Determine the maximum load the truss can handle before buckle and print
%the maximum load to cost ratio.
for i = 1:numberOfMembers
    compressionOnly(i) = compressionOnly(i)./(1211.447/(distance(1,i)^2));
end
maxLoad = abs(sum(L))*(1/max(compressionOnly));
 
fprintf('Maximum Load Over Cost: %f\n',maxLoad/cost);