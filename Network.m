function [W1, W2] = Network()
    close all
    clear all
    clc
    % Defining variables
    armLength = [0.4;0.4];
    baseOrigin = [0, 0];
    samples = 1000;
    noOfInputs = 2;
    noOfHiddenNodes = 8;
    noOfOutputNodes = 2;
    
    % Generating 2 x samples data between 0 and pi
    angles = Data;
    angles.values = pi * rand(2,samples);
    % Calculating arm end points given angles
    [P1, P2] = RevoluteForwardKinematics2D(armLength, angles.values, baseOrigin);
    
    % Setting up input values and normalizing the data
    X = Data;
    X.values = P2;
    %X = normalize(X);
    %angles = normalize(angles);
    
    % Initialising random weights, plus 1 used for the bias
    W1 = rand(noOfHiddenNodes, noOfInputs + 1);
    W2 = rand(noOfOutputNodes, noOfHiddenNodes + 1);
    
    % Training the data 1000 times for each data point
    for i = 1:1000
        for j = 1:samples
            [W1, W2] = Train(X.values(:,j), angles.values(:,j), W1, W2);
        end 
    end

    out = Data;
    out.values = pi * rand(2,samples);
    [P1, out.values] = RevoluteForwardKinematics2D(armLength, out.values, baseOrigin);
    %out = normalize(out);
    for i = 1:samples
        o = FeedForward(out.values(:,i), W1, W2);
        out.values(1,i) = o(1,1);
        out.values(2,i) = o(2,1);
    end
    
    %out = reverseNormalize(out);
    %X = reverseNormalize(X);
    %angles = reverseNormalize(angles);
    
    [P3, P4] = RevoluteForwardKinematics2D(armLength, out.values, baseOrigin);
    
    figure
    hold on
    tiledlayout(2,2)
    nexttile
    plot(X.values(1,:), X.values(2,:), 'b.');
    nexttile
    plot(angles.values(1,:), angles.values(2,:), 'b.');
    nexttile
    plot(out.values(1,:), out.values(2,:), 'r.');
    nexttile
    plot(P4(1,:), P4(2,:), 'r.', 'markersize',4);
    
    function M = normalize(M)
        M.meanVal(1) = mean(M.values(1,:));
        M.meanVal(2) = mean(M.values(2,:));
        M.stdVal(1) = std(M.values(1,:));
        M.stdVal(2) = std(M.values(2,:));
        M = M.normalize;
    end

    function M = reverseNormalize(M)
        M = M.reverseNormalize;
    end
end