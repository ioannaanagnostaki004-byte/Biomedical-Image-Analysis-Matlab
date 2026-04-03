%1. Ανάγνωση και επεξήγηση του αρχείου
TR = stlread('man_small.stl'); 
disp(TR)
num_points = size(TR.Points, 1);
num_triangles = size(TR.ConnectivityList, 1);

disp('Πρώτες 5 κορυφές (X, Y, Z):');
disp(TR.Points(1:5, :));

disp('Πρώτα 5 τρίγωνα (Δείκτες προς τις κορυφές):');
disp(TR.ConnectivityList(1:5, :));

%2. 3d visualasation 
numFaces = size(TR.ConnectivityList, 1);
green = repmat([0 1 0], numFaces, 1);

figure();
patch('Faces', TR.ConnectivityList, 'Vertices', TR.Points,  'FaceVertexCData', green , 'FaceColor' , 'flat'); 

view(3); 
axis equal;

%3. 3d visualasation x 4
offsets = [0, 1, 2, 3]; 
V_all = []; 
F_all = []; 

figure();
hold on; 
grid on;

for i = 1:length(offsets)
    current_offset = offsets(i);
    
    V_temp = TR.Points;
    V_temp(:,1) = V_temp(:,1) + current_offset; 

    current_num_v = size(V_all, 1);
    F_new = TR.ConnectivityList + current_num_v;
    
    V_all = [V_all; V_temp];
    F_all = [F_all; F_new];
    
    p(i) = patch('Faces', TR.ConnectivityList, 'Vertices', V_temp, 'FaceVertexCData', green, 'FaceColor', 'flat');
    
end

hold off;
view(3); 
axis equal;

%4. from human perspective to camera perspective 
th_y = deg2rad(-90);
th_x = deg2rad(90);

Ry = [cos(th_y) 0 sin(th_y); 0 1 0; -sin(th_y) 0 cos(th_y)];
Rx = [1 0 0; 0 cos(th_x) -sin(th_x); 0 sin(th_x) cos(th_x)];

R = Ry * Rx;

camera_pov = [-2; 0.8; 0;];
t = -R * camera_pov;

P_extr = [R, t; 0 0 0 1];
disp('Πίνακας Εξωτερικών Παραμέτρων P_extr:');
disp(P_extr);

%5. from 3d to 2d
Q = [V_all'; ones(1, size(V_all, 1))];

Q_prime = P_extr * Q;

x_p = Q_prime(1, :);
y_p = Q_prime(2, :);
z_p = Q_prime(3, :);

u = x_p ./ z_p; %orizontia
v = y_p ./ z_p; %katheth

green_all = repmat([0 1 0], size(F_all, 1), 1);

figure();
hold on; 
grid on;

 patch('Faces', F_all, 'Vertices', [u' v'] ,'FaceVertexCData', green_all, 'FaceColor', 'flat');

hold off;
set(gca, 'YDir', 'reverse');
axis equal;
