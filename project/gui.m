function ConnectingGame
    % Load Images 
    path='tile_image';
    picInformation=dir(fullfile(path,'*.png'));
    N=length(picInformation);
    picList.(['pic',num2str(1)])=imread([path,'/','0.jpg']);
    for i=1:N
        picList.(['pic',num2str(i+1)])=...
            imread([path,'/',picInformation(i).name]);
    end
    disp(N)

    
    
    global selectedPos clickPos
    global link_line
    global board
    global l w num_kinds pairs
    % num_kinds <= 10
    % There are 13 kinds in total, one used for single.
    selectedPos=[];
    link_line=[];

    % Init board
    l=6;
    w=6;
    num_kinds=6;
    pairs = 20;
    [board, generated_pairs] = init_game_board(l,w,num_kinds,pairs);
    
    % Draw board GUI
    MainFig=figure('units','pixels', ...
        'position', ... % [left bottom width height]
        [750 250 800 800],...
        'Numbertitle','off', ...
        'menubar','none', ...
        'resize','off',...
        'name','Tile-matching Game');
    
    axes('parent',MainFig, ...
        'position',[0 0 1 1],... % margin: [left bottom width height]
        'XLim', [40 10*100+10*5-40],...
        'YLim', [40 8*100+8*5-40],...
        'color',[1,1,0.9373],...
        'NextPlot','add',...
        'layer','bottom',...
        'Visible','on',...
        'YDir','reverse',...
        'XTick',[], ...
        'YTick',[]);
    
    % uimenu('label','start')
    uimenu('label','restart', ...
        'callback',@restart)
    uimenu('label','help', ...
        'callback',@solver)
    % uh1=uimenu('label','????');
    % uimenu(uh1,'label','??????', ...
    %     'callback',@restartGame)
    
    margin = 5;
    for i=1:l
        for j=1:w
            drawPicHdl(i,j)=image( ...
                    [(i-1)*100,i*100]+40+i*margin, ... %x
                    [(j-1)*100,j*100]+40+j*margin,... %y
                    picList.(['pic',num2str(board(i,j)+1)]), ...
                    'tag',[num2str(i),num2str(j)],...
                    'ButtonDownFcn',@clickOnPic);
        end
    end

    % Init display messages
    count_text = text(700, 100, [''], ...
                        'FontSize', 18, ...
                        'FontWeight', 'bold', ...
                        'Color', [0.2 0.2 0.2]);
    
    invalid_text = text(700, 200, [''], ...
                        'FontSize', 18, ...
                        'FontWeight', 'bold', ...
                        'Color', [0.2 0.2 0.2]);

    game_status_text = text(700, 300, ['Game Start!'], ...
                        'FontSize', 18, ...
                        'FontWeight', 'bold', ...
                        'Color', [0.2 0.2 0.2]);                    
                    
   title_text = text(80, 730, ['Tile-Matching Game'], ...
                        'FontSize', 75, ...
                        'FontWeight', 'bold', ...
                        'Color', [0.3 0.3 0.3]);

    
    function restart(~,~)
        [board, generated_pairs] = init_game_board(l,w,num_kinds,pairs);
        for i=1:l
            for j=1:w
                drawPicHdl(i,j)=image( ...
                        [(i-1)*100,i*100]+40+i*margin, ... %x
                        [(j-1)*100,j*100]+40+j*margin,... %y
                        picList.(['pic',num2str(board(i,j)+1)]), ...
                        'tag',[num2str(i),num2str(j)],...
                        'ButtonDownFcn',@clickOnPic);
            end
        end

        delete(count_text);
        delete(invalid_text);
        delete(game_status_text);
        % Init display messages
    count_text = text(700, 100, [''], ...
                        'FontSize', 18, ...
                        'FontWeight', 'bold', ...
                        'Color', [0.2 0.2 0.2]);
    
    invalid_text = text(700, 200, [''], ...
                        'FontSize', 18, ...
                        'FontWeight', 'bold', ...
                        'Color', [0.2 0.2 0.2]);

    game_status_text = text(700, 300, ['Game Start!'], ...
                        'FontSize', 18, ...
                        'FontWeight', 'bold', ...
                        'Color', [0.2 0.2 0.2]);
    end

    function solver(~,~)
        delete(count_text);
        delete(invalid_text);
        delete(game_status_text);

        game_status_text = text(700, 300, ['Auto Solving....'], ...
                            'FontSize', 18, ...
                            'FontWeight', 'bold', ...
                            'Color', [0.2 0.2 0.2]);     


        [solution_pairs, solution_nums] = solve_game(board, generated_pairs)
        for i=1:solution_nums
            step_text = text(700, 400, ['Step: ',num2str(i)], ...
                        'FontSize', 18, ...
                        'FontWeight', 'bold', ...
                        'Color', [0.2 0.2 0.2]);        

            x1 = solution_pairs(i, 1);
            y1 = solution_pairs(i, 2);
            x2 = solution_pairs(i, 3);
            y2 = solution_pairs(i, 4);
            if x1 == x2
                if y1 < y2
                    for y = y1:y2
                        set(drawPicHdl(x1,y),'CData',ones(100,100,3).*0.95);
                    end
                else
                    for y = y2:y1
                        set(drawPicHdl(x1,y),'CData',ones(100,100,3).*0.95);
                    end
                end
            elseif y1 == y2
                if x1 < x2
                    for x = x1:x2
                        set(drawPicHdl(x,y1),'CData',ones(100,100,3).*0.95);
                    end
                else
                    for x = x2:x1
                        set(drawPicHdl(x,y1),'CData',ones(100,100,3).*0.95);
                    end
                end
            end
             pause(1)
            delete(step_text);
        end

        delete(game_status_text);

        game_status_text = text(700, 300, ['Auto Solving Finished!'], ...
                            'FontSize', 18, ...
                            'FontWeight', 'bold', ...
                            'Color', [0.2 0.2 0.2]);   
        pause(2)
        delete(game_status_text)
    end

    % Callback function
        function clickOnPic(object,~)
            delete(count_text);
            delete(invalid_text);
            delete(game_status_text);
      
            clickPos=[str2num(object.Tag(1)),str2num(object.Tag(2))];
            if isempty(selectedPos)
                selectedPos=clickPos;
            else
                x1=selectedPos(1);
                y1=selectedPos(2);
                x2=clickPos(1);
                y2=clickPos(2);
                [result_board, valid, count]=check_board_play(board, x1, y1, x2, y2);
                board = result_board;
                % Is the count valid?
                
                % % Draw link line
                % link_line=[selectedPos;clickPos];
                % link_lineX=(link_line(:,1)-1).*100+(link_line(:,1)-1).*5+50;
                % link_lineY=(link_line(:,2)-1).*100+(link_line(:,2)-1).*5+50;
                % line=plot(link_lineX,link_lineY,'Color',[0 0 0],'LineWidth',2);
                % pause(0.3)
                % delete(line)
               
                
                if valid 
                    % Display count
                    count_text = text(700, 100, ['Matched Tile Number: ',num2str(count)], ...
                        'FontSize', 18, ...
                        'FontWeight', 'bold', ...
                        'Color', [0.2 0.2 0.2]);
                    % Update board
                    board = result_board;
                    % Update GUI board
                    if x1 == x2
                        if y1 < y2
                            for y = y1:y2
                                set(drawPicHdl(x1,y),'CData',ones(100,100,3).*0.95);
                            end
                        else
                            for y = y2:y1
                                set(drawPicHdl(x1,y),'CData',ones(100,100,3).*0.95);
                            end
                        end
                    elseif y1 == y2
                        if x1 < x2
                            for x = x1:x2
                                set(drawPicHdl(x,y1),'CData',ones(100,100,3).*0.95);
                            end
                        else
                            for x = x2:x1
                                set(drawPicHdl(x,y1),'CData',ones(100,100,3).*0.95);
                            end
                        end
                    end
                    % for i=1:l
                    %     for j=1:w
                    %         if board(i,j) == 0 && ...
                    %             drawPicHdl(i,j)~=image( ...
                    % [(i-1)*100,i*100]+40+i*margin, ... %x
                    % [(j-1)*100,j*100]+40+j*margin,... %y
                    % picList.(['pic',num2str(board(i,j)+1)]), ...
                    % 'tag',[num2str(i),num2str(j)],...
                    % 'ButtonDownFcn',@clickOnPic)
                    %             set(drawPicHdl(i,j),'CData',ones(100,100,3).*0.95);
                    %         end
                    %     end
                    % end

                    % Check if game is over
                    [game_over, point_exist] = check_game_over(board);
                    [solution_pairs, solution_pairs_num] = solve_game(board, generated_pairs)
                    if game_over
                        if point_exist
                            game_status_text = text(700, 300, ['Game Over: FAILED.'], ...
                            'FontSize', 20, ...
                            'FontWeight', 'bold', ...
                            'Color', [1 0.698 0.4]);
                        else
                            game_status_text = text(700, 300, ['Game Over: SUCCESS!'], ...
                            'FontSize', 20, ...
                            'FontWeight', 'bold', ...
                            'Color', [0.549 0.8745 0.7765]);
                        end
                    end
                else
                    % msgbox("Invalid Play!");
                    invalid_text = text(700, 200, ['Invalid Operation!'], ...
                        'FontSize', 25, ...
                        'FontWeight', 'bold', ...
                        'Color', [1 0.4 0.4]);
                end
    
                % remove selected
                selectedPos=[];
                
                
            end
            
        end
    end
    
function [result_board, valid, count] = check_board_play(board, x1, y1, x2, y2)
    % 输入棋盘以及用户选择的两个子，输出当前选择结果的棋盘以及当前输入是否有效
    result_board = board;
    valid = false;
    kind = board(x1, y1);
    count = 0;
    if kind ~= 0
        if (x1 == x2 && y1 ~= y2)
            valid = true;
            if y1 < y2
                for y = y1:y2
                    if board(x1, y) ~= kind
                        valid = false;
                    end
                end
                if valid
                    for y = y1:y2
                        result_board(x1, y) = 0;
                        count = count + 1;
                    end
                end
            else
                for y = y2:y1
                    if board(x1, y) ~= kind
                        valid = false;
                    end
                end
                if valid
                    for y = y2:y1
                        result_board(x1, y) = 0;
                        count = count + 1;
                    end
                end
            end
        elseif (y1 == y2 && x1 ~= x2)
            valid = true;
            if x1 < x2
                for x = x1:x2
                    if board(x, y1) ~= kind
                        valid = false;
                    end
                end
                if valid
                    for x = x1:x2
                        result_board(x, y1) = 0;
                        count = count + 1;
                    end
                end
            else
                for x = x2:x1
                    if board(x, y1) ~= kind
                        valid = false;
                    end
                end
                if valid
                    for x = x2:x1
                        result_board(x, y1) = 0;
                        count = count + 1;
                    end
                end
            end
        end
    end
end

function [board, generated_pairs] = init_game_board(length, width, num_kinds, pairs)
    % generate board and pairs accordingt o input
    board = zeros(length, width);
    generated_pairs = zeros(pairs, 4);
    for i = 1:pairs
        kind = randi([1 num_kinds]); % init chess kinds
        x = randi([1 length]);
        y = randi([1 length]);
        generated_pairs(i, 1) = x;
        generated_pairs(i, 2) = y;
        direction = randi([1 4]); % generate direction from up, down, left, and right
        if direction == 1 && y ~= 1
            % up
            generated_pairs(i, 3) = x;
            limit = y - 1;
            num_points = randi([1 limit]);
            flag = true;
            for j = 0:num_points
                if board(x, y-j) ~= 0
                    flag = false;
                    % detect whether there is a different size in the way
                end
            end
            if flag
                for j = 0:num_points
                    board(x, y-j) = kind;
                end
                generated_pairs(i, 4) = y-num_points;
            end
        elseif direction == 2 && y ~= width
            % down
            generated_pairs(i, 3) = x;
            limit = width - y;
            num_points = randi([1 limit]);
            flag = true;
            for j = 0:num_points
                if board(x, y+j) ~= 0
                    flag = false;
                end
            end
            if flag
                for j = 0:num_points
                    board(x, y+j) = kind;
                end
                generated_pairs(i, 4) = y+num_points;
            end
        elseif direction == 3 && x ~= 1
            % left
            generated_pairs(i, 4) = y;
            limit = x - 1;
            num_points = randi([1 limit]);
            flag = true;
            for j = 0:num_points
                if board(x-j, y) ~= 0
                    flag = false;
                end
            end
            if flag
                for j = 0:num_points
                    board(x-j, y) = kind;
                end
                generated_pairs(i, 3) = x-num_points;
            end
        elseif direction == 4 && x ~= length
            % right
            generated_pairs(i, 4) = y;
            limit = length - x;
            num_points = randi([1 limit]);
            flag = true;
            for j = 0:num_points
                if board(x+j, y) ~= 0
                    flag = false;
                end
            end
            if flag
                for j = 0:num_points
                    board(x+j, y) = kind;
                end
                generated_pairs(i, 3) = x+num_points;
            end
        end
    end
end

function [game_over, point_exist] = check_game_over(board)
    % 输入棋盘，返回是否游戏结束，以及是否全部消除
    all_eliminated = true;
    point_exist = false;
    board_size = size(board);
    length = board_size(1);
    width = board_size(2);
    for x = 1:length
        for y = 1:width
            % 遍历所有点，判断是否全部消除，以及是否可解决
            if board(x, y) ~= 0
                point_exist = true;
                if x > 1 && board(x-1, y) == board(x, y)
                    all_eliminated = false;
                elseif x < length && board(x+1, y) == board(x, y)
                    all_eliminated = false;
                elseif y > 1 && board(x, y-1) == board(x, y)
                    all_eliminated = false;
                elseif y < width && board(x, y+1) == board(x, y)
                    all_eliminated = false;
                end
            end
        end
    end
    % 游戏结束条件：存在孤立的无法配对的点，或者所有点都已经被消除
    game_over = all_eliminated;
end

function [solution_pairs, solution_nums] = solve_game(board, generated_pairs)
    generated_pairs_size = size(generated_pairs);
    solution_nums = 0;
    solution_pairs = zeros(generated_pairs_size(1), 4);
    for i = 1:generated_pairs_size(1)
        x1 = generated_pairs(i, 1);
        y1 = generated_pairs(i, 2);
        x2 = generated_pairs(i, 3);
        y2 = generated_pairs(i, 4);
        flag = true;
        if x1 == 0 || x2 == 0 || y1 == 0 || y2 == 0
            flag = false;
        end
        if (flag)
            if x1 == x2
                y_start = 0;
                if y1 > y2
                    y_start = y2;
                else
                    y_start = y1;
                end
                y_end = y1 + y2 - y_start;
                solution_start = 0;
                solution_end = 0;
                for y = y_start:y_end
                    if board(x1, y) ~= 0
                        if solution_start == 0
                            solution_start = y;
                        end
                        solution_end = y;
                    end
                end
                if (solution_start ~= solution_end)
                    solution_nums = solution_nums + 1;
                    solution_pairs(solution_nums, 1) = x1;
                    solution_pairs(solution_nums, 2) = solution_start;
                    solution_pairs(solution_nums, 3) = x1;
                    solution_pairs(solution_nums, 4) = solution_end;
                end
            else
                x_start = 0;
                if x1 > x2
                    x_start = x2;
                else
                    x_start = x1;
                end
                x_end = x1 + x2 - x_start;
                solution_start = 0;
                solution_end = 0;
                for x = x_start:x_end
                    if board(x, y1) ~= 0
                        if solution_start == 0
                            solution_start = x;
                        end
                        solution_end = x;
                    end
                end
                if (solution_start ~= solution_end)
                    solution_nums = solution_nums + 1;
                    solution_pairs(solution_nums, 1) = solution_start;
                    solution_pairs(solution_nums, 2) = y1;
                    solution_pairs(solution_nums, 3) = solution_end;
                    solution_pairs(solution_nums, 4) = y1;
                end
            end
        end
    end
end
    
    
