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
    [P1, P2] = RevoluteForwardKinematics2D(armLength, angles, baseOrigin);
    data = [P1(1,:); P2(1,:); ones(1,samples)];
    random = rand(2, samples);
    
    X = [random(1,:); random(2, :);  ones(1,samples)];
    
    learningRate = 0.1;
    noOfInputs = 3;
    noOfHiddenNodes = 3;
    noOfOutputNodes = 1;
    iterations = 100;
    
    W1 = rand(noOfHiddenNodes, noOfInputs);
    W2 = rand(noOfOutputNodes, noOfHiddenNodes + 1);
    
%     for i = 1:1000
% %         a1 = feedForward(X(:,i), W1, W2);
%         t = angles(1,1);
%         [errW1, errW2, o] = train(X(:,1), t, W1, W2);
%         error(i) = errW1(1,1);
%         gen(i) = o;
%         W1 = W1 - learningRate.*errW1;
%         W2 = W2 - learningRate.*errW2;
%     end
    
    o = X(:,1);
    
    for i = 1:1000
%         a1 = feedForward(X(:,i), W1, W2);
        t = angles(2,1);
        [errW1, errW2, o] = train(o, t, W1, W2, X(:,1));
        error(i) = errW1(1,1);
        gen1(i) = o;
        W1 = W1 - learningRate.*errW1;
        W2 = W2 - learningRate.*errW2;
    end 
    
    figure
    hold on
    tiledlayout(2,2)
    nexttile
    plot(error, 'b.');
    nexttile
    plot(P2(1,:), P2(2,:), 'b.');
    nexttile
    plot(random(1,:), random(2,:), 'b.');
    nexttile
    plot(gen, gen1, 'r.');
end    

function activation = feedForward(input, W1, W2)    
    % Calculate output from hidden layer
    net = W1*input;
    % Sigmoid activation function
    a1 = sigmoidFunction(net);
    % Adding bias to activation from hidden layer
    a1hat = [a1; 1];
    
    % Calculating output from output layer
    output = W2*a1hat;
    % Sigmoid activation function
    activation = sigmoidFunction(output);
end

function [errGradientW1, errGradientW2, o] = train(input, target, W1, W2, X)
    % Calculate output from hidden layer
    net = W1*input;
    % Sigmoid activation function
    a2 = sigmoidFunction(net);
    % Adding bias to activation from hidden layer
    a2hat = [a2; 1];
    % Calculating output from output layer
    output = W2*a2hat;
    % Sigmoid activation function
    o = sigmoidFunction(output);
    %o = output;
    

    delta3 = -(target-o).*o.*(1-o);
    
    W2Hat = [W2(1,1), W2(1,2), W2(1,3)];
    delta2 = (W2Hat'*delta3).*a2.*(1-a2);
    
    errGradientW1 = delta2*X';
    errGradientW2 = delta3*a2hat'; 
end

function result = sigmoidFunction(net)
    result = 1 ./ (1+(exp(-net)));
end