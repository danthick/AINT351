function Network()
    close all
    clear all
    clc 
    % Defining variables
    armLength = [0.4;0.4];
    baseOrigin = [0, 0];
    samples = 1000;
    noOfInputs = 3;
    noOfHiddenNodes = 5;
    noOfOutputNodes = 2;
    
    % Generating 2 x samples data between 0 - pi
    angles = pi * rand(2,samples);
    % Calculating arm end points given angles
    [P1, P2] = RevoluteForwardKinematics2D(armLength, angles, baseOrigin);
    
    X = Data;
    X.values = P2;
    X = normalize(X);
    
    global W1;  global W2;
    W1 = rand(noOfHiddenNodes, noOfInputs);
    W2 = rand(noOfOutputNodes, noOfHiddenNodes + 1);
    
    for i = 1:1000
        for j = 1:samples
            train(X.values(:,j), angles(:,j))
        end 
    end
    
    out = Data;
    out.values = rand(2,samples);
    out.values = X.values;
    out = normalize(out);
    Xrand  = out.values;
    for i = 1:samples
        o = feedForward(Xrand(:,i));
        out.values(1,i) = o(1,1);
        out.values(2,i) = o(2,1);
    end
    out = reverseNormalize(out);
    X = reverseNormalize(X);
    
    out.values(:,1)
    X.values(:,1)
    
    [P3, P4] = RevoluteForwardKinematics2D(armLength, out.values, baseOrigin);
    
    figure
    hold on
    tiledlayout(2,2)
    nexttile
    plot(X.values(1,:), X.values(2,:), 'b.');
    nexttile
    plot(angles(1,:), angles(2,:), 'b.');
    nexttile
    plot(out.values(1,:), out.values(2,:), 'r.');
    nexttile
    plot(P4(1,:), P4(2,:), 'r.', 'markersize',4);
    
end

function train(input, target)
    global W1;
    global W2;
    % Calculate output from hidden layer and add bias
    input = [input; 1];
    net = W1*input;
    % Sigmoid activation function
    a2 = sigmoidFunction(net);
    % Adding bias to activation from hidden layer
    a2hat = [a2; 1];
    % Calculating output from output layer
    o = W2*a2hat;

    delta3 = -(target-o);
    W2Hat = [W2(1,1), W2(1,2), W2(1,3), W2(1,4), W2(1,5); W2(2,1), W2(2,2), W2(2,3), W2(2,4), W2(2,5)];
    delta2 = (W2Hat'*delta3).*a2.*(1-a2);
    
    errGradientW1 = delta2*input';
    errGradientW2 = delta3*a2hat';
    
    W1 = W1 - 0.01*errGradientW1;
    W2 = W2 - 0.01*errGradientW2;
end

function output = feedForward(input)
    global W1;
    global W2;
    % Calculate output from hidden layer
    input = [input; 1];
    net = W1*input;
    % Sigmoid activation function
    a2 = sigmoidFunction(net);
    % Adding bias to activation from hidden layer
    a2hat = [a2; 1];
    % Calculating output from output layer
    output = W2*a2hat;
end

% Sigmoid Function
function result = sigmoidFunction(net)
    result = 1 ./ (1+(exp(-net)));
end

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