function Network()
    close all
    clear all
    clc 
    % Defining variables
    armLength = [0.4;0.4];
    baseOrigin = [0, 0];
    samples = 1000;
    
    % Generating 2xsamples data between 0 - pi
    angles = pi * rand(2,samples);
    % Calculating arm end points given angles
    [P1, P2] = RevoluteForwardKinematics2D(armLength, angles, baseOrigin);
    
    noOfInputs = 3;
    noOfHiddenNodes = 3;
    noOfOutputNodes = 2;
    
    global W1; 
    W1 = rand(noOfHiddenNodes, noOfInputs);
    global W2;
    W2 = rand(noOfOutputNodes, noOfHiddenNodes + 1);
    
    minVal(1) = min(P2(1,:));
    maxVal(1) = max(P2(1,:));
    minVal(2) = min(P2(2,:));
    maxVal(2)= max(P2(2,:));
    for k = 1:2
        P2(k,:) = (P2(k,:) - min(P2(k,:))) ./ max(P2(k,:) - min(P2(k,:)));
    end
    
    idx = randperm(samples);
    for i = 1:1000
        for j = 1:samples
            train(P2(:,idx(j)), angles(:,idx(j)))
        end 
    end
    
    X = rand(2,samples);
    
    for i = 1:samples
        o = feedForward(X(:,i));
        out(1,i) = o(1,1);
        out(2,i) = o(2,1);
    end
    
    for k = 1:2
        P2(k,:) = P2(k,:) .* (maxVal(k) - minVal(k)) + minVal(k);
    end
    
    [P3, P4] = RevoluteForwardKinematics2D(armLength, out, baseOrigin);
    
    figure
    hold on
    tiledlayout(2,2)
    nexttile
    plot(P2(1,:), P2(2,:), 'b.');
    nexttile
    plot(X(1,:), X(2,:), 'b.');
    nexttile
    plot(out(1,:), out(2,:), 'r.');
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
    W2Hat = [W2(1,1), W2(1,2), W2(1,3); W2(2,1), W2(2,2), W2(2,3)];
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
end

function M = reverseNormalize(M)

end