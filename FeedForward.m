function output = FeedForward(input, W1, W2)
    % Calculate output from hidden layer
    input = [input; 1];
    net = W1*input;
    % Sigmoid activation function
    a2 = SigmoidFunction(net);
    % Adding bias to activation from hidden layer
    a2hat = [a2; 1];
    % Calculating output from output layer
    output = W2*a2hat;
end