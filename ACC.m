clear;
clc;

%%initialize all the components.
a = arduino('COM5','Uno','Libraries',{'Ultrasonic' 'ExampleLCD/LCDAddon'});
speed = 0;
cur_speed = 0;
max_speed = 200;
set_speed = 0;
cursetspeed = 0;
increase = 'D13';
decrease = 'D12';
cruise = 'D11';
adp = 'D10';
cancel = 'A2';
cru = 0;
adc = 0;
tempStepCru = 0;
tempStepThreshCru = 7;
tempStep = 0;
tempStepThresh = 4;
set_adp_cruise = 0;
stored_speed = 0;


ultrasonicObj = ultrasonic(a,'D8','D9');
lcd = addon(a,'ExampleLCD/LCDAddon','RegisterSelectPin','D7','EnablePin','D6','DataPins',{'D5','D4','D3','D2'});
initializeLCD(lcd);

while 1

printLCD(lcd,'Speed');
printLCD(lcd,num2str(cur_speed));

inc_state = readDigitalPin(a,increase);
dec_state = readDigitalPin(a,decrease);
cru_state = readDigitalPin(a,cruise);
adp_state = readDigitalPin(a,adp);
can_state = readVoltage(a,cancel);

d = readDistance(ultrasonicObj);
distance = (d*343)/2;

if inc_state == 1 && cur_speed <= max_speed
    cur_speed = cur_speed + 1;
end
if dec_state == 1 && cur_speed > 0
    cur_speed = cur_speed - 1;
    printLCD(lcd,'Speed');
    printLCD(lcd,num2str(cur_speed));
end
if cru_state == 1
    set_speed = 1;
end
if set_speed == 0
    tempStepCru = tempStepCru + 1;
    if mod(tempStepCru , tempStepThreshCru) == 0 && cur_speed > 0
        cur_speed = cur_speed - 1;
        tempStepCru = 0;
    end
end
if adp_state == 1
    set_adp_cruise = 1;
end
if set_adp_cruise == 1
    tempStep = tempStep + 1;
    if distance < 20 && cur_speed > 0
        if stored_speed < cur_speed
            stored_speed = cur_speed;
        end
        if mod(tempStep , tempStepThresh ) == 0
            cur_speed = cur_speed - 1;
            tempStep = 0;
        end
    else
        if stored_speed > cur_speed
            if mod(tempStep , tempStepThresh ) == 0
                cur_speed = cur_speed + 1;
                tempStep = 0;
            end
        end
    end
end
if can_state > 4
    set_adp_cruise = 0;
    set_speed = 0;
end
thingSpeakWrite(1457868,cur_speed,'WriteKey','21WP3JEZRN1GFAD2');
end
