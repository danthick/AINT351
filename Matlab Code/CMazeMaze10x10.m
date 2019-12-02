%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% all rights reserved
% Author: Dr. Ian Howard
% Associate Professor (Senior Lecturer) in Computational Neuroscience
% Centre for Robotics and Neural Systems
% Plymouth University
% A324 Portland Square
% PL4 8AA
% Plymouth, Devon, UK
% howardlab.com
% 22/09/2018
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


classdef CMazeMaze10x10
    % define Maze work for RL
    %  Detailed explanation goes here
    
    properties
        
        % parameters for the gmaze grid management
        %scalingXY;
        blockedLocations;
        cursorCentre;
        limitsXY;
        xStateCnt
        yStateCnt;
        stateCnt;
        stateNumber;
        totalStateCnt
        squareSizeX;
        cursorSizeX;
        squareSizeY;
        cursorSizeY;
        stateOpen;
        stateStart;
        stateEnd;
        stateEndID;
        stateX;
        stateY;
        xS;
        yS
        stateLowerPoint;
        textLowerPoint;
        stateName;
        
        % parameters for Q learning
        QValues;
        tm;
        actionCnt;
    end
    
    methods
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % constructor to specity maze
        function f = CMazeMaze10x10(limitsXY)
            
            % set scaling for display
            f.limitsXY = limitsXY;
            f.blockedLocations = [];
            
            % setup actions
            f.actionCnt = 4;
            
            % build the maze
            f = SimpleMaze10x10(f);
            
            % display progress
            disp(sprintf('Building Maze CMazeMaze10x10'));
            
        end
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % build the maze
        function f = SetMaze(f, xStateCnt, yStateCnt, blockedLocations, startLocation, endLocation)
            
            % set size
            f.xStateCnt=xStateCnt;
            f.yStateCnt=yStateCnt;
            f.stateCnt = xStateCnt*yStateCnt;
            
            % compute state countID
            for x =  1:xStateCnt
                for y =  1:yStateCnt
                    
                    % get the unique state identified index
                    ID = x + (y -1) * xStateCnt;
                    
                    % record it
                    f.stateNumber(x,y) = ID;
                    
                    % also record how x and y relate to the ID
                    f.stateX(ID) = x;
                    f.stateY(ID) = y;
                end
            end
            
            % calculate maximum number of states in maze
            % but not all will be occupied
            f.totalStateCnt = f.xStateCnt * f.yStateCnt;
            
            
            % get cell centres
            f.squareSizeX= 1 * (f.limitsXY(1,2) - f.limitsXY(1,1))/f.xStateCnt;
            f.cursorSizeX = 0.5 * (f.limitsXY(1,2) - f.limitsXY(1,1))/f.xStateCnt;
            f.squareSizeY= 1 * (f.limitsXY(2,2) - f.limitsXY(2,1))/f.yStateCnt;
            f.cursorSizeY = 0.5 * (f.limitsXY(2,2) - f.limitsXY(2,1))/f.yStateCnt;
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % init maze with no closed cell
            f.stateOpen = ones(xStateCnt, yStateCnt);
            f.stateStart = startLocation;
            f.stateEnd = endLocation;
            f.stateEndID = f.stateNumber(f.stateEnd(1),f.stateEnd(2));
            
            % put in blocked locations
            for idx = 1:size(blockedLocations,1)
                bx = blockedLocations(idx,1);
                by = blockedLocations(idx,2);
                f.stateOpen(bx, by) = 0;
            end
            
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % get locations for all states
            for x=1:xStateCnt
                for y=1:xStateCnt
                    
                    % start at (0,0)
                    xV = x-1;
                    yV = y-1;
                    
                    % pure scaling component
                    % assumes input is between 0 - 1
                    scaleX =  (f.limitsXY(1,2) - f.limitsXY(1,1)) / xStateCnt;
                    scaleY = (f.limitsXY(2,2) - f.limitsXY(2,1)) / yStateCnt;
                    
                    % remap the coordinates and add on the specified orgin
                    f.xS(x) = xV  * scaleX + f.limitsXY(1,1);
                    f.yS(y) = yV  * scaleY + f.limitsXY(2,1);
                    
                    % remap the coordinates, add on the specified orgin and add on half cursor size
                    f.cursorCentre(x,y,1) = xV * scaleX + f.limitsXY(1,1) + f.cursorSizeX/2;
                    f.cursorCentre(x,y,2) = yV * scaleY + f.limitsXY(2,1) + f.cursorSizeY/2;
                    
                    f.stateLowerPoint(x,y,1) = xV * scaleX + f.limitsXY(1,1);  - f.squareSizeX/2;
                    f.stateLowerPoint(x,y,2) = yV * scaleY + f.limitsXY(2,1); - f.squareSizeY/2;
                    
                    f.textLowerPoint(x,y,1) = xV * scaleX + f.limitsXY(1,1)+ 10 * f.cursorSizeX/20;
                    f.textLowerPoint(x,y,2) = yV * scaleY + f.limitsXY(2,1) + 10 * f.cursorSizeY/20;
                end
            end
        end
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % draw rectangle
        function DrawSquare( f, pos, faceColour)
            % Draw rectagle
            rectangle('Position', pos,'FaceColor', faceColour,'EdgeColor','k', 'LineWidth', 3);
        end
        
        % draw circle
        function DrawCircle( f, pos, faceColour)
            % Draw rectagle
            rectangle('Position', pos,'FaceColor', faceColour,'Curvature', [1 1],'EdgeColor','k', 'LineWidth', 3);
        end
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % draw the maze
        function DrawMaze(f)
            figure('position', [100, 100, 1200, 1500]);
            fontSize = 20;
            hold on
            h=title(sprintf('YOURIDHERE: Maze wth %d x-axis X %d y-axis cells', f.xStateCnt, f.yStateCnt));
            set(h,'FontSize', fontSize);
            
            for x=1:f.xStateCnt
                for y=1:f.yStateCnt
                    pos = [f.stateLowerPoint(x,y,1)  f.stateLowerPoint(x,y,2)  f.squareSizeX f.squareSizeY];
                    
                    % if location open plot as blue
                    if(f.stateOpen(x,y))
                        DrawSquare( f, pos, 'b');
                        % otherwise plot as black
                    else
                        DrawSquare( f, pos, 'k');
                    end
                end
            end
            
            
            % put in start locations
            for idx = 1:size(f.stateStart,1)
                % plot start
                x = f.stateStart(idx, 1);
                y = f.stateStart(idx, 2);
                pos = [f.stateLowerPoint(x,y,1)  f.stateLowerPoint(x,y,2)  f.squareSizeX f.squareSizeY];
                DrawSquare(f, pos,'g');
            end
            
            % put in end locations
            for idx = 1:size(f.stateEnd,1)
                % plot end
                x = f.stateEnd(idx, 1);
                y = f.stateEnd(idx, 2);
                pos = [f.stateLowerPoint(x,y,1)  f.stateLowerPoint(x,y,2)  f.squareSizeX f.squareSizeY];
                DrawSquare(f, pos,'r');
            end
            
            % put on names
            for x=1:f.xStateCnt
                for y=1:f.yStateCnt
                    sidx=f.stateNumber(x,y);
                    stateNameID = sprintf('%s', f.stateName{sidx});
                    text(f.textLowerPoint(x,y,1),f.textLowerPoint(x,y,2), stateNameID, 'FontSize', 20)
                end
            end
        end
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % setup 10x10 maze
        function f = SimpleMaze10x10(f)
            
            xCnt=10;
            yCnt=10;
            
            % specify start location in (x,y) coordinates
            % example only
            startLocation=[1 1];
            % YOUR CODE GOES HERE
            
            
            % specify end location in (x,y) coordinates
            % example only
            endLocation=[10 10];
            % YOUR CODE GOES HERE
            
            
            % specify blocked location in (x,y) coordinates
            f.blockedLocations = [4 1; 6 2; 8 2; 9 2; 1 3; 3 3; 4 3; 8 3; 9 3; 
                1 4; 4 4; 5 4; 1 5; 4 5; 5 5; 6 5; 7 5; 10 5; 1 6; 4 6; 6 6; 7 6; 10 6;
                4 7; 8 7; 2 8; 3 8; 4 8; 6 8; 8 8; 9 8; 2 9; 3 9; 4 9; 6 9; 9 9; 6 10;];
            % YOUR CODE GOES HERE
            
            % build the maze
            f = SetMaze(f, xCnt, yCnt, f.blockedLocations, startLocation, endLocation);
            
            % write the maze state
            maxCnt = xCnt * yCnt;
            for idx = 1:maxCnt
                f.stateName{idx} = num2str(idx);
            end
            
        end
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Reward function that takes a stateID and an action
        function reward = RewardFunction(f, stateID, action)
            if ((stateID == 90 && action == 1) || (stateID == 99 && action == 4))
                reward = 10;
            else
                reward = 0;
            end
        end
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Function to compute a random starting state between 0 and 100 not
        % including blocked states
        function startingState = RandomStartingState(f)
            % Initial values
            allowed = false;
            b = 100;         
            
            while (allowed == false)
                % Getting a random starting state
                startingState = ceil(b*rand);
                % Checking if starting state is in the blockedLocations array
                for i = 1:size(f.blockedLocations)
                    % Getting tile number
                    sidx=f.stateNumber(f.blockedLocations(i, 1),f.blockedLocations(i, 2));    
                    % Changing bool value depending on if state is allowed or not
                    if (sidx == startingState || startingState == 100)
                        allowed = false;
                        break;
                    else
                        allowed = true;
                    end
                end
            end          
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % look for end state
        function endState = IsEndState(f, x, y)
            
            % default to not found
            endState=100;
            
            % YOUR CODE GOES HERE ....
            
        end
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Intialise the Q-Table
        function f = InitQTable(f, minVal, maxVal)
            f.QValues = (maxVal-minVal).*rand(f.totalStateCnt, f.actionCnt) + minVal;
        end
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Function to build the transition matrix
        function f = BuildTransitionMatrix(f)
            % Defining actions
            north = 1; east = 2; south = 3; west = 4;
            
            % Loop through each state
            for i = 1:f.xStateCnt
                for j = 1:f.yStateCnt
                    % Check if state is open
                    if (f.stateOpen(i, j))
                        sidx=f.stateNumber(i,j);
                        % Loop through each possible action
                        for k = 1:4
                            % Increase or decrease coordinates
                            % depending on action
                            if (k == north)
                                if (i > 0 && i <= 10 && j > 0 && j <= 9)
                                    if (f.stateOpen(i, j + 1))
                                        f.tm(sidx, k) = f.stateNumber(i,j + 1);
                                    else
                                        f.tm(sidx, k) = f.stateNumber(i,j);
                                    end
                                else
                                    f.tm(sidx, k) = f.stateNumber(i,j);
                                end
                            elseif(k == east)
                                if (i > 1 && i <= 10 && j > 0 && j <= 10)
                                    if (f.stateOpen(i - 1, j))
                                        f.tm(sidx, k) = f.stateNumber(i - 1,j);
                                    else
                                        f.tm(sidx, k) = f.stateNumber(i,j);
                                    end
                                 else
                                    f.tm(sidx, k) = f.stateNumber(i,j);
                                end
                            elseif(k == south)
                                if (i > 0 && i <= 10 && j > 1 && j <= 10)
                                    if (f.stateOpen(i, j - 1))
                                        f.tm(sidx, k) = f.stateNumber(i,j - 1);
                                    else
                                        f.tm(sidx, k) = f.stateNumber(i,j);
                                    end
                                 else
                                    f.tm(sidx, k) = f.stateNumber(i,j);
                                end
                            elseif(k == west)
                                if (i > 0 && i <= 9 && j > 0 && j <= 10)
                                    if (f.stateOpen(i + 1, j))
                                        f.tm(sidx, k) = f.stateNumber(i + 1, j);
                                    else
                                        f.tm(sidx, k) = f.stateNumber(i,j);
                                    end
                                 else
                                    f.tm(sidx, k) = f.stateNumber(i,j);
                                end
                            end
                        end
                    end
                end
            end
        end        
    end
end

