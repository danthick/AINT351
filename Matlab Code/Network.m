function [W1, W2] = Network()
    % Defining variables
    armLength = [0.4;0.4];
    baseOrigin = [0, 0];
    samples = 1000;
    iterations = 1000;
    noOfInputs = 2;
    noOfHiddenNodes = 20;
    noOfOutputNodes = 2;
    
    % Generating 2 x samples data between 0 and pi
    angles = Data;
    angles.values = pi * rand(2,samples);
    % Calculating arm end points given angles
    [P1, P2] = RevoluteForwardKinematics2D(armLength, angles.values, baseOrigin);
    
    % Setting up input values and normalizing the data
    X = Data;
    X.values = P2;
    %X = Normalize(X);
    %angles = Normalize(angles);
    
    % Initialising random weights, plus 1 used for the bias
    W1 = rand(noOfHiddenNodes, noOfInputs + 1);
    W2 = rand(noOfOutputNodes, noOfHiddenNodes + 1);
    
    % Training the data for the number of iterations for each data point
    for i = 1:iterations
        for j = 1:samples
            [W1, W2] = Train(X.values(:,j), angles.values(:,j), W1, W2);
        end 
    end

    out = Data;
    out.values = pi * rand(2,samples);
    [P1, out.values] = RevoluteForwardKinematics2D(armLength, out.values, baseOrigin);
    %out = Normalize(out);
    
    for i = 1:samples
        out.values(:,i) = FeedForward(out.values(:,i), W1, W2);
    end
    
    %out = ReverseNormalize(out);
    %X = ReverseNormalize(X);
    %angles = ReverseNormalize(angles);
    
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
end