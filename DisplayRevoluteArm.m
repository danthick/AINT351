function DisplayRevoluteArm()
    close all
    clear all
    clc
    % Defining variables
    armLength = [0.4;0.4];
    baseOrigin = [0, 0];
    samples = 1000;
    
    % Generating 2xsamples data between 0 - pi
    data = pi * rand(2,samples);
    [P1, P2] = RevoluteForwardKinematics2D(armLength, data, baseOrigin);
    % Plot data
    figure
    hold on
    title({'ID: 10555972', 'Arm Endpoint'});
    xlabel('x[m]');
    ylabel('y[m]'); 
    plot(P2(1,:), P2(2,:), 'r.')
    plot(baseOrigin(1), baseOrigin(2), 'b.', 'MarkerSize', 20);

    
    % Generating just 10 samples
    samples = 10;
    data = pi * rand(2,samples);
    [P1, P2] = RevoluteForwardKinematics2D(armLength, data, baseOrigin);
        
    figure
    for i = 1:samples
      % Plotting points with arm, connecting to origin
      hold on
      plot([P1(1,i) P2(1,i)],[P1(2,i) P2(2,i)], 'b-o', 'MarkerSize', 5,  'MarkerFaceColor', 'green');
      plot([P1(1,i) baseOrigin(1)], [P1(2,i) baseOrigin(2)], 'r-o', 'MarkerSize', 5);
    end
end