function DisplayRevoluteArm()
    close all
    clear all
    clc
    % Defining variables
    armLength = [0.4;0.4];
    baseOrigin = [0, 0];
    samples = 1000;
    
    % Generating 2 x samples between 0 - pi
    angles = pi * rand(2,samples);
    % Run angles through forward kinematics
    [P1, P2] = RevoluteForwardKinematics2D(armLength, angles, baseOrigin);
    
    % Plot randomly generated angles
    figure
    hold on
    title({'ID: 10555972', 'Arm Joint Angles'});
    xlabel('x-axis');
    ylabel('y-axis'); 
    plot(angles(1,:), angles(2,:), 'r.');
    
    % Plot end points
    figure
    hold on
    title({'ID: 10555972', 'Arm Endpoint'});
    xlabel('x[m]');
    ylabel('y[m]'); 
    plot(P2(1,:), P2(2,:), 'r.')
    plot(baseOrigin(1), baseOrigin(2), 'b.', 'MarkerSize', 20);
    
    % Plot 10 arm configurations
    figure
    title({'ID: 10555972', 'Arm Configuration'});
    xlabel('x[m]');
    ylabel('y[m]');
    for i = 1:10
      hold on
      % Plotting from elbow to end of arm
      plot([P1(1,i) P2(1,i)],[P1(2,i) P2(2,i)], 'b-o', 'MarkerSize', 5,  'MarkerFaceColor', 'green');
      % Plotting from origin to elbow
      plot([P1(1,i) baseOrigin(1)], [P1(2,i) baseOrigin(2)], 'r-o', 'MarkerSize', 5);
    end
end