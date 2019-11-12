function test2()
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
    W1 = (pi--pi).*rand(noOfHiddenNodes, noOfInputs)-pi;
    global W2;
    W2 = (pi--pi).*rand(noOfOutputNodes, noOfHiddenNodes + 1)-pi;
    
    for k = 1:2
        P2(k,:) = (P2(k,:) - min(P2(k,:))) ./ max(P2(k,:) - min(P2(k,:)));
    end
    
    for i = 1:1000
        for j = 1:samples
            train(P2(:,j), angles(:,j))
        end 
    end
    
     X = (1--1).*rand(2,samples) - 1;
     
    for i = 1:samples
        o = feedForward(X(:,i));
        out(1,i) = o(1,1);
        out(2,i) = o(2,1);
    end
    
    for k = 1:2
        P2(k,:) = (P2(k,:) - min(P2(k,:))) ./ max(P2(k,:) - min(P2(k,:)));
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
    
    %delta3 = -(target-o).*o.*(1-o);
    delta3 = -(target-o);
    
    W2Hat = [W2(1,1), W2(1,2), W2(1,3); W2(2,1), W2(2,2), W2(2,3)];
    delta2 = (W2Hat'*delta3).*a2.*(1-a2);
    
    errGradientW1 = delta2*input';
    errGradientW2 = delta3*a2hat';
    
    W1 = W1 - 0.001*errGradientW1;
    W2 = W2 - 0.001*errGradientW2;
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

function result = sigmoidFunction(net)
    result = 1 ./ (1+(exp(-net)));
end