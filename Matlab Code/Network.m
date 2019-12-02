function [W1, W2] = Network()
    % Defining variables
    armLength = [0.4;0.4]; baseOrigin = [0, 0];
    samples = 1000; iterations = 1000;
    noOfInputs = 2; noOfHiddenNodes = 25; noOfOutputNodes = 2;
    
    % Generating 2 x samples data between 0 and pi
    randAngles = pi * rand(2,samples);
    % Calculating arm end points given angles
    [P1, P2] = RevoluteForwardKinematics2D(armLength, randAngles, baseOrigin);
    
    % Initialising random weights, plus 1 used for the bias
    W1 = rand(noOfHiddenNodes, noOfInputs + 1);
    W2 = rand(noOfOutputNodes, noOfHiddenNodes + 1);

    % Training the data for the number of iterations for each data point
    for i = 1:iterations
        for j = 1:samples
            [W1, W2, err(j)] = TrainNetwork(P2(:,j), randAngles(:,j), W1, W2);
        end
        % Calculating error
        error(i) = mean(err);
    end
    
    % Plotting error
    figure
    hold on
    title({'ID: 10555972', 'Amount of Error'});
    xlabel('Iterations');
    ylabel('Error'); 
    plot(error, 'b-');
    
    % Generating new data to feed forward pass through the network
    randAngles2 = pi * rand(2,samples);
    [P1, endPoints] = RevoluteForwardKinematics2D(armLength, randAngles2, baseOrigin);
    
    % Passing data through network
    for i = 1:samples
        outputtedAngles(:,i) = FeedForward(endPoints(:,i), W1, W2);
    end
    
    % Using the output angles and getting the arm end points
    [P3, P4] = RevoluteForwardKinematics2D(armLength, outputtedAngles, baseOrigin);
    
    % Plotting the random angles and endpoints. Then plotting the generated
    % inverse angles and end points from the network.
    figure
    hold on
    tiledlayout(2,2)
    nexttile 
    plot(endPoints(1,:), endPoints(2,:), 'b.');
    title({'ID: 10555972', 'Random Endpoints'});
    nexttile
    plot(randAngles2(1,:), randAngles2(2,:), 'b.');
    title({'ID: 10555972', 'Random Joint Angles'});
    nexttile
    plot(outputtedAngles(1,:), outputtedAngles(2,:), 'r.');
    title({'ID: 10555972', 'Angles Generated via Inverse Network'});
    nexttile
    plot(P4(1,:), P4(2,:), 'r.', 'markersize',4);
    title({'ID: 10555972', 'Endpoints Generated via Inverse Network'});
end