-- // toast notifs with progress

local toast = {};
toast.__index = toast;

local queue = {};

function toast.new(message, duration)
    if typeof(message) ~= "string" or message == "" then
        error("Message must be a valid string");
    end;

    if (duration ~= nil and typeof(duration) ~= "number") then
        error("Duration must be a number or nil");
    end;

    local frame = Instance.new("Frame");
    frame.Size = UDim2.new(0.2, 0, 0.05, 0);
    frame.BackgroundTransparency = 1;
    frame.Position = UDim2.new(-1, 0, 0, -frame.AbsoluteSize.Y);
    frame.Parent = gethui();

    local label = Instance.new("TextLabel");
    label.Size = UDim2.new(1, 0, 0.6, 0);
    label.Text = message;
    label.TextColor3 = Color3.fromRGB(255, 255, 255);
    label.TextSize = 14;
    label.BorderSizePixel = 0;
    label.BackgroundColor3 = Color3.new(0, 0, 0);
    label.BackgroundTransparency = 0.5;
    label.Parent = frame;

    local progress_bar = Instance.new("Frame");
    progress_bar.Size = UDim2.new(1, 0, 0.05, 0);
    progress_bar.Position = UDim2.new(0, 0, 0.6, 0);
    progress_bar.BackgroundColor3 = Color3.new(1, 1, 1);
    progress_bar.BorderSizePixel = 0;
    progress_bar.Parent = frame;

    table.insert(queue, frame);

    local function slide_in()
        frame:TweenPosition(
            UDim2.new(0, 10, 0, (#queue - 1) * 50 + 10),
            Enum.EasingDirection.InOut,
            Enum.EasingStyle.Sine,
            1,
            true
        );
    end;

    local function slide_out()
        frame:TweenPosition(UDim2.new(-1, 0, 0, -frame.AbsoluteSize.Y), Enum.EasingDirection.Out, Enum.EasingStyle.Sine, 1, true);
        wait(0.5);
        frame:Destroy();
        table.remove(queue, table.find(queue, frame));

        for index, notification in ipairs(queue) do
            notification:TweenPosition(
                UDim2.new(0, 10, 0, (index - 1) * 50 + 10),
                Enum.EasingDirection.InOut,
                Enum.EasingStyle.Sine,
                0.7,
                true
            );
        end;
    end;

    local function start_progress_bar()
        local elapsed_time = 0;

        while elapsed_time < duration do
            elapsed_time += task.wait();
            progress_bar.Size = UDim2.new(1 - (elapsed_time / duration), 0, 0.05, 0);
        end;
    end;

    slide_in();
    coroutine.wrap(start_progress_bar)();
    delay(duration or 3, slide_out);
end;

return toast;
