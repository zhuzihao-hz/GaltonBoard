classdef GaltonBoard < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        GaltonBoardUIFigure  matlab.ui.Figure
        GraphPanel           matlab.ui.container.Panel
        UIAxes               matlab.ui.control.UIAxes
        ControlPanel         matlab.ui.container.Panel
        ExitButton           matlab.ui.control.Button
        StartButton          matlab.ui.control.Button
        PauseButton          matlab.ui.control.StateButton
        ClearButton          matlab.ui.control.Button
        ParameterPanel       matlab.ui.container.Panel
        NumberKnobLabel      matlab.ui.control.Label
        NumberKnob           matlab.ui.control.Knob
        Label                matlab.ui.control.Label
        Label_2              matlab.ui.control.Label
        PilotLampLabel       matlab.ui.control.Label
        PilotLamp            matlab.ui.control.Lamp
        VelocityKnobLabel    matlab.ui.control.Label
        VelocityKnob         matlab.ui.control.DiscreteKnob
        GraphPanel_2         matlab.ui.container.Panel
        UIAxes2              matlab.ui.control.UIAxes
    end


    methods (Access = private)
    
        function printfixedpoints(app)
            hold(app.UIAxes,'on')
            colormap(app.UIAxes,'cool');
            %绘制钉子
            for i =1:5
                for j=1:i
                    x(i,j)=3-0.5*i+1*(j-1);
                    y(i,j)=6-i;
                    plot(app.UIAxes,x(i,j),y(i,j),'o');
                end
            end
        end
        
        function drop(app)
            %小球的个数
            numofballs = round(app.NumberKnob.Value,0);
            %小球的速度
            velofballs = app.Label_2.Text/100;
            switch app.VelocityKnob.Value
                case '10'
                    velofballs=0.1;
                case '20'
                    velofballs=0.2;
                case '25'
                    velofballs=0.25;
                case '50'
                    velofballs=0.5;
            end
            %culx用于记录小球下落的最终位置
            culx = zeros(5);
            for i=1:numofballs
                x=2.5;
                y=6;
                %每一个小球下落至底
                while y>0
                    printfixedpoints(app);
                    hold(app.UIAxes,'on')
                    plot(app.UIAxes,x,y,'ro','MarkerFaceColor','r');
                    if y>5
                        y = y - velofballs;
                        %控制精度，防止出现没有停留在整点而不能判断方向
                        y=round(y,4);
                    else
                        y=round(y,4);
                        x=round(x,4);
                        if y==fix(y)
                            results = probadir(app);
                            y = y-velofballs;
                            x = x-velofballs*0.5*results;
                        else
                            y = y-velofballs;
                            x = x-velofballs*0.5*results;
                        end
                    end
                    pause(0.1)
                    
                end
                %每个小球下落完成后清空图一
                cla(app.UIAxes);
                if fix(x)>=0
                    if fix(x)==5
                        culx(5)=culx(5)+1;
                    else
                        culx(fix(x)+1)=culx(fix(x)+1)+1;
                    end
                else
                    culx(1)=culx(1)+1;
                end
                legend(app.UIAxes2,'off');
                bar(app.UIAxes2,culx)     
            end
            app.PilotLamp.Color = [1,0,0];
        end
        
        function results = probadir(app)
            pro=rand();
            %0.5的概率向左走
            if pro<=0.5
                results=1;
            %0.5的概率向右走
            else
                results=-1;
            end
        end
        
    end


    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            printfixedpoints(app)
            %启动时Pause设置为不能用
            app.PauseButton.Enable = 'off';
        end

        % Button pushed function: ExitButton
        function ExitButtonPushed(app, event)
            %关闭app
            close(app.GaltonBoardUIFigure);
        end

        % Button pushed function: StartButton
        function StartButtonPushed(app, event)
            %开始前先清空坐标区
            cla(app.UIAxes);
            cla(app.UIAxes2);
            app.PilotLamp.Color = [0,1,0];
            app.PauseButton.Text = 'Pasue';
            app.PauseButton.Value=0;
            %按下Start后Pause才可用
            app.PauseButton.Enable = 'on';
            drop(app);
        end

        % Value changed function: PauseButton
        function PauseButtonValueChanged(app, event)
            %Pause在Pause和Continue之间切换
            value = app.PauseButton.Value;
            if value==1
                app.PauseButton.Text = 'Continue';
                app.PilotLamp.Color = [1,0,0];
                waitfor(app)
            else
                app.PauseButton.Text = 'Pasue';
                app.PilotLamp.Color = [0,1,0];
                uiresume
            end 
        end

        % Value changed function: NumberKnob
        function NumberKnobValueChanged(app, event)
            %记录小球个数
            value = app.NumberKnob.Value;
            app.Label.Text = num2str(round(value,0));
        end

        % Value changed function: VelocityKnob
        function VelocityKnobValueChanged(app, event)
            %记录小球下落速度
            value = app.VelocityKnob.Value;
            app.Label_2.Text=value;
        end

        % Button pushed function: ClearButton
        function ClearButtonPushed(app, event)
            %清空坐标轴
            cla(app.UIAxes);
            cla(app.UIAxes2);
            app.PilotLamp.Color = [1,0,0];
            app.PauseButton.Text = 'Pasue';
            app.PauseButton.Value=0;
            app.PauseButton.Enable = 'off';
            pause();
        end
    end

    % App initialization and construction
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create GaltonBoardUIFigure
            app.GaltonBoardUIFigure = uifigure;
            app.GaltonBoardUIFigure.Colormap = [0.2431 0.149 0.6588;0.251 0.1647 0.7059;0.2588 0.1804 0.7529;0.2627 0.1961 0.7961;0.2706 0.2157 0.8353;0.2745 0.2353 0.8706;0.2784 0.2549 0.898;0.2784 0.2784 0.9216;0.2824 0.302 0.9412;0.2824 0.3216 0.9569;0.2784 0.3451 0.9725;0.2745 0.3686 0.9843;0.2706 0.3882 0.9922;0.2588 0.4118 0.9961;0.2431 0.4353 1;0.2196 0.4588 0.9961;0.1961 0.4863 0.9882;0.1843 0.5059 0.9804;0.1804 0.5294 0.9686;0.1765 0.549 0.9529;0.1686 0.5686 0.9373;0.1529 0.5922 0.9216;0.1451 0.6078 0.9098;0.1373 0.6275 0.898;0.1255 0.6471 0.8902;0.1098 0.6627 0.8745;0.0941 0.6784 0.8588;0.0706 0.6941 0.8392;0.0314 0.7098 0.8157;0.0039 0.7216 0.7922;0.0078 0.7294 0.7647;0.0431 0.7412 0.7412;0.098 0.749 0.7137;0.1412 0.7569 0.6824;0.1725 0.7686 0.6549;0.1922 0.7765 0.6235;0.2157 0.7843 0.5922;0.2471 0.7922 0.5569;0.2902 0.7961 0.5176;0.3412 0.8 0.4784;0.3922 0.8039 0.4353;0.4471 0.8039 0.3922;0.5059 0.8 0.349;0.5608 0.7961 0.3059;0.6157 0.7882 0.2627;0.6706 0.7804 0.2235;0.7255 0.7686 0.1922;0.7725 0.7608 0.1647;0.8196 0.749 0.1529;0.8627 0.7412 0.1608;0.902 0.7333 0.1765;0.9412 0.7294 0.2118;0.9725 0.7294 0.2392;0.9961 0.7451 0.2353;0.9961 0.7647 0.2196;0.9961 0.7882 0.2039;0.9882 0.8118 0.1882;0.9804 0.8392 0.1765;0.9686 0.8627 0.1647;0.9608 0.8902 0.1529;0.9608 0.9137 0.1412;0.9647 0.9373 0.1255;0.9686 0.9608 0.1059;0.9765 0.9843 0.0824];
            app.GaltonBoardUIFigure.Position = [100 100 1020 807];
            app.GaltonBoardUIFigure.Name = 'GaltonBoard';

            % Create GraphPanel
            app.GraphPanel = uipanel(app.GaltonBoardUIFigure);
            app.GraphPanel.Title = 'Graph';
            app.GraphPanel.FontSize = 14;
            app.GraphPanel.Position = [30 383 666 376];

            % Create UIAxes
            app.UIAxes = uiaxes(app.GraphPanel);
            app.UIAxes.DataAspectRatio = [9 6 1];
            app.UIAxes.PlotBoxAspectRatio = [1.22222222222222 1 1];
            app.UIAxes.XLim = [-3 8];
            app.UIAxes.YLim = [0 6];
            app.UIAxes.ZLim = [0 1];
            app.UIAxes.CLim = [0 1];
            app.UIAxes.GridColor = [0.15 0.15 0.15];
            app.UIAxes.MinorGridColor = [0.1 0.1 0.1];
            app.UIAxes.XColor = [0.15 0.15 0.15];
            app.UIAxes.XTick = [-2 -1 0 1 2 3 4 5 6 7];
            app.UIAxes.YColor = [0.15 0.15 0.15];
            app.UIAxes.YTick = [0 1 2 3 4 5 6];
            app.UIAxes.ZColor = [0.15 0.15 0.15];
            app.UIAxes.ZTick = [0 0.5 1];
            app.UIAxes.CameraPosition = [2.5 3 9.16025403784439];
            app.UIAxes.CameraTarget = [2.5 3 0.5];
            app.UIAxes.CameraUpVector = [0 1 0];
            app.UIAxes.Position = [44 12 579 327];

            % Create ControlPanel
            app.ControlPanel = uipanel(app.GaltonBoardUIFigure);
            app.ControlPanel.Title = 'Control';
            app.ControlPanel.FontSize = 14;
            app.ControlPanel.Position = [30 43 666 133];

            % Create ExitButton
            app.ExitButton = uibutton(app.ControlPanel, 'push');
            app.ExitButton.ButtonPushedFcn = createCallbackFcn(app, @ExitButtonPushed, true);
            app.ExitButton.FontSize = 20;
            app.ExitButton.Position = [490 37 107 47];
            app.ExitButton.Text = 'Exit';

            % Create StartButton
            app.StartButton = uibutton(app.ControlPanel, 'push');
            app.StartButton.ButtonPushedFcn = createCallbackFcn(app, @StartButtonPushed, true);
            app.StartButton.FontSize = 20;
            app.StartButton.Position = [72 37 107 47];
            app.StartButton.Text = 'Start';

            % Create PauseButton
            app.PauseButton = uibutton(app.ControlPanel, 'state');
            app.PauseButton.ValueChangedFcn = createCallbackFcn(app, @PauseButtonValueChanged, true);
            app.PauseButton.Text = 'Pause';
            app.PauseButton.FontSize = 20;
            app.PauseButton.Position = [218 37 107 47];

            % Create ClearButton
            app.ClearButton = uibutton(app.ControlPanel, 'push');
            app.ClearButton.ButtonPushedFcn = createCallbackFcn(app, @ClearButtonPushed, true);
            app.ClearButton.FontSize = 20;
            app.ClearButton.Position = [357 37 107 47];
            app.ClearButton.Text = 'Clear';

            % Create ParameterPanel
            app.ParameterPanel = uipanel(app.GaltonBoardUIFigure);
            app.ParameterPanel.Title = 'Parameter';
            app.ParameterPanel.FontSize = 14;
            app.ParameterPanel.Position = [765 43 185 716];

            % Create NumberKnobLabel
            app.NumberKnobLabel = uilabel(app.ParameterPanel);
            app.NumberKnobLabel.HorizontalAlignment = 'center';
            app.NumberKnobLabel.Position = [69 524 49 15];
            app.NumberKnobLabel.Text = 'Number';

            % Create NumberKnob
            app.NumberKnob = uiknob(app.ParameterPanel, 'continuous');
            app.NumberKnob.Limits = [20 300];
            app.NumberKnob.MajorTicks = [20 50 80 110 140 170 200 230 260 300];
            app.NumberKnob.ValueChangedFcn = createCallbackFcn(app, @NumberKnobValueChanged, true);
            app.NumberKnob.Position = [63 573 60 60];
            app.NumberKnob.Value = 20;

            % Create Label
            app.Label = uilabel(app.ParameterPanel);
            app.Label.HorizontalAlignment = 'center';
            app.Label.VerticalAlignment = 'center';
            app.Label.FontSize = 16;
            app.Label.Position = [64 472 63 23];
            app.Label.Text = '20';

            % Create Label_2
            app.Label_2 = uilabel(app.ParameterPanel);
            app.Label_2.HorizontalAlignment = 'center';
            app.Label_2.VerticalAlignment = 'center';
            app.Label_2.FontSize = 16;
            app.Label_2.Position = [65 232 57 26];
            app.Label_2.Text = '10';

            % Create PilotLampLabel
            app.PilotLampLabel = uilabel(app.ParameterPanel);
            app.PilotLampLabel.HorizontalAlignment = 'right';
            app.PilotLampLabel.Position = [54 125 29 15];
            app.PilotLampLabel.Text = 'Pilot';

            % Create PilotLamp
            app.PilotLamp = uilamp(app.ParameterPanel);
            app.PilotLamp.Position = [98 122 20 20];
            app.PilotLamp.Color = [1 0 0];

            % Create VelocityKnobLabel
            app.VelocityKnobLabel = uilabel(app.ParameterPanel);
            app.VelocityKnobLabel.HorizontalAlignment = 'center';
            app.VelocityKnobLabel.Position = [71 305 47 15];
            app.VelocityKnobLabel.Text = 'Velocity';

            % Create VelocityKnob
            app.VelocityKnob = uiknob(app.ParameterPanel, 'discrete');
            app.VelocityKnob.Items = {'10', '20', '25', '50'};
            app.VelocityKnob.ValueChangedFcn = createCallbackFcn(app, @VelocityKnobValueChanged, true);
            app.VelocityKnob.Position = [64 335 60 60];
            app.VelocityKnob.Value = '10';

            % Create GraphPanel_2
            app.GraphPanel_2 = uipanel(app.GaltonBoardUIFigure);
            app.GraphPanel_2.Title = 'Graph';
            app.GraphPanel_2.Position = [30 192 666 179];

            % Create UIAxes2
            app.UIAxes2 = uiaxes(app.GraphPanel_2);
            xlabel(app.UIAxes2, 'X')
            ylabel(app.UIAxes2, 'Y')
            app.UIAxes2.Position = [99 9 444 135];
        end
    end

    methods (Access = public)

        % Construct app
        function app = GaltonBoard

            % Create and configure components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.GaltonBoardUIFigure)

            % Execute the startup function
            runStartupFcn(app, @startupFcn)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.GaltonBoardUIFigure)
        end
    end
end